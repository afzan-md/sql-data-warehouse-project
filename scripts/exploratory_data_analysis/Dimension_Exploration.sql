-- Explore All Countries our customers come from.
SELECT DISTINCT country
FROM   gold.dim_customers;

-- Explore all product categories.
SELECT   DISTINCT category,
                  subcategory,
                  product_name  -- all three are related to each other.
FROM     gold.dim_products
ORDER BY 1, 2, 3;
-- 