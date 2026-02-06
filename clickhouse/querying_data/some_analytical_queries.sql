-- How many properties were sold for over 1 million pounds in 2024? 22471
SELECT count()
FROM uk_prices_3
WHERE price > 1000000 AND toYear(date) == '2024';

-- How many unique towns are in the dataset? 1172
SELECT uniqExact(town)
FROM uk_prices_3

-- Which town had the highest number of properties sold? LONDON
SELECT
    town,
    count()
FROM uk_prices_3
GROUP BY town
ORDER BY 2 DESC;

-- Using the topK function, write a query that returns the top 10 towns that are not London with the most properties sold.
SELECT 
    topKIf(10)(town, town != 'LONDON')
FROM uk_prices_3;

-- What are the top 10 most expensive towns to buy property in the UK, on average?
SELECT 
    town,
    formatReadableQuantity(avg(price)) as average_price
FROM uk_prices_3
GROUP BY town
ORDER BY average_price DESC
LIMIT 10;

-- What is the address of the most expensive property in the dataset?
-- Specifically, return the addr1, addr2, street and town columns
SELECT
    argMax(
        concat(addr1, ' ', addr2, ' ', street, ' ', town),
        price
    )
FROM uk_prices_3;

-- Write a single query that returns the average price of properties for each type.
-- The distinct values of type are detached, semi-detached, terraced, flat, and other.
SELECT
    type AS property_type,
    formatReadableQuantity(AVG(price)) AS average_price
FROM uk_prices_3
GROUP BY property_type
ORDER BY 2 DESC;

-- What is the sum of the price of all properties sold in the counties of Avon, Essex, Devon, Kent, and Cornwall in the year 2024?
SELECT SUM(price) FROM uk_prices_3
WHERE toYear(date) == '2024' AND county IN ('AVON', 'ESSEX', 'DEVON', 'KENT', 'CORNWALL');

-- What is the average price of properties sold per month from 2005 to 2010?
SELECT
    toStartOfMonth(date) AS month,
    formatReadableQuantity(AVG(price)) AS average_price
FROM uk_prices_3
WHERE toYear(date) BETWEEN '2005' AND '2010'
GROUP BY month
ORDER BY month ASC;

-- How many properties were sold in Liverpool each day in 2020?
-- For the quiz at the end of this module, keep track of how many properties were sold on December 31, 2020.
--  6
SELECT
    formatDateTime(date, '%Y-%m-%d') as day,
    COUNT() AS properties_sold
FROM uk_prices_3
WHERE town = 'LIVERPOOL' AND toYear(date) == '2020'
GROUP BY day
ORDER BY day;

-- Write a query that returns the price of the most expensive property in each town divided by the price of the
-- most expensive property in the entire dataset.
-- Sort the results in descending order of the computed result
WITH (
    SELECT max(price) FROM uk_prices_3
) AS overall_max
SELECT
    town,
    max(price) / overall_max AS price_ratio
FROM uk_prices_3
GROUP BY town
ORDER BY 2 DESC;
