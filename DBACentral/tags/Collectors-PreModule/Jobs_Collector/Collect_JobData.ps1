$LogFile = ".\Logs\Jobs_SQL_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

if ((Test-Path ".\Logs") -ne 1)
{
	New-Item ".\Logs" -type directory
}

# Start logging things
Start-Transcript -Path $LogFile

$cn_DBAServer = New-Object System.Data.SqlClient.SqlConnection("Data Source=DBACentral;Integrated Security=SSPI;Initial Catalog=DBACentral;");

#Query to get the server names
$Server_Query = @"
SELECT 
	[FullName]
    ,[DotNetConnectionString]
FROM [DBACentral].[dbo].[ServerInventory_SQL_AllServers_vw]
ORDER BY 1
"@

# Debug Query
#$Server_Query = @"
#SELECT 
#	[ServerID]
#    ,[FullName]
#    ,[DotNetConnectionString]
#FROM [DBACentral].[dbo].[ServerInventory_SQL_AllServers_vw]
#WHERE [FullName] IN ('SISBSS1','SDVDB1\OEC','SDVDB6\PV') 
#ORDER BY 1
#"@

# The query to collect
$Product_Query = @"
SELECT 
	@@SERVERNAME AS ServerName
	,[job_id]
	,[name]
	,[enabled]
	,[description]
	,[start_step_id]
	,[category_id]
	,[owner_sid]
	,[delete_level]
	,[date_created]
	,[date_modified]
	,[version_number]
FROM [msdb].[dbo].[sysjobs]

SELECT
	@@SERVERNAME			AS ServerName
	,sj.[name]				AS JobName
	,sjs.[step_id]
	,sjs.[step_name]
	,sjs.[subsystem]
	,sjs.[command]
	,sjs.[flags]
	,sjs.[additional_parameters]
	,sjs.[cmdexec_success_code]
	,sjs.[on_success_action]
	,sjs.[on_success_step_id]
	,sjs.[on_fail_action]
	,sjs.[on_fail_step_id]
	,sjs.[server]
	,sjs.[database_name]
	,sjs.[database_user_name]
	,sjs.[retry_attempts]
	,sjs.[retry_interval]
	,sjs.[os_run_priority]
	,sjs.[output_file_name]
from msdb.dbo.sysjobsteps sjs
INNER JOIN [msdb].[dbo].[sysjobs] sj
	ON sj.[job_id] = sjs.[job_id]

SELECT 
	@@SERVERNAME			AS ServerName
	,sj.[name]				AS JobName
	,sjh.[instance_id]
	,sjh.[step_id]
	,sjh.[step_name]
	,sjh.[sql_message_id]
	,sjh.[sql_severity]
	,sjh.[message]
	,sjh.[run_status]
	,sjh.[run_date]
	,sjh.[run_time]
	,sjh.[run_duration]
	,sjh.[operator_id_emailed] 
	,sjh.[operator_id_netsent]
	,sjh.[operator_id_paged]
	,sjh.[retries_attempted]
	,sjh.[server]
FROM [msdb].[dbo].[sysjobhistory] sjh
INNER JOIN [msdb].[dbo].[sysjobs] sj
	ON sj.[job_id] = sjh.[job_id]
WHERE sjh.[run_date] > (YEAR(DATEADD(day,-3,GETDATE())) * 10000) + (MONTH(DATEADD(day,-3,GETDATE())) * 100) + (DAY(DATEADD(day,-3,GETDATE())))
ORDER BY sjh.[instance_id]
"@

$ds_ServerList = New-Object System.Data.DataSet "dsServerList"

$da_ServerList = New-Object System.Data.SqlClient.SqlDataAdapter ($Server_Query,$cn_DBAServer);
$da_ServerList.Fill($ds_ServerList) | Out-Null;

$dtServerList = New-Object System.Data.DataTable "dtServerList";
$dtServerList = $ds_ServerList.Tables[0];

$CurrentPath = Get-Location

