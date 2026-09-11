DECLARE @MinFragmentationPercent DECIMAL(5,2) = 30.00;
DECLARE @MinSizeMB DECIMAL(18,2) = 1000.00;

WITH HeapFragmentation AS
(
    SELECT
        ips.object_id,
        ips.index_id,
        MAX(ips.avg_fragmentation_in_percent) AS FragmentationPercent
    FROM sys.dm_db_index_physical_stats
    (
        DB_ID(),
        NULL,
        NULL,
        NULL,
        'LIMITED'
    ) AS ips
    WHERE ips.index_id = 0 -- Heap
    GROUP BY
        ips.object_id,
        ips.index_id
),
HeapSize AS
(
    SELECT
        ps.object_id,
        SUM(ps.row_count) AS RecordCount,
        SUM(ps.reserved_page_count) * 8.0 / 1024 AS SizeMB,
        SUM(ps.used_page_count) * 8.0 / 1024 AS UsedSizeMB
    FROM sys.dm_db_partition_stats AS ps
    WHERE ps.index_id = 0 -- Heap
    GROUP BY
        ps.object_id
)
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    i.type_desc AS IndexType,
    i.name AS IndexName,
    hf.FragmentationPercent,
    hs.RecordCount,
    CAST(hs.SizeMB AS DECIMAL(18,2)) AS SizeMB,
    CAST(hs.UsedSizeMB AS DECIMAL(18,2)) AS UsedSizeMB
FROM HeapFragmentation AS hf
INNER JOIN HeapSize AS hs
    ON hs.object_id = hf.object_id
INNER JOIN sys.tables AS t
    ON t.object_id = hf.object_id
INNER JOIN sys.indexes AS i
    ON i.object_id = hf.object_id
   AND i.index_id = hf.index_id
WHERE hf.FragmentationPercent > @MinFragmentationPercent
  AND hs.SizeMB > @MinSizeMB
ORDER BY
    hf.FragmentationPercent DESC
GO
