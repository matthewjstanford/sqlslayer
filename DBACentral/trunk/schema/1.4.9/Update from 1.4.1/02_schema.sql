USE [DBACentral]
GO

IF OBJECT_ID('[dbo].[ServerInventory_SQL_SQLBackup_Audit_InsertValue]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[ServerInventory_SQL_SQLBackup_Audit_InsertValue]

DELETE FROM dbo.ServerInventory_SQL_AttributeMaster
WHERE AttribName IN ('SQLBackup_Version','SQLBackup_License','SQLBackup_SerialNumber','SQLBackup_AuditDate')

INSERT INTO ServerInventory_SQL_AttributeMaster (AttribName)
VALUES ('SQLBackup_Version'),('SQLBackup_License'),('SQLBackup_SerialNumber'),('SQLBackup_AuditDate')

/****** Object:  StoredProcedure [hist].[ServerInventory_SQL_Configurations_InsertValue]    Script Date: 08/02/2010 14:40:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************
**  Name:			[dbo].[ServerInventory_SQL_SQLBackup_Audit_InsertValue]
**  Desc:			Saves RedGate SQLBackup specific information to the attributes
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2010-08-02
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE PROCEDURE [dbo].[ServerInventory_SQL_SQLBackup_Audit_InsertValue] (
	@ServerID					INT
	,@Version					NVARCHAR(1000)
	,@License					NVARCHAR(1000)
	,@SerialNumber				NVARCHAR(1000)
)
AS

DECLARE @ALT dbo.AttributeListType

INSERT INTO @ALT (AttributeName,AttributeValue)
VALUES 
	('SQLBackup_Version',@Version)
	,('SQLBackup_License',@License)
	,('SQLBackup_SerialNumber',@SerialNumber)
	,('SQLBackup_AuditDate',CAST(GETDATE() AS NVARCHAR(1000)))

EXEC [dbo].[ServerInventory_SQL_SaveAttributes] @ServerID, @ALT

GO


