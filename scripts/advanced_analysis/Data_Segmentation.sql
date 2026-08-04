-- Segment products into cost ranges and count how
-- many product fall into each segment.
WITH product_segment AS(
SELECT   product_key,
         product_name,
         CASE WHEN cost < 100 THEN 'Below 100'
              WHEN cost BETWEEN 100 AND 500 THEN '100-500'
              WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
              ELSE 'Above 1000' 
         END AS cost_range
FROM     gold.dim_products)

SELECT 
cost_range,
count(product_key) total_products
from product_segment
group by cost_range
order by total_products desc;

/*
Group customers into 3 segments based on their spending behavior:
  - VIP: Customers with at least 12 months of history and spending more than 5000 
  - Regular: Customers with at least 12 months of history but 5000 or less
  - New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group. 
*/
WITH     customer_spending
AS       (SELECT   c.customer_key,
                   SUM(f.sales_amount) AS spendings,
                   MIN(order_date) AS min_date,
                   MAX(order_date) AS max_date,
                   DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
          FROM     gold.fact_sales AS f
                   LEFT OUTER JOIN
                   gold.dim_customers AS c
                   ON f.customer_key = c.customer_key
          GROUP BY c.customer_key)

SELECT  customer_segment,
        COUNT(customer_key) AS total_customers
FROM     (SELECT *,
                 CASE WHEN lifespan >= 12 AND spendings > 5000 THEN 'VIP' 
                      WHEN lifespan >= 12 AND spendings <= 5000 THEN 'Regular'
                      ELSE 'New'
                 END AS customer_segment
          FROM   customer_spending) AS t
GROUP BY customer_segment
ORDER BY total_customers DESC;