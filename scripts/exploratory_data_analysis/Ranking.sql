-- Which 5 products generate the highest revenue?
SELECT   TOP 5 p.product_name,
               SUM(f.sales_amount) AS total_revenue
FROM     gold.fact_sales AS f
         LEFT OUTER JOIN
         gold.dim_products AS p
         ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Using Window Function
SELECT   *
FROM     (SELECT   p.product_name,
                   SUM(f.sales_amount) AS total_revenue,
                   RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank
          FROM     gold.fact_sales AS f
                   LEFT OUTER JOIN
                   gold.dim_products AS p
                   ON p.product_key = f.product_key
          GROUP BY p.product_name) AS t
WHERE    rank <= 5;


-- What are the 5 worst-performing products in terms of sales? 
SELECT   TOP 5 p.product_name,
               SUM(f.sales_amount) AS total_revenue
FROM     gold.fact_sales AS f
         LEFT OUTER JOIN
         gold.dim_products AS p
         ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Find the top 10 customers who have generated highest revenue
SELECT * FROM(
    SELECT   c.customer_key,
             c.first_name,
             c.last_name,
             SUM(f.sales_amount) AS total_revenue,
             ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) rank
    FROM     gold.fact_sales AS f
             LEFT OUTER JOIN
             gold.dim_customers AS c
             ON c.customer_key = f.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
) t 
WHERE rank <= 10;

-- The 3 customers with fewest orders placed
SELECT * FROM(
    SELECT   c.customer_key,
             c.first_name,
             c.last_name,
             COUNT(DISTINCT order_number) AS orders_placed,
             ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT order_number)) Rank
    FROM     gold.fact_sales AS f
             LEFT OUTER JOIN
             gold.dim_customers AS c
             ON c.customer_key = f.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
) t where rank <= 3;
