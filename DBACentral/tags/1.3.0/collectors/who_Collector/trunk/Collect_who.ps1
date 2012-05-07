#$CurrentPath = "E:\Production\DBACentral\who_Collector"

#$LogFile = "$CurrentPath\Logs\who_Logger_Log_$(get-date -uformat ""%Y%m%d%H%M"").txt"

#if ((Test-Path "$CurrentPath\Logs") -ne 1)
#{
#	New-Item "$CurrentPath\Logs" -type directory
#}

# Start logging things
#Start-Transcript -Path $LogFile

$cn_DBAServer = New-Object System.Data.SqlClient.SqlConnection("Data Source=UHVSQLMAN01;Integrated Security=SSPI;Initial Catalog=DBACentral;");

#Query to get the server names
$Server_Query = @"
SELECT 
	a.[ServerID]
	,s.[FullName]
	,s.[DotNetConnectionString]
FROM [dbo].[ServerInventory_SQL_ServerAttributes_vw] a
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
	ON a.ServerID = s.ServerID
WHERE a.[AttribName] = 'Logging_who'
AND s.[Enabled] = 1
"@

# The query to collect
$Product_Query = @"
EXECUTE [admin].[dbo].[who]
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
		$Inserter = New-Object System.Data.SqlClient.SqlCommand("[audit].[Logging_who_Collector]",$cn_DBAServer);
		$Inserter.CommandType = "StoredProcedure";
		
		$Inserter.Parameters.Add("@ServerID",$ServerID) | Out-Null
		$Inserter.Parameters.Add("@SPID",$Target_Reader["SPID"]) | Out-Null
		$Inserter.Parameters.Add("@KPID",$Target_Reader["KPID"]) | Out-Null
		$Inserter.Parameters.Add("@DBName",$Target_Reader["DBName"]) | Out-Null
		$Inserter.Parameters.Add("@Query",$Target_Reader["Query"]) | Out-Null
		$Inserter.Parameters.Add("@Login",$Target_Reader["Login"]) | Out-Null
		$Inserter.Parameters.Add("@HostName",$Target_Reader["HostName"]) | Out-Null
		$Inserter.Parameters.Add("@Status",$Target_Reader["Status"]) | Out-Null
		$Inserter.Parameters.Add("@Command",$Target_Reader["Command"]) | Out-Null
		$Inserter.Parameters.Add("@BlkBy",$Target_Reader["BlkBy"]) | Out-Null
		$Inserter.Parameters.Add("@TranCount",$Target_Reader["TranCount"]) | Out-Null
		$Inserter.Parameters.Add("@ReadLockCount",$Target_Reader["ReadLockCount"]) | Out-Null
		$Inserter.Parameters.Add("@WriteLockCount",$Target_Reader["WriteLockCount"]) | Out-Null
		$Inserter.Parameters.Add("@SchemaLockCount",$Target_Reader["SchemaLockCount"]) | Out-Null	
		$Inserter.Parameters.Add("@WaitType",$Target_Reader["WaitType"]) | Out-Null
		$Inserter.Parameters.Add("@PercentComplete",$Target_Reader["PercentComplete"]) | Out-Null
		$Inserter.Parameters.Add("@EstCompTime",$Target_Reader["EstCompTime"]) | Out-Null
		$Inserter.Parameters.Add("@CPU",$Target_Reader["CPU"]) | Out-Null		
		$Inserter.Parameters.Add("@IO",$Target_Reader["IO"]) | Out-Null
		$Inserter.Parameters.Add("@Reads",$Target_Reader["Reads"]) | Out-Null
		$Inserter.Parameters.Add("@Writes",$Target_Reader["Writes"]) | Out-Null		
		$Inserter.Parameters.Add("@LastRead",$Target_Reader["LastRead"]) | Out-Null
		$Inserter.Parameters.Add("@LastWrite",$Target_Reader["LastWrite"]) | Out-Null
		$Inserter.Parameters.Add("@StartTime",$Target_Reader["StartTime"]) | Out-Null
		$Inserter.Parameters.Add("@LastBatch",$Target_Reader["LastBatch"]) | Out-Null
		$Inserter.Parameters.Add("@ProgramName",$Target_Reader["ProgramName"]) | Out-Null

		$Inserter.ExecuteNonQuery() 
		$Inserter.Dispose()
	}
	
	$Target_Reader.Dispose()
	$cmd_TargetServer.Dispose()

	
};

Stop-Transcript
