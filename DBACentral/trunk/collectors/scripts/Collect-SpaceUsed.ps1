param(
	[switch]$AllServers,
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
	[ServerName]
	,[SQLVersion]
	,[CollectTable]
	,[CollectDatabase] 
	,[ConnectionString]
FROM [dbo].[SpaceUsed_CollectTableOrDatabase_vw] 
ORDER BY 1
"@

# Query to get all server names
if ($AllServers) {
$Server_Query = @"
SELECT 
	[FullName] AS [ServerName]
	,[SQLVersion]
	,1 AS [CollectTable]
	,1 AS [CollectDatabase] 
	,[DotNetConnectionString] AS [ConnectionString]
FROM [dbo].[ServerInventory_SQL_AllServers_vw]
ORDER BY 1
"@
}

# Debug Query
if ($Debug) {
	$Server_Query = @"
	SELECT 
		[ServerName]
		,[SQLVersion]
		,[CollectTable]
		,[CollectDatabase] 
		,[ConnectionString]
	FROM [dbo].[SpaceUsed_CollectTableOrDatabase_vw] 
	WHERE [UsedForTesting] = 1
	ORDER BY 1
"@
}

# Get Server list
$dtServerList = GetServerList $DBAC $Server_Query

#Table Size SQL statement
$TableSizeSQL = @"
SET NOCOUNT ON

IF OBJECT_ID('tempdb.dbo.#AllTables') IS NOT NULL
	DROP TABLE #AllTables

CREATE TABLE #AllTables (
	DBName		SYSNAME
	,SchemaName	SYSNAME
	,ObjectName	SYSNAME
	,ObjectID	INT
	,rows		BIGINT
	,reserved	BIGINT
	,data		BIGINT
	,index_size	BIGINT
	,unused		BIGINT
)

DECLARE 
	@DBName SYSNAME
	,@SQL	NVARCHAR(4000)

DECLARE #dbs CURSOR STATIC LOCAL FOR
SELECT name FROM sys.databases
WHERE source_database_id IS NULL
AND name NOT IN ('model','tempdb')
AND state_desc = 'ONLINE'
ORDER BY name

OPEN #dbs

FETCH NEXT FROM #dbs INTO @DBName

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @SQL = '
USE [' + @DBName + ']

DECLARE
	@objname		NVARCHAR(776)
	,@id			INT
	,@schema_id		INT
	,@type			CHAR(2) 
	,@pages			BIGINT
	,@logsize		BIGINT
	,@reservedpages BIGINT
	,@usedpages		BIGINT
	,@rowCount		BIGINT

DECLARE @Table NVARCHAR(4000)

DECLARE #c CURSOR LOCAL FAST_FORWARD FOR
SELECT ''['' + SCHEMA_NAME(schema_id) + ''].['' + name + '']'' 
FROM sys.objects WHERE type = ''U''

OPEN #c

FETCH NEXT FROM #c INTO @Table

WHILE @@FETCH_STATUS = 0
BEGIN

SET @ObjName = @Table

/*
**  Try to find the object.
*/
SELECT @id = object_id, @type = type, @schema_id = [schema_id] FROM sys.objects WHERE object_id = object_id(@objname)

