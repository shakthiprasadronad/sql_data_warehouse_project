/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `LOAD DATA INFILE` command to load data from csv Files to bronze tables.

Parameters:
    SET GLOBAL LOCAL_INFILE=ON
    (Make sure settings in Manage Server Connections > DataWarehouse > Connection > Advanced > Others : firstline - OPT_LOCAL_INFILE=1)
===============================================================================
*/

/*
Inorder to import the raw csv data in to newly created tables inside MySQL without errors like
1. Error 1366 Incorrect Integer Value in the Int rows
2. Error 1292 Incorrect date format in the rows

These are basically empty rows available in csv files
But We can filter and remove them in Data Cleansing Process in next layers

At This stage we need the raw data in Bronze layer so below settings are made 
to get the raw import 
--Firstly we are temporarliy relaxing Strict SQL Mode to SQL = '';
--this includes and corrects the data type and imports in to MySQL Workbench
*/


select @@sql_mode ;
SET SESSION sql_mode = '';


/*
----LOADING_STARTS_HERE----
*/

SET @batch_start_time = now();
		-- '================================================';
		-- 'Loading Bronze Layer';
		-- '================================================';
--


		-- '------------------------------------------------';
		-- 'Loading CRM Tables'--
        
--

SET @start_time = now();
TRUNCATE TABLE bronze.crm_cust_info;
SET GLOBAL LOCAL_INFILE=ON;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/bronze/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS duration;


--
        
SET @start_time = now();
TRUNCATE TABLE bronze.crm_prd_info;
SET GLOBAL LOCAL_INFILE=ON;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/bronze/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS duration;
 
 
--

SET @start_time = now();
TRUNCATE TABLE bronze.crm_sales_details;
SET GLOBAL LOCAL_INFILE=ON;
        
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/bronze/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS duration;


--


		-- '------------------------------------------------';
		-- 'Loading ERP Tables'--
        
        
--

SET @start_time = now();
TRUNCATE TABLE bronze.erp_cust_az12;
SET GLOBAL LOCAL_INFILE=ON;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/bronze/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS duration;


--

SET @start_time = now();
TRUNCATE TABLE bronze.erp_loc_a101;
SET GLOBAL LOCAL_INFILE=ON;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/bronze/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS duration;


--

SET @start_time = now();
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
SET GLOBAL LOCAL_INFILE=ON;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/bronze/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS duration;


--


SET @batch_end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time), ' seconds') AS duration;


/*
----LOADING_ENDS_HERE----
*/
