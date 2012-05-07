SELECT 
	da.[AttributeValue]
	,bh.* 
FROM [hist].[Backups_History_vw] bh
INNER JOIN [hist].[ServerInventory_SQL_DatabaseAttributes_vw] da
	ON bh.[ServerName] = da.[ServerName]
	AND bh.[DatabaseName] = da.[DBName]
WHERE bh.[ServerName] = 'UHVSQLMAN01'
AND bh.[DatabaseName] = 'DBACentral'
AND da.[AttributeName] = 'recovery_model_desc'
AND 
	(
		CASE -- If there was a tlog backup on a db that is no longer in SIMPLE, remove it
			WHEN da.[AttributeValue] = 'SIMPLE' AND bh.[BackupType] = 'L' THEN 0
			ELSE 1
		END
	) = 1
ORDER BY [StartDate]