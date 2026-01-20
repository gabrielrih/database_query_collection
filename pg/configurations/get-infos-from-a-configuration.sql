/**
    Getting more information about a specific configuration using SQL

    WHERE:
        max_connections is the configuration name. It could be any other configuration name.
        boot_val is the value for that specific configuration.
        pending_restart indicates if a restart is necessary to get the new configuration value (true or false).
*/
SELECT name, source, boot_val, sourcefile, pending_restart FROM pg_settings
WHERE name='max_connections'