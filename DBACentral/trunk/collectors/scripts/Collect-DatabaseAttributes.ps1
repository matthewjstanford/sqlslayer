<# 
 .Synopsis
  Matt Stanford (SQLSlayer.com)

  Collector for database attributes. 

 .Description
  Part of the DBACentral suite of database tools provided by SQLSlayer.  This
  collector gathers database attributes in a narrow fashion and stores them 
  centrally for reporting purposes.

  This collector does require the admin database to be available on each target
  server as it relies on the DatabaseAttributes_vw view.

 .Parameter Verbose
  Should the script be verbose in it's output.

 .Parameter Debug
  Should the script run in debug mode with test servers.
 
 .Link
  http://www.SQLSlayer.com
  
 .Inputs
  None.  This collector is data driven from the DBACentral database.
  
 .Outputs
  None.  This collector writes to the DBACentral database.

 .Example
   # Normal run, will hit all configured servers from DBACentral
   Collect-DatabaseAttributes

 .Example
   # Run in debug mode against only test servers (controlled by DBAC Server Attributes)
   Collect-DatabaseAttributes -Debug
#>
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

# The query to collect SQL attributes
$Attribute_Query = @"
SELECT 
	[Database_Name]
	,[file_id]
	,[AttributeName]
	,[AttributeValue]
FROM [admin].[dbo].[DatabaseAttributes_vw]
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
		$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($Attribute_Query, $cn_TargetServer);

		$cmd_TargetServer.CommandTimeout = 30;
		
		$Target_Reader = $cmd_TargetServer.ExecuteReader();

		While ($Target_Reader.Read())
		{
			if ($DBAC.State -ne "Open")
			{
				$DBAC.Open()
			}
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[ServerInventory_SQL_SaveDatabaseAttribute]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";

			$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
			$Inserter.Parameters.Add("@DatabaseName",$Target_Reader["Database_Name"]) | Out-Null
			$Inserter.Parameters.Add("@file_id",$Target_Reader["file_id"]) | Out-Null
			$Inserter.Parameters.Add("@AttributeName",$Target_Reader["AttributeName"]) | Out-Null
			$Inserter.Parameters.Add("@AttributeValue",$Target_Reader["AttributeValue"]) | Out-Null
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
}
Log "Script Execution Complete" "End" "" $MyInvocation.MyCommand.path

$DBAC.Close()
$DBAC.Dispose()
