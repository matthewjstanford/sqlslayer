IF OBJECT_ID('audit.ConnectionCounts_vw','V') IS NOT NULL 
	DROP VIEW [audit].[ConnectionCounts_vw]
GO

/******************************************************************************
* Name
	[audit].[ConnectionCounts_vw]

* Author
	Adam Bean
	
* Date
	2011.05.10
	
* Synopsis
	View to report on SQL connection counts

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

CREATE VIEW [audit].[ConnectionCounts_vw]

AS

SELECT 
	sn.[ServerName]
	,sa.[Environment]
	,cc.[CounterValue]
	,ri.[DateCreated]
FROM [hist].[ServerInventory_ServerIDs] sn
JOIN [audit].[ConnectionCounts] cc
	ON sn.[HistServerID] = cc.[HistServerID]
JOIN [audit].[ConnectionCounts_RunIDs] ri
	ON cc.[RunID] = ri.[RunID]
JOIN [dbo].[ServerInventory_SQL_AllServers_vw] sa
	ON sn.[ServerName] = sa.[FullName]