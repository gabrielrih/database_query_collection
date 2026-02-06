SELECT
    town,
    count() AS total
FROM uk_prices_1
GROUP BY town
ORDER BY total DESC
FORMAT Vertical;

SELECT
    town,
    count() AS total
FROM uk_prices_1
GROUP BY town
ORDER BY total DESC
FORMAT JSONEachRow;
