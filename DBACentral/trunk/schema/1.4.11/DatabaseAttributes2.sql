USE DBACentral
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX__DatabaseAttributeValues__file_id')
	DROP INDEX [hist].[ServerInventory_SQL_DatabaseAttributeValues].[IX__DatabaseAttributeValues__file_id]

IF OBJECT_ID('[hist].[ServerInventory_SQL_SysMasterFiles_vw]','V') IS NOT NULL
	DROP VIEW [hist].[ServerInventory_SQL_SysMasterFiles_vw]
IF OBJECT_ID('[hist].[ServerInventory_SQL_SysDatabases_vw]','V') IS NOT NULL
	DROP VIEW [hist].[ServerInventory_SQL_SysDatabases_vw]

GO
CREATE NONCLUSTERED INDEX [IX__DatabaseAttributeValues__file_id]
ON [hist].[ServerInventory_SQL_DatabaseAttributeValues] ([file_id])
INCLUDE ([DatabaseAttributeValueID],[HistServerID],[HistDatabaseID],[DatabaseAttributeID])
WITH (FILLFACTOR = 85)

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_SysMasterFiles_vw]
**  Desc:			Assembles all database file attributes into sysmasterfiles style view
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2011.04.11
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [hist].[ServerInventory_SQL_SysMasterFiles_vw]
AS
WITH FILTER AS (
	SELECT 
		MAX(v.[DatabaseAttributeValueID]) AS [MaxAttributeValueID]
	FROM [hist].[ServerInventory_SQL_DatabaseAttributeValues] v
	WHERE [file_id] IS NOT NULL -- DB Files Only
	GROUP BY [HistServerID], [HistDatabaseID], [file_id], [DatabaseAttributeID]
), DBAttributes AS (
	SELECT
		s.[ServerName]
		,d.[DBName]
		,v.[file_id]
		,a.[AttributeName]
		,v.[AttributeValue]
	FROM [hist].[ServerInventory_SQL_DatabaseAttributeValues] v
	INNER JOIN FILTER f
		ON v.[DatabaseAttributeValueID] = f.[MaxAttributeValueID]
	INNER JOIN [hist].[ServerInventory_SQL_DatabaseAttributeMaster] a
		ON v.[DatabaseAttributeID] = a.[DatabaseAttributeID]
	INNER JOIN [hist].[ServerInventory_ServerIDs] s
		ON v.[HistServerID] = s.[HistServerID]
	INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
		ON v.[HistDatabaseID] = d.[DatabaseID]
)
SELECT
	[ServerName]
	,[DBName]						AS [database_name]
	,[file_id]
	,pvt.[type_desc]
	,pvt.[data_space_id]
	,pvt.[name]
	,pvt.[physical_name]
	,pvt.[state_desc]
	,pvt.[size]
	,CAST(CONVERT(DECIMAL(12,2),pvt.[size]) * 8 / 1024. AS DECIMAL(12,2))	AS [size_MB]
	,pvt.[max_size]
	,CAST(CONVERT(DECIMAL(12,2),pvt.[max_size]) * 8 / 1024. AS DECIMAL(12,2))	AS [max_size_MB]
	,pvt.[growth]
	,CAST(CASE 
		WHEN pvt.[is_percent_growth] = 0 
			THEN CONVERT(DECIMAL(12,2),pvt.[growth]) * 8 / 1024.
		ELSE CONVERT(DECIMAL(12,2),pvt.[size]) * 8 / 1024. * CONVERT(DECIMAL(12,2),pvt.[growth]) / 100
 	END	AS DECIMAL(12,2))							AS [next_growth_MB]
	,pvt.[is_media_read_only]
	,pvt.[is_read_only]
	,pvt.[is_sparse]
	,pvt.[is_percent_growth]
	,pvt.[is_name_reserved]
FROM
(
	SELECT
		[ServerName]
		,[DBName]
		,[file_id]
		,[AttributeName]
		,[AttributeValue]
	FROM DBAttributes
) p
PIVOT (
	MAX(p.[AttributeValue])
	FOR [p].[AttributeName] IN (
		[type_desc]
		,[max_size]
		,[is_sparse]
		,[physical_name]
		,[is_read_only]
		,[is_percent_growth]
		,[state_desc]
		,[name]
		,[growth]
		,[size]
		,[is_name_reserved]
		,[data_space_id]
		,[is_media_read_only]
	)
) pvt

GO
/*******************************************************************************************************
**  Name:			[hist].[ServerInventory_SQL_SysDatabases_vw]
**  Desc:			Assembles all database attributes into sysdatabases style view
**  Auth:			Matt Stanford (SQLSlayer)
**  Date:			2011.04.11
**  Debug:			
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:		Author:			Description:
**	--------	--------		---------------------------------------
********************************************************************************************************/
CREATE VIEW [hist].[ServerInventory_SQL_SysDatabases_vw]
AS

