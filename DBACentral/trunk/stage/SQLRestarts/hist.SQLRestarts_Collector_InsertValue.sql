IF OBJECT_ID('hist.SQLRestarts_Collector_InsertValue','P') IS NOT NULL 
	DROP PROCEDURE [hist].[SQLRestarts_Collector_InsertValue]
GO

/******************************************************************************
* Name
	[hist].[SQLRestarts_Collector_InsertValue]

* Author
	Adam Bean
	
* Date
	2011.04.20
	
* Synopsis
	Support procedure to insert data from powershell SQL restart collector
	
* Examples
	Only to be called from powershell collector - Collect-SQLRestarts

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

CREATE PROCEDURE [hist].[SQLRestarts_Collector_InsertValue]
(
	@RunID				INT
	,@ServerName		VARCHAR(256)
	,@TimeOfRestart		DATETIME
	,@OutageInSeconds	INT
)

AS

SET NOCOUNT ON

DECLARE 
	@HistServerID	INT

-- Find the RunID
IF NOT EXISTS
(
	SELECT [RunID]
	FROM [hist].[SQLRestarts_RunIDs]
	WHERE [RunID] = @RunID
)
BEGIN
	INSERT INTO [hist].[SQLRestarts_RunIDs]
	([RunID])
	SELECT @RunID
END

-- Get the server ID	
EXEC [hist].[ServerInventory_GetServerID] @ServerName = @ServerName, @ServerID = @HistServerID OUTPUT

-- Insert the data
IF NOT EXISTS 
(
	SELECT 
		[HistServerID]
		,[RunID]
	FROM [hist].[SQLRestarts_History]
	WHERE [HistServerID] = @HistServerID
	AND [TimeOfRestart] = @TimeOfRestart
)
BEGIN	
	INSERT INTO [hist].[SQLRestarts_History]
	([HistServerID], [RunID], [TimeOfRestart], [OutageInSeconds])
	VALUES
	(@HistServerID, @RunID, @TimeOfRestart, @OutageInSeconds)
END

SET NOCOUNT OFF