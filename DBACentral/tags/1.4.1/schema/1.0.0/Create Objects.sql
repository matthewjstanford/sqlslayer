USE [DBACentral]
GO
/****** Object:  Schema [hist]    Script Date: 03/04/2009 13:48:47 ******/
CREATE SCHEMA [hist] AUTHORIZATION [dbo]
GO
/****** Object:  Table [hist].[Users_UserNames]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[Users_UserNames](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [sysname] NOT NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_UserNames_UserName] ON [hist].[Users_UserNames] 
(
	[UserName] ASC
)
INCLUDE ( [UserID]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [hist].[ServerInventory_SQL_ObjectIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[ServerInventory_SQL_ObjectIDs](
	[ObjectID] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NOT NULL,
	[SQLType] [nvarchar](128) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ObjectID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
/****** Object:  Table [dbo].[ServerInventory_Environments]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerInventory_Environments](
	[EnvironmentID] [tinyint] IDENTITY(1,1) NOT NULL,
	[EnvironmentName] [varchar](100) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[EnvironmentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerInventory_SQL_ServerCredentials]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerInventory_SQL_ServerCredentials](
	[CredentialID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](100) NULL,
	[Password] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[CredentialID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [hist].[ServerInventory_SQL_TableIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[ServerInventory_SQL_TableIDs](
	[TableID] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[TableID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
/****** Object:  Table [dbo].[Backups_BackupAgents]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Backups_BackupAgents](
	[BackupAgentID] [int] IDENTITY(1,1) NOT NULL,
	[BackupAgentKey] [varchar](10) NULL,
	[Description] [varchar](100) NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BackupAgentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[Backups_Devices]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[Backups_Devices](
	[DeviceID] [int] IDENTITY(1,1) NOT NULL,
	[DeviceName] [nvarchar](260) NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DeviceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Backups_Devices] ON [hist].[Backups_Devices] 
(
	[DeviceName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [dbo].[Backups_BackupTypes]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Backups_BackupTypes](
	[BackupTypeID] [int] IDENTITY(1,1) NOT NULL,
	[BackupTypeKey] [varchar](10) NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BackupTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[Backups_BackupJobHistory]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [hist].[Backups_BackupJobHistory](
	[JobName] [sysname] NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[StartTime] [smalldatetime] NOT NULL,
	[FinishTime] [smalldatetime] NOT NULL,
	[nbrDBs] [int] NOT NULL,
	[sizeDBs] [bigint] NULL,
	[jobOutcome] [varchar](20) NULL,
	[buLocation] [varchar](255) NULL,
	[sqlbuSize] [int] NULL,
	[Schedule] [varchar](255) NULL,
	[DateCreated] [smalldatetime] NULL
) ON [History]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[Backups_Types]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [hist].[Backups_Types](
	[BackupTypeID] [int] IDENTITY(1,1) NOT NULL,
	[BackupType] [char](1) NULL,
	[BackupTypeDesc] [varchar](30) NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BackupTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Backups_Types] ON [hist].[Backups_Types] 
(
	[BackupType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [dbo].[Backups_SrvSettings]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Backups_SrvSettings](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[jobName] [varchar](50) NULL,
	[srvName] [varchar](50) NULL,
	[targetSrv] [varchar](50) NULL,
	[targetShare] [varchar](50) NULL,
	[dbRecord] [bit] NULL,
	[buExceptions] [bit] NULL,
	[buAgent] [varchar](20) NULL,
	[alertLevel] [int] NULL,
	[jobEnabled] [bit] NULL,
	[buType] [varchar](5) NULL,
	[loggingLevel] [int] NULL,
	[compressLevel] [int] NULL,
	[buTHreads] [int] NULL,
	[buStart] [varchar](255) NULL,
	[buTime] [varchar](100) NULL,
	[buDuration] [int] NULL,
	[nagHost] [varchar](50) NULL,
	[nagSvc] [varchar](50) NULL,
	[checkFile1] [varchar](255) NULL,
	[checkFile2] [varchar](255) NULL,
	[runJob1] [varchar](255) NULL,
	[runJob2] [varchar](255) NULL,
	[runEXE] [varchar](255) NULL,
	[lsPath] [varchar](255) NULL,
	[sqlVersion] [varchar](10) NULL,
	[lsVersion] [varchar](10) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE CLUSTERED INDEX [IX_SrvSettings] ON [dbo].[Backups_SrvSettings] 
(
	[srvName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [hist].[ChangeTracking_SQL_ActionIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [hist].[ChangeTracking_SQL_ActionIDs](
	[ActionID] [int] IDENTITY(1,1) NOT NULL,
	[ActionType] [varchar](255) NULL,
 CONSTRAINT [PK_ChangeTracking_SQL_ActionIDs] PRIMARY KEY CLUSTERED 
(
	[ActionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[DTSStore_Descriptions]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[DTSStore_Descriptions](
	[DescriptionID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DescriptionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Descriptions_1] ON [hist].[DTSStore_Descriptions] 
(
	[Description] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [hist].[DTSStore_Categories]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[DTSStore_Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID_GUID] [uniqueidentifier] NOT NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Categories_1] ON [hist].[DTSStore_Categories] 
(
	[CategoryID_GUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [hist].[ChangeTracking_SQL_ObjectTypeIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [hist].[ChangeTracking_SQL_ObjectTypeIDs](
	[ObjectTypeId] [int] IDENTITY(1,1) NOT NULL,
	[SQLType] [nvarchar](128) NULL,
	[RefType] [nvarchar](128) NULL,
	[SqlDesc] [varchar](50) NULL,
 CONSTRAINT [PK_ChangeTracking_SQL_ObjectTypeIDs] PRIMARY KEY CLUSTERED 
(
	[ObjectTypeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[DTSStore_PackageNames]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[DTSStore_PackageNames](
	[PackageNameID] [int] IDENTITY(1,1) NOT NULL,
	[PackageName] [sysname] NOT NULL,
	[PackageID] [uniqueidentifier] NOT NULL,
	[datecreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[PackageNameID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_PackageNames_1] ON [hist].[DTSStore_PackageNames] 
(
	[PackageName] ASC,
	[PackageID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [hist].[DTSStore_Owners]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [hist].[DTSStore_Owners](
	[OwnerID] [int] IDENTITY(1,1) NOT NULL,
	[Owner] [sysname] NOT NULL,
	[Owner_sid] [varbinary](85) NOT NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[OwnerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_Owners_1] ON [hist].[DTSStore_Owners] 
(
	[Owner] ASC,
	[Owner_sid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [dbo].[ServerInventory_SQL_Editions]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerInventory_SQL_Editions](
	[EditionID] [smallint] IDENTITY(1,1) NOT NULL,
	[EditionName] [varchar](100) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[EditionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[ServerInventory_SQL_DatabaseIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[ServerInventory_SQL_DatabaseIDs](
	[DatabaseID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [sysname] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[DatabaseID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_DatabaseIDs_DatabaseName] ON [hist].[ServerInventory_SQL_DatabaseIDs] 
(
	[DBName] ASC
)
INCLUDE ( [DatabaseID]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  Table [dbo].[ServerInventory_SQL_BuildLevelDesc]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerInventory_SQL_BuildLevelDesc](
	[ProductVersion] [varchar](100) NOT NULL,
	[SQLVersion] [smallint] NOT NULL,
	[Build] [int] NOT NULL,
	[ProductLevel] [nvarchar](128) NOT NULL,
	[ServicePack] [tinyint] NOT NULL,
	[CumulativeUpdate] [tinyint] NOT NULL,
	[Description] [varchar](4000) NULL,
	[ReleaseDate] [smalldatetime] NULL,
	[KBArticle] [char](6) NULL,
	[Link] [varchar](500) NULL,
 CONSTRAINT [PK_ProductVersion] PRIMARY KEY CLUSTERED 
(
	[ProductVersion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerInventory_SQL_AttributeMaster]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerInventory_SQL_AttributeMaster](
	[AttribID] [int] IDENTITY(1,1) NOT NULL,
	[AttribName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_AttributeID] PRIMARY KEY CLUSTERED 
(
	[AttribID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AttribName] ON [dbo].[ServerInventory_SQL_AttributeMaster] 
(
	[AttribName] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NTPermissions_PermissionSQLStatements]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NTPermissions_PermissionSQLStatements](
	[StatementID] [int] IDENTITY(1,1) NOT NULL,
	[SQLToExecute] [nvarchar](max) NULL,
	[Description] [varchar](100) NULL,
	[CompatVersionStart] [int] NULL,
	[CompatVersionEnd] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[StatementID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[ServerInventory_ServerIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [hist].[ServerInventory_ServerIDs](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](200) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_ServerIDs_ServerName] ON [hist].[ServerInventory_ServerIDs] 
(
	[ServerName] ASC
)
INCLUDE ( [ServerID]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
GO
/****** Object:  StoredProcedure [hist].[ServerInventory_GetServerID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[ServerInventory_GetServerID] (
	@ServerName			VARCHAR(1000)
	,@ServerID			INT OUTPUT
)
AS

-- Find the ServerID
SELECT 
	@ServerID = [ServerID]
FROM 
	[hist].[ServerInventory_ServerIDs] id
WHERE id.[ServerName] = @ServerName

IF @ServerID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_ServerIDs] (ServerName) 
	VALUES (@ServerName)
	
	SET @ServerID = SCOPE_IDENTITY()
END
GO
/****** Object:  Table [dbo].[NTPermissions_EnvironmentExceptions]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NTPermissions_EnvironmentExceptions](
	[EnvironmentID] [tinyint] NULL,
	[StatementID] [int] NULL,
	[RunInAdditionToDefault] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [hist].[DTSStore_PackageStore]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[DTSStore_PackageStore](
	[ServerID] [int] NOT NULL,
	[PackageNameID] [int] NOT NULL,
	[VersionID] [uniqueidentifier] NOT NULL,
	[DescriptionID] [int] NULL,
	[CategoryID] [int] NULL,
	[CreateDate] [datetime] NULL,
	[OwnerID] [int] NULL,
	[PackageData] [image] NULL,
	[PackageType] [int] NOT NULL,
	[DateCreated] [smalldatetime] NULL,
 CONSTRAINT [PK_DTSStore_PackageStore] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[PackageNameID] ASC,
	[VersionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History] TEXTIMAGE_ON [History]
GO
/****** Object:  StoredProcedure [hist].[ChangeTracking_SQL_GETActionID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [hist].[ChangeTracking_SQL_GETActionID]    Script Date: 02/20/2009 16:41:20 ******/

