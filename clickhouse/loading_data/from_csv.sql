-- Describe the schema of a csv file using a different delimiter
DESC s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv')
SETTINGS format_csv_delimiter = '~';

-- Count the number of rows in a csv file
SELECT COUNT(1)
FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv')
SETTINGS format_csv_delimiter = '~';

-- Sum some string values
-- But before sum it, it converts the value to an integer
-- It's a good trick when ClickHouse infers the schema incorrectly
-- Another way to do this is by using the schema_inference_hints setting instead of the toUInt32OrZero function
SELECT SUM(toUInt32OrZero(approved_amount)), SUM(toUInt32OrZero(recommended_amount))
FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv')
SETTINGS format_csv_delimiter = '~';


-- Inserting data from CSV and converting some data types to import in a table
INSERT INTO operating_budget
    WITH
        splitByChar('(', c4) AS result
    SELECT
        c1 AS fiscal_year,
        c2 AS service,
        c3 AS department,
        result[1] AS program,
        splitByChar(')',result[2])[1] AS program_code,
        c5 AS description,
        c6 AS item_category,
        toUInt32OrZero(c7) AS approved_amount,
        toUInt32OrZero(c8) AS recommended_amount,
        toDecimal64(c9, 2) AS actual_amount,
        c10 AS fund,
        c11 AS fund_type
    FROM s3(
        'https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv',
        'CSV',
        'c1 String,
        c2 String,
        c3 String,
        c4 String,
        c5 String,
        c6 String,
        c7 String,
        c8 String,
        c9 String,
        c10 String,
        c11 String'
        )
    SETTINGS
        format_csv_delimiter = '~',
        input_format_csv_skip_first_lines=1;
