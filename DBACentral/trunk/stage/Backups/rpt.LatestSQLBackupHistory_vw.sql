IF OBJECT_ID('rpt.LatestSQLBackupHistory_vw','V') IS NOT NULL 
	DROP VIEW [rpt].[LatestSQLBackupHistory_vw]
GO

/******************************************************************************
* Name
	[rpt].[LatestSQLBackupHistory_vw]

* Author
	Adam Bean
	
* Date
	2011.04.27
	
* Synopsis
	Reporting view to show latest SQL Server backups
	
* Description
	Combining the data of server inventory, backup history, database attributes and the 
	collectors log,	this view will show all supporting information for the latest backups 	
	for all	servers and databases.

* Dependencies
	Collecotrs: BackupHistory, DatabaseAttributes

* Notes
	[IsCurrentRecoveryModel] is a quick way to determine if at any point within a databases backup
	history there was a transaction log backup on a database that now has a SIMPLE recovery model. 
	This is used to exclude	those results outside of the CTE.
	
	[HoursSinceLastBackup] is not based on current date/time and is instead a DATEDIFF between 
	the last time the backup happened and the last time in which the data was colelcted	through 
	the BackupHistory powershell collector.
	
	[DateCreated] is the timestamp in which the backup history collection collected the data.
	
	[HoursSinceLastCollection] is the amount of hours that have passed between now and the last time
	the BackupHistory powershell collector was run.
	
	[LastAttributeCollectionPoll] is the amount of hours that have passed between now and the last time
	the DatabaseAttributes powershell collector was run. This is used to determine how old a database is.
	If there are more than 23 hours difference between the time the database attribute was last recorded
	and the time in which the collector was run, this implies a dropped database, which is not reported on.
	
*******************************************************************************
* License
*******************************************************************************
	Copyright © SQLSlayer.com. All rights reserved.

	All objects published by SQLSlayer.com are licensed and goverened by 
	Creative Commons Attribution-Share Alike 3.0
	http://creativecommons.org/licenses/by-sa/3.0/

	For more scripts and sample code, go to http://www.SQLSlayer.com

	You may alter this code for your own *non-commercial* purposes. You may
	republish altered code as long as you give due credit.

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
*******************************************************************************
* Change History
*******************************************************************************
	Date:		Author:			Description:
	--------	--------		---------------------------------------
	YYYYDDMM	Full Name	
******************************************************************************/

CREATE VIEW [rpt].[LatestSQLBackupHistory_vw]

AS

WITH [BU_CTE] AS
(
	SELECT 
		ss.[FullName]									AS [ServerName]
		,ss.[Environment]
		,sd.[database_name]								AS [DatabaseName]
		,sd.[recovery_model_desc]						AS [RecoveryModel]
		,CASE -- If the recovery model has changed, need to remove old backup entries on the tlog
			WHEN sd.[recovery_model_desc] = 'SIMPLE' AND lbt.[BackupType] = 'L' THEN 0
			ELSE 1
		END												AS [IsCurrentRecoveryModel]
		,lbt.[BackupType]
		,bh.[BUTime_Seconds]							AS [BackupTimeSeconds]
		,bh.[Size_MBytes]								AS [BackupSizeMB]
		,bh.[PhysicalDeviceName]
		,lbt.[EndDate]									AS [LastBackupTime]
		,DATEDIFF(HOUR,lbt.[EndDate],bhc.[DateCreated]) AS [HoursSinceLastBackup]
		,bhc.[DateCreated]								AS [DatePolled]
		,DATEDIFF(HOUR,bhc.[DateCreated],GETDATE())		AS [HoursSinceLastCollection]
	FROM [dbo].[ServerInventory_SQL_AllServers_vw] ss -- Server inventory
	JOIN [hist].[ServerInventory_SQL_SysDatabases_vw] sd -- Recovery model
		ON ss.[FullName] = sd.[ServerName]
	JOIN -- Retrieve last backup history collector time
	(
		SELECT 
			[ServerName]
			,MAX([DateCreated]) AS [DateCreated]
		FROM [hist].[Collectors_Log_vw]
		WHERE SUBSTRING([ScriptName],LEN([ScriptName])-CHARINDEX('\',REVERSE([ScriptName]))+2,100) = 'Collect-BackupHistory.ps1'
		GROUP BY [ServerName]
	) bhc
		ON ss.[FullName] = bhc.[ServerName]
	JOIN -- Retrieve last database attribute collector time
	(
		SELECT 
			[ServerName]
			,MAX([DateCreated]) AS [DateCreated]
		FROM [hist].[Collectors_Log_vw]
		WHERE SUBSTRING([ScriptName],LEN([ScriptName])-CHARINDEX('\',REVERSE([ScriptName]))+2,100) = 'Collect-DatabaseAttributes.ps1'
		GROUP BY [ServerName]
	) dac
		ON ss.[FullName] = dac.[ServerName]
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
		AND sd.[database_name] = lbt.[DatabaseName]
	LEFT JOIN [hist].[Backups_History_vw] bh -- Get the device name and duration
		ON lbt.[ServerName] = bh.[ServerName]
		AND lbt.[DatabaseName] = bh.[DatabaseName]
		AND lbt.[BackupType] = bh.[BackupType]
		AND lbt.[EndDate] = bh.[EndDate]
	WHERE sd.[database_name] != 'tempdb' -- Exclude tempdb
	AND sd.[source_database_id] IS NULL -- Exclude snapshots
	AND DATEDIFF(HOUR,sd.[DateLastSeenOn],dac.[DateCreated]) < 23 -- Remove dropped databases
)

SELECT 
	[ServerName]
	,[Environment]
	,[DatabaseName]
	,[RecoveryModel]
	,[BackupType]
	,[BackupTimeSeconds]
	,[BackupSizeMB]
	,[PhysicalDeviceName]
	,[LastBackupTime]
	,[HoursSinceLastBackup]
	,[DatePolled]
	,[HoursSinceLastCollection]
FROM BU_CTE
WHERE [IsCurrentRecoveryModel] = 1