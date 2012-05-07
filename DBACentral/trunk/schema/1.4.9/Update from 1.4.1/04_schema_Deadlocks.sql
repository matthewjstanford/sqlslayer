USE DBACentral
GO
PRINT('Running cleanup in case this was a partial run')
IF OBJECT_ID('[hist].[Deadlock_ProcessList_vw]','V') IS NOT NULL
	DROP VIEW [hist].[Deadlock_ProcessList_vw]
IF OBJECT_ID('[hist].[Deadlock_Deadlocks_vw]','V') IS NOT NULL
	DROP VIEW [hist].[Deadlock_Deadlocks_vw]
IF OBJECT_ID('[hist].[Deadlock_ResourceList_vw]','V') IS NOT NULL
	DROP VIEW [hist].[Deadlock_ResourceList_vw]

IF OBJECT_ID('[hist].[Deadlock_Process_ExecutionStack_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Deadlock_Process_ExecutionStack_InsertValue]
IF OBJECT_ID('[hist].[Deadlock_GetDeadlockInfo]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Deadlock_GetDeadlockInfo]
IF OBJECT_ID('[hist].[Deadlock_ProcessList_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Deadlock_ProcessList_InsertValue]
IF OBJECT_ID('[hist].[Deadlock_NewDeadlock_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Deadlock_NewDeadlock_InsertValue]
IF OBJECT_ID('[hist].[Deadlock_ResourceList_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Deadlock_ResourceList_InsertValue] 
IF OBJECT_ID('[hist].[Deadlock_ResourceOwner_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Deadlock_ResourceOwner_InsertValue] 
IF OBJECT_ID('[hist].[Deadlock_ResourceWaiter_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [hist].[Deadlock_ResourceWaiter_InsertValue] 

IF OBJECT_ID('[hist].[Deadlock_Process_ExecutionStack]','U') IS NOT NULL
	DROP TABLE [hist].[Deadlock_Process_ExecutionStack]
IF OBJECT_ID('[hist].[Deadlock_ResourceOwners]','U') IS NOT NULL
	DROP TABLE [hist].[Deadlock_ResourceOwners]
IF OBJECT_ID('[hist].[Deadlock_ResourceWaiters]','U') IS NOT NULL
	DROP TABLE [hist].[Deadlock_ResourceWaiters]
IF OBJECT_ID('[hist].[Deadlock_ResourceList]','U') IS NOT NULL
	DROP TABLE [hist].[Deadlock_ResourceList]
IF OBJECT_ID('[hist].[Deadlock_ProcessList]','U') IS NOT NULL
	DROP TABLE [hist].[Deadlock_ProcessList]
IF OBJECT_ID('[hist].[Deadlock_Deadlocks]','U') IS NOT NULL
	DROP TABLE [hist].[Deadlock_Deadlocks]
IF OBJECT_ID('[ref].[SQLServer_RunStatus]','U') IS NOT NULL
	DROP TABLE [ref].[SQLServer_RunStatus]
IF OBJECT_ID('[ref].[SQLServer_IsolationLevels]','U') IS NOT NULL
	DROP TABLE [ref].[SQLServer_IsolationLevels]
IF OBJECT_ID('[ref].[SQLServer_LockModes]','U') IS NOT NULL
	DROP TABLE [ref].[SQLServer_LockModes]
GO
PRINT('Creating deadlock and supporting tables')
CREATE TABLE [ref].[SQLServer_IsolationLevels] (
	[RefIsolationLevelID]			INT IDENTITY CONSTRAINT [PK__SQLServer_IsolationLevels__RefIsolationLevelID] PRIMARY KEY CLUSTERED
	,[IsolationLevel]				VARCHAR(50)
	,[DateCreated]					DATETIME CONSTRAINT [DF__SQLServer_IsolationLevels__DateCreated] DEFAULT GETDATE()
)

CREATE TABLE [ref].[SQLServer_RunStatus] (
	[RefRunStatusID]				INT IDENTITY CONSTRAINT [PK__SQLServer_RunStatus__RefRunStatusID] PRIMARY KEY CLUSTERED
	,[RunStatus]					VARCHAR(50)
	,[DateCreated]					DATETIME CONSTRAINT [DF__SQLServer_RunStatus__DateCreated] DEFAULT GETDATE()
)

CREATE TABLE [ref].[SQLServer_LockModes] (
	[RefLockModeID]					INT IDENTITY CONSTRAINT [PK__SQLServer_LockModes__RefLockModeID] PRIMARY KEY CLUSTERED
	,[LockMode]						VARCHAR(10)
	,[LockName]						VARCHAR(50)
	,[Description]					VARCHAR(1000)
	,[DateCreated]					DATETIME CONSTRAINT [DF__SQLServer_LockModes__DateCreated] DEFAULT GETDATE()
)

CREATE TABLE [hist].[Deadlock_Deadlocks] (
	[HistDeadlockID]				INT IDENTITY CONSTRAINT [PK__Deadlock_Deadlocks__HistDeadlockID] PRIMARY KEY CLUSTERED
	,[HistServerID]					INT CONSTRAINT [FK__Deadlock_Deadlocks__HistServerID__ServerInventory_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs]([HistServerID])
	,[DeadlockSPID]					VARCHAR(11)
	,[VictimProcess]				VARCHAR(20)
	,[DeadlockDate]					DATETIME
	,[SampleDate]					DATETIME CONSTRAINT [DF__Deadlock_Deadlocks__SampleDate] DEFAULT GETDATE()
)

CREATE TABLE [hist].[Deadlock_ProcessList] (
	[HistDeadlockProcessID]			INT IDENTITY CONSTRAINT [PK__Deadlock_ProcessList__HistDeadlockProcessID] PRIMARY KEY CLUSTERED
	,[HistDeadlockID]				INT CONSTRAINT [FK__Deadlock_ProcessList__HistDeadlockID__Deadlock_Deadlocks__HistDeadlockID] FOREIGN KEY REFERENCES [hist].[Deadlock_Deadlocks]([HistDeadlockID]) ON DELETE CASCADE
	,[processid]					VARCHAR(20)
	,[clientapp]					VARCHAR(128)
	,[currentdb]					INT
	,[hostnameHistServerID]			INT CONSTRAINT [FK__Deadlock_ProcessList__HistServerID__ServerInventory_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs]([HistServerID])
	,[hostpid]						SMALLINT
	,[RefIsolationLevelID]			INT CONSTRAINT [FK__Deadlock_ProcessList__RefIsolationLevelID__SQLServer_IsolationLevels__RefIsolationLevelID] FOREIGN KEY REFERENCES [ref].[SQLServer_IsolationLevels] ([RefIsolationLevelID])
	,[kpid]							SMALLINT
	,[lastbatchstarted]				DATETIME
	,[lastbatchcompleted]			DATETIME
	,[lasttranstarted]				DATETIME
	,[modeRefLockModeID]			INT CONSTRAINT [FK__Deadlock_ProcessList__modeRefLockModeID__SQLServer_LockModes__RefLockModeID] FOREIGN KEY REFERENCES [ref].[SQLServer_LockModes] ([RefLockModeID])
	,[loginnameHistUserID]			INT CONSTRAINT [FK__Deadlock_ProcessList__loginnameHistUserID__Users_UserNames__HistUserID] FOREIGN KEY REFERENCES [hist].[Users_UserNames] ([UserID])
	,[priority]						SMALLINT
	,[taskpriority]					SMALLINT
	,[sbid]							SMALLINT
	,[schedulerid]					TINYINT
	,[spid]							SMALLINT
	,[RefRunStatusID]				INT CONSTRAINT [FK__Deadlock_ProcessList__RefRunStatusID__SQLServer_RunStatus__RefRunStatusID] FOREIGN KEY REFERENCES [ref].[SQLServer_RunStatus] ([RefRunStatusID])
	,[transactionname]				VARCHAR(128)
	,[transcount]					SMALLINT
	,[waitresource]					VARCHAR(128)
	,[waittime]						INT
	,[DateCreated]					DATETIME CONSTRAINT [DF__Deadlock_ProcessList__DateCreated] DEFAULT GETDATE()
)

CREATE TABLE [hist].[Deadlock_Process_ExecutionStack] (
	[HistDeadlockExecutionStackID]	INT IDENTITY CONSTRAINT [PK__Deadlock_Process_ExecutionStack__HistDeadlockExecutionStackID] PRIMARY KEY CLUSTERED
	,[HistDeadlockProcessID]		INT CONSTRAINT [FK__Deadlock_Process_ExecutionStack__HistDeadlockProcessID__Deadlock_ProcessList__HistDeadlockProcessID] FOREIGN KEY REFERENCES [hist].[Deadlock_ProcessList] ([HistDeadlockProcessID])
	,[Sequence]						SMALLINT
	,[Stack]						NVARCHAR(4000)
)

CREATE TABLE [hist].[Deadlock_ResourceList] (
	[HistDeadlockResourceID]		INT IDENTITY CONSTRAINT [PK__Deadlock_ResourceList__HistDeadlockResourceID] PRIMARY KEY CLUSTERED
	,[HistDeadlockID]				INT CONSTRAINT [FK__Deadlock_ResourceList__HistDeadlockID__Deadlock_Deadlocks__HistDeadlockID] FOREIGN KEY REFERENCES [hist].[Deadlock_Deadlocks]([HistDeadlockID]) ON DELETE CASCADE
	,[id]							VARCHAR(20)
	,[locktype]						VARCHAR(10)
	,[objectnameHistTableID]		INT CONSTRAINT [FK__Deadlock_ResourceList__objectnameHistTableID__ServerInventory_SQL_TableIDs__TableID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_TableIDs]([TableID])
	,[dbnameHistDatabaseID]			INT CONSTRAINT [FK__Deadlock_ResourceList__dbnameHistDatabaseID__ServerInventory_SQL_DatabaseIDs__DatabaseID] FOREIGN KEY REFERENCES [hist].[ServerInventory_SQL_DatabaseIDs]([DatabaseID])
	,[indexname]					NVARCHAR(128)
	,[hobtid]						VARCHAR(50)
	,[modeRefLockModeID]			INT CONSTRAINT [FK__Deadlock_ResourceList__modeRefLockModeID__SQLServer_LockModes__RefLockModeID] FOREIGN KEY REFERENCES [ref].[SQLServer_LockModes] ([RefLockModeID])
	,[associatedObjectID]			VARCHAR(50)
	,[dbid]							SMALLINT
	,[fileid]						SMALLINT
	,[pageid]						INT
	,[DateCreated]					DATETIME CONSTRAINT [DF__Deadlock_ResourceList__DateCreated] DEFAULT GETDATE()
)

CREATE TABLE [hist].[Deadlock_ResourceOwners] (
	[HistDeadlockResourceID]		INT CONSTRAINT [FK__Deadlock_ResourceOwners__HistDeadlockResourceID__Deadlock_ResourceList__HistDeadlockResourceID] FOREIGN KEY REFERENCES [hist].[Deadlock_ResourceList] ([HistDeadlockResourceID]) --ON DELETE CASCADE
	,[HistDeadlockProcessID]		INT CONSTRAINT [FK__Deadlock_ResourceOwners__HistDeadlockProcessID__Deadlock_ProcessList__HistDeadlockProcessID] FOREIGN KEY REFERENCES [hist].[Deadlock_ProcessList] ([HistDeadlockProcessID]) --ON DELETE CASCADE
	,[modeRefLockModeID]			INT CONSTRAINT [FK__Deadlock_ResourceOwners__modeRefLockModeID__SQLServer_LockModes__RefLockModeID] FOREIGN KEY REFERENCES [ref].[SQLServer_LockModes] ([RefLockModeID])

)

CREATE TABLE [hist].[Deadlock_ResourceWaiters] (
	[HistDeadlockResourceID]		INT CONSTRAINT [FK__Deadlock_ResourceWaiters__HistDeadlockResourceID__Deadlock_ResourceList__HistDeadlockResourceID] FOREIGN KEY REFERENCES [hist].[Deadlock_ResourceList] ([HistDeadlockResourceID]) --ON DELETE CASCADE
	,[HistDeadlockProcessID]		INT CONSTRAINT [FK__Deadlock_ResourceWaiters__HistDeadlockProcessID__Deadlock_ProcessList__HistDeadlockProcessID] FOREIGN KEY REFERENCES [hist].[Deadlock_ProcessList] ([HistDeadlockProcessID]) --ON DELETE CASCADE
	,[modeRefLockModeID]			INT CONSTRAINT [FK__Deadlock_ResourceWaiters__modeRefLockModeID__SQLServer_LockModes__RefLockModeID] FOREIGN KEY REFERENCES [ref].[SQLServer_LockModes] ([RefLockModeID])
	,[requestType]					VARCHAR(10)
)

PRINT('Creating indexes')

CREATE UNIQUE NONCLUSTERED INDEX [UIX__Deadlock_ProcessList__HistDeadlockID__processid] ON [hist].[Deadlock_ProcessList] ([HistDeadlockID], [processid])
CREATE UNIQUE NONCLUSTERED INDEX [UIX__Deadlock_ResourceOwners__HistDeadlockResourceID__HistDeadlockProcessID] ON [hist].[Deadlock_ResourceOwners]([HistDeadlockResourceID],[HistDeadlockProcessID])
CREATE UNIQUE NONCLUSTERED INDEX [UIX__Deadlock_ResourceWaiters__HistDeadlockResourceID__HistDeadlockProcessID] ON [hist].[Deadlock_ResourceWaiters]([HistDeadlockResourceID],[HistDeadlockProcessID])
CREATE UNIQUE NONCLUSTERED INDEX [UIX__Deadlock_Deadlocks__HistServerID__DeadlockSPID__DeadlockDate] ON [hist].[Deadlock_Deadlocks] ([HistServerID],[DeadlockSPID],[DeadlockDate])
CREATE UNIQUE NONCLUSTERED INDEX [UIX__Deadlock_Process_ExecutionStack__HistDeadlockProcessID__Sequence] ON [hist].[Deadlock_Process_ExecutionStack]([HistDeadlockProcessID],[sequence])

GO
PRINT('Creating objects')
GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_NewDeadlock_InsertValue]
**	Desc:			Procedure to inset new deadlocks into schema
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE PROCEDURE [hist].[Deadlock_NewDeadlock_InsertValue] (
	@ServerName						VARCHAR(200)
	,@DeadlockSPID					VARCHAR(11)
	,@DeadlockDate					DATETIME
	,@VictimProcess					VARCHAR(20)
	,@HistDeadlockID				INT OUTPUT
)
AS

SET NOCOUNT ON

DECLARE
	@HistServerID			INT

EXEC [hist].[ServerInventory_GetServerID] @ServerName, @HistServerID OUTPUT

SELECT 
	@HistDeadlockID = [HistDeadlockID]
FROM [hist].[Deadlock_Deadlocks] 
WHERE [HistServerID] = @HistServerID 
AND [DeadlockSPID] = @DeadlockSPID 
AND [DeadlockDate] = @DeadlockDate

IF (@HistDeadlockID IS NULL)
BEGIN
	INSERT INTO [hist].[Deadlock_Deadlocks] ([HistServerID], [DeadlockSPID], [DeadlockDate], [VictimProcess])
	VALUES (@HistServerID, @DeadlockSPID, @DeadlockDate, @VictimProcess)
	
	SET @HistDeadlockID = SCOPE_IDENTITY()
END

GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_ProcessList_InsertValue]
**	Desc:			Procedure to save process info for each deadlock
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE PROCEDURE [hist].[Deadlock_ProcessList_InsertValue] (
	@HistDeadlockID					INT
	,@clientapp						VARCHAR(128)	= NULL
	,@currentdb						INT				= NULL
	,@hostname						VARCHAR(200)	= NULL
	,@hostpid						SMALLINT		= NULL
	,@isolationlevel				VARCHAR(50)		= NULL
	,@kpid							SMALLINT		= NULL
	,@lastbatchstarted				DATETIME		= NULL
	,@lastbatchcompleted			DATETIME		= NULL
	,@lasttranstarted				DATETIME		= NULL
	,@lockmode						VARCHAR(10)		= NULL
	,@loginname						NVARCHAR(128)	= NULL
	,@priority						SMALLINT		= NULL
	,@processid						VARCHAR(20)
	,@taskpriority					SMALLINT		= NULL
	,@sbid							SMALLINT		= NULL
	,@schedulerid					TINYINT			= NULL
	,@spid							SMALLINT		= NULL
	,@runstatus						VARCHAR(50)		= NULL
	,@transactionname				VARCHAR(128)	= NULL
	,@transcount					SMALLINT		= NULL
	,@waitresource					VARCHAR(128)	= NULL
	,@waittime						INT				= NULL
)
AS

DECLARE
	@hostnameHistServerID		INT
	,@loginnameHistUserID		INT
	,@RefIsolationLevelID		INT
	,@RefRunStatusID			INT
	,@RefLockModeID				INT
	
SET @loginname = ISNULL(@loginname,'')
SET @hostname = ISNULL(@hostname,'')

EXEC [hist].[Users_GetUserID] @loginname, @loginnameHistUserID OUTPUT
EXEC [hist].[ServerInventory_GetServerID] @hostname, @hostnameHistServerID OUTPUT

SELECT
	@RefIsolationLevelID = [RefIsolationLevelID]
FROM [ref].[SQLServer_IsolationLevels]
WHERE [IsolationLevel] = @isolationlevel

SELECT
	@RefRunStatusID = [RefRunStatusID]
FROM [ref].[SQLServer_RunStatus]
WHERE [RunStatus] = @runstatus

SELECT 
	@RefLockModeID = [RefLockModeID]
FROM [ref].[SQLServer_LockModes]
WHERE [LockMode] = @lockmode

IF NOT EXISTS (SELECT * FROM [hist].[Deadlock_ProcessList] WHERE [HistDeadlockID] = @HistDeadlockID AND [processid] = @processid)
BEGIN
	INSERT INTO [hist].[Deadlock_ProcessList] ([HistDeadlockID],[clientapp],[currentdb],[hostnameHistServerID],[hostpid],[RefIsolationLevelID],[kpid]
		,[lastbatchstarted],[lastbatchcompleted],[lasttranstarted],[modeRefLockModeID],[loginnameHistUserID],[priority]
		,[processid],[taskpriority],[sbid],[schedulerid],[spid],[RefRunStatusID],[transactionname],[transcount],[waitresource],[waittime])
	VALUES (@HistDeadlockID, @clientapp,@currentdb,@hostnameHistServerID,@hostpid,@RefIsolationLevelID,@kpid
		,@lastbatchstarted,@lastbatchcompleted,@lasttranstarted,@RefLockModeID,@loginnameHistUserID,@priority
		,@processid,@taskpriority,@sbid,@schedulerid,@spid,@RefRunStatusID,@transactionname,@transcount,@waitresource,@waittime)
END

GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_ResourceList_InsertValue]
**	Desc:			Procedure to save resource info for each deadlock
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE PROCEDURE [hist].[Deadlock_ResourceList_InsertValue] (
	@HistDeadlockID					INT
	,@id							VARCHAR(20)
	,@locktype						VARCHAR(10)		= NULL
	,@objectname					VARCHAR(500)	= NULL
	,@indexname						VARCHAR(128)	= NULL
	,@hobtid						VARCHAR(50)		= NULL
	,@mode							VARCHAR(10)		= NULL
	,@associatedObjectID			VARCHAR(50)		= NULL
	,@dbid							SMALLINT		= NULL
	,@fileid						SMALLINT		= NULL
	,@pageid						INT				= NULL
)
AS 

DECLARE
	@ServerName						VARCHAR(200)
	,@HistTableID					INT
	,@HistDatabaseID				INT
	,@vDBName						VARCHAR(128)
	,@vSchemaName					VARCHAR(128)
	,@vObjectName					VARCHAR(128)
	,@firstDot						INT
	,@secondDot						INT
	,@RefLockModeID					INT

SELECT 
	@RefLockModeID = [RefLockModeID]
FROM [ref].[SQLServer_LockModes]
WHERE [LockMode] = @mode

IF @locktype = 'dblock'
BEGIN
	-- In here, @objectname is the database name
	SET @vDBName = @objectname
END 
ELSE
BEGIN
	SET @firstDot = CHARINDEX('.',@objectname)
	SET @secondDot = CHARINDEX('.',@objectname,@firstDot + 1)
		
	IF (@firstDot > 0 AND @secondDot > 0)
	BEGIN
		SET @vDBName = LEFT(@objectname,@firstDot - 1)
		SET @vSchemaName = SUBSTRING(@objectName,@firstdot + 1, @seconddot - @firstdot - 1)
		SET @vObjectName = RIGHT(@objectname,LEN(@objectname) - @seconddot)

		EXEC [hist].[ServerInventory_SQL_GetTableID] @vObjectName, @vSchemaName, @HistTableID OUTPUT
	END
END

-- Get database id
EXEC [hist].[ServerInventory_SQL_GetDatabaseID] @vDBName, @HistDatabaseID OUTPUT

IF NOT EXISTS (SELECT * FROM [hist].[Deadlock_ResourceList] WHERE [HistDeadlockID] = @HistDeadlockID AND [id] = @id)
BEGIN
	INSERT INTO [hist].[Deadlock_ResourceList] ([HistDeadlockID], [id], [locktype], [objectnameHistTableID], [dbnameHistDatabaseID], [indexname],
		[hobtid],[modeRefLockModeID],[associatedObjectID],[dbid],[fileid],[pageid])
	VALUES (@HistDeadlockID, @id, @locktype, @HistTableID, @HistDatabaseID, @indexname,
		@hobtid, @RefLockModeID, @associatedObjectID, @dbid, @fileid, @pageid)
END

GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_Process_ExecutionStack_InsertValue]
**	Desc:			Procedure to save execution stack information for each deadlock process
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE PROCEDURE [hist].[Deadlock_Process_ExecutionStack_InsertValue] (
	@HistDeadlockID					INT
	,@processid						VARCHAR(20)
	,@Stack							NVARCHAR(4000)
	,@sequence						SMALLINT
)
AS

DECLARE
	@HistDeadlockProcessID			INT
	
-- Lookup process id
SELECT
	@HistDeadlockProcessID = [HistDeadlockProcessID]
FROM [hist].[Deadlock_ProcessList]
WHERE [HistDeadlockID] = @HistDeadlockID
AND [processid] = @processid

IF @HistDeadlockProcessID IS NOT NULL AND @Stack NOT IN ('inputbuf','sp_executesql     ','EXECUTE sp_executeSQL @SQL     ')
BEGIN
	IF NOT EXISTS (SELECT * FROM [hist].[Deadlock_Process_ExecutionStack] WHERE [HistDeadlockProcessID] = @HistDeadlockProcessID AND [Sequence] = @sequence)
	BEGIN
		INSERT INTO [hist].[Deadlock_Process_ExecutionStack] ([HistDeadlockProcessID],[Stack],[sequence])
		VALUES (@HistDeadlockProcessID,@Stack,@sequence)
	END
END

GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_ResourceOwner_InsertValue]
**	Desc:			Procedure to save resource owner information for each deadlock
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE PROCEDURE [hist].[Deadlock_ResourceOwner_InsertValue] (
	@HistDeadlockID					INT
	,@ResourceID					VARCHAR(20)
	,@ProcessID						VARCHAR(20)
	,@mode							VARCHAR(10)		= NULL
)
AS

DECLARE
	@HistDeadlockResourceID			INT
	,@HistDeadlockProcessID			INT
	,@RefLockModeID					INT
	
SELECT
	@HistDeadlockProcessID = [HistDeadlockProcessID]
FROM [hist].[Deadlock_ProcessList]
WHERE [HistDeadlockID] = @HistDeadlockID
AND [processid] = @ProcessID

SELECT
	@HistDeadlockResourceID = [HistDeadlockResourceID] 
FROM [hist].[Deadlock_ResourceList]
WHERE [HistDeadlockID] = @HistDeadlockID
AND [id] = @ResourceID

SELECT 
	@RefLockModeID = [RefLockModeID]
FROM [ref].[SQLServer_LockModes]
WHERE [LockMode] = @mode

IF NOT EXISTS (SELECT * FROM [hist].[Deadlock_ResourceOwners] WHERE [HistDeadlockProcessID] = @HistDeadlockProcessID 
		AND [HistDeadlockResourceID] = @HistDeadlockResourceID)
BEGIN
	INSERT INTO [hist].[Deadlock_ResourceOwners] ([HistDeadlockProcessID], [HistDeadlockResourceID], [modeRefLockModeID])
	VALUES (@HistDeadlockProcessID, @HistDeadlockResourceID, @RefLockModeID)
END

GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_ResourceWaiter_InsertValue]
**	Desc:			Procedure to save waiter information for each deadlock
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE PROCEDURE [hist].[Deadlock_ResourceWaiter_InsertValue] (
	@HistDeadlockID					INT
	,@ResourceID					VARCHAR(20)
	,@ProcessID						VARCHAR(20)
	,@mode							VARCHAR(10)		= NULL
	,@requestType					VARCHAR(10)		= NULL
)
AS

DECLARE
	@HistDeadlockResourceID			INT
	,@HistDeadlockProcessID			INT
	,@RefLockModeID					INT
	
SELECT
	@HistDeadlockProcessID = [HistDeadlockProcessID]
FROM [hist].[Deadlock_ProcessList]
WHERE [HistDeadlockID] = @HistDeadlockID
AND [processid] = @ProcessID

SELECT
	@HistDeadlockResourceID = [HistDeadlockResourceID] 
FROM [hist].[Deadlock_ResourceList]
WHERE [HistDeadlockID] = @HistDeadlockID
AND [id] = @ResourceID

SELECT 
	@RefLockModeID = [RefLockModeID]
FROM [ref].[SQLServer_LockModes]
WHERE [LockMode] = @mode

IF NOT EXISTS (SELECT * FROM [hist].[Deadlock_ResourceWaiters] WHERE [HistDeadlockProcessID] = @HistDeadlockProcessID 
		AND [HistDeadlockResourceID] = @HistDeadlockResourceID)
BEGIN
	INSERT INTO [hist].[Deadlock_ResourceWaiters] ([HistDeadlockProcessID], [HistDeadlockResourceID], [modeRefLockModeID], [requestType])
	VALUES (@HistDeadlockProcessID, @HistDeadlockResourceID, @RefLockModeID, @requestType)
END

GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_Deadlocks_vw]
**	Desc:			View to assemble basic deadlock information
					Note that each deadlock is identified uniquely by the Server, SPID and DATE combination
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE VIEW [hist].[Deadlock_Deadlocks_vw]
AS

