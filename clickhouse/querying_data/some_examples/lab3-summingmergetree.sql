-- Introduction:  In this lab, you will keep a running total of the prices spent per town on property in the UK.

-- 1. Run the following query, which groups the uk_prices_3 by town and sums the price column:
SELECT
    town,
    sum(price) AS sum_price,
    formatReadableQuantity(sum_price)
FROM lab_uk_prices_3
GROUP BY town
ORDER BY sum_price DESC;

SELECT
    town,
    sum(price) AS sum_price,
    formatReadableQuantity(sum_price)
FROM uk_prices_3
GROUP BY town
ORDER BY sum_price DESC;

-- 2. If you want to keep a running total, SummingMergeTree is the perfect solution.
-- Create an incremental materialized view that keeps a running sum of the price column for each town in uk_prices_3:
--  a. Name the view prices_sum_view
--  b. Name the destination table prices_sum_dest
--  c. Populate prices_sum_dest with the existing rows in uk_prices_3
SHOW CREATE TABLE lab_uk_prices_3 FORMAT pretty;

CREATE TABLE lab_prices_sum_dest (
    town LowCardinality(String),
    sum_price UInt64
)
ENGINE SummingMergeTree
PRIMARY KEY town;

CREATE MATERIALIZED VIEW lab_prices_sum_view
TO lab_prices_sum_dest
AS
    SELECT
        town,
        SUM(price) AS sum_price
    FROM lab_uk_prices_3
    GROUP BY town;

INSERT INTO lab_prices_sum_dest
    SELECT town, SUM(price) AS sum_price
    FROM lab_uk_prices_3
    GROUP BY town;

-- 3. Check the rows in prices_sum_dest - you should have 1,172 (one for each town).
SELECT count() FROM lab_prices_sum_dest;

-- 4. Verify it worked by running the following two queries - you should get the same result, but the query reading from prices_sum_dest should be much faster:
SELECT
    town,
    sum(price) AS sum_price,
    formatReadableQuantity(sum_price)
FROM lab_uk_prices_3
WHERE town = 'LONDON'
GROUP BY town;

SELECT
    town,
    sum_price AS sum_price,
    formatReadableQuantity(sum_price)
FROM lab_prices_sum_dest
WHERE town = 'LONDON';

-- Do you see a problem with the second query? What happens if you insert the sale of a new property in London as below and re-run the queries?
INSERT INTO lab_uk_prices_3 (price, date, town, street)
VALUES (4294967295, toDate('1994-01-01'), 'LONDON', 'My Street1');

-- Can you fix the query?
-- Sure. You just need to sum all the values.
SELECT
    town,
    SUM(sum_price) AS sum_price,
    formatReadableQuantity(sum_price)
FROM lab_prices_sum_dest
WHERE town = 'LONDON'
GROUP BY town;

-- 5. Write a query on prices_sum_dest that returns the top 10 towns in terms of total price spent on property.
-- Remember that when you query a SummingMergeTree, there might be multiple rows with the same primary key that should be aggregated
--  (i.e., you should always have the sum and the GROUP BY in the query).
SELECT
    town,
    SUM(sum_price) AS sum,
    formatReadableQuantity(sum)
FROM lab_prices_sum_dest
GROUP BY town
ORDER BY sum DESC
LIMIT 10;

--OPTIMIZE TABLE lab_prices_sum_dest;
--SELECT * FROM system.parts WHERE table = 'lab_prices_sum_dest'
