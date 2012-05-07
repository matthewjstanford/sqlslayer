USE [DBACentral_Test]
GO

SET XACT_ABORT OFF
SET NOCOUNT ON

BEGIN TRANSACTION

IF EXISTS (
	SELECT * 
	FROM fn_listextendedproperty(default, default, default, default, default, default, default)
	WHERE LEFT(CAST([value] AS VARCHAR(50)),3) = '1.3'
	AND [name] = 'Version'
)
BEGIN
	PRINT 'Current Version is 1.3.x  Lets begin.'
END
ELSE
BEGIN
	RAISERROR('Current Version of DBACentral is not 1.3.x, this script will not update successfully',16,2) WITH LOG
END

-- Clean up if this is a re-run
-- Logging section
PRINT('Removing old collector objects')
IF OBJECT_ID('[collector].[ServerInventory_SQL_ConfigurationValues]','U') IS NOT NULL
	DROP TABLE [collector].[ServerInventory_SQL_ConfigurationValues]

-- 
IF OBJECT_ID('[rpt].[ServerInventory_SQL_Configurations_CompareServers]','P') IS NOT NULL
	DROP PROCEDURE [rpt].[ServerInventory_SQL_Configurations_CompareServers]
	
IF OBJECT_ID('[hist].[ServerInventory_SQL_ConfigurationValues_Current_vw]','V') IS NOT NULL
	DROP VIEW [hist].[ServerInventory_SQL_ConfigurationValues_Current_vw]

-- Change Control Schema
IF OBJECT_ID ('[hist].[ChangeControl_DeployHistory_Insert]','P') IS NOT NULL
	DROP PROCEDURE [hist].[ChangeControl_DeployHistory_Insert]
	
IF OBJECT_ID('[hist].[ChangeControl_DeployHistory_vw]','V') IS NOT NULL
	DROP VIEW [hist].[ChangeControl_DeployHistory_vw]

IF OBJECT_ID('[hist].[ChangeControl_DeployHistory]','U') IS NOT NULL
	DROP TABLE [hist].[ChangeControl_DeployHistory]
IF OBJECT_ID('[dbo].[ChangeControl_DeployDetail]','U') IS NOT NULL
	DROP TABLE [dbo].[ChangeControl_DeployDetail]
IF OBJECT_ID('[dbo].[ChangeControl_DeployMaster]','U') IS NOT NULL
	DROP TABLE [dbo].[ChangeControl_DeployMaster]
IF OBJECT_ID('[dbo].[ChangeControl_ChangeSetDetail]','U') IS NOT NULL
	DROP TABLE [dbo].[ChangeControl_ChangeSetDetail]
IF OBJECT_ID('[dbo].[ChangeControl_ChangeSet]','U') IS NOT NULL
	DROP TABLE [dbo].[ChangeControl_ChangeSet]
IF OBJECT_ID('[dbo].[ChangeControl_PackageMaster]','U') IS NOT NULL
	DROP TABLE [dbo].[ChangeControl_PackageMaster]
IF OBJECT_ID('[hist].[ChangeControl_ScriptDatabaseXref]','U') IS NOT NULL
	DROP TABLE [hist].[ChangeControl_ScriptDatabaseXref]
IF OBJECT_ID('[hist].[ChangeControl_ScriptMaster]','U') IS NOT NULL
	DROP TABLE [hist].[ChangeControl_ScriptMaster]

