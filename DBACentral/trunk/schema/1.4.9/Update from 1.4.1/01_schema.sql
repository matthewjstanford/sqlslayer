USE [DBACentral]
GO

IF EXISTS (
	SELECT * 
	FROM fn_listextendedproperty(default, default, default, default, default, default, default)
	WHERE LEFT(CAST([value] AS VARCHAR(50)),5) = '1.4.1'
	AND [name] = 'Version'
)
BEGIN
	PRINT 'Current Version is 1.4.1  Lets begin the upgrade to 1.4.9.'
END
ELSE
BEGIN
	RAISERROR('Current Version of DBACentral is not 1.4.1, this script will not update successfully',16,2) WITH LOG
END


IF OBJECT_ID('[hist].[Jobs_SQL_Jobs_vw]','V') IS NOT NULL
	DROP VIEW [hist].[Jobs_SQL_Jobs_vw]
IF OBJECT_ID('[hist].[Metrics_QueryStats_vw]','V') IS NOT NULL
	DROP VIEW [hist].[Metrics_QueryStats_vw]
IF OBJECT_ID('[hist].[Metrics_QueryStats_Insert]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Metrics_QueryStats_Insert]

GO
/*******************************************************************************************************
**  Name:			[hist].[Jobs_SQL_Jobs_vw]
**  Desc:			View to pull back the job definitions from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
**	20100125	Matt Stanford	Fixed bug, now actually pulls the latest jobs only
********************************************************************************************************/
CREATE VIEW [hist].[Jobs_SQL_Jobs_vw]
AS

WITH CurrentJobs (HistJobID)
AS
(
	SELECT
		MAX([HistJobID])
	FROM [hist].[Jobs_SQL_Jobs]
	GROUP BY [HistServerID], [name]
)
SELECT
	s.[ServerName]
	,j.[name]
	,j.[job_id]
	,j.[HistJobID]
	,j.[enabled]
	,j.[description]
	,j.[start_step_id]
	,j.[category_id]
	,j.[owner_sid]
	,j.[delete_level]
	,j.[date_created]
	,j.[date_modified]
	,j.[version_number]
	,j.[DateCreated]
	,j.[LastSeenOn]
FROM [hist].[Jobs_SQL_Jobs] j
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON j.[HistServerID] = s.[HistServerID]
INNER JOIN [CurrentJobs] cj
	ON j.[HistJobID] = cj.[HistJobID]

GO
/*******************************************************************************************************
**  Name:			[hist].[Metrics_QueryStats_vw]
**  Desc:			View to pull query usage metrics from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009.12.15
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20100218	Matt Stanford	Removed the average columns, now calculating them
********************************************************************************************************/
CREATE VIEW [hist].[Metrics_QueryStats_vw]
AS
SELECT 
	s.[ServerName]
	,d.[DBName]
	,o.[SchemaName]
	,o.[ObjectName]
	,qs.[Count]
	,qs.[Total_CPU_Time]
	,qs.[Total_CPU_Time]/qs.[Count]				AS [AVG_CPU_Time]
	,qs.[Last_CPU]
	,qs.[Min_CPU]
	,qs.[Max_CPU]
	,qs.[Total_Run_Time]
	,qs.[Total_Run_Time]/qs.[Count]				AS [AVG_Run_Time]
	,qs.[Last_Run_Time]
	,qs.[Min_Run_Time]
	,qs.[Max_Run_Time]
	,qs.[Total_Logical_Writes]
	,qs.[Total_Logical_Writes]/qs.[Count]		AS [Avg_Logical_Writes]
	,qs.[Last_Logical_Writes]
	,qs.[Min_Logical_Writes]
	,qs.[Max_Logical_Writes]
	,qs.[Total_Physical_Reads]
	,qs.[Total_Physical_Reads]/qs.[Count]		AS [Avg_Physical_Reads]
	,qs.[Last_Physical_Reads]
	,qs.[Min_Physical_Reads]
	,qs.[Max_Physical_Reads]
	,qs.[Total_Logical_Reads]
	,qs.[Total_Logical_Reads]/qs.[Count]		AS [Avg_Logical_Reads]
	,qs.[Last_Logical_Reads]
	,qs.[Min_Logical_Reads]
	,qs.[Max_Logical_Reads]
	,qs.[SampleDate]
FROM [hist].[Metrics_QueryStats] qs
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON qs.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON qs.[HistDatabaseID] = d.[DatabaseID]
INNER JOIN [hist].[ServerInventory_SQL_ObjectIDs] o
	ON qs.[HistObjectID] = o.[ObjectID]


GO

USE [DBACentral]
GO

/****** Object:  StoredProcedure [hist].[Metrics_QueryStats_Insert]    Script Date: 02/18/2010 09:29:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************
**  Name:			[hist].[Metrics_QueryStats_Insert]
**  Desc:			Procedure to insert history values
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-12-11
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20100218	Matt Stanford	Removed the average columns
********************************************************************************************************/
CREATE PROCEDURE [hist].[Metrics_QueryStats_Insert] (
	@ServerName					VARCHAR(200)
	,@DBName					NVARCHAR(128)
	,@Schema					NVARCHAR(128)
	,@Object					NVARCHAR(128)
	,@Count						BIGINT 
	,@Total_CPU_Time			BIGINT 
	,@Last_CPU					BIGINT 
	,@Min_CPU					BIGINT 
	,@Max_CPU					BIGINT 
	,@Total_Run_Time			BIGINT 
	,@Last_Run_Time				BIGINT 
	,@Min_Run_Time				BIGINT 
	,@Max_Run_Time				BIGINT 
	,@Total_Logical_Writes		BIGINT 
	,@Last_Logical_Writes		BIGINT 
	,@Min_Logical_Writes		BIGINT 
	,@Max_Logical_Writes		BIGINT 
	,@Total_Physical_Reads		BIGINT 
	,@Last_Physical_Reads		BIGINT 
	,@Min_Physical_Reads		BIGINT 
	,@Max_Physical_Reads		BIGINT 
	,@Total_Logical_Reads		BIGINT 
	,@Last_Logical_Reads		BIGINT 
	,@Min_Logical_Reads			BIGINT 
	,@Max_Logical_Reads			BIGINT 
)
AS

-- Lookup the server id
DECLARE
	@HistServerID			INT
	,@HistObjectID			INT
	,@HistDatabaseID		INT
	
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @HistServerID OUTPUT

-- Get the database id
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @DBName, @HistDatabaseID OUTPUT

-- Get the object id
EXEC [hist].[ServerInventory_SQL_GetObjectID] @Object, @Schema, NULL, @HistObjectID OUTPUT

-- insert the data
INSERT INTO [hist].[Metrics_QueryStats] ([HistServerID], [HistDatabaseID], [HistObjectID], [Count], [Total_CPU_Time], [Last_CPU], [Min_CPU], [Max_CPU], [Total_Run_Time], [Last_Run_Time], [Min_Run_Time], [Max_Run_Time], [Total_Logical_Writes], [Last_Logical_Writes], [Min_Logical_Writes], [Max_Logical_Writes], [Total_Physical_Reads], [Last_Physical_Reads], [Min_Physical_Reads], [Max_Physical_Reads], [Total_Logical_Reads], [Last_Logical_Reads], [Min_Logical_Reads], [Max_Logical_Reads])
VALUES (@HistServerID,@HistDatabaseID, @HistObjectID,@Count, @Total_CPU_Time, @Last_CPU, @Min_CPU, @Max_CPU, @Total_Run_Time, @Last_Run_Time, @Min_Run_Time, @Max_Run_Time, @Total_Logical_Writes, @Last_Logical_Writes, @Min_Logical_Writes, @Max_Logical_Writes, @Total_Physical_Reads, @Last_Physical_Reads, @Min_Physical_Reads, @Max_Physical_Reads, @Total_Logical_Reads, @Last_Logical_Reads, @Min_Logical_Reads, @Max_Logical_Reads)


GO

IF EXISTS(SELECT * FROM sys.columns WHERE name = 'Avg_CPU_Time' AND object_id = OBJECT_ID('[hist].[Metrics_QueryStats]'))
	ALTER TABLE [hist].[Metrics_QueryStats] DROP COLUMN [Avg_CPU_Time]
IF EXISTS(SELECT * FROM sys.columns WHERE name = 'Avg_Run_Time' AND object_id = OBJECT_ID('[hist].[Metrics_QueryStats]'))
	ALTER TABLE [hist].[Metrics_QueryStats] DROP COLUMN [Avg_Run_Time]

GO
PRINT('Renaming constraints')
DECLARE 
	@DropCmd	NVARCHAR(4000)
	,@AddCmd	NVARCHAR(4000)

DECLARE #c CURSOR LOCAL STATIC FOR
WITH CTE (SchemaName,ObjectName,ColumnName,OldConstraintName,NewConstraintName,[definition])
AS
(
SELECT 
	s.[name]									AS [SchemaName]
	,o.[name]									AS [ObjectName]
	,c.[name]									AS [ColumnName]
	,dc.[name]									AS [OldConstraintName]
	,'DF__' + o.[name] + '__' + c.[name]		AS [NewConstraintName]
	,dc.[definition]
FROM [sys].[default_constraints] dc
INNER JOIN [sys].[objects] o
	ON o.[object_id] = dc.[parent_object_id]
INNER JOIN [sys].[columns] c
	ON dc.[parent_column_id] = c.[column_id]
	AND dc.[parent_object_id] = c.[object_id]
INNER JOIN [sys].[schemas] s
	ON o.[schema_id] = s.[schema_id]
WHERE dc.[is_system_named] = 1
AND dc.[is_ms_shipped] = 0
)
SELECT 
	'ALTER TABLE [' + t.[SchemaName] + '].[' + t.[ObjectName] + '] 
	DROP CONSTRAINT [' + t.[OldConstraintName] + ']'						AS [DropDefault]
	,'ALTER TABLE [' + t.[SchemaName] + '].[' + t.[ObjectName] + '] 
	ADD CONSTRAINT [' + t.[NewConstraintName] + '] 
	DEFAULT ' + t.[definition] + ' FOR [' + t.[ColumnName] + ']'			AS [AddDefault]
FROM CTE t

OPEN #c

FETCH NEXT FROM #c INTO @DropCmd, @AddCmd

WHILE @@FETCH_STATUS = 0
BEGIN

	PRINT('Drop Cmd: ' + @DropCmd)
	PRINT('Create Cmd: ' + @AddCmd)
	
	EXEC(@DropCmd)
	EXEC(@AddCmd)

	FETCH NEXT FROM #c INTO @DropCmd, @AddCmd
END
CLOSE #c
DEALLOCATE #c