CREATE PROCEDURE [hist].[ChangeTracking_SQL_GETActionID] (
	@ActionType		VARCHAR (255)
	,@ActionID			INT OUTPUT
)
AS

DECLARE @msg NVARCHAR (4000)

-- Find the ActionID
SELECT 
	@ActionID = ad.[ActionID]
FROM [hist].[ChangeTracking_SQL_ActionIDs]
	 ad
WHERE ad.[ActionType] = @Actiontype

IF @ActionID IS NULL
BEGIN
	SET @msg = 'This Action type "' + ISNULL (@ActionType,'NULL') + '" does not exist'
	Raiserror (@msg,15,255)
END
GO
/****** Object:  StoredProcedure [hist].[DTSStore_GetPackageNameID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[DTSStore_GetPackageNameID] (
	@PackageName			SYSNAME
	,@PackageID				UNIQUEIDENTIFIER
	,@PackageNameID			INT OUTPUT
)
AS

-- Find the PackageNameID
SELECT 
	@PackageNameID = id.[PackageNameID]
FROM 
	[hist].[DTSStore_PackageNames] id
WHERE id.[PackageName] = @PackageName
AND id.[PackageID] = @PackageID

IF @PackageNameID IS NULL
BEGIN
	INSERT INTO [hist].[DTSStore_PackageNames] ([PackageName],[PackageID])
	VALUES (@PackageName,@PackageID)
	
	SET @PackageNameID = SCOPE_IDENTITY()
END
GO
/****** Object:  StoredProcedure [hist].[DTSStore_GetOwnerID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[DTSStore_GetOwnerID] (
	@Owner					SYSNAME
	,@Owner_SID				VARBINARY(85)
	,@OwnerID				INT OUTPUT
)
AS

-- Find the OwnerID
SELECT
	@OwnerID = id.[OwnerID]
FROM [hist].[DTSStore_Owners] id
WHERE id.[Owner] = @Owner
AND id.[Owner_sid] = @Owner_SID

IF @OwnerID IS NULL
BEGIN
	INSERT INTO [hist].[DTSStore_Owners] ([Owner],[Owner_sid])
	VALUES (@Owner,@Owner_SID)
	
	SET @OwnerID = SCOPE_IDENTITY()
END
GO
/****** Object:  StoredProcedure [hist].[DTSStore_GetDescriptionID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[DTSStore_GetDescriptionID] (
	@Description			NVARCHAR(1024)
	,@DescriptionID			INT OUTPUT
)
AS

-- Find the DescriptionID
SELECT
	@DescriptionID = id.[DescriptionID]
FROM [hist].[DTSStore_Descriptions] id
WHERE id.[Description] = @Description

IF @DescriptionID IS NULL
BEGIN
	INSERT INTO [hist].[DTSStore_Descriptions] ([Description])
	VALUES (@Description)
	
	SET @DescriptionID = SCOPE_IDENTITY()
END
GO
/****** Object:  StoredProcedure [hist].[DTSStore_GetCategoryID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[DTSStore_GetCategoryID] (
	@CategoryID_GUID		UNIQUEIDENTIFIER
	,@CategoryID			INT OUTPUT
)
AS

-- Find the CategoryID
SELECT 
	@CategoryID = id.[CategoryID]
FROM 
	[hist].[DTSStore_Categories] id
WHERE id.[CategoryID_GUID] = @CategoryID_GUID

IF @CategoryID IS NULL
BEGIN
	INSERT INTO [hist].[DTSStore_Categories] ([CategoryID_GUID])
	VALUES (@CategoryID_GUID)
	
	SET @CategoryID = SCOPE_IDENTITY()
END
GO
/****** Object:  Table [hist].[ChangeTracking_SQL_ObjectIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[ChangeTracking_SQL_ObjectIDs](
	[ObjectID] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NOT NULL,
	[ObjectTypeID] [int] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ObjectID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
CREATE NONCLUSTERED INDEX [IX_ChangeTracking_SQL_ObjectIDs] ON [hist].[ChangeTracking_SQL_ObjectIDs] 
(
	[SchemaName] ASC,
	[ObjectName] ASC,
	[ObjectTypeID] ASC
)
INCLUDE ( [ObjectID]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 60) ON [History]
GO
/****** Object:  StoredProcedure [hist].[ChangeTracking_SQL_GETObjectTypeIDs]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[ChangeTracking_SQL_GETObjectTypeIDs] (
	@RefType		NVARCHAR (128)
	,@ObjectTypeID		INT OUTPUT
)
AS

DECLARE @MSG NVARCHAR (4000)

-- Find the ObjectID
SELECT 
	@ObjectTypeID = od.[ObjectTypeID]
FROM [hist].[ChangeTracking_SQL_ObjectTypeIDs]
	 od
WHERE od.[RefType] = @RefType

IF @ObjectTypeID IS NULL
BEGIN
	SET @MSG = 'This reference type "' + @RefType + '" do not exist in the ChangeTracking_SQL_ObjectTypeIDs table.'
	Raiserror (@MSG,15,255)
END
GO
/****** Object:  Table [dbo].[Backups_BackupCommands]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Backups_BackupCommands](
	[CommandID] [int] IDENTITY(1,1) NOT NULL,
	[BackupTypeID] [int] NULL,
	[BackupAgentID] [int] NULL,
	[Command] [varchar](1024) NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CommandID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [hist].[Backups_History]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[Backups_History](
	[ServerID] [int] NOT NULL,
	[MachineID] [int] NULL,
	[DatabaseID] [int] NOT NULL,
	[StartDate] [smalldatetime] NOT NULL,
	[EndDate] [smalldatetime] NULL,
	[Size_MBytes] [int] NULL,
	[BUTypeID] [int] NOT NULL,
	[LogicalDeviceID] [int] NULL,
	[PhysicalDeviceID] [int] NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_BUHist] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[DatabaseID] ASC,
	[BUTypeID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
/****** Object:  StoredProcedure [hist].[Backups_GetTypeID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[Backups_GetTypeID] (
	@BackupType				CHAR(1)
	,@BackupTypeID			INT OUTPUT
)
AS

SELECT
	@BackupTypeID = id.[BackupTypeID]
FROM [hist].[Backups_Types] id
WHERE id.[BackupType] = @BackupType

IF (@BackupTypeID IS NULL)
BEGIN
	INSERT INTO [hist].[Backups_Types] ([BackupType])
	VALUES (@BackupType)
	
	SET @BackupTypeID = SCOPE_IDENTITY()
END
GO
/****** Object:  StoredProcedure [hist].[Backups_GetDeviceID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[Backups_GetDeviceID] (
	@DeviceName				NVARCHAR(260)
	,@DeviceID				INT OUTPUT
)
AS

DECLARE 
	@Msg					NVARCHAR(4000)
	,@DeviceNameToInsert	NVARCHAR(260)

IF (@DeviceName IS NULL)
	SET @DeviceNameToInsert = 'NULL'
ELSE IF (@DeviceName LIKE 'Red Gate SQL Backup (%')
	SET @DeviceNameToInsert = 'Red Gate SQL Backup'
ELSE IF (@DeviceName LIKE 'SQLBACKUP_%')
	SET @DeviceNameToInsert = 'Red Gate SQL Backup'
ELSE
	SET @DeviceNameToInsert = @DeviceName

SELECT
	@DeviceID = id.[DeviceID]
FROM [hist].[Backups_Devices] id
WHERE id.[DeviceName] = @DeviceNameToInsert

IF (@DeviceID IS NULL)
BEGIN
	BEGIN TRY
		INSERT INTO [hist].[Backups_Devices] ([DeviceName])
		VALUES (@DeviceNameToInsert)
		
		SET @DeviceID = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		SET @Msg = 'Just tried to insert ' + @DeviceNameToInsert
		RAISERROR(@Msg,16,2)
	END CATCH
END
GO
/****** Object:  Table [hist].[ServerInventory_SQL_ServerDBTableIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[ServerInventory_SQL_ServerDBTableIDs](
	[ServerDBTableID] [int] IDENTITY(1,1) NOT NULL,
	[ServerID] [int] NULL,
	[DatabaseID] [int] NULL,
	[TableID] [int] NULL,
	[LastUpdated] [smalldatetime] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ServerDBTableID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [History]
) ON [History]
GO
/****** Object:  StoredProcedure [hist].[ServerInventory_SQL_GetDatabaseID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[ServerInventory_SQL_GetDatabaseID] (
	@DBName				SYSNAME
	,@DatabaseID		INT OUTPUT
)
AS

SELECT 
	@DatabaseID = [DatabaseID]
FROM 
	[hist].[ServerInventory_SQL_DatabaseIDs] id
WHERE id.DBName = @DBName

IF @DatabaseID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_DatabaseIDs] (DBName) 
	VALUES (@DBName)
	
	SET @DatabaseID = SCOPE_IDENTITY()
END
GO
/****** Object:  Table [dbo].[ServerInventory_SQL_Master]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerInventory_SQL_Master](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](100) NOT NULL,
	[InstanceName] [varchar](100) NULL,
	[PortNumber] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[SQLVersion] [int] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[EnvironmentID] [tinyint] NOT NULL,
	[EditionID] [smallint] NOT NULL,
	[UseCredential] [bit] NULL,
	[CredentialID] [int] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DoNotAllowDuplicateServers] ON [dbo].[ServerInventory_SQL_Master] 
(
	[ServerName] ASC,
	[InstanceName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [hist].[ServerInventory_SQL_GetTableID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[ServerInventory_SQL_GetTableID] (
	@TableName			SYSNAME
	,@SchemaName		SYSNAME
	,@TableID			INT OUTPUT
)
AS

SELECT 
	@TableID = TableID
FROM 
	[hist].[ServerInventory_SQL_TableIDs] id
WHERE id.[TableName] = @TableName
AND id.[SchemaName] = @SchemaName

IF @TableID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_TableIDs] ([TableName], [SchemaName]) 
	VALUES (@TableName,@SchemaName)
	
	SET @TableID = SCOPE_IDENTITY()
END
GO
/****** Object:  StoredProcedure [hist].[Users_GetUserID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[Users_GetUserID] (
	@UserName				SYSNAME
	,@UserID				INT OUTPUT
)
AS

SET NOCOUNT ON

SELECT
	@UserID = id.[UserID]
FROM [hist].[Users_UserNames] id
WHERE id.[UserName] = @UserName

IF (@UserID IS NULL)
BEGIN
	INSERT INTO [hist].[Users_UserNames] ([UserName])
	VALUES (@UserName)
	
	SET @UserID = SCOPE_IDENTITY()
END
GO
/****** Object:  Table [hist].[SpaceUsed_DatabaseSizes]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[SpaceUsed_DatabaseSizes](
	[ServerID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DataSizeMB] [bigint] NULL,
	[LogSizeMB] [bigint] NULL,
	[SampleDate] [smalldatetime] NULL
) ON [History]
GO
/****** Object:  Table [hist].[SpaceUsed_TableSizes]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[SpaceUsed_TableSizes](
	[ServerDBTableID] [int] NULL,
	[RowCount] [bigint] NULL,
	[ReservedSpaceKB] [bigint] NULL,
	[DataSpaceKB] [bigint] NULL,
	[IndexSizeKB] [bigint] NULL,
	[UnusedKB] [bigint] NULL,
	[SampleDate] [smalldatetime] NULL
) ON [History]
GO
/****** Object:  View [hist].[SpaceUsed_DatabaseSizes_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [hist].[SpaceUsed_DatabaseSizes_vw]
AS

SELECT 
	s.[ServerName]
	,d.[DBName]
	,det.[DataSizeMB]
	,det.[LogSizeMB]
	,det.[SampleDate]
FROM [hist].[SpaceUsed_DatabaseSizes] det
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON s.[ServerID] = det.[ServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = det.[DatabaseID]
GO
/****** Object:  StoredProcedure [hist].[SpaceUsed_DatabaseSizes_InsertValue]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[SpaceUsed_DatabaseSizes_InsertValue] (
	@ServerName			VARCHAR(1000)
	,@DBName			SYSNAME
	,@DataSizeMB		BIGINT
	,@LogSizeMB			BIGINT
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
INSERT INTO [hist].[SpaceUsed_DatabaseSizes] ([ServerID], [DatabaseID], [DataSizeMB], [LogSizeMB], [SampleDate])
VALUES (@ServerID, @DatabaseID, @DataSizeMB, @LogSizeMB, GETDATE())
GO
/****** Object:  View [hist].[SpaceUsed_DatabaseSizes_Delta_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [hist].[SpaceUsed_DatabaseSizes_Delta_vw]
AS
WITH DBData AS (
	SELECT 
		[ServerID]
		,[DatabaseID]
		,[DataSizeMB]
		,[LogSizeMB]
		,[SampleDate]
		,ROW_NUMBER() OVER (PARTITION BY [ServerID], [DatabaseID] ORDER BY SampleDate) as rownum
	FROM [hist].[SpaceUsed_DatabaseSizes]
)
SELECT 
	s.[ServerName]
	,d.[DBName]
	,currow.[DataSizeMB]
	,currow.[DataSizeMB] - prevrow.[DataSizeMB] as DataSizeMBIncrease
	,currow.[LogSizeMB]
	,currow.[LogSizeMB] - prevrow.[LogSizeMB] as LogSizeMBIncrease
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
/****** Object:  StoredProcedure [hist].[ServerInventory_SQL_GetServerDBTableID]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[ServerInventory_SQL_GetServerDBTableID] (
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
WHERE id.[ServerID]	= @ServerID
AND	id.[DatabaseID]	= @DatabaseID
AND id.[TableID]	= @TableID

-- Add the server/db/schema/table combo if necessary
IF @ServerDBTableID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_ServerDBTableIDs] ([ServerID], [DatabaseID], [TableID], [LastUpdated]) 
	VALUES (@ServerID, @DatabaseID, @TableID, GETDATE())
	
	SET @ServerDBTableID = SCOPE_IDENTITY()
END
GO
/****** Object:  Table [dbo].[Backups_Jobs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Backups_Jobs](
	[JobID] [int] IDENTITY(1,1) NOT NULL,
	[JobName] [varchar](50) NULL,
	[ServerID] [int] NULL,
	[TargetServer] [varchar](50) NULL,
	[TargetShare] [varchar](50) NULL,
	[RecordHistory] [bit] NULL,
	[AlertLevel] [tinyint] NULL,
	[Enabled] [bit] NULL,
	[LoggingLevel] [tinyint] NULL,
	[CompressionLevel] [tinyint] NULL,
	[ThreadCount] [tinyint] NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[JobID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [hist].[Backups_History_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  StoredProcedure [hist].[Backups_SaveBackupHistory]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[Backups_SaveBackupHistory] (
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
	WHERE [ServerID] = @ServerID
	AND [DatabaseID] = @DatabaseID
	AND [BUTypeID] = @BackupTypeID
	AND [StartDate] = @StartDate
	)
BEGIN

	INSERT INTO [hist].[Backups_History] ([ServerID], [MachineID], [DatabaseID], [StartDate], [EndDate], [Size_MBytes], [BUTypeID], [UserID], [LogicalDeviceID], [PhysicalDeviceID])
	VALUES (@ServerID,@MachineID,@DatabaseID,@StartDate,@EndDate,@Size_Mbytes,@BackupTypeID,@UserID,@LogicalID,@PhysicalID)

END
GO
/****** Object:  StoredProcedure [hist].[ChangeTracking_SQL_GetObjectIDs]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[ChangeTracking_SQL_GetObjectIDs] (
	@SchemaName		SYSNAME
	,@ObjectName	SYSNAME
	,@RefType		NVARCHAR (128)
	,@ObjectId		INT OUTPUT
)

AS

DECLARE @ObjectTypeID INT

--get the object type id
EXEC [hist].[ChangeTracking_SQL_GETObjectTypeIDs] @RefType, @ObjectTypeID OUTPUT

-- Find the ObjectTypeID
SELECT 
	@ObjectID = ot.[ObjectID]
FROM [hist].[ChangeTracking_SQL_ObjectIDs] 
	 ot
WHERE ot.[SchemaName] = @SchemaName
	AND ot.[ObjectName] = @ObjectName
	AND ot.[ObjectTypeID]	= @ObjectTypeID

-- Add the  combo if necessary
IF @ObjectId IS NULL
BEGIN
	INSERT INTO [hist].[ChangeTracking_SQL_ObjectIDs]  ([SchemaName], [ObjectName], [ObjectTypeID]) 
	VALUES (@SchemaName, @ObjectName, @ObjectTypeID)
	SET @ObjectId = SCOPE_IDENTITY()
END
GO
/****** Object:  Table [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs](
	[ServerID] [int] NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[ObjectID] [int] NOT NULL,
	[ActionID] [int] NOT NULL,
	[DateModified] [date] NOT NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[DatabaseID] ASC,
	[ObjectID] ASC,
	[ActionID] ASC,
	[DateModified] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 60) ON [History]
) ON [History]
GO
/****** Object:  Table [dbo].[NTPermissions_ServerExceptions]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NTPermissions_ServerExceptions](
	[ServerID] [int] NULL,
	[StatementID] [int] NULL,
	[RunInAdditionToDefault] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  View [hist].[DTSStore_Packages_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	ON ps.[ServerID] = srvr.[ServerID]
GO
/****** Object:  StoredProcedure [hist].[DTSStore_StorePackageData]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[DTSStore_StorePackageData] (
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
		[ServerID]
		,[PackageNameID]
		,[VersionID] 
	FROM [hist].[DTSStore_PackageStore] 
	WHERE [ServerID] = @ServerID
	AND [PackageNameID] = @PackageNameID
	AND [VersionID] = @versionid
	)
BEGIN
	INSERT INTO [hist].[DTSStore_PackageStore] (ServerID, PackageNameID, VersionID, DescriptionID, CategoryID, CreateDate, OwnerID, PackageData, PackageType)
	VALUES (@ServerID, @PackageNameID, @versionid, @DescriptionID, @CategoryID_INT, @createdate, @OwnerID, @packagedata, @packagetype)
END
GO
/****** Object:  Table [dbo].[ServerInventory_SQL_AttributeList]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerInventory_SQL_AttributeList](
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
	[ServerID] [int] NOT NULL,
	[AttribID] [int] NOT NULL,
	[AttribValue] [nvarchar](1000) NULL,
	[DateCreated] [smalldatetime] NULL,
	[LastModified] [smalldatetime] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[UniqueID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AttribID] ON [dbo].[ServerInventory_SQL_AttributeList] 
(
	[AttribID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ServerID_AttribID] ON [dbo].[ServerInventory_SQL_AttributeList] 
(
	[ServerID] ASC,
	[AttribID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ServerInventory_SQL_AllServers_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ServerInventory_SQL_AllServers_vw]
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
GO
/****** Object:  View [dbo].[ServerInventory_SQL_BackupLicensing_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ServerInventory_SQL_BackupLicensing_vw]
AS
SELECT DISTINCT
	 vw.servername
	,am.AttribName AS [Software]
	,at.AttribValue AS [Status]
FROM dbo.ServerInventory_SQL_AllServers_vw vw
INNER JOIN dbo.ServerInventory_SQL_AttributeList at
	ON vw.serverid = at.serverid
INNER JOIN [dbo].[ServerInventory_SQL_AttributeMaster] am
	ON at.AttribID = am.AttribID
WHERE am.AttribName = 'redgate'
GO
/****** Object:  View [dbo].[ServerInventory_SQL_AllServers_Compatibility_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ServerInventory_SQL_AllServers_Compatibility_vw]
AS

SELECT
	m.[ServerID]
	,m.[FullName]			AS ServerName
	,m.[SQLVersion]
	,m.[Environment]
	,m.[Edition]
	,m.[Description]
	,CASE WHEN CHARINDEX(',',m.[FullName]) = 0
		THEN m.[FullName]
		ELSE LEFT(m.[FullName],CHARINDEX(',',m.[FullName]) - 1)
	END as [ServerNameNoPort]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] m
GO
/****** Object:  StoredProcedure [hist].[ChangeTracking_SQL_GetServerDBObjectActionIDs]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[ChangeTracking_SQL_GetServerDBObjectActionIDs] (
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
IF NOT EXISTS (SELECT [ServerID], [DatabaseID], [ObjectID], [ActionID], [DateModified]
				FROM [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]
				WHERE ServerID = @ServerID
				AND DatabaseID = @DatabaseID
				AND ObjectID = @ObjectID
				AND ActionID = @ActionID
				AND DateModified = @DateModified
				)
BEGIN
	INSERT INTO [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] ([ServerID], [DatabaseID], [ObjectID], [ActionID], [DateModified], [DateCreated]) 
	VALUES (@ServerID, @DatabaseID, @ObjectID, @ActionID, @DateModified, GETDATE())
END
GO
/****** Object:  View [hist].[ChangeTracking_AllDatabaseChanges_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Kathy Toth is awesome

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
		
FROM [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]id

INNER JOIN [hist].[ChangeTracking_SQL_ObjectIDs] ot
ON ot.ObjectID = id.ObjectID

INNER JOIN hist.ServerInventory_ServerIDs m
ON m.ServerID = id.ServerID

INNER JOIN [hist].[ChangeTracking_SQL_ObjectTypeIDs] ob
ON ob.ObjectTypeID = ot.ObjectTypeID

INNER JOIN [hist].[ChangeTracking_SQL_ActionIDs] ac
ON ac.ActionID = id.ActionID

INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs]d
ON d.DatabaseID = id.DatabaseID

--GO
GO
/****** Object:  Table [dbo].[Backups_JobSchedules]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Backups_JobSchedules](
	[JobScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[JobID] [int] NULL,
	[BackupAgentID] [int] NULL,
	[BackupTypeID] [int] NULL,
	[Schedule] [varchar](255) NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[JobScheduleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[ServerInventory_SQL_ServerAttributes_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ServerInventory_SQL_ServerAttributes_vw]
AS

SELECT 
	m.[ServerID]
	,m.[FullName]				AS ServerName
	,m.[SQLVersion]
	,m.[Environment]			AS EnvironmentName
	,am.[AttribName]
	,attrib.[AttribValue]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] m
INNER JOIN [dbo].[ServerInventory_SQL_AttributeList] attrib
	ON attrib.[ServerID] = m.[ServerID]
INNER JOIN [dbo].[ServerInventory_SQL_AttributeMaster] am
	ON attrib.[AttribID] = am.[AttribID]
GO
/****** Object:  StoredProcedure [dbo].[ServerInventory_SQL_SaveAttribute]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_SQL_SaveAttribute]
**  Desc:			Procedure to manage inserting data into the AttributeList table
**  Auth:			Matt Stanford
**  Date:			2008.12.29
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:		Description:
**	--------	--------	---------------------------------------
********************************************************************************************************/

