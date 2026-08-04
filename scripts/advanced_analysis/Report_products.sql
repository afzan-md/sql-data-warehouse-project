/*
==========================================================================
Product Report
==========================================================================
Purpose: 
  - This report consolidates key product metrics and behaviours
Highlights: 
  1.Gather essential fields such as product name, category, subcategory and costs.
  2.Segments products to identify High Performer, Mid Range, Low Performer.
  3.Aggregates product level metrics:
     - total orders
     - total sales
     - total quantity sold
     - total customers (unique)
     - lifespan (in months)
  4. Calculate valuable KPI's
     - recency (months since last order)
     - average order revenue
     - average monthly revenue
===========================================================================     
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
   DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products
AS
/*
---------------------------------------------------------------------------
1) Retrieving Core Columns
---------------------------------------------------------------------------
*/
WITH   base_query
AS     (SELECT f.order_number,
               f.customer_key,
               f.order_date,
               f.sales_amount,
               f.quantity,
               p.product_key,
               p.product_number,
               p.category,
               p.subcategory,
               p.cost
        FROM   gold.fact_sales AS f
               LEFT OUTER JOIN
               gold.dim_products AS p
               ON f.product_key = p.product_key
        WHERE  order_date IS NOT NULL)

/*
---------------------------------------------------------------------------
2) Customer Aggregations
---------------------------------------------------------------------------
*/
, product_aggregation AS(
    SELECT 
        product_key,
        product_number,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY product_key, product_number, category, subcategory, cost
)

/*
---------------------------------------------------------------------------
3) Final Query: Combines all calculations and KPI's
---------------------------------------------------------------------------
*/
SELECT 
    product_key,
    product_number,
    category,
    subcategory,
    cost,
    CASE WHEN total_sales > 50000 THEN 'High Performer'
         WHEN total_sales >= 10000 THEN 'Mid Range'
         ELSE 'Low Performer'
    END AS performance,
    total_orders,
    avg_selling_price,
    total_sales,
    total_quantity,
    total_customers,
    lifespan,
    DATEDIFF(MONTH, last_order, GETDATE()) recency,
    -- Average Order Revenue: total_sales/total_orders
    CASE WHEN total_orders = 0 THEN 0 
         ELSE total_sales / total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue: total_sales/lifespan
    CASE WHEN lifespan = 0 THEN 0 
         ELSE total_sales / lifespan 
    END AS avg_monthly_revenue
FROM product_aggregation;