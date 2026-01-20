-- Index usage
select * from pg_stat_user_indexes
where relname = 'pedido'
order by idx_scan desc
