-- ============================================================================
-- PROJECT: Walmart Retail Performance Analysis
-- ENVIRONMENT: Databricks SQL (Delta Lake)
-- PURPOSE: Data ingestion, data quality validation, and business analytics
-- ============================================================================

-- ============================================================================
-- PHASE 1: DATA INGESTION & ENVIRONMENT SETUP
-- ============================================================================

-- Create a Delta table by reading the sanitized CSV file from Unity Catalog volumes
CREATE TABLE walmart_retail.walmart_retail.walmart_transactions
USING DELTA
AS
SELECT *
FROM read_files(
  '/Volumes/walmart_retail/walmart_retail/walmart_retail/walmart_sales_cleaned.csv',
  format => 'csv',
  header => 'true',
  inferSchema => 'true'
);

-- Preview the first 10 rows to verify successful schema mapping and data structure
SELECT *
FROM walmart_retail.walmart_retail.walmart_transactions
LIMIT 10;

-- Examine column data types, nullability, and database metadata
DESCRIBE TABLE walmart_retail.walmart_retail.walmart_transactions;


-- ============================================================================
-- PHASE 2: DATA QUALITY ASSURANCE & PROFILING
-- ============================================================================

-- Check for any malformed row parsing caught by Databricks rescued data columns
SELECT _rescued_data
FROM walmart_retail.walmart_retail.walmart_transactions
WHERE _rescued_data IS NOT NULL;

-- Profile data volume, unique key integrity constraints, and temporal boundaries
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT transaction_id) AS unique_transactions,
  COUNT(DISTINCT customer_id) AS unique_customers,
  COUNT(DISTINCT product_id) AS unique_products,
  COUNT(DISTINCT store_id) AS unique_stores,
  MIN(transaction_date) AS earliest_date,
  MAX(transaction_date) AS latest_date
FROM walmart_retail.walmart_retail.walmart_transactions;

-- Missing Value Matrix: Verify completeness across all 28 analytical features
SELECT
  SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN quantity_sold IS NULL THEN 1 ELSE 0 END) AS null_quantity_sold,
  SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
  SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS null_transaction_date,
  SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_store_id,
  SUM(CASE WHEN store_location IS NULL THEN 1 ELSE 0 END) AS null_store_location,
  SUM(CASE WHEN customer_age IS NULL THEN 1 ELSE 0 END) AS null_customer_age,
  SUM(CASE WHEN customer_gender IS NULL THEN 1 ELSE 0 END) AS null_customer_gender,
  SUM(CASE WHEN customer_income IS NULL THEN 1 ELSE 0 END) AS null_customer_income,
  SUM(CASE WHEN customer_loyalty_level IS NULL THEN 1 ELSE 0 END) AS null_loyalty_level,
  SUM(CASE WHEN promotion_applied IS NULL THEN 1 ELSE 0 END) AS null_promotion_applied,
  SUM(CASE WHEN promotion_type IS NULL THEN 1 ELSE 0 END) AS null_promotion_type,
  SUM(CASE WHEN weather_conditions IS NULL THEN 1 ELSE 0 END) AS null_weather,
  SUM(CASE WHEN stockout_indicator IS NULL THEN 1 ELSE 0 END) AS null_stockout
FROM walmart_retail.walmart_retail.walmart_transactions;

-- Domain Constraint Validation: Verify categorical field configurations
SELECT DISTINCT customer_loyalty_level FROM walmart_retail.walmart_retail.walmart_transactions ORDER BY 1;
SELECT DISTINCT payment_method FROM walmart_retail.walmart_retail.walmart_transactions ORDER BY 1;
SELECT DISTINCT weather_conditions FROM walmart_retail.walmart_retail.walmart_transactions ORDER BY 1;
SELECT DISTINCT promotion_type FROM walmart_retail.walmart_retail.walmart_transactions ORDER BY 1;
SELECT DISTINCT customer_gender FROM walmart_retail.walmart_retail.walmart_transactions ORDER BY 1;


-- ============================================================================
-- PHASE 3: BUSINESS METRICS & DASHBOARD BACKING QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VISUAL: Total Revenue by Store Location
-- Page Reference: Sales Overview (Page 1 Central Grid)
-- ----------------------------------------------------------------------------
SELECT
  store_location,
  COUNT(transaction_id) AS total_transactions,
  SUM(quantity_sold) AS total_units_sold,
  ROUND(SUM(quantity_sold * unit_price), 2) AS total_revenue,
  ROUND(AVG(quantity_sold * unit_price), 2) AS avg_transaction_value
