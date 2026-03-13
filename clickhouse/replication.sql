-- Check the cluster configuration and the names of the shards and replicas
SELECT
    cluster,
    shard_num,
    replica_num,
    database_shard_name,
    database_replica_name
FROM system.clusters;

-- Getting the queries executed on a single node (you can choose any of the nodes in the cluster to run this query)
SELECT event_time, query
FROM system.query_log
ORDER BY event_time DESC
LIMIT 20;


-- Here you can run the same query on each node of the cluster to see the queries executed on each node.
SELECT event_time, query
FROM clusterAllReplicas(default, system.query_log)
ORDER BY  event_time DESC
LIMIT 20;

-- Checks the parts of the table on a single node
SELECT count()
FROM system.parts;

-- See the parts in all nodes
SELECT count()
FROM clusterAllReplicas(default, system.parts);
