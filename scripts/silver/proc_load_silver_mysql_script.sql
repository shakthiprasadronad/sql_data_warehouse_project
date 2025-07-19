/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/


select @@sql_mode ;
SET SESSION sql_mode = '';


DELIMITER //

DROP PROCEDURE IF EXISTS silver.load_silver;
CREATE PROCEDURE silver.load_silver()
BEGIN

DECLARE start_time DATETIME;
DECLARE end_time DATETIME;
DECLARE batch_start_time DATETIME;
DECLARE batch_end_time DATETIME;

SET batch_start_time = now();

        -- '================================================';
        -- 'Loading Silver Layer';
        -- '================================================';

		-- '------------------------------------------------';
		-- 'Loading CRM Tables';
		-- '------------------------------------------------';
        
        -- Loading silver.crm_cust_info
SET @start_time = now();
		
TRUNCATE TABLE silver.crm_cust_info;
		
INSERT INTO silver.crm_cust_info 
(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)
select		cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
            trim(cst_lastname) as cst_lastname,
            case when upper(trim(cst_marital_status)) = 'S' then 'Single'
				 when upper(trim(cst_marital_status)) = 'M' then 'Married'
                 else 'n/a' 
                 end as cst_marital_status,
            case when upper(trim(cst_gndr)) = 'M' then 'Male'
				 when upper(trim(cst_gndr)) = 'F' then 'Female'
                 else 'n/a'	
                 end as cst_gndr,
            cst_create_date
from		(
				select 		*,
							row_number() over(partition by cst_id order by cst_create_date desc) as latest_data
				from		bronze.crm_cust_info
                where		cst_id is not null
			) t
where 		latest_data = 1;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), 'seconds') AS duration;


-- Still finding some unwanted rows, Filtering them manually using below code (due to MySQL server settings may have caused source data auto conversion)

delete  from 	silver.crm_cust_info
where	cst_create_date = '0000-00-00';

select *
from silver.crm_cust_info






        -- Loading prd.crm_prd_info

SET @start_time = now();

drop table if exists silver.crm_prd_info ;
create table silver.crm_prd_info
(
prd_id				int default null,
cat_id				varchar(50) default null,
prd_key				varchar(50) default null,
prd_nm  			varchar(50) default null,
prd_cost			int default null,
prd_line			varchar(50) default null,
prd_start_dt		date default null,
prd_end_dt			date default null,
dwh_create_date		datetime default current_timestamp()
);

TRUNCATE TABLE silver.crm_prd_info;

insert into silver.crm_prd_info
(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
select		prd_id,
			concat(substr(prd_key, 1, 2), '_', substr(prd_key, 4, 2)) as cat_id,
            substr(prd_key, 7, length(prd_key)) as prd_key,
            prd_nm,
            ifnull(prd_cost, 0) as prd_cost,
            case when upper(trim(prd_line)) = 'M' then 'Mountain'
				 when upper(trim(prd_line)) = 'R' then 'Road'
                 when upper(trim(prd_line)) = 'S' then 'Other Sales'
                 when upper(trim(prd_line)) = 'T' then 'Touring'
                 else 'n/a'
                 end as prd_line,
            prd_start_dt,
            date_sub((lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)), interval 1 day) as prd_end_dt
from		bronze.crm_prd_info;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), 'seconds') AS duration;






        -- Loading silver.crm_sales_details
        
SET @start_time = now();

TRUNCATE TABLE silver.crm_sales_details;

insert into silver.crm_sales_details
(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)
select		sls_ord_num,
			sls_prd_key,
            sls_cust_id,
            nullif(cast(sls_order_dt as date), 0) as sls_order_dt,
            nullif(cast(sls_ship_dt as date), 0) as sls_ship_dt,
            nullif(cast(sls_due_dt as date), 0) as sls_due_dt,
            case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) then abs(sls_quantity * abs(sls_price)) else sls_sales end as sls_sales,
			sls_quantity,
            case when sls_price is null or sls_price <= 0 or sls_price != sls_sales / nullif(sls_quantity, 0) then abs(sls_sales / nullif(sls_quantity, 0)) else sls_price end as sls_price
from		bronze.crm_sales_details;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), 'seconds') AS duration;


-- still if faced any 0 or inccorect values in sls_sales, sls_quantity, sls_price - then we can re-correct it using below table

-- WIP/ under investigation







        -- Loading silver.erp_cust_az12
        
SET @start_time = now();

TRUNCATE TABLE silver.erp_cust_az12;

insert into silver.erp_cust_az12
(
cid,
bdate,
gen
)
select		case when cid like '%NAS%' then substring(cid, 4, length(cid)) else cid end as cid,
			case when bdate > current_date() then null else bdate end as bdate,
			case when upper(trim(gen)) in ('F', 'FEMALE' ) then 'Female'
				 when upper(trim(gen)) in ('M', 'MALE' ) then 'Male'
                 else 'n/a'
                 end as gen
from		bronze.erp_cust_az12;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), 'seconds') AS duration;









        -- Loading silver.erp_loc_a101
        
SET @start_time = now();

TRUNCATE TABLE silver.erp_loc_a101;

insert into silver.erp_loc_a101
(
cid,
cntry
)
select		replace(cid, '-', '') as cid,
			case when trim(cntry) = 'DE' then 'Germany'
				 when trim(cntry) in ('US', 'USA') then 'United States'
                 when trim(cntry) = '' or cntry is null then 'n/a'
                 else trim(cntry)
                 end as cntry
from		bronze.erp_loc_a101;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), 'seconds') AS duration;









        -- Loading silver.erp_px_cat_g1v2
        
SET @start_time = now();

TRUNCATE TABLE silver.erp_px_cat_g1v2;

insert into silver.erp_px_cat_g1v2
(
id,
cat,
subcat,
maintenance
)
select	id,
		cat,
        subcat,
        maintenance
from 	bronze.erp_px_cat_g1v2;

SET @end_time = now();
SELECT CONCAT(TIMESTAMPDIFF(SECOND, @start_time, @end_time), 'seconds') AS duration;




SET batch_end_time = now();



END

DELIMITER //