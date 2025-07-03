/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

create database if not exists bronze;

use bronze;

drop table if exists bronze.crm_cust_info ;
create table bronze.crm_cust_info 
(
cst_id 				text,
cst_key 			text,
cst_firstname 		text,
cst_lastname 		text,
cst_marital_status 	text,
cst_gndr 			text,
cst_create_date 	text
) ;

drop table if exists bronze.crm_prd_info ;
create table bronze.crm_prd_info
(
prd_id			text,
prd_key			text,
prd_nm  		text,
prd_cost		text,
prd_line		text,
prd_start_dt	text,
prd_end_dt		text
);

drop table if exists bronze.crm_sales_details ;
create table bronze.crm_sales_details
(
sls_ord_num 	text,
sls_prd_key 	text,
sls_cust_id 	text,
sls_order_dt 	text,
sls_ship_dt 	text,
sls_due_dt 		text,
sls_sales 		text,
sls_quantity 	text,
sls_price 		text
);

drop table if exists bronze.erp_CUST_AZ12 ;
create table bronze.erp_CUST_AZ12
(
CID		text,
BDATE	text,
GEN		text
);

drop table if exists bronze.erp_LOC_A101 ;
create table bronze.erp_LOC_A101
(
CID 	text,
CNTRY 	text
);

drop table if exists bronze.erp_PX_CAT_G1V2 ;
create table bronze.erp_PX_CAT_G1V2
(
ID 			text,
CAT 		text,
SUBCAT 		text,
MAINTENANCE text
);
