-- Removing some caracters from a string column
SELECT 
    id,
    replaceRegexpAll(id,'[{}]','')
FROM uk_prices_2
LIMIT 100;


-- Splitting a string column into multiple columns
WITH
    splitByChar(' ', postcode) AS postcodes
SELECT
    postcodes[1] AS postcode1,
    postcodes[2] AS postcode2
FROM uk_prices_2
WHERE postcode != ''
LIMIT 100;
