USE DBACentral

SET XACT_ABORT ON

BEGIN TRANSACTION

IF OBJECT_ID('[dbo].[ServerInventory_SQL_ServerAttributes_vw]','V') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_SQL_ServerAttributes_vw]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_ServerInfo_vw]','V') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_SQL_ServerInfo_vw]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_ServerInstances_vw]','V') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_SQL_ServerInstances_vw]
IF OBJECT_ID('[dbo].[SpaceUsed_CollectTableOrDatabase_vw]','V') IS NOT NULL
	DROP VIEW [dbo].[SpaceUsed_CollectTableOrDatabase_vw]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_BackupLicensing_vw]','V') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_SQL_BackupLicensing_vw]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_TestServers_vw]','V') IS NOT NULL
	DROP VIEW [dbo].[ServerInventory_SQL_TestServers_vw]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_SaveAttribute]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[ServerInventory_SQL_SaveAttribute]
IF OBJECT_ID('[dbo].[ServerInventory_SQL_GetAttributeID]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[ServerInventory_SQL_GetAttributeID]
IF EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID('dbo.ServerInventory_SQL_AttributeMaster') AND name = 'IsCore')
BEGIN
	ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] DROP [DF__ServerInventory_SQL_AttributeMaster__IsCore]
	ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] DROP COLUMN [IsCore]
END
IF EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID('dbo.ServerInventory_SQL_AttributeMaster') AND name = 'IsReadOnly')
BEGIN
	ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] DROP [DF__ServerInventory_SQL_AttributeMaster__IsReadOnly]
	ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] DROP COLUMN [IsReadOnly]
END
IF EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID('dbo.ServerInventory_SQL_AttributeMaster') AND name = 'DateCreated')
BEGIN
	ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] DROP [DF__ServerInventory_SQL_AttributeMaster__DateCreated]
	ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] DROP COLUMN [DateCreated]
END
	
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] ADD [IsCore] BIT CONSTRAINT [DF__ServerInventory_SQL_AttributeMaster__IsCore] DEFAULT (0)
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] ADD [IsReadOnly] BIT CONSTRAINT [DF__ServerInventory_SQL_AttributeMaster__IsReadOnly] DEFAULT (0)
ALTER TABLE [dbo].[ServerInventory_SQL_AttributeMaster] ADD [DateCreated] DATETIME CONSTRAINT [DF__ServerInventory_SQL_AttributeMaster__DateCreated] DEFAULT (GETDATE())
IF NOT EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID('dbo.ServerInventory_SQL_AttributeMaster') AND name = 'AttributeName')
BEGIN
	EXEC sp_rename 'dbo.ServerInventory_SQL_AttributeMaster.AttribName', 'AttributeName', 'COLUMN'
	EXEC sp_rename 'dbo.ServerInventory_SQL_AttributeMaster.AttribID', 'AttributeID', 'COLUMN'
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID('[dbo].[ServerInventory_SQL_AttributeList]') AND name = 'AttributeID')
BEGIN
	EXEC sp_rename '[dbo].[ServerInventory_SQL_AttributeList].[AttribID]', 'AttributeID', 'COLUMN'
	EXEC sp_rename '[dbo].[ServerInventory_SQL_AttributeList].[AttribValue]', 'AttributeValue', 'COLUMN'
END

GO
/******************************************************************************
* Name
	[dbo].[ServerInventory_SQL_GetAttributeID]

* Author
	Matt Stanford
	
* Date
	2011.04.28
	
* Synopsis
	Procedure to manage inserting data into the AttributeList table
	
* Description
	Procedure to manage inserting data into the AttributeList table

* Dependencies
	[dbo].[ServerInventory_SQL_AttributeMaster]
	
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
******************************************************************************/
CREATE PROCEDURE [dbo].[ServerInventory_SQL_GetAttributeID] (
	@AttributeName			VARCHAR(100)
	,@AttributeID			INT OUTPUT
	,@CreateIfNecessary		BIT = 0
)
AS
	
SET @AttributeID = (SELECT [AttributeID] FROM [dbo].[ServerInventory_SQL_AttributeMaster] WHERE [AttributeName] = @AttributeName)

IF @AttributeID IS NULL AND @CreateIfNecessary = 1
BEGIN

	INSERT INTO [dbo].[ServerInventory_SQL_AttributeMaster] ([AttributeName], [IsCore], [IsReadOnly])
	VALUES (@AttributeName, 0, 0)
	
	SET @AttributeID = SCOPE_IDENTITY()

END

GO
/******************************************************************************
* Name
	[dbo].[ServerInventory_SQL_SaveAttribute]

* Author
	Matt Stanford
	
* Date
	2008.12.29
	
* Synopsis
	Procedure to manage inserting data into the AttributeList table
	
* Description
	Procedure to manage inserting data into the AttributeList table

* Dependencies
	[dbo].[ServerInventory_SQL_GetAttributeID]
	[dbo].[ServerInventory_SQL_AttributeList]
	
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
	20110428	Matt Stanford	Modified to call the GetAttributeID procedure for dynamic attribute creation
******************************************************************************/
CREATE PROCEDURE [dbo].[ServerInventory_SQL_SaveAttribute] (
	@ServerID				INT
	,@AttributeName			VARCHAR(100)
	,@AttributeValue		NVARCHAR(1000)
)
AS

DECLARE
	@AttributeID		INT
	
EXEC [dbo].[ServerInventory_SQL_GetAttributeID] @AttributeName, @AttributeID = @AttributeID OUTPUT, @CreateIfNecessary = 1

IF @AttributeID IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT * FROM [dbo].[ServerInventory_SQL_AttributeList] WHERE ServerID = @ServerID AND AttributeID = @AttributeID)
	BEGIN
		-- Its an insert!
		INSERT INTO [dbo].[ServerInventory_SQL_AttributeList] ([ServerID], [AttributeID], [AttributeValue])
		VALUES (@ServerID, @AttributeID, @AttributeValue)
	END
	ELSE IF NOT EXISTS(SELECT * FROM [dbo].[ServerInventory_SQL_AttributeList] WHERE ServerID = @ServerID AND AttributeID = @AttributeID AND AttributeValue = @AttributeValue)
	BEGIN 
		-- Its an update!
		UPDATE al SET al.AttributeValue = @AttributeValue
		FROM [dbo].[ServerInventory_SQL_AttributeList] al
		WHERE al.ServerID = @ServerID 
		AND al.AttributeID = @AttributeID
	END
	ELSE
	BEGIN
		-- Its a trick!
		PRINT('Nothing to do here')
	END
END
ELSE
BEGIN
	PRINT('Attribute does not exist')
END

