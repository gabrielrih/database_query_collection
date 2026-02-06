-- The classic SUM, MIN, MAX and AVG functions, but it also use a nice one called formatReadableQuantity
-- It'll print something like that: 8.16 billion
SELECT
    min(actual_amount),
    max(actual_amount),
    avg(actual_amount),
    formatReadableQuantity(sum(actual_amount))
FROM operating_budget
FORMAT VERTICAL;

-- To get the price of 90% of the values
SELECT
    quantile(0.9)(price)
from uk_prices_3;

-- To get the estimated number of different streets on the talbe
select uniq(street) from uk_prices_3;

-- To get the estimated TOP 10 quantity of street more frequently present on the table
select topK(10)(street) from uk_prices_3;

-- To get the TOP 10 street more frequently present on the table
-- Ignoring the empty ones
select topKIf(10)(street, street != '') from uk_prices_3

-- I'm getting the most expensive price for each town
-- However, I also want to get the some street name
-- The ANY function will bring ANY street name for each town and show it here without the need to add the street on the group by clause
-- The street on the query result can change everytime you run it
select
    town,
    max(price),
    any(street)
from uk_prices_3
group by town
order by town
limit 10;

-- This one does almost the same as the query below
-- However, it doesn't bring ANY street of each town
-- It brings the street that has the most expensive price
-- The query result is always the same
select
    town,
    max(price),
    argMax(street, price)
from uk_prices_3
group by town
order by town
limit 10;

-- The arrayJoin function all turn each element of an array into a different row
-- In this example we split each word for the street column and then you count which of the words appears more
SELECT
    arrayJoin(splitByChar(' ', street)) AS word,
    count() AS total_ocurrences
FROM uk_prices_3
GROUP BY word
ORDER BY 2 DESC
LIMIT 10;


