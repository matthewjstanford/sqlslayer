USE [DBACentral]
GO

SET XACT_ABORT OFF

BEGIN TRANSACTION

IF EXISTS (
	SELECT * 
	FROM fn_listextendedproperty(default, default, default, default, default, default, default)
	WHERE LEFT(CAST([value] AS VARCHAR(50)),3) = '1.2'
	AND [name] = 'Version'
)
BEGIN
	PRINT 'Current Version is 1.2.x  Lets begin.'
END
ELSE
BEGIN
	RAISERROR('Current Version of DBACentral is not 1.2.x, this script will not update successfully',16,2) WITH LOG
END
	
	
SET NUMERIC_ROUNDABORT OFF
GO
SET XACT_ABORT, NOCOUNT ON
GO


-- Collect Foreign and Primary Key information

IF OBJECT_ID('tempdb.dbo.#FKeys') IS NOT NULL
DROP TABLE #FKeys

IF OBJECT_ID('tempdb.dbo.#PKeys') IS NOT NULL
	DROP TABLE #PKeys

DECLARE 
	@FKeyObjID				INT
	,@PCol					SYSNAME
	,@RCol					SYSNAME
	,@PKeyObjID				INT
	,@IndexID				INT
	,@TblObjID				INT
	,@Col					SYSNAME
	,@AscDesc				NVARCHAR(4)
	,@SQL					NVARCHAR(4000)

CREATE TABLE #FKeys (
	[Old_Name]				SYSNAME
	,[New_Name]				SYSNAME NULL
	,[Orig_ObjectID]		INT
	,[Parent_Schema]		SYSNAME
	,[Parent_Table]			SYSNAME
	,[Ref_Schema]			SYSNAME
	,[Ref_Table]			SYSNAME
	,[Parent_Cols]			NVARCHAR(4000) NULL
	,[Ref_Cols]				NVARCHAR(4000) NULL
	,[Old_Drop]				NVARCHAR(4000) NULL
	,[Old_Create]			NVARCHAR(4000) NULL
	,[New_Create]			NVARCHAR(4000) NULL
	,[OnDelete]				NVARCHAR(60)
	,[OnUpdate]				NVARCHAR(60)
	,[IsDisabled]			BIT
	,[IsNotForRepl]			BIT
)


CREATE TABLE #PKeys (
	[Orig_Name]				SYSNAME
	,[New_Name]				SYSNAME NULL
	,[Orig_ObjectID]		INT
	,[Orig_IndexID]			INT
	,[Schema]				SYSNAME
	,[Table]				SYSNAME
	,[Cols4Name]			NVARCHAR(4000) NULL
	,[Cols]					NVARCHAR(4000) NULL
	,[Orig_Drop]			NVARCHAR(4000) NULL
	,[Orig_Create]			NVARCHAR(4000) NULL
	,[New_Create]			NVARCHAR(4000) NULL
	,[Type]					NVARCHAR(60)
	,[FillFactor]			TINYINT
	,[PadIndex]				NVARCHAR(3)
	,[AllowRowLocks]		NVARCHAR(3)
	,[AllowPageLocks]		NVARCHAR(3)
	,[FileGroup]			SYSNAME
)

----------------------------------------------
-- Foreign Keys
INSERT INTO #FKeys ([Old_Name],[Orig_ObjectID],[Parent_Schema],[Parent_Table],[Ref_Schema],[Ref_Table],[Parent_cols],[ref_cols],[OnDelete],[OnUpdate],[IsDisabled],[IsNotForRepl])
SELECT 
	fk.[name]
	,fk.[object_id]
	,p_schema.[name]
	,p_obj.[name]
	,r_schema.[name]
	,r_obj.[name]
	,NULL
	,NULL
	,fk.[delete_referential_action_desc]
	,fk.[update_referential_action_desc]
	,fk.[is_disabled]
	,fk.[is_not_for_replication]
FROM sys.foreign_keys fk
INNER JOIN sys.objects p_obj
	ON p_obj.[object_id] = fk.[parent_object_id]
INNER JOIN sys.objects r_obj
	ON r_obj.[object_id] = fk.[referenced_object_id]
INNER JOIN sys.schemas p_schema
	ON p_schema.[schema_id] = p_obj.[schema_id]
INNER JOIN sys.schemas r_schema
	ON r_schema.[schema_id] = r_obj.[schema_id]


DECLARE #FKeyCols CURSOR LOCAL STATIC FOR
SELECT
	fkc.[constraint_object_id]
	,p_col.[name]
	,r_col.[name]
FROM sys.foreign_key_columns fkc
INNER JOIN sys.columns p_col
	ON p_col.[object_id] = fkc.[parent_object_id]
	AND p_col.[column_id] = fkc.[parent_column_id]
INNER JOIN sys.columns r_col
	ON r_col.[object_id] = fkc.[referenced_object_id]
	AND r_col.[column_id] = fkc.[referenced_column_id]
ORDER BY fkc.[constraint_object_id], fkc.[constraint_column_id]

OPEN #FKeyCols

FETCH NEXT FROM #FKeyCols INTO @FKeyObjID, @PCol, @RCol

