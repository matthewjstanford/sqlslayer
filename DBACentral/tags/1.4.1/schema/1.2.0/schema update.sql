USE [DBACentral]
GO

SET XACT_ABORT OFF

BEGIN TRANSACTION

IF EXISTS (
	SELECT * 
	FROM fn_listextendedproperty(default, default, default, default, default, default, default)
	WHERE LEFT(CAST([value] AS VARCHAR(50)),3) = '1.1'
	AND [name] = 'Version'
)
BEGIN
	PRINT 'Current Version is 1.1.x  Lets begin.'
END
ELSE
BEGIN
	RAISERROR('Current Version of DBACentral is not 1.1.x, this script will not update successfully',16,2) WITH LOG
END
	

-- Clean up if this is a re-run
-- SpaceUsed section
IF OBJECT_ID('[hist].[SpaceUsed_DatabaseSizes_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[SpaceUsed_DatabaseSizes_InsertValue]
IF OBJECT_ID('[hist].[SpaceUsed_DatabaseSizes_vw]','V') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_DatabaseSizes_vw]
IF OBJECT_ID('[hist].[SpaceUsed_DatabaseSizes_Delta_vw]','V') IS NOT NULL
	DROP VIEW [hist].[SpaceUsed_DatabaseSizes_Delta_vw]

-- ServerInventory Section
IF OBJECT_ID('[dbo].[ServerInventory_SQL_InsertServer]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[ServerInventory_SQL_InsertServer]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_SaveAttributes]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[ServerInventory_SQL_SaveAttributes]
IF EXISTS (SELECT * FROM sys.types WHERE name = 'AttributeListType')
	DROP TYPE [dbo].[AttributeListType]

-- Owner Section
IF OBJECT_ID('[dbo].[ServerInventory_ApplicationOwners_Xref]','U') IS NOT NULL
	DROP TABLE [dbo].[ServerInventory_ApplicationOwners_Xref] 
IF OBJECT_ID('[dbo].[ServerInventory_ServerOwners_Xref]','U') IS NOT NULL
	DROP TABLE [dbo].[ServerInventory_ServerOwners_Xref]
IF OBJECT_ID('[dbo].[ServerInventory_ServerApplications_Xref]','U') IS NOT NULL
	DROP TABLE [dbo].[ServerInventory_ServerApplications_Xref]
IF OBJECT_ID('[dbo].[ServerInventory_DatabaseOwners_Xref]','U') IS NOT NULL
	DROP TABLE [dbo].[ServerInventory_DatabaseOwners_Xref]
IF OBJECT_ID('[dbo].[ServerInventory_Applications]','U') IS NOT NULL
	DROP TABLE [dbo].[ServerInventory_Applications]
IF OBJECT_ID('[dbo].[ServerInventory_Owners]','U') IS NOT NULL
	DROP TABLE [dbo].[ServerInventory_Owners]

-- Cluster Section
IF OBJECT_ID('[dbo].[ServerInventory_SQL_InsertClusterNode]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[ServerInventory_SQL_InsertClusterNode]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_DeleteClusterNode]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[ServerInventory_SQL_DeleteClusterNode]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_ClusterNodes_vw]','V') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_SQL_ClusterNodes_vw]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_ClusterNodes]','U') IS NOT NULL
	DROP TABLE [dbo].[ServerInventory_SQL_ClusterNodes]

-- Configuration Section
IF OBJECT_ID('[hist].[ServerInventory_SQL_ConfigurationValues_vw]','V') IS NOT NULL
	DROP VIEW [hist].[ServerInventory_SQL_ConfigurationValues_vw]
IF OBJECT_ID('[hist].[ServerInventory_SQL_ConfigurationValues]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_ConfigurationValues]
IF OBJECT_ID('[ref].[ServerInventory_SQL_ConfigurationOptions]','U') IS NOT NULL
	DROP TABLE [ref].[ServerInventory_SQL_ConfigurationOptions]
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'ref')
	EXEC('DROP SCHEMA [ref]')

