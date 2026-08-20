# Project Progress Tracker
## Supply Chain Performance & Risk Analytics

**Analyst:** Manohar Choudhary
**Project Start:** June 2026
**Project Complete:** August 2026
**GitHub:** github.com/MANOHAR2004/supply-chain-performance-analytics_2

---

## Overall Project Status: ✅ COMPLETE

| Phase | Description | Status | Completion |
|---|---|---|---|
| Phase 1 | Python EDA & Cleaning | ✅ Complete | June 2026 |
| Phase 2 | SQL Analysis | ✅ Complete | July 2026 |
| Phase 3 | Power BI Dashboard | ✅ Complete | August 2026 |
| Phase 4 | Web Scraping Enhancement | 📋 Planned | Pending |
| Phase 5 | GitHub & LinkedIn Publication | 🔄 In Progress | August 2026 |

---

## Dataset Information

| Property | Value |
|---|---|
| Source | USAID SCMS Delivery History Dataset |
| Raw rows | 10,324 |
| Raw columns | 33 |
| Final columns | 39 (after feature engineering) |
| Date range | 2006 — 2015 |
| Countries | 43 |
| Vendors | 72 |
| Product groups | 5 (ARV, HRDT, ANTM, ACT, MRDT) |
| Shipment modes | 4 (Air, Truck, Air Charter, Ocean) |
| File location | data/raw_data/SCMS_Delivery_History_Dataset_20150929.csv |
| Encoding | latin1 |

---

## Phase 1 — Python EDA & Data Cleaning ✅ Complete

### Files
- Notebook: `python_code/01_eda_cleaning.ipynb`
- Output: `data/processed/scms_cleaned.csv`

### Data Quality Issues Resolved

| Issue | Column | Problem | Fix | Status |
|---|---|---|---|---|
| 001 | Freight Cost (USD) | Stored as object — mixed types | Superseded by Issue 006 | Resolved |
| 002 | Shipment Mode | 360 nulls (3.49%) | Filled with Unknown | Resolved |
| 003 | Dosage | 1,736 nulls (16.8%) | Dosage_Applicable flag created | Resolved |
| 004 | Line Item Insurance | 287 nulls (2.78%) | Filled with 0 | Resolved |
| 005 | Date columns (3) | Wrong format — all NaT | Converted with "%d-%b-%y" | Resolved |
| 006 | Freight Cost (USD) | Mixed numeric and text | Freight_Type flag + pd.to_numeric | Resolved |
| 007 | Weight (Kilograms) | Mixed numeric and text | Weight_Type flag + pd.to_numeric | Resolved |
| 008 | CSV file | UnicodeDecodeError on load | encoding="latin1" in read_csv | Resolved |
| 009 | PQ/PO date columns | Placeholder text + different format | Separate conversion "%m/%d/%Y" | Resolved |

### Feature Engineering

| Feature | Formula | Values | Business Purpose |
|---|---|---|---|
| Delivery_Delay_Days | Delivered Date − Scheduled Date | Integer days | Core delivery KPI |
| On_Time_Delivery | Delay ≤ 2 days | On Time / Late | Binary performance flag |
| Delivery_Status | Three-way classification | Early / On Time / Late | Granular performance |
| Freight_Type | Text detection in Freight Cost | Absorbed / Separate | Cost analysis flag |
| Weight_Type | Text detection in Weight | Recorded / Captured Separately | Weight analysis flag |
| Dosage_Applicable | Product Group check | Applicable / Not Applicable | HRDT/MRDT exclusion flag |

### Key Decisions Made in Phase 1

- On-time tolerance window: 0 to +2 days (not strictly 0)
- Dosage nulls retained as NaN — structural gap, not data error
- HRDT and MRDT have no applicable dosage — flag created
- PQ First Sent and PO Sent dates kept as VARCHAR — contain
  placeholder text "Pre-PQ Process" and "Date Not Captured"
- Absorbed freight rows retained — excluded only from cost
  analysis, included in delivery performance analysis
- CSV exported with utf-8 encoding for Power BI compatibility

