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