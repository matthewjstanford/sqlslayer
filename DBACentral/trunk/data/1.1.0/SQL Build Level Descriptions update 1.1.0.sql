USE [DBACentral]
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET XACT_ABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
BEGIN TRANSACTION

-- Add 7 rows to [dbo].[ServerInventory_SQL_BuildLevelDesc]
INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build], [ProductLevel], [ServicePack], [CumulativeUpdate], [Description], [ReleaseDate], [KBArticle], [Link]) VALUES ('10.0.1788.0', 2008, 1788, N'RTM', 0, 3, 'FIX: When you run a query against multiple remote tables in SQL Server 2008, the query runs slowly', '2009-01-28 00:00:00.000', NULL, NULL)
INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build], [ProductLevel], [ServicePack], [CumulativeUpdate], [Description], [ReleaseDate], [KBArticle], [Link]) VALUES ('10.0.1790.0', 2008, 1790, N'RTM', 0, 3, 'FIX: When you restore a SQL Server 2005 backup file in SQL Server 2008, the operation takes much longer than when you restore the same backup file in SQL Server 2005', '2009-02-04 00:00:00.000', NULL, NULL)
INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build], [ProductLevel], [ServicePack], [CumulativeUpdate], [Description], [ReleaseDate], [KBArticle], [Link]) VALUES ('10.0.1798.0', 2008, 1798, N'RTM', 0, 4, 'Cumulative Update 4 for RTM', '2009-03-16 00:00:00.000', '963036', 'http://support.microsoft.com/kb/963036')
INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build], [ProductLevel], [ServicePack], [CumulativeUpdate], [Description], [ReleaseDate], [KBArticle], [Link]) VALUES ('10.0.2531.0', 2008, 2531, N'SP1', 1, 0, 'Service Pack 1 for SQL Server 2008', '2009-04-07 00:00:00.000', '968369', 'http://support.microsoft.com/kb/968369')
INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build], [ProductLevel], [ServicePack], [CumulativeUpdate], [Description], [ReleaseDate], [KBArticle], [Link]) VALUES ('9.00.4213.00', 2005, 4213, N'SP3', 3, 2, 'Hotfix for Analysis Services bug', '2009-03-06 00:00:00.000', NULL, NULL)
INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build], [ProductLevel], [ServicePack], [CumulativeUpdate], [Description], [ReleaseDate], [KBArticle], [Link]) VALUES ('9.00.4216.00', 2005, 4216, N'SP3', 3, 2, 'FIX: The performance of database mirroring decreases when you run a database maintenance job that generates a large number of transaction log activities in SQL Server 2005', '2009-04-01 00:00:00.000', '967101', 'http://support.microsoft.com/kb/967101/')
INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build], [ProductLevel], [ServicePack], [CumulativeUpdate], [Description], [ReleaseDate], [KBArticle], [Link]) VALUES ('9.00.4220.00', 2005, 4220, N'SP3', 3, 3, 'Cumulative update package 3 for SQL Server 2005 Service Pack 3', '2009-04-20 00:00:00.000', '967909', 'http://support.microsoft.com/kb/967909/')

COMMIT TRANSACTION
GO

