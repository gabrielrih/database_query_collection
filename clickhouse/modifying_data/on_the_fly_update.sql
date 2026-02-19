-- On-the-fly updates

-- It's an alternative for the heavyweight and lightweight options
-- This command actually doesn't change the value on disk (as the parts are immutable)
-- It performes this update when you run a SELECT, so the user sees the new value but the on disk, is the old value still there
-- The updated rows will eventually be updated during the next merge.
-- Note that it can be a performance problem if you have a lot this updates on the same table
ALTER TABLE random UPDATE y = 'hello' WHERE x > 10
SET apply_mutations_on_fly = 1;
