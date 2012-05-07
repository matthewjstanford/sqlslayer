CREATE INDEX [IX__ConnectionCounts__HistServerID__RunID] ON [audit].[ConnectionCounts] 
(
	[HistServerID]
	,[RunID]
)
INCLUDE ([CounterValue]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE INDEX [IX__ConnectionCounts_RunIDs__RunID__DateCreated] ON [audit].[ConnectionCounts_RunIDs] 
(
	[RunID]
	,[DateCreated]
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]