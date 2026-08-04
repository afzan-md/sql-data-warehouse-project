-- Explore all Objects in the Database
SELECT *
FROM   INFORMATION_SCHEMA.TABLES;

-- Explore all Columns in the Database
SELECT *
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = 'dim_customers';