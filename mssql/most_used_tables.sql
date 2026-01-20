-- Most used tables
SELECT
    OBJECT_NAME(ius.object_id) AS TableName,
    SUM(user_seeks + user_scans + user_lookups) AS TotalReads,
    SUM(user_updates) AS TotalWrites
FROM sys.dm_db_index_usage_stats AS ius
JOIN sys.indexes AS idx ON ius.object_id = idx.object_id AND ius.index_id = idx.index_id
WHERE ius.database_id = DB_ID() -- current database
GROUP BY OBJECT_NAME(ius.object_id)
ORDER BY TotalReads DESC, TotalWrites DESC
GO

-- It's based on the last server restart
SELECT
    sqlserver_start_time AS "last_server_restart_date",
    GETDATE() AS "current_date",
    DATEDIFF(HOUR, sqlserver_start_time, GETDATE()) AS hours_since_restart
FROM sys.dm_os_sys_info;
GO
