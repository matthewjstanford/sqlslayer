
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
USE [DBACentral]
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Creating schemata'
GO
CREATE SCHEMA [migrate]
AUTHORIZATION [dbo]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
CREATE SCHEMA [report]
AUTHORIZATION [dbo]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[Backups_History]'
GO
ALTER TABLE [hist].[Backups_History] DROP
CONSTRAINT [FK_BUHist_LogicalDeviceID],
CONSTRAINT [FK_BUHist_PhysicalDeviceID],
CONSTRAINT [FK_BUHist_BackupType],
CONSTRAINT [FK_BUHist_ServerID],
CONSTRAINT [FK_BUHist_ServerID2],
CONSTRAINT [FK_BUHist_UserID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]'
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] DROP
CONSTRAINT [FK_ChangeTracking_SQL_ObjectIDs_ObjectID],
CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID2]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[DTSStore_PackageStore]'
GO
ALTER TABLE [hist].[DTSStore_PackageStore] DROP
CONSTRAINT [FK_Catagories_CategoryID],
CONSTRAINT [FK_Descriptions_DescriptionID],
CONSTRAINT [FK_Owners_OwnerID],
CONSTRAINT [FK_PackageNames_PackageNameID],
CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[Jobs_SQL_JobHistory]'
GO
ALTER TABLE [hist].[Jobs_SQL_JobHistory] DROP
CONSTRAINT [FK_JobHistory_JobID],
CONSTRAINT [FK_JobHistory_HistServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[Jobs_SQL_JobSteps]'
GO
ALTER TABLE [hist].[Jobs_SQL_JobSteps] DROP
CONSTRAINT [FK_sysjobsteps_JobID],
CONSTRAINT [FK_sysjobsteps_HistServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[ServerInventory_SQL_ServerDBTableIDs]'
GO
ALTER TABLE [hist].[ServerInventory_SQL_ServerDBTableIDs] DROP
CONSTRAINT [FK_SI_ServerIDs_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[SpaceUsed_DatabaseSizes]'
GO
ALTER TABLE [hist].[SpaceUsed_DatabaseSizes] DROP
CONSTRAINT [FK_SI_ServerIDs_ServerID_2]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [hist].[Jobs_SQL_Jobs]'
GO
ALTER TABLE [hist].[Jobs_SQL_Jobs] DROP
CONSTRAINT [FK_SQL_sysjobs_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[NTPermissions_ServerExceptions]'
GO
ALTER TABLE [dbo].[NTPermissions_ServerExceptions] DROP
CONSTRAINT [FK__NTPermiss__Serve__1E6F845E]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[Backups_Jobs]'
GO
ALTER TABLE [dbo].[Backups_Jobs] DROP
CONSTRAINT [FK_Master_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[ServerInventory_ClusterNodes]'
GO
ALTER TABLE [dbo].[ServerInventory_ClusterNodes] DROP
CONSTRAINT [FK_SI_ClusterNodes_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[ServerInventory_ServerOwners_Xref]'
GO
ALTER TABLE [dbo].[ServerInventory_ServerOwners_Xref] DROP
CONSTRAINT [FK_SI_Master_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[ServerInventory_ServerApplications_Xref]'
GO
ALTER TABLE [dbo].[ServerInventory_ServerApplications_Xref] DROP
CONSTRAINT [FK_SI_Master_ServerID2]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[ServerInventory_SQL_AttributeList]'
GO
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] DROP
CONSTRAINT [FK_SI_SQL_Master_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[ServerInventory_DatabaseOwners_Xref]'
GO
ALTER TABLE [dbo].[ServerInventory_DatabaseOwners_Xref] DROP
CONSTRAINT [FK_SI_SQLMaster_ServerID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[Backups_Devices]'
GO
ALTER TABLE [hist].[Backups_Devices] DROP CONSTRAINT [PK__Backups___49E1233122AA2996]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[Backups_Types]'
GO
ALTER TABLE [hist].[Backups_Types] DROP CONSTRAINT [PK__Backups___F928CDC915502E78]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[ChangeTracking_SQL_ObjectIDs]'
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ObjectIDs] DROP CONSTRAINT [PK__ChangeTr__9A6192B002FC7413]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[DTSStore_Categories]'
GO
ALTER TABLE [hist].[DTSStore_Categories] DROP CONSTRAINT [PK__DTSStore__19093A2B0F975522]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[DTSStore_Descriptions]'
GO
ALTER TABLE [hist].[DTSStore_Descriptions] DROP CONSTRAINT [PK__DTSStore__A58A9FEB0BC6C43E]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[DTSStore_Owners]'
GO
ALTER TABLE [hist].[DTSStore_Owners] DROP CONSTRAINT [PK__DTSStore__819385982C3393D0]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[DTSStore_PackageNames]'
GO
ALTER TABLE [hist].[DTSStore_PackageNames] DROP CONSTRAINT [PK__DTSStore__329D7CF7286302EC]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[Jobs_SQL_Jobs]'
GO
ALTER TABLE [hist].[Jobs_SQL_Jobs] DROP CONSTRAINT [PK__Jobs_SQL__38632B7110566F31]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[ServerInventory_ServerIDs]'
GO
ALTER TABLE [hist].[ServerInventory_ServerIDs] DROP CONSTRAINT [PK__ServerIn__C56AC8875EBF139D]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[ServerInventory_SQL_AttributeList]'
GO
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] DROP CONSTRAINT [PK__ServerIn__A2A2BAAB41EDCAC5]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[ServerInventory_SQL_Master]'
GO
ALTER TABLE [dbo].[ServerInventory_SQL_Master] DROP CONSTRAINT [PK__ServerIn__C56AC88774AE54BC]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [hist].[Users_UserNames]'
GO
ALTER TABLE [hist].[Users_UserNames] DROP CONSTRAINT [PK__Users_Us__1788CCAC49C3F6B7]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating types'
GO
CREATE TYPE [dbo].[DatabaseListType] AS TABLE
(
[DBName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[DatabaseMaintenance_CheckDB_OK]'
GO
CREATE TABLE [hist].[DatabaseMaintenance_CheckDB_OK]
(
[HistServerID] [int] NOT NULL,
[DatabaseID] [int] NOT NULL,
[CheckDBID] [bigint] NOT NULL,
[DateCreated] [datetime] NOT NULL
) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [CIX_CheckDB_OK__DateCreated] on [hist].[DatabaseMaintenance_CheckDB_OK]'
GO
CREATE CLUSTERED INDEX [CIX_CheckDB_OK__DateCreated] ON [hist].[DatabaseMaintenance_CheckDB_OK] ([DateCreated]) WITH (FILLFACTOR=100) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__Database__E9DF81BB7B71F792] on [hist].[DatabaseMaintenance_CheckDB_OK]'
GO
ALTER TABLE [hist].[DatabaseMaintenance_CheckDB_OK] ADD CONSTRAINT [PK__Database__E9DF81BB7B71F792] PRIMARY KEY NONCLUSTERED  ([HistServerID], [DatabaseID], [CheckDBID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[DatabaseMaintenance_CheckDB_Errors]'
GO
CREATE TABLE [hist].[DatabaseMaintenance_CheckDB_Errors]
(
[HistServerID] [int] NOT NULL,
[DatabaseID] [int] NOT NULL,
[CheckDBID] [bigint] NOT NULL,
[RunID] [uniqueidentifier] NOT NULL,
[DateCreated] [datetime] NOT NULL,
[Error] [int] NULL,
[Level] [int] NULL,
[State] [int] NULL,
[MessageText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RepairLevel] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NULL,
[ObjectID] [int] NULL,
[IndexId] [int] NULL,
[PartitionID] [bigint] NULL,
[AllocUnitID] [bigint] NULL,
[File] [int] NULL,
[Page] [int] NULL,
[Slot] [int] NULL,
[RefFile] [int] NULL,
[RefPage] [int] NULL,
[RefSlot] [int] NULL,
[Allocation] [int] NULL
) ON [History] TEXTIMAGE_ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [CIX_CheckDB_Errors__DateCreated] on [hist].[DatabaseMaintenance_CheckDB_Errors]'
GO
CREATE CLUSTERED INDEX [CIX_CheckDB_Errors__DateCreated] ON [hist].[DatabaseMaintenance_CheckDB_Errors] ([DateCreated]) WITH (FILLFACTOR=100) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__Database__E9DF81BB75B91E3C] on [hist].[DatabaseMaintenance_CheckDB_Errors]'
GO
ALTER TABLE [hist].[DatabaseMaintenance_CheckDB_Errors] ADD CONSTRAINT [PK__Database__E9DF81BB75B91E3C] PRIMARY KEY NONCLUSTERED  ([HistServerID], [DatabaseID], [CheckDBID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_CheckDB_Errors__RunID] on [hist].[DatabaseMaintenance_CheckDB_Errors]'
GO
CREATE NONCLUSTERED INDEX [IX_CheckDB_Errors__RunID] ON [hist].[DatabaseMaintenance_CheckDB_Errors] ([RunID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [hist].[SpaceUsed_TableSizes_vw]'
GO
ALTER VIEW [hist].[SpaceUsed_TableSizes_vw]
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
	ON s.[ServerID] = m.[ServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = m.[DatabaseID]
INNER JOIN [hist].[ServerInventory_SQL_TableIDs] t
	ON t.[TableID] = m.[TableID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[DatabaseMaintenance_CheckDB_vw]'
GO

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
	ON s.[ServerID] = e.[HistServerID]
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
	ON s.[ServerID] = o.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = o.[DatabaseID]

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [hist].[ServerInventory_SQL_GetDatabaseID]'
GO
ALTER PROCEDURE [hist].[ServerInventory_SQL_GetDatabaseID] (
	@DBName				SYSNAME
	,@DatabaseID		INT OUTPUT
)
AS

SELECT 
	@DatabaseID = [DatabaseID]
FROM 
	[hist].[ServerInventory_SQL_DatabaseIDs] id
WHERE (id.[DBName] = @DBName AND @DBName IS NOT NULL)
OR (id.[DBName] IS NULL AND @DBName IS NULL)

IF @DatabaseID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_DatabaseIDs] (DBName) 
	VALUES (@DBName)
	
	SET @DatabaseID = SCOPE_IDENTITY()
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [hist].[ServerInventory_GetServerID]'
GO
ALTER PROCEDURE [hist].[ServerInventory_GetServerID] (
	@ServerName			VARCHAR(1000)
	,@ServerID			INT OUTPUT
)
AS

-- Find the ServerID
SELECT 
	@ServerID = [ServerID]
FROM 
	[hist].[ServerInventory_ServerIDs] id
WHERE (id.[ServerName] = @ServerName AND @ServerName IS NOT NULL)
OR (id.[ServerName] IS NULL AND @ServerName IS NULL)

IF @ServerID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_ServerIDs] (ServerName) 
	VALUES (@ServerName)
	
	SET @ServerID = SCOPE_IDENTITY()
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [report].[SpaceUsed_AvgDBGrowthPerDay]'
GO
/*******************************************************************************************************
**	Name:			[report].[SpaceUsed_AvgDBGrowthPerDay]
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
**	Date:		Author:		Description:
**	--------	--------	---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [report].[SpaceUsed_AvgDBGrowthPerDay] (
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
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [hist].[Backups_History_vw]'
GO

ALTER VIEW [hist].[Backups_History_vw]
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
	ON h.[ServerID] = sn.[ServerID]
INNER JOIN [hist].[ServerInventory_ServerIDs] mn
	ON h.[ServerID] = mn.[ServerID]
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
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[General_Paths]'
GO
CREATE TABLE [hist].[General_Paths]
(
[HistPathID] [int] NOT NULL IDENTITY(1, 1),
[Path] [varchar] (900) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [date] NULL DEFAULT (getdate())
) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_HistPathID] on [hist].[General_Paths]'
GO
ALTER TABLE [hist].[General_Paths] ADD CONSTRAINT [PK_HistPathID] PRIMARY KEY CLUSTERED  ([HistPathID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_Paths] on [hist].[General_Paths]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Paths] ON [hist].[General_Paths] ([Path]) WITH (FILLFACTOR=90) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[General_GetPathID]'
GO

CREATE PROCEDURE [hist].[General_GetPathID] (
	@Path					VARCHAR(900)
	,@HistPathID			INT OUTPUT
)
AS

SET NOCOUNT ON

SELECT
	@HistPathID = [HistPathID]
FROM [hist].[General_Paths] p
WHERE p.[Path] = @Path

IF @HistPathID IS NULL AND @Path IS NOT NULL
BEGIN
	INSERT INTO [hist].[General_Paths] ([Path])
	VALUES (@Path)
	
	SET @HistPathID = SCOPE_IDENTITY()
END
	
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[General_FileNames]'
GO
CREATE TABLE [hist].[General_FileNames]
(
[HistFileNameID] [int] NOT NULL IDENTITY(1, 1),
[FileName] [varchar] (900) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [date] NULL DEFAULT (getdate())
) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_HistFileNameID] on [hist].[General_FileNames]'
GO
ALTER TABLE [hist].[General_FileNames] ADD CONSTRAINT [PK_HistFileNameID] PRIMARY KEY CLUSTERED  ([HistFileNameID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_FileNames] on [hist].[General_FileNames]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_FileNames] ON [hist].[General_FileNames] ([FileName]) WITH (FILLFACTOR=90) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[General_GetFileNameID]'
GO

CREATE PROCEDURE [hist].[General_GetFileNameID] (
	@FileName				VARCHAR(900)
	,@HistFileNameID		INT OUTPUT
)
AS

SET NOCOUNT ON

SELECT
	@HistFileNameID = [HistFileNameID]
FROM [hist].[General_FileNames] f
WHERE f.[FileName] = @FileName

IF @HistFileNameID IS NULL AND @FileName IS NOT NULL
BEGIN
	INSERT INTO [hist].[General_FileNames] ([FileName])
	VALUES (@FileName)
	
	SET @HistFileNameID = SCOPE_IDENTITY()
END
	
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[General_FullFileName]'
GO
CREATE TABLE [hist].[General_FullFileName]
(
[HistPathFileNameID] [int] NOT NULL IDENTITY(1, 1),
[HistPathID] [int] NULL,
[HistFileNameID] [int] NULL,
[DateCreated] [date] NULL DEFAULT (getdate())
) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_HistPathFileNameID] on [hist].[General_FullFileName]'
GO
ALTER TABLE [hist].[General_FullFileName] ADD CONSTRAINT [PK_HistPathFileNameID] PRIMARY KEY CLUSTERED  ([HistPathFileNameID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_FullFileName] on [hist].[General_FullFileName]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_FullFileName] ON [hist].[General_FullFileName] ([HistPathID], [HistFileNameID]) WITH (FILLFACTOR=90) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[SpaceUsed_FileSizes]'
GO
CREATE TABLE [hist].[SpaceUsed_FileSizes]
(
[HistServerID] [int] NOT NULL,
[HistPathFileNameID] [int] NOT NULL,
[FileAttribute] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSizeKB] [bigint] NULL,
[SampleDate] [smalldatetime] NOT NULL DEFAULT (getdate())
) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_SpaceUsed_FileSizes] on [hist].[SpaceUsed_FileSizes]'
GO
ALTER TABLE [hist].[SpaceUsed_FileSizes] ADD CONSTRAINT [PK_SpaceUsed_FileSizes] PRIMARY KEY CLUSTERED  ([HistServerID], [SampleDate], [HistPathFileNameID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[SpaceUsed_FileSizes_vw]'
GO

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
	ON fs.[HistServerID] = s.[ServerID]
INNER JOIN [hist].[General_FullFileName] ffn
	ON ffn.[HistPathFileNameID] = fs.[HistPathFileNameID]
INNER JOIN [hist].[General_Paths] p
	ON ffn.[HistPathID] = p.[HistPathID]
INNER JOIN [hist].[General_FileNames] fn
	ON ffn.[HistFileNameID] = fn.[HistFileNameID]

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[DatabaseMaintenance_InsertCheckDBResults]'
GO

CREATE PROCEDURE [hist].[DatabaseMaintenance_InsertCheckDBResults]
(
	@ServerName			SYSNAME
	,@DatabaseName		SYSNAME
	,@CheckDBID			BIGINT
	,@RunID				UNIQUEIDENTIFIER
	,@DateCreated		DATETIME
	,@Error				INT
	,@Level				INT
	,@State				INT
	,@MessageText		VARCHAR(MAX)
	,@RepairLevel		VARCHAR(128)
	,@Status			INT
	,@ObjectID			INT
	,@IndexID			INT
	,@PartitionID		BIGINT
	,@AllocUnitID		BIGINT
	,@File				INT
	,@Page				INT
	,@Slot				INT
	,@RefFile			INT
	,@RefPage			INT
	,@RefSlot			INT
	,@Allocation		INT
)
AS

SET NOCOUNT ON

DECLARE
	@IsOK			BIT
	,@HistServerID	INT
	,@DatabaseID	INT
	
-- Get the IDs for the insert
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @HistServerID OUTPUT
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @DatabaseName, @DatabaseID OUTPUT

-- Logic to determine if the run was successful or not
IF COALESCE(@Error,@Level,@State) IS NOT NULL
	SET @IsOK = 0
ELSE
	SET @IsOK = 1
	
IF @IsOK = 1
BEGIN
	MERGE INTO [hist].[DatabaseMaintenance_CheckDB_OK] AS t
	USING (SELECT @HistServerID, @DatabaseID, @CheckDBID) AS s (HistServerID, DatabaseID, CheckDBID)
	ON s.[HistServerID] = t.[HistServerID]
	AND s.[DatabaseID] = t.[DatabaseID]
	AND s.[CheckDBID] = t.[CheckDBID]
	WHEN NOT MATCHED THEN
	INSERT ([HistServerID],[DatabaseID],[CheckDBID], [DateCreated])
	VALUES (@HistServerID,@DatabaseID,@CheckDBID,@DateCreated);
END
ELSE
BEGIN
	MERGE INTO [hist].[DatabaseMaintenance_CheckDB_Errors] AS t
	USING (SELECT @HistServerID, @DatabaseID, @CheckDBID) AS s (HistServerID, DatabaseID, CheckDBID)
	ON s.[HistServerID] = t.[HistServerID]
	AND s.[DatabaseID] = t.[DatabaseID]
	AND s.[CheckDBID] = t.[CheckDBID]
	WHEN NOT MATCHED THEN
	INSERT ([HistServerID],[DatabaseID],[RunID],[CheckDBID],[DateCreated],[Error],[Level],[State],[MessageText],[RepairLevel],[Status],[ObjectID],[IndexID]
	,[PartitionID],[AllocUnitID],[File],[Page],[Slot],[RefFile],[RefPage],[RefSlot],[Allocation])
	VALUES (@HistServerID,@DatabaseID,@RunID,@CheckDBID,@DateCreated,@Error,@Level,@State,@MessageText,@RepairLevel,@Status,@ObjectID,@IndexID
	,@PartitionID,@AllocUnitID,@File,@Page,@Slot,@RefFile,@RefPage,@RefSlot,@Allocation);
END

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[ServerInventory_SQL_AllServers_vw]'
GO

ALTER VIEW [dbo].[ServerInventory_SQL_AllServers_vw]
AS
SELECT 
	m.[ServerID]
	,m.[ServerName]
	,m.[InstanceName]
	,m.[PortNumber]
	,CASE 
		WHEN m.[InstanceName] IS NOT NULL AND m.[PortNumber] IS NOT NULL
			THEN m.[ServerName] + '\' + m.[InstanceName] + ',' + CAST(m.[PortNumber] AS VARCHAR(10))
		WHEN m.[InstanceName] IS NOT NULL
			THEN m.[ServerName] + '\' + m.[InstanceName]
		WHEN m.[PortNumber] IS NOT NULL
			THEN m.[ServerName] + ',' + CAST(m.[PortNumber] AS VARCHAR(10))
		ELSE m.[ServerName]
	END as [FullName]
	,m.[SQLVersion]
	,env.[EnvironmentName]	as Environment
	,ed.[EditionName]		as Edition
	,m.[Description]
	,m.[UseCredential]
	,cred.[UserName]
	,cred.[Password]
	,'Data Source=' + CASE 
		WHEN m.[InstanceName] IS NOT NULL AND m.[PortNumber] IS NOT NULL
			THEN m.[ServerName] + '\' + m.[InstanceName] + ',' + CAST(m.[PortNumber] AS VARCHAR(10))
		WHEN m.[InstanceName] IS NOT NULL
			THEN m.[ServerName] + '\' + m.InstanceName
		WHEN m.[PortNumber] IS NOT NULL
			THEN m.[ServerName] + ',' + CAST(m.[PortNumber] AS VARCHAR(10))
		ELSE m.[ServerName]
	END + ';Initial Catalog=master;' + CASE
		WHEN m.[UseCredential] = 0 
			THEN 'Integrated Security=SSPI;'
		ELSE 'User Id=' + cred.[UserName] + ';Password=' + cred.[Password] + ';'
	END AS [DotNetConnectionString]
FROM [dbo].[ServerInventory_SQL_Master] m
INNER JOIN [dbo].[ServerInventory_Environments] env
	ON env.[EnvironmentID] = m.[EnvironmentID]
INNER JOIN [dbo].[ServerInventory_SQL_Editions] ed
	ON ed.[EditionID] = m.[EditionID]
LEFT OUTER JOIN [dbo].[ServerInventory_SQL_ServerCredentials] cred
	ON cred.[CredentialID] = m.[CredentialID]
WHERE m.[Enabled] = 1

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[SpaceUsed_CollectTableOrDatabase_vw]'
GO
ALTER VIEW [dbo].[SpaceUsed_CollectTableOrDatabase_vw]
AS

WITH TableOrDB
AS
(
	SELECT 
		a.[ServerName]
		,a.[SQLVersion]
		,a.[AttribName]
		,a.[AttribValue]
		,s.[DotNetConnectionString]
	FROM [dbo].[ServerInventory_SQL_ServerAttributes_vw] a
	INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
		ON a.ServerID = s.ServerID
	WHERE a.[AttribName] IN ('SpaceUsed_Collect_Database', 'SpaceUsed_Collect_Table')
)
SELECT 
	COALESCE(t.[ServerName],d.[ServerName]) as ServerName
	,COALESCE(t.[SQLVersion],d.[SQLVersion]) as SQLVersion
	,CASE WHEN t.[AttribValue] IS NULL 
		THEN 0
		ELSE 1
	END as CollectTable
	,CASE WHEN d.[AttribValue] IS NULL 
		THEN 0
		ELSE 1
	END as CollectDatabase
	,COALESCE(t.[DotNetConnectionString],d.[DotNetConnectionString]) as ConnectionString
FROM (SELECT * FROM TableOrDB WHERE [AttribName] = 'SpaceUsed_Collect_Table' AND [AttribValue] = 'TRUE') t
FULL OUTER JOIN (SELECT * FROM TableOrDB WHERE [AttribName] = 'SpaceUsed_Collect_Database' AND [AttribValue] = 'TRUE') d
ON t.[ServerName] = d.[ServerName]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[General_GetFullFileNameID]'
GO

CREATE PROCEDURE [hist].[General_GetFullFileNameID] (
	@Path					VARCHAR(900)
	,@FileName				VARCHAR(900)
	,@FullFileNameID		INT OUTPUT
)
AS

SET NOCOUNT ON

DECLARE
	@HistPathID				INT
	,@HistFileNameID		INT
	
EXEC [hist].[General_GetPathID] @Path, @HistPathID OUTPUT
EXEC [hist].[General_GetFileNameID] @FileName, @HistFileNameID OUTPUT

SELECT
	@FullFileNameID = ffn.[HistPathFileNameID]
FROM [hist].[General_FullFileName] ffn
WHERE ffn.[HistPathID] = @HistPathID
AND ffn.[HistFileNameID] = @HistFileNameID

IF @FullFileNameID IS NULL
BEGIN
	INSERT INTO [hist].[General_FullFileName] ([HistPathID],[HistFileNameID])
	VALUES (@HistPathID,@HistFileNameID)
	
	SET @FullFileNameID = SCOPE_IDENTITY()
END
	
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [hist].[SpaceUsed_FileSizes_InsertValue]'
GO

CREATE PROCEDURE [hist].[SpaceUsed_FileSizes_InsertValue] (
	@ServerName				VARCHAR(200)
	,@Path					VARCHAR(900)
	,@FileName				VARCHAR(900)
	,@FileAttributes		VARCHAR(5)
	,@FileSizeKB			BIGINT
)
AS

SET NOCOUNT ON

DECLARE
	@HistServerID			INT
	,@HistFullNameID		INT

EXEC [hist].[ServerInventory_GetServerID] @ServerName, @HistServerID OUTPUT
EXEC [hist].[General_GetFullFileNameID] @Path, @FileName, @HistFullNameID OUTPUT

IF @HistServerID IS NOT NULL AND @HistFullNameID IS NOT NULL
BEGIN
	INSERT INTO [hist].[SpaceUsed_FileSizes] ([HistServerID], [HistPathFileNameID], [FileSizeKB], [FileAttribute])
	VALUES (@HistServerID, @HistFullNameID, @FileSizeKB, @FileAttributes)

END

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__Backups___49E1233139CE5167] on [hist].[Backups_Devices]'
GO
ALTER TABLE [hist].[Backups_Devices] ADD CONSTRAINT [PK__Backups___49E1233139CE5167] PRIMARY KEY CLUSTERED  ([DeviceID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_SrvSettings] on [dbo].[Backups_SrvSettings]'
GO
CREATE CLUSTERED INDEX [IX_SrvSettings] ON [dbo].[Backups_SrvSettings] ([srvName]) ON [PRIMARY]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__Backups___F928CDC935099C4A] on [hist].[Backups_Types]'
GO
ALTER TABLE [hist].[Backups_Types] ADD CONSTRAINT [PK__Backups___F928CDC935099C4A] PRIMARY KEY CLUSTERED  ([BackupTypeID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__DTSStore__19093A2B76177A41] on [hist].[DTSStore_Categories]'
GO
ALTER TABLE [hist].[DTSStore_Categories] ADD CONSTRAINT [PK__DTSStore__19093A2B76177A41] PRIMARY KEY CLUSTERED  ([CategoryID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__DTSStore__A58A9FEB7152C524] on [hist].[DTSStore_Descriptions]'
GO
ALTER TABLE [hist].[DTSStore_Descriptions] ADD CONSTRAINT [PK__DTSStore__A58A9FEB7152C524] PRIMARY KEY CLUSTERED  ([DescriptionID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__DTSStore__819385987ADC2F5E] on [hist].[DTSStore_Owners]'
GO
ALTER TABLE [hist].[DTSStore_Owners] ADD CONSTRAINT [PK__DTSStore__819385987ADC2F5E] PRIMARY KEY CLUSTERED  ([OwnerID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__DTSStore__329D7CF76C8E1007] on [hist].[DTSStore_PackageNames]'
GO
ALTER TABLE [hist].[DTSStore_PackageNames] ADD CONSTRAINT [PK__DTSStore__329D7CF76C8E1007] PRIMARY KEY CLUSTERED  ([PackageNameID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__Jobs_SQL__38632B71208E6DA8] on [hist].[Jobs_SQL_Jobs]'
GO
ALTER TABLE [hist].[Jobs_SQL_Jobs] ADD CONSTRAINT [PK__Jobs_SQL__38632B71208E6DA8] PRIMARY KEY CLUSTERED  ([HistJobID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__Users_Us__1788CCAC438CC5CB] on [hist].[Users_UserNames]'
GO
ALTER TABLE [hist].[Users_UserNames] ADD CONSTRAINT [PK__Users_Us__1788CCAC438CC5CB] PRIMARY KEY CLUSTERED  ([UserID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_Backups_Devices] on [hist].[Backups_Devices]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Backups_Devices] ON [hist].[Backups_Devices] ([DeviceName]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_Backups_Types] on [hist].[Backups_Types]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Backups_Types] ON [hist].[Backups_Types] ([BackupType]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__ChangeTr__9A6192B0476843A7] on [hist].[ChangeTracking_SQL_ObjectIDs]'
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ObjectIDs] ADD CONSTRAINT [PK__ChangeTr__9A6192B0476843A7] PRIMARY KEY NONCLUSTERED  ([ObjectID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_ChangeTracking_SQL_ObjectIDs] on [hist].[ChangeTracking_SQL_ObjectIDs]'
GO
CREATE NONCLUSTERED INDEX [IX_ChangeTracking_SQL_ObjectIDs] ON [hist].[ChangeTracking_SQL_ObjectIDs] ([SchemaName], [ObjectName], [ObjectTypeID]) INCLUDE ([ObjectID]) WITH (FILLFACTOR=60) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_Categories_1] on [hist].[DTSStore_Categories]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Categories_1] ON [hist].[DTSStore_Categories] ([CategoryID_GUID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_Descriptions_1] on [hist].[DTSStore_Descriptions]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Descriptions_1] ON [hist].[DTSStore_Descriptions] ([Description]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_Owners_1] on [hist].[DTSStore_Owners]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Owners_1] ON [hist].[DTSStore_Owners] ([Owner], [Owner_sid]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_PackageNames_1] on [hist].[DTSStore_PackageNames]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_PackageNames_1] ON [hist].[DTSStore_PackageNames] ([PackageName], [PackageID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_sysjobs_ServerID_job_id] on [hist].[Jobs_SQL_Jobs]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_sysjobs_ServerID_job_id] ON [hist].[Jobs_SQL_Jobs] ([HistServerID], [job_id], [date_modified]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__ServerIn__C56AC887379037E3] on [hist].[ServerInventory_ServerIDs]'
GO
ALTER TABLE [hist].[ServerInventory_ServerIDs] ADD CONSTRAINT [PK__ServerIn__C56AC887379037E3] PRIMARY KEY NONCLUSTERED  ([ServerID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_ServerIDs_ServerName] on [hist].[ServerInventory_ServerIDs]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_ServerIDs_ServerName] ON [hist].[ServerInventory_ServerIDs] ([ServerName]) INCLUDE ([ServerID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__ServerIn__A2A2BAAB22AA2996] on [dbo].[ServerInventory_SQL_AttributeList]'
GO
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] ADD CONSTRAINT [PK__ServerIn__A2A2BAAB22AA2996] PRIMARY KEY NONCLUSTERED  ([UniqueID]) ON [PRIMARY]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_AttribID] on [dbo].[ServerInventory_SQL_AttributeList]'
GO
CREATE NONCLUSTERED INDEX [IX_AttribID] ON [dbo].[ServerInventory_SQL_AttributeList] ([AttribID]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_ServerID_AttribID] on [dbo].[ServerInventory_SQL_AttributeList]'
GO
CREATE NONCLUSTERED INDEX [IX_ServerID_AttribID] ON [dbo].[ServerInventory_SQL_AttributeList] ([ServerID], [AttribID]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_AttribName] on [dbo].[ServerInventory_SQL_AttributeMaster]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AttribName] ON [dbo].[ServerInventory_SQL_AttributeMaster] ([AttribName]) WITH (FILLFACTOR=100, PAD_INDEX=ON) ON [PRIMARY]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__ServerIn__C56AC8871DE57479] on [dbo].[ServerInventory_SQL_Master]'
GO
ALTER TABLE [dbo].[ServerInventory_SQL_Master] ADD CONSTRAINT [PK__ServerIn__C56AC8871DE57479] PRIMARY KEY NONCLUSTERED  ([ServerID]) ON [PRIMARY]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_DoNotAllowDuplicateServers] on [dbo].[ServerInventory_SQL_Master]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DoNotAllowDuplicateServers] ON [dbo].[ServerInventory_SQL_Master] ([ServerName], [InstanceName]) ON [PRIMARY]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UIX_UserNames_UserName] on [hist].[Users_UserNames]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_UserNames_UserName] ON [hist].[Users_UserNames] ([UserName]) INCLUDE ([UserID]) ON [History]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[DatabaseMaintenance_CheckDB_Errors]'
GO
ALTER TABLE [hist].[DatabaseMaintenance_CheckDB_Errors] ADD
CONSTRAINT [FK_CheckDB_Errors__HistServerID] FOREIGN KEY ([HistServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID]),
CONSTRAINT [FK_CheckDB_Errors__DatabaseID] FOREIGN KEY ([DatabaseID]) REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[DatabaseMaintenance_CheckDB_OK]'
GO
ALTER TABLE [hist].[DatabaseMaintenance_CheckDB_OK] ADD
CONSTRAINT [FK_CheckDB_OK__HistServerID] FOREIGN KEY ([HistServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID]),
CONSTRAINT [FK_CheckDB_OK__DatabaseID] FOREIGN KEY ([DatabaseID]) REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[General_FullFileName]'
GO
ALTER TABLE [hist].[General_FullFileName] ADD
CONSTRAINT [FK_FullFileName__HistFileNameID] FOREIGN KEY ([HistFileNameID]) REFERENCES [hist].[General_FileNames] ([HistFileNameID]) ON DELETE CASCADE,
CONSTRAINT [FK_FullFileName__HistPathID] FOREIGN KEY ([HistPathID]) REFERENCES [hist].[General_Paths] ([HistPathID]) ON DELETE CASCADE
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[SpaceUsed_FileSizes]'
GO
ALTER TABLE [hist].[SpaceUsed_FileSizes] ADD
CONSTRAINT [FK_FileSizes__HistPathFileNameID] FOREIGN KEY ([HistPathFileNameID]) REFERENCES [hist].[General_FullFileName] ([HistPathFileNameID]) ON DELETE CASCADE,
CONSTRAINT [FK_FileSizes__HistServerID] FOREIGN KEY ([HistServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[Backups_History]'
GO
ALTER TABLE [hist].[Backups_History] ADD
CONSTRAINT [FK_BUHist_LogicalDeviceID] FOREIGN KEY ([LogicalDeviceID]) REFERENCES [hist].[Backups_Devices] ([DeviceID]),
CONSTRAINT [FK_BUHist_PhysicalDeviceID] FOREIGN KEY ([PhysicalDeviceID]) REFERENCES [hist].[Backups_Devices] ([DeviceID]),
CONSTRAINT [FK_BUHist_BackupType] FOREIGN KEY ([BUTypeID]) REFERENCES [hist].[Backups_Types] ([BackupTypeID]),
CONSTRAINT [FK_BUHist_ServerID] FOREIGN KEY ([ServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID]),
CONSTRAINT [FK_BUHist_ServerID2] FOREIGN KEY ([MachineID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID]),
CONSTRAINT [FK_BUHist_UserID] FOREIGN KEY ([UserID]) REFERENCES [hist].[Users_UserNames] ([UserID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]'
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] ADD
CONSTRAINT [FK_ChangeTracking_SQL_ObjectIDs_ObjectID] FOREIGN KEY ([ObjectID]) REFERENCES [hist].[ChangeTracking_SQL_ObjectIDs] ([ObjectID]),
CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID2] FOREIGN KEY ([ServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[DTSStore_PackageStore]'
GO
ALTER TABLE [hist].[DTSStore_PackageStore] ADD
CONSTRAINT [FK_Catagories_CategoryID] FOREIGN KEY ([CategoryID]) REFERENCES [hist].[DTSStore_Categories] ([CategoryID]),
CONSTRAINT [FK_Descriptions_DescriptionID] FOREIGN KEY ([DescriptionID]) REFERENCES [hist].[DTSStore_Descriptions] ([DescriptionID]),
CONSTRAINT [FK_Owners_OwnerID] FOREIGN KEY ([OwnerID]) REFERENCES [hist].[DTSStore_Owners] ([OwnerID]),
CONSTRAINT [FK_PackageNames_PackageNameID] FOREIGN KEY ([PackageNameID]) REFERENCES [hist].[DTSStore_PackageNames] ([PackageNameID]),
CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID] FOREIGN KEY ([ServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[Jobs_SQL_JobHistory]'
GO
ALTER TABLE [hist].[Jobs_SQL_JobHistory] ADD
CONSTRAINT [FK_JobHistory_JobID] FOREIGN KEY ([HistJobID]) REFERENCES [hist].[Jobs_SQL_Jobs] ([HistJobID]),
CONSTRAINT [FK_JobHistory_HistServerID] FOREIGN KEY ([HistServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[Jobs_SQL_JobSteps]'
GO
ALTER TABLE [hist].[Jobs_SQL_JobSteps] ADD
CONSTRAINT [FK_sysjobsteps_JobID] FOREIGN KEY ([HistJobID]) REFERENCES [hist].[Jobs_SQL_Jobs] ([HistJobID]),
CONSTRAINT [FK_sysjobsteps_HistServerID] FOREIGN KEY ([HistServerIDForServerCol]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[ServerInventory_SQL_ServerDBTableIDs]'
GO
ALTER TABLE [hist].[ServerInventory_SQL_ServerDBTableIDs] ADD
CONSTRAINT [FK_SI_ServerIDs_ServerID] FOREIGN KEY ([ServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[SpaceUsed_DatabaseSizes]'
GO
ALTER TABLE [hist].[SpaceUsed_DatabaseSizes] ADD
CONSTRAINT [FK_SI_ServerIDs_ServerID_2] FOREIGN KEY ([ServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [hist].[Jobs_SQL_Jobs]'
GO
ALTER TABLE [hist].[Jobs_SQL_Jobs] ADD
CONSTRAINT [FK_SQL_sysjobs_ServerID] FOREIGN KEY ([HistServerID]) REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[NTPermissions_ServerExceptions]'
GO
ALTER TABLE [dbo].[NTPermissions_ServerExceptions] ADD
CONSTRAINT [FK__NTPermiss__Serve__5070F446] FOREIGN KEY ([ServerID]) REFERENCES [dbo].[ServerInventory_SQL_Master] ([ServerID]) ON DELETE CASCADE
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[Backups_Jobs]'
GO
ALTER TABLE [dbo].[Backups_Jobs] ADD
CONSTRAINT [FK_Master_ServerID] FOREIGN KEY ([ServerID]) REFERENCES [dbo].[ServerInventory_SQL_Master] ([ServerID]) ON DELETE CASCADE
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[ServerInventory_SQL_AttributeList]'
GO
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] ADD
CONSTRAINT [FK_SI_SQL_Master_ServerID] FOREIGN KEY ([ServerID]) REFERENCES [dbo].[ServerInventory_SQL_Master] ([ServerID]) ON DELETE CASCADE
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering extended properties'
GO
EXEC sp_updateextendedproperty N'Version', N'1.1.0', NULL, NULL, NULL, NULL, NULL, NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO
