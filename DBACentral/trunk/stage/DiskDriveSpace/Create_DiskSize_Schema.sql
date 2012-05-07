USE [DBACentral]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID('[hist].[FK__ServerInventory_Size_DriveMaster__DriveLabelID__ServerInventory_Size_DriveLabel__DriveLabelID]')  AND parent_object_id = OBJECT_ID(N'[hist].[ServerInventory_Size_DriveMaster]'))
ALTER TABLE [hist].[ServerInventory_Size_DriveMaster] DROP CONSTRAINT [FK__ServerInventory_Size_DriveMaster__DriveLabelID__ServerInventory_Size_DriveLabel__DriveLabelID]
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID('[hist].[FK__ServerInventory_Size_DriveMaster__DriveLetterID__ServerInventory_Size_DriveLetter__DriveLetterID]') AND parent_object_id = OBJECT_ID(N'[hist].[ServerInventory_Size_DriveMaster]'))
ALTER TABLE [hist].[ServerInventory_Size_DriveMaster] DROP CONSTRAINT [FK__ServerInventory_Size_DriveMaster__DriveLetterID__ServerInventory_Size_DriveLetter__DriveLetterID]
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[hist].[FK__ServerInventory_Size_DriveMaster__HistServerID__ServerInventory_ServerIDs__HistServerID]') AND parent_object_id = OBJECT_ID(N'[hist].[ServerInventory_Size_DriveMaster]'))
ALTER TABLE [hist].[ServerInventory_Size_DriveMaster] DROP CONSTRAINT [FK__ServerInventory_Size_DriveMaster__HistServerID__ServerInventory_ServerIDs__HistServerID]
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('[hist].[SpaceUsed_DriveSizes_DriveMaster]') AND name = N'UIX__SpaceUsed_DriveSizes_DriveMaster__RunID_HistServerID_DriveLetterID_DriveLabelID')
DROP INDEX [UIX__SpaceUsed_DriveSizes_DriveMaster__RunID_HistServerID_DriveLetterID_DriveLabelID] ON [hist].[SpaceUsed_DriveSizes_DriveMaster] WITH ( ONLINE = OFF )
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_DriveMaster]') AND type in (N'U'))
DROP TABLE [hist].[SpaceUsed_DriveSizes_DriveMaster]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_GetDriveLabelIDs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [hist].[SpaceUsed_DriveSizes_GetDriveLabelIDs]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_GetDriveLetterIDs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [hist].[SpaceUsed_DriveSizes_GetDriveLetterIDs]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_InsertDriveMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [hist].[SpaceUsed_DriveSizes_InsertDriveMaster]
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_vw]'))
DROP VIEW [hist].[SpaceUsed_DriveSizes_vw]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_RunIDs]') AND type in (N'U'))
DROP TABLE [hist].[SpaceUsed_DriveSizes_RunIDs]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_DriveLabel]') AND type in (N'U'))
DROP TABLE [hist].[SpaceUsed_DriveSizes_DriveLabel]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hist].[SpaceUsed_DriveSizes_DriveLetter]') AND type in (N'U'))
DROP TABLE [hist].[SpaceUsed_DriveSizes_DriveLetter]

GO


--------------------------------------------------------------------------------------------------------------

/******** CREATE TABLES *******/


