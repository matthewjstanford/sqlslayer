<# 
 .Synopsis
  Matt Stanford (SQLSlayer.com)

  Collector that gathers results of the CheckDB procedure.

 .Description
  Part of the DBACentral suite of database tools provided by SQLSlayer.  This
  collector gathers the results of the CheckDB procedure from the admin database.
  That procedure writes its results locally to the DatabaseMaintenance_CheckDB table
  in the admin database on each server.  This script just reads all of those distributed
  tables and centralizes the data on to DBACentral.

  This collector does require the admin database to be available on each target
  server as it relies on the usage of the CheckDB procedure.

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
   Collect-CheckDB.ps1

 .Example
   # Run in debug mode against only test servers (controlled by DBAC Server Attributes)
   Collect-CheckDB.ps1 -Debug
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

Log "Script Starting" "Begin" "" $MyInvocation.MyCommand.path

$DBAC = OpenDBAC;

if ($DBAC.State -ne "Open")
{
	$DBAC.Open()
}

#Query to get the server names
$Server_Query = @"
SELECT 
	[FullName]
    ,[DotNetConnectionString]
FROM [DBACentral].[dbo].[ServerInventory_SQL_AllServers_vw]
ORDER BY 1
"@

# Debug Query
if ($Debug) {
	$Server_Query = @"
	SELECT 
		s.[FullName]
		,s.[DotNetConnectionString]
	FROM [dbo].[ServerInventory_SQL_TestServers_vw]
	ORDER BY 1
"@
}

# The query to collect
$Product_Query = @"
USE [admin]

IF OBJECT_ID('[dbo].[DatabaseMaintenance_CheckDB]','U') IS NOT NULL
BEGIN
	DECLARE @Dt DATETIME
	
	SET @Dt = DATEADD(day,-10,GETDATE())

	SELECT 
		[DatabaseName]
		,[RunID]
		,[DateCreated]
		,[Error]
		,[Level]
		,[State]
		,[MessageText]
		,[RepairLevel]
		,[Status]
		,[DbId]
		,[ObjectID]
		,[IndexId]
		,[PartitionID]
		,[AllocUnitID]
		,[File]
		,[Page]
		,[Slot]
		,[RefFile]
		,[RefPage]
		,[RefSlot]
		,[Allocation]
	FROM [admin].[dbo].[DatabaseMaintenance_CheckDB]
	WHERE [DateCreated] > @Dt
END
ELSE
	SELECT TOP 0
		NULL AS [DatabaseName]
		,NULL AS [RunID]
		,NULL AS [DateCreated]
		,NULL AS [Error]
		,NULL AS [Level]
		,NULL AS [State]
		,NULL AS [MessageText]
		,NULL AS [RepairLevel]
		,NULL AS [Status]
		,NULL AS [DbId]
		,NULL AS [ObjectID]
		,NULL AS [IndexId]
		,NULL AS [PartitionID]
		,NULL AS [AllocUnitID]
		,NULL AS [File]
		,NULL AS [Page]
		,NULL AS [Slot]
		,NULL AS [RefFile]
		,NULL AS [RefPage]
		,NULL AS [RefSlot]
		,NULL AS [Allocation]
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
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[DatabaseMaintenance_InsertCheckDBResults]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";

			$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
			$Inserter.Parameters.Add("@DatabaseName",$Target_Reader["DatabaseName"]) | Out-Null
			$Inserter.Parameters.Add("@RunID",$Target_Reader["RunID"]) | Out-Null
			$Inserter.Parameters.Add("@DateCreated",$Target_Reader["DateCreated"]) | Out-Null
			$Inserter.Parameters.Add("@Error",$Target_Reader["Error"]) | Out-Null
			$Inserter.Parameters.Add("@Level",$Target_Reader["Level"]) | Out-Null
			$Inserter.Parameters.Add("@State",$Target_Reader["State"]) | Out-Null
			$Inserter.Parameters.Add("@MessageText",$Target_Reader["MessageText"]) | Out-Null
			$Inserter.Parameters.Add("@RepairLevel",$Target_Reader["RepairLevel"]) | Out-Null
			$Inserter.Parameters.Add("@Status",$Target_Reader["Status"]) | Out-Null
			$Inserter.Parameters.Add("@ObjectID",$Target_Reader["ObjectID"]) | Out-Null
			$Inserter.Parameters.Add("@IndexID",$Target_Reader["IndexID"]) | Out-Null
			$Inserter.Parameters.Add("@PartitionID",$Target_Reader["PartitionID"]) | Out-Null
			$Inserter.Parameters.Add("@AllocUnitID",$Target_Reader["AllocUnitID"]) | Out-Null
			$Inserter.Parameters.Add("@File",$Target_Reader["File"]) | Out-Null
			$Inserter.Parameters.Add("@Slot",$Target_Reader["Slot"]) | Out-Null
			$Inserter.Parameters.Add("@Page",$Target_Reader["Page"]) | Out-Null
			$Inserter.Parameters.Add("@RefFile",$Target_Reader["RefFile"]) | Out-Null
			$Inserter.Parameters.Add("@RefPage",$Target_Reader["RefPage"]) | Out-Null
			$Inserter.Parameters.Add("@RefSlot",$Target_Reader["RefSlot"]) | Out-Null
			$Inserter.Parameters.Add("@Allocation",$Target_Reader["Allocation"]) | Out-Null

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
