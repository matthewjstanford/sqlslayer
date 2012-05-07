param(
	[switch]$AllServers,
	[switch]$Verbose,
	[switch]$Debug
)

# Start logging things
$local:ErrorActionPreference = "Stop"

Import-Module DBACCollector -Force -Global

if ($Verbose){$VerbosePreference = "Continue"}
if ($Debug){
	$DebugPreference = "Continue"
	$VerbosePreference = "Continue"
	GetConfig
	}

Log "Starting Script" "Begin" "" $MyInvocation.MyCommand.path

$DBAC = OpenDBAC;

if ($DBAC.State -ne "Open")
{
	$DBAC.Open()
}

#Query to get the server names
$Server_Query = @"
SELECT 
	sa.[ServerName]
	,sa.[SQLVersion]
	,s.[DotNetConnectionString] AS [ConnectionString]
FROM [dbo].[ServerInventory_SQL_ServerAttributes_vw] sa
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
	ON sa.[ServerID] = s.[ServerID]
WHERE sa.[AttributeName] = 'QueryStats_Collect'
AND sa.[AttributeValue] = 'TRUE'
"@

if ($AllServers) {
$Server_Query = @"
SELECT 
	s.[FullName]	AS [ServerName]
	,s.[SQLVersion]
	,s.[DotNetConnectionString] AS [ConnectionString]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] s
"@
}

# Debug Query
if ($Debug) {
$Server_Query = @"
	SELECT 
		s.[FullName]	AS [ServerName]
		,s.[SQLVersion]
		,s.[DotNetConnectionString]
	FROM [dbo].[ServerInventory_SQL_TestServers_vw]
	ORDER BY 1
"@
}

$QueryStats_Query = @"
SELECT 
	DB_NAME(st.[dbid])									AS [DBName]
	,OBJECT_SCHEMA_NAME(st.[objectid], st.[dbid])		AS [Schema]
	,OBJECT_NAME(st.[objectid], st.[dbid])				AS [Object]
	,SUM(qs.[execution_count])							AS [Count]
	,SUM(qs.[total_worker_time])						AS [Total_CPU_Time]
	,SUM(qs.[last_worker_time])							AS [Last_CPU]
	,SUM(qs.[min_worker_time])							AS [Min_CPU]
	,SUM(qs.[max_worker_time])							AS [Max_CPU]
	,SUM(qs.[total_elapsed_time])						AS [Total_Run_Time]
	,SUM(qs.[last_elapsed_time])						AS [Last_Run_Time]
	,SUM(qs.[min_elapsed_time])							AS [Min_Run_Time]
	,SUM(qs.[max_elapsed_time])							AS [Max_Run_Time]
	,SUM(qs.[total_logical_writes])						AS [Total_Logical_Writes]
	,SUM(qs.[last_logical_writes])						AS [Last_Logical_Writes]
	,SUM(qs.[min_logical_writes])						AS [Min_Logical_Writes]
	,SUM(qs.[max_logical_writes])						AS [Max_Logical_Writes]
	,SUM(qs.[total_physical_reads])						AS [Total_Physical_Reads]
	,SUM(qs.[last_physical_reads])						AS [Last_Physical_Reads]
	,SUM(qs.[min_physical_reads])						AS [Min_Physical_Reads]
	,SUM(qs.[max_physical_reads])						AS [Max_Physical_Reads]
	,SUM(qs.[total_logical_reads])						AS [Total_Logical_Reads]
	,SUM(qs.[last_logical_reads])						AS [Last_Logical_Reads]
	,SUM(qs.[min_logical_reads])						AS [Min_Logical_Reads]
	,SUM(qs.[max_logical_reads])						AS [Max_Logical_Reads]
FROM [sys].[dm_exec_query_stats] qs 
CROSS APPLY [sys].[dm_exec_sql_text](qs.[sql_handle]) st
WHERE st.[objectid] IS NOT NULL
AND DB_NAME(st.[dbid]) IS NOT NULL
GROUP BY st.[objectid], st.[dbid], st.[text]
"@

