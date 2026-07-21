-- First of all, you must grant the older_owner permissions to the new_onwer using the GRANT command
GRANT new_owner_name to old_owner_name;

-- DB
-- Change the database owner
-- IMPORTANT: When you run it the db objects owner doesn't change. You must change it one by one.
ALTER DATABASE checkin_dev OWNER TO adminalmoxgo;

-- TABLES
-- Creates the ALTER TABLE commands to change the table owner from all tables from a specific db
-- Example: ALTER TABLE public."Area" OWNER to adminalmoxgo;
SELECT 'ALTER TABLE '|| schemaname || '."' || tablename ||'" OWNER TO new_owner_name;'
FROM pg_tables
WHERE   schemaname NOT IN ('information_schema', 'pg_catalog', 'cron','pg_toast') AND
        tableowner <> 'new_owner_name' AND
        tablename NOT IN ('__EFMigrationsHistory') -- Table used by Azure PaaS
ORDER BY schemaname, tablename;


-- SEQUENCES
-- Creates the ALTER SEQUENCE commands to change the sequence owner from all sequences from a specific db
-- Example: ALTER SEQUENCE public."Area_id_seq" OWNER TO adminalmoxgo;
SELECT 'ALTER SEQUENCE ' || schemaname || '."' || sequencename || '" OWNER TO new_owner_name;'
FROM pg_sequences
WHERE   schemaname NOT IN ('information_schema', 'pg_catalog', 'cron', 'pg_toast') AND
  sequenceowner <> 'new_owner_name'
ORDER BY schemaname, sequencename;
