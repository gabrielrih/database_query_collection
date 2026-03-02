-- This query performes well on the uk_prices_3 table, because the filter are using the columns of the primary key
SELECT MAX(price) AS max_price
FROM uk_prices_3
WHERE postcode1 = 'DH1' AND postcode2 = '1AD';

-- However, may I want to run the same query but instead, filter by the town
-- Note that in this case a full table scan is requires since the town column is not on the primary key
SELECT MAX(price) AS max_price
FROM uk_prices_3
WHERE town = 'DURHAM';

-- Here it's one possibility of the use of incremental materialized views
-- I can DUPLICATE the data in other table, but using a different primary key
CREATE TABLE uk_prices_by_town(
    price UInt32,
    date Date,
    street LowCardinality(String),
    town LowCardinality(String),
    district LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY town;

-- And then you create the materialized view to keep the uk_prices_by_town table updated for when new a insert comes to the uk_prices_3 table (source table)
CREATE MATERIALIZED VIEW uk_prices_by_town_view
TO uk_prices_by_town
AS
    SELECT price, date, street, town, district
    FROM uk_prices_3;

-- Note that you you SELECT data from the target table and no new INSERT came to the source table, you'll see no data
-- There is because the materialized view will just copy new data to the target table...
SELECT * FROM uk_prices_by_town;

-- ... the previous data, old data, must be copyed manually to the target table
-- obs: in production, if you're continuosly inserting data on the source table, you'll probable need to use a WHERE clause to copy just the old data,
-- and not the new ones already inserted on the target table. Example, WHERE date < toDateTime('2026-02-01 12:30:00')
INSERT INTO uk_prices_by_town
    SELECT price, date, street, town, district
    FROM uk_prices_3; 

-- Finally, note that if you run the previous query but now using the target table, the query will run much faster
SELECT MAX(price) AS max_price
FROM uk_prices_by_town
WHERE town = 'DURHAM';
