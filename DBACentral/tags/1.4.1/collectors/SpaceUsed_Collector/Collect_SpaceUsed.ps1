$CurrentPath = "E:\Production\DBACentral\SpaceUsed_Collector"

$LogFile = "$CurrentPath\Logs\SpaceUsed_Collector_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

if ((Test-Path "$CurrentPath\Logs") -ne 1)
{
	New-Item "$CurrentPath\Logs" -type directory
}

# Start logging things
Start-Transcript -Path $LogFile

$cn_DBAServer = New-Object System.Data.SqlClient.SqlConnection("Data Source=DBACENTRAL;Integrated Security=SSPI;Initial Catalog=DBACentral;");

#Query to get the server names
$Server_Query = @"
SELECT 
	[ServerName]
	,[SQLVersion]
	,[CollectTable]
	,[CollectDatabase] 
	,[ConnectionString]
FROM [dbo].[SpaceUsed_CollectTableOrDatabase_vw] 
ORDER BY 1
"@

# Debug Query
#$Server_Query = @"
#SELECT 
#	[ServerName]
#	,[SQLVersion]
#	,[CollectTable]
#	,[CollectDatabase] 
#	,[ConnectionString]
#FROM [dbo].[SpaceUsed_CollectTableOrDatabase_vw] 
#WHERE [ServerName] IN ('SISBSS1','SDVDB1\OEC','SDVDB1\PV') 
#ORDER BY 1
#"@


$ds_ServerList = New-Object System.Data.DataSet "dsServerList"

$da_ServerList = New-Object System.Data.SqlClient.SqlDataAdapter ($Server_Query,$cn_DBAServer);
$da_ServerList.Fill($ds_ServerList) | Out-Null;

$dtServerList = New-Object System.Data.DataTable "dtServerList";
$dtServerList = $ds_ServerList.Tables[0];

#Read in the SQL File for getting the size info
$TableSizeSQL = Get-Content "$CurrentPath\Includes\TableSize.sql";
$DBSizeSQL = "EXEC [admin].[dbo].[SpaceUsed] @Summary = 2";

$ds_TableSizes = New-Object System.Data.DataSet "dsTableSizes"
$ds_DBSizes = New-Object System.Data.DataSet "dsDBSizes"

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerName = $_.ServerName;
	$SQLVersion = $_.SQLVersion;
	$DoTable = $_.CollectTable;
	$DoDB = $_.CollectDatabase;
	$ConString = $_.ConnectionString;
	
	"Now collecting data from $ServerName @ $(get-date)"

	# Connect to the target server
	$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
	$cn_TargetServer.Open();
	
	# If the "CollectTable" flag is set then collect table data
	if (($DoTable) -and ($SQLVersion -ge "2005"))
	{
		"	Collecting Table Size Data @ $(get-date)"
		# Get a SQL command object to the target server
		$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($TableSizeSQL, $cn_TargetServer);
	
		$cmd_TargetServer.CommandTimeout = 300;
		
		$Target_Reader = $cmd_TargetServer.ExecuteReader();
	
		While ($Target_Reader.Read())
		{
			if ($cn_DBAServer.State -ne "Open")
			{
				$cn_DBAServer.Open()
			}
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[SpaceUsed_TableSizes_InsertValue]",$cn_DBAServer);
			$Inserter.CommandType = "StoredProcedure";
	
			$Inserter.Parameters.Add("@ServerName",$Target_Reader["ServerName"]) | Out-Null
			$Inserter.Parameters.Add("@DBName",$Target_Reader["DBName"]) | Out-Null
			$Inserter.Parameters.Add("@SchemaName",$Target_Reader["SchemaName"]) | Out-Null
			$Inserter.Parameters.Add("@TableName",$Target_Reader["ObjectName"]) | Out-Null
			$Inserter.Parameters.Add("@RowCount",$Target_Reader["rows"]) | Out-Null
			$Inserter.Parameters.Add("@ReservedSpaceKB",$Target_Reader["reserved"]) | Out-Null
			$Inserter.Parameters.Add("@DataSpaceKB",$Target_Reader["data"]) | Out-Null
			$Inserter.Parameters.Add("@IndexSizeKB",$Target_Reader["index_size"]) | Out-Null
			$Inserter.Parameters.Add("@UnusedKB",$Target_Reader["unused"]) | Out-Null
			$Inserter.ExecuteNonQuery() | out-null
			$Inserter.Dispose()
		}
		
		$Target_Reader.Dispose()
		$cmd_TargetServer.Dispose()
	}
	
	# If the "CollectDatabase" flag is set then collect database data
	if ($DoDB)
	{
		"	Collecting Database Size Data @ $(get-date)"
		
		# Get a SQL command object to the target server
		$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($DBSizeSQL, $cn_TargetServer);
	
		$cmd_TargetServer.CommandTimeout = 300;
		
		$Target_Reader = $cmd_TargetServer.ExecuteReader();
		
		While ($Target_Reader.Read())
		{
			if ($cn_DBAServer.State -ne "Open")
			{
				$cn_DBAServer.Open()
			}
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[SpaceUsed_DatabaseSizes_InsertValue]",$cn_DBAServer);
			$Inserter.CommandType = "StoredProcedure";
			
			$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
			$Inserter.Parameters.Add("@DBName",$Target_Reader["DBName"]) | Out-Null
			$Inserter.Parameters.Add("@DataSizeMB",$Target_Reader["DataSizeMB"]) | Out-Null
			$Inserter.Parameters.Add("@LogSizeMB",$Target_Reader["LogSizeMB"]) | Out-Null
			$Inserter.Parameters.Add("@DataSizeUnusedMB",$Target_Reader["DataSizeUnusedMB"]) | Out-Null
			$Inserter.Parameters.Add("@LogSizeUnusedMB",$Target_Reader["LogSizeUnusedMB"]) | Out-Null
			$Inserter.ExecuteNonQuery() | out-null
			$Inserter.Dispose()
		}
		
		$Target_Reader.Dispose()
		$cmd_TargetServer.Dispose()
	}
	
};

Stop-Transcript
