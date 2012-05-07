$LogFile = ".\Logs\SQLServer_Attribute_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

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
	[ServerID]
    ,[FullName]
    ,[DotNetConnectionString]
FROM [dbo].[ServerInventory_SQL_AllServers_vw]
ORDER BY 1
"@

# Debug Query
#$Server_Query = @"
#SELECT 
#	[ServerID]
#    ,[FullName]
#    ,[DotNetConnectionString]
#FROM [admin].[dbo].[ServerInventory_SQL_AllServers_vw]
#WHERE [FullName] IN ('SISBSS1','SDVDB1\OEC','SDVDB6\PV') 
#ORDER BY 1
#"@

# The query to collect
$Product_Query = @"
SELECT 'SQLServer_ServicePack' [Key], SERVERPROPERTY('ProductLevel') [Value] UNION
SELECT 'SQLServer_Edition',SERVERPROPERTY('Edition')UNION
SELECT 'SQLServer_Engine' ,CASE SERVERPROPERTY('EngineEdition') 
		WHEN 1 THEN 'Personal'
		WHEN 2 THEN 'Standard'
		WHEN 3 THEN 'Enterprise'
		WHEN 4 THEN 'Express'
	END UNION
SELECT 'SQLServer_Build', SERVERPROPERTY('ProductVersion')
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
	$ServerID = $_.ServerID;
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
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[dbo].[ServerInventory_SQL_SaveAttribute]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@ServerID",$ServerID) | Out-Null
		$Inserter.Parameters.Add("@AttribName",$Target_Reader["Key"]) | Out-Null
		$Inserter.Parameters.Add("@AttribValue",$Target_Reader["Value"]) | Out-Null
		$Inserter.ExecuteNonQuery() | out-null
		$Inserter.Dispose()
	}
	
	$Target_Reader.Dispose()
	$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