FROM walmart_retail.walmart_retail.walmart_transactions
GROUP BY store_location
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- VISUAL: Revenue by Category
-- Page Reference: Sales Overview (Page 1 Right Donut Chart / Tooltip)
-- ----------------------------------------------------------------------------
SELECT
  category,
  COUNT(transaction_id) AS total_transactions,
  SUM(quantity_sold) AS total_units_sold,
  ROUND(SUM(quantity_sold * unit_price), 2) AS total_revenue,
  ROUND(AVG(unit_price), 2) AS avg_unit_price,
  ROUND(AVG(quantity_sold * unit_price), 2) AS avg_transaction_value
FROM walmart_retail.walmart_retail.walmart_transactions
GROUP BY category
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- VISUAL: Monthly Revenue Trend
-- Page Reference: Sales Overview (Page 1 Bottom Trend Line)
-- ----------------------------------------------------------------------------
SELECT
  DATE_FORMAT(transaction_date, 'yyyy-MM') AS month,
  COUNT(transaction_id) AS total_transactions,
  SUM(quantity_sold) AS total_units_sold,
  ROUND(SUM(quantity_sold * unit_price), 2) AS total_revenue
FROM walmart_retail.walmart_retail.walmart_transactions
GROUP BY DATE_FORMAT(transaction_date, 'yyyy-MM')
ORDER BY month ASC;


-- ----------------------------------------------------------------------------
-- VISUAL: Promotion Effectiveness Analysis
-- Page Reference: Customer & Loyalty Analysis (Page 2 / Executive Summary Page 4)
-- ----------------------------------------------------------------------------
SELECT
  promotion_applied,
  promotion_type,
  COUNT(transaction_id) AS total_transactions,
  SUM(quantity_sold) AS total_units_sold,
  ROUND(SUM(quantity_sold * unit_price), 2) AS total_revenue,
  ROUND(AVG(quantity_sold * unit_price), 2) AS avg_transaction_value
FROM walmart_retail.walmart_retail.walmart_transactions
GROUP BY promotion_applied, promotion_type
ORDER BY promotion_applied DESC, total_revenue DESC;


-- ----------------------------------------------------------------------------
-- VISUAL: Customer Loyalty Analysis
-- Page Reference: Customer & Loyalty Analysis (Page 2 Strategic Framework Rows)
-- ----------------------------------------------------------------------------
SELECT
  customer_loyalty_level,
  COUNT(transaction_id) AS total_transactions,
  COUNT(DISTINCT customer_id) AS unique_customers,
  SUM(quantity_sold) AS total_units_sold,
  ROUND(SUM(quantity_sold * unit_price), 2) AS total_revenue,
  ROUND(AVG(quantity_sold * unit_price), 2) AS avg_transaction_value,
  ROUND(AVG(customer_age), 1) AS avg_age,
  ROUND(AVG(customer_income), 2) AS avg_income
FROM walmart_retail.walmart_retail.walmart_transactions
GROUP BY customer_loyalty_level
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- VISUAL: Weather and Holiday Impact
-- Page Reference: Sales Overview & Operations Pages (External Factors Grid)
-- ----------------------------------------------------------------------------
SELECT
  weather_conditions,
  holiday_indicator,
  COUNT(transaction_id) AS total_transactions,
  SUM(quantity_sold) AS total_units_sold,
  ROUND(SUM(quantity_sold * unit_price), 2) AS total_revenue,
  ROUND(AVG(quantity_sold * unit_price), 2) AS avg_transaction_value
FROM walmart_retail.walmart_retail.walmart_transactions
GROUP BY weather_conditions, holiday_indicator
ORDER BY weather_conditions, holiday_indicator DESC;


-- ----------------------------------------------------------------------------
-- VISUAL: Stockout and Inventory Analysis
-- Page Reference: Operations & Inventory (Page 3 Actual vs Forecasted Layouts)
-- ----------------------------------------------------------------------------
SELECT
  stockout_indicator,
  category,
  COUNT(transaction_id) AS total_transactions,
  SUM(quantity_sold) AS total_units_sold,
  ROUND(SUM(quantity_sold * unit_price), 2) AS total_revenue,
  ROUND(AVG(inventory_level), 1) AS avg_inventory_level,
  ROUND(AVG(forecasted_demand), 1) AS avg_forecasted_demand,
  ROUND(AVG(actual_demand), 1) AS avg_actual_demand
FROM walmart_retail.walmart_retail.walmart_transactions
GROUP BY stockout_indicator, category
ORDER BY stockout_indicator DESC, category;