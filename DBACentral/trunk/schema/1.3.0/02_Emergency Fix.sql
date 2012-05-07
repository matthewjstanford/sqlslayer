USE [DBACentral]

GO
/*******************************************************************************************************
**  Name:			[hist].[Backups_SaveBackupHistory]
**  Desc:			Adds a backup history into repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090728	Matt Stanford	Emergency change because of broken HistServerID
********************************************************************************************************/
ALTER PROCEDURE [hist].[Backups_SaveBackupHistory] (
	@ServerName				SYSNAME
	,@MachineName			SYSNAME
	,@DatabaseName			SYSNAME
	,@StartDate				SMALLDATETIME
	,@EndDate				SMALLDATETIME
	,@Size_Mbytes			INT
	,@BUType				CHAR(1)
	,@UserName				SYSNAME
	,@LogicalDevice			NVARCHAR(128)
	,@PhysicalDevice		NVARCHAR(260)
)
AS
SET NOCOUNT ON

DECLARE 
	@ServerID				INT
	,@MachineID				INT
	,@DatabaseID			INT
	,@BackupTypeID			INT
	,@LogicalID				INT
	,@PhysicalID			INT
	,@UserID				INT
	
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @ServerID OUTPUT
EXEC [hist].[ServerInventory_GetServerID] @MachineName, @MachineID OUTPUT
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @DatabaseName, @DatabaseID OUTPUT
EXEC [hist].[Backups_GetTypeID] @BUType, @BackupTypeID OUTPUT
EXEC [hist].[Backups_GetDeviceID] @LogicalDevice, @LogicalID OUTPUT
EXEC [hist].[Backups_GetDeviceID] @PhysicalDevice, @PhysicalID OUTPUT
EXEC [hist].[Users_GetUserID] @UserName, @UserID OUTPUT

IF NOT EXISTS (
	SELECT * 
	FROM [hist].[Backups_History] 
	WHERE [HistServerID] = @ServerID
	AND [DatabaseID] = @DatabaseID
	AND [BUTypeID] = @BackupTypeID
	AND [StartDate] = @StartDate
	)
BEGIN

	INSERT INTO [hist].[Backups_History] ([HistServerID], [MachineID], [DatabaseID], [StartDate], [EndDate], [Size_MBytes], [BUTypeID], [UserID], [LogicalDeviceID], [PhysicalDeviceID])
	VALUES (@ServerID,@MachineID,@DatabaseID,@StartDate,@EndDate,@Size_Mbytes,@BackupTypeID,@UserID,@LogicalID,@PhysicalID)

END

GO
/*******************************************************************************************************
**  Name:			[hist].[ChangeTracking_SQL_GetServerDBObjectActionIDs]
**  Desc:			Procedure to save object change into the repository
**  Auth:			Kathy Toth (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090728	Matt Stanford	Emergency change because of broken HistServerID
********************************************************************************************************/
ALTER PROCEDURE [hist].[ChangeTracking_SQL_GetServerDBObjectActionIDs] (
	@ServerName		SYSNAME
	,@DatabaseName	SYSNAME 
	,@SchemaName	SYSNAME
	,@ObjectName	SYSNAME
	,@RefType		NVARCHAR (128)
	,@ActionType	VARCHAR (255)
	,@DateModified	DATE
)
AS

DECLARE @DatabaseID INT
DECLARE @ServerID INT
DECLARE @ActionID INT
DECLARE @ObjectID INT
DECLARE @RecordID INT

-- Find the ServerID
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @ServerID OUTPUT

-- Find the DatabaseID
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @DatabaseName, @DatabaseID OUTPUT

--Find the ActionID
EXEC [hist].[ChangeTracking_SQL_GETActionID] @ActionType, @ActionID OUTPUT

--find the Objects and their types
EXEC [hist].[ChangeTracking_SQL_GetObjectIDs] @SchemaName, @ObjectName, @RefType, @ObjectID OUTPUT


--Find the DateModified -hmm not to sure how to handle this

-- Add the  combo if necessary
IF NOT EXISTS (SELECT [HistServerID], [DatabaseID], [ObjectID], [ActionID], [DateModified]
				FROM [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]
				WHERE [HistServerID] = @ServerID
				AND DatabaseID = @DatabaseID
				AND ObjectID = @ObjectID
				AND ActionID = @ActionID
				AND DateModified = @DateModified
				)
BEGIN
	INSERT INTO [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] ([HistServerID], [DatabaseID], [ObjectID], [ActionID], [DateModified], [DateCreated]) 
	VALUES (@ServerID, @DatabaseID, @ObjectID, @ActionID, @DateModified, GETDATE())
END

GO
/*******************************************************************************************************
**  Name:			[hist].[DTSStore_StorePackageData]
**  Desc:			Procedure to save DTS packages into the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090728	Matt Stanford	Emergency change because of broken HistServerID
********************************************************************************************************/
ALTER PROCEDURE [hist].[DTSStore_StorePackageData] (
	@SourceServer			SYSNAME
	,@name					SYSNAME
	,@id					UNIQUEIDENTIFIER
	,@versionid				UNIQUEIDENTIFIER
	,@description			NVARCHAR(1024)
	,@categoryid			UNIQUEIDENTIFIER
	,@createdate			DATETIME
	,@owner					SYSNAME
	,@packagedata			IMAGE
	,@owner_sid				VARBINARY(85)
	,@packagetype			INT
)
AS

