-- DBS
-- Check the DB owner
SELECT d.datname as "Name", pg_catalog.pg_get_userbyid(d.datdba) as "Owner"
FROM pg_catalog.pg_database d
WHERE d.datname = 'database-name'
ORDER BY 1;

-- TABLES
-- Check the table owner
SELECT schemaname, tablename, tableowner
FROM pg_tables
WHERE   schemaname NOT IN ('information_schema', 'pg_catalog', 'cron','pg_toast')

/**
 * Pega os owner de todos os objetos a partir da database selecionada.
 * 	DB > Schemas > Tables > Functions > Sequences
 */
select pg_get_userbyid(proowner) from pg_proc where pronamespace not in (to_regnamespace('pg_toast')::oid, to_regnamespace('pg_catalog')::oid, to_regnamespace('information_schema')::oid)
union
select sequenceowner from pg_sequences
union 
select tableowner from pg_tables where schemaname not in ('pg_toast', 'pg_catalog', 'information_schema')
union 
select pg_get_userbyid(nspowner) from pg_namespace where nspname not in ('pg_toast', 'pg_catalog', 'information_schema', 'public')
union
select pg_catalog.pg_get_userbyid(d.datdba) from pg_catalog.pg_database d where d.datname = current_database();