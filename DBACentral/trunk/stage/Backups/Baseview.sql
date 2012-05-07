SELECT 
	ss.[FullName]				AS [ServerName]
	,ss.[Environment]
	,sd.[database_name]
	,sd.[recovery_model_desc]
	,CASE -- If the recovery model has changed, need to remove old backup entries on the tlog
		WHEN sd.[recovery_model_desc] = 'SIMPLE' AND bh.[BackupType] = 'L' THEN 0
		ELSE 1
	END							AS [IsCurrentRecoveryModel]
	,bh.[BackupType]
	,bh.[BUTime_Seconds]		AS [BackupTimeSeconds]
	,bh.[Size_MBytes]			AS [BackupSizeMB]
	,bh.[PhysicalDeviceName]
	,bh.[StartDate]
	,bh.[EndDate]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] ss -- Server inventory
JOIN [hist].[ServerInventory_SQL_SysDatabases_vw] sd -- Recovery model
	ON ss.[FullName] = sd.[ServerName]
LEFT JOIN [hist].[Backups_History_vw] bh -- Get the device name and duration
	ON sd.[ServerName] = bh.[ServerName]
	AND sd.[database_name] = bh.[DatabaseName]
WHERE sd.[database_name] != 'tempdb'
AND sd.[source_database_id] IS NULL -- Exclude snapshots
AND ss.FullName = 'UHVSQLMAN01'
AND sd.[database_name] = 'DBACentral'