/*
===============================================================================
DDL Script: Create silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
    Data Engineers best practices includes adding metadata columns - These columns will not be available in source data,
    like create_date(), update_date(), source_system(), file_location() - Why because this helps in future as we go along building DWH,
    incase of any corrupt data or if there's a requirement to investigate source data - this helps to track our source data correctness,
	Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

create database if not exists silver;

use silver;

drop table if exists silver.crm_cust_info ;
create table silver.crm_cust_info 
(
cst_id 				int default null,
cst_key 			varchar(50) default null,
cst_firstname 		varchar(50) default null,
cst_lastname 		varchar(50) default null,
cst_marital_status 	varchar(50) default null,
cst_gndr 			varchar(50) default null,
cst_create_date 	date default null,
dwh_create_date		datetime default current_timestamp()
) ;

drop table if exists silver.crm_prd_info ;
create table silver.crm_prd_info
(
prd_id				int default null,
prd_key				varchar(50) default null,
prd_nm  			varchar(50) default null,
prd_cost			int default null,
prd_line			varchar(50) default null,
prd_start_dt		date default null,
prd_end_dt			date default null,
dwh_create_date		datetime default current_timestamp()
);

drop table if exists silver.crm_sales_details ;
create table silver.crm_sales_details
(
sls_ord_num 		varchar(50) default null,
sls_prd_key 		varchar(50) default null,
sls_cust_id 		int default null,
sls_order_dt 		date default null,
sls_ship_dt 		date default null,
sls_due_dt 			date default null,
sls_sales 			int default null,
sls_quantity 		int default null,
sls_price 			int default null,
dwh_create_date		datetime default current_timestamp()
);

drop table if exists silver.erp_CUST_AZ12 ;
create table silver.erp_CUST_AZ12
(
CID					varchar(50) default null,
BDATE				date default null,
GEN					varchar(50) default null,
dwh_create_date		datetime default current_timestamp()
);

drop table if exists silver.erp_LOC_A101 ;
create table silver.erp_LOC_A101
(
CID 				varchar(50) default null,
CNTRY 				varchar(50) default null,
dwh_create_date		datetime default current_timestamp()
);

drop table if exists silver.erp_PX_CAT_G1V2 ;
create table silver.erp_PX_CAT_G1V2
(
ID 					varchar(50) default null,
CAT 				varchar(50) default null,
SUBCAT 				varchar(50) default null,
MAINTENANCE 		varchar(50) default null,
dwh_create_date		datetime default current_timestamp()
);
