INSERT INTO [dbo].[ServerInventory_SQL_AttributeList]([ServerID],[AttribID],[AttribValue])
SELECT 
      [ServerID]
      ,(SELECT AttribID FROM [dbo].[ServerInventory_SQL_AttributeMaster]  WHERE [AttribName] = 'SpaceUsed_Collect_Database')
      ,'TRUE'
FROM [dbo].[ServerInventory_SQL_AllServers_vw] 
WHERE [FullName] IN
(
	SELECT 
		[FullName]
	FROM [dbo].[ServerInventory_SQL_AllServers_vw] 

	EXCEPT

	SELECT 
		[ServerName]
	FROM [ServerInventory_SQL_ServerAttributes_vw]
	WHERE [AttribName] = 'SpaceUsed_Collect_Database'
)
