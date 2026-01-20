/**
    Example of Declarative Partitioning table.
    Reference: https://www.postgresql.org/docs/current/ddl-partitioning.html
*/

-- Create the parent table
-- This table doesn't receive data, the data will be redirect to the child tables
CREATE TABLE measurement (
    logdate         date not null,
    peaktemp        int
) PARTITION BY RANGE (logdate);

-- Create the partitions
CREATE TABLE measurement_y2019 PARTITION OF measurement
    FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');

CREATE TABLE measurement_y2020 PARTITION OF measurement
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE measurement_y2021 PARTITION OF measurement
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

CREATE TABLE measurement_y2022 PARTITION OF measurement
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

-- Create indexes on parent table
CREATE INDEX ON measurement (logdate);