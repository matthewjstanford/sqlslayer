USE [DBACentral]
GO
IF OBJECT_ID('[hist].[ServerInventory_SQL_SaveDatabaseAttribute]','P') IS NOT NULL
	DROP PROCEDURE [hist].[ServerInventory_SQL_SaveDatabaseAttribute]
IF OBJECT_ID('[hist].[ServerInventory_SQL_DatabaseAttributes_vw]','V') IS NOT NULL
	DROP VIEW [hist].[ServerInventory_SQL_DatabaseAttributes_vw]
IF OBJECT_ID('[hist].[ServerInventory_SQL_DatabaseAttributeValues]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_DatabaseAttributeValues]
IF OBJECT_ID('[hist].[ServerInventory_SQL_DatabaseAttributeMaster]','U') IS NOT NULL
	DROP TABLE [hist].[ServerInventory_SQL_DatabaseAttributeMaster]


CREATE TABLE [hist].[ServerInventory_SQL_DatabaseAttributeMaster] (
	[DatabaseAttributeID]		INT IDENTITY CONSTRAINT [PK__ServerInventory_SQL_DatabaseAttributeMaster__DatabaseAttributeID] PRIMARY KEY CLUSTERED NOT NULL
	,[AttributeName]			VARCHAR(500) NOT NULL
	,[DateCreated]				DATETIME CONSTRAINT [DF__ServerInventory_SQL_DatabaseAttributeMaster__DateCreated] DEFAULT (GETDATE()) NOT NULL
) ON [History]


CREATE TABLE [hist].[ServerInventory_SQL_DatabaseAttributeValues] (
	[DatabaseAttributeValueID]	INT IDENTITY CONSTRAINT [PK__ServerInventory_SQL_DatabaseAttributeValues__DatabaseAttributeValueID] PRIMARY KEY CLUSTERED NOT NULL
	,[HistServerID]				INT CONSTRAINT [FK__ServerInventory_SQL_DatabaseAttributeValues__HistServerID__ServerInventory_SQL_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([HistServerID])
	,[HistDatabaseID]			INT CONSTRAINT [FK__ServerInventory_SQL_DatabaseAttributeValues__HistDatabaseID__ServerInventory_SQL_DatabaseIDs__DatabaseID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs] ([DatabaseID])
	,[file_id]					INT NULL
	,[DatabaseAttributeID]		INT CONSTRAINT [FK__DatabaseAttributeValues__DatabaseAttributeID__DatabaseAttributeMaster__DatabaseAttributeID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_DatabaseAttributeMaster] ([DatabaseAttributeID])
	,[AttributeValue]			SQL_VARIANT NULL
	,[DateCreated]				DATETIME CONSTRAINT [DF__ServerInventory_SQL_DatabaseAttributeValues__DateCreated] DEFAULT (GETDATE()) NOT NULL
	,[DateLastSeenOn]			DATETIME CONSTRAINT [DF__ServerInventory_SQL_DatabaseAttributeValues__DateLastSeenOn] DEFAULT (GETDATE()) NOT NULL
) ON [History]


CREATE UNIQUE NONCLUSTERED INDEX [UIX__ServerInventory_SQL_DatabaseAttributeMaster__AttributeName] ON [hist].[ServerInventory_SQL_DatabaseAttributeMaster]([AttributeName]) WITH (FILLFACTOR = 85)
CREATE NONCLUSTERED INDEX [IX__DatabaseAttributeValues__HistServerID__HistDatabaseID__file_id__DatabaseAttributeID] 
	ON [hist].[ServerInventory_SQL_DatabaseAttributeValues] ([HistServerID],[HistDatabaseID],[file_id],[DatabaseAttributeID]) INCLUDE ([AttributeValue]) WITH (FILLFACTOR = 85)
GO

CREATE VIEW [hist].[ServerInventory_SQL_DatabaseAttributes_vw]
AS

SELECT
	s.[ServerName]
	,d.[DBName]
	,v.[file_id]
	,a.[AttributeName]
	,v.[AttributeValue]
	,v.[DateCreated]
	,v.[DateLastSeenOn]
FROM [hist].[ServerInventory_SQL_DatabaseAttributeValues] v
INNER JOIN [hist].[ServerInventory_SQL_DatabaseAttributeMaster] a
	ON v.[DatabaseAttributeID] = a.[DatabaseAttributeID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON v.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
	ON v.[HistDatabaseID] = d.[DatabaseID]
GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_SaveDatabaseAttribute]
**  Desc:			Stores database attribute values
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2011.04.06
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [hist].[ServerInventory_SQL_SaveDatabaseAttribute] (
	@ServerName				VARCHAR(200)
	,@DatabaseName			VARCHAR(128)
	,@file_id				INT
	,@AttributeName			VARCHAR(500)
	,@AttributeValue		SQL_VARIANT
)
AS
SET NOCOUNT ON

DECLARE 
	@HistServerID				INT
	,@AttributeID				INT
	,@DatabaseID				INT
	,@DatabaseAttributeValueID	INT
	,@CurrentValue				SQL_VARIANT

-- Get the server ID	
EXEC [hist].[ServerInventory_GetServerID] @ServerName = @ServerName, @ServerID = @HistServerID OUTPUT

-- Get the attribute ID
SELECT
	@AttributeID = [DatabaseAttributeID]
FROM [hist].[ServerInventory_SQL_DatabaseAttributeMaster]
WHERE [AttributeName] = @AttributeName

IF @AttributeID IS NULL
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_DatabaseAttributeMaster] ([AttributeName])
	VALUES (@AttributeName)
	
	SET @AttributeID = SCOPE_IDENTITY()
END

-- Get the database ID
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @DBName = @DatabaseName, @DatabaseID = @DatabaseID OUTPUT

-- If the most recent entry is not equal to the current value (or null) then insert a new record.
;WITH CTE 
AS (
	SELECT 
		MAX([DatabaseAttributeValueID]) AS [AttributeID]
	FROM [hist].[ServerInventory_SQL_DatabaseAttributeValues]
	WHERE [HistServerID]			= @HistServerID
	AND [HistDatabaseID]			= @DatabaseID
	AND ISNULL([file_id],'')		= ISNULL(@file_id,'')
	AND [DatabaseAttributeID]		= @AttributeID
)
SELECT 
	@DatabaseAttributeValueID = c.[AttributeID]
	,@CurrentValue = v.[AttributeValue]
FROM CTE c
INNER JOIN [hist].[ServerInventory_SQL_DatabaseAttributeValues] v
	ON c.[AttributeID] = v.[DatabaseAttributeValueID]

-- The one condition to do an update
IF (@DatabaseAttributeValueID IS NOT NULL AND @CurrentValue = @AttributeValue)
BEGIN
	UPDATE a SET [DateLastSeenOn] = GETDATE()
	FROM [hist].[ServerInventory_SQL_DatabaseAttributeValues] a
	WHERE a.[DatabaseAttributeValueID] = @DatabaseAttributeValueID
END
-- Do the insert
ELSE
BEGIN
	INSERT INTO [hist].[ServerInventory_SQL_DatabaseAttributeValues] ([HistServerID], [HistDatabaseID], [file_id], [DatabaseAttributeID], [AttributeValue], [DateCreated], [DateLastSeenOn])
	VALUES (@HistServerID, @DatabaseID, @file_id, @AttributeID, @AttributeValue, GETDATE(), GETDATE())
END