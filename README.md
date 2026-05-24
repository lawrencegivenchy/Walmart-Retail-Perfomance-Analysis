# Walmart Retail Performance Analysis

## 📌 Project Overview
A comprehensive retail analytics project analyzing 5,000 transactions across 5 United States Walmart store locations from January to September 2024. This end-to-end project covers the data pipeline from initial data cleaning to advanced validation using SQL, culminating in an interactive, executive-ready Power BI application.

## 💼 Business Problem
Walmart's operations team required deep, centralized visibility into store performance, customer loyalty behavior, promotion effectiveness, and supply chain inventory health to substitute intuition with data-driven decision making.

## 🛠️ Tools Used
* **Microsoft Excel** — Initial data cleaning & profiling
* **SQL (Databricks)** — Exploratory data analysis, data validation, and structural verification
* **Power BI Desktop** — Multi-page dashboard architecture, UI/UX design, and interactive visualization

## 📊 Dataset Profile
* **Source:** Kaggle Retail Dataset
* **Volume:** 5,000 transactions | 28 features (columns)
* **Temporal Scope:** January 2024 — September 2024
* **Geographic Scope:** 5 distinct US metropolitan store locations
* **Product Scope:** 2 primary categories (Electronics and Appliances)

---

## 🧹 Data Pipeline & Cleaning

### Phase 1: Excel Data Prep
* Separated raw `transaction_date` timestamp fields into distinct, optimized `date` and `time` columns.
* Inspected and standardized column headers for database schema compatibility.
* Exported the sanitized dataset as a **CSV UTF-8 (comma-delimited)** file for cloud data warehouse ingestion.

### Phase 2: SQL Validation (Databricks)
* **Primary Key Integrity:** Confirmed `0` duplicate transaction IDs.
* **Data Completeness:** Verified `0` null values across all 28 columns.
* **Categorical Domain Verification:** Confirmed constraints for 5 distinct store locations, 4 loyalty tiers, 4 payment methods, 4 weather conditions, and 3 promotion types.

---

## 📈 Key Findings
1. **Top Performer:** Los Angeles generated the highest total revenue at **$3.3M**.
2. **Core Revenue Driver:** Electronics led product sales, driving **52.03%** of total revenue.
3. **Seasonality Peak:** September 2024 hit a baseline monthly revenue peak of **$2.02M**.
4. **Supply Chain Disconnect:** The overall stockout rate exceeded **51.86%** despite highly accurate demand forecasting models.
5. **Loyalty Inefficiency:** Bronze customers held the highest average demographic income at **$70,932**, yet remained un-upgraded in the lowest loyalty tier.
6. **Promo Basket Value:** Percentage Discount promotions generated the highest average transaction value at **$3,106**.
7. **Data Quality Anomaly:** Identified **1,794 transactions** flagged as "Promoted" that entirely lacked a recorded promotion type.

---

## 💡 Business Recommendations
1. **Fix Replenishment Execution:** Audit warehouse-to-shelf logistics. Demand forecasting trends are highly accurate, meaning stockouts (>51%) are driven by physical execution gaps, not bad data.
2. **Target Bronze Tiers:** Launch a targeted data-driven upgrade campaign aimed at high-income Bronze tier customers to transition them into higher-yielding loyalty brackets.
3. **Prioritize High-Value Promos:** Optimize marketing spend by scaling Percentage Discount campaigns, which yield the highest average transaction values ($3,106).
4. **Investigate June Revenue Dip:** Deep-dive into the June structural sales drop ($1.60M lowest completed month) to determine external market or inventory constraints.
5. **Data Governance Clean-up:** Resolve the upstream system bugs causing 1,794 transactions to drop promotion types during data capture.

---

## 🖥️ Dashboard Architecture
The Power BI application utilizes a modern, left-hand app-style navigation menu mapping across four customized visual layers:

1. **Sales Overview** — High-level operational metrics, geographic store maps, category splits, and chronological trend lines.
2. **Customer & Loyalty Analysis** — Demographic grids, purchasing volume segments, payment preferences, and promo responses.
3. **Operations & Inventory** — Dual-axis actual vs. forecasted demand tracking, inventory levels, supplier lead times, and stockout impacts.
4. **Executive Summary** — Bulletproof data narratives and prescriptive recommendations explicitly framed for stakeholders.

---

## 🖥️ Dashboard Architecture & Visuals
The complete interactive Power BI application is structured across four custom application-style pages. 

To view the full high-resolution layout and pixel-perfect design specifications for all pages, you can access the compiled dashboard documentation file directly:

🔗 **[View / Download Full Dashboard PDF](./Walmart_Retail_Perfomance_Analysis_Dash.pdf)**

---

### 📄 Document Page Index
1. **Page 1: Sales Overview** — High-level operational revenue, geographic store distributions, category splits, and chronological trend lines.
2. **Page 2: Customer & Loyalty Analysis** — Demographic grids, purchasing volume segments, payment method preferences, and promotion responses.
3. **Page 3: Operations & Inventory** — Dual-axis actual vs. forecasted demand tracking, inventory level baselines, supplier lead times, and stockout impacts.
4. **Page 4: Executive Summary** — Strategic data narratives and prescriptive recommendations explicitly framed for stakeholders.

---

## 💻 Core SQL Script Highlights

'''SQL
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
ORDER BY stockout_indicator DESC, category;'''
