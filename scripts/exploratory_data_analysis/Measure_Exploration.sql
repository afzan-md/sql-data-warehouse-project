-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales
FROM   gold.fact_sales;

-- Find how many items are sold (Total Quantity)
SELECT SUM(quantity) AS total_quantity
FROM   gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_sales_price
FROM   gold.fact_sales;

-- Find the Total number of Orders
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM   gold.fact_sales;

-- Find the Total number of Products
SELECT COUNT(DISTINCT product_key) AS total_products
FROM   gold.dim_products;

-- Find the Total number of Customers
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM   gold.dim_customers;

-- Find the total number of Customers that have placed order
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM   gold.fact_sales;
 
-- Generate a Report that shows all key metrics of the business 
SELECT 'Total Sales' AS measure_name,
       SUM(sales_amount) AS measure_value
FROM   gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name,
       SUM(quantity)
FROM   gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS measure_name,
       AVG(price)
FROM   gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders' AS measure_name,
       COUNT(DISTINCT order_number)
FROM   gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products' AS measure_name,
       COUNT(DISTINCT product_key)
FROM   gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers' AS measure_name,
       COUNT(DISTINCT customer_key)
FROM   gold.dim_customers;