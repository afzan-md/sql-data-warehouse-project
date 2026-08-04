/*
==========================================================================
Customer Report
==========================================================================
Purpose: 
  - This report consolidates key customer metrics and behaviours
Highlights: 
  1.Gather essential fields such as names, ages, and transactional details.
  2.Segments customer in categories (VIP, Regular, New) and age groups.
  3.Aggregates customer level metrics:
     - total orders
     - total sales
     - total quantity purchased
     - total products
     - lifespan (in months)
  4. Calculate valuable KPI's
     - recency (months since last order)
     - average order value
     - average monthly spend
===========================================================================     
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
   DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers
AS
/*
---------------------------------------------------------------------------
1) Retrieving Core Columns
---------------------------------------------------------------------------
*/
WITH   base_query
AS     (SELECT f.order_number,
               f.product_key,
               f.order_date,
               f.sales_amount,
               f.quantity,
               c.customer_key,
               c.customer_number,
               concat(c.first_name, ' ', c.last_name) AS customer_name,
               DATEDIFF(year, c.birthdate, GETDATE()) AS age
        FROM   gold.fact_sales AS f
               LEFT OUTER JOIN
               gold.dim_customers AS c
               ON f.customer_key = c.customer_key
        WHERE  order_date IS NOT NULL)
/*
---------------------------------------------------------------------------
2) Customer Aggregations
---------------------------------------------------------------------------
*/
, customer_aggregation
AS     (SELECT   customer_key,
                 customer_number,
                 customer_name,
                 age,
                 COUNT(DISTINCT order_number) AS total_orders,
                 SUM(sales_amount) AS total_sales,
                 SUM(quantity) AS total_quantity,
                 COUNT(product_key) AS total_products,
                 MIN(order_date) AS first_order,
                 MAX(order_date) AS last_order,
                 DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
        FROM     base_query
        GROUP BY customer_key, customer_number, customer_name, age)

/*
---------------------------------------------------------------------------
3) Final Query: Combines all calculations and KPI's
---------------------------------------------------------------------------
*/
SELECT customer_key,
       customer_number,
       customer_name,
       CASE WHEN age < 20 THEN 'Under 20'
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39' 
            WHEN age BETWEEN 40 AND 50 THEN '40-50'
            ELSE 'Above 50' 
       END AS age_group,
       CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP' 
            WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
            ELSE 'New'
       END AS customer_segment,
       last_order,
       DATEDIFF(MONTH, last_order, GETDATE()) AS order_recency,
       total_orders,
       total_sales,
       total_quantity,
       total_products,
       -- Average Order Value: total_sales/total_orders
       CASE WHEN total_orders = 0 THEN 0 
            ELSE total_sales / total_orders
       END AS avg_order_value,
       -- Average Monthly Spend: total_sales/lifespan
       CASE WHEN lifespan = 0 THEN 0 
            ELSE total_sales / lifespan 
       END AS avg_monthly_spend
FROM   customer_aggregation;