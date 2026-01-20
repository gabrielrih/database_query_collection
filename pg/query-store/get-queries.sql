/*
    Query Store data is stored in the azure_sys database on your Postgres server.
    Run this SELECT to get the results.

    References:
    - AZ PG Flexible Server (https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-query-store)
    - Fields description (https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/postgresql/concepts-query-store.md)
*/
SELECT * FROM query_store.qs_view; 
SELECT * FROM query_store.pgms_wait_sampling_view;