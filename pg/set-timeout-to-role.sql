DO $$
DECLARE 
    v_users RECORD;
BEGIN

    FOR v_users IN SELECT rolname FROM pg_roles WHERE rolname = 'ebd-usr-app-rundeck-prd-rw' LOOP
    --FOR v_users IN SELECT rolname FROM pg_roles WHERE rolname LIKE 'usr_hoop_%' LOOP
        RAISE NOTICE 'Timeout for user %', v_users.rolname;
        EXECUTE FORMAT('ALTER ROLE %I SET idle_in_transaction_session_timeout = ''20min''', v_users.rolname);
        EXECUTE FORMAT('ALTER ROLE %I SET statement_timeout  = ''20min''', v_users.rolname);
        EXECUTE FORMAT('ALTER ROLE %I SET lock_timeout = ''20min''', v_users.rolname);
    END LOOP;

RAISE NOTICE 'Finishing set timeouts for hoop users';    

END $$;