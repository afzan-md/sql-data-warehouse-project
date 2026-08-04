-- Sales Performance Over Time.
SELECT   FORMAT(order_date, 'yyyy-MMM') AS order_date,
         SUM(sales_amount) AS total_sales,
         COUNT(DISTINCT customer_key) AS total_customer,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');