SELECT [HistDeadlockID]
      ,s.[ServerName]
      ,[DeadlockSPID]
      ,[VictimProcess]
      ,[DeadlockDate]
      ,[SampleDate]
FROM [hist].[Deadlock_Deadlocks] d
INNER JOIN [hist].[ServerInventory_ServerIDs] s
	ON d.[HistServerID] = s.[HistServerID]

	
GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_ProcessList_vw]
**	Desc:			View to assemble the process list information for each deadlock
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE VIEW [hist].[Deadlock_ProcessList_vw]
AS
SELECT 
	dl.[HistDeadlockID]				AS [HistDeadlockID]
	,p.[HistDeadlockProcessID]		AS [HistDeadlockProcessID]
	,dl_sn.[ServerName]				AS [Deadlock_ServerName]
	,dl.[DeadlockSPID]				AS [Deadlock_SPID]
	,dl.[DeadlockDate]				AS [DeadlockDate]
	,CASE WHEN dl.[VictimProcess] = p.[processid] THEN 1 
		ELSE 0
	END								AS [Was_Deadlock_Victim]
	,p.[processid]					AS [processid]
	,p.[clientapp]					AS [clientapp]
	,p.[currentdb]					AS [DBID]
	,p_sn.[ServerName]				AS [Process_ServerName]
	,p.[hostpid]					AS [hostpid]
	,iso.[IsolationLevel]			AS [IsolationLevel]
	,p.[kpid]						AS [kpid]
	,p.[lastbatchstarted]
	,p.[lastbatchcompleted]
	,p.[lasttranstarted]
	,lm.[LockMode]
	,lm.[LockName]					AS [LockName]
	,lm.[Description]				AS [LockDesc]
	,u.[UserName]					AS [loginname]
	,p.[priority]
	,p.[taskpriority]
	,p.[sbid]
	,p.[schedulerid]
	,p.[spid]
	,stat.[RunStatus]				AS [status]
	,p.[transactionname]
	,p.[transcount]
	,p.[waitresource]
	,p.[waittime]
	,p.[DateCreated]
