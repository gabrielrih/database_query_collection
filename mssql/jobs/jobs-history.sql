/**
	All jobs history in a day
*/
SELECT 
    j.name,
    j.description,
    h.step_id,
    h.step_name,
    h.message,
    h.run_status,
    h.run_date,
    h.run_time,
    h.run_duration
FROM msdb.dbo.sysjobhistory h
INNER JOIN msdb.dbo.sysjobs j 
    ON h.job_id = j.job_id
WHERE h.run_date = 20210611   -- using numeric format, no quotes needed
ORDER BY h.run_time;
