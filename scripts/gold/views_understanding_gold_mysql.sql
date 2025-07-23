					-- creating customer table from crm


-- Step-1 Data Tables joining and checking for duplicates/nulls

select		ci.cst_id,
			ci.cst_key,
			ci.cst_firstname,
            ci.cst_lastname,
            ci.cst_marital_status,
            ci.cst_gndr,
            ci.cst_create_date,
            ca.bdate,
            ca.gen,
            la.cntry
from 		silver.crm_cust_info  ci
left join	silver.erp_cust_az12 ca			-- when inner join done then it matches the matching values only eliminating nulls, so we perform left join inorder to not to lose data
on			ci.cst_key = ca.cid			
left join	silver.erp_loc_a101 la
on			ci.cst_key = la.cid				-- always perform from master table - leftjoin - other tables


-- After joining, we must check if any duplicates wee introduced by the join logic

select		cst_id, count(*)
from		(
select		ci.cst_id,
			ci.cst_key,
			ci.cst_firstname,
            ci.cst_lastname,
            ci.cst_marital_status,
            ci.cst_gndr,
            ci.cst_create_date,
            ca.bdate,
            ca.gen,
            la.cntry
from 		silver.crm_cust_info  ci
left join	silver.erp_cust_az12 ca			
on			ci.cst_key = ca.cid			
left join	silver.erp_loc_a101 la
on			ci.cst_key = la.cid
) t
group by	cst_id
having 		count(*) > 1

-- We don't have any duplicates from above query
-- also nulls are converted to n/a in silver layer itself


-- Step-2 Check for repeating columns from tables after joining

-- just by looking at table we can see there are 'cst_gndr' and 'gen' columns
-- we need to integrate them now
-- before integrating them let's check for duplicates and nulls investigation

select		distinct ci.cst_gndr, ca.gen
from 		silver.crm_cust_info  ci
left join	silver.erp_cust_az12 ca			
on			ci.cst_key = ca.cid			
left join	silver.erp_loc_a101 la
on			ci.cst_key = la.cid
order by	1, 2

-- here we get two columns with 'same dimensions in both columns'(male - male/female - female/na - na)
-- or 
-- 'n/a in one and dim in one' (n/a - female/ male - n/a)
-- or
-- 'dim and n/a' or 'dim and non matching dims' ( male - female )

-- In this case we need to discuss with business experts and verigy which is master and which one to refer
-- Since the crm is the master received from them -- they'll again say it's CRM
-- so we can use crm gender as master and missing ones can be takem from erp

select		distinct ci.cst_gndr, ca.gen,
            case when ci.cst_gndr != 'n/a' then ci.cst_gndr else coalesce(ca.gen, 'n/a') end as new_gen, -- crm is the master for gender info so we use
from 		silver.crm_cust_info  ci
left join	silver.erp_cust_az12 ca			
on			ci.cst_key = ca.cid			
left join	silver.erp_loc_a101 la
on			ci.cst_key = la.cid
order by	1, 2
			
-- researched the case when statment and found below one works as well
-- case when ci.cst_gndr = 'n/a' then ca.gen else ci.cst_gndr end as new_gen2

-- **This is called Data Integration**--

-- This new column we can integrate in to the existing table

select		ci.cst_id as customer_id,
			ci.cst_key as customer_number,
			ci.cst_firstname as first_name,
            ci.cst_lastname as last_name,
            la.cntry as country,
            ci.cst_marital_status as marital_status,
            case when ci.cst_gndr != 'n/a' then ci.cst_gndr else coalesce(ca.gen, 'n/a') end as gender,
            ca.bdate as birthdate,
            ci.cst_create_date as create_date
from 		silver.crm_cust_info  ci
left join	silver.erp_cust_az12 ca	
on			ci.cst_key = ca.cid			
left join	silver.erp_loc_a101 la
on			ci.cst_key = la.cid	

