$LogFile = "E:\Production\DBACentral\DTSStore_Collector\Logs\DTSStore_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

if ((Test-Path ".\Logs") -ne 1)
{
	New-Item ".\Logs" -type directory
}

# Start logging things
Start-Transcript -Path $LogFile

$cn_DBAServer = New-Object System.Data.SqlClient.SqlConnection("Data Source=DBACENTRAL;Integrated Security=SSPI;Initial Catalog=DBACentral;");

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
	@@ServerName AS [SourceServer]
	,dts.[name]
	,dts.[id]
	,dts.[versionid]
	,dts.[description]
	,dts.[categoryid]
	,dts.[createdate]
	,dts.[owner]
	,dts.[packagedata]
	,dts.[owner_sid]
	,dts.[packagetype]
FROM [msdb].[dbo].[sysdtspackages] dts
INNER JOIN (
SELECT
	[id] AS [PackageID]
	,MAX([createdate]) AS [CreateDate]
FROM [msdb].[dbo].[sysdtspackages]
GROUP BY [id]
) mv
	ON dts.[id] = mv.[PackageID]
	AND dts.[CreateDate] = mv.[CreateDate]
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
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[DTSStore_StorePackageData]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@SourceServer",$Target_Reader["SourceServer"]) | Out-Null
		$Inserter.Parameters.Add("@name",$Target_Reader["name"]) | Out-Null
		$Inserter.Parameters.Add("@id",$Target_Reader["id"]) | Out-Null
		$Inserter.Parameters.Add("@versionid",$Target_Reader["versionid"]) | Out-Null
		$Inserter.Parameters.Add("@description",$Target_Reader["description"]) | Out-Null
		$Inserter.Parameters.Add("@categoryid",$Target_Reader["categoryid"]) | Out-Null
		$Inserter.Parameters.Add("@createdate",$Target_Reader["createdate"]) | Out-Null
		$Inserter.Parameters.Add("@owner",$Target_Reader["owner"]) | Out-Null
		$Inserter.Parameters.Add("@packagedata",$Target_Reader["packagedata"]) | Out-Null
		$Inserter.Parameters.Add("@owner_sid",$Target_Reader["owner_sid"]) | Out-Null
		$Inserter.Parameters.Add("@packagetype",$Target_Reader["packagetype"]) | Out-Null

		$Inserter.ExecuteNonQuery() | out-null
		$Inserter.Dispose()
	}
	
	$Target_Reader.Dispose()
	$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
