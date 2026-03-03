-- Introduction: In this lab, you will define a refreshable materialized view on the uk_prices_3 table.
-- You are going to compute the average price of properties sold each day from January 1, 2025, to the end of the dataset,
--  and configure the MV to refresh twice per day.

-- 1. Define a refreshable materialized view on uk_prices_3 that satisfies the following criteria:
-- a. The name of the MV is uk_averages_by_day_mv
-- b. The MV computes the average price of properties for each day starting on January 1, 2025.
-- c. The MV stores the result in a destination table named uk_averages_by_day
-- d. It refreshes every 12 hours
SHOW CREATE TABLE lab_uk_prices_3 FORMAT pretty;

CREATE TABLE lab_uk_averages_by_day (
    day LowCardinality(String),
    avg_price UInt32
)
ENGINE MergeTree
ORDER BY day;

CREATE MATERIALIZED VIEW lab_uk_averages_by_day_mv
REFRESH EVERY 12 hours
TO lab_uk_averages_by_day
AS
    SELECT
        toYYYYMMDD(date) AS day,
        AVG(price) AS avg_price
    FROM lab_uk_prices_3
    WHERE toYear(date) = '2025'
    GROUP BY day;

-- 2. Run a query that returns all the rows in uk_averages_by_day to verify that the destination table was created properly.
SELECT * FROM lab_uk_averages_by_day LIMIT 10;