-- In-order to connect data models we need a separate column called surrogate_key 
-- a table's surrogate_key is just nothing but representation of each table through we can conenct to other table in a ordered structure

 select		row_number() over(order by cst_id) as customer_key,
			ci.cst_id as customer_id,
			ci.cst_key as customer_number,
			ci.cst_firstname as first_name,
            ci.cst_lastname as last_name,
            la.cntry as country,
            ci.cst_marital_status as marital_status,
            case when ci.cst_gndr != 'n/a' then ci.cst_gndr else coalesce(ca.gen, 'n/a') end as gender,
            ca.bdate as birthdate,
            ci.cst_create_date as create_date
from 		silver.crm_cust_info  ci
left join	silver.erp_cust_az12 ca	
on			ci.cst_key = ca.cid			
left join	silver.erp_loc_a101 la
on			ci.cst_key = la.cid	

-- now let's create the view called 'gold.dim_customers'

create view gold.dim_customers as
select		row_number() over(order by cst_id) as customer_key,
			ci.cst_id as customer_id,
			ci.cst_key as customer_number,
			ci.cst_firstname as first_name,
            ci.cst_lastname as last_name,
            la.cntry as country,
            ci.cst_marital_status as marital_status,
            case when ci.cst_gndr != 'n/a' then ci.cst_gndr else coalesce(ca.gen, 'n/a') end as gender,
            ca.bdate as birthdate,
            ci.cst_create_date as create_date
from 		silver.crm_cust_info  ci
left join	silver.erp_cust_az12 ca	
on			ci.cst_key = ca.cid			
left join	silver.erp_loc_a101 la
on			ci.cst_key = la.cid	



-- Quality check for the views created

-- Step-1 Load and observe
select	*
from	gold.dim_customers		-- loads correctly without any issue + All columns looks good for analystics

-- Step-2 check the cardinality columns with distinct
select	distinct gender
from	gold.dim_customers      -- only 3 distinct dims came and it's what we required







			-- Creating view of products tables from crm

select		pn.prd_id,
			pn.cat_id,
            pn.prd_key,
            pn.prd_nm,
            pn.prd_cost,
            pn.prd_line,
            pn.prd_start_dt,
            pn.prd_end_dt
from		silver.crm_prd_info pn

-- we can see the end_date of product is null
-- then it is current info of the product - meaning( consider products with end dates are historical ones and end date with nulls are active/current products )


select		pn.prd_id,
			pn.cat_id,
            pn.prd_key,
            pn.prd_nm,
            pn.prd_cost,
            pn.prd_line,
            pn.prd_start_dt,
            pc.cat,
            pc.subcat,
            pc.maintenance
from		silver.crm_prd_info pn
left join	silver.erp_px_cat_g1v2 pc
on 			pn.cat_id = pc.id
where		pn.prd_end_dt is null 		-- filters out all historical data
            
-- now we have collected all relevant data from customers and products tables


-- Quality Checking

-- 1.Check for duplicate rows

select 		prd_key,
			count(*)
from		(
select		pn.prd_id,
			pn.cat_id,
            pn.prd_key,
            pn.prd_nm,
            pn.prd_cost,
            pn.prd_line,
            pn.prd_start_dt,
            pc.cat,
            pc.subcat,
            pc.maintenance
from		silver.crm_prd_info pn
left join	silver.erp_px_cat_g1v2 pc
on 			pn.cat_id = pc.id
where		pn.prd_end_dt is null 
) t
group by	prd_key
having 		count(*) > 1


-- 2.Friendly naming and providing a surrogate key to interact with other tables in furture

select		pn.prd_id as product_id,
            pn.prd_key as product_number,
            pn.prd_nm as product_name,
            pn.cat_id as category_id,
            pc.cat as category,
            pc.subcat as subcategory,
            pc.maintenance,
            pn.prd_cost as cost,
            pn.prd_line as product_line,
            pn.prd_start_dt as start_date
from		silver.crm_prd_info pn
left join	silver.erp_px_cat_g1v2 pc
on 			pn.cat_id = pc.id
where		pn.prd_end_dt is null 

-- In-order to connect data models we need a separate column called surrogate_key 
-- a table's surrogate_key is just nothing but representation of each table through we can conenct to other table in a ordered structure

