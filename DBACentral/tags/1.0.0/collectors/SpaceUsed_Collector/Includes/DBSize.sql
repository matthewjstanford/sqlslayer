USE master

SET NOCOUNT ON

SELECT
	@@ServerName	AS ServerName
	,DBName
	,[ROWS]			as DataSizeMB
	,[LOG]			as LogSizeMB
FROM
(
	SELECT 
		d.name						as DBName
		,mf.type_desc
		,mf.size * 8/1024			as [SizeMB]
	FROM sys.master_files mf
	INNER JOIN sys.databases d
		ON d.database_id = mf.database_id
	WHERE d.source_database_id IS NULL
) p
PIVOT (
	SUM(SizeMB)
	FOR type_desc IN ([LOG],[ROWS])
) as PT
ORDER BY DBName