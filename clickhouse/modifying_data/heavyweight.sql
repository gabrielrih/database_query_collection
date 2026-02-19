-- Heavyweight updates/deletes

-- You can delete or update rows using mutation
-- Those commands trigger an mutation event (it doesn't take effect immediatly)
-- In those cases the parts must be rewrite on the file system through background process.
ALTER TABLE random DELETE WHERE y != 'hello';
ALTER TABLE random UPDATE y = 'hello' WHERE x > 10;

-- You can check the status of the mutations (update and delete proccess)
-- They execute in the order they were created, and each part is processed in that order.
-- Data inserted after a mutation is created is not mutated.
-- They can take minuter to hours to finish.
SELECT * FROM system.mutations;

KILL MUTATION;
