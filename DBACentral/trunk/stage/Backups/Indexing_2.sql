--DROP INDEX [hist].[Backups_History].[_dta_index_Backups_History_5_1493580359__K3_K1_K7_K10_K9_K8_K4_5_6]
--DROP INDEX [hist].[ServerInventory_SQL_DatabaseAttributeValues].[_dta_index_ServerInventory_SQL_DatabaseAttr_5_928058392__K2_K3_K5_6]

CREATE NONCLUSTERED INDEX [_dta_index_Backups_History_5_1493580359__K3_K1_K7_K10_K9_K8_K4_5_6] ON [hist].[Backups_History] 
(
	[DatabaseID] ASC,
	[HistServerID] ASC,
	[BUTypeID] ASC,
	[UserID] ASC,
	[PhysicalDeviceID] ASC,
	[LogicalDeviceID] ASC,
	[StartDate] ASC
)
INCLUDE ( [EndDate],
[Size_MBytes]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [_dta_index_ServerInventory_SQL_DatabaseAttr_5_928058392__K2_K3_K5_6] ON [hist].[ServerInventory_SQL_DatabaseAttributeValues] 
(
	[HistServerID] ASC,
	[HistDatabaseID] ASC,
	[DatabaseAttributeID] ASC
)
INCLUDE ( [AttributeValue]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
