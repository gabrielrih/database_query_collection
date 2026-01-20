-- Get estimated rows on tables
SELECT
    schemaname || '.' || pg_stat_user_tables.relname AS table_name,
    reltuples AS estimated_rows
FROM pg_stat_user_tables 
JOIN pg_class ON pg_stat_user_tables.relid = pg_class.oid
WHERE pg_stat_user_tables.relname in ('pedido_situacao_complementar', 'pedido_situacao_alocacao')
ORDER BY reltuples DESC;
