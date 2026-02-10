/**
It's kind of a table but it's stored on memory in a key-value structure (https://clickhouse.com/docs/dictionary)
The source is external
The layout is how the dictionary is built in memory
The lifetime is in seconds. It means the dictionary updates itself automatically
**/
CREATE DICTIONARY uk_populations (
    city String,
    population UInt32
)
PRIMARY KEY city
SOURCE(
    HTTP(
        url 'https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/uk_populations.tsv'
        format 'TabSeparatedWithNames'
    )

)
LAYOUT(HASHED())
LIFETIME(86400);

SELECT COUNT() FROM uk_populations;

SELECT * FROM uk_populations;

-- We also have specific functions to work with dictionary
SELECT dictGet('uk_populations', 'population', 'London');

-- You can join data using this dictionary and normal SQL JOIN clause
SELECT
    town,
    avg(price) AS average,
    any(population) as population
FROM uk_prices_3
JOIN uk_populations ON lower(uk_prices_3.town) = lower(uk_populations.city)
GROUP BY town
LIMIT 100;

-- But you can also join data using the dictGet function (which is faster than the normal JOIN clause)
SELECT
    town,
    avg(price) AS average,
    dictGet('uk_populations', 'population', initcap(town)) AS population
FROM uk_prices_3
GROUP BY town
LIMIT 100;
