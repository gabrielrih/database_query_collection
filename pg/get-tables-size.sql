SELECT
    relname AS table_name,
    schemaname as schema_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS extra_size
FROM
    pg_catalog.pg_statio_user_tables
--where relname = 'table_name' and schemaname = 'schema_name'
ORDER BY
    pg_total_relation_size(relid) DESC;
