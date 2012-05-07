$CurrentPath = "E:\Production\DBACentral\TestConnections_Collector"

$LogFile = "$CurrentPath\Logs\TestConnections_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

if ((Test-Path "$CurrentPath\Logs") -ne 1)
{
	New-Item "$CurrentPath\Logs" -type directory
}

# Start logging things
Start-Transcript -Path $LogFile

$cn_DBAServer = New-Object System.Data.SqlClient.SqlConnection("Data Source=UHVSQLMAN01;Integrated Security=SSPI;Initial Catalog=DBACentral;");

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

# The query to collect
$Product_Query = @"
SELECT @@SERVERNAME AS [LocalServerName], CAST(SERVERPROPERTY('ServerName') AS VARCHAR(64)) AS [ServerPropertyServerName]
"@

$ds_ServerList = New-Object System.Data.DataSet "dsServerList"

$da_ServerList = New-Object System.Data.SqlClient.SqlDataAdapter ($Server_Query,$cn_DBAServer);
$da_ServerList.Fill($ds_ServerList) ;

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
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[audit].[TestConnections_Collector]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";
		
		$Inserter.Parameters.Add("@ServerID",$ServerID) | Out-Null
		$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
		$Inserter.Parameters.Add("@InstanceName",$InstanceName) | Out-Null
		$Inserter.Parameters.Add("@LocalServerName",$Target_Reader["LocalServerName"]) | Out-Null
		$Inserter.Parameters.Add("@ServerPropertyServerName",$Target_Reader["ServerPropertyServerName"]) | Out-Null
		$Inserter.Parameters.Add("@CouldConnect",1) | Out-Null

		$Inserter.ExecuteNonQuery() 
		$Inserter.Dispose()
	}
	
	$Target_Reader.Dispose()
	$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