CREATE PROCEDURE [dbo].[ServerInventory_SQL_SaveAttribute] (
	@ServerID			INT
	,@AttribName		VARCHAR(100)
	,@AttribValue		NVARCHAR(1000)
)
AS

DECLARE
	@AttribID		INT
	
SET @AttribID = (SELECT AttribID FROM [dbo].[ServerInventory_SQL_AttributeMaster] WHERE AttribName = @AttribName)

IF @AttribID IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT * FROM [dbo].[ServerInventory_SQL_AttributeList] WHERE ServerID = @ServerID AND AttribID = @AttribID)
	BEGIN
		-- Its an insert!
		INSERT INTO [dbo].[ServerInventory_SQL_AttributeList] ([ServerID], [AttribID], [AttribValue])
		VALUES (@ServerID, @AttribID, @AttribValue)
	END
	ELSE IF NOT EXISTS(SELECT * FROM [dbo].[ServerInventory_SQL_AttributeList] WHERE ServerID = @ServerID AND AttribID = @AttribID AND AttribValue = @AttribValue)
	BEGIN 
		-- Its an update!
		UPDATE al SET al.AttribValue = @AttribValue
		FROM [dbo].[ServerInventory_SQL_AttributeList] al
		WHERE al.ServerID = @ServerID 
		AND al.AttribID = @AttribID
	END
	ELSE
	BEGIN
		-- Its a trick!
		PRINT('Nothing to do here')
	END
