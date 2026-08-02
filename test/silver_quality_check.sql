/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


-- Check for NULLs and Duplicates in Primary key
SELECT   cst_id,
         count(*)
FROM     bronze.crm_cust_info
GROUP BY cst_id
HAVING   count(*) > 1
         OR cst_id IS NULL;

-- Check for unwanted space
SELECT cst_firstname
FROM   bronze.crm_cust_info
WHERE  cst_firstname != trim(cst_firstname);

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM   bronze.crm_cust_info;

-- Check for NULLs and negetive costs, quantity etc...
SELECT prd_cost
FROM   bronze.crm_prd_info
WHERE  prd_cost < 0
       OR prd_cost IS NULL;

-- Check for invalid date orders DATA ENRICHMENT
SELECT *
FROM   bronze.crm_prd_info
WHERE  prd_end_dt < prd_start_dt;

-- Check for invalid dates
SELECT sls_order_dt
FROM   bronze.crm_sales_details
WHERE  sls_order_dt <= 0
       OR len(sls_order_dt) != 8
       OR sls_order_dt > '20500101'
       OR sl
