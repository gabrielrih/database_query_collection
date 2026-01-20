select 
	a.relname AS table_name,
	b.nspname as schema_name,
	a.reltuples::bigint AS estimated_rows
FROM pg_class a
inner join pg_namespace b on a.relnamespace = b.oid
where
	a.relname = 'table-name' and
	b.nspname = 'schema-name';
