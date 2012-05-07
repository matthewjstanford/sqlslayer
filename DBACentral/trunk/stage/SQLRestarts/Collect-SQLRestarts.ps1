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

Log "Starting Script" "Begin" "" $MyInvocation.MyCommand.path

$DBAC = OpenDBAC;

if ($DBAC.State -ne "Open")
{
	$DBAC.Open()
}

#Query to get the server names
$Server_Query = @"
SELECT 
	[ServerID]
	,[ServerName]
	,[InstanceName]
	,[FullName]
	,[DotNetConnectionString]
FROM [dbo].[ServerInventory_SQL_AllServers_vw]
ORDER BY 2, 3
"@

# Get the last RunID
$RunID_Query = @"
SELECT ISNULL(MAX([RunID]),0) + 1 AS [RunID] FROM [hist].[SQLRestarts_RunIDs]
"@

# Retrieve RunID
$dtRunID = GetDataTable $DBAC $RunID_Query
$RunID = $dtRunID[0];
"RunID: $RunID"

# The query to collect
# Remove @LogCount for the first run
$Product_Query = @"
EXEC [admin].[dbo].[ReadErrorLog] @FindRestarts = 1, @LogCount = 2
"@

$dtServerList = GetServerList $DBAC $Server_Query

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerID = $_.ServerID;
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

		# Change the timeout to a much higher number (like 2400) for the first run
		$cmd_TargetServer.CommandTimeout = 600;
		
		$Target_Reader = $cmd_TargetServer.ExecuteReader();

		While ($Target_Reader.Read())
		{
			if ($DBAC.State -ne "Open")
			{
				$DBAC.Open()
			}
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[SQLRestarts_Collector_InsertValue]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";
			
			$Inserter.Parameters.Add("@RunID",$RunID) | Out-Null
			$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
			$Inserter.Parameters.Add("@TimeOfRestart",$Target_Reader["TimeOfRestart"]) | Out-Null
			$Inserter.Parameters.Add("@OutageInSeconds",$Target_Reader["OutageInSeconds"]) | Out-Null

			$Inserter.ExecuteNonQuery() 
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