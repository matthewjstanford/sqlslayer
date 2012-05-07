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
	[ServerID]
    ,[FullName]
    ,[DotNetConnectionString]
FROM [dbo].[ServerInventory_SQL_AllServers_vw]
ORDER BY 1
"@

# Debug Query
if ($Debug) {
$Server_Query = @"
	SELECT 
		[ServerID]
	    ,[FullName]
	    ,[DotNetConnectionString]
	FROM [dbo].[ServerInventory_SQL_TestServers_vw]
	ORDER BY 1
"@
}

# The query to collect SQL attributes
$Attribute_Query = @"
SET NOCOUNT ON;

DECLARE @SqlMajorVersion INT;
DECLARE @OldDllVersion VARCHAR(20);
DECLARE @OldExeVersion VARCHAR(20);
DECLARE @OldLicenseVersionId VARCHAR(1);
DECLARE @OldLicenseVersionText VARCHAR(20);
DECLARE @NewDllVersion VARCHAR(20);
DECLARE @NewExeVersion VARCHAR(20);
DECLARE @NewLicenseVersionId VARCHAR(1);
DECLARE @NewLicenseVersionText VARCHAR(20);
DECLARE @SerialNumber VARCHAR(30);
DECLARE @MachineName VARCHAR(128);
DECLARE @InstanceName VARCHAR(128);
DECLARE @CombinedName VARCHAR(128);

    SET @CombinedName = CAST(SERVERPROPERTY('ServerName') AS VARCHAR(128));
    IF @CombinedName IS NULL SET @CombinedName = '';
    
    IF (OBJECT_ID('tempdb..#SqbOutput')) IS NULL
      CREATE TABLE #SqbOutput (TextOutput VARCHAR(1024));
      
          -- If the SQL Backup components are already installed, attempt to get the current version details.
    IF OBJECT_ID('master..sqbutility') IS NOT NULL
      BEGIN
        -- A version has been installed, we need to find out which (we use #SqbOutput to get rid of the
        -- blank result sets)
        INSERT #SqbOutput EXECUTE master..sqbutility 30, @OldDllVersion OUTPUT;
        INSERT #SqbOutput EXECUTE master..sqbutility 1030, @OldExeVersion OUTPUT;
        INSERT #SqbOutput EXECUTE master..sqbutility 1021, @OldLicenseVersionId OUTPUT, NULL, @SerialNumber OUTPUT;
            --SELECT * from #SqbOutput

        -- Clean the temporary table
        DELETE FROM #SqbOutput;

        -- Convert the License Edition into Text
        SELECT @OldLicenseVersionText =
          CASE WHEN @OldLicenseVersionId = '0' THEN 'Trial: Expired'
               WHEN @OldLicenseVersionId = '1' THEN 'Trial'
               WHEN @OldLicenseVersionId = '2' THEN 'Standard'
               WHEN @OldLicenseVersionId = '3' THEN 'Professional'
               WHEN @OldLicenseVersionId = '6' THEN 'Lite'
          END
      END
    ELSE
      BEGIN
        SET @OldDllVersion = 'Not Installed';
        SET @OldExeVersion = 'Not Installed';
        SET @OldLicenseVersionId = '-1';
        SET @OldLicenseVersionText = NULL;
        SET @SerialNumber = NULL;
      END
   
   
      -- Installation flag not set, just return the old details
      SELECT @CombinedName AS SqlServerName, @OldDllVersion AS CurrentVersion, 
             @OldLicenseVersionText AS CurrentLicense, @SerialNumber AS SerialNumber;
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
		$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($Attribute_Query, $cn_TargetServer);
	
		$cmd_TargetServer.CommandTimeout = 30;
		
		$Target_Reader = $cmd_TargetServer.ExecuteReader();
	
		While ($Target_Reader.Read())
		{
			if ($DBAC.State -ne "Open")
			{
				$DBAC.Open()
			}
			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[dbo].[ServerInventory_SQL_SQLBackup_Audit_InsertValue]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";
	
			$Inserter.Parameters.Add("@ServerID",$ServerID) | Out-Null
			$Inserter.Parameters.Add("@Version",$Target_Reader["CurrentVersion"]) | Out-Null
			$Inserter.Parameters.Add("@License",$Target_Reader["CurrentLicense"]) | Out-Null
			$Inserter.Parameters.Add("@SerialNumber",$Target_Reader["SerialNumber"]) | Out-Null
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