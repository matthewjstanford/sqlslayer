USE DBACentral
GO

SET XACT_ABORT ON

BEGIN TRANSACTION

-- Remove old procedures
IF OBJECT_ID('[dbo].[Collectors_Log_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[Collectors_Log_InsertValue]

-- Remove unused tables
IF OBJECT_ID('dbo.Collectors_Log','U') IS NOT NULL
	DROP TABLE dbo.Collectors_Log
IF OBJECT_ID('dbo.Collectors_RecipeDetails','U') IS NOT NULL
	DROP TABLE dbo.Collectors_RecipeDetails
IF OBJECT_ID('dbo.Collectors_RecipeMaster','U') IS NOT NULL
	DROP TABLE dbo.Collectors_RecipeMaster
IF OBJECT_ID('dbo.Collectors_Scripts','U') IS NOT NULL
	DROP TABLE dbo.Collectors_Scripts

-- New procedures
IF OBJECT_ID('[hist].[Collectors_GetScriptID]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Collectors_GetScriptID]
IF OBJECT_ID('[hist].[Collectors_Log_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Collectors_Log_InsertValue]

-- New Views
IF OBJECT_ID('[hist].[Collectors_Log_vw]','V') IS NOT NULL
	DROP VIEW [hist].[Collectors_Log_vw]

-- New tables
IF OBJECT_ID('hist.Collectors_Log','U') IS NOT NULL
	DROP TABLE hist.Collectors_Log
IF OBJECT_ID('hist.Collectors_StateIDs','U') IS NOT NULL
	DROP TABLE hist.Collectors_StateIDs
IF OBJECT_ID('hist.Collectors_ScriptIDs','U') IS NOT NULL
	DROP TABLE hist.Collectors_ScriptIDs

-- Create new tables
CREATE TABLE [hist].[Collectors_StateIDs] (
	[HistCollectorLogStateID]		INT IDENTITY CONSTRAINT [PK__Collectors_StateIDs__HistCollectorLogStateID] PRIMARY KEY CLUSTERED
	,[State]						VARCHAR(10)
)

CREATE TABLE [hist].[Collectors_ScriptIDs] (
	[HistCollectorLogScriptID]		INT IDENTITY CONSTRAINT [PK__Collectors_ScriptIDs__HistCollectorLogScriptID] PRIMARY KEY CLUSTERED
	,[ScriptName]					VARCHAR(500)
	,[DateCreated]					DATETIME CONSTRAINT [DF__Collectors_ScriptIDs__DateCreated] DEFAULT (GETDATE())
)

CREATE TABLE [hist].[Collectors_Log] (
	[HistLogID]						INT IDENTITY CONSTRAINT [PK__Collectors_Log__HistLogID] PRIMARY KEY CLUSTERED
	,[HistUserID]					INT CONSTRAINT [FK__Collectors_Log__HistUserID__Users_UserNames__UserID] FOREIGN KEY REFERENCES [hist].[Users_UserNames] ([UserID])
	,[HistServerID]					INT CONSTRAINT [FK__Collectors_Log__HistServerID__ServerInventory_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([HistServerID])
	,[HistCollectorLogScriptID]		INT CONSTRAINT [FK__Collectors_Log__HistCollectorLogScriptID__Collectors_ScriptIDs__HistCollectorLogScriptID] FOREIGN KEY REFERENCES [hist].[Collectors_ScriptIDs] ([HistCollectorLogScriptID])
	,[HistCollectorLogStateID]		INT CONSTRAINT [FK__Collectors_Log__HistCollectorLogStateID__Collectors_StateIDs__HistCollectorLogStateID] FOREIGN KEY REFERENCES [hist].[Collectors_StateIDs] ([HistCollectorLogStateID])
	,[LogMessage]					VARCHAR(500)
	,[LogVersion]					SMALLINT
	,[DateCreated]					DATETIME CONSTRAINT [DF__Collectors_Log__DateCreated] DEFAULT (GETDATE())
)

-- Data

INSERT INTO [hist].[Collectors_StateIDs] ([State])
VALUES ('Begin'),('Progress'),('Error'),('End')
	
-- Views
GO
/*******************************************************************************************************
**  Name:			[hist].[Collectors_Log_vw]
**  Desc:			View to assemble the Collector Log information
**  Auth:			Matt Stanford 
**  Date:			2011-02-03
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [hist].[Collectors_Log_vw]
AS

SELECT 
	sids.[ScriptName]
	,s.[ServerName]
	,u.[UserName]
	,st.[State]
	,l.[LogMessage]
	,l.[LogVersion]
	,l.[DateCreated]
FROM [hist].[Collectors_Log] l
INNER JOIN [hist].[Collectors_ScriptIDs] sids
	ON l.[HistCollectorLogScriptID] = sids.[HistCollectorLogScriptID]
INNER JOIN [hist].[Collectors_StateIDs] st
	ON l.[HistCollectorLogStateID] = st.[HistCollectorLogStateID]
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON l.[HistServerID] = s.[HistServerID]
INNER JOIN [hist].[Users_UserNames] u
	ON l.[HistUserID] = u.[UserID]
GO


-- Procedures
GO
/*******************************************************************************************************
**  Name:			[hist].[Collectors_GetScriptID]
**  Desc:			Proc to get/create the script ID for this script
**  Auth:			Matt Stanford 
**  Date:			2011-02-03
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [hist].[Collectors_GetScriptID] (
	@ScriptName				VARCHAR(500)
	,@ScriptID				INT OUTPUT
)
AS

SELECT
	@ScriptID = [HistCollectorLogScriptID]
FROM [hist].[Collectors_ScriptIDs] sids
WHERE sids.[ScriptName] = @ScriptName

IF @ScriptID IS NULL
BEGIN
	INSERT INTO [hist].[Collectors_ScriptIDs] ([ScriptName])
	VALUES (@ScriptName)
	
	SET @ScriptID = SCOPE_IDENTITY()
END


GO

/*******************************************************************************************************
**  Name:			[hist].[Collectors_Log_InsertValue]
**  Desc:			Procedure to add logging information about the collectors
**  Auth:			Matt Stanford 
**  Date:			2011-02-03
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [hist].[Collectors_Log_InsertValue] (
	@ServerName				VARCHAR(200)
	,@LoginName				NVARCHAR(50)
	,@ScriptName			VARCHAR(500)
	,@State					VARCHAR(10)
	,@LogMessage			VARCHAR(500)
	,@LogVersion			SMALLINT
	,@RetentionDays			SMALLINT = 60
)
AS
SET NOCOUNT ON

DECLARE 
	@HistServerID			INT
	,@HistUserID			INT
	,@RetentionDate			DATETIME
	,@ScriptID				INT
	,@StateID				INT

-- Get the server ID	
EXEC [hist].[ServerInventory_GetServerID] @ServerName = @ServerName, @ServerID = @HistServerID OUTPUT

-- Get the user ID
EXEC [hist].[Users_GetUserID] @UserName = @LoginName, @UserID = @HistUserID OUTPUT

-- Get the script ID
EXEC [hist].[Collectors_GetScriptID] @ScriptName = @ScriptName, @ScriptID = @ScriptID OUTPUT

-- Get the state ID
SELECT
	@StateID = st.[HistCollectorLogStateID]
FROM [hist].[Collectors_StateIDs] st
WHERE st.[State] = @State

-- Insert the row
INSERT INTO [hist].[Collectors_Log] ([HistUserID],[HistServerID],[HistCollectorLogScriptID],[HistCollectorLogStateID],[LogMessage],[LogVersion],[DateCreated])
VALUES (@HistUserID,@HistServerID,@ScriptID,@StateID,@LogMessage,@LogVersion,GETDATE())

SET @RetentionDate = DATEADD(day,-@RetentionDays,GETDATE())

-- Trim up the data
DELETE l
FROM [hist].[Collectors_Log] l
INNER JOIN [hist].[Collectors_ScriptIDs] sids
	ON l.[HistCollectorLogScriptID] = sids.[HistCollectorLogScriptID]
WHERE l.[DateCreated] < @RetentionDate
AND sids.[ScriptName] = @ScriptName
AND l.[HistServerID] = @HistServerID


GO

COMMIT TRANSACTION

PRINT N'Stamping database version 1.4.10'
EXEC sys.sp_updateextendedproperty @name=N'Version', @value=N'1.4.10'