FROM [hist].[Deadlock_Deadlocks] dl
INNER JOIN [hist].[Deadlock_ProcessList] p
	ON dl.[HistDeadlockID] = p.[HistDeadlockID]
INNER JOIN [hist].[ServerInventory_ServerIDs] dl_sn
	ON dl.[HistServerID] = dl_sn.[HistServerID]
INNER JOIN [hist].[ServerInventory_ServerIDs] p_sn
	ON p.[hostnameHistServerID] = p_sn.[HistServerID]
LEFT OUTER JOIN [ref].[SQLServer_IsolationLevels] iso
	ON p.[RefIsolationLevelID] = iso.[RefIsolationLevelID]
LEFT OUTER JOIN [hist].[Users_UserNames] u
	ON p.[loginnameHistUserID] = u.[UserID]
LEFT OUTER JOIN [ref].[SQLServer_RunStatus] stat
	ON p.[RefRunStatusID] = stat.[RefRunStatusID]
LEFT OUTER JOIN [ref].[SQLServer_LockModes] lm
	ON p.[modeRefLockModeID] = lm.[RefLockModeID]
	
GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_ResourceList_vw]
**	Desc:			View to assemble the resource list information for each deadlock
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE VIEW [hist].[Deadlock_ResourceList_vw]
AS
SELECT 
	rl.[HistDeadlockResourceID]
	,rl.[HistDeadlockID]
	,rl.[id]
	,rl.[locktype]
	,db.[DBName]
	,tbl.[SchemaName]
	,tbl.[TableName]
	,rl.[indexname]
	,rl.[hobtid]
	,lm.[LockMode]
	,lm.[LockName]					AS [LockName]
	,lm.[Description]				AS [LockDesc]
	,rl.[associatedObjectID]
	,rl.[dbid]
	,rl.[fileid]
	,rl.[pageid]
	,rl.[DateCreated]
