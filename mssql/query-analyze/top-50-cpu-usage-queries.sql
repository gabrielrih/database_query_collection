/*
	Queries que mais utilizaram CPU
*/
IF object_id('tempdb..#Temp_Trace') IS NOT NULL DROP TABLE #Temp_Trace

SELECT TOP 50 total_worker_time, SQL_HANDLE, execution_count, last_execution_time, last_worker_time
INTO #Temp_Trace
FROM sys.dm_exec_query_stats A
--where last_elapsed_time > 20
	--and last_execution_time > dateadd(ss,-600,getdate()) --ultimos 5 min
ORDER BY A.total_worker_time DESC

SELECT DISTINCT *
FROM #Temp_Trace A
CROSS APPLY sys.dm_exec_sql_text (SQL_HANDLE)
ORDER BY 1 DESC
GO

-- Pega as queries que usaram mais CPU separando por SECONDARY e PRIMARY
-- 	Útil para separar queries em um ambiente com AlwaysOn onde a aplicação usa também as replicas para consulta
DECLARE @MinimumAvgRunningTimeInMs AS INT = 2000
DECLARE @Page AS INT = 1
DECLARE @Count AS INT = 50
DECLARE @Skip AS INT = (@Page * @Count) - @Count

SELECT
    rs.plan_id,
    CASE rs.replica_group_id
        WHEN 1 THEN 'PRIMARY'
        WHEN 2 THEN 'SECONDARY'
        WHEN 3 THEN 'GEO SECONDARY'
        WHEN 4 THEN 'GEO HA SECONDARY'
        ELSE CONCAT('NAMED REPLICA_', rs.replica_group_id)
    END AS replica_type,
    FORMAT(MIN(rsi.start_time), 'yyyy-MM-dd HH:mm:ss') AS first_execution_time,
    FORMAT(MAX(rsi.end_time), 'yyyy-MM-dd HH:mm:ss') AS last_execution_time,
    SUM(rs.count_executions) AS count_executions,
    AVG(rs.avg_duration) / 1000 AS avg_duration_ms,
    MIN(rs.min_duration) / 1000 AS min_duration_ms,
    MAX(rs.max_duration) / 1000 AS max_duration_ms,
    AVG(rs.avg_cpu_time) / 1000 AS avg_cpu_ms,
    MAX(rs.max_cpu_time) / 1000 AS max_cpu_ms,
    SUM(rs.count_executions * rs.avg_cpu_time) / 1000 AS total_cpu_ms,

    AVG(rs.avg_logical_io_reads) AS avg_logical_io_reads,
    AVG(rs.avg_logical_io_writes) AS avg_logical_io_writes,
    AVG(rs.avg_physical_io_reads) AS avg_physical_io_reads,
    AVG(rs.avg_rowcount) AS avg_rowcount

FROM sys.query_store_runtime_stats rs
JOIN sys.query_store_runtime_stats_interval rsi ON rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
JOIN sys.query_store_plan p ON rs.plan_id = p.plan_id
JOIN sys.query_store_query q ON p.query_id = q.query_id
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
WHERE
	rsi.start_time >= '2026-03-06T08:00:00' AND rsi.start_time < '2026-03-06T09:00:00' AND
	rs.avg_duration > @MinimumAvgRunningTimeInMs * 1000
GROUP BY rs.plan_id, q.query_id, rs.replica_group_id, qt.query_sql_text, p.query_plan
ORDER BY total_cpu_ms DESC, count_executions DESC
OFFSET @Skip ROWS FETCH NEXT @Count ROWS ONLY
GO
