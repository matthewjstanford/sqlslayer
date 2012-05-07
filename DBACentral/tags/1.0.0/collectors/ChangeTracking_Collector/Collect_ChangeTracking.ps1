$LogFile = ".\Logs\ChangeTracking_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").log"

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

#Debug Query
#$Server_Query = @"
#SELECT 
#	[FullName]
#    ,[DotNetConnectionString]
#FROM [DBACentral].[dbo].[ServerInventory_SQL_AllServers_vw]
#WHERE [FullName] IN ('SISBSS1','SDVDB6\PV') 
#ORDER BY 1
#"@

# The query to collect
$Product_Query = @"
--Kathy Toth is awesome

SELECT 
	[ServerName]
	,[DatabaseName]
	,[Type]
	,[ChangeAction]
	,[Dt]
	,[Schema]
	,CASE 
	WHEN [SCHEMA] IS NULL
		THEN [Object]
	ELSE RIGHT([Object], LEN([Object]) -LEN([Schema])-1)
	END AS [Object]
 FROM (SELECT 
      @@SERVERNAME AS [ServerName]
      ,[DatabaseName]
      ,RIGHT(VSSItem,3) as [Type]
      ,[ChangeAction]
      ,CONVERT(VARCHAR(10),DATEADD(hour,-5,[RecCreatedDt]),111) as Dt
      ,CASE 
      WHEN CHARINDEX('.',VSSItem) = LEN(VSSItem) - 3
            THEN NULL
      WHEN CHARINDEX('.',VSSItem) > 0 
            THEN LEFT(VSSItem,CHARINDEX('.',VSSItem) - 1)
      ELSE NULL
      END as [Schema]
     ,LEFT(VSSItem,LEN(VSSItem) - 4) as [Object]
FROM [admin].[dbo].[ArchUtilChanges]
WHERE DatabaseName IS NOT NULL
AND DatabaseName NOT IN ('admin')
AND VSSItem NOT LIKE '%.USR'
AND VSSItem NOT LIKE '%.ROL'
AND CHARINDEX('.',VSSItem) > 0
AND RecCreatedDt > DATEADD(day,-7,GETDATE())
) t
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
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[ChangeTracking_SQL_GetServerDBObjectActionIDs]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";

		$Inserter.Parameters.Add("@ServerName",$Target_Reader["ServerName"]) | Out-Null
		$Inserter.Parameters.Add("@DatabaseName",$Target_Reader["DatabaseName"]) | Out-Null
		$Inserter.Parameters.Add("@SchemaName",$Target_Reader["Schema"]) | Out-Null
		$Inserter.Parameters.Add("@ObjectName",$Target_Reader["Object"]) | Out-Null
		$Inserter.Parameters.Add("@RefType",$Target_Reader["type"]) | Out-Null
		$Inserter.Parameters.Add("@ActionType",$Target_Reader["changeaction"]) | Out-Null
		$Inserter.Parameters.Add("@DateModified",$Target_Reader["dt"]) | Out-Null

		$Inserter.ExecuteNonQuery() | out-null
		$Inserter.Dispose()
	}
	
	$Target_Reader.Dispose()
	$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
