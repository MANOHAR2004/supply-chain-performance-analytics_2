# Supply Chain Performance & Risk Analytics

![Python](https://img.shields.io/badge/Python-3.13-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow)
![Status](https://img.shields.io/badge/Status-In%20Progress-green)

## Project Overview

An end-to-end supply chain analytics project analysing 10,324 real 
USAID procurement shipment records to identify delivery performance 
gaps, freight cost inefficiencies, and vendor reliability patterns 
across global health commodity supply chains.

This project demonstrates a complete data analytics pipeline — from 
raw data ingestion and cleaning in Python, through deep SQL analysis, 
to an interactive Power BI dashboard with DAX measures.

---

## Business Problem

A supply chain director needs answers to four critical questions:

- Which vendors are consistently delivering late and by how much?
- What percentage of shipments are on time across different shipment modes?
- Where is freight cost disproportionately high relative to line item value?
- Which countries and routes carry the highest delivery risk?

---

## Dataset

**Source:** USAID Supply Chain Management System (SCMS) 
Delivery History Dataset — publicly available procurement data 
from global health commodity shipments.

**Size:** 10,324 rows × 33 original columns (38 after feature engineering)

**Domain:** Pharmaceutical supply chain — ARV medicines, 
diagnostic test kits (HRDT/MRDT), antimalarials (ANTM/ACT)

**Coverage:** Multiple countries, vendors, shipment modes 
(Air, Truck, Air Charter, Ocean), and product categories

---

## Project Structure
supply-chain-performance-analytics/
│
├── data/
│ ├── raw_data/ # Original unmodified dataset
│ └── processed/ # Cleaned data output
│ └── scms_cleaned.csv
│
├── python_code/
│ └── 01_eda_cleaning.ipynb # Phase 1 — EDA & cleaning notebook
│
├── sql/ # Phase 2 — SQL analysis scripts (coming)
│ ├── 01_schema.sql
│ ├── 02_cleaning.sql
│ ├── 03_analysis.sql
│ └── 04_views.sql
│
├── scraping/ # Phase 3 — Web scraping scripts (coming)
│
├── powerbi/ # Phase 4 — Dashboard file (coming)
│ └── dashboard.pbix
│
├── docs/
│ └── issue_log.md # Live data quality issue tracker
│
└── README.md
![Project structure](<img width="782" height="675" alt="image" src="https://github.com/user-attachments/assets/67c72136-e41b-4d0d-ba27-f7c202262315" />
)
---

## Tech Stack

| Tool | Purpose |
|---|---|
| Python 3.13 | EDA, data cleaning, feature engineering |
| pandas | DataFrame operations and transformation |
| numpy | Conditional column creation |
| matplotlib / seaborn | Exploratory visualisation |
| MySQL 8.0 | Schema design and analytical queries |
| Power BI | Interactive dashboard and DAX measures |
| Git / GitHub | Version control and portfolio hosting |

---

## Phase 1 — EDA & Data Cleaning ✓ Complete

### Data Quality Issues Resolved

| Issue | Column | Problem | Resolution |
|---|---|---|---|
| 001 | Freight Cost (USD) | Mixed types — numeric + text | Freight_Type flag + numeric conversion |
| 002 | Shipment Mode | 360 nulls (3.49%) | Filled with "Unknown" — correlated with absorbed freight |
| 003 | Dosage | 1736 nulls (16.8%) | Dosage_Applicable flag — structural gap for HRDT/MRDT |
| 004 | Line Item Insurance | 287 nulls (2.78%) | Filled with 0 — zero is valid value |
| 005 | Date columns (3) | Wrong format string | Converted with correct format "%d-%b-%y" |
| 006 | Freight Cost | Mixed types | Absorbed vs Separate freight flag created |
| 007 | Weight (Kilograms) | Mixed types — numeric + text | Weight_Type flag + numeric conversion |
| 008 | CSV encoding | UnicodeDecodeError | latin1 encoding applied on load |
| 009 | PQ/PO date columns | Placeholder text + different format | Separate conversion with "%m/%d/%Y" |

### Feature Engineering

| Feature | Formula | Business Purpose |
|---|---|---|
| Delivery_Delay_Days | Delivered Date − Scheduled Date | Days early or late per shipment |
| On_Time_Delivery | Delay <= 2 days | Binary on-time KPI with 2-day tolerance |
| Delivery_Status | Early / On Time / Late | Three-way delivery performance classification |

### Key Findings from Phase 1

- **89.9%** overall on-time delivery rate (9,278 of 10,324 shipments)
- **27.3%** of shipments delivered early — potential over-expediting cost issue
- **10.1%** late deliveries — 1,046 shipments requiring vendor investigation
- **39.9%** of shipments (4,126 rows) have freight absorbed into commodity cost
- **Dosage nulls are structural** — HRDT and MRDT diagnostic kits have no applicable dosage
- **Shipment Mode nulls correlate 100%** with absorbed freight rows

---

## Phase 2 — SQL Analysis 🔄 In Progress

35+ analytical queries covering:
- Vendor performance ranking using window functions
- On-time delivery rate by shipment mode and country using CTEs
- Freight cost efficiency analysis by route and carrier
- Delay pattern analysis using LAG/LEAD
- Top vs bottom supplier identification using DENSE_RANK

---

## Phase 3 — Web Scraping 📋 Planned

Python web scraping using requests and BeautifulSoup to enrich 
dataset with external commodity price and shipping rate data 
from public sources.

---

## Phase 4 — Power BI Dashboard 📋 Planned

Interactive dashboard with 20+ DAX measures covering:
- Supplier KPI scorecards
- Freight cost analysis by mode and route
- Delivery performance trends over time
- Country-level risk heatmap

---

## Key Business KPIs (Preview)

| KPI | Value |
|---|---|
| Overall On-Time Delivery Rate | 89.9% |
| Late Shipment Rate | 10.1% |
| Early Shipment Rate | 27.3% |
| Absorbed Freight Percentage | 39.9% |
| Total Shipments Analysed | 10,324 |
| Countries Covered | Multiple |
| Vendors Tracked | Multiple |

---

## How to Run This Project

**Prerequisites:**
- Python 3.13+
- Jupyter Lab
- pandas, numpy, matplotlib, seaborn, mysql-connector-python

**Setup:**
```bash
git clone https://github.com/MANOHAR2004/supply-chain-performance-analytics_2.git
cd supply-chain-performance-analytics_2
pip install pandas numpy matplotlib seaborn mysql-connector-python jupyterlab
```

**Run Phase 1:**
```bash
cd python_code
jupyter lab
# Open 01_eda_cleaning.ipynb
# Kernel → Restart and Run All
```

---

## Author

**Manohar Choudhary**
MBA (Marketing) — IMS DAVV Indore
Aspiring Data Analyst | Python · SQL · Power BI

[GitHub](https://github.com/MANOHAR2004) | 
[LinkedIn](www.linkedin.com/in/manohar-choudhary)

---

*Project Status: Phase 1 Complete — Phase 2 In Progress*

