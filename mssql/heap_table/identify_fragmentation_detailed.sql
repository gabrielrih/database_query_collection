DECLARE @MinFragmentationPercent DECIMAL(5,2) = 30.00;
DECLARE @MinSizeMB              DECIMAL(18,2) = 1000.00;
DECLARE @MinForwardedRecords    BIGINT = 0;

WITH HeapPhysicalStats AS
(
    SELECT
        ips.object_id,
        ips.index_id,

        MAX(ips.avg_fragmentation_in_percent)
            AS FragmentationPercent,

        SUM(ISNULL(ips.forwarded_record_count, 0))
            AS ForwardedRecordCount
    FROM sys.dm_db_index_physical_stats
    (
        DB_ID(),
        NULL,
        NULL,
        NULL,
        'DETAILED'
    ) AS ips
    WHERE ips.index_id = 0
      AND ips.alloc_unit_type_desc = 'IN_ROW_DATA'
      AND ips.index_level = 0
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
    WHERE ps.index_id = 0
    GROUP BY
        ps.object_id
)
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    i.type_desc AS IndexType,
    i.name AS IndexName,

    CAST(hps.FragmentationPercent AS DECIMAL(10,2))
        AS FragmentationPercent,

    hps.ForwardedRecordCount,

    hs.RecordCount,
    CAST(hs.SizeMB AS DECIMAL(18,2)) AS SizeMB,
    CAST(hs.UsedSizeMB AS DECIMAL(18,2)) AS UsedSizeMB
FROM HeapPhysicalStats AS hps
INNER JOIN HeapSize AS hs
    ON hs.object_id = hps.object_id
INNER JOIN sys.tables AS t
    ON t.object_id = hps.object_id
INNER JOIN sys.indexes AS i
    ON i.object_id = hps.object_id
   AND i.index_id = hps.index_id
WHERE hps.FragmentationPercent > @MinFragmentationPercent
  AND hs.SizeMB > @MinSizeMB
  AND hps.ForwardedRecordCount >= @MinForwardedRecords
ORDER BY
    hps.ForwardedRecordCount DESC
GO
