$LogFile = ".\Logs\Backups_History_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

if ((Test-Path ".\Logs") -ne 1)
{
	New-Item ".\Logs" -type directory
}

# Start logging things
Start-Transcript -Path $LogFile

$cn_DBAServer = New-Object System.Data.SqlClient.SqlConnection("Data Source=SISBSS2;Integrated Security=SSPI;Initial Catalog=DBACentral;");

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
	bs.[server_name]			AS [ServerName]
	,bs.[machine_name]			AS [MachineName]
	,bs.[database_name]			AS [DatabaseName]
	,bs.[backup_start_date]		AS [StartDate]
	,bs.[backup_finish_date]	AS [EndDate]
	,CAST(bs.[backup_size]/1024/1024 AS INT) as [Size_Mbytes]
	,bs.[type]					AS [BUType]
	,bs.[user_name]				AS [UserName]
	,bmf.[logical_device_name]	AS [LogicalDevice]
	,bmf.[physical_device_name] AS [PhysicalDevice]
FROM [msdb].[dbo].[backupset] bs
INNER JOIN [msdb].[dbo].[backupmediafamily] bmf
ON bs.[media_set_id] = bmf.[media_set_id]
WHERE bmf.[family_sequence_number] = 1
AND bs.[server_name] = @@ServerName
AND bs.[backup_start_date] > DATEADD(day,-3,GETDATE())
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
	
	"Now collecting data from $ServerName @ $(get-date)"

	# Connect to the target server
	$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
	$cn_TargetServer.Open();
	
	# Get a SQL command object to the target server
	$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($Product_Query, $cn_TargetServer);

	$cmd_TargetServer.CommandTimeout = 30;
	
	$Target_Reader = $cmd_TargetServer.ExecuteReader();

	While ($Target_Reader.Read())
	{
		if ($cn_DBAServer.State -ne "Open")
		{
			$cn_DBAServer.Open()
		}
		
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Backups_SaveBackupHistory]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@ServerName",$Target_Reader["ServerName"]) | Out-Null
		$Inserter.Parameters.Add("@MachineName",$Target_Reader["MachineName"]) | Out-Null
		$Inserter.Parameters.Add("@DatabaseName",$Target_Reader["DatabaseName"]) | Out-Null
		$Inserter.Parameters.Add("@StartDate",$Target_Reader["StartDate"]) | Out-Null
		$Inserter.Parameters.Add("@EndDate",$Target_Reader["EndDate"]) | Out-Null
		$Inserter.Parameters.Add("@Size_MBytes",$Target_Reader["Size_MBytes"]) | Out-Null
		$Inserter.Parameters.Add("@BUType",$Target_Reader["BUType"]) | Out-Null
		$Inserter.Parameters.Add("@UserName",$Target_Reader["UserName"]) | Out-Null
		$Inserter.Parameters.Add("@LogicalDevice",$Target_Reader["LogicalDevice"]) | Out-Null
		$Inserter.Parameters.Add("@PhysicalDevice",$Target_Reader["PhysicalDevice"]) | Out-Null

		$Inserter.ExecuteNonQuery() | out-null
		$Inserter.Dispose()
	}
	
	$Target_Reader.Dispose()
	$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
