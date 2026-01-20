SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename LIKE 'my_user_prefix_%'

