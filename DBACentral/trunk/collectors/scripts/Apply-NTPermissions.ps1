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
$SQLStatement_Query = @"
SELECT 
	[FullName]
	,[DotNetConnectionString]
	,[SQLToExecute]
	,[Description]
FROM [admin].[dbo].[NTPermissions_SQLStatements_vw]
ORDER BY FullName, Sequence
"@

# Debug Query
if ($Debug) {
	$SQLStatement_Query = @"
	SELECT 
		[FullName]
		,[DotNetConnectionString]
		,[SQLToExecute]
		,[Description]
	FROM [admin].[dbo].[NTPermissions_SQLStatements_vw]
	Where FullName IN ('SISBSS1','SIPSQL3OLD\BLUE')
	ORDER BY FullName, Sequence
"@
}

$dtServerList = GetServerList $DBAC $SQLStatement_Query

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerName = $_.FullName;
	$SQLToExecute = $_.SQLToExecute;
	$Description = $_.Description;
	$ConString = $_.DotNetConnectionString;
	
	Log "Now applying NT permissions ($Description)" "Progress" $ServerName $MyInvocation.MyCommand.path

	try
	{
		# Connect to the target server
		$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
		$cn_TargetServer.Open();
		
		# Get a SQL command object to the target server
		$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($SQLToExecute, $cn_TargetServer);

		$cmd_TargetServer.CommandTimeout = 300;
			
		$cmd_TargetServer.ExecuteNonQuery() | Out-Null;
			
		$cmd_TargetServer.Dispose()
		
		Log "Finished applying NT permissions" "Progress" $ServerName $MyInvocation.MyCommand.path
	
	}
	catch
	{	
		Log "$error[0].ToString()" "Error" $ServerName $MyInvocation.MyCommand.path
	}
	finally
	{
		$cmd_TargetServer.Dispose()
	}
	
};

Log "Script Execution Complete" "End" "" $MyInvocation.MyCommand.path

$DBAC.Close()
$DBAC.Dispose()