IF OBJECT_ID('audit.ConnectionCounts') IS NULL
BEGIN
	CREATE TABLE [audit].[ConnectionCounts]
		(
			[HistServerID]	INT
			,[RunID]		INT
			,[CounterValue]	INT
		)
END

IF OBJECT_ID('audit.ConnectionCounts_RunIDs') IS NULL
BEGIN
	CREATE TABLE [audit].[ConnectionCounts_RunIDs]
		(
			[RunID]			INT
			,[DateCreated]	SMALLDATETIME
		)
	ALTER TABLE [audit].[ConnectionCounts_RunIDs] ADD CONSTRAINT [DF_ConnectionCounts_RunIDs_DateCreated] DEFAULT GETDATE() FOR [DateCreated]
END