END
ELSE
BEGIN
	PRINT('Attribute does not exist')
END
GO
/****** Object:  View [dbo].[NTPermissions_SQLStatements_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[NTPermissions_SQLStatements_vw]
AS
-- Select all servers that don't have a "instead of" flag set
-- Select all environment specific things
-- Select all server specific things

-- Default action for all servers that don't have the "instead of" flag set
SELECT
	srv.[ServerID]
	,srv.[FullName]
	,srv.[DotNetConnectionString]
	,N'EXEC [admin].[dbo].[NTPermissions_AllDBs]' AS [SQLToExecute]
	,'Default' AS [Description]
	,1 AS [Sequence]
FROM
	[dbo].[ServerInventory_SQL_AllServers_vw] srv
WHERE srv.ServerID NOT IN (
	SELECT
		s.[ServerID]
	FROM [dbo].[ServerInventory_SQL_Master] s
	FULL OUTER JOIN [dbo].[NTPermissions_EnvironmentExceptions] e_ex
		ON s.[EnvironmentID] = e_ex.[EnvironmentID]
	FULL OUTER JOIN [dbo].[NTPermissions_ServerExceptions] s_ex
		ON s.[ServerID] = s_ex.[ServerID]
	WHERE e_ex.[RunInAdditionToDefault] = 0
	OR s_ex.[RunInAdditionToDefault] = 0
)
	
UNION ALL
	
-- Run the environment specific statements
SELECT 
	s.[ServerID]
	,srv.[FullName]
	,srv.[DotNetConnectionString]
	,sql_sta.[SQLToExecute] AS [SQLToExecute]
	,sql_sta.[Description]
	,2 AS [Sequence]
FROM [dbo].[ServerInventory_SQL_Master] s
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] srv
	ON s.[ServerID] = srv.[ServerID]
INNER JOIN [dbo].[NTPermissions_EnvironmentExceptions] e_ex
	ON s.[EnvironmentID] = e_ex.[EnvironmentID]
INNER JOIN [dbo].[NTPermissions_PermissionSQLStatements] sql_sta
	ON e_ex.[StatementID] = sql_sta.[StatementID]
	AND ISNULL(sql_sta.[CompatVersionStart],2000) <= srv.[SQLVersion]
	AND ISNULL(sql_sta.[CompatVersionEnd],5000) >= srv.[SQLVersion]

UNION ALL
	
-- Lastly, run the server specific statements
SELECT 
	srv.[ServerID]
	,srv.[FullName]
	,srv.[DotNetConnectionString]
	,sql_sta.[SQLToExecute] AS [SQLToExecute]
	,sql_sta.[Description]
	,3 AS [Sequence]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] srv
INNER JOIN [dbo].[NTPermissions_ServerExceptions] s_ex
	ON srv.[ServerID] = s_ex.[ServerID]
INNER JOIN [dbo].[NTPermissions_PermissionSQLStatements] sql_sta
	ON s_ex.[StatementID] = sql_sta.[StatementID]
	AND ISNULL(sql_sta.[CompatVersionStart],2000) <= srv.[SQLVersion]
	AND ISNULL(sql_sta.[CompatVersionEnd],5000) >= srv.[SQLVersion]
GO
/****** Object:  View [dbo].[NTPermissions_ShowMappings_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[NTPermissions_ShowMappings_vw]
AS

SELECT
	sql_sta.[Description]
	,env.[EnvironmentName] as [Name]
	,'Environment' as [EnvOrSrv]
	,sql_sta.[SQLToExecute]
FROM [dbo].[NTPermissions_EnvironmentExceptions] e_ex
INNER JOIN [dbo].[NTPermissions_PermissionSQLStatements] sql_sta
	ON e_ex.[StatementID] = sql_sta.[StatementID]
INNER JOIN [dbo].[ServerInventory_Environments] env
	ON e_ex.[EnvironmentID] = env.[EnvironmentID]
	
UNION ALL

SELECT
	sql_sta.[Description]
	,srv.[FullName] as [ItemName]
	,'Server' as [EnvOrSrv]
	,sql_sta.[SQLToExecute]
FROM [dbo].[NTPermissions_ServerExceptions] s_ex
INNER JOIN [dbo].[NTPermissions_PermissionSQLStatements] sql_sta
	ON s_ex.[StatementID] = sql_sta.[StatementID]
INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] srv
	ON s_ex.[ServerID] = srv.[ServerID]
GO
/****** Object:  View [hist].[SpaceUsed_TableSizes_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  StoredProcedure [hist].[SpaceUsed_TableSizes_InsertValue]    Script Date: 03/04/2009 13:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hist].[SpaceUsed_TableSizes_InsertValue] (
	@ServerName			VARCHAR(1000)
	,@DBName			SYSNAME
	,@SchemaName		SYSNAME
	,@TableName			SYSNAME
	,@RowCount			BIGINT
	,@ReservedSpaceKB	BIGINT
	,@DataSpaceKB		BIGINT
	,@IndexSizeKB		BIGINT
	,@UnusedKB			BIGINT
)
AS

SET NOCOUNT ON

DECLARE 
	@ServerDBTableID	INT
	
-- Get the ServerDBTableID
EXEC [hist].[ServerInventory_SQL_GetServerDBTableID] @ServerName, @DBName, @SchemaName, @TableName, @ServerDBTableID OUTPUT

-- Now that we've got that, just insert into our detail table
INSERT INTO [hist].[SpaceUsed_TableSizes] ([ServerDBTableID], [RowCount], [ReservedSpaceKB], [DataSpaceKB], [IndexSizeKB], [UnusedKB], [SampleDate])
VALUES (@ServerDBTableID, @RowCount, @ReservedSpaceKB, @DataSpaceKB, @IndexSizeKB, @UnusedKB, GETDATE())
GO
/****** Object:  View [hist].[SpaceUsed_TableSizes_Delta_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	ON s.[ServerID] = m.[ServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON d.[DatabaseID] = m.[DatabaseID]
INNER JOIN [hist].[ServerInventory_SQL_TableIDs] t
	ON t.[TableID] = m.[TableID]
LEFT OUTER JOIN TableData prevrow
	ON currow.rownum = prevrow.rownum + 1
	AND currow.ServerDBTableID = prevrow.ServerDBTableID
GO
/****** Object:  View [dbo].[SpaceUsed_CollectTableOrDatabase_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SpaceUsed_CollectTableOrDatabase_vw]
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
/****** Object:  View [dbo].[ServerInventory_SQL_ServerInstances_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ServerInventory_SQL_ServerInstances_vw]
AS

WITH SN ([ServerName], [Environment], [InstanceName])
AS
(
	SELECT 
		[ServerName]
		,[EnvironmentName]
		,[AttribValue]
	FROM [dbo].[ServerInventory_SQL_ServerAttributes_vw] 
	WHERE [AttribName] = 'InstanceName'
)
SELECT 
	i.[InstanceName]
	,d.[ServerName] as DEV
	,q.[ServerName] as QA
	,p.[ServerName] as Prod
FROM (SELECT DISTINCT [InstanceName] FROM SN) i
LEFT OUTER JOIN (SELECT [ServerName],[InstanceName] FROM SN WHERE [Environment] = 'DEV') d
	ON d.[InstanceName] = i.[InstanceName]
LEFT OUTER JOIN (SELECT [ServerName],[InstanceName] FROM SN WHERE [Environment] = 'QA') q
	ON q.[InstanceName] = i.[InstanceName]
LEFT OUTER JOIN (SELECT [ServerName],[InstanceName] FROM SN WHERE [Environment] IN ('SAVVIS','BI','OECPROD')) p
	ON p.[InstanceName] = i.[InstanceName]
GO
/****** Object:  View [dbo].[ServerInventory_SQL_ServerInfo_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ServerInventory_SQL_ServerInfo_vw]
AS

SELECT 
	srv.[ServerID]
	,srv.[FullName] as [ServerName]
	,srv.[Environment]
	,srv.[Description]
	,COALESCE(att.[SQLVersion],srv.[SQLVersion]) AS [SQLVersion]
	,att.[SQLServer_ServicePack]
	,att.[CumulativeUpdate]
	,att.[Description] as [ProductVersionDescription]
	,att.[SQLServer_Build]
	,COALESCE(att.[SQLServer_Edition],srv.[Edition]) AS [Edition]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] srv
LEFT OUTER JOIN (
	SELECT 
		PVT.[ServerName]
		,[SQLServer_Build]
		,bd.[SQLVersion]
		,bd.[ProductLevel]
		,bd.[CumulativeUpdate]
		,[SQLServer_Edition]
		,[SQLServer_ServicePack]
		,bd.[Description]
	FROM
	(
		SELECT 
			s.FullName as ServerName
			,sa.AttribName
			,sa.AttribValue
		FROM [dbo].[ServerInventory_SQL_AllServers_vw] s
		LEFT OUTER JOIN [dbo].[ServerInventory_SQL_ServerAttributes_vw] sa
			ON sa.ServerName = s.FullName
		WHERE sa.AttribName IN ('SQLServer_Build','SQLServer_ServicePack','SQLServer_Edition','SQLServer_Engine')
	) as st
	PIVOT
	(
		MAX(AttribValue)
		FOR AttribName 
			IN ([SQLServer_Build],[SQLServer_ServicePack],[SQLServer_Edition],[SQLServer_Engine])
	) as PVT
	LEFT OUTER JOIN [dbo].[ServerInventory_SQL_BuildLevelDesc] bd
		ON bd.[ProductVersion] = PVT.[SQLServer_Build]
) att
ON att.[ServerName] = srv.[FullName]
GO
/****** Object:  View [dbo].[ServerInventory_AllServers_Compatibility_vw]    Script Date: 03/04/2009 13:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ServerInventory_AllServers_Compatibility_vw]
AS
SELECT *
FROM dbo.ServerInventory_SQL_AllServers_Compatibility_vw
GO
/****** Object:  Table [dbo].[Backups_DBsToNotBackup]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Backups_DBsToNotBackup](
	[DBsToNotBackupID] [int] IDENTITY(1,1) NOT NULL,
	[JobScheduleID] [int] NULL,
	[DatabaseName] [sysname] NOT NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DBsToNotBackupID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Backups_DBsToBackup]    Script Date: 03/04/2009 13:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Backups_DBsToBackup](
	[DBsToBackupID] [int] IDENTITY(1,1) NOT NULL,
	[JobScheduleID] [int] NULL,
	[DatabaseName] [sysname] NOT NULL,
	[DateCreated] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DBsToBackupID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF__Backups_B__DateC__0C0786B7]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_BackupAgents] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__Backups_B__DateC__17793963]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_BackupCommands] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__Backups_B__DateC__10CC3BD4]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_BackupTypes] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__Backups_J__Recor__1D3212B9]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_Jobs] ADD  DEFAULT ((1)) FOR [RecordHistory]
GO
/****** Object:  Default [DF__Backups_J__Enabl__1E2636F2]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_Jobs] ADD  DEFAULT ((1)) FOR [Enabled]
GO
/****** Object:  Default [DF__Backups_J__DateC__1F1A5B2B]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_Jobs] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__Backups_J__DateC__26BB7CF3]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_JobSchedules] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF_SrvSettings_targetSrv]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_SrvSettings] ADD  CONSTRAINT [DF_SrvSettings_targetSrv]  DEFAULT ('oecfp3') FOR [targetSrv]
GO
/****** Object:  Default [DF_SrvSettings_targetShare]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_SrvSettings] ADD  CONSTRAINT [DF_SrvSettings_targetShare]  DEFAULT ('sqlbu$') FOR [targetShare]
GO
/****** Object:  Default [DF_SrvSettings_dbRecord]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_SrvSettings] ADD  CONSTRAINT [DF_SrvSettings_dbRecord]  DEFAULT ((1)) FOR [dbRecord]
GO
/****** Object:  Default [DF_SrvSettings_buExeptions]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_SrvSettings] ADD  CONSTRAINT [DF_SrvSettings_buExeptions]  DEFAULT ((0)) FOR [buExceptions]
GO
/****** Object:  Default [DF_SrvSettings_alertLevel]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_SrvSettings] ADD  CONSTRAINT [DF_SrvSettings_alertLevel]  DEFAULT ((2)) FOR [alertLevel]
GO
/****** Object:  Default [DF_SrvSettings_jobEnabled]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_SrvSettings] ADD  CONSTRAINT [DF_SrvSettings_jobEnabled]  DEFAULT ((1)) FOR [jobEnabled]
GO
/****** Object:  Default [DF_SrvSettings_loggingLevel]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_SrvSettings] ADD  CONSTRAINT [DF_SrvSettings_loggingLevel]  DEFAULT ((0)) FOR [loggingLevel]
GO
/****** Object:  Default [DF__NTPermiss__RunIn__3F466844]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_EnvironmentExceptions] ADD  DEFAULT ((1)) FOR [RunInAdditionToDefault]
GO
/****** Object:  Default [DF__NTPermiss__RunIn__4316F928]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_ServerExceptions] ADD  DEFAULT ((1)) FOR [RunInAdditionToDefault]
GO
/****** Object:  Default [DF__ServerInv__DateC__403A8C7D]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__ServerInv__LastM__412EB0B6]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] ADD  DEFAULT (getdate()) FOR [LastModified]
GO
/****** Object:  Default [DF__ServerInv__Enabl__3D5E1FD2]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_Master] ADD  DEFAULT ((1)) FOR [Enabled]
GO
/****** Object:  Default [DF__ServerInv__UseCr__3E52440B]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_Master] ADD  DEFAULT ((0)) FOR [UseCredential]
GO
/****** Object:  Default [DF__Backups_B__DateC__322D2F9F]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_BackupJobHistory] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__Backups_D__DateC__3BB699D9]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_Devices] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__Backups_T__DateC__36F1E4BC]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_Types] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__ChangeTra__DateC__51E5D21A]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__DTSStore___DateC__77FFC2B3]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_Categories] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__DTSStore___DateC__733B0D96]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_Descriptions] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__DTSStore___DateC__7CC477D0]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_Owners] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__DTSStore___datec__6E765879]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_PackageNames] ADD  DEFAULT (getdate()) FOR [datecreated]
GO
/****** Object:  Default [DF__DTSStore___DateC__04659998]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_PackageStore] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  Default [DF__SpaceUsed__Sampl__5BCD9859]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[SpaceUsed_DatabaseSizes] ADD  DEFAULT (getdate()) FOR [SampleDate]
GO
/****** Object:  Default [DF__Users_Use__DateC__45750E3D]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Users_UserNames] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
/****** Object:  ForeignKey [FK_BackupAgents_AgentID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_BackupCommands]  WITH CHECK ADD  CONSTRAINT [FK_BackupAgents_AgentID] FOREIGN KEY([BackupAgentID])
REFERENCES [dbo].[Backups_BackupAgents] ([BackupAgentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Backups_BackupCommands] CHECK CONSTRAINT [FK_BackupAgents_AgentID]
GO
/****** Object:  ForeignKey [FK_BackupCommands_CommandID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_BackupCommands]  WITH CHECK ADD  CONSTRAINT [FK_BackupCommands_CommandID] FOREIGN KEY([BackupTypeID])
REFERENCES [dbo].[Backups_BackupTypes] ([BackupTypeID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Backups_BackupCommands] CHECK CONSTRAINT [FK_BackupCommands_CommandID]
GO
/****** Object:  ForeignKey [FK_Do_JobScheduleID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_DBsToBackup]  WITH CHECK ADD  CONSTRAINT [FK_Do_JobScheduleID] FOREIGN KEY([JobScheduleID])
REFERENCES [dbo].[Backups_JobSchedules] ([JobScheduleID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Backups_DBsToBackup] CHECK CONSTRAINT [FK_Do_JobScheduleID]
GO
/****** Object:  ForeignKey [FK_DoNot_JobScheduleID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_DBsToNotBackup]  WITH CHECK ADD  CONSTRAINT [FK_DoNot_JobScheduleID] FOREIGN KEY([JobScheduleID])
REFERENCES [dbo].[Backups_JobSchedules] ([JobScheduleID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Backups_DBsToNotBackup] CHECK CONSTRAINT [FK_DoNot_JobScheduleID]
GO
/****** Object:  ForeignKey [FK_Master_ServerID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Master_ServerID] FOREIGN KEY([ServerID])
REFERENCES [dbo].[ServerInventory_SQL_Master] ([ServerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Backups_Jobs] CHECK CONSTRAINT [FK_Master_ServerID]
GO
/****** Object:  ForeignKey [FK_Backups_BackupTypes_BackupTypeID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_JobSchedules]  WITH CHECK ADD  CONSTRAINT [FK_Backups_BackupTypes_BackupTypeID] FOREIGN KEY([BackupTypeID])
REFERENCES [dbo].[Backups_BackupTypes] ([BackupTypeID])
GO
ALTER TABLE [dbo].[Backups_JobSchedules] CHECK CONSTRAINT [FK_Backups_BackupTypes_BackupTypeID]
GO
/****** Object:  ForeignKey [FK_JobID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_JobSchedules]  WITH CHECK ADD  CONSTRAINT [FK_JobID] FOREIGN KEY([JobID])
REFERENCES [dbo].[Backups_Jobs] ([JobID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Backups_JobSchedules] CHECK CONSTRAINT [FK_JobID]
GO
/****** Object:  ForeignKey [FK_Schedules_BackupAgents_AgentID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[Backups_JobSchedules]  WITH CHECK ADD  CONSTRAINT [FK_Schedules_BackupAgents_AgentID] FOREIGN KEY([BackupAgentID])
REFERENCES [dbo].[Backups_BackupAgents] ([BackupAgentID])
GO
ALTER TABLE [dbo].[Backups_JobSchedules] CHECK CONSTRAINT [FK_Schedules_BackupAgents_AgentID]
GO
/****** Object:  ForeignKey [FK__NTPermiss__Envir__46E78A0C]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_EnvironmentExceptions]  WITH CHECK ADD FOREIGN KEY([EnvironmentID])
REFERENCES [dbo].[ServerInventory_Environments] ([EnvironmentID])
ON DELETE CASCADE
GO
/****** Object:  ForeignKey [FK__NTPermiss__State__47DBAE45]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_EnvironmentExceptions]  WITH CHECK ADD FOREIGN KEY([StatementID])
REFERENCES [dbo].[NTPermissions_PermissionSQLStatements] ([StatementID])
GO
/****** Object:  ForeignKey [FK__NTPermiss__State__48CFD27E]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_EnvironmentExceptions]  WITH CHECK ADD FOREIGN KEY([StatementID])
REFERENCES [dbo].[NTPermissions_PermissionSQLStatements] ([StatementID])
GO
/****** Object:  ForeignKey [FK__NTPermiss__Serve__5070F446]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_ServerExceptions]  WITH CHECK ADD FOREIGN KEY([ServerID])
REFERENCES [dbo].[ServerInventory_SQL_Master] ([ServerID])
ON DELETE CASCADE
GO
/****** Object:  ForeignKey [FK__NTPermiss__State__5165187F]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_ServerExceptions]  WITH CHECK ADD FOREIGN KEY([StatementID])
REFERENCES [dbo].[NTPermissions_PermissionSQLStatements] ([StatementID])
GO
/****** Object:  ForeignKey [FK__NTPermiss__State__52593CB8]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[NTPermissions_ServerExceptions]  WITH CHECK ADD FOREIGN KEY([StatementID])
REFERENCES [dbo].[NTPermissions_PermissionSQLStatements] ([StatementID])
GO
/****** Object:  ForeignKey [FK_SI_SQL_AttributeMaster_AttributeID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList]  WITH CHECK ADD  CONSTRAINT [FK_SI_SQL_AttributeMaster_AttributeID] FOREIGN KEY([AttribID])
REFERENCES [dbo].[ServerInventory_SQL_AttributeMaster] ([AttribID])
GO
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] CHECK CONSTRAINT [FK_SI_SQL_AttributeMaster_AttributeID]
GO
/****** Object:  ForeignKey [FK_SI_SQL_Master_ServerID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList]  WITH CHECK ADD  CONSTRAINT [FK_SI_SQL_Master_ServerID] FOREIGN KEY([ServerID])
REFERENCES [dbo].[ServerInventory_SQL_Master] ([ServerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeList] CHECK CONSTRAINT [FK_SI_SQL_Master_ServerID]
GO
/****** Object:  ForeignKey [FK_SI_Environments_EnvironmentID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_Master]  WITH CHECK ADD  CONSTRAINT [FK_SI_Environments_EnvironmentID] FOREIGN KEY([EnvironmentID])
REFERENCES [dbo].[ServerInventory_Environments] ([EnvironmentID])
GO
ALTER TABLE [dbo].[ServerInventory_SQL_Master] CHECK CONSTRAINT [FK_SI_Environments_EnvironmentID]
GO
/****** Object:  ForeignKey [FK_SI_SQL_Editions_EditionID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_Master]  WITH CHECK ADD  CONSTRAINT [FK_SI_SQL_Editions_EditionID] FOREIGN KEY([EditionID])
REFERENCES [dbo].[ServerInventory_SQL_Editions] ([EditionID])
GO
ALTER TABLE [dbo].[ServerInventory_SQL_Master] CHECK CONSTRAINT [FK_SI_SQL_Editions_EditionID]
GO
/****** Object:  ForeignKey [FK_SI_SQL_ServerCredentials_CredentialID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [dbo].[ServerInventory_SQL_Master]  WITH CHECK ADD  CONSTRAINT [FK_SI_SQL_ServerCredentials_CredentialID] FOREIGN KEY([CredentialID])
REFERENCES [dbo].[ServerInventory_SQL_ServerCredentials] ([CredentialID])
GO
ALTER TABLE [dbo].[ServerInventory_SQL_Master] CHECK CONSTRAINT [FK_SI_SQL_ServerCredentials_CredentialID]
GO
/****** Object:  ForeignKey [FK_BUHist_BackupType]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_History]  WITH CHECK ADD  CONSTRAINT [FK_BUHist_BackupType] FOREIGN KEY([BUTypeID])
REFERENCES [hist].[Backups_Types] ([BackupTypeID])
GO
ALTER TABLE [hist].[Backups_History] CHECK CONSTRAINT [FK_BUHist_BackupType]
GO
/****** Object:  ForeignKey [FK_BUHist_DatabaseID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_History]  WITH CHECK ADD  CONSTRAINT [FK_BUHist_DatabaseID] FOREIGN KEY([DatabaseID])
REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
GO
ALTER TABLE [hist].[Backups_History] CHECK CONSTRAINT [FK_BUHist_DatabaseID]
GO
/****** Object:  ForeignKey [FK_BUHist_LogicalDeviceID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_History]  WITH CHECK ADD  CONSTRAINT [FK_BUHist_LogicalDeviceID] FOREIGN KEY([LogicalDeviceID])
REFERENCES [hist].[Backups_Devices] ([DeviceID])
GO
ALTER TABLE [hist].[Backups_History] CHECK CONSTRAINT [FK_BUHist_LogicalDeviceID]
GO
/****** Object:  ForeignKey [FK_BUHist_PhysicalDeviceID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_History]  WITH CHECK ADD  CONSTRAINT [FK_BUHist_PhysicalDeviceID] FOREIGN KEY([PhysicalDeviceID])
REFERENCES [hist].[Backups_Devices] ([DeviceID])
GO
ALTER TABLE [hist].[Backups_History] CHECK CONSTRAINT [FK_BUHist_PhysicalDeviceID]
GO
/****** Object:  ForeignKey [FK_BUHist_ServerID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_History]  WITH CHECK ADD  CONSTRAINT [FK_BUHist_ServerID] FOREIGN KEY([ServerID])
REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
ALTER TABLE [hist].[Backups_History] CHECK CONSTRAINT [FK_BUHist_ServerID]
GO
/****** Object:  ForeignKey [FK_BUHist_ServerID2]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_History]  WITH CHECK ADD  CONSTRAINT [FK_BUHist_ServerID2] FOREIGN KEY([MachineID])
REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
ALTER TABLE [hist].[Backups_History] CHECK CONSTRAINT [FK_BUHist_ServerID2]
GO
/****** Object:  ForeignKey [FK_BUHist_UserID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[Backups_History]  WITH CHECK ADD  CONSTRAINT [FK_BUHist_UserID] FOREIGN KEY([UserID])
REFERENCES [hist].[Users_UserNames] ([UserID])
GO
ALTER TABLE [hist].[Backups_History] CHECK CONSTRAINT [FK_BUHist_UserID]
GO
/****** Object:  ForeignKey [FK_ChangeTracking_SQL_ObjectTypeIDs]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[ChangeTracking_SQL_ObjectIDs]  WITH CHECK ADD  CONSTRAINT [FK_ChangeTracking_SQL_ObjectTypeIDs] FOREIGN KEY([ObjectTypeID])
REFERENCES [hist].[ChangeTracking_SQL_ObjectTypeIDs] ([ObjectTypeId])
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ObjectIDs] CHECK CONSTRAINT [FK_ChangeTracking_SQL_ObjectTypeIDs]
GO
/****** Object:  ForeignKey [FK_ChangeTracking_SQL_ActionIDs_ActionID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]  WITH CHECK ADD  CONSTRAINT [FK_ChangeTracking_SQL_ActionIDs_ActionID] FOREIGN KEY([ActionID])
REFERENCES [hist].[ChangeTracking_SQL_ActionIDs] ([ActionID])
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] CHECK CONSTRAINT [FK_ChangeTracking_SQL_ActionIDs_ActionID]
GO
/****** Object:  ForeignKey [FK_ChangeTracking_SQL_ObjectIDs_ObjectID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]  WITH CHECK ADD  CONSTRAINT [FK_ChangeTracking_SQL_ObjectIDs_ObjectID] FOREIGN KEY([ObjectID])
REFERENCES [hist].[ChangeTracking_SQL_ObjectIDs] ([ObjectID])
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] CHECK CONSTRAINT [FK_ChangeTracking_SQL_ObjectIDs_ObjectID]
GO
/****** Object:  ForeignKey [FK_ServerInventory_ServerIDs_ServerID2]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]  WITH CHECK ADD  CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID2] FOREIGN KEY([ServerID])
REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] CHECK CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID2]
GO
/****** Object:  ForeignKey [FK_ServerInventory_SQL_DatabaseIDs_DatabaseID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs]  WITH CHECK ADD  CONSTRAINT [FK_ServerInventory_SQL_DatabaseIDs_DatabaseID] FOREIGN KEY([DatabaseID])
REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
GO
ALTER TABLE [hist].[ChangeTracking_SQL_ServerDBObjectActionIDs] CHECK CONSTRAINT [FK_ServerInventory_SQL_DatabaseIDs_DatabaseID]
GO
/****** Object:  ForeignKey [FK_Catagories_CategoryID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_PackageStore]  WITH CHECK ADD  CONSTRAINT [FK_Catagories_CategoryID] FOREIGN KEY([CategoryID])
REFERENCES [hist].[DTSStore_Categories] ([CategoryID])
GO
ALTER TABLE [hist].[DTSStore_PackageStore] CHECK CONSTRAINT [FK_Catagories_CategoryID]
GO
/****** Object:  ForeignKey [FK_Descriptions_DescriptionID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_PackageStore]  WITH CHECK ADD  CONSTRAINT [FK_Descriptions_DescriptionID] FOREIGN KEY([DescriptionID])
REFERENCES [hist].[DTSStore_Descriptions] ([DescriptionID])
GO
ALTER TABLE [hist].[DTSStore_PackageStore] CHECK CONSTRAINT [FK_Descriptions_DescriptionID]
GO
/****** Object:  ForeignKey [FK_Owners_OwnerID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_PackageStore]  WITH CHECK ADD  CONSTRAINT [FK_Owners_OwnerID] FOREIGN KEY([OwnerID])
REFERENCES [hist].[DTSStore_Owners] ([OwnerID])
GO
ALTER TABLE [hist].[DTSStore_PackageStore] CHECK CONSTRAINT [FK_Owners_OwnerID]
GO
/****** Object:  ForeignKey [FK_PackageNames_PackageNameID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_PackageStore]  WITH CHECK ADD  CONSTRAINT [FK_PackageNames_PackageNameID] FOREIGN KEY([PackageNameID])
REFERENCES [hist].[DTSStore_PackageNames] ([PackageNameID])
GO
ALTER TABLE [hist].[DTSStore_PackageStore] CHECK CONSTRAINT [FK_PackageNames_PackageNameID]
GO
/****** Object:  ForeignKey [FK_ServerInventory_ServerIDs_ServerID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[DTSStore_PackageStore]  WITH CHECK ADD  CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID] FOREIGN KEY([ServerID])
REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
ALTER TABLE [hist].[DTSStore_PackageStore] CHECK CONSTRAINT [FK_ServerInventory_ServerIDs_ServerID]
GO
/****** Object:  ForeignKey [FK_SI_ServerIDs_ServerID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[ServerInventory_SQL_ServerDBTableIDs]  WITH CHECK ADD  CONSTRAINT [FK_SI_ServerIDs_ServerID] FOREIGN KEY([ServerID])
REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
ALTER TABLE [hist].[ServerInventory_SQL_ServerDBTableIDs] CHECK CONSTRAINT [FK_SI_ServerIDs_ServerID]
GO
/****** Object:  ForeignKey [FK_SI_DatabaseIDs_DatabaseID_2]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[SpaceUsed_DatabaseSizes]  WITH CHECK ADD  CONSTRAINT [FK_SI_DatabaseIDs_DatabaseID_2] FOREIGN KEY([DatabaseID])
REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
GO
ALTER TABLE [hist].[SpaceUsed_DatabaseSizes] CHECK CONSTRAINT [FK_SI_DatabaseIDs_DatabaseID_2]
GO
/****** Object:  ForeignKey [FK_SI_ServerIDs_ServerID_2]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[SpaceUsed_DatabaseSizes]  WITH CHECK ADD  CONSTRAINT [FK_SI_ServerIDs_ServerID_2] FOREIGN KEY([ServerID])
REFERENCES [hist].[ServerInventory_ServerIDs] ([ServerID])
GO
ALTER TABLE [hist].[SpaceUsed_DatabaseSizes] CHECK CONSTRAINT [FK_SI_ServerIDs_ServerID_2]
GO
/****** Object:  ForeignKey [FK_SI_ServerDBTableIDs_ServerDBTableID]    Script Date: 03/04/2009 13:48:51 ******/
ALTER TABLE [hist].[SpaceUsed_TableSizes]  WITH CHECK ADD  CONSTRAINT [FK_SI_ServerDBTableIDs_ServerDBTableID] FOREIGN KEY([ServerDBTableID])
REFERENCES [hist].[ServerInventory_SQL_ServerDBTableIDs] ([ServerDBTableID])
GO
ALTER TABLE [hist].[SpaceUsed_TableSizes] CHECK CONSTRAINT [FK_SI_ServerDBTableIDs_ServerDBTableID]
GO
----------------------------------------------------
