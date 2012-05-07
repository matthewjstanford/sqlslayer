IF OBJECT_ID('hist.SQLRestarts_RunIDs') IS NULL
BEGIN
	CREATE TABLE [hist].[SQLRestarts_RunIDs]
		(
			[RunID]			INT
			,[DateCreated]	SMALLDATETIME
		)
	ALTER TABLE [hist].[SQLRestarts_RunIDs] ADD CONSTRAINT [DF_SQLRestarts_RunIDs_DateCreated] DEFAULT GETDATE() FOR [DateCreated]
END
