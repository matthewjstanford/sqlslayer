IF OBJECT_ID('hist.SQLRestarts_History','U') IS NULL
BEGIN
	CREATE TABLE [hist].[SQLRestarts_History]
	(
		[SQLRestartHistoryID]	INT IDENTITY(1,1) NOT NULL
		,[HistServerID]			INT NOT NULL CONSTRAINT [FK__SQLRestarts_History__HistServerID__ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ([HistServerID])
		,[TimeOfRestart]		DATETIME NOT NULL
		,[Type]					BIT
		,[DBAComments]			VARCHAR(4096) NULL
		,[RunID]				INT
		,[OutageInSeconds]		INT NULL
	CONSTRAINT [PK__SQLRestarts_History__SQLServerStartup] PRIMARY KEY CLUSTERED 
	(
		[SQLRestartHistoryID] ASC
	) ON [History]
	)
	ALTER TABLE [hist].[SQLRestarts_History] ADD CONSTRAINT	DF__SQLRestarts_History__Type DEFAULT 0 FOR [Type]
END