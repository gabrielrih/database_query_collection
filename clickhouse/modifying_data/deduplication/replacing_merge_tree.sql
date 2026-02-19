-- Deduplication is a way to update data by actually inserting data
-- To do that you use specific table engines that has this logic

-- Let's create a simple table using the ReplacingMergeTree engine
-- https://clickhouse.com/docs/engines/table-engines/mergetree-family/replacingmergetree
-- This table engine uses the columns from the ORDER BY clause to replace values and deduplicate rows
CREATE TABLE rmt_demo (
    x UInt32,
    y String
)
ENGINE = ReplacingMergeTree 
ORDER BY x;

-- Now we insert two rows
INSERT INTO rmt_demo VALUES
    (1, 'hello'),
    (2, 'goodbye');

-- We can see there are two rows on the table
SELECT * FROM rmt_demo;

-- Now we update the row by the x columns
-- So the value was "hello" and now it is "hi"
INSERT INTO rmt_demo VALUES (1, 'hi');

-- However, when you query the table you can see three rows instead of just two
-- That's because the data is deduplicate JUST WHEN A MERGE OCCURS
SELECT * FROM rmt_demo;

-- If you want to see just the latest "version" of each row you can use the FINAL clause
-- This command will return to you just two rows
SELECT * FROM rmt_demo FINAL;

-- In order to test things, you can force a table merge
OPTIMIZE TABLE rmt_demo FINAL;
SELECT * FROM system.parts WHERE table = 'rmt_demo' and active = 1;