$dtServerList = GetServerList $DBAC $Server_Query

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerName = $_.ServerName;
	$SQLVersion = $_.SQLVersion;
	$ConString = $_.ConnectionString;
	
	Log "Now collecting data" "Progress" $ServerName $MyInvocation.MyCommand.path
	
	try
	{
		# Connect to the target server
		$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
		$cn_TargetServer.Open();
		
		$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($QueryStats_Query, $cn_TargetServer);

		$cmd_TargetServer.CommandTimeout = 300;
		
		$Target_Reader = $cmd_TargetServer.ExecuteReader();

		While ($Target_Reader.Read())
		{
			if ($DBAC.State -ne "Open")
			{
				$DBAC.Open()
			}
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Metrics_QueryStats_Insert]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";

			$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
			$Inserter.Parameters.Add("@DBName",$Target_Reader["DBName"]) | Out-Null
			$Inserter.Parameters.Add("@Schema",$Target_Reader["Schema"]) | Out-Null
			$Inserter.Parameters.Add("@Object",$Target_Reader["Object"]) | Out-Null
			$Inserter.Parameters.Add("@Count",$Target_Reader["Count"]) | Out-Null
			$Inserter.Parameters.Add("@Total_CPU_Time",$Target_Reader["Total_CPU_Time"]) | Out-Null
			$Inserter.Parameters.Add("@Last_CPU",$Target_Reader["Last_CPU"]) | Out-Null
			$Inserter.Parameters.Add("@Min_CPU",$Target_Reader["Min_CPU"]) | Out-Null
			$Inserter.Parameters.Add("@Max_CPU",$Target_Reader["Max_CPU"]) | Out-Null
			$Inserter.Parameters.Add("@Total_Run_Time",$Target_Reader["Total_Run_Time"]) | Out-Null
			$Inserter.Parameters.Add("@Last_Run_Time",$Target_Reader["Last_Run_Time"]) | Out-Null
			$Inserter.Parameters.Add("@Min_Run_Time",$Target_Reader["Min_Run_Time"]) | Out-Null
			$Inserter.Parameters.Add("@Max_Run_Time",$Target_Reader["Max_Run_Time"]) | Out-Null
			$Inserter.Parameters.Add("@Total_Logical_Writes",$Target_Reader["Total_Logical_Writes"]) | Out-Null
			$Inserter.Parameters.Add("@Last_Logical_Writes",$Target_Reader["Last_Logical_Writes"]) | Out-Null
			$Inserter.Parameters.Add("@Min_Logical_Writes",$Target_Reader["Min_Logical_Writes"]) | Out-Null
			$Inserter.Parameters.Add("@Max_Logical_Writes",$Target_Reader["Max_Logical_Writes"]) | Out-Null
			$Inserter.Parameters.Add("@Total_Physical_Reads",$Target_Reader["Total_Physical_Reads"]) | Out-Null
			$Inserter.Parameters.Add("@Last_Physical_Reads",$Target_Reader["Last_Physical_Reads"]) | Out-Null
			$Inserter.Parameters.Add("@Min_Physical_Reads",$Target_Reader["Min_Physical_Reads"]) | Out-Null
			$Inserter.Parameters.Add("@Max_Physical_Reads",$Target_Reader["Max_Physical_Reads"]) | Out-Null
			$Inserter.Parameters.Add("@Total_Logical_Reads",$Target_Reader["Total_Logical_Reads"]) | Out-Null
			$Inserter.Parameters.Add("@Last_Logical_Reads",$Target_Reader["Last_Logical_Reads"]) | Out-Null
			$Inserter.Parameters.Add("@Min_Logical_Reads",$Target_Reader["Min_Logical_Reads"]) | Out-Null
			$Inserter.Parameters.Add("@Max_Logical_Reads",$Target_Reader["Max_Logical_Reads"]) | Out-Null

			$Inserter.ExecuteNonQuery() | out-null
			$Inserter.Dispose()
		}
			
		$Target_Reader.Dispose()
		$cmd_TargetServer.Dispose()
		
		Log "Finished collecting data" "Progress" $ServerName $MyInvocation.MyCommand.path
	}
	catch
	{	
		Log "$error[0].ToString()" "Error" $ServerName $MyInvocation.MyCommand.path
	}
	finally
	{
		$Target_Reader.Dispose()
		$cmd_TargetServer.Dispose()
	}
	
};

Log "Script Execution Complete" "End" "" $MyInvocation.MyCommand.path

$DBAC.Close()
$DBAC.Dispose()