FROM [hist].[Deadlock_ResourceList] rl
LEFT OUTER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] db
	ON rl.[dbnameHistDatabaseID] = db.[DatabaseID]
LEFT OUTER JOIN [hist].[ServerInventory_SQL_TableIDs] tbl
	ON rl.[objectnameHistTableID] = tbl.[TableID]
INNER JOIN [ref].[SQLServer_LockModes] lm
	ON rl.[modeRefLockModeID] = lm.[RefLockModeID]
GO
/*******************************************************************************************************
**	Name:			[hist].[Deadlock_GetDeadlockInfo]
**	Desc:			Procedure to gather all of the deadlock info and output it all at once
**	Auth:			Matt Stanford
**	Date:			2010.12.20
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
**  
********************************************************************************************************/
CREATE PROCEDURE [hist].[Deadlock_GetDeadlockInfo] (
	@HistDeadlockID					INT
)
AS

SELECT 
	'Deadlock'						AS [WhatIsThis]
	,*
FROM [hist].[Deadlock_Deadlocks_vw] 
WHERE [HistDeadlockID] = @HistDeadlockID

SELECT
	'ProcessList'					AS [WhatIsThis]
	,*
FROM [hist].[Deadlock_ProcessList_vw]
WHERE [HistDeadlockID] = @HistDeadlockID

