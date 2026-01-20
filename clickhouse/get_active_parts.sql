-- All active parts of all tables
SELECT * 
FROM system.parts
AND active = 1;

-- Active parts of a single table
SELECT * 
FROM system.parts
WHERE table = 'uk_prices_1'
AND active = 1;