---

## Phase 2 — SQL Analysis ✅ Complete

### Database Details

| Property | Value |
|---|---|
| Database | supply_chain_db |
| Table | scms_shipments |
| Rows loaded | 10,324 |
| Columns | 39 |
| Primary Key | ID (INT) |
| Views created | 2 |
| Stored procedures | 1 |

### Files

- Schema: `sql/01_schema.sql`
- Cleaning: `sql/02_cleaning.sql`
- Analysis: `sql/03_analysis.sql`
- Views: `sql/04_views.sql`
- Load script: `python_code/02_load_to_mysql.py`

### Views Created

| View | Rows | Purpose |
|---|---|---|
| vw_delivery_performance | 9,964 | Power BI delivery pages |
| vw_vendor_country_analysis | 9,964 | Power BI vendor/country pages |

Note: Both views exclude Unknown Shipment Mode (360 rows removed)

### Stored Procedure

```sql
CALL GetVendorReport('vendor_name');
```

Returns 4 result sets: overall scorecard, freight distribution,
year by year trend, country breakdown for any vendor.

### SQL Concepts Used

| Concept | Query |
|---|---|
| CTE (single) | Q1, Q2, Q3, Q4 |
| Chained CTEs | Q5, Q10 |
| Recursive CTE | Q16 |
| RANK / DENSE_RANK | Q2, Q5 |
| NTILE | Q5, Q15 |
| LAG | Q7, Q11, Q12, Q13, Q14 |
| PARTITION BY | Q6, Q7 |
| SUM OVER running total | Q12 |
| Correlated subquery | Q8 |
| Subquery in SELECT | Q18 |
| LEFT JOIN between CTEs | Q10 |
| Stored Procedure | Q17 |
| CREATE VIEW | Q19, Q20 |
| Composite risk scoring | Q10 |
| NULLIF | Q11, Q14 |
| YEAR / QUARTER / MONTH | Q12, Q13, Q14 |

### Complete Query List

| Query | Business Question | Finding |
|---|---|---|
| Q1 | On-time rate by shipment mode | Air best 91.87%, Ocean worst 82.75% |
| Q2 | Vendor late shipment ranking | SCMS from RDC rank 1 at 16.22% |
| Q3 | Country delay analysis | Congo DRC only positive avg delay +11.24 |
| Q4 | Freight cost by mode | Air worst ratio 8.48%, Truck best 3.22% |
| Q5 | Vendor comprehensive scorecard | 6 High Risk, 5 Reliable vendors |
| Q6 | Vendor performance by country | SCMS worst vendor in 17+ countries |
| Q7 | Vendor trend with LAG | SCMS crisis 2010-2011, false recovery 2012 |
| Q8 | Above average delay vendors | CIPLA +4.78 days, Aurobindo +4.41 days |
| Q9 | Product group performance | ARV only group below 90% on-time |
| Q10 | Country composite risk score | Congo DRC rank 1, South Africa rank 22 |
| Q11 | Country procurement YoY | Nigeria strongest growth, SA collapsed 94% post-2011 |
| Q12 | Monthly volume + running total | $1.627B cumulative, Aug 2014 spike |
| Q13 | Quarterly on-time trend | Q2 2011 worst at 62%, +22.47pp recovery Q3 2011 |
| Q14 | Annual late rate YoY | 5 deteriorating years, 4 improving years |
| Q15 | NTILE vendor segmentation | 4 tiers: High/Medium/Low Risk/Reliable |
| Q16 | Classification hierarchy | ARV 82.82%, Adult ARV 63.88% of all shipments |
| Q17 | Stored procedure | GetVendorReport — 4 result sets per vendor |
| Q18 | Executive KPI dashboard | Single row all programme KPIs |
| Q19 | Power BI delivery view | 9,964 rows, 18 columns |
| Q20 | Power BI vendor/country view | 9,964 rows, 17 columns |

---

## Phase 3 — Power BI Dashboard ✅ Complete

### Files

