-- Inserting data into uk_prices_3 from uk_prices_2 with data transformation
INSERT INTO uk_prices_3
    WITH
        splitByChar(' ', postcode) AS postcodes
    SELECT
        replaceRegexpAll(id,'[{}]','') AS id,
        toUInt32(price) AS price,
        date,
        postcodes[1] AS postcode1,
        postcodes[2] AS postcode2,
        transform(type, ['T', 'S', 'D', 'F', 'O'], ['terraced', 'semi-detached', 'detached', 'flat', 'other'],'other') AS type,
        is_new = 'Y' AS is_new,
        transform(duration, ['F', 'L', 'U'], ['freehold', 'leasehold', 'unknown'],'unknown') AS duration,
        addr1,
        addr2,
        street,
        locality,
        town,
        district,
        county
    FROM uk_prices_2;
