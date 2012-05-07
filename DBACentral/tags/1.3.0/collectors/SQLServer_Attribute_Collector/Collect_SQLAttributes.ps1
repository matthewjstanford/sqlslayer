$LogFile = ".\Logs\SQLServer_Attribute_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

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

# The query to collect SQL attributes
$Attribute_Query = @"
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

$Configuration_Query = @"
IF (@@microsoftversion / 0x1000000) & 0xff = 8
BEGIN
	SELECT
		CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)) AS [ServerName]
		,CAST(c.[config] AS INT)				AS [configuration_id]
		,CAST(sv.[name] AS NVARCHAR(35))		AS [name]
		,CAST(c.[value] AS SQL_VARIANT)			AS [value]
		,CAST(sv.[low] AS SQL_VARIANT)			AS [minimum]
		,CAST(sv.[high] AS SQL_VARIANT)			AS [maximum]
		,CAST(cc.[value] AS SQL_VARIANT)		AS [value_in_use]
		,CAST(c.[comment] AS NVARCHAR(255))		AS [description]
		,CAST(CASE c.[status]
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN 0
			WHEN 3 THEN 1
			ELSE 0
		END AS BIT)								AS [is_dynamic]
		,CAST(CASE c.[status]
			WHEN 0 THEN 0
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			ELSE 0
		END AS BIT)								AS [is_advanced]
	FROM [master].[dbo].[sysconfigures] c
	INNER JOIN [master].[dbo].[syscurconfigs] cc
		ON c.[config] = cc.[config]
	INNER JOIN [master].[dbo].[spt_values] sv
		ON c.[config] = sv.[number]
	WHERE sv.[type] = 'C'
END
ELSE IF (@@microsoftversion / 0x1000000) & 0xff IN (9,10)
BEGIN
	SELECT 
		CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)) AS [ServerName]
		,CAST([configuration_id] AS INT)		AS [configuration_id]
		,CAST([name] AS NVARCHAR(35))			AS [name]
		,CAST([value] AS SQL_VARIANT)			AS [value]
		,CAST([minimum] AS SQL_VARIANT)			AS [minimum]
		,CAST([maximum] AS SQL_VARIANT)			AS [maximum]
		,CAST([value_in_use] AS SQL_VARIANT)	AS [value_in_use]
		,CAST([description] AS NVARCHAR(255))	AS [description]
		,CAST([is_dynamic] AS BIT)				AS [is_dynamic]
		,CAST([is_advanced] AS BIT)				AS [is_advanced]
	FROM sys.configurations

END
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
	$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($Attribute_Query, $cn_TargetServer);

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
	
	# Get a SQL command object to the target server for config collection
	$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($Configuration_Query, $cn_TargetServer);

	$cmd_TargetServer.CommandTimeout = 30;
	
	$Target_Reader = $cmd_TargetServer.ExecuteReader();

	While ($Target_Reader.Read())
	{
		if ($cn_DBAServer.State -ne "Open")
		{
			$cn_DBAServer.Open()
		}
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[ServerInventory_SQL_Configurations_InsertValue]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@ServerName",$Target_Reader["ServerName"]) | Out-Null
		$Inserter.Parameters.Add("@ConfigName",$Target_Reader["name"]) | Out-Null
		$Inserter.Parameters.Add("@ConfigValue",$Target_Reader["value"]) | Out-Null
		$Inserter.Parameters.Add("@ConfigValueInUse",$Target_Reader["value_in_use"]) | Out-Null
		$Inserter.ExecuteNonQuery() | out-null
		$Inserter.Dispose()
	}
	
	$Target_Reader.Dispose()
	$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
