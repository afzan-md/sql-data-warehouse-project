/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks to validate the integrity, 
    consistency, and accuracy of the 'gold' layer. These checks ensure:
    - Uniqueness of the surrogate keys in the dimension tables.
    - Referential integrity between fact and dimension tables. 
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
-- Check duplicate in PK
SELECT   prd_key,
         count(*)
FROM     (SELECT pi.prd_id,
       pi.cat_id,
       pi.prd_key,
       pi.prd_nm,
       pi.prd_cost,
       pi.prd_line,
       pi.prd_start_dt,
       pc.cat,
       pc.subcat,
       pc.maintenance
FROM   silver.crm_prd_info AS pi
       LEFT OUTER JOIN
       silver.erp_px_cat_g1v2 AS pc
       ON pi.cat_id = pc.id
       where pi.prd_end_dt is null) AS t
GROUP BY prd_key
HAVING   count(*) > 1;

-- Data integration

SELECT   DISTINCT ci.cst_gndr,
                  ca.GEN,
                  case when ci.cst_gndr != 'n/a' then ci.cst_gndr
                  else coalesce(ca.gen, 'n/a')
                  end
FROM     silver.crm_cust_info AS ci
         LEFT OUTER JOIN
         silver.erp_cust_az12 AS ca
         ON ci.cst_key = ca.CID
         LEFT OUTER JOIN
         silver.erp_loc_a101 AS la
         ON ci.cst_key = la.CID
ORDER BY 1, 2;

-- Foreign Key Integrity (Dimensions) ** For Fact Table **

SELECT *
FROM   gold.fact_sales AS f
       LEFT OUTER JOIN
       gold.dim_customers AS c
       ON c.customer_key = f.customer_key
       LEFT OUTER JOIN
       gold.dim_products AS p
       ON p.product_key = f.product_key
WHERE  c.customer_key IS NULL
       AND p.product_key IS NULL;


select * from gold.dim_customers;
select * from gold.dim_products;
