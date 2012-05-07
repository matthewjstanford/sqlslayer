IF OBJECT_ID('hist.SQLRestarts_vw','V') IS NOT NULL 
	DROP VIEW [hist].[SQLRestarts_vw]
GO

/******************************************************************************
* Name
	[hist].[SQLRestarts_vw]

* Author
	Adam Bean
	
* Date
	2011.04.20
	
* Synopsis
	View to report on SQL restart collector data

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

CREATE VIEW [hist].[SQLRestarts_vw]

AS

SELECT 
	rh.[SQLRestartHistoryID]
	,si.[HistServerID]
	,ri.[RunID]
	,si.[ServerName]
	,sa.[Environment]
	,rh.[TimeOfRestart]
	,rh.[OutageInSeconds]
	,CASE rh.[Type]
		WHEN 0 THEN 'Unexpected'
		ELSE 'Expected'
	END AS [Type]
	,rh.[DBAComments]
	,ri.[DateCreated]
FROM [hist].[ServerInventory_ServerIDs] si
JOIN [hist].[SQLRestarts_History] rh
	ON si.[HistServerID] = rh.[HistServerID]
JOIN [hist].[SQLRestarts_RunIDs] ri
	ON rh.[RunID] = ri.[RunID]
JOIN [dbo].[ServerInventory_SQL_AllServers_vw] sa
	ON si.[ServerName] = ISNULL(sa.[ServerName] + '\' + sa.[InstanceName], sa.[ServerName])
