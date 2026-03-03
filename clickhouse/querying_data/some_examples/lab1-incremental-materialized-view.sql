-- Introduction:
-- In this lab, you will define an incremental materialized view on the uk_prices_3 table that stores the property prices partitioned by year.

SHOW CREATE TABLE lab_uk_prices_3 FORMAT PRETTY;

-- 1. Write a single query on the uk_prices_3 table that computes the number of properties sold and the average price of all the properties sold for the year 2020.
-- Notice your query needs to process all the rows in the table.
SELECT 
    COUNT(1) as total_of_sold_properties,
    AVG(price) as average_price
FROM lab_uk_prices_3
WHERE toYear(date) = '2020';

-- 2. Write a similar query as the one you wrote in step 1, except this time return the year, count and average for all the years in the dataset.
-- (In other words, group the result by toYear(date) instead of filtering by the year 2020).
-- Again, your query will need to process all the rows in the table.
WITH (
    toYear(date) as year
)
SELECT 
    year,
    COUNT() as total_of_sold_properties,
    AVG(price) as average_price
FROM lab_uk_prices_3
GROUP BY year
ORDER BY year ASC;

-- 3. Suppose you want to run queries frequently on the yearly historical data of uk_prices_3.
-- Let's define an incremental materialized view that partitions the data by year and sorts the data by town,
-- so that our queries do not need to scan every row each time we run our queries.
-- Let's start by defining the destination table. Define a new MergeTree table that satisfies the following requirements:
-- a. The name of the table is prices_by_year_dest
-- b. The table will store the date, price, addr1, addr2, street, town, district and county columns from uk_prices_3
-- c. The primary key is the town column followed by the date column
-- d. The table is partitioned by year
CREATE TABLE lab_prices_by_year_dest (
    date DateTime,
    price UInt32,
    addr1 String,
    addr2 String,
    street String,
    town LowCardinality(String),
    district LowCardinality(String),
    county LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (town, date)
PARTITION BY toYear(date);

-- 4. Create a materialized view named prices_by_year_view that sends the date, price, addr1, addr2, street, town, district and county
--  columns to the prices_by_year_dest table.
CREATE MATERIALIZED VIEW lab_prices_by_year_view
TO lab_prices_by_year_dest
AS
    SELECT date, price, addr1, addr2, street, town, district, county
    FROM lab_uk_prices_3;

-- 5. Backfill the prices_by_year_dest table with all of the existing rows in uk_prices_3.
INSERT INTO lab_prices_by_year_dest
SELECT date, price, addr1, addr2, street, town, district, county FROM lab_uk_prices_3;

-- 6. Count the number of rows in prices_by_year_dest and verify it's the same number of rows in uk_prices_3 (30,033,199 rows).
SELECT COUNT(1) FROM lab_prices_by_year_dest;
SELECT COUNT(1) FROM lab_uk_prices_3;

-- 7. Run the following query, which returns the parts that were created for your prices_by_year_dest table.
-- You will see lots of parts, and folder names contain the year:
SELECT * FROM system.parts WHERE table = 'lab_prices_by_year_dest';

-- 8. For comparison, notice that uk_prices_3 probably only has 1 or 2 parts:
SELECT * FROM system.parts WHERE table = 'lab_uk_prices_3';

-- 9. Let's see if we gained any benefits from defining this materialized view.
-- Run the same query from step 1, except this time run it on prices_by_year_dest instead of uk_prices_3.
-- How many rows were scanned? 895.168 rows
SELECT 
    COUNT(1) as total_of_sold_properties,
    AVG(price) as average_price
FROM lab_prices_by_year_dest
WHERE toYear(date) = '2020';

-- 10. Use prices_by_year_dest to count how many properties were sold and the maximum, average, and 90th quantile of the price of properties
--  sold in June of 2005 in the county of Staffordshire.
SELECT
    COUNT(1) AS total_of_sold_properties,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    quantile(0.9)(price) AS quantile_price
FROM lab_prices_by_year_dest
WHERE county = 'STAFFORDSHIRE' AND (date BETWEEN '2005-06-01' AND '2005-06-30');

-- 11. Let's verify that the insert trigger for your materialized view is working properly.
-- Run the following command, which inserts 3 rows into uk_prices_3 for properties in the year 1994.
-- (Right now your uk_prices_3 table doesn't contain any transactions from 1994.)
INSERT INTO lab_uk_prices_3 VALUES
    ('51f279f5-ef5f-46e1-bd8e-b6c4159d8fa7', 125000, '1994-03-07', 'B77', '4JT', 'semi-detached', 0, 'freehold', 10,'',	'CRIGDON','WILNECOTE','TAMWORTH','TAMWORTH','STAFFORDSHIRE'),
    ('a0d2f609-b6f9-4972-857c-8e4266d146ae', 440000000, '1994-07-29', 'WC1B', '4JB', 'other', 0, 'freehold', 'VICTORIA HOUSE', '', 'SOUTHAMPTON ROW', '','LONDON','CAMDEN', 'GREATER LONDON'),
    ('1017aff1-6f1e-420a-aad5-7d03ce60c8c5', 2000000, '1994-01-22','BS40', '5QL', 'detached', 0, 'freehold', 'WEBBSBROOK HOUSE','', 'SILVER STREET', 'WRINGTON', 'BRISTOL', 'NORTH SOMERSET', 'NORTH SOMERSET');

-- 13. Verify you have three new rows in prices_by_year_dest where the year is 1994.
SELECT * FROM lab_prices_by_year_dest WHERE toYear(date) = '1994';

-- 14. You should also see a new part folder for prices_by_year_dest named 1994_0_0_0:
SELECT * FROM system.parts WHERE table = 'lab_prices_by_year_dest';

