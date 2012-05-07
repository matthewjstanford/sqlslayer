SELECT 
	ss.[FullName]				AS [ServerName]
	,ss.[Environment]
	,da.[DBName]
	,da.[AttributeValue]		AS [RecoveryModel]
	,lbt.[BackupType]
	,bh.[BUTime_Seconds]		AS [BackupTimeSeconds]
	,bh.[Size_MBytes]			AS [BackupSizeMB]
	,bh.[PhysicalDeviceName]
	,lbt.[EndDate]				AS [LastBackupTime]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] ss -- Server inventory
JOIN [hist].[ServerInventory_SQL_DatabaseAttributes_vw] da -- Recovery model
	ON ss.[FullName] = da.[ServerName]
	AND da.[AttributeName] = 'recovery_model_desc'
	AND DATEADD(WEEK, -1, GETDATE()) < da.[DateLastSeenOn]
LEFT JOIN
(-- Exclude snapshots
	SELECT
		[ServerName]
		,[DBName]
	FROM [hist].[ServerInventory_SQL_DatabaseAttributes_vw]
	WHERE [AttributeName] = 'source_database_id'
) an
	ON da.[ServerName] = an.[ServerName]
	AND da.[DBName] = an.[DBName]
LEFT JOIN
(-- Retrieve last backup time
	SELECT 
		[ServerName]
		,[DatabaseName]
		,[BackupType]
		,MAX([EndDate]) AS [EndDate]
	FROM [hist].[Backups_History_vw] 
	GROUP BY
		[ServerName]
		,[DatabaseName]
		,[BackupType]
) lbt
	ON ISNULL(ss.[ServerName] + '\' + ss.[InstanceName], ss.[ServerName]) = lbt.[ServerName]
	AND da.[DBName] = lbt.[DatabaseName]
LEFT JOIN [hist].[Backups_History_vw] bh -- Get the device name and duration
	ON lbt.[ServerName] = bh.[ServerName]
	AND lbt.[DatabaseName] = bh.[DatabaseName]
	AND lbt.[BackupType] = bh.[BackupType]
	AND lbt.[EndDate] = bh.[EndDate]
WHERE ss.FullName = 'VENTSQL03\INTRANET'
AND an.[DBName] IS NULL
AND da.[DBName] != 'tempdb'
ORDER BY 3,9