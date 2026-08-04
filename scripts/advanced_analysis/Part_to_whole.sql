-- which category contribute the most to overall sales
WITH cat_sales AS(
SELECT category,
       SUM(sales_amount) total_sales
FROM   gold.fact_sales AS f
       LEFT OUTER JOIN
       gold.dim_products AS p
       ON p.product_key = f.product_key
GROUP BY category)

SELECT
category,
total_sales,
SUM(total_sales) OVER() overall_sales,
CAST(ROUND(CAST(total_sales as float)/SUM(total_sales) OVER() * 100, 2) AS varchar) + '%'  ptw_sale
from cat_sales