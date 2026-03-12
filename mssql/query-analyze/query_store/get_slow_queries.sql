SELECT TOP 50
	stat.plan_id,
	Qry.query_id AS query_id,
	Txt.query_sql_text AS query,
	FORMAT(MIN(stat.first_execution_time), 'yyyy-MM-dd HH:MM:ss') AS first_execution_time,
	FORMAT(MAX(stat.last_execution_time), 'yyyy-MM-dd HH:MM:ss') AS last_execution_time,
	SUM(stat.count_executions) AS count_executions,
	AVG(stat.avg_duration) / 1000 AS avg_duration_in_ms,
	MIN(stat.min_duration) / 1000 AS min_duration_in_ms,
	MAX(stat.max_duration) / 1000 AS max_duration_in_ms,
    AVG(stat.avg_logical_io_reads) AS avg_logical_io_reads,
	AVG(stat.avg_logical_io_writes) AS avg_logical_io_writes,
	AVG(stat.avg_physical_io_reads) AS avg_physical_io_reads,
	AVG(stat.avg_rowcount) AS avg_rowcount
FROM sys.query_store_runtime_stats stat
INNER JOIN sys.query_store_plan AS Pl ON stat.plan_id = Pl.plan_id
INNER JOIN sys.query_store_query AS Qry ON Pl.query_id = Qry.query_id
INNER JOIN sys.query_store_query_text AS Txt ON Qry.query_text_id = Txt.query_text_id
WHERE runtime_stats_interval_id IN (
	SELECT runtime_stats_interval_id FROM sys.query_store_runtime_stats_interval
	WHERE start_time between '2024-04-19T00:00:00.000' AND '2024-04-20T00:00:00.000'
)
and avg_duration > 10000 * 1000 -- in microseconds
GROUP BY stat.plan_id, Qry.query_id, Txt.query_sql_text
ORDER BY count_executions DESC, avg_duration_in_ms DESC
GO


-- Pega as queries que usaram mais CPU separando por SECONDARY e PRIMARY
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
    AVG(rs.avg_rowcount) AS avg_rowcount,
	qt.query_sql_text AS query,
    p.query_plan AS query_plan
FROM sys.query_store_runtime_stats rs
JOIN sys.query_store_runtime_stats_interval rsi ON rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
JOIN sys.query_store_plan p ON rs.plan_id = p.plan_id
JOIN sys.query_store_query q ON p.query_id = q.query_id
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
WHERE
	rsi.start_time >= '2026-03-12T00:00:00' AND rsi.start_time < '2026-03-12T13:00:00' AND
	rs.avg_duration > @MinimumAvgRunningTimeInMs * 1000
GROUP BY rs.plan_id, q.query_id, rs.replica_group_id, qt.query_sql_text, p.query_plan
GO
ORDER BY total_cpu_ms DESC, count_executions DESC
OFFSET @Skip ROWS FETCH NEXT @Count ROWS ONLY
GO
