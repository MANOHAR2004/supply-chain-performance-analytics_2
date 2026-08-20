# Supply Chain Performance & Risk Analytics

![Python](https://img.shields.io/badge/Python-3.13-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## Project Overview

An end-to-end supply chain analytics project analysing 10,324 
real USAID procurement shipment records spanning 2006-2015 
across 43 countries and 72 vendors. The project identifies 
delivery performance gaps, freight cost inefficiencies, and 
vendor reliability patterns across global health commodity 
supply chains — specifically pharmaceutical procurement for 
HIV/AIDS, malaria, and diagnostic programmes.

This project demonstrates a complete data analytics pipeline:
Python (EDA + cleaning) → MySQL (schema + analysis) → 
Power BI (interactive dashboard).

![Dashboard Preview_page_2](<img width="1324" height="743" alt="image" src="https://github.com/user-attachments/assets/6fa36d15-0098-4ecc-90b8-b1f7aad21657" />


)

![Dashboard Preview_page_1](<img width="1328" height="739" alt="image" src="https://github.com/user-attachments/assets/7a69576c-8b17-4728-aa79-eb0435b56d1e" />



)

![Dashboard Demo](<img width="1389" height="793" alt="ShareX_cSUNl77FUh" src="https://github.com/user-attachments/assets/a2ff2810-d8ee-427e-8f11-8ab087e817f3" />


---

## Business Problem

A supply chain director needs answers to four critical questions:

- Which vendors are consistently delivering late and by how much?
- What percentage of shipments are on time across different 
  shipment modes and countries?
- Where is freight cost disproportionately high relative to 
  line item value?
- Which countries and product groups carry the highest 
  delivery risk?

---

## Dataset

**Source:** USAID Supply Chain Management System (SCMS) 
Delivery History Dataset — publicly available government 
procurement data from global health commodity shipments.

**Download:** Available on Kaggle — search 
"SCMS Delivery History Dataset"

**Size:** 10,324 rows × 33 original columns 
(39 after feature engineering)

**Coverage:** 2006-2015 | 43 countries | 72 vendors | 
4 shipment modes | 5 product groups

**Domain:** Pharmaceutical supply chain — ARV medicines, 
diagnostic test kits (HRDT/MRDT), antimalarials (ANTM/ACT)

---

## Project Structure

supply-chain-performance-analytics/
│
├── data/
│ ├── raw_data/
│ │ └── SCMS_Delivery_History_Dataset_20150929.csv
│ └── processed/
│ ├── scms_cleaned.csv
│ ├── vw_delivery_performance.csv
│ └── vw_vendor_country_analysis.csv
│
├── python_code/
│ ├── 01_eda_cleaning.ipynb
│ ├── 02_load_to_mysql.py
│ └── 03_export_for_powerbi.py
│ ├── 02_load_to_mysql.ipynb
│ ├── 02_load_to_mysql.py
│ └── tempCodeRunnerFile.py
│ ├── scraper.PY
│ └── 03_export_for_powerbi.ipynb
│
├── sql/
│ ├── 01_schema.sql
│ ├── 02_cleaning.sql
│ ├── 03_analysis.sql
│ └── 04_views.sql
  └── 01_schema_1.sql
│
├── powerbi/
│ └── Supply_chain_management_dashboard.pbix
│
├── docs/
│ ├── issue_log.md
│ ├── business_questions.md
│ └── progress_tracker.md
│
└── README.md


---

## Tech Stack

| Tool | Version | Purpose |
|---|---|---|
| Python | 3.13 | EDA, cleaning, feature engineering |
| pandas | Latest | Dataframe operations |
| numpy | Latest | Conditional column creation |
| SQLAlchemy | Latest | MySQL connection from Python |
| MySQL | 8.0 | Schema design and SQL analysis |
| Power BI Desktop | Latest | Dashboard and DAX measures |
| Git / GitHub | — | Version control |

---

## Pipeline Architecture

Raw CSV (10,324 rows)
↓
Python EDA & Cleaning
(01_eda_cleaning.ipynb)
↓
Cleaned CSV (39 columns)
↓
MySQL Load via Python
(02_load_to_mysql.py)
↓
SQL Analysis (20 queries)
(03_analysis.sql)
↓
MySQL Views Created
(vw_delivery_performance
vw_vendor_country_analysis)
↓
Python Export Script
(03_export_for_powerbi.py)
↓
Power BI Dashboard
(4 pages, 25+ DAX measures)


---

## Phase 1 — Python EDA & Data Cleaning

### Data Quality Issues Resolved (9 Issues)

| Issue | Column | Problem | Resolution |
|---|---|---|---|
| 001 | Freight Cost (USD) | Mixed numeric and text values | Freight_Type flag + numeric conversion |
| 002 | Shipment Mode | 360 nulls (3.49%) | Filled with Unknown — correlated with absorbed freight |
| 003 | Dosage | 1,736 nulls (16.8%) | Dosage_Applicable flag — structural gap for HRDT/MRDT |
| 004 | Line Item Insurance | 287 nulls (2.78%) | Filled with 0 — zero is valid value |
| 005 | Date columns (3) | Wrong format string | Converted with correct format "%d-%b-%y" |
| 006 | Freight Cost | Mixed types | Absorbed vs Separate freight flag created |
| 007 | Weight (Kilograms) | Mixed types | Weight_Type flag + numeric conversion |
| 008 | CSV encoding | UnicodeDecodeError | latin1 encoding applied on load |
| 009 | PQ/PO date columns | Placeholder text + different format | Separate conversion with "%m/%d/%Y" |

### Feature Engineering (3 New Columns)

| Feature | Formula | Business Purpose |
|---|---|---|
| Delivery_Delay_Days | Delivered Date − Scheduled Date | Days early or late per shipment |
| On_Time_Delivery | Delay ≤ 2 days → On Time | Binary KPI with 2-day tolerance |
| Delivery_Status | Early / On Time / Late | Three-way delivery classification |

---

## Phase 2 — SQL Analysis (20 Queries)

### SQL Concepts Demonstrated

- Single, chained, and recursive CTEs
- Window functions: RANK, DENSE_RANK, NTILE, LAG, SUM OVER
- PARTITION BY for independent group calculations
- Correlated and independent subqueries
- Stored procedure with input parameters
- Composite risk scoring with weighted metrics
- LEFT JOIN between CTEs for bias-free analysis
- Running totals with ROWS BETWEEN UNBOUNDED PRECEDING
- Views for Power BI connectivity

### Query Summary

| Query | Business Question | Key Concept |
|---|---|---|
| Q1 | On-time rate by shipment mode | GROUP BY, CASE |
| Q2 | Vendor late shipment ranking | CTE, DENSE_RANK |
| Q3 | Country delay analysis | CTE, AVG, window function |
| Q4 | Freight cost by shipment mode | Filtered aggregation |
| Q5 | Vendor comprehensive scorecard | Chained CTEs, NTILE |
| Q6 | Vendor performance by country | PARTITION BY |
| Q7 | Vendor trend over time | LAG, PARTITION BY |
| Q8 | Above average delay vendors | Correlated subquery |
| Q9 | Product group performance | Multi-metric aggregation |
| Q10 | Country composite risk score | Weighted scoring, LEFT JOIN CTEs |
| Q11 | Country procurement YoY trend | LAG, NULLIF |
| Q12 | Monthly volume + running total | SUM OVER, ROWS BETWEEN |
| Q13 | Quarterly on-time trend | QUARTER(), LAG |
| Q14 | Annual late rate YoY change | YEAR(), CASE classification |
| Q15 | Vendor NTILE segmentation | NTILE(4), CASE |
| Q16 | Classification hierarchy | Recursive CTE, UNION ALL |
| Q17 | Vendor performance report | Stored Procedure |
| Q18 | Executive KPI dashboard | Subqueries in SELECT |
| Q19 | Power BI delivery view | CREATE VIEW |
| Q20 | Power BI vendor/country view | CREATE VIEW |

---

## Phase 3 — Power BI Dashboard (4 Pages)

### DAX Measures Created (25+)

**Page 1 — Executive Summary:**
Total Shipments, On Time Rate %, Late Rate %,
Avg Delay Days, Total Procurement Value, Total Vendors

**Page 2 — Country Risk Analysis:**
Early Rate %, Late Shipments Count, Best Country,
Worst Country, Best Country Late Rate %,
Worst Country Late Rate %, Countries Above 10% Late Rate

**Page 3 — Vendor Performance:**
Best Vendor, Worst Vendor, Best Vendor Late Rate %,
Worst Vendor Late Rate %, High Risk Vendors Count,
Reliable Vendors Count

**Page 4 — Freight Analysis:**
Total Freight Cost, Absorbed Freight %,
Most Expensive Mode, Most Cost Efficient Mode,
Avg Freight Cost Ratio by Mode

### Dashboard Pages

**Page 1 — Executive Summary**
6 KPI cards, on-time rate by shipment mode bar chart,
delivery status donut chart, top 5 worst vendors table,
top 5 worst countries bar chart, year slicer

**Page 2 — Country Risk Analysis**
World map showing late rate by country,
4 country KPI cards, quarterly on-time trend line chart,
average delay days by country bar chart, country slicer

**Page 3 — Vendor Performance Analysis**
6 vendor KPI cards, SCMS from RDC year over year
trend line chart with crisis annotations,
top 5 worst vendors, top 5 best vendors,
all vendor distribution chart, vendor slicer

**Page 4 — Freight & Operations Analysis**
4 freight KPI cards, freight cost ratio by mode bar chart,
average freight cost by mode bar chart,
freight type distribution donut chart,
product group scatter chart (on-time vs cost),
shipment mode slicer

---

## Key Business Findings

### Executive Summary
- **Overall on-time delivery rate: 89.52%**
- **Total programme procurement value: $1.587 billion**
- **Total freight cost: $67.4 million (4.25% of goods value)**
- **Programme coverage: 43 countries, 72 vendors, 2006-2015**

### Vendor Risk
- **Highest risk vendor: SCMS from RDC**
  - 16.22% late rate on 5,404 shipments
  - Handles 52% of all programme shipments
  - Late rate deteriorated from 1.41% (2007) to 34.10% (2011)
  - False recovery in 2012 (9%) followed by relapse to 32.21% (2014)
  - Worst vendor in 17+ countries simultaneously

- **Most reliable vendor: Bristol-Myers Squibb**
  - 0% late rate across all shipments
  - Benchmark for vendor performance standards

### Country Risk
- **Highest risk country: Burundi**
  - 28.57% late rate — nearly 1 in 3 shipments late
- **Most delayed country: Congo DRC**
  - Only country with positive average delay (+11.24 days)
  - 24.92% late rate, maximum delay of 165 days
- **Most reliable country: Vietnam**
  - 0.87% late rate across 688 shipments

### Delivery Crisis
- **2010-2011 programme crisis identified:**
  - Q4 2010: On-time rate collapsed 18.43 percentage points
    in a single quarter
  - Q2 2011: Programme hit all-time low of 62% on-time rate
  - Single vendor (SCMS from RDC) caused programme-wide failure
  - Programme never fully recovered to pre-2010 baseline

### Freight Efficiency
- **Air freight paradox:** Most used mode (61% of shipments)
  but worst cost efficiency (8.48% freight ratio)
- **Most cost efficient: Truck (3.22%)**
- **39.9% of shipments have absorbed freight** —
  procurement transparency concern
- **ARV medicines:** Largest volume (83%) but lowest
  on-time rate (87.71%) — highest clinical risk

### Product Risk
- **ARV medicines** are the only product group below
  the 90% on-time threshold despite being 83% of volume
- **ANTM antimalarials:** 100% on-time but 61.94%
  freight cost ratio — extreme cost inefficiency

---

## How to Run This Project

### Prerequisites
- Python 3.13+
- MySQL 8.0+
- Power BI Desktop
- Required Python packages (see below)

### Installation

```bash
git clone https://github.com/MANOHAR2004/supply-chain-performance-analytics_2.git
cd supply-chain-performance-analytics_2

pip install pandas numpy matplotlib seaborn sqlalchemy 
pymysql mysql-connector-python jupyterlab
```

### Setup MySQL Database

```sql
CREATE DATABASE supply_chain_db;
USE supply_chain_db;
```

Run scripts in this order:

sql/01_schema.sql
sql/02_cleaning.sql


### Run Phase 1 — Python Cleaning

```bash
cd python_code
jupyter lab
```

Open `01_eda_cleaning.ipynb` → Kernel → Restart and Run All

### Run Phase 2 — Load to MySQL

```bash
python 02_load_to_mysql.py
```

Then run in MySQL Workbench:

sql/03_analysis.sql
sql/04_views.sql


### Run Phase 3 — Export for Power BI

```bash
python 03_export_for_powerbi.py
```

Open `powerbi/dashboard.pbix` in Power BI Desktop.
Update the data source path to your local `data/processed/` folder.
Click Refresh.

---

## Project Documentation

| Document | Location | Purpose |
|---|---|---|
| Issue Log | docs/issue_log.md | All 9 data quality issues with decisions |
| Business Questions | docs/business_questions.md | 20 analytical questions with findings |
| Progress Tracker | docs/progress_tracker.md | Project status and decisions log |

---

## Resume Description

**Supply Chain Performance & Risk Analytics**
Python · MySQL · Power BI · DAX

- Analysed 10,324 real USAID procurement shipment records 
  spanning 43 countries and 72 vendors to identify delivery 
  performance gaps and freight cost inefficiencies across 
  global health commodity supply chains
- Built end-to-end Python data pipeline — resolved 9 data 
  quality issues including mixed-type columns, structural nulls, 
  and encoding errors — engineering 3 KPI columns from raw dates
- Wrote 20 advanced SQL queries using CTEs, window functions 
  (LAG, NTILE, PARTITION BY), correlated subqueries, stored 
  procedures, and composite risk scoring to identify SCMS from 
  RDC as highest-risk vendor (16.22% late rate, 5,404 shipments)
- Built 4-page interactive Power BI dashboard with 25+ DAX 
  measures revealing 2010-2011 delivery crisis where on-time 
  rate collapsed from 98% to 62% — traced to a single vendor 
  causing programme-wide failure across 17 countries

---

## Author

**Manohar Choudhary**
MBA (Marketing) — IMS DAVV Indore
Data Analyst | Python · SQL · Power BI

[GitHub](https://github.com/MANOHAR2004)

---

*Project completed August 2026*
