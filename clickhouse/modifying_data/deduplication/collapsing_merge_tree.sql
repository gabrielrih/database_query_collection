-- The CollapsingMergeTree works with a sign column that must have the value 1 or -1
-- The main idea is that when you want to delete the row, you just insert a row with the same ORDER BY column setting the sign to -1
-- And when you want to update a row, you insert two rows (the first one setting the sign to -1 and the second one inserting the new row with sign equals 1)
CREATE TABLE url_hits (
    url String,
    hits UInt64,
    sign Int8
)
ENGINE = CollapsingMergeTree(sign)
ORDER BY url;

-- First of all, we insert two rows that represents the current values
INSERT INTO url_hits VALUES
    ('/index.html', 20, 1)
    ('/docs', 10, 1);

SELECT * FROM url_hits;

-- To update the value of /index.html from 20 to 30, I need to first insert a sign -1 and then insert the new value
INSERT INTO url_hits VALUES
    ('/index.html', 20, -1),
    ('/index.html', 30, 1);

-- Note that when I query without the FINAL clause, it retrieves all the rows (three rows)
SELECT * FROM url_hits;

-- However, if I use the FINAL clause, the old rows with sign 1 and -1 cancel each other and just the last /index.html with 30 hits are shown
SELECT * FROM url_hits FINAL;

-- Maybe another way to do that without the FINAL clause is the one below
-- Note that this query can be faster than the one using FINAL because this one can run in parallel across the cluster
-- Meanwhile, when using FINAL the result must the handle just in one replica on a single thread
-- IMPORTANT: However, it's important to note that if you delete a row from the time, this query here won't work
SELECT
    url,
    sum(hits*sign)
FROM url_hits
GROUP BY url;

-- To delete a row, you just need to insert a new one using negative sign
-- In this case you may not know the current hits values
INSERT INTO url_hits (url, sign) VALUES
    ('/docs', -1);

SELECT * FROM url_hits FINAL;

-- Again, when the table is merged, the old rows are removed
OPTIMIZE TABLE url_hits FINAL;
SELECT * FROM system.parts WHERE table = 'url_hits' and active = 1;