SELECT
	'ExecutionStack'				AS [WhatIsThis]
	,p.[processid]
	,st.[Sequence]
	,st.[Stack]
FROM [hist].[Deadlock_Process_ExecutionStack] st
INNER JOIN [hist].[Deadlock_ProcessList_vw] p
	ON st.[HistDeadlockProcessID] = p.[HistDeadlockProcessID]
WHERE p.[HistDeadlockID] = @HistDeadlockID
ORDER BY p.[processid], st.[Sequence]

SELECT
	'ResourceList'					AS [WhatIsThis]
	,*
FROM [hist].[Deadlock_ResourceList_vw]
WHERE [HistDeadlockID] = @HistDeadlockID

SELECT
	'ResourceOwners'				AS [WhatIsThis]
	,r.[id]							AS [ResourceID]
	,p.[processid]
	,lm.[LockMode]
	,lm.[LockName]
	,ISNULL(db.[DBName],'') + ISNULL('.' + tbl.[SchemaName],'') + ISNULL('.' + tbl.[TableName],'') AS [ObjectName]
	,r.[IndexName]					AS [IndexName]
FROM [hist].[Deadlock_ResourceOwners] ro
INNER JOIN [hist].[Deadlock_ResourceList] r
	ON ro.[HistDeadlockResourceID] = r.[HistDeadlockResourceID]
