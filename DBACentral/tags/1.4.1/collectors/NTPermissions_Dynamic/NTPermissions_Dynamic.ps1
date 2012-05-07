$LogFile = ".\Logs\NTPermissions_Dynamic_$(get-date -uformat ""%Y%m%d%H%M"").txt"

if ((Test-Path ".\Logs") -ne 1)
{
	New-Item ".\Logs" -type directory
}

# Start logging things
Start-Transcript -Path $LogFile

$cn_DBAServer = New-Object System.Data.SqlClient.SqlConnection("Data Source=DBACENTRAL;Integrated Security=SSPI;Initial Catalog=admin;");

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
#$Server_Query = @"
#SELECT 
#	[FullName]
#	,[DotNetConnectionString]
#	,[SQLToExecute]
#	,[Description]
#FROM [admin].[dbo].[NTPermissions_SQLStatements_vw]
#Where FullName IN ('SISBSS1','SIPSQL3OLD\BLUE')
#ORDER BY FullName, Sequence
#"@


$ds_ServerList = New-Object System.Data.DataSet "dsServerList"

$da_ServerList = New-Object System.Data.SqlClient.SqlDataAdapter ($SQLStatement_Query,$cn_DBAServer);
$da_ServerList.Fill($ds_ServerList) | Out-Null;

$dtServerList = New-Object System.Data.DataTable "dtServerList";
$dtServerList = $ds_ServerList.Tables[0];

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerName = $_.FullName;
	$SQLToExecute = $_.SQLToExecute;
	$Description = $_.Description;
	$ConString = $_.DotNetConnectionString;
	
	"Now applying NT permissions ($Description) to $ServerName @ $(get-date)"

	# Connect to the target server
	$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
	$cn_TargetServer.Open();
	
	# Get a SQL command object to the target server
	$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($SQLToExecute, $cn_TargetServer);

	$cmd_TargetServer.CommandTimeout = 300;
		
	$cmd_TargetServer.ExecuteNonQuery() | Out-Null;
		
	$cmd_TargetServer.Dispose()
	
};

Stop-Transcript