- Dashboard: `powerbi/dashboard.pbix`
- Export script: `python_code/03_export_for_powerbi.py`
- Data sources: `data/processed/vw_delivery_performance.csv`
  and `data/processed/vw_vendor_country_analysis.csv`

### Connection Method

Python SQLAlchemy → MySQL views → CSV export →
Power BI CSV import (Import mode)

### DAX Measures (25+ total)

**Page 1 — Executive Summary:**

| Measure | Formula Approach | Value |
|---|---|---|
| Total Shipments | COUNTROWS | 9,964 |
| On Time Rate % | CALCULATE + DIVIDE | 89.52% |
| Late Rate % | CALCULATE + DIVIDE | 10.48% |
| Avg Delay Days | AVERAGE | -6.15 |
| Total Procurement Value | SUM | $1.587B |
| Total Vendors | DISTINCTCOUNT | 72 |

**Page 2 — Country Risk Analysis:**

| Measure | Formula Approach | Value |
|---|---|---|
| Early Rate % | CALCULATE + DIVIDE | 27.97% |
| Late Shipments Count | CALCULATE + COUNTROWS | 1,044 |
| Best Country | VAR + ADDCOLUMNS + TOPN | Vietnam |
| Worst Country | VAR + ADDCOLUMNS + TOPN | Burundi |
| Best Country Late Rate % | MINX + FILTER + SUMMARIZE | 0.87% |
| Worst Country Late Rate % | MAXX + FILTER + SUMMARIZE | 28.57% |
| Countries Above 10% Late Rate | COUNTROWS + FILTER + SUMMARIZE | 8 |
| Year-Quarter | Calculated column | 2006 Q1 format |
| Year-Quarter Sort | Calculated column | Numeric sort key |

**Page 3 — Vendor Performance:**

| Measure | Formula Approach | Value |
|---|---|---|
| Best Vendor | VAR + ADDCOLUMNS + TOPN | Bristol-Myers Squibb |
| Worst Vendor | VAR + ADDCOLUMNS + TOPN | SCMS from RDC |
| Best Vendor Late Rate % | MINX + FILTER + SUMMARIZE | 0.00% |
| Worst Vendor Late Rate % | MAXX + FILTER + SUMMARIZE | 16.22% |
| High Risk Vendors Count | VAR + FILTER (LateRate > 4%) | 6 |
| Reliable Vendors Count | VAR + FILTER (LateRate ≤ 0.5%) | 5 |

**Page 4 — Freight Analysis:**

| Measure | Formula Approach | Value |
|---|---|---|
| Total Freight Cost | CALCULATE + SUM (Separate only) | $67.4M |
| Absorbed Freight % | CALCULATE + DIVIDE | 39.9% |
| Most Expensive Mode | VAR + ADDCOLUMNS + TOPN DESC | Air Charter |
| Most Cost Efficient Mode | VAR + ADDCOLUMNS + TOPN ASC | Truck |
| Avg Freight Cost Ratio by Mode | DIVIDE SUM/SUM (Separate only) | Context dependent |

### Dashboard Pages

**Page 1 — Executive Summary**
- 6 KPI cards: Total Shipments, On Time Rate %, Late Rate %,
  Avg Delay Days, Total Procurement Value, Total Vendors
- Bar chart: On-time rate by shipment mode
- Donut chart: Delivery status distribution
- Table: Top 5 worst vendors by late rate
- Bar chart: Top 5 worst countries by late rate
- Slicer: Year dropdown

**Page 2 — Country Risk Analysis**
- Map visual: Late rate by country (colour intensity)
- 4 KPI cards: Best Country, Best Country Late Rate %,
  Worst Country, Worst Country Late Rate %
- Line chart: Quarterly on-time rate trend 2006-2015
- Bar chart: Average delay days by country (top 10)
- Slicer: Country dropdown

**Page 3 — Vendor Performance Analysis**
- 6 KPI cards: Best Vendor, Best Vendor Late Rate %,
  Reliable Vendors Count, Worst Vendor,
  Worst Vendor Late Rate %, High Risk Vendors Count
