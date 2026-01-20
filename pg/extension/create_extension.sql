-- Check if an extension exists
SELECT * 
FROM pg_available_extensions 
WHERE name = 'pg_stat_statements' and installed_version is not null;

-- Create extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;