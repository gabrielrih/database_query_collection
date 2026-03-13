-- Getting the compressed and uncompressed size on disk of a table
SELECT
    formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size
FROM system.parts
WHERE table = 'uk_prices_1' AND active = 1;

-- Getting the compressed and uncompressed size on disk across all replicas in the cluster
SELECT
    instance,
    * EXCEPT instance APPLY formatReadableSize
FROM (
    SELECT
        hostname() AS instance,
        sum(primary_key_size),
        sum(primary_key_bytes_in_memory),
        sum(primary_key_bytes_in_memory_allocated)
    FROM clusterAllReplicas(default, system.parts)
    GROUP BY instance
);

-- Getting the size of the columns of a table
SELECT
    name,
    formatReadableSize(data_compressed_bytes),
    formatReadableSize(data_uncompressed_bytes)
FROM system.columns
WHERE table = 'uk_prices_3'
ORDER BY data_compressed_bytes DESC;
