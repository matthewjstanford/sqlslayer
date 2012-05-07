IF OBJECT_ID('hist.SQLRestarts_UpdateValue','P') IS NOT NULL 
	DROP PROCEDURE [hist].[SQLRestarts_UpdateValue]
GO

/******************************************************************************
* Name
	[hist].[SQLRestarts_UpdateValue]

* Author
	Adam Bean
	
* Date
	2011.04.20
	
* Synopsis
	Support procedure to update SQL restart data

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

CREATE PROCEDURE [hist].[SQLRestarts_UpdateValue]
(
	@SQLRestartID	INT
	,@DBAComments	VARCHAR(MAX)
	,@Type			BIT
)

AS

SET NOCOUNT ON

UPDATE [hist].[SQLRestarts_History]
	SET [DBAComments] = @DBAComments
	,[Type] = @Type
WHERE [SQLRestartHistoryID] = @SQLRestartID

SET NOCOUNT OFF