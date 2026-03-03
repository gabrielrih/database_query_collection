-- Introduction:  In this lab, you will define a skipping index for the uk_prices_3 table.

-- 1. Write a query that lists all the distinct values of county in the uk_prices_3 table.
-- Notice there are only 133 unique values.
SELECT DISTINCT(county) AS county
FROM lab_uk_prices_3
GROUP BY county;

-- 2. The county column is not in the primary key of uk_prices_3, so filtering by county requires an entire table scan, as you can see by running the following query:
--  It took 2 seconds and performed a full table scan (30M of rows)
SELECT
    formatReadableQuantity(count()),
    avg(price)
FROM lab_uk_prices_3
WHERE county = 'GREATER LONDON';

-- 3. This seems like a good scenario for a skipping index.
-- Define a new skipping index named county_index on the uk_prices_3 table that satisfies the following requirements:
--  a. It is a bloom filter index on the county column
--  b. The granularity of the index is 1
ALTER TABLE lab_uk_prices_3
ADD INDEX county_index county
TYPE bloom_filter(0.025)
GRANULARITY 1;

-- 4. Materialize the county_index.
ALTER TABLE lab_uk_prices_3 MATERIALIZE INDEX county_index;

-- 5. Check the status of the materializing of the new index by monitoring the system.mutations table.
select * from system.mutations order by create_time desc;

-- 6. When the mutation is complete, run the following query to see the size of data skipping indexes (aka secondary indexes).
SELECT
    table,
    formatReadableSize(data_compressed_bytes) as data_compressed,
    formatReadableSize(secondary_indices_compressed_bytes) as index_compressed,
    formatReadableSize(primary_key_size) as primary_key
FROM
    system.parts
WHERE active = 1 AND table = 'lab_uk_prices_3'
ORDER BY secondary_indices_uncompressed_bytes DESC
LIMIT 50;

-- 7. Run the query from step 2 again.
-- How many rows were scanned this time?
--  It took 900ms and read 6M of rows
SELECT
    formatReadableQuantity(count()),
    avg(price)
FROM lab_uk_prices_3
WHERE county = 'GREATER LONDON';

-- 8. Run the EXPLAIN command with indexes = 1 on the query from step 2.
-- This will show you exactly how many granules would be skipped using county_index vs. the primary index (without actually running the query).
-- It's a very useful output when you are designing and testing skipping indexes.
EXPLAIN indexes=1 SELECT
    formatReadableQuantity(count()),
    avg(price)
FROM lab_uk_prices_3
WHERE county = 'GREATER LONDON';

