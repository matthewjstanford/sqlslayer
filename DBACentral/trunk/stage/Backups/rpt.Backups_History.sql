IF OBJECT_ID('rpt.Backups_History','P') IS NOT NULL 
	DROP PROCEDURE [rpt].[Backups_History]
GO

/******************************************************************************
* Name
	[rpt].[Backups_History]

* Author
	Adam Bean
	
* Date
	2011.05.04
	
* Synopsis
	Reporting procedure to display backup history with recovery model
	
* Examples
	

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

CREATE PROCEDURE [rpt].[Backups_History]
(
	@Environment			VARCHAR(MAX)	= NULL
	,@ServerName			VARCHAR(MAX)	= NULL
	,@DBName				VARCHAR(MAX)	= NULL
	,@FindMissing			BIT				= 0
	,@FindNonStandard		BIT				= 0
	,@FindNonStandardString	VARCHAR(32)		= NULL
)

AS

SET NOCOUNT ON


IF OBJECT_ID('tempdb.dbo.#backuphistory') IS NOT NULL
   DROP TABLE #backuphistory
   
SELECT 
      da.[AttributeValue]
      --,CASE -- If the recovery model has changed, need to remove old backup entries on the tlog
      --      WHEN da.[AttributeValue] = 'SIMPLE' AND [BackupType] = 'L' THEN 0
      --      ELSE 1
      --END	AS [IsCurrentRecoveryModel]
      ,bh.* 
--INTO #backuphistory
FROM [hist].[Backups_History_vw] bh
JOIN [dbo].[ServerInventory_SQL_AllServers_vw] ss
	ON ISNULL(ss.[ServerName] + '\' + ss.[InstanceName], ss.[ServerName]) = bh.[ServerName]
JOIN [hist].[ServerInventory_SQL_DatabaseAttributes_vw] da
      ON ss.[FullName] = da.[ServerName]
      AND bh.[DatabaseName] = da.[DBName]
LEFT JOIN [dbo].[Split_fn](@Environment,',') en
	ON ss.[Environment] = en.[item]
LEFT JOIN [dbo].[Split_fn](@ServerName,',') sn
	ON ISNULL(ss.[ServerName] + '\' + ss.[InstanceName], ss.[ServerName]) = sn.[item]
LEFT JOIN [dbo].[Split_fn](@DBName,',') db
	ON bh.[DatabaseName] = db.[item]
	--AND ISNULL(ss.[ServerName] + '\' + ss.[InstanceName], ss.[ServerName]) = sn.[item]
WHERE da.[AttributeName] = 'recovery_model_desc'
--AND bh.ServerName = 'UHVSQLMAN01'
--AND bh.DatabaseName = 'DBACENTRAL'
AND ((en.[item] IS NOT NULL AND @Environment IS NOT NULL) OR @Environment IS NULL) -- Specified environment(s), or all
AND ((sn.[item] IS NOT NULL AND @ServerName IS NOT NULL) OR @ServerName IS NULL) -- Specified server name(s), or all
AND ((db.[item] IS NOT NULL AND @DBName IS NOT NULL) OR @DBName IS NULL) -- Specified database name(s), or all

--CREATE INDEX [#IX_backuphistory_IsCurrentRecoveryModel] ON #backuphistory
--(
--	[IsCurrentRecoveryModel]
--)

--SELECT * FROM #backuphistory

SET NOCOUNT OFF