-- [hist].[SpaceUsed_DriveSizes_DriveLabel]
CREATE TABLE [hist].[SpaceUsed_DriveSizes_DriveLabel](
	[DriveLabelID] [int] IDENTITY(1,1) NOT NULL,
	[DriveLabel] [varchar](30) NULL,
 CONSTRAINT [PK__SpaceUsed_DriveSizes_DriveLabel__DriveLabelID] PRIMARY KEY CLUSTERED 
(
	[DriveLabelID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


-- [hist].[SpaceUsed_DriveSizes_DriveLetter]

CREATE TABLE [hist].[SpaceUsed_DriveSizes_DriveLetter](
	[DriveLetterID] [int] IDENTITY(1,1) NOT NULL,
	[DriveLetter] [varchar](2) NULL,
 CONSTRAINT [PK__SpaceUsed_DriveSizes_DriveLetter__DriveLetterID] PRIMARY KEY CLUSTERED 
(
	[DriveLetterID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


-- [hist].[SpaceUsed_DriveSizes_RunIDs]

CREATE TABLE [hist].[SpaceUsed_DriveSizes_RunIDs](
	[RunID] [int] NOT NULL,
	[DateCreated] [smalldatetime] NULL, 
 CONSTRAINT [PK_SpaceUsed_DriveSizes_RunIDs] PRIMARY KEY CLUSTERED 
(
	[RunID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


-- [hist].[SpaceUsed_DriveSizes_DriveMaster]

CREATE TABLE [hist].[SpaceUsed_DriveSizes_DriveMaster]
    (
     [RunID] INT CONSTRAINT [FK__SpaceUsed_DriveSizes_DriveMaster__RunID__SpaceUsed_DriveSizes_RunIDs__RunID] FOREIGN KEY REFERENCES [hist].[SpaceUsed_DriveSizes_RunIDs] ( [RunID] )
    ,[HistServerID] INT CONSTRAINT [FK__SpaceUsed_DriveSizes_DriveMaster__HistServerID__ServerInventory_ServerIDs__HistServerID] FOREIGN KEY REFERENCES [hist].[ServerInventory_ServerIDs] ( [HistServerID] )
    ,[DriveLetterID] INT CONSTRAINT [FK__SpaceUsed_DriveSizes_DriveMaster__DriveLetterID__SpaceUsed_DriveSizes_DriveLetter__DriveLetterID] FOREIGN KEY REFERENCES [hist].[SpaceUsed_DriveSizes_DriveLetter] ( [DriveLetterID] )
    ,[DriveLabelID] INT CONSTRAINT [FK__SpaceUsed_DriveSizes_DriveMaster__DriveLabelID__SpaceUsed_DriveSizes_DriveLabel__DriveLabelID] FOREIGN KEY REFERENCES [hist].[SpaceUsed_DriveSizes_DriveLabel] ( [DriveLabelID] )
    ,[HostName] NVARCHAR (100)
    ,[DrivePath] VARCHAR (100)
    ,[FreeSpaceMB] BIGINT
    ,[CapacityMB] BIGINT
    ,[MountPoint] BIT 
    )

CREATE INDEX [UIX__SpaceUsed_DriveSizes_DriveMaster__RunID_HistServerID_DriveLetterID_DriveLabelID] ON [DBACentral].[hist].[SpaceUsed_DriveSizes_DriveMaster] ([RunID], [HistServerID], [DriveLetterID],[DriveLabelID]) WITH (ONLINE = ON)

--------------------------------------------------------------------------------------------------------------

/******** CREATE VIEWS *******/
USE [DBACentral]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
* Name
	[hist].[SpaceUsed_DriveSizes_vw]

* Author
	Kathy J Toth
	
* Date
	2011.19.07
	
* Synopsis
	The view ties all the tables together to give you an overview of the disk space 
	
* Description
	Have you ever wanted to know how much total capacity you have on a disk and how much space is currently free? Well, look no more and use this view to see that information.

* Examples
	SELECT * FROM [hist].[SpaceUsed_DriveSizes_vw]

* Dependencies
	[hist].[SpaceUsed_DriveSizes_DriveMaster]
	[hist].[SpaceUsed_DriveSizes_DriveLabel]
	[hist].[SpaceUsed_DriveSizes_DriveLetter]
	[hist].[SpaceUsed_DriveSizes_RunIDs]
	[hist].[ServerInventory_ServerIDs]
	
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
GO
CREATE VIEW [hist].[SpaceUsed_DriveSizes_vw]
AS

SELECT 
	[ServerName]															AS [ServerName]
	,[DriveLabel]															AS [DriveLabel]
	,[DrivePath]															AS [DrivePath]
	,[FreeSpaceMB]															AS [FreeSpaceMB]
	,[CapacityMB]															AS [CapacityMB]
	,ISNULL(([FreeSpaceMB])* 100 / ((NULLIF([CapacityMB],0))),0)			AS [PercentUsed]
	,100 - (ISNULL(([FreeSpaceMB]) * 100 / ((NULLIF([CapacityMB],0))),0) )	AS [PercentUnused]
	,CASE	
		WHEN [MountPoint] = 1
			THEN 'Yes'
			ELSE 'No'
		END AS [MountPoint]
	,[SISRID].[RunID]
	,[SISRID].[DateCreated]
FROM  hist.[SpaceUsed_DriveSizes_DriveMaster] AS SISDM
JOIN hist.[ServerInventory_ServerIDs] AS SISID 
	ON [SISDM].[HistServerID] = [SISID].[HistServerID]
JOIN [hist].[SpaceUsed_DriveSizes_DriveLabel] AS SISDL 
	ON [SISDM].[DriveLabelID] = [SISDL].[DriveLabelID]
JOIN [hist].[SpaceUsed_DriveSizes_DriveLetter] AS SISDL2 
	ON SISDM.[DriveLetterID] = SISDL2.[DriveLetterID]
JOIN [hist].[SpaceUsed_DriveSizes_RunIDs] AS SISRID 
	ON SISRID.[RunID] = [SISDM].[RunID]  

GO
--------------------------------------------------------------------------------------------------------------


/******** CREATE STORED PROCEDURES *******/
USE [DBACentral]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
* Name
	[hist].[SpaceUsed_DriveSizes_GetDriveLabelIDs]

* Author
	Kathy J Toth
	
* Date
	2011.19.07
	
* Synopsis
	This procedure will insert the drive label if it doesn't already exist and then return the drive label ID.
	
* Description
	This procedure will insert the drive label if it doesn't already exist and then return the drive label ID.

* Examples
	EXEC [hist].[SpaceUsed_DriveSizes_GetDriveLabelIDs] @DriveLabel = 'SQL Data'

* Dependencies
	[hist].[SpaceUsed_DriveSizes_DriveLabel]

* Parameters
	@DriveLable		- This is the drive label of said drive
	
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
CREATE PROCEDURE [hist].[SpaceUsed_DriveSizes_GetDriveLabelIDs] (
	@DriveLabel NVARCHAR (30)
	,@DriveLabelID INT OUTPUT
)

AS 

IF NOT EXISTS

(
	SELECT [DriveLabel]
	FROM [hist].[SpaceUsed_DriveSizes_DriveLabel]
	WHERE [DriveLabel] = ISNULL (@DriveLabel,'')
	
)
BEGIN
	INSERT INTO [hist].[SpaceUsed_DriveSizes_DriveLabel] ([DriveLabel])
	VALUES (ISNULL(@DriveLabel,''))
	SET @DriveLabelID = SCOPE_IDENTITY()
	
END
ELSE
BEGIN	
	SET @DriveLabelID = 
	(
		SELECT DriveLabelID
		FROM [hist].[SpaceUsed_DriveSizes_DriveLabel]
		WHERE [DriveLabel] = ISNULL (@DriveLabel,'')
	)
END	

--------------------------------------------------------------------------------------------------------------
GO
USE [DBACentral]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
* Name
	[hist].[SpaceUsed_DriveSizes_GetDriveLetterIDs]

* Author
	Kathy J Toth
	
* Date
	2011.19.07
	
* Synopsis
	This procedure will insert the drive letter if it doesn't already exist and then return the drive letter ID.
	
* Description
	This procedure will insert the drive letter if it doesn't already exist and then return the drive letter ID.

* Examples
	EXEC [hist].[SpaceUsed_DriveSizes_GetDriveLetterIDs] @DriveLetter = 'A'

* Dependencies
	[hist].[SpaceUsed_DriveSizes_DriveLetter]

* Parameters
	@DriveLetter		- This is the drive letter of said drive
	
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
CREATE PROCEDURE [hist].[SpaceUsed_DriveSizes_GetDriveLetterIDs] (
	@DriveLetter	NVARCHAR (2)
	,@DriveLetterID	INT OUTPUT
)

AS

IF NOT EXISTS
	(
		SELECT [DriveLetter]
		FROM [hist].[SpaceUsed_DriveSizes_DriveLetter]
		WHERE [DriveLetter] = REPLACE(ISNULL(NULLIF(LEFT(@DriveLetter,1),''),'MP'),':','')
	)

BEGIN
	INSERT INTO [hist].[SpaceUsed_DriveSizes_DriveLetter]  ([DriveLetter]) 
	VALUES (REPLACE(ISNULL(NULLIF(LEFT(@DriveLetter,1),''),'MP'),':',''))
	SET @DriveLetterID = SCOPE_IDENTITY()
END
ELSE
BEGIN	
	SET @DriveLetterID = 
	(
		SELECT [DriveLetterID]
		FROM [hist].[SpaceUsed_DriveSizes_DriveLetter]
		WHERE [DriveLetter] = REPLACE(ISNULL(NULLIF(LEFT(@DriveLetter,1),''),'MP'),':','')
	)
END	


GO

--------------------------------------------------------------------------------------------------------------
USE [DBACentral]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
* Name
	[hist].[SpaceUsed_DriveSizes_InsertDriveMaster]

* Author
	Kathy J Toth
	
* Date
	2011.19.07
	
* Synopsis
	This procedure gathers all the supporting disk size and detailed information including the server name.
	
* Description
	This procedure gathers all the supporting disk size and detailed information including the server name.

* Examples
	EXEC [hist].[SpaceUsed_DriveSizes_InsertDriveMaster] @ServerName = 'UHAEMRSQLTEST01', @DriveLetter = 'E', @DriveLabel = 'SQL Data', @FreeSpaceMB = '34', @CapacityMB = '250'

* Dependencies
	[hist].[SpaceUsed_DriveSizes_DriveMaster]
	[hist].[SpaceUsed_DriveSizes_DriveLabel]
	[hist].[SpaceUsed_DriveSizes_DriveLetter]
	[hist].[SpaceUsed_DriveSizes_RunIDs]
	[hist].[ServerInventory_ServerIDs]
	
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
CREATE PROCEDURE [hist].[SpaceUsed_DriveSizes_InsertDriveMaster] (
	@ServerName		VARCHAR (256)
	,@DriveLetter	VARCHAR (2)
	,@DriveLabel	VARCHAR (30)
	,@DrivePath		VARCHAR (100)
	,@FreeSpaceMB	INT
	,@CapacityMB	INT
	,@MountPoint	BIT
	,@RunID			INT
	,@HostName		NVARCHAR (100)
)

AS

SET NOCOUNT ON

DECLARE 
	 @HistServerID	INT
	,@DriveLetterID INT
	,@DriveLabelID INT

-- Insert New RunID

IF NOT EXISTS
	(
		SELECT [RunID]
		FROM [DBACentral].[hist].[SpaceUsed_DriveSizes_RunIDs] AS SISRID
		WHERE [RunID] = @RunID
	)

BEGIN
	INSERT INTO [DBACentral].[hist].[SpaceUsed_DriveSizes_RunIDs] ( [RunID], [DateCreated] )
	VALUES (@RunID,GETDATE())
END

-- Get the server ID	
EXEC [hist].[ServerInventory_GetServerID] @ServerName = @ServerName, @ServerID = @HistServerID OUTPUT

-- Get the drive letter ID
EXEC [hist].[SpaceUsed_DriveSizes_GetDriveLetterIDs] @DriveLetter = @DriveLetter, @DriveLetterID = @DriveLetterID OUTPUT

-- Get the drive label ID
EXEC [hist].[SpaceUsed_DriveSizes_GetDriveLabelIDs] @DriveLabel = @DriveLabel, @DriveLabelID = @DriveLabelID OUTPUT

-- Insert all the gathered data plus the drive sizes
BEGIN
	INSERT INTO [hist].[SpaceUsed_DriveSizes_DriveMaster] ([RunID], [HistServerID], [DriveLetterID], [DriveLabelID], [HostName], [DrivePath], [FreeSpaceMB], [CapacityMB], [MountPoint])
	VALUES (@RunID, @HistServerID, @DriveLetterID, @DriveLabelID, @HostName, @DrivePath, @FreeSpaceMB, @CapacityMB, @MountPoint)		   
END

