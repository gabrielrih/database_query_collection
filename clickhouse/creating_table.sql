
-- Creating a MergeTree table
CREATE TABLE weather
(
    `station_id` LowCardinality(String),
    `date` Date32,
    `tempAvg` Int32,
    `tempMax` Int32,
    `tempMin` Int32,
    `precipitation` Int32,
    `snowfall` Int32,
    `snowDepth` Int32,
    `percentDailySun` Int8,
    `averageWindSpeed` Int32,
    `maxWindSpeed` Int32,
    `weatherType` UInt8,
    `location` Tuple(
        `1` Float64,
        `2` Float64),
    `elevation` Float32,
    `name` LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (date);

-- Creating an in memory table
CREATE TABLE weather_temp
(
    `station_id` String,
    `date` Date32,
    `tempAvg` Int32,
    `tempMax` Int32,
    `tempMin` Int32,
    `precipitation` Int32,
    `snowfall` Int32,
    `snowDepth` Int32,
    `percentDailySun` Int8,
    `averageWindSpeed` Int32,
    `maxWindSpeed` Int32,
    `weatherType` UInt8,
    `location` Tuple(
        `1` Float64,
        `2` Float64),
    `elevation` Float32,
    `name` String
)
ENGINE = Memory;

-- Some more example of datatypes
CREATE TABLE operating_budget
(
    `fiscal_year` LowCardinality(String),
    `service` LowCardinality(String),
    `department` LowCardinality(String),
    `program` LowCardinality(String),
    `program_code` LowCardinality(String),
    `description` String,
    `item_category` LowCardinality(String),
    `approved_amount` UInt32,
    `recommended_amount` UInt32,
    `actual_amount` Decimal(12,2),
    `fund` LowCardinality(String),
    `fund_type` Enum('GENERAL FUNDS' = 1, 'FEDERAL FUNDS' = 2, 'OTHER FUNDS' = 3)
)
ENGINE = MergeTree
PRIMARY KEY (fiscal_year, program);