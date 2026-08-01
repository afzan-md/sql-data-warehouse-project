/*
**************************************
Stored Procedure: Load Bronze Layer
**************************************
Script Purpose:
  This stored procedure loads data into bronze schema from external csv files.
  It performs the following actions:
   - Truncates the bronze tables before loading data.
   - Uses the Bulk insert command to load data from csv files.

This stored procedure does'nt use any parameters.

Usage example: EXEC bronze.load_bronze
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    BEGIN TRY
        DECLARE @start_time AS DATETIME, @end_time AS DATETIME,
                @Full_start as datetime, @Full_end as Datetime ;
        
        set @Full_start = GETDATE();
        PRINT '==========================';
        PRINT 'Loading Bronze Layer';
        PRINT '==========================';
        
        PRINT '--------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------';
        
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>>> Inserting Data Into : bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info FROM 'C:\Users\Afzan\Desktop\DWH_Project\Dataset\source_crm\cust_info.csv'
            WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        print '**************************************************';
        
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>>> Inserting Data Into : bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info FROM 'C:\Users\Afzan\Desktop\DWH_Project\Dataset\source_crm\prd_info.csv'
            WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        print '**************************************************';
        
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>>> Inserting Data Into : bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details FROM 'C:\Users\Afzan\Desktop\DWH_Project\Dataset\source_crm\sales_details.csv'
            WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        print '**************************************************';

        set @Full_end = GETDATE();
        PRINT '>> Total Duration: ' + CAST (Datediff(second, @Full_start, @Full_end) AS NVARCHAR) + ' seconds';
        
        PRINT '--------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------------';
 
        set @Full_start = GETDATE();

        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT '>>> Inserting Data Into : bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12 FROM 'C:\Users\Afzan\Desktop\DWH_Project\Dataset\source_erp\cust_az12.csv'
            WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        print '**************************************************';
        
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT '>>> Inserting Data Into : bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101 FROM 'C:\Users\Afzan\Desktop\DWH_Project\Dataset\source_erp\loc_a101.csv'
            WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        print '**************************************************';
        
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '>>> Inserting Data Into : bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2 FROM 'C:\Users\Afzan\Desktop\DWH_Project\Dataset\source_erp\px_cat_g1v2.csv'
            WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST (Datediff(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        print '**************************************************';

        set @Full_end = GETDATE();
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
