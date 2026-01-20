-- Single database
SELECT pg_size_pretty( pg_database_size('dbname') );

-- All databases
SELECT datname AS database_name, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY pg_database_size(datname) DESC;
