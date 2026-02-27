-- The size of all databases
SELECT
    d.name AS DatabaseName,
    CAST(SUM(CASE WHEN mf.type = 0 THEN mf.size ELSE 0 END) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS DataSizeGB,
    CAST(SUM(CASE WHEN mf.type = 1 THEN mf.size ELSE 0 END) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS LogSizeGB,
    CAST(SUM(mf.size) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS TotalSizeGB
FROM sys.databases d
INNER JOIN sys.master_files mf ON d.database_id = mf.database_id
GROUP BY d.name
ORDER BY TotalSizeGB DESC
GO