-- Index Information Structures
IF OBJECT_ID('[hist].[ServerInventory_SQL_ColumnNames]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_ColumnNames]
IF OBJECT_ID('[hist].[ServerInventory_SQL_IndexMaster]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_IndexMaster]
IF OBJECT_ID('[hist].[ServerInventory_SQL_IndexUsage]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_IndexUsage]
IF OBJECT_ID('[hist].[ServerInventory_SQL_IndexDetails]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_IndexDetails]
IF OBJECT_ID('[ref].[ServerInventory_SQL_DataTypes]','U') IS NOT NULL
	DROP TABLE [ref].[ServerInventory_SQL_DataTypes]
IF OBJECT_ID('[ref].[ServerInventory_SQL_ServerVersions]','U') IS NOT NULL
	DROP TABLE [ref].[ServerInventory_SQL_ServerVersions]

-- Powershell script objects
IF OBJECT_ID('[dbo].[Collectors_Log_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[Collectors_Log_InsertValue]
IF OBJECT_ID('[dbo].[Collectors_Log]','U') IS NOT NULL
	DROP TABLE [dbo].[Collectors_Log]
IF OBJECT_ID('[dbo].[Collectors_RecipeDetails]','U') IS NOT NULL
	DROP TABLE [dbo].[Collectors_RecipeDetails]
IF OBJECT_ID('[dbo].[Collectors_RecipeMaster]','U') IS NOT NULL
	DROP TABLE [dbo].[Collectors_RecipeMaster]
IF OBJECT_ID('[dbo].[Collectors_Scripts]','U') IS NOT NULL
	DROP TABLE [dbo].[Collectors_Scripts]

IF OBJECT_ID('[hist].[Metrics_QueryStats_Insert]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Metrics_QueryStats_Insert]
IF OBJECT_ID('[hist].[ServerInventory_SQL_GetObjectID]','P') IS NOT NULL
	DROP PROCEDURE [hist].[ServerInventory_SQL_GetObjectID]
IF OBJECT_ID('[hist].[Metrics_QueryStats]','U') IS NOT NULL
	DROP TABLE [hist].[Metrics_QueryStats]

-- Objects in the collector schema
PRINT('Removing old "collector" objects')
IF EXISTS(SELECT * FROM sys.schemas WHERE name = 'collector')
	EXEC ('DROP SCHEMA [collector]')

CREATE TABLE [dbo].[Collectors_Scripts] (
	[ScriptID]				INT IDENTITY CONSTRAINT [PK__Collectors_Scripts__ScriptID] PRIMARY KEY CLUSTERED ON [Primary]
	,[Name]					VARCHAR(200)
	,[Definition]			NVARCHAR(MAX)
	,[Enabled]				BIT CONSTRAINT [DF__Collectors_Scripts__Enabled] DEFAULT (1)
	,[Language]				VARCHAR(100)
	,[DateCreated]			SMALLDATETIME CONSTRAINT [DF__Collectors_Scripts__DateCreated] DEFAULT (GETDATE())
) ON [Primary]

CREATE TABLE [dbo].[Collectors_RecipeMaster] (
	[RecipeID]				INT IDENTITY CONSTRAINT [PK__Collectors_RecipeMaster__RecipeID] PRIMARY KEY CLUSTERED ON [Primary]
	,[Name]					VARCHAR(200)
	,[Description]			VARCHAR(1000)
	,[Enabled]				BIT CONSTRAINT [DF__Collectors_RecipeMaster__Enabled] DEFAULT (1)
	,[DateCreated]			SMALLDATETIME CONSTRAINT [DF__Collectors_RecipeMaster__DateCreated] DEFAULT (GETDATE())
)

CREATE TABLE [dbo].[Collectors_RecipeDetails] (
	[RecipeID]				INT CONSTRAINT [FK__Collectors_RecipeDetails__RecipeID__Collectors_RecipeMaster__RecipeID] FOREIGN KEY REFERENCES [dbo].[Collectors_RecipeMaster] ([RecipeID]) ON DELETE CASCADE
	,[ScriptID]				INT CONSTRAINT [FK__Collectors_RecipeDetails__ScriptID__Collectors_Scripts__ScriptID] FOREIGN KEY REFERENCES [dbo].[Collectors_Scripts] ([ScriptID]) ON DELETE CASCADE
	,[Sequence]				TINYINT
	,[Enabled]				BIT CONSTRAINT [DF__Collectors_RecipeDetails__Enabled] DEFAULT (1)
	,[DateCreated]			SMALLDATETIME CONSTRAINT [DF__Collectors_RecipeDetails__DateCreated] DEFAULT (GETDATE())
	,CONSTRAINT [PK__Collectors_RecipeDetails__RecipeID__ScriptID] PRIMARY KEY NONCLUSTERED
	(	
		[RecipeID]
		,[ScriptID]
	) ON [Primary]
) ON [Primary]

CREATE TABLE [dbo].[Collectors_Log] (
	[RecipeName]			VARCHAR(200)
	,[HistUserID]			INT	CONSTRAINT [FK__Collectors_Log__HistUserID__Users_UserNames__UserID] FOREIGN KEY REFERENCES [hist].[Users_UserNames] ([UserID])
	,[HistServerID]			INT CONSTRAINT [FK__Collectors_Log__HistServerID__ServerInventory_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([HistServerID])
	,[State]				VARCHAR(10)
	,[LogMessage]			VARCHAR(500)
	,[LogVersion]			SMALLINT
	,[DateCreated]			DATETIME CONSTRAINT [DF__Collectors_Log__DateCreated] DEFAULT (GETDATE())
) ON [Primary]

CREATE TABLE [ref].[ServerInventory_SQL_ServerVersions] (
	[RefSQLVersionID]		INT IDENTITY CONSTRAINT [PK__ServerInventory_SQL_ServerVersions__RefSQLVersionID] PRIMARY KEY CLUSTERED ON [Primary]
	,[SQLVersionText]		VARCHAR(10)
	,[SQLVersion]			DECIMAL(5,2)
	,[StartingBuild]		DECIMAL(7,2)
	,[EndingBuild]			DECIMAL(7,2)
) ON [Primary]

CREATE TABLE [ref].[ServerInventory_SQL_DataTypes] (
	[RefDataTypeID]			INT IDENTITY CONSTRAINT [PK__ServerInventory_SQL_DataTypes__RefDataTypeID] PRIMARY KEY CLUSTERED ON [Primary]
	,[RefSQLVersionID]		INT CONSTRAINT [FK__ServerInventory_SQL_DataTypes__RefSQLVersionID__ServerInventory_SQL_ServerVersions__RefSQLVersionID] FOREIGN KEY REFERENCES [ref].[ServerInventory_SQL_ServerVersions] ([RefSQLVersionID])
	,[name]					NVARCHAR(128)
	,[system_type_id]		INT
	,[max_length]			SMALLINT
	,[precision]			TINYINT
	,[scale]				TINYINT
) ON [Primary]

CREATE TABLE [hist].[ServerInventory_SQL_ColumnNames] (
	[HistColumnID]			INT IDENTITY CONSTRAINT [PK__ServerInventory_SQL_ColumnNames__HistColumnID] PRIMARY KEY CLUSTERED ON [History]
	,[ColumnName]			NVARCHAR(128)
	,[ColumnTypeID]			INT CONSTRAINT [FK__ServerInventory_SQL_ColumnNames__ColumnTypeID__ServerInventory_SQL_DataTypes__RefDataTypeID] FOREIGN KEY REFERENCES [ref].[ServerInventory_SQL_DataTypes] ([RefDataTypeID])
	,[DateCreated]			SMALLDATETIME CONSTRAINT [DF__ServerInventory_SQL_ColumnNames__DateCreated] DEFAULT (GETDATE())
) ON [History]

CREATE TABLE [hist].[ServerInventory_SQL_IndexMaster] (
	[HistIndexID]			INT IDENTITY CONSTRAINT [PK__ServerInventory_SQL_IndexMaster__HistIndexID] PRIMARY KEY CLUSTERED ON [History]
	,[HistServerDBTableID]	INT CONSTRAINT [FK__ServerInventory_SQL_IndexMaster__HistServerDBTableID__ServerInventory_SQL_ServerDBTableIDs__ServerDBTableID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_ServerDBTableIDs] ([ServerDBTableID])
	,[IndexName]			NVARCHAR(128)
	,[IndexType]			TINYINT
	,[is_unique]			BIT
	,[ignore_dup_key]		BIT
	,[is_primary_key]		BIT
	,[fillfactor]			TINYINT CONSTRAINT [CK__ServerInventory_SQL_IndexMaster__fillfactor] CHECK ([fillfactor] >= 100)
	,[is_padded]			BIT
	,[is_disabled]			BIT
	,[allow_row_locks]		BIT
	,[allow_page_locks]		BIT
	,[has_filter]			BIT
	,[DateCreated]			SMALLDATETIME CONSTRAINT [DF__ServerInventory_SQL_IndexMaster__DateCreated] DEFAULT (GETDATE())
	,[DateLastSeenOn]		SMALLDATETIME CONSTRAINT [DF__ServerInventory_SQL_IndexMaster__DateLastSeenOn] DEFAULT (GETDATE())
) ON [History]

CREATE TABLE [hist].[ServerInventory_SQL_IndexDetails] (
	[HistIndexID]			INT CONSTRAINT [FK__ServerInventory_SQL_IndexDetails__HistIndexID__ServerInventory_SQL_IndexMaster__HistIndexID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_IndexMaster] ([HistIndexID])
	,[HistColumnID]			INT CONSTRAINT [FK__ServerInventory_SQL_IndexDetails__HistColumnID__ServerInventory_SQL_ColumnNames__HistColumnID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_ColumnNames] ([HistColumnID])
	,[Sequence]				TINYINT
	,[IsDescending]			BIT
	,[DateCreated]			SMALLDATETIME CONSTRAINT [DF__ServerInventory_SQL_IndexDetails__DateCreated] DEFAULT (GETDATE())
) ON [History]

CREATE TABLE [hist].[ServerInventory_SQL_IndexUsage] (
	[HistIndexID]			INT CONSTRAINT [FK__ServerInventory_SQL_IndexUsage__HistIndexID__ServerInventory_SQL_IndexMaster__HistIndexID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_IndexMaster] ([HistIndexID]) 
	,[ReadCount]			BIGINT
	,[WriteCount]			BIGINT
	,[SampleDate]			SMALLDATETIME CONSTRAINT [DF__ServerInventory_SQL_IndexUsage__SampleDate] DEFAULT (GETDATE())
	,[SampleMSTicks]		BIGINT
) ON [History]

GO
/*******************************************************************************************************
**  Name:			[dbo].[Collectors_Log_InsertValue]
**  Desc:			Procedure to add logging information about the collectors
**  Auth:			Matt Stanford 
**  Date:			2009-10-13
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [dbo].[Collectors_Log_InsertValue] (
	@ServerName				VARCHAR(200)
	,@LoginName				NVARCHAR(50)
	,@RecipeName			VARCHAR(200)
	,@State					VARCHAR(10)
	,@LogMessage			VARCHAR(1000)
	,@LogVersion			SMALLINT
	,@RetentionDays			SMALLINT = 60
)
AS
SET NOCOUNT ON

DECLARE 
	@HistServerID			INT
	,@HistUserID			INT
	,@RetentionDate			DATETIME

-- Get the server ID	
EXEC [hist].[ServerInventory_GetServerID] @ServerName = @ServerName, @ServerID = @HistServerID OUTPUT

-- Get the user ID
EXEC [hist].[Users_GetUserID] @UserName = @LoginName, @UserID = @HistUserID OUTPUT

-- Insert the row
INSERT INTO [dbo].[Collectors_Log] ([RecipeName],[HistUserID],[HistServerID],[State],[LogMessage],[LogVersion],[DateCreated])
VALUES (@RecipeName,@HistUserID,@HistServerID,@State,@LogMessage,@LogVersion,GETDATE())

SET @RetentionDate = DATEADD(day,-@RetentionDays,GETDATE())

-- Trim up the data
DELETE l
FROM [dbo].[Collectors_Log] l
WHERE l.[DateCreated] < @RetentionDate
AND l.[RecipeName] = @RecipeName
AND l.[HistServerID] = @HistServerID

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_IndexUsage_vw] 
**  Desc:			View index usage data over time
**  Auth:			Matt Stanford 
**  Date:			2009-10-13
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [hist].[ServerInventory_SQL_IndexUsage_vw] 
AS

SELECT 
	im.[HistIndexID]
	,s.[ServerName]
	,d.[DBName]
	,t.[SchemaName]
	,t.[TableName]
	,im.[IndexName]
	,iu.[ReadCount]
	,iu.[WriteCount]
	,iu.[SampleMSTicks]
	,iu.[SampleDate]
FROM [hist].[ServerInventory_SQL_IndexMaster] im
INNER JOIN [hist].[ServerInventory_SQL_IndexUsage] iu
	ON im.[HistIndexID] = iu.[HistIndexID]
INNER JOIN [hist].[ServerInventory_SQL_ServerDBTableIDs] sdbt
	ON sdbt.[ServerDBTableID] = im.[HistServerDBTableID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON sdbt.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON sdbt.[DatabaseID] = d.[DatabaseID]
INNER JOIN [hist].[ServerInventory_SQL_TableIDs] t
	ON sdbt.[TableID] = t.[TableID]

GO

/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_Indexes_vw]
**  Desc:			View index information
**  Auth:			Matt Stanford 
**  Date:			2009-10-13
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [hist].[ServerInventory_SQL_Indexes_vw]
AS

SELECT
	s.[ServerName]
	,d.[DBName]
	,t.[SchemaName]
	,t.[TableName]
	,im.[IndexName]
	,KeyCols.[Col1] + KeyCols.[Col2] + KeyCols.[Col3] + KeyCols.[Col4] + KeyCols.[Col5] 
		+ KeyCols.[Col6] + KeyCols.[Col7] + KeyCols.[Col8] + KeyCols.[Col9] + KeyCols.[Col10] + KeyCols.[Col11] as KeyCols
	,NonKeyCols.[Col1] + NonKeyCols.[Col2] + NonKeyCols.[Col3] + NonKeyCols.[Col4] + NonKeyCols.[Col5] 
		+ NonKeyCols.[Col6] + NonKeyCols.[Col7] + NonKeyCols.[Col8] + NonKeyCols.[Col9] + NonKeyCols.[Col10] + NonKeyCols.[Col11] as NonKeyCols
FROM [hist].[ServerInventory_SQL_IndexMaster] im
INNER JOIN [hist].[ServerInventory_SQL_ServerDBTableIDs] sdbt
	ON sdbt.[ServerDBTableID] = im.[HistServerDBTableID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON sdbt.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON sdbt.[DatabaseID] = d.[DatabaseID]
INNER JOIN [hist].[ServerInventory_SQL_TableIDs] t
	ON sdbt.[TableID] = t.[TableID]
LEFT OUTER JOIN 
	(
	SELECT
		[HistIndexID]
		,'[' + [1] + ']' AS 'Col1'
		,ISNULL(',[' + [2] + ']','') AS 'Col2'
		,ISNULL(',[' + [3] + ']','') AS 'Col3'
		,ISNULL(',[' + [4] + ']','') AS 'Col4'
		,ISNULL(',[' + [5] + ']','') AS 'Col5'
		,ISNULL(',[' + [6] + ']','') AS 'Col6'
		,ISNULL(',[' + [7] + ']','') AS 'Col7'
		,ISNULL(',[' + [8] + ']','') AS 'Col8'
		,ISNULL(',[' + [9] + ']','') AS 'Col9'
		,ISNULL(',[' + [10] + ']','') AS 'Col10'
		,ISNULL(',[' + [11] + ']','') AS 'Col11'
	FROM (
		SELECT 
			ic.[HistIndexID]
			,c.[ColumnName]
			,ROW_NUMBER() OVER (PARTITION BY ic.[HistIndexID] ORDER BY ic.[Sequence]) pt
		FROM [hist].[ServerInventory_SQL_IndexDetails] ic
		INNER JOIN [hist].[ServerInventory_SQL_ColumnNames] c
			ON ic.[HistColumnID] = c.[HistColumnID]
		WHERE ic.[Sequence] >= 1 -- No nonkey columns
	) as ST
	PIVOT
	(
		MAX([ColumnName])
		FOR pt IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11])
	) as PvT
) AS KeyCols
	ON im.[HistIndexID] = KeyCols.[HistIndexID]
LEFT OUTER JOIN  (
	SELECT
		[HistIndexID]
		,'[' + [1] + ']' AS 'Col1'
		,ISNULL(',[' + [2] + ']','') AS 'Col2'
		,ISNULL(',[' + [3] + ']','') AS 'Col3'
		,ISNULL(',[' + [4] + ']','') AS 'Col4'
		,ISNULL(',[' + [5] + ']','') AS 'Col5'
		,ISNULL(',[' + [6] + ']','') AS 'Col6'
		,ISNULL(',[' + [7] + ']','') AS 'Col7'
		,ISNULL(',[' + [8] + ']','') AS 'Col8'
		,ISNULL(',[' + [9] + ']','') AS 'Col9'
		,ISNULL(',[' + [10] + ']','') AS 'Col10'
		,ISNULL(',[' + [11] + ']','') AS 'Col11'
	FROM (
		SELECT 
			ic.[HistIndexID]
			,c.[ColumnName]
			,ROW_NUMBER() OVER (PARTITION BY ic.[HistIndexID] ORDER BY ic.[Sequence]) pt
		FROM [hist].[ServerInventory_SQL_IndexDetails] ic
		INNER JOIN [hist].[ServerInventory_SQL_ColumnNames] c
			ON ic.[HistColumnID] = c.[HistColumnID]
		WHERE ic.[Sequence] = 0 -- No key columns
	) as ST
	PIVOT
	(
		MAX([ColumnName])
		FOR pt IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11])
	) as PvT
) AS NonKeyCols
	ON KeyCols.[HistIndexID] = NonKeyCols.[HistIndexID]

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_GetHistIndexID]
**  Desc:			Adds/Looks up the HistIndexID for each Index
**  Auth:			Matt Stanford
**  Date:			2009-10-13
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [hist].[ServerInventory_SQL_GetHistIndexID] (
	@ServerName				VARCHAR(200)
	,@DatabaseName			NVARCHAR(128)
	,@SchemaName			NVARCHAR(128)
	,@TableName				NVARCHAR(128)
	,@IndexName				NVARCHAR(128)
	,@IndexType				TINYINT
	,@is_unique				BIT
	,@ignore_dup_key		BIT
	,@is_primary_key		BIT
	,@fillfactor			TINYINT
	,@is_padded				BIT
	,@is_disabled			BIT
	,@allow_row_locks		BIT
	,@allow_page_locks		BIT
	,@has_filter			BIT
	,@HistIndexID			INT OUTPUT
)

AS
SET NOCOUNT ON

DECLARE
	@HistServerDBTableID	INT
	
-- Get the Server - DB - Schema - Table ID
EXEC [hist].[ServerInventory_SQL_GetServerDBTableID] 
	@ServerName			= @ServerName
	,@DatabaseName		= @DatabaseName
	,@SchemaName		= @SchemaName
	,@TableName			= @TableName
	,@ServerDBTableID	= @HistServerDBTableID OUTPUT
	
-- Lookup the index
SELECT 
	@HistIndexID = [HistIndexID]
FROM [hist].[ServerInventory_SQL_IndexMaster] im
WHERE [HistServerDBTableID] = @HistServerDBTableID
AND [IndexName] = @IndexName
AND [is_unique] = @is_unique
AND [ignore_dup_key] = @ignore_dup_key
AND [is_primary_key] = @is_primary_key
AND [fillfactor] = @fillfactor
AND [is_padded] = @is_padded
AND [is_disabled] = @is_disabled
AND [allow_row_locks] = @allow_row_locks
AND [allow_page_locks] = @allow_page_locks
AND [has_filter] = @has_filter

IF @HistIndexID IS NOT NULL
BEGIN -- Update the last seen date

	UPDATE [hist].[ServerInventory_SQL_IndexMaster]
		SET [DateLastSeenOn] = GETDATE()
	WHERE [HistIndexID] = @HistIndexID

END
ELSE -- Gotta do an insert
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_IndexMaster]
	VALUES (@HistServerDBTableID,@IndexName,@IndexType,@is_unique,@ignore_dup_key,@is_primary_key,@fillfactor,@is_padded
	,@is_disabled,@allow_row_locks,@allow_page_locks,@has_filter,GETDATE(),GETDATE())
	
	SET @HistIndexID = SCOPE_IDENTITY()
END

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_IndexUsage_InsertValue]
**  Desc:			Inserts Usage information for each index
**  Auth:			Matt Stanford
**  Date:			2009-10-13
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [hist].[ServerInventory_SQL_IndexUsage_InsertValue] (
	@ServerName				VARCHAR(200)
	,@DatabaseName			NVARCHAR(128)
	,@SchemaName			NVARCHAR(128)
	,@TableName				NVARCHAR(128)
	,@IndexName				NVARCHAR(128)
	,@IndexType				TINYINT
	,@is_unique				BIT
	,@ignore_dup_key		BIT
	,@is_primary_key		BIT
	,@fillfactor			TINYINT
	,@is_padded				BIT
	,@is_disabled			BIT
	,@allow_row_locks		BIT
	,@allow_page_locks		BIT
	,@has_filter			BIT
	,@ReadCount				BIGINT
	,@WriteCount			BIGINT
	,@SampleMSTicks			BIGINT
)
AS

SET NOCOUNT ON

DECLARE
	@HistIndexID			INT

EXEC [hist].[ServerInventory_SQL_GetHistIndexID] 
	@ServerName = @ServerName
	,@DatabaseName = @DatabaseName
	,@SchemaName = @SchemaName
	,@TableName = @TableName
	,@IndexName = @IndexName
	,@IndexType = @IndexType
	,@is_unique = @is_unique
	,@ignore_dup_key = @ignore_dup_key
	,@is_primary_key = @is_primary_key
	,@fillfactor = @fillfactor
	,@is_padded = @is_padded
	,@is_disabled = @is_disabled
	,@allow_row_locks = @allow_row_locks
	,@allow_page_locks = @allow_page_locks
	,@has_filter = @has_filter
	,@HistIndexID = @HistIndexID OUTPUT

INSERT INTO [hist].[ServerInventory_SQL_IndexUsage] ([HistIndexID],[ReadCount],[WriteCount],[SampleMSTicks],[SampleDate])
VALUES (@HistIndexID,@ReadCount,@WriteCount,@SampleMSTicks,GETDATE())

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_ConfigurationValues_Current_vw]
**  Desc:			View display only the current (or most current) configuration values
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-08-12
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [hist].[ServerInventory_SQL_ConfigurationValues_Current_vw]
AS

SELECT 
	s.[ServerName]
	,o.[configuration_id]
	,o.[name]
	,v.[value]
	,o.[minimum]
	,o.[maximum]
	,v.[value_in_use]
	,o.[description]
	,o.[is_dynamic]
	,o.[is_advanced]
	,v.[DateCreated]
	,v.[DateLastSeenOn]
FROM [hist].[ServerInventory_SQL_ConfigurationValues] v
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON v.[HistServerID]			= s.[HistServerID]
INNER JOIN [ref].[ServerInventory_SQL_ConfigurationOptions] o
	ON v.[RefConfigOptionID]	= o.[RefConfigOptionID]
INNER JOIN (
	SELECT 
		[RefConfigOptionID]
		,[HistServerID]
		,MAX([DateCreated]) AS [DateCreated]
	FROM [hist].[ServerInventory_SQL_ConfigurationValues]
	GROUP BY [RefConfigOptionID], [HistServerID]
) a
	ON a.[RefConfigOptionID]		= v.[RefConfigOptionID]
	AND a.[HistServerID]			= v.[HistServerID]
	AND a.[DateCreated]				= v.[DateCreated]

GO
/*******************************************************************************************************
**  Name:			[rpt].[ServerInventory_SQL_Configurations_CompareServers]
**  Desc:			Compares the current system configuration of two different servers
**  Auth:			Matt Stanford
**  Date:			2009-08-12
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [rpt].[ServerInventory_SQL_Configurations_CompareServers]
(
	@ServerA			VARCHAR(200)
	,@ServerB			VARCHAR(200)
	,@ShowDifferentOnly	BIT = 0
)
AS

--DECLARE 
--	@ServerA VARCHAR(200)
--	,@ServerB VARCHAR(200)

IF OBJECT_ID('tempdb.dbo.#ServerAVals') IS NOT NULL
	DROP TABLE #ServerAVals

IF OBJECT_ID('tempdb.dbo.#ServerBVals') IS NOT NULL
	DROP TABLE #ServerBVals

IF OBJECT_ID('tempdb.dbo.#ConfigOpts') IS NOT NULL
	DROP TABLE #ConfigOpts
	
-- Collect the union of the options between the two servers
SELECT DISTINCT
	[configuration_id]
	,[name]
	,[description]
	,[minimum]
	,[maximum]
	,[is_dynamic]
	,[is_advanced]
INTO #ConfigOpts
FROM [hist].[ServerInventory_SQL_ConfigurationValues_Current_vw]
WHERE [ServerName] IN (@ServerA,@ServerB)

-- Get all of Server A's current values
SELECT
	[ServerName]
	,[configuration_id]
	,[value]
	,[value_in_use]
	,[DateCreated]
	,[DateLastSeenOn]
INTO #ServerAVals
FROM [hist].[ServerInventory_SQL_ConfigurationValues_Current_vw]
WHERE [ServerName] = @ServerA

-- Get all of Server B's current values
SELECT
	[ServerName]
	,[configuration_id]
	,[value]
	,[value_in_use]
	,[DateCreated]
	,[DateLastSeenOn]
INTO #ServerBVals
FROM [hist].[ServerInventory_SQL_ConfigurationValues_Current_vw]
WHERE [ServerName] = @ServerB

SELECT
	@ServerA												AS [ServerA]
	,@ServerB												AS [ServerB]
	,co.[configuration_id]
	,co.[name]
	,co.[description]
	,co.[minimum]
	,co.[maximum]
	,co.[is_dynamic]
	,co.[is_advanced]
	,a.[value]												AS [ServerA_value]
	,b.[value]												AS [ServerB_value]
	,a.[value_in_use]										AS [ServerA_value_in_use]
	,b.[value_in_use]										AS [ServerB_value_in_use]
	,CASE 
		WHEN a.[value] = b.[value] 
			AND a.[value_in_use] = b.[value_in_use]
			THEN 0
		ELSE 1
	END														AS [is_different]
FROM #ConfigOpts co
LEFT OUTER JOIN #ServerAVals a
	ON a.[configuration_id] = co.[configuration_id]
LEFT OUTER JOIN #ServerBVals b
	ON b.[configuration_id] = co.[configuration_id]
WHERE (@ShowDifferentOnly = 0)
OR (@ShowDifferentOnly = 1 AND 
CASE 
	WHEN a.[value] = b.[value] 
		AND a.[value_in_use] = b.[value_in_use]
		THEN 0
	ELSE 1
END = 1
)
GO

-- The most atomic unit of work.  No server/environment metadata is stored here.
CREATE TABLE [hist].[ChangeControl_ScriptMaster] (
	[ScriptID]					INT IDENTITY (1,1) NOT NULL		CONSTRAINT [PK__ChangeControl_ScriptMaster__ScriptID] PRIMARY KEY CLUSTERED ([ScriptID]) ON [HISTORY]
	,[Definition]				NVARCHAR (MAX)
	,[FileName]					VARCHAR (500)
	,[DateCreated]				SMALLDATETIME
	,[UserName]					VARCHAR (50)
) ON [HISTORY]

-- Xref to databases affected by this script
CREATE TABLE [hist].[ChangeControl_ScriptDatabaseXref] (
	[ScriptID]					INT								CONSTRAINT [FK__ChangeControl_ScriptDatabaseXref__ScriptID__ChangeControl_ScriptMaster__ScriptID] FOREIGN KEY REFERENCES [hist].[ChangeControl_ScriptMaster]([ScriptID])
	,[DatabaseID]				INT								CONSTRAINT [FK__ChangeControl_ScriptDatabaseXref__DatabaseID__ServerInventory_SQL_DatabaseIDs__DatabaseID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
	,CONSTRAINT [PK__ChangeControl_ScriptDatabaseXref__ScriptID__DatabaseID] PRIMARY KEY CLUSTERED (
		[ScriptID]
		,[DatabaseID]
	) ON [History]
) ON [HISTORY]

-- A high-level object that is basically a set of ChangeSets.  Also adds some metadata like Patch/DBU number
CREATE TABLE [dbo].[ChangeControl_PackageMaster] (
	[PackageID]					INT IDENTITY (1,1) NOT NULL		CONSTRAINT [PK__ChangeControl_PackageMaster__PackageID] PRIMARY KEY CLUSTERED ([PackageID]) ON [PRIMARY],
	[PackageLabel]				VARCHAR(255),
	[Year]						SMALLINT,						
	[Type]						VARCHAR (10),
	[Number]					SMALLINT,
	[Revision]					TINYINT,
	[Description]				VARCHAR(255),
	[UserName]					VARCHAR(50),
	[DateCreated]				SMALLDATETIME
) ON [PRIMARY]

-- A unit of work
CREATE TABLE [dbo].[ChangeControl_ChangeSet] (
	[ChangeSetID]				INT IDENTITY (1,1) NOT NULL		CONSTRAINT [PK__ChangeControl_ChangeSet__PackageDetailID] PRIMARY KEY CLUSTERED ([ChangeSetID]) ON [PRIMARY] 
	,[PackageID]				INT								CONSTRAINT [FK__ChangeControl_ChangeSet__PackageID__ChangeControl_PackageMaster_PackageID] FOREIGN KEY REFERENCES [dbo].[ChangeControl_PackageMaster] ([PackageID])
	,[Description]				NVARCHAR(255)
	,[InstanceName]				VARCHAR (50)
	,[Sequence]					SMALLINT
	,[UserName]					VARCHAR(50)
	,[DateCreated]				SMALLDATETIME					CONSTRAINT [DF__ChangeControl_ChangeSet__DateCreated] DEFAULT GETDATE()
) ON [PRIMARY]

-- Just a way to link scripts to ChangeSets, across schemas and add things like Sequence
CREATE TABLE [dbo].[ChangeControl_ChangeSetDetail] (
	[ChangeSetID]				INT								CONSTRAINT [FK__ChangeControl_ChangeSetDetail__ChangeSetID__ChangeControl_ChangeSet__ChangeSetID] FOREIGN KEY REFERENCES [dbo].[ChangeControl_ChangeSet] ([ChangeSetID])
	,[ScriptID]					INT								CONSTRAINT [FK__ChangeControl_ChangeSet__ScriptID__ChangeControl_ScriptMaster__ScriptID] FOREIGN KEY REFERENCES [hist].[ChangeControl_ScriptMaster]([ScriptID])
	,[Sequence]					SMALLINT
	,[IsRemoved]				BIT								CONSTRAINT [DF__ChangeControl_ChangeSetDetail__IsRemoved] DEFAULT 0
	,[UserName]					VARCHAR (50)
	,[DateCreated]				SMALLDATETIME					CONSTRAINT [DF__ChangeControl_ChangeSetDetail__DateCreated] DEFAULT GETDATE()
) ON [PRIMARY]	

--CREATE TABLE [dbo].[ChangeControl_ChangeSetExceptions] (
--	[ExceptionID]				INT IDENTITY (1,1) NOT NULL		CONSTRAINT [PK__ChangeControl_ChangeSetExceptions__ExceptionID] PRIMARY KEY CLUSTERED ([ExceptionID]) ON [PRIMARY],
--	[ChangeSetID]				INT								CONSTRAINT [FK__ChangeControl_ChangeSetExceptions__ChangeSetID__ChangeControl_ChangeSet__ChangeSetID] FOREIGN KEY REFERENCES [dbo].[ChangeControl_ChangeSet]  (ChangeSetID),
--	[EnvironmentID]				TINYINT							CONSTRAINT [FK__ChangeControl_ChangeSetExceptions__EnvironmentID__ServerInventory_Environments__EnvironmentID] FOREIGN KEY REFERENCES [dbo].[ServerInventory_Environments] (EnvironmentID)
--) ON [PRIMARY]

-- A high-level object that contains a set of packages
CREATE TABLE [dbo].[ChangeControl_DeployMaster] (
	[DeployID]					INT IDENTITY (1,1)				CONSTRAINT [FK__ChangeControl_DeployMaster__DeployID] PRIMARY KEY CLUSTERED ([DeployID]) ON [PRIMARY]
	,[DeployName]				VARCHAR(50)
	,[UserName]					VARCHAR (50)
	,[DateCreated]				SMALLDATETIME					CONSTRAINT [DF__ChangeControl_DeployMaster__DateCreated] DEFAULT GETDATE()
) ON [PRIMARY]

-- A set of scripts that are gathered from the PackageMaster - Sequence added
CREATE TABLE [dbo].[ChangeControl_DeployDetail] (
	[DeployID]					INT								CONSTRAINT [FK__ChangeControl_DeployDetail__DeployID__ChangeControl_DeployMaster__DeployID] FOREIGN KEY REFERENCES [dbo].[ChangeControl_DeployMaster] ([DeployID]) ON DELETE CASCADE
	,[ScriptID]					INT								CONSTRAINT [FK__ChangeControl_DeployMaster__ScriptID__ChangeControl_ScriptMaster__ScriptID] FOREIGN KEY REFERENCES [hist].[ChangeControl_ScriptMaster]([ScriptID])
	,[Sequence]					SMALLINT
	,[IsEnabled]				BIT								CONSTRAINT [DF__ChangeControl_DeployMaster__IsEnabled] DEFAULT 1
	,[UserName]					VARCHAR (50)
	,[DateCreated]				SMALLDATETIME					CONSTRAINT [DF__ChangeControl_DeployDetail__DateCreated] DEFAULT GETDATE()
) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [IX__ChangeControl_DeployDetail__DeployID__ScriptID] ON [dbo].[ChangeControl_DeployDetail] ([DeployID],[ScriptID]) WITH (FILLFACTOR = 90)

----

CREATE TABLE [hist].[ChangeControl_DeployHistory] (
	[HistServerID]				INT								CONSTRAINT [FK__ChangeControl_DeployHistory__HistServerID__ServerInventory_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([HistServerID])
	,[InstanceName]				VARCHAR(50)
	,[EnvironmentName]			VARCHAR(50)
	,[DeployName]				VARCHAR(50) NULL
	,[PackageName]				VARCHAR(50)
	,[ScriptID]					INT								CONSTRAINT [FK__ChangeControl_DeployHistory__ScriptID__ChangeControl_ScriptMaster__ScriptID] FOREIGN KEY REFERENCES [hist].[ChangeControl_ScriptMaster]([ScriptID])
	,[Output]					NVARCHAR(MAX)
	,[OutputType]				VARCHAR (50)
	,[IsError]					BIT								CONSTRAINT [DF__ChangeControl_DeployHistory__IsError] DEFAULT 0
	,[UserName]					VARCHAR (50)
	,[DateCreated]				SMALLDATETIME					CONSTRAINT [DF__ChangeControl_DeployHistory__DateCreated] DEFAULT GETDATE()	
) ON [HISTORY]

--Create some constraints
--CREATE UNIQUE NONCLUSTERED INDEX [UIX__ChangeControl_PackageMaster__Year__Type__Number__Revision] ON [dbo].[ChangeControl_PackageMaster] ([Year] ASC,[Type] ASC,[Number] ASC,[Revision] ASC) ON [PRIMARY]
--CREATE UNIQUE NONCLUSTERED INDEX [UIX__ChangeControl_PackageDetail__PackageID__PackageSequence] ON [dbo].[ChangeControl_PackageDetail] ([PackageID] ASC,[PackageSequence]) ON [PRIMARY]

GO
/*******************************************************************************************************
**  Name:			[hist].[ChangeControl_DeployHistory_Insert]
**  Desc:			Procedure to insert history values
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-09-04
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	
********************************************************************************************************/
CREATE PROCEDURE [hist].[ChangeControl_DeployHistory_Insert] (
	@ServerName				VARCHAR(200)
	,@InstanceName			VARCHAR(50)
	,@EnvironmentName		VARCHAR(50)
	,@DeployName			VARCHAR(50) = NULL
	,@PackageName			VARCHAR(50)
	,@ScriptID				INT
	,@Output				NVARCHAR(MAX)
	,@OutputType			VARCHAR(50)
	,@IsError				BIT
	,@UserName				VARCHAR(50)
	,@DateCreated			SMALLDATETIME
)
AS

-- Lookup the server id
DECLARE
	@HistServerID			INT
	
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @HistServerID OUTPUT

-- insert the data
INSERT INTO [hist].[ChangeControl_DeployHistory] ([HistServerID], [InstanceName], [EnvironmentName], [ScriptID], [Output], [OutputType], [UserName], [DateCreated])
VALUES (@HistServerID,@InstanceName,@EnvironmentName,@ScriptID,@Output,@OutputType,@UserName,@DateCreated)

GO
/*******************************************************************************************************
**  Name:			[hist].[ChangeControl_DeployHistory_vw]
**  Desc:			View to assemble all history data
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-09-04
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	
********************************************************************************************************/
CREATE VIEW [hist].[ChangeControl_DeployHistory_vw]
AS

SELECT
	h.[DeployName]
	,h.[PackageName]
	,s.[ServerName]
	,h.[InstanceName]
	,h.[EnvironmentName]
	,sm.[Definition]
	,sm.[FileName]
	,h.[Output]
	,h.[OutputType]
	,h.[DateCreated]
	,h.[UserName]
FROM [hist].[ChangeControl_DeployHistory] h
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON h.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[ChangeControl_ScriptMaster] sm
	ON h.[ScriptID] = sm.[ScriptID]

GO

PRINT N'Creating Metrics objects'

CREATE TABLE [hist].[Metrics_QueryStats](
	[HistServerID]				INT CONSTRAINT [FK__Metrics_QueryStats__HistServerID__ServerInventory_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([HistServerID])
	,[HistDatabaseID]			INT CONSTRAINT [FK__Metrics_QueryStats__HistDatabaseID__ServerInventory_SQL_DatabaseIDs__DatabaseID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
	,[HistObjectID]				INT CONSTRAINT [FK__Metrics_QueryStats__HistObjectID__ServerInventory_SQL_ObjectIDs__HistObjectID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_ObjectIDs] ([ObjectID])
	,[Count]					BIGINT NULL
	,[Total_CPU_Time]			BIGINT NULL
	,[AVG_CPU_Time]				BIGINT NULL
	,[Last_CPU]					BIGINT NULL
	,[Min_CPU]					BIGINT NULL
	,[Max_CPU]					BIGINT NULL
	,[Total_Run_Time]			BIGINT NULL
	,[AVG_Run_Time]				BIGINT NULL
	,[Last_Run_Time]			BIGINT NULL
	,[Min_Run_Time]				BIGINT NULL
	,[Max_Run_Time]				BIGINT NULL
	,[Total_Logical_Writes]		BIGINT NULL
	,[Last_Logical_Writes]		BIGINT NULL
	,[Min_Logical_Writes]		BIGINT NULL
	,[Max_Logical_Writes]		BIGINT NULL
	,[Total_Physical_Reads]		BIGINT NULL
	,[Last_Physical_Reads]		BIGINT NULL
	,[Min_Physical_Reads]		BIGINT NULL
	,[Max_Physical_Reads]		BIGINT NULL
	,[Total_Logical_Reads]		BIGINT NULL
	,[Last_Logical_Reads]		BIGINT NULL
	,[Min_Logical_Reads]		BIGINT NULL
	,[Max_Logical_Reads]		BIGINT NULL
	,[SampleDate]				SMALLDATETIME CONSTRAINT [DF__Metrics_QueryStats__SampleDate] DEFAULT GETDATE()
) ON [History]

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_GetObjectID]
**  Desc:			Procedure to get/insert object IDs
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-12-11
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	
********************************************************************************************************/
CREATE PROCEDURE [hist].[ServerInventory_SQL_GetObjectID] (
	@ObjectName			NVARCHAR(128)
	,@SchemaName		NVARCHAR(128)
	,@SQLType			NVARCHAR(128) = NULL
	,@ObjectID			INT OUTPUT
)
AS

SELECT 
	@ObjectID = ObjectID
FROM 
	[hist].[ServerInventory_SQL_ObjectIDs] id
WHERE id.[ObjectName] = @ObjectID
AND id.[SchemaName] = @SchemaName
AND (id.[SQLType] = @SQLType OR @SQLType IS NULL)


IF @ObjectID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_ObjectIDs] ([ObjectName], [SchemaName],[SQLType])
	VALUES (@ObjectName,@SchemaName,@SQLType)
	
	SET @ObjectID = SCOPE_IDENTITY()
END

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
**	
********************************************************************************************************/
CREATE PROCEDURE [hist].[Metrics_QueryStats_Insert] (
	@ServerName					VARCHAR(200)
	,@DBName					NVARCHAR(128)
	,@Schema					NVARCHAR(128)
	,@Object					NVARCHAR(128)
	,@Count						BIGINT 
	,@Total_CPU_Time			BIGINT 
	,@AVG_CPU_Time				BIGINT 
	,@Last_CPU					BIGINT 
	,@Min_CPU					BIGINT 
	,@Max_CPU					BIGINT 
	,@Total_Run_Time			BIGINT 
	,@AVG_Run_Time				BIGINT 
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
INSERT INTO [hist].[Metrics_QueryStats] (HistServerID, HistDatabaseID, HistObjectID, Count, Total_CPU_Time, AVG_CPU_Time, Last_CPU, Min_CPU, Max_CPU, Total_Run_Time, AVG_Run_Time, Last_Run_Time, Min_Run_Time, Max_Run_Time, Total_Logical_Writes, Last_Logical_Writes, Min_Logical_Writes, Max_Logical_Writes, Total_Physical_Reads, Last_Physical_Reads, Min_Physical_Reads, Max_Physical_Reads, Total_Logical_Reads, Last_Logical_Reads, Min_Logical_Reads, Max_Logical_Reads)
VALUES (@HistServerID,@HistDatabaseID, @HistObjectID,@Count, @Total_CPU_Time, @AVG_CPU_Time, @Last_CPU, @Min_CPU, @Max_CPU, @Total_Run_Time, @AVG_Run_Time, @Last_Run_Time, @Min_Run_Time, @Max_Run_Time, @Total_Logical_Writes, @Last_Logical_Writes, @Min_Logical_Writes, @Max_Logical_Writes, @Total_Physical_Reads, @Last_Physical_Reads, @Min_Physical_Reads, @Max_Physical_Reads, @Total_Logical_Reads, @Last_Logical_Reads, @Min_Logical_Reads, @Max_Logical_Reads)

GO
PRINT N'Stamping database version 1.4.0'
EXEC sys.sp_updateextendedproperty @name=N'Version', @value=N'1.4.0'


--PRINT N'---- Rolled everything back ----'
--ROLLBACK
COMMIT TRANSACTION