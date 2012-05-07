--DROP INDEX [hist].[Collectors_Log].[IX__Collectors_Log__HistCollectorLogStateID__HistServerID__HistUserID__HistCollectorLogScriptID]
--DROP INDEX [hist].[ServerInventory_SQL_DatabaseAttributeValues].[IX__ServerInventory_SQL_DatabaseAttributeValues__COVERING]
--DROP INDEX [hist].[Backups_Devices].[IX__Backups_Devices__DeviceID]
--DROP INDEX [hist].[Backups_History].[IX__Backups_History__EndDate__DatabaseID__HistServerID__BUTypeID__UserID__PhysicalDeviceID__LogicalDeviceID]
--DROP INDEX [hist].[ServerInventory_SQL_DatabaseIDs].[IX__ServerInventory_SQL_DatabaseIDs__DatabaseID__DBName]

CREATE INDEX [IX__Collectors_Log__HistCollectorLogStateID__HistServerID__HistUserID__HistCollectorLogScriptID] ON [hist].[Collectors_Log] 
(
	[HistCollectorLogStateID]
	,[HistServerID]
	,[HistUserID]
	,[HistCollectorLogScriptID] 
)
INCLUDE 
(
	[DateCreated]
)

CREATE INDEX [IX__ServerInventory_SQL_DatabaseAttributeValues__COVERING] ON [hist].[ServerInventory_SQL_DatabaseAttributeValues] 
(
	[DatabaseAttributeValueID]
	,[HistServerID]
	,[HistDatabaseID]
	,[file_id]
	,[DatabaseAttributeID]
	,[AttributeValue]
	,[DateCreated]
	,[DateLastSeenOn]
)

CREATE NONCLUSTERED INDEX [IX__Backups_Devices__DeviceID] ON [hist].[Backups_Devices] 
(
	[DeviceID]
)
INCLUDE 
( 
	[DeviceName]
)

CREATE INDEX [IX__Backups_History__EndDate__DatabaseID__HistServerID__BUTypeID__UserID__PhysicalDeviceID__LogicalDeviceID] ON [hist].[Backups_History] 
(
	[EndDate]
	,[DatabaseID]
	,[HistServerID]
	,[BUTypeID]
	,[UserID]
	,[PhysicalDeviceID]
	,[LogicalDeviceID]
)
INCLUDE 
(
	[StartDate]
	,[Size_MBytes]
)	 

CREATE INDEX [IX__ServerInventory_SQL_DatabaseIDs__DatabaseID__DBName] ON [hist].[ServerInventory_SQL_DatabaseIDs] 
(
	[DatabaseID]
	,[DBName]
)
