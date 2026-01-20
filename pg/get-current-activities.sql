-- Get queries that are current running
SELECT
	S.pid,
	AGE(clock_timestamp(), query_start),
	usename,
	application_name,
	client_addr,
	query
FROM pg_stat_activity S
ORDER BY usename desc

-- Getting current activities for APPLICATION USERS
select datid, datname, pid, usename, wait_event_type, wait_event, state, query from pg_stat_activity
where usename not in ('azuresu', 'datadog', 'AADS_A_SAZ_AMBEV_DBA')
order by datname, usename

-- Getting sessions per database/user
select datname, usename, count(1) qty from pg_catalog.pg_stat_activity
where usename not in ('azuresu', 'datadog', 'AADS_A_SAZ_AMBEV_DBA') and usename is not null
group by datname, usename
order by qty desc

-- or just...
select * from pg_catalog.pg_stat_activity 
  
