<# 
 .Synopsis
  Matt Stanford (SQLSlayer.com)
  Collector for database backup history. 

 .Description
  Part of the DBACentral suite of database tools provided by SQLSlayer.  This
  collector gathers database backup history and stores it in the DBACentral 
  database for reporting purposes.

  This collector does not rely on the admin database in any way.

 .Parameter Verbose
  Should the script be verbose in it's output.

 .Parameter Debug
  Should the script run in debug mode with test servers.
 
 .Link
  http://www.SQLSlayer.com
  
 .Inputs
  None.  This collector is data driven from the DBACentral database.
  
 .Outputs
  None.  This collector writes to the DBACentral database.

 .Example
   # Normal run, will hit all configured servers from DBACentral
   Collect-BackupHistory.ps1

 .Example
   # Run in debug mode against only test servers (controlled by DBAC Server Attributes)
   Collect-BackupHistory.ps1 -Debug
#>
param(
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

$DBAC = OpenDBAC;

if ($DBAC.State -ne "Open")
{
	$DBAC.Open()
}

Log "Script Starting" "Begin" "" $MyInvocation.MyCommand.path

#Query to get the server names
$Server_Query = @"
SELECT 
	[FullName]
    ,[DotNetConnectionString]
FROM [dbo].[ServerInventory_SQL_AllServers_vw]
ORDER BY 1
"@

# Debug Query
if ($Debug) {
	$Server_Query = @"
	SELECT 
		s.[ServerID]
		,s.[FullName]
		,s.[DotNetConnectionString]
	FROM [dbo].[ServerInventory_SQL_TestServers_vw]
	ORDER BY 1
"@
}

# The query to collect
$Product_Query = @"
IF (@@microsoftversion / 0x1000000) & 0xff = 8
BEGIN
	EXEC('
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
		,0							AS [is_copy_only] -- 2005 and up
	FROM [msdb].[dbo].[backupset] bs
	INNER JOIN [msdb].[dbo].[backupmediafamily] bmf
	ON bs.[media_set_id] = bmf.[media_set_id]
	WHERE bmf.[family_sequence_number] = 1
	--AND bs.[server_name] = @@ServerName
	AND bs.[backup_start_date] > DATEADD(day,-3,GETDATE())')
END
ELSE IF (@@microsoftversion / 0x1000000) & 0xff IN (9,10)
BEGIN
	EXEC('
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
		,bs.[is_copy_only]	AS [is_copy_only]
	FROM [msdb].[dbo].[backupset] bs
	INNER JOIN [msdb].[dbo].[backupmediafamily] bmf
	ON bs.[media_set_id] = bmf.[media_set_id]
	WHERE bmf.[family_sequence_number] = 1
	AND bs.[server_name] = @@ServerName
	AND bs.[backup_start_date] > DATEADD(day,-3,GETDATE())')
END
"@

$dtServerList = GetServerList $DBAC $Server_Query

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerName = $_.FullName;
	$ConString = $_.DotNetConnectionString;
	
	Log "Now collecting data" "Progress" $ServerName $MyInvocation.MyCommand.path
	
	try
	{

		# Connect to the target server
		$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
		$cn_TargetServer.Open();
		
		# Get a SQL command object to the target server
		$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($Product_Query, $cn_TargetServer);

		$cmd_TargetServer.CommandTimeout = 30;
		
		$Target_Reader = $cmd_TargetServer.ExecuteReader();

		While ($Target_Reader.Read())
		{
			if ($DBAC.State -ne "Open")
			{
				$DBAC.Open()
			}
			
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Backups_SaveBackupHistory]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";

			$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
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
