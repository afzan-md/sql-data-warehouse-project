-- Find the date of first and last date.
-- How many years of sales are available.
SELECT MIN(order_date) AS first_order_date,
       MAX(order_date) AS last_last_date,
       DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM   gold.fact_sales;

-- Find the youngest and oldest customer.
SELECT MIN(birthdate) AS oldest_customer,
       DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
       MAX(birthdate) AS youngest_customer,
       DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM   gold.dim_customers;


