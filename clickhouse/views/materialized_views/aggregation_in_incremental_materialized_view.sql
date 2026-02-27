-- When you use an AggregatingMergeTree table engine,
--      you can use the state combinator to store the intermediate state of an aggregate function. This allows you to perform incremental aggregation, which can be more efficient for large datasets.
--      also, all columns must have the AggregateFunction or SimpleAggregateFunction data type, except the columns from the Primary Key
-- References:
--  https://clickhouse.com/docs/sql-reference/aggregate-functions/combinators#-state
--  https://clickhouse.com/docs/sql-reference/data-types/aggregatefunction
--  https://clickhouse.com/docs/sql-reference/data-types/simpleaggregatefunction
CREATE TABLE uk_aggregated_prices (
    district String,
    avg_prive AggregateFunction(avg, UInt32),
    max_price SimpleAggregateFunction(max, UInt32),  -- max can be aggregate or SimpleAggregateFunction
    quant90 AggregateFunction(quantiles(0.90), UInt32)
)
ENGINE = AggregatingMergeTree
PRIMARY KEY district;

CREATE MATERIALIZED VIEW uk_aggregated_prices_view
TO uk_aggregated_prices
AS
    SELECT
        district,
        avgState(price) AS avg_price,
        maxState(price) AS max_price,
        quantilesState(0.90)(price) AS quant90
    FROM uk_prices_3
    GROUP BY district;

-- You can see that there is no data on the target table, because the materialized view will just copy new data to the target table when new a insert comes to the source table
SELECT * FROM uk_aggregated_prices_view;

-- So, let's insert the old data to the target table
INSERT INTO uk_aggregated_prices
    SELECT
        district,
        avgState(price) AS avg_price,
        maxSimpleState(price) AS max_price,
        quantilesState(0.90)(price) AS quant90
    FROM uk_prices_3
    GROUP BY district;

-- Now, if you check some rows you'll see the query is to slow
-- That's because there are binary data on it, and it took some time to load
-- However, take a deep breath because this is not how you should use this kind of table
SELECT * FROM uk_aggregated_prices LIMIT 10;

-- This is the right way to do that
-- This is a GOOD query to put in a dashboard. Even if you have a trillion of rows on the source table, this table will keep just a few rows, and the query will run very fast
SELECT 
    district,
    avgMerge(avg_price),
    max(max_price),
    quantilesMerge(0.90)(quant90)
FROM uk_aggregated_prices
GROUP BY district;

-- Now compare the time of the previous query with the time of the same query but using the source table, and you'll see a huge difference
-- This is a BAD query to put in a dashboard if you have a lot of data
SELECT 
    district,
    avg(price),
    max(price),
    quantile(0.90)(price)
FROM uk_prices_3
GROUP BY district;

