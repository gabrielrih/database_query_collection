SELECT
    tbl.n_live_tup,
    tbl.n_dead_tup,
    tbl.schemaname || '.' || tbl.relname AS tabl,
    (psut.n_dead_tup::float / (psut.n_live_tup + psut.n_dead_tup) * 100) AS dead_tuple_percent,
    pg_size_pretty(pg_total_relation_size(tbl.schemaname || '.' || tbl.relname)) AS table_size
FROM
    pg_stat_all_tables tbl
JOIN
    pg_stat_user_tables psut ON (tbl.relname = psut.relname AND tbl.schemaname = psut.schemaname)
JOIN
    pg_class ON psut.relid = pg_class.oid
WHERE
    tbl.schemaname NOT LIKE 'pg_%'
    AND (psut.n_live_tup + psut.n_dead_tup) != 0
    AND (psut.n_dead_tup::float / (psut.n_live_tup + psut.n_dead_tup) * 100) != 0
ORDER BY
    dead_tuple_percent DESC;
