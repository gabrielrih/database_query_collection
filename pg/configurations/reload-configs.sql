/*
    It reloads the configuration file and all configurations
    This is needed to PG read the configs files and reload the configurations to the pg_settings database.
    It's important also to comment that some parameters required the service restart to take effect.
*/
SELECT * FROM pg_reload_conf();