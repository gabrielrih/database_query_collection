-- Introduction:  In this lab, you will define a Materialized View that maintains "running" aggregate values on the UK property prices dataset. 

-- 1. Suppose you have a dashboard with several visualizations that need to be updated on a regular basis.
-- Feel free to run the following queries to see what the results are:
--  a. The maximum and minimum price of properties sold each month:
-- It took 1 second to run and performed a full table scan (30M rows)
WITH
    toStartOfMonth(date) AS month
SELECT
    month,
    min(price) AS min_price,
    max(price) AS max_price
FROM lab_uk_prices_3
GROUP BY month
ORDER BY month DESC;

-- b. The average price of homes sold each month:
-- It took 700ms and performed a full table scan (30M rows)
WITH
    toStartOfMonth(date) AS month
SELECT
    month,
    avg(price)
FROM uk_prices_3
GROUP BY month
ORDER BY month DESC;

-- c. The volume (the number of properties) sold each month:
-- It took 400 ms and performed a full table scan (30M rows)
WITH
    toStartOfMonth(date) AS month
SELECT
    month,
    count()
FROM uk_prices_3
GROUP BY month
ORDER BY month DESC;

-- 2. In ClickHouse, it's a best practice to minimize the number of materialized views on a table. 
-- Define a single incremental materialized view that computes and maintains all of the aggregations in step 1 above. Here are some guidelines:
--  a. Name your destination table uk_prices_aggs_dest
--  b. Name your materialized view uk_prices_aggs_view
--  c. Populate the destination table with all the existing rows in uk_prices_3 where the date is after January 1, 1995.
--      (This will avoid those few sample rows from 1994 that you may have added in a previous lab.)
SHOW CREATE TABLE lab_uk_prices_3 FORMAT pretty;

CREATE TABLE lab_uk_prices_aggs_dest (
    month Date,
    min_price SimpleAggregateFunction(min, UInt32),
    max_price SimpleAggregateFunction(max, UInt32),
    avg_price AggregateFunction(avg, UInt32),
    volume AggregateFunction(count, UInt32)
)
ENGINE AggregatingMergeTree
PRIMARY KEY month;

CREATE MATERIALIZED VIEW lab_uk_prices_aggs_view
TO lab_uk_prices_aggs_dest
AS
    WITH
        toStartOfMonth(date) AS month
    SELECT
        month,
        minSimpleState(price) AS min_price,
        maxSimpleState(price) AS max_price,
        avgState(price) AS avg_price,
        countState() AS volume
    FROM lab_uk_prices_3
    GROUP BY month;

INSERT INTO lab_uk_prices_aggs_dest
    WITH
        toStartOfMonth(date) AS month
    SELECT
        month,
        minSimpleState(price) AS min_price,
        maxSimpleState(price) AS max_price,
        avgState(price) AS avg_price,
        countState() AS volume
    FROM lab_uk_prices_3
    WHERE date >= toDate('1995-01-01')
    GROUP BY month;

-- 3. Select all the rows from uk_prices_agg_dest.
-- Notice the "simple" aggregate functions have a readable value, and the other aggregate functions contain binary data:
SELECT * FROM lab_uk_prices_aggs_dest;

-- 4. Using the destination table, write a query that returns the minimum and maximum price for each month of 2023.
SELECT
    month,
    max(max_price) AS max_price,
    min(min_price) AS min_price
FROM lab_uk_prices_aggs_dest
WHERE month between '2023-01-01' AND '2023-12-01'
GROUP BY month
ORDER BY month ASC;

-- 5. Similarly, write a query on the destination table that returns the average price of homes for the last two years.
WITH (
    toStartOfMonth(now()) AS current_month
)
SELECT
    month,
    avgMerge(avg_price) AS avg_price
FROM lab_uk_prices_aggs_dest
WHERE
    month >= (current_month - (INTERVAL 2 YEAR)) AND month < current_month
GROUP BY month
ORDER BY month DESC;

-- 6. Write a query on the destination table that computes the number of homes sold in 2020
SELECT
    countMerge(volume) AS total_of_properties_sold
FROM lab_uk_prices_aggs_dest
WHERE toYear(month) = '2020';

-- 7. Let's verify your view is triggered on inserts. Insert the following test rows into uk_prices_3:
INSERT INTO lab_uk_prices_3 (date, price, town) VALUES
    ('1994-08-01', 10000, 'Little Whinging'),
    ('1994-08-01', 1, 'Little Whinging');

-- 8. You should see a new row in uk_prices_aggs_dest for the month of August, 1994:
SELECT
    month,
    countMerge(volume),
    min(min_price),
    max(max_price)
FROM lab_uk_prices_aggs_dest
WHERE toYYYYMM(month) = '199408'
GROUP BY month; 

