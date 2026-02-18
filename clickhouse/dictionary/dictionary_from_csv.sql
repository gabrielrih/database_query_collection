/**
It's kind of a table but it's stored on memory in a key-value structure (https://clickhouse.com/docs/dictionary)
The source is external
The layout is how the dictionary is built in memory
The lifetime is in seconds. It means the dictionary updates itself automatically
**/
CREATE DICTIONARY uk_mortage_rates (
    date DateTime64,
    variable Decimal32(2),
    fixed Decimal32(2),
    bank Decimal32(2)
)
PRIMARY KEY date
SOURCE(
    HTTP(
        url 'https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/mortgage_rates.csv'
        format 'CSVWithNames'
    )
)
LAYOUT(COMPLEX_KEY_HASHED())
LIFETIME(2628000000);


-- Let's try to find a correlation between the volume of properties sold and the interest rate.
-- Using the uk_prices_3 table, write a query that returns the number of properties sold per month along with the variable interest rate for that month.
-- You should get back 220 rows - one for each month in the dictionary.
WITH (
    toStartOfMonth(prices.date) as month
)
SELECT
    month,
    count(),
    any(mortage.variable)
FROM uk_prices_3 AS prices
JOIN uk_mortage_rates AS mortage on month = toStartOfMonth(mortage.date)
GROUP BY month
ORDER BY month;

-- It's not obvious if there is a correlation or not.
-- Try running the previous query again, but sort the results by the volume of property sold descending.
-- Which date had the highest volume of properties sold? 
WITH (
    toStartOfMonth(prices.date) as month
)
SELECT
    month,
    count() as property_solved,
    any(mortage.variable)
FROM uk_prices_3 AS prices
JOIN uk_mortage_rates AS mortage on month = toStartOfMonth(mortage.date)
GROUP BY month
ORDER BY property_solved desc;

-- It is hard to tell just by looking at the numbers, so let's use a more scientific approach.
-- Using the query from step 4 as a subquery, use the corr function on the count() and variable columns returned from that query in step 4.
-- (You will have to convert the Decimal32 values to Float32.)
-- The result of the corr function is the Pearson correlation coefficient. If the response is greater than 0, then the two columns move in the same direction.
-- If the response is negative, then the two values move in the opposite direction.
SELECT
    corr(
        toFloat32(property_solved),
        toFloat32(variable)
    )
FROM (
    WITH (
        toStartOfMonth(date) as month
    )
    SELECT
        month,
        count() AS property_solved,
        any(variable) AS variable
    FROM uk_prices_3 prices
    JOIN uk_mortage_rates mortage ON month = toStartOfMonth(mortage.date)
    GROUP BY month
);

-- Based on the previous query, there is a relationship between volume of properties sold and the variable interest rate.
-- Run that query again, but this time use the fixed interest rate volume (instead of variable).
SELECT
    corr(
        toFloat32(property_solved),
        toFloat32(fixed)
    )
FROM (
    WITH (
        toStartOfMonth(date) as month
    )
    SELECT
        month,
        count() AS property_solved,
        any(fixed) AS fixed
    FROM uk_prices_3 prices
    JOIN uk_mortage_rates mortage ON month = toStartOfMonth(mortage.date)
    GROUP BY month
);