INNER JOIN [hist].[Deadlock_ProcessList] p
	ON ro.[HistDeadlockProcessID] = p.[HistDeadlockProcessID]
INNER JOIN [ref].[SQLServer_LockModes] lm
	ON ro.[modeRefLockModeID] = lm.[RefLockModeID]
LEFT OUTER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] db
	ON r.[dbnameHistDatabaseID] = db.[DatabaseID]
LEFT OUTER JOIN [hist].[ServerInventory_SQL_TableIDs] tbl
	ON r.[objectnameHistTableID] = tbl.[TableID]
WHERE r.[HistDeadlockID] = @HistDeadlockID

SELECT
	'ResourceWaiters'				AS [WhatIsThis]
	,r.[id]							AS [ResourceID]
	,p.[processid]
	,rw.[requestType]
	,lm.[LockMode]
	,lm.[LockName]
	,ISNULL(db.[DBName],'') + ISNULL('.' + tbl.[SchemaName],'') + ISNULL('.' + tbl.[TableName],'') AS [ObjectName]
	,r.[IndexName]					AS [IndexName]
FROM [hist].[Deadlock_ResourceWaiters] rw
INNER JOIN [hist].[Deadlock_ResourceList] r
	ON rw.[HistDeadlockResourceID] = r.[HistDeadlockResourceID]
INNER JOIN [hist].[Deadlock_ProcessList] p
	ON rw.[HistDeadlockProcessID] = p.[HistDeadlockProcessID]
INNER JOIN [ref].[SQLServer_LockModes] lm
	ON rw.[modeRefLockModeID] = lm.[RefLockModeID]
LEFT OUTER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] db
	ON r.[dbnameHistDatabaseID] = db.[DatabaseID]
LEFT OUTER JOIN [hist].[ServerInventory_SQL_TableIDs] tbl
	ON r.[objectnameHistTableID] = tbl.[TableID]
WHERE r.[HistDeadlockID] = @HistDeadlockID
GO
PRINT N'Stamping database version 1.5.0'
EXEC sys.sp_updateextendedproperty @name=N'Version', @value=N'1.5.0'