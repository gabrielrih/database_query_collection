-- A skipping index is the same as a secondary index in other databases
-- It allows you to quickly find rows in a table based on the values of one or more columns
-- Skipping indexes are used to speed up queries that filter on those columns

-- The query below does a full table scan, which can be slow if the table is large
SELECT avg(price) FROM uk_prices_3
WHERE town = 'DURHAM';

-- To optimize this query, we can create a skipping index on the 'town' column
-- OBS: We can also use other types of skipping indexes, such as minmax or set indexes
ALTER TABLE uk_prices_3
ADD INDEX town_bf_index town
TYPE bloom_filter(0.025)
GRANULARITY 1;

ALTER TABLE uk_prices_3 MATERIALIZE INDEX town_bf_index;

-- Now, check the same query again. It should be much faster because it can use the skipping index to quickly find the relevant rows
SELECT avg(price) FROM uk_prices_3
WHERE town = 'DURHAM';