WITH FILTER AS (
	SELECT 
		MAX(v.[DatabaseAttributeValueID]) AS [MaxAttributeValueID]
	FROM [hist].[ServerInventory_SQL_DatabaseAttributeValues] v
	WHERE [file_id] IS NULL -- DB Options only
	GROUP BY [HistServerID], [HistDatabaseID], [DatabaseAttributeID]
), DBAttributes AS (
	SELECT
		s.[ServerName]
		,d.[DBName]
		,a.[AttributeName]
		,v.[AttributeValue]
		,v.[DateCreated]
		,v.[DateLastSeenOn]
	FROM [hist].[ServerInventory_SQL_DatabaseAttributeValues] v
	INNER JOIN FILTER f
		ON v.[DatabaseAttributeValueID] = f.[MaxAttributeValueID]
	INNER JOIN [hist].[ServerInventory_SQL_DatabaseAttributeMaster] a
		ON v.[DatabaseAttributeID] = a.[DatabaseAttributeID]
	INNER JOIN [hist].[ServerInventory_ServerIDs] s
		ON v.[HistServerID] = s.[HistServerID]
	INNER JOIN [hist].[ServerInventory_SQL_DatabaseIDs] d
		ON v.[HistDatabaseID] = d.[DatabaseID]
)
SELECT 
	[ServerName1]					AS [ServerName]
	,[DBName1]						AS [database_name]
	,pvt.[database_id]
	,pvt.[source_database_id]
	,pvt.[owner_sid]
	,pvt.[create_date]
	,pvt.[compatibility_level]
	,pvt.[collation_name]
	,pvt.[user_access_desc]
	,pvt.[is_read_only]
	,pvt.[is_auto_close_on]
	,pvt.[is_auto_shrink_on]
	,pvt.[state_desc]
	,pvt.[is_in_standby]
	,pvt.[is_cleanly_shutdown]
	,pvt.[is_supplemental_logging_enabled]
	,pvt.[snapshot_isolation_state_desc]
	,pvt.[is_read_committed_snapshot_on]
	,pvt.[recovery_model_desc]
	,pvt.[page_verify_option_desc]
	,pvt.[is_auto_create_stats_on]
	,pvt.[is_auto_update_stats_on]
	,pvt.[is_auto_update_stats_async_on]
	,pvt.[is_ansi_null_default_on]
	,pvt.[is_ansi_nulls_on]
	,pvt.[is_ansi_padding_on]
	,pvt.[is_ansi_warnings_on]
	,pvt.[is_arithabort_on]
	,pvt.[is_concat_null_yields_null_on]
	,pvt.[is_numeric_roundabort_on]
	,pvt.[is_quoted_identifier_on]
	,pvt.[is_recursive_triggers_on]
	,pvt.[is_cursor_close_on_commit_on]
	,pvt.[is_local_cursor_default]
	,pvt.[is_fulltext_enabled]
	,pvt.[is_trustworthy_on]
	,pvt.[is_db_chaining_on]
	,pvt.[is_parameterization_forced]
	,pvt.[is_master_key_encrypted_by_server]
	,pvt.[is_published]
	,pvt.[is_subscribed]
	,pvt.[is_merge_published]
	,pvt.[is_distributor]
	,pvt.[is_sync_with_backup]
	,pvt.[service_broker_guid]
	,pvt.[is_broker_enabled]
	,pvt.[log_reuse_wait_desc]
	,pvt.[is_date_correlation_on]
	,pvt.[is_cdc_enabled]
	,pvt.[is_encrypted]
	,pvt.[is_honor_broker_priority_on]
	,(SELECT MIN([DateCreated])
	FROM DBAttributes
	WHERE [ServerName] = [ServerName1]
	AND [DBName] = [DBName1]
	GROUP BY [ServerName], [DBName])  AS [DateCreated]
	,(SELECT MAX([DateLastSeenOn])
	FROM DBAttributes
	WHERE [ServerName] = [ServerName1]
	AND [DBName] = [DBName1]
	GROUP BY [ServerName], [DBName])  AS [DateLastSeenOn]
FROM (
	SELECT
		[ServerName] AS [ServerName1]
		,[DBName] AS [DBName1]
		,[AttributeName]
		,[AttributeValue]
	FROM DBAttributes
) p
PIVOT (
	MAX(p.[AttributeValue])
	FOR [p].[AttributeName] IN (
		[database_id]
		,[source_database_id]
		,[owner_sid]
		,[create_date]
		,[compatibility_level]
		,[collation_name]
		,[user_access_desc]
		,[is_read_only]
		,[is_auto_close_on]
		,[is_auto_shrink_on]
		,[state_desc]
		,[is_in_standby]
		,[is_cleanly_shutdown]
		,[is_supplemental_logging_enabled]
		,[snapshot_isolation_state_desc]
		,[is_read_committed_snapshot_on]
		,[recovery_model_desc]
		,[page_verify_option_desc]
		,[is_auto_create_stats_on]
		,[is_auto_update_stats_on]
		,[is_auto_update_stats_async_on]
		,[is_ansi_null_default_on]
		,[is_ansi_nulls_on]
		,[is_ansi_padding_on]
		,[is_ansi_warnings_on]
		,[is_arithabort_on]
		,[is_concat_null_yields_null_on]
		,[is_numeric_roundabort_on]
		,[is_quoted_identifier_on]
		,[is_recursive_triggers_on]
		,[is_cursor_close_on_commit_on]
		,[is_local_cursor_default]
		,[is_fulltext_enabled]
		,[is_trustworthy_on]
		,[is_db_chaining_on]
		,[is_parameterization_forced]
		,[is_master_key_encrypted_by_server]
		,[is_published]
		,[is_subscribed]
		,[is_merge_published]
		,[is_distributor]
		,[is_sync_with_backup]
		,[service_broker_guid]
		,[is_broker_enabled]
		,[log_reuse_wait_desc]
		,[is_date_correlation_on]
		,[is_cdc_enabled]
		,[is_encrypted]
		,[is_honor_broker_priority_on]
		)
) pvt