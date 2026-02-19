-- Lightweight updates/deletes

-- Delete or update rows using the normal SQL sintax
-- The difference from this syntax to the use of mutation is that here the rows are marked as deleted
-- It means the rows are immediatly "deleted" for the user view but it's kept on disk
-- Eventually, the data will be deleted when a part merge occurs
-- The use of this strategy can be a problem if you start deleting a lot of rows and the parts don't merge. It can slows your queries down.
DELETE FROM random WHERE y != 'hello';