WHILE @@FETCH_STATUS = 0
BEGIN

	-- We're going to change the ServerID column in hist.ServerInventory_ServerIDs to HistServerID, so compensate here
	IF EXISTS(SELECT * FROM #FKeys WHERE [Orig_ObjectID] = @FKeyObjID AND @RCol = 'ServerID' AND [Ref_Schema] = 'hist' AND [Ref_Table] = 'ServerInventory_ServerIDs')
	BEGIN
	
		IF @PCol = 'ServerID'
			SET @PCol = 'HistServerID'
	
		SET @RCol = 'HistServerID'
	END 

	UPDATE f
		SET [Parent_Cols] = ISNULL([Parent_Cols] + '__','') + @PCol
		,[Ref_Cols] = ISNULL([Ref_Cols] + '__','') + @RCol
	FROM #FKeys f
	WHERE f.[Orig_ObjectID] = @FKeyObjID

	FETCH NEXT FROM #FKeyCols INTO @FKeyObjID, @PCol, @RCol
END
CLOSE #FKeyCols
DEALLOCATE #FKeyCols

--SELECT 
--	[Parent_Schema]
--	,[Parent_Table]
--FROM #FKeys
--WHERE [Ref_Cols] IN ('ServerID')
--AND [Parent_Cols] = 'ServerID'
--AND [Ref_Schema] = 'hist' 
--AND [Ref_Table] = 'ServerInventory_ServerIDs'

-- Create the new names
UPDATE f
	SET New_Name = LEFT('FK__' + [Parent_Table] + '__' + [Parent_Cols] + '__' + [Ref_Table] + '__' + [Ref_Cols],128)
FROM #FKeys f

UPDATE f
	SET Old_Drop = 'ALTER TABLE [' + f.[Parent_Schema] + '].[' + f.[Parent_Table] + '] DROP CONSTRAINT [' + f.[Old_Name] + ']'
	,Old_Create = 'ALTER TABLE [' + f.[Parent_Schema] + '].[' + f.[Parent_Table] + '] ADD CONSTRAINT [' + f.[Old_Name] + '] FOREIGN KEY ([' + f.[Parent_Cols] + ']) REFERENCES [' 
		+ f.[Ref_Schema] + '].[' + f.[Ref_Table] + '] ([' + f.[Ref_Cols] + '])'
	,New_Create = 'ALTER TABLE [' + f.[Parent_Schema] + '].[' + f.[Parent_Table] + '] ADD CONSTRAINT [' + f.[New_Name] + '] FOREIGN KEY ([' + f.[Parent_Cols] + ']) REFERENCES [' 
		+ f.[Ref_Schema] + '].[' + f.[Ref_Table] + '] ([' + f.[Ref_Cols] + '])'
FROM #FKeys f

UPDATE f
	SET New_Create = New_Create + ' ON DELETE ' + [OnDelete]
	,Old_Create = Old_Create + ' ON DELETE ' + [OnDelete]
FROM #FKeys f 
WHERE [OnDelete] <> 'NO_ACTION'

UPDATE f
	SET New_Create = New_Create + ' ON UPDATE ' + [OnUpdate]
	,Old_Create = Old_Create + ' ON UPDATE ' + [OnUpdate]
FROM #FKeys f 
WHERE [OnUpdate] <> 'NO_ACTION'

UPDATE f
	SET New_Create = New_Create + ' NOT FOR REPLICATION'
	,Old_Create = Old_Create + ' NOT FOR REPLICATION'
FROM #FKeys f 
WHERE [IsNotForRepl] = 1

----------------------------------------------
-- Primary Keys

INSERT INTO #PKeys ([Orig_Name],[Schema],[Table],[Orig_ObjectID],[Orig_IndexID],[Type],[FillFactor],[PadIndex],[AllowRowLocks],[AllowPageLocks],[FileGroup])
SELECT 
	i.[name]				AS [Orig_Name]
	,s.[name]				AS [Schema]
	,o.[name]				AS [Table]
	,o.[object_id]			AS [Orig_ObjectID]
	,i.[index_id]			AS [Orig_IndexID]
	,i.[type_desc]			AS [Type]
	,i.[fill_factor]		AS [FillFactor]
	,CASE i.[is_padded]
		WHEN 1 THEN 'ON'
		ELSE 'OFF'
	END
	,CASE i.[allow_row_locks]
		WHEN 1 THEN 'ON'
		ELSE 'OFF'
	END
	,CASE i.[allow_page_locks]
		WHEN 1 THEN 'ON'
		ELSE 'OFF'
	END
	,fg.[name]
FROM sys.indexes i
INNER JOIN sys.objects o
	ON o.[object_id] = i.[object_id]
INNER JOIN sys.schemas s
	ON s.[schema_id] = o.[schema_id]
INNER JOIN sys.filegroups fg
	ON fg.[data_space_id] = i.[data_space_id]
WHERE o.[is_ms_shipped] = 0
AND i.[is_primary_key] = 1

-- Get the column names
DECLARE #PKeyCols CURSOR LOCAL STATIC FOR
SELECT
	ic.[object_id]
	,ic.[index_id]
	,col.[name]
	,CASE ic.[is_descending_key]
		WHEN 1 THEN 'DESC'
		ELSE 'ASC'
	END 
FROM sys.index_columns ic
INNER JOIN sys.columns col
	ON col.[object_id] = ic.[object_id]
	AND col.[column_id] = ic.[column_id]
WHERE ic.[is_included_column] = 0
ORDER BY ic.[object_id], ic.[key_ordinal]

OPEN #PKeyCols

FETCH NEXT FROM #PKeyCols INTO @PKeyObjID, @IndexID, @Col, @AscDesc

WHILE @@FETCH_STATUS = 0
BEGIN

	-- We're going to change this column to HistServerID, so fix the PKey definition
	IF EXISTS(SELECT * FROM #PKeys WHERE [Orig_ObjectID] = @PKeyObjID AND [Orig_IndexID] = @IndexID AND @Col = 'ServerID' AND [Schema] = 'hist' 
	AND [Table] IN ('ServerInventory_ServerIDs','Backups_History','ChangeTracking_SQL_ServerDBObjectActionIDs','DTSStore_PackageStore','ServerInventory_SQL_ServerDBTableIDs','SpaceUsed_DatabaseSizes'))
	BEGIN
		SET @Col = 'HistServerID'
	END

	UPDATE p
		SET [Cols4Name] = ISNULL([Cols4Name] + '__','') + @Col
		,[Cols] = ISNULL([Cols] + ', ','') + '[' + @Col + '] ' + @AscDesc
	FROM #PKeys p
	WHERE p.[Orig_ObjectID] = @PKeyObjID
	AND p.[Orig_IndexID] = @IndexID

	FETCH NEXT FROM #PKeyCols INTO @PKeyObjID, @IndexID, @Col, @AscDesc
END
CLOSE #PKeyCols
DEALLOCATE #PKeyCols

-- Create the new names
UPDATE p
	SET [New_Name] = LEFT('PK__' + [Table] + '__' + [Cols4Name],128)
FROM #PKeys p


-- Create DROP and ADD commands
UPDATE p
	SET [Orig_Drop] = 'ALTER TABLE [' + p.[Schema] + '].[' + p.[Table] + '] DROP CONSTRAINT [' + p.[Orig_Name] + ']'
	--,Old_Create = 'ALTER TABLE [' + f.[Parent_Schema] + '].[' + f.[Parent_Table] + '] ADD CONSTRAINT [' + f.[Old_Name] + '] FOREIGN KEY ([' + f.[Parent_Cols] + ']) REFERENCES [' 
	--	+ f.[Ref_Schema] + '].[' + f.[Ref_Table] + '] ([' + f.[Ref_Cols] + '])'
	,[New_Create] = 'ALTER TABLE [' + p.[Schema] + '].[' + p.[Table] + '] ADD CONSTRAINT [' + p.[New_Name] + '] PRIMARY KEY ' + p.[Type] + ' (' + REPLACE(p.[Cols],'__',',') + ')' +
	' WITH (PAD_INDEX = ' + [PadIndex] + ', ' + CASE WHEN [FillFactor] > 0 THEN 'FILLFACTOR = ' + CAST([FillFactor] AS NVARCHAR(3)) + ', ' ELSE '' END +
	'ALLOW_ROW_LOCKS = ' + [AllowRowLocks] + ', ALLOW_PAGE_LOCKS = ' + [AllowPageLocks] + ') ON [' + [FileGroup] + ']'
FROM #PKeys p

PRINT('Dropping all foreign keys')
----------------------------------------------
-- Drop all Foreign Keys
DECLARE #reaper CURSOR LOCAL STATIC FOR
SELECT 
	[Old_Drop]
FROM #FKeys

OPEN #reaper

FETCH NEXT FROM #reaper INTO @SQL

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC(@SQL)

	FETCH NEXT FROM #reaper INTO @SQL
END

CLOSE #reaper
DEALLOCATE #reaper

PRINT('Dropping all primary keys')
----------------------------------------------
-- Drop all Primary Keys
DECLARE #reaper CURSOR LOCAL STATIC FOR
SELECT 
	[Orig_Drop]
FROM #PKeys

OPEN #reaper

FETCH NEXT FROM #reaper INTO @SQL

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC(@SQL)

	FETCH NEXT FROM #reaper INTO @SQL
END

CLOSE #reaper
DEALLOCATE #reaper

PRINT('Renaming ServerID to HistServerID')
-- Change the name of the ServerID column in the tables to HistServerID
EXEC sp_rename 'hist.ServerInventory_ServerIDs.ServerID','HistServerID','COLUMN'
EXEC sp_rename 'hist.Backups_History.ServerID','HistServerID','COLUMN'
EXEC sp_rename 'hist.ChangeTracking_SQL_ServerDBObjectActionIDs.ServerID','HistServerID','COLUMN'
EXEC sp_rename 'hist.DTSStore_PackageStore.ServerID','HistServerID','COLUMN'
EXEC sp_rename 'hist.ServerInventory_SQL_ServerDBTableIDs.ServerID','HistServerID','COLUMN'
EXEC sp_rename 'hist.SpaceUsed_DatabaseSizes.ServerID','HistServerID','COLUMN'

PRINT('Adding new primary keys')
----------------------------------------------
-- Create new Primary Keys
DECLARE #creator CURSOR LOCAL STATIC FOR
SELECT DISTINCT
	[New_Create]
FROM #PKeys

OPEN #creator

FETCH NEXT FROM #creator INTO @SQL

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC(@SQL)

	FETCH NEXT FROM #creator INTO @SQL
END

CLOSE #creator
DEALLOCATE #creator

PRINT('Adding new foreign keys')
----------------------------------------------
-- Create new Primary Keys
DECLARE #creator CURSOR LOCAL STATIC FOR
SELECT DISTINCT
	[New_Create]
FROM #FKeys

OPEN #creator

FETCH NEXT FROM #creator INTO @SQL

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC(@SQL)

	FETCH NEXT FROM #creator INTO @SQL
END

CLOSE #creator
DEALLOCATE #creator

GO


-- Insert SEED data into the ConfigurationOptions table

SET XACT_ABORT OFF

------------------------------------------------------------

-- Clean up if this is a re-run
-- SpaceUsed section
PRINT('Removing old hist.ServerInventory objects')
IF OBJECT_ID('[hist].[ServerInventory_SQL_ConfigurationValues]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_ConfigurationValues]
IF OBJECT_ID('[hist].[ServerInventory_SQL_Configurations_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[ServerInventory_SQL_Configurations_InsertValue]
IF OBJECT_ID('[hist].[ServerInventory_GetServerID]','P') IS NOT NULL
	DROP PROCEDURE [hist].[ServerInventory_GetServerID]	

-- Objects in the report schema
PRINT('Removing old "report" objects')
IF OBJECT_ID('[report].[SpaceUsed_AvgDBGrowthPerDay]','P') IS NOT NULL
	DROP PROCEDURE [report].[SpaceUsed_AvgDBGrowthPerDay]
	
PRINT('Removing old "rpt" objects')
IF OBJECT_ID('[rpt].[SpaceUsed_AvgDBGrowthPerDay]','P') IS NOT NULL
	DROP PROCEDURE [rpt].[SpaceUsed_AvgDBGrowthPerDay]
IF OBJECT_ID('[rpt].[DBSizes_Summary]','P') IS NOT NULL
	DROP PROCEDURE [rpt].[DBSizes_Summary]
IF OBJECT_ID('[rpt].[Backup_Summary]','P') IS NOT NULL
	DROP PROCEDURE [rpt].[Backup_Summary]
IF OBJECT_ID('[rpt].[DBSizes_Summary_vw]','V') IS NOT NULL
	DROP VIEW [rpt].[DBSizes_Summary_vw]
IF OBJECT_ID('[rpt].[Backup_Summary_vw]','V') IS NOT NULL
	DROP VIEW [rpt].[Backup_Summary_vw]

PRINT('Removing old SpaceUsed objects')
IF OBJECT_ID('[hist].[SpaceUsed_DatabaseSizes_Delta_vw]','V') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_DatabaseSizes_Delta_vw]

-- Going to try to rename the ServerID column from hist.ServerInventory_ServerIDs to HistServerID
PRINT ('Going to try to rename the ServerID column from hist.ServerInventory_ServerIDs to HistServerID')
IF OBJECT_ID('[hist].[ChangeTracking_AllDatabaseChanges_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[ChangeTracking_AllDatabaseChanges_vw]
IF OBJECT_ID('[hist].[SpaceUsed_TableSizes_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_TableSizes_vw]
IF OBJECT_ID('[hist].[SpaceUsed_TableSizes_Delta_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_TableSizes_Delta_vw]
IF OBJECT_ID('[hist].[ServerInventory_SQL_ConfigurationValues_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[ServerInventory_SQL_ConfigurationValues_vw]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_ClusterNodes_vw]','V ') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_SQL_ClusterNodes_vw]
IF OBJECT_ID('[hist].[ServerInventory_GetServerID]','P ') IS NOT NULL
	DROP PROCEDURE [hist].[ServerInventory_GetServerID]
IF OBJECT_ID('[hist].[SpaceUsed_DatabaseSizes_Delta_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_DatabaseSizes_Delta_vw]
IF OBJECT_ID('[hist].[SpaceUsed_DatabaseSizes_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_DatabaseSizes_vw]
IF OBJECT_ID('[hist].[DatabaseMaintenance_CheckDB_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[DatabaseMaintenance_CheckDB_vw]
IF OBJECT_ID('[hist].[Jobs_SQL_JobHistory_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[Jobs_SQL_JobHistory_vw]
IF OBJECT_ID('[hist].[Jobs_SQL_Jobs_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[Jobs_SQL_Jobs_vw]
IF OBJECT_ID('[hist].[Jobs_SQL_JobSteps_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[Jobs_SQL_JobSteps_vw]
IF OBJECT_ID('[hist].[Backups_History_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[Backups_History_vw]
IF OBJECT_ID('[hist].[DTSStore_Packages_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[DTSStore_Packages_vw]
IF OBJECT_ID('[hist].[SpaceUsed_FileSizes_vw]','V ') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_FileSizes_vw]
	
IF OBJECT_ID('[dbo].[ServerInventory_ServerOwners_vw]','V ') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_ServerOwners_vw]
IF OBJECT_ID('[dbo].[ServerInventory_ApplicationOwners_vw]','V ') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_ApplicationOwners_vw]
IF OBJECT_ID('[dbo].[ServerInventory_ServerApplications_vw]','V ') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_ServerApplications_vw]
IF OBJECT_ID('[dbo].[ServerInventory_DatabaseOwners_vw]','V ') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_DatabaseOwners_vw]
IF OBJECT_ID('[dbo].[ServerInventory_Owners_vw]','V ') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_Owners_vw]

PRINT('Removing "report" schema')
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'report')
	EXEC('DROP SCHEMA report')

PRINT ('Adding new schemas')
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'rpt')
	EXEC('CREATE SCHEMA rpt')

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'mon')
	EXEC('CREATE SCHEMA mon')
	
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'audit')
	EXEC('CREATE SCHEMA audit')

GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_ServerOwners_vw]
**  Desc:			View to pair owners up to thier servers
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-07-21
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [dbo].[ServerInventory_ServerOwners_vw]
AS

SELECT
	s.[ServerID]
	,s.[ServerName] + ISNULL('\' + s.[InstanceName],'') AS [ServerName]
	,o.[OwnerName]
	,s.[Environment]
	,s.[Description]
FROM [dbo].[ServerInventory_ServerOwners_Xref] sx
INNER JOIN [dbo].[ServerInventory_Owners] o
	ON o.[OwnerID] = sx.[OwnerID]
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
	ON s.[ServerID] = sx.[ServerID]
GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_ApplicationOwners_vw]
**  Desc:			View to pair owners up to thier applications
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-07-21
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [dbo].[ServerInventory_ApplicationOwners_vw]
AS

SELECT
	a.[ApplicationName]
	,o.[OwnerName]
FROM [dbo].[ServerInventory_ApplicationOwners_Xref] ax
INNER JOIN [dbo].[ServerInventory_Applications] a
	ON ax.[ApplicationID] = a.[ApplicationID]
INNER JOIN [dbo].[ServerInventory_Owners] o
	ON ax.[OwnerID] = o.[OwnerID]
GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_ServerApplications_vw]
**  Desc:			View to pair servers up to thier applications
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-07-21
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [dbo].[ServerInventory_ServerApplications_vw]
AS

