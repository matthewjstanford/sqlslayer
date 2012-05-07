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
FROM [dbo].[ServerInventory_SQL_AllServers_vw]
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
SELECT
	dts.[name]
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
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[DTSStore_StorePackageData]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";

			$Inserter.Parameters.Add("@SourceServer",$ServerName) | Out-Null
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