- Line chart: Vendor late rate trend 2007-2015 (hero visual)
  with reference lines at 10% and 34.10%
- Bar chart: Top 5 worst vendors by late rate
- Bar chart: Top 5 best vendors by late rate
- Bar chart: All vendor late rate distribution
- Slicer: Vendor dropdown

**Page 4 — Freight & Operations Analysis**
- 4 KPI cards: Total Freight Cost, Absorbed Freight %,
  Most Expensive Mode, Most Cost Efficient Mode
- Bar chart: Freight cost ratio by shipment mode (hero visual)
- Bar chart: Average freight cost by shipment mode
- Donut chart: Freight type distribution (Separate vs Absorbed)
- Scatter chart: Product group — on-time rate vs freight cost ratio
- Slicer: Shipment Mode dropdown

---

## Key Decisions Made Across Project

| Decision | Rationale |
|---|---|
| On-time tolerance: 0 to +2 days | Last-mile variability allowance |
| Min shipments for country analysis: 50 | Statistical significance |
| Min shipments for vendor analysis: 30 | Statistical significance |
| Delivery metrics: ALL shipments | No freight filter — avoids selection bias |
| Cost metrics: Separate freight only | Absorbed freight has no recorded cost |
| Composite risk weights: 50/30/20 | Late rate most impactful for business |
| Separate delivery/cost CTE filters | South Africa case proved single filter biases results |
| Power BI: CSV not direct MySQL | Connector issues — Python export script used instead |
| VAR pattern for complex DAX | Readable, debuggable, senior-level approach |
| SUM/SUM for freight ratio | Mathematically correct vs AVERAGE of ratios |

---

## Critical Findings Summary

### Programme Level
- Overall on-time rate: **89.52%**
- Total procurement value: **$1.587 billion**
- Total freight cost: **$67.4 million (4.25%)**
- Programme coverage: **43 countries, 72 vendors**

### Vendor Risk
- SCMS from RDC: **16.22% late rate, 5,404 shipments**
  - Worst vendor in 17+ countries simultaneously
  - Crisis: 1.41% (2007) → 34.10% (2011) → false recovery
  - Never sustained improvement after 2012 recovery
- Bristol-Myers Squibb: **0% late rate** — benchmark vendor

### Country Risk
- Burundi: **28.57% late rate** — worst by late rate
- Congo DRC: **+11.24 days average delay** — only positive
- Vietnam: **0.87% late rate** — most reliable corridor
- South Africa: **Rank 22/22** — best performing large country

### Delivery Crisis
- **Q4 2010:** -18.43pp single quarter collapse
- **Q2 2011:** 62.00% — programme all-time low
- **Q3 2011:** +22.47pp recovery — largest single quarter jump
- **Root cause:** SCMS from RDC 34.10% late rate in 2011
- **Status:** Never recovered to pre-2010 baseline (0-2%)

### Freight Efficiency
- Air freight: **61% of shipments, 8.48% cost ratio** (worst)
- Truck: **3.22% cost ratio** (most efficient)
- Absorbed freight: **39.9%** — transparency concern
- ARV medicines: **83% of volume, 87.71% on-time** (below target)

---

### Phase 4 — Web Scraping (Planned)
- [ ] Learn requests and BeautifulSoup
- [ ] Scrape commodity price data from public sources
- [ ] Enrich supply chain dataset with external pricing
- [ ] Store scraped data in MySQL
- [ ] Add scraping findings to Power BI dashboard


## Git Commit History Summary

| Commit | Description |
|---|---|
| Initial | Project structure created |
| Phase 1 | EDA and cleaning notebook complete |
| Phase 2 | MySQL schema and data load |
| Phase 2 | SQL analysis Q1-Q10 |
| Phase 2 | SQL analysis Q11-Q20 |
| Phase 2 | Views and stored procedure |
| Phase 3 | Power BI export script |
| Phase 3 | Dashboard Pages 1-2 |
| Phase 3 | Dashboard Pages 3-4 |
| Final | README updated, project complete |


---

*Last updated: August 2026*
*Project status: Complete — Phase 4 web scraping pending*