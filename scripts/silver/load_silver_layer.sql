/*
**************************************
Stored Procedure: Load Silver Layer
**************************************
Script Purpose:
  This stored procedure loads data into silver schema from bronze schema.
  It performs the following actions:
   - Truncates the silver tables before loading data.
   - Insert cleaned bronze tables in silver tables.

This stored procedure does'nt use any parameters.

Usage example: EXEC bronze.load_silver
*/


CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    BEGIN TRY
        DECLARE @start_time AS DATETIME, @end_time AS DATETIME, @Full_start AS DATETIME, @Full_end AS DATETIME;
        SET @Full_start = GETDATE();
        PRINT '==========================';
        PRINT 'Loading Silver Layer';
        PRINT '==========================';
        PRINT '--------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------';
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>>> Inserting Data Into : silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
        SELECT cst_id,
               cst_key,
               TRIM(cst_firstname) AS cst_firstname,
               TRIM(cst_lastname) AS cst_lastname,
               CASE WHEN upper(trim(cst_marital_status)) = 'S' THEN 'Single' WHEN upper(trim(cst_marital_status)) = 'M' THEN 'Married' ELSE 'n/a' END AS cst_marital_status,
               CASE WHEN upper(trim(cst_gndr)) = 'F' THEN 'Female' WHEN upper(trim(cst_gndr)) = 'M' THEN 'Male' ELSE 'n/a' END AS cst_gndr,
               cst_create_date
        FROM   (SELECT *,
                       ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
                FROM   bronze.crm_cust_info) AS t
        WHERE  flag_last = 1
               AND cst_id IS NOT NULL;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '**************************************************';
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>>> Inserting Data Into : silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
        SELECT prd_id,
               replace(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
               SUBSTRING(prd_key, 7, len(prd_key)) AS prd_key,
               prd_nm,
               ISNULL(prd_cost, 0) AS prd_cost,
               CASE upper(trim(prd_line)) WHEN 'M' THEN 'Mountain' WHEN 'R' THEN 'Road' WHEN 'S' THEN 'Other Sales' WHEN 'T' THEN 'Touring' ELSE 'n/a' END AS prd_line,
               CAST (prd_start_dt AS DATE) AS prd_start_dt,
               CAST (lead(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
        FROM   bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '**************************************************';
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>>> Inserting Data Into : silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
        SELECT sls_ord_num,
               sls_prd_key,
               sls_cust_id,
               CASE WHEN sls_order_dt <= 0
                         OR len(sls_order_dt) != 8 THEN NULL ELSE CAST (CAST (sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
               CASE WHEN sls_ship_dt <= 0
                         OR len(sls_ship_dt) != 8 THEN NULL ELSE CAST (CAST (sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
               CASE WHEN sls_due_dt <= 0
                         OR len(sls_due_dt) != 8 THEN NULL ELSE CAST (CAST (sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
               CASE WHEN sls_sales <= 0
                         OR sls_sales IS NULL
                         OR sls_sales != sls_quantity * abs(sls_price) THEN sls_quantity * abs(sls_price) ELSE sls_sales END AS sls_sales,
               sls_quantity,
               CASE WHEN sls_price = 0
                         OR sls_price IS NULL THEN sls_sales / NULLIF (sls_quantity, 0) WHEN sls_price < 0 THEN abs(sls_price) ELSE sls_price END AS sls_price
        FROM   bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '**************************************************';
        SET @Full_end = GETDATE();
        PRINT '>> Total Duration: ' + CAST (Datediff(second, @Full_start, @Full_end) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------------';
        SET @Full_start = GETDATE();
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>>> Inserting Data Into : silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (CID, BDATE, GEN)
        SELECT CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, len(CID)) ELSE CID END AS CID,
               CASE WHEN BDATE > GETDATE() THEN NULL ELSE BDATE END AS BDATE,
               CASE WHEN upper(trim(GEN)) IN ('F', 'FEMALE') THEN 'Female' WHEN upper(trim(GEN)) IN ('M', 'MALE') THEN 'Male' ELSE 'n/a' END AS GEN
        FROM   bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '**************************************************';
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>>> Inserting Data Into : silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (CID, CNTRY)
        SELECT replace(CID, '-', '') AS CID,
               CASE WHEN trim(CNTRY) = 'DE' THEN 'Germany' WHEN trim(CNTRY) IN ('US', 'USA') THEN 'United States' WHEN trim(CNTRY) = ''
                                                                                                                       OR CNTRY IS NULL THEN 'n/a' ELSE trim(CNTRY) END AS CNTRY
        FROM   bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '**************************************************';
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>>> Inserting Data Into : silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id,
               cat,
               subcat,
               maintenance
        FROM   bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '**************************************************';
        SET @Full_end = GETDATE();
        PRINT '>> Total Duration: ' + CAST (Datediff(second, @Full_start, @Full_end) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT '--------------------------------------------';
        PRINT 'Error Occured';
        PRINT 'ERROR_MESSAGE: ' + Error_message();
        PRINT 'ERROR_NUMBER: ' + CAST (Error_number() AS NVARCHAR);
        PRINT 'ERROR_LINE: ' + CAST (Error_line() AS VARCHAR);
        PRINT '--------------------------------------------';
    END CATCH
END