$ds_Product = New-Object System.Data.DataSet "dsProduct"

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerName = $_.FullName;
	$ConString = $_.DotNetConnectionString;
	$AtLeastOneJobWasAdded = 0;
	
	"Now collecting data from $ServerName @ $(get-date)"

	# Connect to the target server
	$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
	$cn_TargetServer.Open();
	
	# Get a SQL command object to the target server
	$ds_TargetServer = New-Object System.Data.DataSet "dsTargetServer"

	$da_TargetServer = New-Object System.Data.SqlClient.SqlDataAdapter ($Product_Query,$cn_TargetServer);
	$da_TargetServer.Fill($ds_TargetServer) | Out-Null;

	# Collect the 3 different recordsets
	$dt_sysjobs = $ds_TargetServer.Tables[0];
	
	$dt_sysjobsteps = $ds_TargetServer.Tables[1];
	
	$dt_sysjobhistory = $ds_TargetServer.Tables[2];
	
	# Try to insert all new job definitions
	$dt_sysjobs | ForEach-Object {
		if ($cn_DBAServer.State -ne "Open")
		{
			$cn_DBAServer.Open()
		}
		
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Jobs_SQL_InsertJob]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@ServerName",$_.ServerName) | Out-Null
		$Inserter.Parameters.Add("@job_id",$_.job_id) | Out-Null
		$Inserter.Parameters.Add("@name",$_.name) | Out-Null
		$Inserter.Parameters.Add("@enabled",$_.enabled) | Out-Null
		$Inserter.Parameters.Add("@description",$_.description) | Out-Null
		$Inserter.Parameters.Add("@start_step_id",$_.start_step_id) | Out-Null
		$Inserter.Parameters.Add("@category_id",$_.category_id) | Out-Null
		$Inserter.Parameters.Add("@owner_sid",$_.owner_sid) | Out-Null
		$Inserter.Parameters.Add("@delete_level",$_.delete_level) | Out-Null
		$Inserter.Parameters.Add("@date_created",$_.date_created) | Out-Null
		$Inserter.Parameters.Add("@date_modified",$_.date_modified) | Out-Null
		$Inserter.Parameters.Add("@version_number",$_.version_number) | Out-Null

		$ret = $Inserter.ExecuteScalar();
		
		$DidInsert;
		$Inserter.Dispose()
		
		if ($ret -gt 0)
		{
			#If we inserted at least one job definition then we'll re-reun through the job steps.  Otherwise we'll skip it
			$AtLeastOneJobWasAdded = 1;
		}
	}
	
	# If we had some jobs added, then process job steps
	if ($AtLeastOneJobWasAdded = 1)
	{
		$dt_sysjobsteps | ForEach-Object {
			if ($cn_DBAServer.State -ne "Open")
			{
				$cn_DBAServer.Open()
			}
			
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Jobs_SQL_InsertJobStep]",$cn_DBAServer);
			$Inserter.CommandType = "StoredProcedure";

			$Inserter.Parameters.Add("@ServerName",$_.ServerName) | Out-Null
			$Inserter.Parameters.Add("@JobName",$_.JobName) | Out-Null
			$Inserter.Parameters.Add("@step_id",$_.step_id) | Out-Null
			$Inserter.Parameters.Add("@step_name",$_.step_name) | Out-Null
			$Inserter.Parameters.Add("@subsystem",$_.subsystem) | Out-Null
			$Inserter.Parameters.Add("@command",$_.command) | Out-Null
			$Inserter.Parameters.Add("@flags",$_.flags) | Out-Null
			$Inserter.Parameters.Add("@additional_parameters",$_.additional_parameters) | Out-Null
			$Inserter.Parameters.Add("@cmdexec_success_code",$_.cmdexec_success_code) | Out-Null
			$Inserter.Parameters.Add("@on_success_action",$_.on_success_action) | Out-Null
			$Inserter.Parameters.Add("@on_success_step_id",$_.on_success_step_id) | Out-Null
			$Inserter.Parameters.Add("@on_fail_action",$_.on_fail_action) | Out-Null
			$Inserter.Parameters.Add("@on_fail_step_id",$_.on_fail_step_id) | Out-Null
			$Inserter.Parameters.Add("@server",$_.server) | Out-Null
			$Inserter.Parameters.Add("@database_name",$_.database_name) | Out-Null
			$Inserter.Parameters.Add("@database_user_name",$_.database_user_name) | Out-Null
			$Inserter.Parameters.Add("@retry_attempts",$_.retry_attempts) | Out-Null
			$Inserter.Parameters.Add("@retry_interval",$_.retry_interval) | Out-Null
			$Inserter.Parameters.Add("@os_run_priority",$_.os_run_priority) | Out-Null
			$Inserter.Parameters.Add("@output_file_name",$_.output_file_name) | Out-Null

			$Inserter.ExecuteNonQuery() | Out-Null
			$Inserter.Dispose()
		}
	
	
	}
	
	# Try to insert each row of sysjobhistory
	$dt_sysjobhistory | ForEach-Object {
	
		if ($cn_DBAServer.State -ne "Open")
		{
			$cn_DBAServer.Open()
		}
		
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Jobs_SQL_InsertJobHistory]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@ServerName",$_.ServerName) | Out-Null
		$Inserter.Parameters.Add("@JobName",$_.JobName) | Out-Null
		$Inserter.Parameters.Add("@instance_id",$_.instance_id) | Out-Null
		$Inserter.Parameters.Add("@step_id",$_.step_id) | Out-Null
		$Inserter.Parameters.Add("@step_name",$_.step_name) | Out-Null
		$Inserter.Parameters.Add("@sql_message_id",$_.sql_message_id) | Out-Null
		$Inserter.Parameters.Add("@sql_severity",$_.sql_severity) | Out-Null
		$Inserter.Parameters.Add("@message",$_.message) | Out-Null
		$Inserter.Parameters.Add("@run_status",$_.run_status) | Out-Null
		$Inserter.Parameters.Add("@run_date",$_.run_date) | Out-Null
		$Inserter.Parameters.Add("@run_time",$_.run_time) | Out-Null
		$Inserter.Parameters.Add("@run_duration",$_.run_duration) | Out-Null
		$Inserter.Parameters.Add("@operator_id_emailed",$_.operator_id_emailed) | Out-Null
		$Inserter.Parameters.Add("@operator_id_netsent",$_.operator_id_netsent) | Out-Null
		$Inserter.Parameters.Add("@operator_id_paged",$_.operator_id_paged) | Out-Null
		$Inserter.Parameters.Add("@retries_attempted",$_.retries_attempted) | Out-Null
		$Inserter.Parameters.Add("@server",$_.server) | Out-Null

		$Inserter.ExecuteNonQuery() | Out-Null
		$Inserter.Dispose()
	
	}
	
	#$Target_Reader.Dispose()
	#$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
