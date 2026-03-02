-- Create the target table for the materialized view
CREATE TABLE uk_prices_town_stats (
    town LowCardinality(String),
    average_price Decimal64(10),
    max_price UInt32
)
ENGINE MergeTree
ORDER BY town;

-- Create the materialized view that populates the target table
CREATE MATERIALIZED VIEW uk_prices_town_stats_mv
REFRESH EVERY 1 HOUR
TO uk_prices_town_stats
AS
    SELECT
        town,
        AVG(price) AS average_price,
        MAX(price) AS max_price
    FROM uk_prices_3
    GROUP BY town;

SELECT * FROM uk_prices_town_stats
WHERE town = 'DURHAM';

-- To refresh the materialized view manually, you can use the following command:
SYSTEM REFRESH VIEW uk_prices_town_stats_mv;

-- And you can change the refresh interval of the materialized view using:
ALTER TABLE uk_prices_town_stats_mv
MODIFY REFRESH EVERY 30 MINUTE;

-- To check the status of the materialized view refreshes, you can query the system.view_refreshes table
SELECT status, last_success_time, last_refresh_time, next_refresh_time, read_rows, written_rows
FROM system.view_refreshes
WHERE view = 'uk_prices_town_stats_mv';
