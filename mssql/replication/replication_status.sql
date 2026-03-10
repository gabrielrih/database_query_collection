-- Status da replica
-- Azure SQL Database BC PaaS
-- Reference: https://learn.microsoft.com/en-us/azure/azure-sql/database/troubleshoot-geo-replication-redo?view=azuresql
select
	database_id,
	is_primary_replica,
	synchronization_state_desc,
	synchronization_health,
	redo_queue_size,
	last_commit_time,
	getdate() current_date_time,
	DATEDIFF(
        SECOND,
        last_commit_time,
        GETUTCDATE()
    ) AS replication_lag_seconds
from sys.dm_database_replica_states
go
