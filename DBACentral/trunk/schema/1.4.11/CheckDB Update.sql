USE [DBACentral]

SET XACT_ABORT ON
BEGIN TRANSACTION

ALTER TABLE hist.DatabaseMaintenance_CheckDB_Errors DROP CONSTRAINT PK__DatabaseMaintenance_CheckDB_Errors__HistServerID__DatabaseID__CheckDBID
ALTER TABLE hist.DatabaseMaintenance_CheckDB_Errors DROP COLUMN CheckDBID
ALTER TABLE hist.DatabaseMaintenance_CheckDB_Errors ADD CONSTRAINT PK__DatabaseMaintenance_CheckDB_Errors__HistServerID__DatabaseID__RunID PRIMARY KEY NONCLUSTERED (HistServerID, DatabaseID, RunID)

ALTER TABLE hist.DatabaseMaintenance_CheckDB_OK ADD RunID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
ALTER TABLE hist.DatabaseMaintenance_CheckDB_OK DROP CONSTRAINT [PK__DatabaseMaintenance_CheckDB_OK__HistServerID__DatabaseID__CheckDBID]
ALTER TABLE hist.DatabaseMaintenance_CheckDB_OK DROP COLUMN CheckDBID
ALTER TABLE hist.[DatabaseMaintenance_CheckDB_OK] ADD CONSTRAINT [PK__DatabaseMaintenance_CheckDB_OK__HistServerID__DatabaseID__RunID] PRIMARY KEY NONCLUSTERED (HistServerID, DatabaseID, RunID)

COMMIT


GO

IF OBJECT_ID('[hist].[DatabaseMaintenance_InsertCheckDBResults]') IS NOT NULL
	DROP PROCEDURE [hist].[DatabaseMaintenance_InsertCheckDBResults]

GO
/*

This version of the proc is where I begin to phase out the @CheckDBID, which is currently (or was) a part 
of the primary keys of the history tables.

*/


CREATE PROCEDURE [hist].[DatabaseMaintenance_InsertCheckDBResults]
(
	@ServerName			SYSNAME
	,@DatabaseName		SYSNAME
	,@CheckDBID			BIGINT = NULL -- No longer used, left for compatibility
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
	USING (SELECT @HistServerID, @DatabaseID, @RunID) AS s (HistServerID, DatabaseID, RunID)
	ON s.[HistServerID] = t.[HistServerID]
	AND s.[DatabaseID] = t.[DatabaseID]
	AND s.[RunID] = t.[RunID]
	WHEN NOT MATCHED THEN
	INSERT ([HistServerID],[DatabaseID],[RunID], [DateCreated])
	VALUES (@HistServerID,@DatabaseID,@RunID,@DateCreated);
END
ELSE
BEGIN
	MERGE INTO [hist].[DatabaseMaintenance_CheckDB_Errors] AS t
	USING (SELECT @HistServerID, @DatabaseID, @RunID) AS s (HistServerID, DatabaseID, RunID)
	ON s.[HistServerID] = t.[HistServerID]
	AND s.[DatabaseID] = t.[DatabaseID]
	AND s.[RunID] = t.[RunID]
	WHEN NOT MATCHED THEN
	INSERT ([HistServerID],[DatabaseID],[RunID],[DateCreated],[Error],[Level],[State],[MessageText],[RepairLevel],[Status],[ObjectID],[IndexID]
	,[PartitionID],[AllocUnitID],[File],[Page],[Slot],[RefFile],[RefPage],[RefSlot],[Allocation])
	VALUES (@HistServerID,@DatabaseID,@RunID,@DateCreated,@Error,@Level,@State,@MessageText,@RepairLevel,@Status,@ObjectID,@IndexID
	,@PartitionID,@AllocUnitID,@File,@Page,@Slot,@RefFile,@RefPage,@RefSlot,@Allocation);
END


GO


