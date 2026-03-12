/* Quando o servidor é reiniciado a tampdb é recriada, sendo assim podemos pegar a data de criação da DB tempdb */
SELECT * FROM sys.databases WHERE database_id = 2

/* It returns information about the last statistic reset or server restart */
SELECT
    FORMAT(sqlserver_start_time, 'yyyy-MM-dd HH:mm:ss') AS last_stats_reset_utc_date,
    FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') AS current_utc_date,
	DATEDIFF(HOUR, sqlserver_start_time, GETDATE()) AS hours_since_last_reset
FROM sys.dm_os_sys_info
