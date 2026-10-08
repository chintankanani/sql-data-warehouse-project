/*
===============================================================================
Quality Check
===============================================================================
Script Purpose:
    The script performs various quality check for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes check for:
    - NULL or duplicate primary keys.
    - Unwantes spaces value un string fields.
    - Data standardization & consistency.
    - Invlid data ranges & orders.
    - Data consistency between related fields.
		
Usage Notes:
    - Run these checks after loading silver layer.
    - Investigate and resolve any discrepancies found during the checks

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

===============================================================================
-- Checking 'silver.crm_cust_info'
===============================================================================

-- check for NULLs or Duplicate in Primary Key
-- Expection: No result

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id

-- Check for unwanted spaces
-- Expection: No result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Check for unwanted spaces
-- Expection: No result
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Check for unwanted spaces
-- Expection: No result
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- Data Standardization & Consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info -- store clear & meaningful values rather than using abbreviated terms

===============================================================================
-- Checking 'silver.crm_prd_info'
===============================================================================
-- check for NULLs or Duplicate in Primary Key
-- Expection: No result

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expection: No result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLS or Negative numbers
-- Expection: No result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
-- Expection: End date should be after start date
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

===============================================================================
-- Checking 'silver.crm_sales_details'
===============================================================================
-- Check for unwanted spaces
-- Expection: No result
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check for Invalid Dates
-- Expection: No result
SELECT 
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 --YYYYMMDD

-- Check for Invalid Dates
-- Expection: No result
SELECT 
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity & Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero or negatives

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

===============================================================================
-- Checking 'silver.erp_cust_az12'
===============================================================================
-- Identify Out-of-Range Dates
SELECT DISTINCT
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

-- Data Standardization & Consistencey
SELECT DISTINCT gen
FROM silver.erp_cust_az12

===============================================================================
-- Checking 'silver.erp_loc_a101'
===============================================================================
-- Data Standardization & Consistencey
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry

===============================================================================
-- Checking 'silver.erp_px_cat_g1v2'
===============================================================================
-- Checked for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT
cat -- Check for subcat & maintenance 
FROM silver.erp_px_cat_g1v2