select		row_number() oevr(order by pn.prd_start_dt, pn.prd_key) as product_key,
			pn.prd_id as product_id,
            pn.prd_key as product_number,
            pn.prd_nm as product_name,
            pn.cat_id as category_id,
            pc.cat as category,
            pc.subcat as subcategory,
            pc.maintenance,
            pn.prd_cost as cost,
            pn.prd_line as product_line,
            pn.prd_start_dt as start_date
from		silver.crm_prd_info pn
left join	silver.erp_px_cat_g1v2 pc
on 			pn.cat_id = pc.id
where		pn.prd_end_dt is null 

-- now create view for product table

create view gold.dim_products as
select		row_number() over(order by pn.prd_start_dt, pn.prd_key) as product_key,
			pn.prd_id as product_id,
            pn.prd_key as product_number,
            pn.prd_nm as product_name,
            pn.cat_id as category_id,
            pc.cat as category,
            pc.subcat as subcategory,
            pc.maintenance,
            pn.prd_cost as cost,
            pn.prd_line as product_line,
            pn.prd_start_dt as start_date
from		silver.crm_prd_info pn
left join	silver.erp_px_cat_g1v2 pc
on 			pn.cat_id = pc.id
where		pn.prd_end_dt is null 


-- Quality Checks

-- look for loads or not

select		*
from		gold.dim_products











				--  Creating FACT Sales
                
-- Till now we created customers and products relational database connections and tables
-- Now it's time to actually create Sales and Customers and Products 

select			sd.sls_ord_num,
				sd.sls_prd_key,
                sd.sls_cust_id,
                sd.sls_order_dt,
                sd.sls_ship_dt,
                sd.sls_due_dt,
                sd.sls_sales,
                sd.sls_quantity,
                sd.sls_price
from			silver.crm_sales_details  sd


-- here we can observe the table with Dimensions and Measures
-- Bulding Fact - Use the dimension's surrogate keys instead of IDs to easily connect facts with dimensions

-- Step-1 Join the SD table with product and customer table -- search for common keys in schema diagram

select			sd.sls_ord_num,
				sd.sls_prd_key,
                sd.sls_cust_id,
                sd.sls_order_dt,
                sd.sls_ship_dt,
                sd.sls_due_dt,
                sd.sls_sales,
                sd.sls_quantity,
                sd.sls_price
from			silver.crm_sales_details  sd
left join		gold.dim_products pr
on 				sd.sls_prd_key = pr.product_number
left join		gold.dim_customers cu
on				sd.sls_cust_id = cu.customer_id


-- Step-2 - Now join the table with customer table
			-- Now Create a Surrogate key and renaming headers to user friendly manner


select			sd.sls_ord_num as order_number,
				pr.product_key,
                cu.customer_key,
                sd.sls_order_dt as order_date,
                sd.sls_ship_dt as shipping_date,
                sd.sls_due_dt as due_date,
                sd.sls_sales as sales_amount,
                sd.sls_quantity as quantity,
                sd.sls_price as price
from			silver.crm_sales_details  sd
left join		gold.dim_products pr
on 				sd.sls_prd_key = pr.product_number
left join		gold.dim_customers cu
on				sd.sls_cust_id = cu.customer_id

-- now if we observe -- we connected 3 tables -- customer - product - & sales detailes using that surrogate key
-- see the first 3 columns - (these are same in customer and product and sales tables)


-- Creating View for sales details

create view gold.fact_sales
(
select			sd.sls_ord_num as order_number,
				pr.product_key,
                cu.customer_key,
                sd.sls_order_dt as order_date,
                sd.sls_ship_dt as shipping_date,
                sd.sls_due_dt as due_date,
                sd.sls_sales as sales_amount,
                sd.sls_quantity as quantity,
                sd.sls_price as price
from			silver.crm_sales_details  sd
left join		gold.dim_products pr
on 				sd.sls_prd_key = pr.product_number
left join		gold.dim_customers cu
on				sd.sls_cust_id = cu.customer_id
)






				-- Foreign Key Integration (Dimensions)


select			*
from			gold.fact_sales	f
left join		gold.dim_customers c
on				c.customer_key = f.customer_key
left join		gold.dim_products p
on				p.product_key = f.product_key
where			p.product_key is null

-- Here we can see the product key is the surrogate key we kept creating while building gold layer


