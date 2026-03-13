-- Check the compression ratio of a table
SELECT
    formatReadableSize(sum(data_uncompressed_bytes) AS u) AS uncompressed,
    formatReadableSize(sum(data_compressed_bytes) AS c) AS compressed,
    round(u / c, 2) AS compression_ratio,
    count() AS num_of_parts
FROM system.parts
WHERE table = 'uk_prices_3' AND active = 1;

-- Check the compression ratio for each column in a table
SELECT
    column,
    formatReadableSize(sum(column_data_uncompressed_bytes) AS u) AS uncompressed,
    formatReadableSize(sum(column_data_compressed_bytes) AS c) AS compressed,
    round(u / c, 2) AS compression_ratio
FROM system.parts_columns
WHERE table = 'uk_prices_3' AND active = 1
GROUP BY column;
