$LogFile = ".\Logs\CheckDB_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

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
#	[FullName]
#    ,[DotNetConnectionString]
#FROM [DBACentral].[dbo].[ServerInventory_SQL_AllServers_vw]
#WHERE [FullName] IN ('SISBSS1','SISBSS1\SQL2000','SISBSS2','QASQL1\Legacy,1433') 
#ORDER BY 1
#"@

# The query to collect
$Product_Query = @"
USE [admin]

IF OBJECT_ID('[dbo].[DatabaseMaintenance_CheckDB]','U') IS NOT NULL
BEGIN
	DECLARE @Dt DATETIME
	
	SET @Dt = DATEADD(day,-10,GETDATE())

	SELECT 
		@@SERVERNAME AS [ServerName]
		,[CheckDBID]
		,[DatabaseName]
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
		@@SERVERNAME AS [ServerName]
		,NULL AS [CheckDBID]
		,NULL AS [DatabaseName]
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
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[DatabaseMaintenance_InsertCheckDBResults]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@ServerName",$Target_Reader["ServerName"]) | Out-Null
		$Inserter.Parameters.Add("@DatabaseName",$Target_Reader["DatabaseName"]) | Out-Null
		$Inserter.Parameters.Add("@CheckDBID",$Target_Reader["CheckDBID"]) | Out-Null
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

	
};

Stop-Transcript