SELECT 
	s.[ServerID]
	,s.[ServerName] + ISNULL('\' + s.[InstanceName],'') AS [ServerName]
	,a.[ApplicationName]
	,s.[Environment]
	,s.[Description]
FROM [dbo].[ServerInventory_ServerApplications_Xref] sax
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
	ON sax.[ServerID] = s.[ServerID]
INNER JOIN [dbo].[ServerInventory_Applications] a
	ON sax.[ApplicationID] = a.[ApplicationID]
GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_DatabaseOwners_vw]
**  Desc:			View to pair databases up to thier owners
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-07-21
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [dbo].[ServerInventory_DatabaseOwners_vw]
AS

SELECT
	s.[ServerName] + ISNULL('\' + s.[InstanceName],'') AS [ServerName]
	,d.[DBName]
	,o.[OwnerName]
FROM [dbo].[ServerInventory_DatabaseOwners_Xref] dox
INNER JOIN [dbo].[ServerInventory_Owners] o
	ON dox.[OwnerID] = o.[OwnerID]
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
	ON dox.[ServerID] = s.[ServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON dox.[DatabaseID] = d.[DatabaseID]

GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_Owners_vw]
**  Desc:			View to show all of an owner's items
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009-07-21
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [dbo].[ServerInventory_Owners_vw]
AS

SELECT
	'SERVER'												AS [Type]
	,NULL													AS [ParentItem]
	,[ServerName]											AS [Item]
	,[OwnerName]											AS [OwnerName]
FROM [dbo].[ServerInventory_ServerOwners_vw]

UNION ALL

SELECT
	'APPLICATION'											AS [Type]
	,NULL													AS [ParentItem]
	,[ApplicationName]										AS [Item]
	,[OwnerName]											AS [OwnerName]
FROM [dbo].[ServerInventory_ApplicationOwners_vw]

UNION ALL

SELECT
	'DATABASE'												AS [Type]
	,[ServerName]											AS [ParentItem]
	,[DBName]												AS [Item]
	,[OwnerName]											AS [OwnerName]
FROM [dbo].[ServerInventory_DatabaseOwners_vw]
	
GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_ConfigurationValues]
**  Desc:			Container for historical configuration values
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			20090706
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090716	Matt Stanford	Table is unused, so re-creating it (not modifying).  Added DateLastSeenOn column, changed data types.
********************************************************************************************************/
CREATE TABLE [hist].[ServerInventory_SQL_ConfigurationValues](
	[HistConfigValueID]		INT IDENTITY(1,1)	NOT NULL
	,[RefConfigOptionID]	INT					NULL		CONSTRAINT [FK__SQL_ConfigValues__ConfigOptions] FOREIGN KEY([RefConfigOptionID]) REFERENCES [ref].[ServerInventory_SQL_ConfigurationOptions] ([RefConfigOptionID])
	,[HistServerID]			INT					NULL		CONSTRAINT [FK__SQL_ConfigValues__HistServerID] FOREIGN KEY([HistServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([HistServerID])
	,[value]				SQL_VARIANT			NOT NULL
	,[value_in_use]			SQL_VARIANT			NOT NULL
	,[DateCreated]			SMALLDATETIME		NOT NULL	CONSTRAINT [DF__SQL_ConfigValues__DateCreated]  DEFAULT (getdate()) 
	,[DateLastSeenOn]		SMALLDATETIME		NOT NULL	CONSTRAINT [DF__SQL_ConfigValues__DateLastSeenOn]  DEFAULT (getdate())
	CONSTRAINT [PK__SQL_ConfigValues__HistConfigValueID] PRIMARY KEY CLUSTERED 
	(
		[HistConfigValueID] ASC
	) ON [History]
) ON [History]

GO
/*******************************************************************************************************
**  Name:			[hist].[ChangeTracking_AllDatabaseChanges_vw]
**  Desc:			View to show all database changes
**  Auth:			Kathy Toth (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[ChangeTracking_AllDatabaseChanges_vw]
AS
SELECT 
	m.[ServerName]
	,d.[DBName]
	,ot.[SchemaName]
	,ot.[ObjectName]
	,ob.[SQLType] AS [SQL_Object_Type]
	,ob.[RefType] AS [Reference_Object_Type]
	,ob.[SQLDesc] AS [Description]
	,ac.[ActionType] AS [Action]
	,id.[DateModified]
		
FROM [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] id
INNER JOIN [hist].[ChangeTracking_SQL_ObjectIDs] ot
	ON ot.[ObjectID] = id.[ObjectID]
INNER JOIN [hist].[ServerInventory_ServerIDs] m
	ON m.[HistServerID] = id.[HistServerID]
INNER JOIN [hist].[ChangeTracking_SQL_ObjectTypeIDs] ob
	ON ob.[ObjectTypeID] = ot.[ObjectTypeID]
INNER JOIN [hist].[ChangeTracking_SQL_ActionIDs] ac
	ON ac.[ActionID] = id.[ActionID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs]d
	ON d.[DatabaseID] = id.[DatabaseID]

GO
/*******************************************************************************************************
**  Name:			[hist].[SpaceUsed_TableSizes_vw]
**  Desc:			View to show all table sizes
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[SpaceUsed_TableSizes_vw]
AS

SELECT 
	s.[ServerName]
	,d.[DBName]
	,t.[SchemaName]
	,t.[TableName]
	,det.[RowCount]
	,det.[ReservedSpaceKB]
	,det.[DataSpaceKB]
	,det.[IndexSizeKB]
	,det.[UnusedKB]
	,CASE WHEN det.[RowCount] = 0 THEN 0
	ELSE CAST(CAST(det.[ReservedSpaceKB] AS DECIMAL) / det.[RowCount] AS DECIMAL(10,3))
	END as [KB/Row]
	,det.[SampleDate]
FROM [hist].[SpaceUsed_TableSizes] det
INNER JOIN [hist].[ServerInventory_SQL_ServerDBTableIDs] m
	ON m.[ServerDBTableID] = det.[ServerDBTableID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[HistServerID] = m.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = m.[DatabaseID]
INNER JOIN [hist].[ServerInventory_SQL_TableIDs] t
	ON t.[TableID] = m.[TableID]

GO
/*******************************************************************************************************
**  Name:			[hist].[SpaceUsed_TableSizes_Delta_vw]
**  Desc:			View to show all table size differences day over day
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[SpaceUsed_TableSizes_Delta_vw]
AS
WITH TableData AS (
	SELECT 
		[ServerDBTableID]
		,[RowCount]
		,[ReservedSpaceKB]
		,[DataSpaceKB]
		,[IndexSizeKB]
		,[UnusedKB]
		,[SampleDate]
		,ROW_NUMBER() OVER (PARTITION BY [ServerDBTableID] ORDER BY SampleDate) as rownum
	FROM [hist].[SpaceUsed_TableSizes]
)
SELECT 
	s.[ServerName]
	,d.[DBName]
	,t.[SchemaName]
	,t.[TableName]
	,currow.[RowCount]
	,currow.[RowCount] - prevrow.[RowCount] as [RowsAdded]
	,currow.[ReservedSpaceKB]
	,currow.[ReservedSpaceKB] - prevrow.[ReservedSpaceKB] as [ReservedSpaceKBAdded]
	,currow.[DataSpaceKB]
	,currow.[DataSpaceKB] - prevrow.[DataSpaceKB] as [DataSpaceKBAdded]
	,currow.[IndexSizeKB]
	,currow.[IndexSizeKB] - prevrow.[IndexSizeKB] as [IndexSizeKBAdded]
	,currow.[UnusedKB]
	,currow.[UnusedKB] - prevrow.[UnusedKB] as [UnusedKBAdded]
	,currow.[SampleDate] 
FROM TableData currow
INNER JOIN [hist].[ServerInventory_SQL_ServerDBTableIDs] m
	ON m.[ServerDBTableID] = currow.[ServerDBTableID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[HistServerID] = m.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = m.[DatabaseID]
INNER JOIN [hist].[ServerInventory_SQL_TableIDs] t
	ON t.[TableID] = m.[TableID]
LEFT OUTER JOIN TableData prevrow
	ON currow.rownum = prevrow.rownum + 1
	AND currow.ServerDBTableID = prevrow.ServerDBTableID

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_ConfigurationValues_vw]
**  Desc:			View to show Configuration values of SQL servers
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[ServerInventory_SQL_ConfigurationValues_vw]
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
FROM [hist].[ServerInventory_SQL_ConfigurationValues] v
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON v.[HistServerID] = s.[HistServerID]
INNER JOIN [ref].[ServerInventory_SQL_ConfigurationOptions] o
	ON v.[RefConfigOptionID] = o.[RefConfigOptionID]

GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_SQL_ClusterNodes_vw]
**  Desc:			View to show which servers are part of which clusters
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			20090706
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [dbo].[ServerInventory_SQL_ClusterNodes_vw]
AS

SELECT 
	m.[ServerID]					AS [ServerID]
	,m.[FullName]					AS [FullSQLInstanceName]
	,s.[ServerName]					AS [NodeName]
FROM [dbo].[ServerInventory_SQL_ClusterNodes] c
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] m
	ON c.[ServerID] = m.[ServerID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON c.[HistServerID] = s.[HistServerID]
	
GO
/*******************************************************************************************************
**  Name:			[hist].[SpaceUsed_DatabaseSizes_vw]
**  Desc:			View to pull back the database sizes from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090706	Matt Stanford	Fully backwards-compatible change to add DataSizeUnusedMB and LogSizeUnusedMB
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[SpaceUsed_DatabaseSizes_vw]
AS

SELECT 
	s.[ServerName]
	,d.[DBName]
	,det.[DataSizeMB]
	,det.[LogSizeMB]
	,det.[DataSizeUnusedMB]
	,det.[LogSizeUnusedMB]
	,det.[DataSizeMB] - det.[DataSizeUnusedMB]		AS [DataSizeUsedMB]
	,det.[LogSizeMB] - det.[LogSizeUnusedMB]		AS [LogSizeUsedMB]
	,det.[SampleDate]
FROM [hist].[SpaceUsed_DatabaseSizes] det
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[HistServerID] = det.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = det.[DatabaseID]


GO
/*******************************************************************************************************
**  Name:			[hist].[DatabaseMaintenance_CheckDB_vw]
**  Desc:			View to pull back the checkdb results from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[DatabaseMaintenance_CheckDB_vw]
AS

SELECT
	s.[ServerName]		AS [ServerName]
	,d.[DBName]			AS [DatabaseName]
	,CAST(1 AS BIT)		AS [EncounteredError]
	,e.[RunID]
	,e.[DateCreated]
	,e.[Error]
	,e.[Level]
	,e.[State]
	,e.[MessageText]
	,e.[RepairLevel]
	,e.[Status]
	,e.[ObjectID]
	,e.[IndexId]
	,e.[PartitionID]
	,e.[AllocUnitID]
	,e.[File]
	,e.[Page]
	,e.[Slot]
	,e.[RefFile]
	,e.[RefPage]
	,e.[RefSlot]
	,e.[Allocation]
FROM [hist].[DatabaseMaintenance_CheckDB_Errors] e
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[HistServerID] = e.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = e.[DatabaseID]

UNION ALL

SELECT
	s.[ServerName]		AS [ServerName]
	,d.[DBName]			AS [DatabaseName]
	,0
	,NULL	
	,o.[DateCreated]
	,NULL
	,NULL
	,NULL
	,'No errors encountered'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
FROM [hist].[DatabaseMaintenance_CheckDB_OK] o
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[HistServerID] = o.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = o.[DatabaseID]


GO
/*******************************************************************************************************
**  Name:			[hist].[Jobs_SQL_JobHistory_vw]
**  Desc:			View to pull back the job history results from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[Jobs_SQL_JobHistory_vw]
AS

SELECT
	s.[ServerName]
	,j.[name]					AS [JobName]
	,jh.[instance_id]
	,jh.[step_id]
	,jh.[step_name]
	,jh.[sql_message_id]
	,jh.[sql_severity]
	,jh.[message]
	,jh.[run_status]
	,jh.[run_datetime]
	,jh.[run_duration]
	,jh.[operator_id_emailed]
	,jh.[operator_id_netsent]
	,jh.[operator_id_paged]
	,jh.[retries_attempted]
	,s2.[ServerName]			AS [server]
FROM [hist].[Jobs_SQL_JobHistory] jh
INNER JOIN [hist].[Jobs_SQL_Jobs] j
	ON j.[HistJobID] = jh.[HistJobID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON j.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s2
	ON jh.[HistServerID] = s2.[HistServerID]
	

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
********************************************************************************************************/
CREATE VIEW [hist].[Jobs_SQL_Jobs_vw]
AS

WITH CurrentJobs (HistJobID)
AS
(
	SELECT
		MAX([HistJobID])
	FROM [hist].[Jobs_SQL_Jobs]
	GROUP BY [HistServerID], [job_id]
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
**  Name:			[hist].[Jobs_SQL_JobSteps_vw]
**  Desc:			View to pull back the job step definitions from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[Jobs_SQL_JobSteps_vw]
AS

WITH [CurrentJobs] (HistJobID)
AS
(
	SELECT
		MAX([HistJobID])
	FROM [hist].[Jobs_SQL_Jobs]
	GROUP BY [HistServerID], [job_id]
)
SELECT
	job_s.[ServerName]
	,j.[name]				AS [JobName]
	,j.[job_id]
	,js.[HistJobID]
	,js.[step_id]
	,js.[step_name]
	,js.[subsystem]
	,js.[command]
	,js.[flags]
	,js.[additional_parameters]
	,js.[cmdexec_success_code]
	,js.[on_success_action]
	,js.[on_success_step_id]
	,js.[on_fail_action]
	,js.[on_fail_step_id]
	,s.[ServerName]			AS [server]
	,d.[DBName]				AS [database_name]
	,js.[database_user_name]
	,js.[retry_attempts]
	,js.[retry_interval]
	,js.[os_run_priority]
	,js.[output_file_name]
	,js.[DateCreated]
FROM [hist].[Jobs_SQL_JobSteps] js
INNER JOIN [hist].[Jobs_SQL_Jobs] j
	ON js.[HistJobID] = j.[HistJobID]
INNER JOIN [hist].[ServerInventory_ServerIDs] job_s
	ON job_s.[HistServerID] = j.[HistServerID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[HistServerID] = js.[HistServerIDForServerCol]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON js.[HistDatabaseID] = d.[DatabaseID]
INNER JOIN [CurrentJobs] cj
	ON js.[HistJobID] = cj.[HistJobID]

GO
/*******************************************************************************************************
**  Name:			[hist].[Backups_History_vw]
**  Desc:			View to pull back the backup history from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[Backups_History_vw]
AS

SELECT
	sn.[ServerName]			AS [ServerName]
	,mn.[ServerName]		AS [MachineName]
	,db.[DBName]			AS [DatabaseName]
	,h.[StartDate]			AS [StartDate]
	,h.[EndDate]			AS [EndDate]
	,DATEDIFF(second,h.[StartDate],h.[EndDate]) AS [BUTime_Seconds]
	,h.[Size_MBytes]		AS [Size_MBytes]
	,t.[BackupType]			AS [BackupType]
	,t.[BackupTypeDesc]		AS [BackupTypeDesc]
	,u.[UserName]			AS [UserName]
	,CASE ld.[DeviceName]	
		WHEN 'NULL' THEN NULL
		ELSE ld.[DeviceName]	
	END						AS [LogicalDeviceName]
	,CASE pd.[DeviceName]		
		WHEN 'NULL' THEN NULL
		ELSE pd.[DeviceName] 
	END						AS [PhysicalDeviceName]
	,LEFT(pd.[DeviceName],LEN(pd.[DeviceName]) - CHARINDEX('\',REVERSE(pd.[DeviceName]))) as [BackupPath]
	,REPLACE(RIGHT(pd.[DeviceName],CHARINDEX('\',REVERSE(pd.[DeviceName]))),'\','') as [FileName]
FROM [hist].[Backups_History] h
INNER JOIN [hist].[ServerInventory_ServerIDs] sn
	ON h.[HistServerID] = sn.[HistServerID]
INNER JOIN [hist].[ServerInventory_ServerIDs] mn
	ON h.[HistServerID] = mn.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] db
	ON h.[DatabaseID] = db.[DatabaseID]
INNER JOIN [hist].[Backups_Types] t
	ON h.[BUTypeID] = t.[BackupTypeID]
INNER JOIN [hist].[Backups_Devices] ld
	ON h.[LogicalDeviceID] = ld.[DeviceID]
INNER JOIN [hist].[Backups_Devices] pd
	ON h.[PhysicalDeviceID] = pd.[DeviceID]
INNER JOIN [hist].[Users_UserNames] u
	ON h.[UserID] = u.[UserID]

GO
/*******************************************************************************************************
**  Name:			[hist].[DTSStore_Packages_vw]
**  Desc:			View to pull DTS package definitions from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[DTSStore_Packages_vw]
AS
SELECT 
	srvr.[ServerName]		AS [SourceServer]
	,names.[PackageName]	AS [name]
	,names.[PackageID]		AS [id]
	,ps.[VersionID]			AS [versionid]
	,descs.[Description]	AS [description]
	,cats.[CategoryID_GUID]	AS [categoryid]
	,ps.[CreateDate]		AS [createdate]
	,owners.[Owner]			AS [owner]
	,ps.[PackageData]		AS [packagedata]
	,owners.[Owner_sid]		AS [owner_sid]
	,ps.[PackageType]		AS [packagetype]
	,ps.[DateCreated]		AS [datecreated]
FROM [hist].[DTSStore_PackageStore] ps
INNER JOIN [hist].[DTSStore_PackageNames] names
	ON ps.[PackageNameID] = names.[PackageNameID]
INNER JOIN [hist].[DTSStore_Categories] cats
	ON ps.[CategoryID] = cats.[CategoryID]
INNER JOIN [hist].[DTSStore_Descriptions] descs
	ON ps.[DescriptionID] = descs.[DescriptionID]
INNER JOIN [hist].[DTSStore_Owners] owners
	ON ps.[OwnerID] = owners.[OwnerID]
INNER JOIN [hist].[ServerInventory_ServerIDs] srvr
	ON ps.[HistServerID] = srvr.[HistServerID]

GO
/*******************************************************************************************************
**  Name:			[hist].[SpaceUsed_FileSizes_vw]
**  Desc:			View to pull file size information from the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090717	Matt Stanford	Changed because of HistServerID change
********************************************************************************************************/
CREATE VIEW [hist].[SpaceUsed_FileSizes_vw]
AS

SELECT
	s.[ServerName]
	,p.[Path]
	,fn.[FileName]
	,CASE WHEN SUBSTRING(fs.[FileAttribute],1,1) = 'd'
		THEN 1
		ELSE 0
	END AS [IsDirectory]
	,CASE WHEN SUBSTRING(fs.[FileAttribute],2,1) = 'a'
		THEN 1
		ELSE 0
	END AS [IsArchiveSet]
	,CASE WHEN SUBSTRING(fs.[FileAttribute],3,1) = '?'
		THEN 1
		ELSE 0
	END AS [IsSomething]
	,CASE WHEN SUBSTRING(fs.[FileAttribute],4,1) = 'h'
		THEN 1
		ELSE 0
	END AS [IsHidden]
	,fs.[FileAttribute]
	,fs.[FileSizeKB]
	,fs.[SampleDate]
FROM [hist].[SpaceUsed_FileSizes] fs
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON fs.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[General_FullFileName] ffn
	ON ffn.[HistPathFileNameID] = fs.[HistPathFileNameID]
INNER JOIN [hist].[General_Paths] p
	ON ffn.[HistPathID] = p.[HistPathID]
INNER JOIN [hist].[General_FileNames] fn
	ON ffn.[HistFileNameID] = fn.[HistFileNameID]

GO

PRINT('Adding new hist.ServerInventory objects')
GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_GetServerID]
**  Desc:			Gets/Creates a HistServerID based on the Server Name
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090716	Matt Stanford	Reduced the data type from VARCHAR(1000) to VARCHAR(200)
**								Changed because of HistServerID change
********************************************************************************************************/
CREATE PROCEDURE [hist].[ServerInventory_GetServerID] (
	@ServerName			VARCHAR(200)
	,@ServerID			INT OUTPUT
)
AS

-- Find the ServerID
SELECT 
	@ServerID = [HistServerID]
FROM 
	[hist].[ServerInventory_ServerIDs] id
WHERE (id.[ServerName] = @ServerName AND @ServerName IS NOT NULL)
OR (id.[ServerName] IS NULL AND @ServerName IS NULL)

IF @ServerID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_ServerIDs] ([ServerName]) 
	VALUES (@ServerName)
	
	SET @ServerID = SCOPE_IDENTITY()
END

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_Configurations_InsertValue]
**  Desc:			Adds all of the configuration values historically for all servers
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [hist].[ServerInventory_SQL_Configurations_InsertValue] (
	@ServerName					VARCHAR(200)
	,@ConfigName				NVARCHAR(35)
	,@ConfigValue				SQL_VARIANT
	,@ConfigValueInUse			SQL_VARIANT
)
AS

DECLARE 
	@RefConfigOptionID			INT
	,@HistServerID				INT
	,@HistConfigValueID			INT

-- Get/Create the HistServerID
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @HistServerID OUTPUT

-- Lookup the ConfigOptionID
SELECT
	@RefConfigOptionID = co.[RefConfigOptionID]
FROM [ref].[ServerInventory_SQL_ConfigurationOptions] co
WHERE co.[name] = @ConfigName

IF @RefConfigOptionID IS NOT NULL
BEGIN

	-- Check to see if the value already exists
	SELECT 
		@HistConfigValueID = MAX([HistConfigValueID])
	FROM [hist].[ServerInventory_SQL_ConfigurationValues]
	WHERE [RefConfigOptionID]	= @RefConfigOptionID
	AND [HistServerID]			= @HistServerID
	AND [value]					= @ConfigValue
	AND [value_in_use]			= @ConfigValueInUse
	
	IF @HistConfigValueID IS NOT NULL
	BEGIN
		-- Configuration Exists, mark it as "seen"
		-- Do an update
		UPDATE [hist].[ServerInventory_SQL_ConfigurationValues]
		SET [DateLastSeenOn] = GETDATE()
		WHERE [HistConfigValueID] = @HistConfigValueID
	END
	ELSE
	BEGIN
		-- Doesn't exist, new configuration!!!
		-- Do an insert
		INSERT INTO [hist].[ServerInventory_SQL_ConfigurationValues] ([RefConfigOptionID], [HistServerID], [value], [value_in_use])
		VALUES (@RefConfigOptionID, @HistServerID, @ConfigValue, @ConfigValueInUse)
	
	END

END
GO
PRINT('Adding modified SpaceUsed objects')
GO

/*******************************************************************************************************
**  Name:			[hist].[SpaceUsed_DatabaseSizes_Delta_vw]
**  Desc:			View to pull back the database sizes from the repository and show the daily delta
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090706	Matt Stanford	Fully backwards-compatible change to add DataSizeUnusedMB and LogSizeUnusedMB
**	20090716	Matt Stanford	Added DataPercentChange and LogPercentChange columns
********************************************************************************************************/
CREATE VIEW [hist].[SpaceUsed_DatabaseSizes_Delta_vw]
AS
WITH DBData AS (
	SELECT 
		[HistServerID]
		,[DatabaseID]
		,[DataSizeMB]
		,[LogSizeMB]
		,[DataSizeUnusedMB]
		,[LogSizeUnusedMB]
		,[SampleDate]
		,ROW_NUMBER() OVER (PARTITION BY [HistServerID], [DatabaseID] ORDER BY SampleDate) as rownum
	FROM [hist].[SpaceUsed_DatabaseSizes]
)
SELECT 
	s.[ServerName]
	,d.[DBName]
	,currow.[DataSizeMB]
	,currow.[DataSizeMB] - prevrow.[DataSizeMB]					AS [DataSizeMBIncrease]
	,CASE
		WHEN prevrow.[DataSizeMB] = 0 THEN 0
		ELSE CAST(CAST(currow.[DataSizeMB] - prevrow.[DataSizeMB] AS DECIMAL(10,2)) * 100 / prevrow.[DataSizeMB] AS DECIMAL(10,2))
	END															AS [DataPercentChange]
	,currow.[LogSizeMB]
	,currow.[LogSizeMB] - prevrow.[LogSizeMB]					AS [LogSizeMBIncrease]
	,CASE
		WHEN prevrow.[LogSizeMB] = 0 THEN 0
		ELSE CAST(CAST(currow.[LogSizeMB] - prevrow.[LogSizeMB] AS DECIMAL(10,2)) * 100 / prevrow.[LogSizeMB] AS DECIMAL(10,2))
	END															AS [LogPercentChange]
	,currow.[DataSizeUnusedMB]
	,currow.[DataSizeUnusedMB] - prevrow.[DataSizeUnusedMB]		AS [DataSizeUnusedMBIncrease]
	,currow.[LogSizeUnusedMB]
	,currow.[LogSizeUnusedMB] - prevrow.[LogSizeUnusedMB]		AS [LogSizeUnusedMBIncrease]
	,currow.[SampleDate]
FROM DBData currow
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[HistServerID] = currow.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = currow.[DatabaseID]
LEFT OUTER JOIN DBData prevrow
	ON prevrow.[HistServerID] = currow.[HistServerID]
	AND prevrow.[DatabaseID] = currow.[DatabaseID]
	AND currow.[rownum] = prevrow.[rownum] + 1


GO

PRINT('Adding new rpt procedures')
GO
/*******************************************************************************************************
**	Name:			[rpt].[SpaceUsed_AvgDBGrowthPerDay]
**	Desc:			Reporting procedure to get average database growth per day
**	Auth:			Matt Stanford
**	Debug:			
DECLARE
	@Exclusions	[DatabaseListType]
	
INSERT INTO @Exclusions
VALUES('OECArchive'),('OECImports'),('admin'),('master'),('model'),('OECFaxManager'),('tempdb'),('OECConquest')

EXEC [report].[SpaceUsed_AvgDBGrowthPerDay] '2009-01-17', '2009-04-01', 'S227938HZ1SQL1\Legacy', @Exclusions

**	Date:			2009-04-28
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090716	Matt Stanford	Moved from "report" schema to "rpt"
********************************************************************************************************/
CREATE PROCEDURE [rpt].[SpaceUsed_AvgDBGrowthPerDay] (
	@StartDate		DATETIME
	,@EndDate		DATETIME
	,@ServerName	VARCHAR(200)
	,@Exclusions	[DatabaseListType] READONLY
)
AS 
SET NOCOUNT ON 
/*
-- DEBUG!!!
DECLARE
	@StartDate		DATETIME
	,@EndDate		DATETIME
	,@ServerName	VARCHAR(200)
	,@Exclusions	[DatabaseListType]
	
INSERT INTO @Exclusions
VALUES('OECArchive'),('OECImports'),('admin'),('master'),('model'),('OECFaxManager'),('tempdb'),('OECConquest')
	
SET @StartDate = '2009-01-17'
SET @EndDate = '2009-04-01'
SET @ServerName = 's227938hz1sql1\legacy'
*/
----
DECLARE 
	@InitValue		BIGINT
	,@FinalValue	BIGINT
	,@Diff			BIGINT
	,@Days			INT
	
SET @Days = DATEDIFF(day,@StartDate,@EndDate)
	
SELECT
	@InitValue = SUM(ds.[DataSizeMB]) + SUM(ds.[LogSizeMB])
FROM [hist].[SpaceUsed_DatabaseSizes_vw] ds
LEFT OUTER JOIN @Exclusions ex
	ON ds.[DBName] = ex.[DBName]
WHERE ex.[DBName] IS NULL
AND ds.[SampleDate] BETWEEN @StartDate AND DATEADD(day,1,@StartDate)
AND ds.[ServerName] = @ServerName

SELECT
	@FinalValue = SUM(ds.[DataSizeMB]) + SUM(ds.[LogSizeMB])
FROM [hist].[SpaceUsed_DatabaseSizes_vw] ds
LEFT OUTER JOIN @Exclusions ex
	ON ds.[DBName] = ex.[DBName]
WHERE ex.[DBName] IS NULL
AND ds.[SampleDate] BETWEEN DATEADD(day,-1,@EndDate) AND @EndDate
AND ds.[ServerName] = @ServerName

SET @Diff = @FinalValue - @InitValue

SELECT 
	@InitValue AS [Initial Size (MB)]
	,@FinalValue AS [Final Size (MB)]
	,CAST(@Diff AS DECIMAL(12,2))/@Days AS [Size (MB) Per Day Growth]

GO
/*******************************************************************************************************
**	Name:			[rpt].[Backup_Summary_vw]
**	Desc:			View to retrieve backup history SSRS report
**	Auth:			Adam Bean (SQLSlayer.com)
**	Date:			2009.04.02
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  20090716	Matt Stanford	Changed the join criteria to be based on name, not ID
********************************************************************************************************/
CREATE VIEW [rpt].[Backup_Summary_vw]

AS

SELECT 
	ISNULL(s.[Environment],'Server Was Removed') AS [Environment]
	,b.[ServerName]
	,b.[DatabaseName]			AS [DBName]
	,b.[StartDate]
	,b.[EndDate]
	,b.[BUTime_Seconds]
	,b.[BUTime_Seconds] / 60	AS [BUTime_Minutes]
	,b.[Size_MBytes]			AS [Size_MB]
	,b.[Size_MBytes] / 1024		AS [Size_GB]
	,b.[BackupType]
	,b.[UserName]
	,b.[PhysicalDeviceName]
	,b.[BackupPath]
	,b.[FileName]
FROM [hist].[Backups_History_vw] b
LEFT OUTER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
	ON CASE 
		WHEN s.[InstanceName] IS NOT NULL THEN s.[ServerName] + '\' + s.[InstanceName]
		ELSE s.[ServerName]
	END = b.[ServerName]

GO

/*******************************************************************************************************
**	Name:			[rpt].[DBSizes_Summary_vw]
**	Desc:			View to retrieve database size history SSRS report
**	Auth:			Adam Bean (SQLSlayer.com)
**	Date:			2009.04.08
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:		Description:
**	--------	--------	---------------------------------------
**  
********************************************************************************************************/

CREATE VIEW [rpt].[DBSizes_Summary_vw]

AS

SELECT 
      s.[Environment]
      ,d.[ServerName]
      ,d.[DBName]             
      ,d.[DataSizeMB]
      ,d.[DataSizeMBIncrease]
      ,d.[DataPercentChange]
      ,d.[LogSizeMB]
      ,d.[LogSizeMBIncrease]
      ,d.[LogPercentChange]
      ,d.[SampleDate]
FROM [hist].[SpaceUsed_DatabaseSizes_Delta_vw] d
JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
	ON CASE 
		WHEN s.[InstanceName] IS NOT NULL THEN s.[ServerName] + '\' + s.[InstanceName]
		ELSE s.[ServerName]
	END = d.[ServerName]

GO
/*******************************************************************************************************
**	Name:			[rpt].[Backup_Summary]
**	Desc:			Reporting procedure for backup history SSRS report
**	Auth:			Adam Bean (SQLSlayer.com)
**	Date:			2009.04.02
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:		Description:
**	--------	--------	---------------------------------------
**  
********************************************************************************************************/

CREATE PROCEDURE [rpt].[Backup_Summary]
(
	@Environment	VARCHAR(MAX)	= NULL
	,@ServerName	VARCHAR(MAX)	= NULL
	,@DBName		NVARCHAR(MAX)	= NULL
	,@DateStart		DATETIME		= NULL
	,@DateEnd		DATETIME		= NULL
)

AS

SET NOCOUNT ON

SELECT 
	[Environment]
	,[ServerName]
	,[DBName]
	,[StartDate]
	,[EndDate]
	,[BUTime_Seconds]
	,[BUTime_Minutes]
	,[Size_MB]
	,[Size_GB]
	,[BackupType]
	,[UserName]
	,[PhysicalDeviceName]
	,[BackupPath]
	,[FileName]
FROM [rpt].[Backup_Summary_vw]
WHERE (@Environment IS NULL OR [Environment] IN (SELECT [item] AS [Environment] FROM [admin].[dbo].[Split_fn](@Environment,',')))
AND (@ServerName IS NULL OR [ServerName] IN (SELECT [item] AS [ServerName] FROM [admin].[dbo].[Split_fn](@ServerName,',')))
AND (@DBName IS NULL OR [DBName] IN (SELECT [item] AS [DatabaseName] FROM [admin].[dbo].[Split_fn](@DBName,',')))
AND (@DateStart IS NULL AND @DateEnd IS NULL OR [StartDate] BETWEEN @DateStart AND @DateEnd)

SET NOCOUNT OFF

GO
/*******************************************************************************************************
**	Name:			[rpt].[DBSizes_Summary]
**	Desc:			Reporting procedure for database sizes history SSRS report
**	Auth:			Adam Bean (SQLSlayer.com)
**	Date:			2009.04.08
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:		Description:
**	--------	--------	---------------------------------------
**  
********************************************************************************************************/

CREATE PROCEDURE [rpt].[DBSizes_Summary]
(
	@Environment	VARCHAR(MAX)	= NULL
	,@ServerName	VARCHAR(MAX)	= NULL
	,@DBName		NVARCHAR(MAX)	= NULL
	,@DateStart		DATETIME		= NULL
	,@DateEnd		DATETIME		= NULL
)

AS

SET NOCOUNT ON

SELECT 
	[Environment]
	,[ServerName]
	,[DBName]			
	,[DataSizeMB]
	,[DataSizeMBIncrease]
	,[LogSizeMB]
	,[LogSizeMBIncrease]
	,[SampleDate]
FROM [rpt].[DBSizes_Summary_vw]
WHERE (@Environment IS NULL OR [Environment] IN (SELECT [item] AS [Environment] FROM [admin].[dbo].[Split_fn](@Environment,',')))
AND (@ServerName IS NULL OR [ServerName] IN (SELECT [item] AS [ServerName] FROM [admin].[dbo].[Split_fn](@ServerName,',')))
AND (@DBName IS NULL OR [DBName] IN (SELECT [item] AS [DatabaseName] FROM [admin].[dbo].[Split_fn](@DBName,',')))
AND (@DateStart IS NULL AND @DateEnd IS NULL OR [SampleDate] BETWEEN @DateStart AND @DateEnd)

SET NOCOUNT OFF

GO

PRINT('Adding indexes for speed')
CREATE INDEX [IX__SpaceUsed_DBSizes__SampleDate] ON [hist].[SpaceUsed_DatabaseSizes] ([SampleDate]) WITH (FILLFACTOR = 100)
CREATE INDEX [IX__SpaceUsed_DBSizes__DatabaseID__SampleDate] ON [hist].[SpaceUsed_DatabaseSizes] ([DatabaseID],[SampleDate]) WITH (FILLFACTOR = 85)
CREATE INDEX [IX__SpaceUsed_DBSizes__HistServerID__SampleDate] ON [hist].[SpaceUsed_DatabaseSizes] ([HistServerID],[SampleDate]) WITH (FILLFACTOR = 85)


PRINT N'Stamping database version 1.3.0'
EXEC sys.sp_updateextendedproperty @name=N'Version', @value=N'1.3.0'


--PRINT N'---- Rolled everything back ----'
--ROLLBACK
COMMIT TRANSACTION