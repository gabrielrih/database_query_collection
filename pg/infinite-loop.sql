DO $$
BEGIN
    LOOP
        RAISE NOTICE 'Loop rodando...';
        PERFORM pg_sleep(30);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
