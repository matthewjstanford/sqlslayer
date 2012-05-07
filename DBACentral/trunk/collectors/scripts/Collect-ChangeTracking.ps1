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

#Debug Query
if ($Debug) {
	$Server_Query = @"
	SELECT 
		[FullName]
	    ,[DotNetConnectionString]
	FROM [dbo].[ServerInventory_SQL_TestServers_vw]
	ORDER BY 1
"@
}

# The query to collect
$Product_Query = @"
SELECT 
	[DatabaseName]
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
      [DatabaseName]
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
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[ChangeTracking_SQL_GetServerDBObjectActionIDs]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";

			$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
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