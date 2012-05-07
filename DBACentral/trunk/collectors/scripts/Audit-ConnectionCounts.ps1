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
"@

# Get the last RunID
$RunID_Query = @"
SELECT ISNULL(MAX([RunID]),0) + 1 AS [RunID] FROM [audit].[ConnectionCounts_RunIDs]
"@

# The query to collect
$Product_Query = @"
SELECT [cntr_value] FROM [master].[dbo].[sysperfinfo] WHERE [counter_name] = 'User Connections'
"@

# Retrieve RunID
$dtRunID = GetDataTable $DBAC $RunID_Query
$RunID = $dtRunID[0];
"RunID: $RunID"

# Retrieve server list
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
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[audit].[ConnectionCounts_Collector]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";
			
			$Inserter.Parameters.Add("@RunID",$RunID) | Out-Null
	        $Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
			$Inserter.Parameters.Add("@CntrValue",$Target_Reader["cntr_value"]) | Out-Null

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