/*
** Now calculate the summary data. 
*  Note that LOB Data and Row-overflow Data are counted as Data Pages.
*/
SELECT 
	@reservedpages = SUM (reserved_page_count),
	@usedpages = SUM (used_page_count),
	@pages = SUM (
		CASE
			WHEN (index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
			ELSE lob_used_page_count + row_overflow_used_page_count
		END
		),
	@rowCount = SUM (
		CASE
			WHEN (index_id < 2) THEN row_count
			ELSE 0
		END
		)
FROM sys.dm_db_partition_stats
WHERE object_id = @id;

/*
** Check if table has XML Indexes or Fulltext Indexes which use internal tables tied to this table
*/
IF (SELECT count(*) FROM sys.internal_tables WHERE parent_id = @id AND INTernal_type IN (202,204)) > 0 
BEGIN
	/*
	**  Now calculate the summary data. Row counts in these internal tables dont 
	**  contribute towards row count of original table.  
	*/
	SELECT 
		@reservedpages = @reservedpages + sum(reserved_page_count),
		@usedpages = @usedpages + sum(used_page_count)
	FROM sys.dm_db_partition_stats p, sys.internal_tables it
	WHERE it.parent_id = @id AND it.INTernal_type IN (202,204) AND p.object_id = it.object_id;
END

INSERT INTO #AllTables
SELECT 
	DBName = DB_NAME(),
	[schema] = SCHEMA_NAME(@schema_id),
	name = OBJECT_NAME (@id),
	[object_id] = @id,
	rows = @rowCount,
	[reserved] = @reservedpages * 8,
	[data] = @pages * 8,
	[index_size] = (CASE WHEN @usedpages > @pages THEN (@usedpages - @pages) ELSE 0 END) * 8,
	[unused] = (CASE WHEN @reservedpages > @usedpages THEN (@reservedpages - @usedpages) ELSE 0 END) * 8


	FETCH NEXT FROM #c INTO @Table
END

CLOSE #c
DEALLOCATE #c
'
	
	EXEC(@SQL)
		
	FETCH NEXT FROM #dbs INTO @DBName

END 

CLOSE #dbs
DEALLOCATE #dbs


SELECT 
	@@ServerName as ServerName
	,*
FROM #AllTables
ORDER BY 1,2,[Reserved] DESC
"@;

# DB Size SQL Statement
$DBSizeSQL = "EXEC [admin].[dbo].[SpaceUsed] @Summary = 2";

# Loop through each server from the server list and connect to it
$dtServerList | ForEach-Object { 
	$ServerName = $_.ServerName;
	$SQLVersion = $_.SQLVersion;
	$DoTable = $_.CollectTable;
	$DoDB = $_.CollectDatabase;
	$ConString = $_.ConnectionString;
	
	Log "Now collecting data" "Progress" $ServerName $MyInvocation.MyCommand.path
	
	try
	{

		# Connect to the target server
		$cn_TargetServer = New-Object System.Data.SqlClient.SqlConnection($ConString);
		$cn_TargetServer.Open();
	
		# If the "CollectTable" flag is set then collect table data
		if (($DoTable) -and ($SQLVersion -ge "2005"))
		{
			Log "Collecting Table Size Data" "Progress" $ServerName $MyInvocation.MyCommand.path
			# Get a SQL command object to the target server
			$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($TableSizeSQL, $cn_TargetServer);
		
			$cmd_TargetServer.CommandTimeout = 300;
			
			$Target_Reader = $cmd_TargetServer.ExecuteReader();
		
			While ($Target_Reader.Read())
			{
				if ($DBAC.State -ne "Open")
				{
					$DBAC.Open()
				}
				$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[SpaceUsed_TableSizes_InsertValue]",$DBAC);
				$Inserter.CommandType = "StoredProcedure";
		
				$Inserter.Parameters.Add("@ServerName",$ServerName) | Out-Null
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
			
			Log "Finished collecting Table Size Data" "Progress" $ServerName $MyInvocation.MyCommand.path
		}
		
		# If the "CollectDatabase" flag is set then collect database data
		if ($DoDB)
		{
			Log "Collecting Database Size Data" "Progress" $ServerName $MyInvocation.MyCommand.path
			
			# Get a SQL command object to the target server
			$cmd_TargetServer = New-Object System.Data.SqlClient.SqlCommand ($DBSizeSQL, $cn_TargetServer);
		
			$cmd_TargetServer.CommandTimeout = 300;
			
			$Target_Reader = $cmd_TargetServer.ExecuteReader();
			
			While ($Target_Reader.Read())
			{
				if ($DBAC.State -ne "Open")
				{
					$DBAC.Open()
				}
				$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[SpaceUsed_DatabaseSizes_InsertValue]",$DBAC);
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
			
			Log "Finished collecting Database Size Data" "Progress" $ServerName $MyInvocation.MyCommand.path
		}
		
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