PRINT('Creating new Configuration Settings section')
-- Create the new objects
EXEC('CREATE SCHEMA [ref]')
GO
---------------------------
-- New Configuration Section
GO
CREATE TABLE [ref].[ServerInventory_SQL_ConfigurationOptions]
(
	[RefConfigOptionID]					INT IDENTITY
	,[configuration_id]					INT
	,[name]								NVARCHAR(35)
	,[minimum]							SQL_VARIANT
	,[maximum]							SQL_VARIANT
	,[description]						NVARCHAR(255)
	,[is_dynamic]						BIT
	,[is_advanced]						BIT
	,CONSTRAINT PK__RefConfigOptionID PRIMARY KEY CLUSTERED
	(
		[RefConfigOptionID]
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [hist].[ServerInventory_SQL_ConfigurationValues]
(
	[HistConfigValueID]					INT IDENTITY
	,[RefConfigOptionID]				INT CONSTRAINT FK__SQL_ConfigValues__ConfigOptions FOREIGN KEY REFERENCES [ref].[ServerInventory_SQL_ConfigurationOptions] ([RefConfigOptionID])
	,[HistServerID]						INT CONSTRAINT FK__SQL_ConfigValues__HistServerID FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
	,[value]							SQL_VARIANT NOT NULL
	,[value_in_use]						SQL_VARIANT NOT NULL
	,[DateCreated]						DATETIME CONSTRAINT DF__SQL_ConfigValues__DateCreated DEFAULT GETDATE()
	,CONSTRAINT PK__SQL_ConfigValues__HistConfigValueID PRIMARY KEY CLUSTERED
	(
		[HistConfigValueID]
	) ON [History]
) ON [History]

GO

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
	ON v.[HistServerID] = s.[ServerID]
INNER JOIN [ref].[ServerInventory_SQL_ConfigurationOptions] o
	ON v.[RefConfigOptionID] = o.[RefConfigOptionID]
GO

---------------------------
-- New Cluster Section
PRINT('Creating new Cluster section')
GO

CREATE TABLE [dbo].[ServerInventory_SQL_ClusterNodes]
(
	[NodeID]							INT IDENTITY
	,[ServerID]							INT CONSTRAINT [FK__SI_SQL_ClusterNodes__ServerID] FOREIGN KEY REFERENCES [dbo].[ServerInventory_SQL_Master] ([ServerID]) ON DELETE CASCADE
	,[HistServerID]						INT CONSTRAINT [FK__SI_SQL_ClusterNodes__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
	,[DateCreated]						DATETIME CONSTRAINT [DF__SI_SQL_ClusterNodes__DateCreated] DEFAULT GETDATE()
	,CONSTRAINT [PK__SI_SQL_ClusterNodes__NodeID] PRIMARY KEY CLUSTERED 
	(
		[NodeID] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

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
	ON c.[HistServerID] = s.[ServerID]
	
GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_SQL_InsertClusterNode]
**  Desc:			Procedure to manage inserting data into the ClusterNodes table
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009.06.25
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [dbo].[ServerInventory_SQL_InsertClusterNode] (
	@ServerName						VARCHAR(100)
	,@InstanceName					VARCHAR(100) = NULL
	,@NodeName						VARCHAR(200)
)
AS

SET NOCOUNT ON

DECLARE
	@ServerID		INT
	,@HistServerID	INT

-- Lookup the master server id
SELECT
	@ServerID = [ServerID]
FROM [dbo].[ServerInventory_SQL_Master]
WHERE [ServerName] = @ServerName
AND ISNULL([InstanceName],'') = ISNULL(@InstanceName,'')

-- Lookup the hist server id for the node name
EXEC [hist].[ServerInventory_GetServerID] @NodeName, @HistServerID OUTPUT

IF @ServerID IS NOT NULL AND @HistServerID IS NOT NULL
BEGIN
	-- Try to insert
	IF NOT EXISTS (SELECT * FROM [dbo].[ServerInventory_SQL_ClusterNodes] WHERE [ServerID] = @ServerID AND [HistServerID] = @HistServerID)
		INSERT INTO [dbo].[ServerInventory_SQL_ClusterNodes] ([ServerID],[HistServerID])
		VALUES(@ServerID,@HistServerID)
	ELSE
		PRINT('Node already attached to this instance')
END 
ELSE
	PRINT('Server Not Found')

GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_SQL_DeleteClusterNode]
**  Desc:			Procedure to manage deleting data from the ClusterNodes table
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009.06.25
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [dbo].[ServerInventory_SQL_DeleteClusterNode] (
	@ServerName						VARCHAR(100)
	,@InstanceName					VARCHAR(100) = NULL
	,@NodeName						VARCHAR(200)
)
AS

SET NOCOUNT ON

DECLARE
	@ServerID		INT
	,@HistServerID	INT

-- Lookup the master server id
SELECT
	@ServerID = [ServerID]
FROM [dbo].[ServerInventory_SQL_Master]
WHERE [ServerName] = @ServerName
AND ISNULL([InstanceName],'') = ISNULL(@InstanceName,'')

-- Lookup the hist server id for the node name
EXEC [hist].[ServerInventory_GetServerID] @NodeName, @HistServerID OUTPUT

IF @ServerID IS NOT NULL AND @HistServerID IS NOT NULL
BEGIN
	-- Try to delete
	DELETE FROM [dbo].[ServerInventory_SQL_ClusterNodes] WHERE [ServerID] = @ServerID AND [HistServerID] = @HistServerID
END 
ELSE
	PRINT('Server Not Found')

GO

---------------------------
-- New Owner Section
PRINT('Creating new Owner section')

-- Create server owners table 
CREATE TABLE [dbo].[ServerInventory_Owners]
(
	[OwnerID]						INT IDENTITY(1,1) NOT NULL
	,[OwnerName]					VARCHAR(256) NULL
	,CONSTRAINT [PK__SI_Owners] PRIMARY KEY CLUSTERED 
	(
		[OwnerID] ASC
	) ON [Primary]
) ON [PRIMARY]

-- Create applications table
CREATE TABLE [dbo].[ServerInventory_Applications]
(
	[ApplicationID]					INT IDENTITY(1,1) NOT NULL
	,[ApplicationName]				VARCHAR(256) NULL
	,CONSTRAINT [PK__SI_Applications] PRIMARY KEY CLUSTERED 
	(
		[ApplicationID] ASC
	) ON [Primary]
) ON [Primary]

-- Create application owner xref table
CREATE TABLE [dbo].[ServerInventory_ApplicationOwners_Xref] 
(
	[ApplicationID]					INT CONSTRAINT [FK__SI_Applications__AppIDs] FOREIGN KEY REFERENCES [dbo].[ServerInventory_Applications]([ApplicationID])
	,[OwnerID]						INT CONSTRAINT [FK__SI_Owners__OwnerIDs] FOREIGN KEY REFERENCES [dbo].[ServerInventory_Owners]([OwnerID])
) ON [Primary]
CREATE UNIQUE CLUSTERED INDEX [CUIX__SI_ApplicationOwnerXref__ApplicationID__OwnerID] 
ON [dbo].[ServerInventory_ApplicationOwners_Xref] ([ApplicationID], [OwnerID]) ON [Primary]

-- Create server owner xref table
CREATE TABLE [dbo].[ServerInventory_ServerOwners_Xref] 
(
	[ServerID]						INT CONSTRAINT [FK__SI_SrvOwnerXref__ServerID] FOREIGN KEY REFERENCES [dbo].[ServerInventory_SQL_Master]([ServerID])
	,[OwnerID]						INT CONSTRAINT [FK__SI_SrvOwnerXref__OwnerIDs] FOREIGN KEY REFERENCES [dbo].[ServerInventory_Owners]([OwnerID])
) ON [Primary]
CREATE UNIQUE CLUSTERED INDEX [CUIX__SI_SrvOwnerXref__ServerID__OwnerID]
ON [dbo].[ServerInventory_ServerOwners_Xref] ([ServerID], [OwnerID]) ON [Primary]

-- Create server applications xref table
CREATE TABLE [dbo].[ServerInventory_ServerApplications_Xref]
(
	[ServerID]						INT CONSTRAINT [FK__SI_SrvAppXref__ServerID] FOREIGN KEY REFERENCES [dbo].[ServerInventory_SQL_Master]([ServerID])
	,[ApplicationID]				INT CONSTRAINT [FK__SI_SrvAppXref__AppIDs] FOREIGN KEY REFERENCES [dbo].[ServerInventory_Applications]([ApplicationID])
) ON [Primary]
CREATE UNIQUE CLUSTERED INDEX [CUIX__SrvAppXref__ServerID__ApplicationID]
ON [dbo].[ServerInventory_ServerApplications_Xref] ([ServerID], [ApplicationID]) ON [Primary]

-- Create database owner xref table
CREATE TABLE [dbo].[ServerInventory_DatabaseOwners_Xref] 
(
	[ServerID]						INT CONSTRAINT [FK_SI_SQLMaster_ServerID] FOREIGN KEY REFERENCES [dbo].[ServerInventory_SQL_Master]([ServerID])
	,[DatabaseID]					INT CONSTRAINT [FK_SI_DatabaseIDs_DatabaseID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs]([DatabaseID])
	,[OwnerID]						INT CONSTRAINT [FK_SI_Owners_OwnerIDs3] FOREIGN KEY REFERENCES [dbo].[ServerInventory_Owners]([OwnerID])
) ON [Primary]
CREATE UNIQUE CLUSTERED INDEX [CUIX__DBOwnerXref__ServerID__DatabaseID]
ON [dbo].[ServerInventory_DatabaseOwners_Xref] ([ServerID], [DatabaseID], [OwnerID]) ON [Primary]

---- Add description to databaseIDs
--ALTER TABLE hist.[ServerInventory_SQL_DatabaseIDs] ADD
--	[Description]	varchar(256) NULL
--GO

CREATE TYPE [dbo].[AttributeListType]
AS TABLE (
	AttributeName					VARCHAR(100)
	,AttributeValue					NVARCHAR(1000)
)

GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_SQL_SaveAttributes]
**  Desc:			Procedure to manage inserting data into the Attributes table
					Contains a cursor... but it should only run when servers are added to the master table
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009.06.25
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [dbo].[ServerInventory_SQL_SaveAttributes] (
	@ServerID						INT
	,@AttributesToAdd				[dbo].[AttributeListType] READONLY
)
AS

DECLARE 
	@AttribName						VARCHAR(100)
	,@AttribValue					NVARCHAR(1000)

DECLARE #savAtt CURSOR LOCAL STATIC FOR
SELECT
	AttributeName
	,AttributeValue
FROM @AttributesToAdd

OPEN #savAtt

FETCH NEXT FROM #savAtt INTO @AttribName, @AttribValue
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC [dbo].[ServerInventory_SQL_SaveAttribute] @ServerID, @AttribName, @AttribValue
	FETCH NEXT FROM #savAtt INTO @AttribName, @AttribValue
END

CLOSE #savAtt
DEALLOCATE #savAtt

GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_SQL_InsertServer]
**  Desc:			Adds a new instance to the SQL_Master table
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2009.06.25
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [dbo].[ServerInventory_SQL_InsertServer] (
	@ServerName						VARCHAR(100)
	,@InstanceName					VARCHAR(100) = NULL
	,@PortNumber					INT = NULL
	,@Description					NVARCHAR(MAX)
	,@SQLVersion					INT
	,@Enabled						BIT = 1
	,@EnvrionmentName				VARCHAR(100)
	,@EditionName					VARCHAR(100)
	,@AttributesToAdd				[dbo].[AttributeListType] READONLY
	,@ServerID						INT OUTPUT
)

AS

SET NOCOUNT ON

DECLARE
	@EnvironmentID					INT
	,@EditionID						INT

-- Lookup the Environment ID
SELECT
	@EnvironmentID = [EnvironmentID]
FROM [dbo].[ServerInventory_Environments]
WHERE [EnvironmentName] = @EnvrionmentName

IF @EnvironmentID IS NULL
BEGIN
	PRINT('Environment is not recognized')
	RETURN 255
END

-- Lookup the Edition ID
SELECT
	@EditionID = [EditionID]
FROM [dbo].[ServerInventory_SQL_Editions]
WHERE [EditionName] = @EditionName

IF @EditionID IS NULL
BEGIN
	PRINT('Edition is not recognized')
	RETURN 255
END

-- Make sure there isn't already a server like this
IF NOT EXISTS (
	SELECT * 
	FROM [dbo].[ServerInventory_SQL_Master] 
	WHERE [ServerName] = @ServerName 
	AND ISNULL([InstanceName],'') = ISNULL(@InstanceName,'')
	AND ISNULL([PortNumber],0) = ISNULL(@PortNumber,0)
	AND [EditionID] = @EditionID
	AND [EnvironmentID] = @EnvironmentID
	)
BEGIN
	-- All clear, do the insert
	INSERT INTO [dbo].[ServerInventory_SQL_Master] ([ServerName], [InstanceName], [PortNumber], [Description], [SQLVersion], [Enabled], [EnvironmentID], [EditionID], [UseCredential])
	VALUES(@ServerName,@InstanceName,@PortNumber,@Description,@SQLVersion,@Enabled,@EnvironmentID,@EditionID,0)
	
	SET @ServerID = SCOPE_IDENTITY()
	
	EXEC [dbo].[ServerInventory_SQL_SaveAttributes] @ServerID, @AttributesToAdd

END
ELSE
	PRINT('Server already in the table')
GO

---------------------------
-- New Owner Section
PRINT('Modifying the SpaceUsed section')

GO

ALTER TABLE [hist].[SpaceUsed_DatabaseSizes] 
ADD [DataSizeUnusedMB] BIGINT NULL

ALTER TABLE [hist].[SpaceUsed_DatabaseSizes] 
ADD [LogSizeUnusedMB] BIGINT NULL

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
CREATE PROCEDURE [hist].[SpaceUsed_DatabaseSizes_InsertValue] (
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
INSERT INTO [hist].[SpaceUsed_DatabaseSizes] ([ServerID], [DatabaseID], [DataSizeMB], [LogSizeMB], [DataSizeUnusedMB], [LogSizeUnusedMB], [SampleDate])
VALUES (@ServerID, @DatabaseID, @DataSizeMB, @LogSizeMB, @DataSizeUnusedMB, @LogSizeUnusedMB, GETDATE())

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
********************************************************************************************************/
CREATE VIEW [hist].[SpaceUsed_DatabaseSizes_Delta_vw]
AS
WITH DBData AS (
	SELECT 
		[ServerID]
		,[DatabaseID]
		,[DataSizeMB]
		,[LogSizeMB]
		,[DataSizeUnusedMB]
		,[LogSizeUnusedMB]
		,[SampleDate]
		,ROW_NUMBER() OVER (PARTITION BY [ServerID], [DatabaseID] ORDER BY SampleDate) as rownum
	FROM [hist].[SpaceUsed_DatabaseSizes]
)
SELECT 
	s.[ServerName]
	,d.[DBName]
	,currow.[DataSizeMB]
	,currow.[DataSizeMB] - prevrow.[DataSizeMB]					AS [DataSizeMBIncrease]
	,currow.[LogSizeMB]
	,currow.[LogSizeMB] - prevrow.[LogSizeMB]					AS [LogSizeMBIncrease]
	,currow.[DataSizeUnusedMB]
	,currow.[DataSizeUnusedMB] - prevrow.[DataSizeUnusedMB]		AS [DataSizeUnusedMBIncrease]
	,currow.[LogSizeUnusedMB]
	,currow.[LogSizeUnusedMB] - prevrow.[LogSizeUnusedMB]		AS [LogSizeUnusedMBIncrease]
	,currow.[SampleDate]
FROM DBData currow
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[ServerID] = currow.[ServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = currow.[DatabaseID]
LEFT OUTER JOIN DBData prevrow
	ON prevrow.ServerID = currow.ServerID
	AND prevrow.DatabaseID = currow.DatabaseID
	AND currow.rownum = prevrow.rownum + 1

GO
/*******************************************************************************************************
**  Name:			[hist].[SpaceUsed_DatabaseSizes_vw]
**  Desc:			View to pull back the database sizes from the repository
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
	ON s.[ServerID] = det.[ServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = det.[DatabaseID]

GO

PRINT N'Stamping database version 1.2.0'
EXEC sys.sp_updateextendedproperty @name=N'Version', @value=N'1.2.0'

--Had_Error:

--ROLLBACK
COMMIT TRANSACTION