DECLARE
	@CategoryID_INT			INT
	,@DescriptionID			INT
	,@OwnerID				INT
	,@PackageNameID			INT
	,@ServerID				INT
	
EXECUTE [hist].[DTSStore_GetCategoryID] @CategoryID, @CategoryID_INT OUTPUT
EXECUTE [hist].[DTSStore_GetDescriptionID] @Description, @DescriptionID OUTPUT
EXECUTE [hist].[DTSStore_GetOwnerID] @owner, @owner_sid, @OwnerID OUTPUT
EXECUTE [hist].[DTSStore_GetPackageNameID] @name, @id, @PackageNameID OUTPUT
EXECUTE [hist].[ServerInventory_GetServerID] @SourceServer, @ServerID OUTPUT

-- Now that all of the IDs have been collected, lets insert the data into 
-- the main table

IF NOT EXISTS (
	SELECT 
		[HistServerID]
		,[PackageNameID]
		,[VersionID] 
	FROM [hist].[DTSStore_PackageStore] 
	WHERE [HistServerID] = @ServerID
	AND [PackageNameID] = @PackageNameID
	AND [VersionID] = @versionid
	)
BEGIN
	INSERT INTO [hist].[DTSStore_PackageStore] ([HistServerID], PackageNameID, VersionID, DescriptionID, CategoryID, CreateDate, OwnerID, PackageData, PackageType)
	VALUES (@ServerID, @PackageNameID, @versionid, @DescriptionID, @CategoryID_INT, @createdate, @OwnerID, @packagedata, @packagetype)
END

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_GetServerDBTableID]
**  Desc:			Procedure to save table/server pairings into the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090728	Matt Stanford	Emergency change because of broken HistServerID
********************************************************************************************************/
ALTER PROCEDURE [hist].[ServerInventory_SQL_GetServerDBTableID] (
	@ServerName			VARCHAR(1000)
	,@DatabaseName		SYSNAME
	,@SchemaName		SYSNAME
	,@TableName			SYSNAME
	,@ServerDBTableID	INT OUTPUT
)
AS

DECLARE 
	@ServerID			INT
	,@DatabaseID		INT
	,@TableID			INT

-- Find the ServerID
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @ServerID OUTPUT

-- Find the DatabaseID
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @DatabaseName, @DatabaseID OUTPUT

-- Find the TableID
EXEC [hist].[ServerInventory_SQL_GetTableID] @TableName, @SchemaName, @TableID OUTPUT

-- Find the ServerDBTableID	
SELECT 
	@ServerDBTableID = ServerDBTableID
FROM
	[hist].[ServerInventory_SQL_ServerDBTableIDs] id
WHERE id.[HistServerID]	= @ServerID
AND	id.[DatabaseID]	= @DatabaseID
AND id.[TableID]	= @TableID

-- Add the server/db/schema/table combo if necessary
IF @ServerDBTableID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_ServerDBTableIDs] ([HistServerID], [DatabaseID], [TableID], [LastUpdated]) 
	VALUES (@ServerID, @DatabaseID, @TableID, GETDATE())
	
	SET @ServerDBTableID = SCOPE_IDENTITY()
END

GO
/*******************************************************************************************************
**  Name:			[hist].[SpaceUsed_DatabaseSizes_InsertValue]
**  Desc:			Adds a database size sampling into the repository
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			(unknown)
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**	20090706	Matt Stanford	Fully backwards-compatible change to add DataSizeUnusedMB and LogSizeUnusedMB
********************************************************************************************************/
ALTER PROCEDURE [hist].[SpaceUsed_DatabaseSizes_InsertValue] (
	@ServerName			VARCHAR(1000)
	,@DBName			SYSNAME
	,@DataSizeMB		BIGINT
	,@LogSizeMB			BIGINT
	,@DataSizeUnusedMB	BIGINT = NULL
	,@LogSizeUnusedMB	BIGINT = NULL
)
AS

DECLARE 
	@ServerID			INT
	,@DatabaseID		INT
	
-- Find the ServerID
EXEC [hist].[ServerInventory_GetServerID] @ServerName, @ServerID OUTPUT

-- Find the DatabaseID
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @DBName, @DatabaseID OUTPUT

-- Now that we've got that, just insert into our detail table
INSERT INTO [hist].[SpaceUsed_DatabaseSizes] ([HistServerID], [DatabaseID], [DataSizeMB], [LogSizeMB], [DataSizeUnusedMB], [LogSizeUnusedMB], [SampleDate])
VALUES (@ServerID, @DatabaseID, @DataSizeMB, @LogSizeMB, @DataSizeUnusedMB, @LogSizeUnusedMB, GETDATE())

GO