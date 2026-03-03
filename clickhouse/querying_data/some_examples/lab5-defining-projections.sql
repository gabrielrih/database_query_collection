-- Introduction:  In this lab, you will define a projection on the uk_prices_3 table.

-- 1. When analyzing property prices, location is going to obviously be a common filtering and grouping column.
-- For example, suppose we want to analyze property prices for the town of Liverpool.
-- Run the following query - and notice every row is read because town is not a part of the primary key:
--  It took 700ms and read all 30M rows (full table scan)
SELECT
    toYear(date) AS year,
    count(),
    avg(price),
    max(price),
    formatReadableQuantity(sum(price))
FROM lab_uk_prices_3
WHERE town = 'LIVERPOOL'
GROUP BY year
ORDER BY year DESC;

-- 2. You are going to define a projection, but first let's take a look at the amount of disk space being consumed by uk_prices_3.
-- Run the following query - your table should be using about 600M of disk space:
SELECT
    formatReadableSize(sum(bytes_on_disk)),
    count() AS num_of_parts
FROM system.parts
WHERE table = 'lab_uk_prices_3' AND active = 1;

-- 3. Define a new projection on uk_prices_3 named town_date_projection that satisfies the following requirements:
--  a. Contains only the town, date, and price columns
--  b. The data is sorted by town, then date
ALTER TABLE lab_uk_prices_3
ADD PROJECTION lab_town_date_projection
(
    SELECT town, date, price
    ORDER BY town, date
);

-- 4. Materialize the  town_date_projection and wait for the mutation to complete.
ALTER TABLE lab_uk_prices_3 MATERIALIZE PROJECTION lab_town_date_projection;
SELECT * FROM system.mutations;

-- 5. Now run the query from step 1 again. How many rows were read this time?
--  It took 250ms and read just 300K rows
SELECT
    toYear(date) AS year,
    count(),
    avg(price),
    max(price),
    formatReadableQuantity(sum(price))
FROM lab_uk_prices_3
WHERE town = 'LIVERPOOL'
GROUP BY year
ORDER BY year DESC;

-- 6. Run the query from step 2 again. How much disk space did your projection add to the table storage?
--  703M
SELECT
    formatReadableSize(sum(bytes_on_disk)),
    count() AS num_of_parts
FROM system.parts
WHERE table = 'lab_uk_prices_3' AND active = 1;

-- 7. Define a new projection on uk_prices_3 named handy_aggs_projection that satisfies the following requirements:
--  a. Selects the average, maximum and sum of the price column
--  b. Groups by town column
ALTER TABLE lab_uk_prices_3
ADD PROJECTION lab_handy_aggs_projection
(
    SELECT avg(price), max(price), sum(price)
    GROUP BY town
);

-- 8. Materialize the handy_aggs_projection and wait for the mutation to complete.
ALTER TABLE lab_uk_prices_3 MATERIALIZE PROJECTION lab_handy_aggs_projection;
SELECT * FROM system.mutations;

-- 9. Run the following query and notice that only about 1,172 rows are scanned:
--  Actually it was 5.520 rows, but it worked
SELECT
    avg(price),
    max(price),
    formatReadableQuantity(sum(price))
FROM lab_uk_prices_3
WHERE town = 'LIVERPOOL';

-- 10. Add EXPLAIN to the front of the query in the previous step.
-- Notice in the output that you can see the data is being read from the hidden table built from your handy_aggs_projection (instead of the uk_prices_3 table).
EXPLAIN indexes=1 SELECT
    avg(price),
    max(price),
    formatReadableQuantity(sum(price))
FROM lab_uk_prices_3
WHERE town = 'LIVERPOOL';

