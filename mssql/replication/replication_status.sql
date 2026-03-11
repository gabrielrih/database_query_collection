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


-- Watch sincronization replication lag between PRIMARY and the READ REPLICA
SET NOCOUNT ON

DECLARE @lag_threshold_in_seconds INT = 1
DECLARE @is_first BIT = 1
DECLARE @lag INT
DECLARE @dbid INT
DECLARE @sync_state NVARCHAR(60)
DECLARE @redo_queue BIGINT
DECLARE @commit_time DATETIME2
DECLARE @msg NVARCHAR(4000)

RAISERROR(
	'Monitoring replication. It triggers a message when the lag was greater than or equals to %d seconds.',
	0,
	1,
	@lag_threshold_in_seconds )
WITH NOWAIT

WHILE 1 = 1
BEGIN
    SELECT
        @dbid = database_id,
        @sync_state = synchronization_state_desc,
        @redo_queue = redo_queue_size,
        @commit_time = last_commit_time,
        @lag = DATEDIFF(SECOND, last_commit_time, GETUTCDATE())
    FROM sys.dm_database_replica_states
    WHERE is_primary_replica = 0  -- secondary
	
    IF @lag >= @lag_threshold_in_seconds
    BEGIN
        SET @msg = CONCAT(
            'Time: ', CONVERT(VARCHAR(23), GETDATE(), 121),
            ' | DB: ', DB_NAME(@dbid),
            ' | Lag: ', @lag, ' sec',
            ' | SyncState: ', @sync_state,
            ' | RedoQueue: ', @redo_queue,
            ' | LastCommit: ', CONVERT(VARCHAR(23), @commit_time, 121)
        )
        RAISERROR(@msg, 0, 1) WITH NOWAIT;
    END

    WAITFOR DELAY '00:00:05'

END

SET NOCOUNT OFF
