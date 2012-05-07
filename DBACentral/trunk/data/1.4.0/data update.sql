USE DBACentral

DECLARE
	@SQLVersionID INT

PRINT ('Inserting control data into [ref].[ServerInventory_SQL_DataTypes]')

INSERT INTO [ref].[ServerInventory_SQL_ServerVersions] ([SQLVersionText],[SQLVersion],[StartingBuild],[EndingBuild])
VALUES
 ('6',6,121,151)
,('6.5',6.5,201,480)
,('7',7,517,1152)
,('2000',8,047,2273)
,('2005',9,1090,NULL)
,('2008',10,1019.17,NULL)
,('2008 R2',10.5,1092.20,NULL)

SELECT
	@SQLVersionID = [RefSQLVersionID]
FROM [ref].[ServerInventory_SQL_ServerVersions]
WHERE [SQLVersionText] = '2008'

-- 2008 Data Types
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'image',34,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'text',35,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'uniqueidentifier',36,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'date',40,3,10,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'time',41,5,16,7)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetime2',42,8,27,7)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetimeoffset',43,10,34,7)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'tinyint',48,1,3,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallint',52,2,5,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'int',56,4,10,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smalldatetime',58,4,16,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'real',59,4,24,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'money',60,8,19,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetime',61,8,23,3)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'float',62,8,53,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'sql_variant',98,8016,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'ntext',99,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bit',104,1,1,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'decimal',106,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'numeric',108,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallmoney',122,4,10,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bigint',127,8,19,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'hierarchyid',240,892,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'geometry',240,-1,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'geography',240,-1,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varbinary',165,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varchar',167,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'binary',173,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'char',175,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'timestamp',189,8,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nvarchar',231,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nchar',239,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'xml',241,-1,0,0)

SELECT
	@SQLVersionID = [RefSQLVersionID]
FROM [ref].[ServerInventory_SQL_ServerVersions]
WHERE [SQLVersionText] = '2008 R2'

-- 2008 R2 Data Types
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'image',34,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'text',35,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'uniqueidentifier',36,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'date',40,3,10,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'time',41,5,16,7)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetime2',42,8,27,7)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetimeoffset',43,10,34,7)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'tinyint',48,1,3,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallint',52,2,5,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'int',56,4,10,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smalldatetime',58,4,16,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'real',59,4,24,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'money',60,8,19,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetime',61,8,23,3)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'float',62,8,53,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'sql_variant',98,8016,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'ntext',99,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bit',104,1,1,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'decimal',106,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'numeric',108,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallmoney',122,4,10,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bigint',127,8,19,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'hierarchyid',240,892,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'geometry',240,-1,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'geography',240,-1,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varbinary',165,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varchar',167,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'binary',173,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'char',175,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'timestamp',189,8,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nvarchar',231,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nchar',239,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'xml',241,-1,0,0)


SELECT
	@SQLVersionID = [RefSQLVersionID]
FROM [ref].[ServerInventory_SQL_ServerVersions]
WHERE [SQLVersionText] = '2005'

-- 2005 Data Types
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'image',34,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'text',35,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'uniqueidentifier',36,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'tinyint',48,1,3,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallint',52,2,5,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'int',56,4,10,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smalldatetime',58,4,16,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'real',59,4,24,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'money',60,8,19,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetime',61,8,23,3)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'float',62,8,53,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'sql_variant',98,8016,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'ntext',99,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bit',104,1,1,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'decimal',106,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'numeric',108,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallmoney',122,4,10,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bigint',127,8,19,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varbinary',165,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varchar',167,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'binary',173,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'char',175,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'timestamp',189,8,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nvarchar',231,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nchar',239,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'xml',241,-1,0,0)

SELECT
	@SQLVersionID = [RefSQLVersionID]
FROM [ref].[ServerInventory_SQL_ServerVersions]
WHERE [SQLVersionText] = '2000'

-- SQL 2000
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bigint',127,8,19,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'binary',173,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'bit',104,1,1,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'char',175,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'datetime',61,8,23,3)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'decimal',106,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'float',62,8,53,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'image',34,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'int',56,4,10,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'money',60,8,19,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nchar',239,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'ntext',99,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'numeric',108,17,38,38)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'nvarchar',231,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'real',59,4,24,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smalldatetime',58,4,16,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallint',52,2,5,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'smallmoney',122,4,10,4)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'sql_variant',98,8016,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'text',35,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'timestamp',189,8,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'tinyint',48,1,3,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'uniqueidentifier',36,16,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varbinary',165,8000,0,0)
INSERT INTO [ref].[ServerInventory_SQL_DataTypes] ([RefSQLVersionID],[name],[system_type_id],[max_length],[precision],[scale])  VALUES (@SQLVersionID,'varchar',167,8000,0,0)