GO
/******************************************************************************
* Name
	[dbo].[ServerInventory_SQL_ServerAttributes_vw]

* Author
	Matt Stanford
	
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
CREATE VIEW [dbo].[ServerInventory_SQL_ServerAttributes_vw]
AS

SELECT 
	m.[ServerID]
	,m.[FullName]				AS ServerName
	,m.[SQLVersion]
	,m.[Environment]			AS EnvironmentName
	,am.[AttributeName]
	,attrib.[AttributeValue]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] m
INNER JOIN [dbo].[ServerInventory_SQL_AttributeList] attrib
	ON attrib.[ServerID] = m.[ServerID]
INNER JOIN [dbo].[ServerInventory_SQL_AttributeMaster] am
	ON attrib.[AttributeID] = am.[AttributeID]

GO
/******************************************************************************
* Name
	[rpt].[LatestSQLBackupHistory_vw]

* Author
	Matt Stanford
	
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
CREATE VIEW [dbo].[ServerInventory_SQL_ServerInfo_vw]
AS

SELECT 
	srv.[ServerID]
	,srv.[FullName] as [ServerName]
	,srv.[Environment]
	,srv.[Description]
	,srv.[SQLVersion]							AS [DBAC_SQLVersion]
	,srv.[Edition]								AS [DBAC_Edition]
	,att.[SQLServer_ServicePack]
	,att.[CumulativeUpdate]
	,att.[Description]							AS [ProductVersionDescription]
	,att.[SQLVersion]							AS [SQLServer_SQLVersion]
	,att.[SQLServer_Build]
	,att.[SQLServer_Edition]
	,att.[SQLServer_@@ServerName]
	,att.[SQLServer_MachineName]
	,att.[SQLServer_PhysicalName]
	,att.[SQLServer_ServerName]
	,att.[SQLServer_InstanceName]
	,att.[SQLServer_LicenseType]
	,att.[SQLServer_IsClustered]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] srv
LEFT OUTER JOIN (
	SELECT 
		PVT.[ServerName]
		,[SQLServer_Build]
		,bd.[SQLVersion]
		,bd.[ProductLevel]
		,bd.[CumulativeUpdate]
		,[SQLServer_Edition]
		,[SQLServer_ServicePack]
		,bd.[Description]
		,[SQLServer_@@ServerName]
		,[SQLServer_MachineName]
		,[SQLServer_PhysicalName]
		,[SQLServer_ServerName]
		,[SQLServer_InstanceName]
		,[SQLServer_LicenseType]
		,[SQLServer_IsClustered]
	FROM
	(
		SELECT 
			s.FullName as ServerName
			,sa.AttributeName
			,sa.AttributeValue
		FROM [dbo].[ServerInventory_SQL_AllServers_vw] s
		LEFT OUTER JOIN [dbo].[ServerInventory_SQL_ServerAttributes_vw] sa
			ON sa.ServerName = s.FullName
		WHERE sa.[AttributeName] IN ('SQLServer_Build','SQLServer_ServicePack','SQLServer_Edition','SQLServer_Engine','SQLServer_@@ServerName','SQLServer_InstanceName','SQLServer_IsClustered',
		'SQLServer_LicenseType','SQLServer_MachineName','SQLServer_PhysicalName','SQLServer_ServerName')
	) as st
	PIVOT
	(
		MAX(AttributeValue)
		FOR AttributeName 
			IN ([SQLServer_Build],[SQLServer_ServicePack],[SQLServer_Edition],[SQLServer_Engine],[SQLServer_@@ServerName],[SQLServer_MachineName], 
			[SQLServer_PhysicalName], [SQLServer_ServerName], [SQLServer_InstanceName], [SQLServer_LicenseType], [SQLServer_IsClustered])
	) as PVT
	LEFT OUTER JOIN [dbo].[ServerInventory_SQL_BuildLevelDesc] bd
		ON bd.[ProductVersion] = PVT.[SQLServer_Build]
) att
ON att.[ServerName] = srv.[FullName]
GO
/******************************************************************************
* Name
	[rpt].[LatestSQLBackupHistory_vw]

* Author
	Matt Stanford
	
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
CREATE VIEW [dbo].[ServerInventory_SQL_BackupLicensing_vw]
AS
SELECT DISTINCT
	 vw.[servername]
	,am.[AttributeName] AS [Software]
	,at.[AttributeValue] AS [Status]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] vw
INNER JOIN [dbo].[ServerInventory_SQL_AttributeList] at
	ON vw.[serverid] = at.[serverid]
INNER JOIN [dbo].[ServerInventory_SQL_AttributeMaster] am
	ON at.[AttributeID] = am.[AttributeID]
WHERE am.[AttributeName] = 'redgate'

GO
/******************************************************************************
* Name
	[dbo].[ServerInventory_SQL_TestServers_vw]

* Author
	Matt Stanford
	
* Date
	2011.04.28
	
* Synopsis
	Reporting view to show latest SQL Server backups
	
* Description
	Combining the data of server inventory, backup history, database attributes and the 
	collectors log,	this view will show all supporting information for the latest backups 	
	for all	servers and databases.

* Dependencies
	[dbo].[ServerInventory_SQL_ServerAttributes_vw]
	[dbo].[ServerInventory_SQL_AllServers_vw]
	
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
CREATE VIEW [dbo].[ServerInventory_SQL_TestServers_vw]
AS
SELECT 
	s.[ServerID]
	,s.[FullName]
	,s.[DotNetConnectionString]
FROM [dbo].[ServerInventory_SQL_AllServers_vw] s
INNER JOIN [dbo].[ServerInventory_SQL_ServerAttributes_vw] sa
	ON s.[ServerID] = sa.[ServerID]
WHERE sa.[AttributeName] = 'UsedForTesting' AND sa.[AttributeValue] = 'TRUE'
GO
/******************************************************************************
* Name
	[dbo].[SpaceUsed_CollectTableOrDatabase_vw]

* Author
	Matt Stanford
	
* Date
	<2011.04.28
	
* Synopsis
	View to drive the spaceused collectors
	
* Description
	View to drive the spaceused collectors

* Dependencies
	[dbo].[ServerInventory_SQL_ServerAttributes_vw]
	[dbo].[ServerInventory_SQL_AllServers_vw]
	
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
ALTER VIEW [dbo].[SpaceUsed_CollectTableOrDatabase_vw]
AS

WITH TableOrDB
AS
(
	SELECT 
		a.[ServerID]
		,a.[ServerName]
		,a.[SQLVersion]
		,a.[AttributeName]
		,a.[AttributeValue]
		,s.[DotNetConnectionString]
	FROM [dbo].[ServerInventory_SQL_ServerAttributes_vw] a
	INNER JOIN [dbo].[ServerInventory_SQL_AllServers_vw] s
		ON a.ServerID = s.ServerID
	WHERE a.[AttributeName] IN ('SpaceUsed_Collect_Database', 'SpaceUsed_Collect_Table','UsedForTesting')
)
SELECT 
	COALESCE(t.[ServerName],d.[ServerName]) as ServerName
	,COALESCE(t.[SQLVersion],d.[SQLVersion]) as SQLVersion
	,CASE WHEN t.[AttributeValue] IS NULL 
		THEN 0
		ELSE 1
	END as CollectTable
	,CASE WHEN d.[AttributeValue] IS NULL 
		THEN 0
		ELSE 1
	END as CollectDatabase
	,CASE WHEN x.[AttributeValue] IS NULL 
		THEN 0
		ELSE 1
	END as UsedForTesting
	,COALESCE(t.[DotNetConnectionString],d.[DotNetConnectionString]) as ConnectionString
FROM (SELECT * FROM TableOrDB WHERE [AttributeName] = 'SpaceUsed_Collect_Table' AND [AttributeValue] = 'TRUE') t
FULL OUTER JOIN (SELECT * FROM TableOrDB WHERE [AttributeName] = 'SpaceUsed_Collect_Database' AND [AttributeValue] = 'TRUE') d
	ON t.[ServerID] = d.[ServerID]
LEFT OUTER JOIN (SELECT * FROM TableOrDB WHERE [AttributeName] = 'UsedForTesting' AND [AttributeValue] = 'TRUE') x
	ON COALESCE(t.[ServerID],d.[ServerID]) = x.[ServerID]


GO



COMMIT