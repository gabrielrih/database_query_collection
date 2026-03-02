-- Let's first create an example table
CREATE TABLE uk_prices_3
(
    `id` UUID,
    `price` UInt32,
    `date` DateTime,
    `postcode1` LowCardinality(String),
    `postcode2` LowCardinality(String),
    `type` Enum8('other' = 0, 'terraced' = 1, 'semi-detached' = 2, 'detached' = 3, 'flat' = 4),
    `is_new` UInt8,
    `duration` Enum8('unknown' = 0, 'freehold' = 1, 'leasehold' = 2),
    `addr1` String,
    `addr2` String,
    `street` String,
    `locality` LowCardinality(String),
    `town` LowCardinality(String),
    `district` LowCardinality(String),
    `county` LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (postcode1, postcode2)
ORDER BY (postcode1, postcode2);

-- If you filter by town for example you'll see it will performe a full table scan as the town column is not part of the primary key
SELECT AVG(price) AS avg_price
FROM uk_prices_3
WHERE town = 'DURHAM';

-- However, if we add a projection that groups by town, then the query will be able to use the projection and avoid scanning the entire table
-- Note here that this command will not actually create the projection, it will just define it.
--  The projection will be created in the background and will be available for use once it's ready.
--  You can check the status of the projection using the system.projections table.
ALTER TABLE uk_prices_3
ADD PROJECTION town_sort_projection
(
    SELECT
        town, price, date, street, locality
    ORDER BY town
);
SELECT * FROM system.mutations;

-- When the projection is ready, you need to materialize it before it can be used by queries.
-- This is necessary just when you create a project on an existing table, if you create a projection at the same time as the table, it will be materialized automatically.
ALTER TABLE uk_prices_3
MATERIALIZE PROJECTION town_sort_projection;

-- Now, try to run the same query again, and you should see that it uses the projection and is much faster
SELECT AVG(price) AS avg_price
FROM uk_prices_3
WHERE town = 'DURHAM';

EXPLAIN indexes=1 SELECT AVG(price) AS avg_price
FROM uk_prices_3
WHERE town = 'DURHAM';

-- Let's try a second example using aggregation, instead of just ordering data
ALTER TABLE uk_prices_3
ADD PROJECTION max_town_price_projection
(
    SELECT
        town,
        max(price)
    GROUP BY town
);
SELECT * FROM system.mutations;

ALTER TABLE uk_prices_3 MATERIALIZE PROJECTION max_town_price_projection;

-- Now, just try it and see what happens
SELECT max(price) AS max_price FROM uk_prices_3
WHERE town = 'LONDON';

EXPLAIN indexes=1 SELECT max(price) AS max_price FROM uk_prices_3
WHERE town = 'LONDON';