INSERT INTO [dbo].[ServerInventory_SQL_BuildLevelDesc] ([ProductVersion], [SQLVersion], [Build] ,[ProductLevel],[ServicePack],[CumulativeUpdate],[Description],[ReleaseDate],[KBArticle],[Link])
VALUES ('10.0.2710.0',2008,2710,'SP1',1,1,'Cumulative Update 1 for SP1','2009-04-15','969099','http://support.microsoft.com/kb/969099/')
,('10.0.2714.0',2008,2714,'SP1',1,2,'Cumulative Update 2 for SP1','2009-05-18','970315','http://support.microsoft.com/kb/970315/')
,('10.0.2718.0',2008,2718,'SP1',1,2,'4 hotfixes for CU2 SP1','2009-06-12',NULL,NULL)
,('10.0.2723.0',2008,2723 ,'SP1',1,3,'Cumulative Update 3 for SP1','2009-07-20','971491','http://support.microsoft.com/kb/971491/')
,('10.0.2734.0',2008,2734 ,'SP1',1,4,'Cumulative Update 4 for SP1','2009-09-21','973602','http://support.microsoft.com/kb/973602/')
,('10.0.1799.0',2008,1799 ,'RTM',0,4,'FIX: The cascading report parameters are inconsistent in a SQL Server 2008 Reporting Services report that contains three or more levels of cascading report parameters','2009-03-31',NULL,NULL)
,('10.0.1806.0',2008,1806 ,'RTM',0,5,'Cumulative Update 5 for RTM','2009-05-18','969531','http://support.microsoft.com/kb/969531/')
,('10.0.1812.0',2008,1812 ,'RTM',0,6,'Cumulative Update 6 for RTM','2009-07-20','971490','http://support.microsoft.com/kb/971490/')
,('10.0.1818.0',2008,1818 ,'RTM',0,7,'Cumulative Update 7 for RTM','2009-09-21','973601','http://support.microsoft.com/kb/973601/')
,('9.00.4224.00',2005,4224 ,'SP3',3,3,'FIX: Error message when you run a query that contains duplicate join conditions in SQL Server 2005: "Internal Query Processor Error: The query processor could not produce a query plan"','2009-05-22',NULL,NULL)
,('9.00.4226.00',2005,4226 ,'SP3',3,4,'Cumulative Update 4 for SP3','2009-05-22','970279','http://support.microsoft.com/kb/970279/')
,('9.00.4230.00',2005,4230 ,'SP3',3,5,'Cumulative Update 5 for SP3','2009-08-17','972511','http://support.microsoft.com/kb/972511/')
,('9.00.3302.00',2005,3302 ,'SP2',2,11,'2 hotfixes for SP2 CU11','2009-01-13',NULL,NULL)
,('9.00.3303.00',2005,3303 ,'SP2',2,11,'FIX: Error message when you run an UPDATE statement on a database that has the SNAPSHOT or READ COMMITTED SNAPSHOT isolation level enabled in SQL Server 2005: "The Database ID <Database ID>, Page (<N>:<N>), slot <N> for LOB data type node does not exist"','2009-02-10',NULL,NULL)
,('9.00.3310.00',2005,3310 ,'SP2',2,11,'MS09-004: Description of the security update for SQL Server 2005 QFE: February 10, 2009','2009-02-10',NULL,NULL)
,('9.00.3315.00',2005,3315 ,'SP2',2,12,'Cumulative Update 12 for SP2','2009-02-16','962970','http://support.microsoft.com/kb/962970/')
,('9.00.3320.00',2005,3320 ,'SP2',2,12,'FIX: Error message when you run the DBCC CHECKDB statement on a database in SQL Server 2005: "Unable to deallocate a kept page"','2009-03-17',NULL,NULL)
,('9.00.3325.00',2005,3325 ,'SP2',2,13,'Cumulative Update 13 for SP2','2009-04-20','967908','http://support.microsoft.com/kb/967908/')
,('9.00.3327.00',2005,3327 ,'SP2',2,13,'2 hotfixes for SP2 CU13','2009-05-26',NULL,NULL)
,('9.00.3328.00',2005,3328 ,'SP2',2,14,'Cumulative Update 14 for SP2','2009-06-15','970278','http://support.microsoft.com/kb/970278/')
,('9.00.3330.00',2005,3330 ,'SP2',2,15,'Cumulative Update 15 for SP2','2009-08-17','972510','http://support.microsoft.com/kb/972510/')
