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

## 📸 Dashboard Screenshots
### 1. Sales Overview
*Add your Page 1 Image Link here*

### 2. Customer & Loyalty Analysis
*Add your Page 2 Image Link here*

### 3. Operations & Inventory
*Add your Page 3 Image Link here*

### 4. Executive Summary
*Add your Page 4 Image Link here*

---

## 💻 Core SQL Script Highlights

### 1. Data Integrity and Duplicate Check
```sql
SELECT 
    transaction_id, 
    COUNT(*) as duplicate_count
FROM 
    walmart_transactions
GROUP BY 
    transaction_id
HAVING 
    COUNT(*) > 1;
