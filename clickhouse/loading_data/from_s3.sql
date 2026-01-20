-- Describe the schema of a parquet file on AWS S3
DESC s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/noaa/noaa_enriched.parquet')

-- Describe the schema of a parquet file on AWS S3
-- Not allowing nullable columns
DESC s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/noaa/noaa_enriched.parquet')
SETTINGS schema_inference_make_columns_nullable=0;

-- Creating an in memory table and loading with some data from AWS S3
CREATE TABLE weather_temp
ENGINE = Memory
AS 
    SELECT * 
    FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/noaa/noaa_enriched.parquet')
    LIMIT 100
    SETTINGS schema_inference_make_columns_nullable=0;

-- Inserting data from S3 into a MergeTable
-- You can also filter the content from the parquet file
INSERT INTO weather
    SELECT * 
    FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/noaa/noaa_enriched.parquet')
    WHERE toYear(date) >= '1995';
