/**
    Commands to change config values

    All ALTER SYSTEM commands change the configurations in postgres.auto.conf
    The configurationes in this file overrides the postgresql.conf
    
    The main advantage to change configs this way is to DON'T TOUCH the postgresql.conf file.
*/

-- Change a value for a specific parameter
ALTER SYSTEM SET work_mem='10MB'
SELECT * FROM pg_reload_conf()

-- Reset all config to the default
ALTER SYSTEM RESET ALL