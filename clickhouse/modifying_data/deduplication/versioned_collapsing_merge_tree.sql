-- This one works exactly like CollapsingMergeTree but it has a version to avoid race condition
-- So, you can use it in the cases you have multi-threads inserting a lot of data on the same table.
CREATE TABLE vcmt_demo (
    url String,
    hits UInt64,
    sign Int8,
    version UInt32
)
ENGINE = VersionedCollapsingMergeTree(sign, version)
ORDER BY url;