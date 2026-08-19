# Business Questions & Analysis Specification
## Supply Chain Performance & Risk Analytics
**Project:** USAID SCMS Delivery History Analysis  
**Analyst:** Manohar Choudhary  
**Dataset:** 10,324 shipment records | 2006–2015  
**Last Updated:** July 2026

---

## How to Read This Document

Each business question follows this structure:
- **BQ (Business Question):** What the stakeholder wants to know
- **Why It Matters:** Business impact of this insight
- **Data Used:** Which columns answer this question
- **SQL File:** Reference to the query in 03_analysis.sql
- **Key Finding:** What the data actually showed
- **Recommendation:** What action should be taken

---

## Business Area 1 — Delivery Performance

### BQ-01 — On-Time Delivery Rate by Shipment Mode
**Business Question:**
Which shipment mode delivers on time most consistently?

**Why It Matters:**
Shipment mode is a controllable procurement decision.
If one mode consistently underperforms, procurement teams
can shift volume to better-performing modes and reduce
delivery risk without increasing cost.

**Data Used:**
Shipment_Mode, On_Time_Delivery, Delivery_Delay_Days

**SQL Reference:** 03_analysis.sql — Query 1

**Key Finding:**
- Air: 91.87% on-time (best performer, 6,113 shipments)
- Air Charter: 90.00% on-time (650 shipments)
- Truck: 85.23% on-time (418 late shipments in absolute terms)
- Ocean: 82.75% on-time (worst performer)

**Recommendation:**
Ocean and Truck modes underperform Air by 7-9 percentage
points. Review carrier contracts for Ocean and Truck routes.
For non-urgent shipments currently using Air, evaluate
Truck as a cost-efficient alternative given its 85% rate.

---

### BQ-02 — Vendor Late Shipment Ranking
**Business Question:**
Which vendors have the worst on-time delivery performance
and should be flagged for contract review?

**Why It Matters:**
Vendor reliability directly impacts patient access to
medicines in USAID-funded programmes. A vendor with
consistent late deliveries creates downstream health risks
beyond just operational inefficiency.

**Data Used:**
Vendor, On_Time_Delivery, Delivery_Delay_Days

**Data Note:** SCMS from RDC total shipments = 5,404 overall.
Query 2 reported 5,092 due to WHERE Shipment_Mode != 'Unknown'
filter excluding 312 SCMS rows with unrecorded shipment mode.
Dashboard uses unfiltered 16.22% late rate as complete picture.
SQL Query 2 filtered rate (15.30%) represents mode-specific analysis only.

**SQL Reference:** 03_analysis.sql — Query 2

**Key Finding:**
- SCMS from RDC: 16.22% late rate (826 late from 5,092
  shipments — single largest risk vendor)
- BIO-RAD LABORATORIES: 14.29% late rate
- CIPLA LIMITED: 12.57% late rate
- Aurobindo Pharma: 12.13% late rate (high volume risk)

**Recommendation:**
SCMS from RDC handles 52% of all shipments with 16.2%
late rate — this requires immediate escalation. Recommend
performance improvement plan with penalty clauses for
vendors exceeding 10% late rate threshold.

---

### BQ-03 — Delivery Delay Analysis by Country
**Business Question:**
Which countries experience the longest average delivery
delays and highest late shipment rates?

**Why It Matters:**
Country-level delay patterns reveal infrastructure and
logistics corridor weaknesses that are outside vendor
control. These require different interventions — local
logistics partnerships, buffer stock policies, or
pre-positioning of inventory.

**Data Used:**
Country, Delivery_Delay_Days, On_Time_Delivery,
Delivery_Status

**SQL Reference:** 03_analysis.sql — Query 3

**Key Finding:**
- Congo DRC: Only country with positive average delay
  (+11.24 days), 24.92% late rate, max 165 day delay
- Burundi: Worst late rate at 28.57%
- South Africa: Most reliable large-volume country
  (-12.11 avg delay, 7.77% late rate, 13.98% of volume)
- Nigeria paradox: Largest volume (11.87%) with
  consistently early deliveries (-11.41 avg delay)

**Recommendation:**
Congo DRC and Burundi require country-specific
intervention — local pre-positioning of buffer stock
recommended. South Africa and Nigeria corridors should
be studied as best-practice models for other countries.

---

### BQ-04 — Freight Cost Efficiency by Shipment Mode
**Business Question:**
Which shipment mode is most cost-efficient relative to
the value of goods being shipped?

**Why It Matters:**
Freight cost as a percentage of line item value reveals
whether the cost of moving goods is proportionate to
their value. High ratios indicate potential for cost
optimisation by shifting to alternative modes.

**Data Used:**
Shipment_Mode, Freight_Cost_USD, Line_Item_Value,
Freight_Type

**SQL Reference:** 03_analysis.sql — Query 4

**Key Finding:**
- Air: 8.48% ratio — WORST cost efficiency despite being
  dominant mode (4,115 shipments)
- Air Charter: 5.00% ratio — ships highest value goods
  ($421K avg) justifying premium cost
- Ocean: 3.40% ratio — most cost-efficient for value
- Truck: 3.22% ratio — most cost-efficient overall

**Counterintuitive Finding:**
Regular Air freight is least cost-efficient despite lower
absolute cost than Air Charter. Air Charter ships goods
4x more valuable, making its premium justified.

**Recommendation:**
For non-urgent Air shipments carrying lower-value goods,
evaluate Truck as alternative. Potential freight cost
reduction of 5.26 percentage points per shipment value.

---

### BQ-05 — Vendor Comprehensive Performance Scorecard
**Business Question:**
Which vendors are both expensive AND unreliable — and
which are best performers on both dimensions?

**Why It Matters:**
Single-dimension vendor ranking (only late rate OR only
cost) gives incomplete picture. A vendor can be cheap
but consistently late, or expensive but always on time.
Combined scorecard enables better procurement decisions.

**Data Used:**
Vendor, Freight_Cost_USD, Line_Item_Value,
On_Time_Delivery, Delivery_Delay_Days, Freight_Type

**SQL Reference:** 03_analysis.sql — Query 5

**Key Finding:**
- High Risk vendors (Tier 1): BIO-RAD (16% late, 15% freight ratio),
  SCMS from RDC (15.76% late — dominant vendor, highest volume risk)
- Cost outlier: Shanghai Kehua 32.54% freight ratio despite Medium Risk
  delivery performance — cost risk independent of delivery risk
- Reliable tier: Bristol-Myers Squibb, Merck Sharp & Dohme,
  Hoffmann-La Roche all at 0% late rate — procurement benchmarks

**Recommendation:**
Immediate contract review for SCMS from RDC — handles largest
shipment volume in High Risk tier. Separate cost audit for
Shanghai Kehua — freight cost ratio 4x the mode average.
Use Reliable tier vendors as benchmark for SLA standards.

---

## Business Area 2 — Vendor Analysis

### BQ-06 — Vendor Performance by Country
**Business Question:**
Does vendor performance vary significantly by country,
or do the same vendors underperform everywhere?

**SQL Reference:** 03_analysis.sql — Query 6
**Key Finding:**
SCMS from RDC is worst vendor in 17+ countries simultaneously.
Country-specific risks:
- Burundi: SCMS 38.89% late (worst combination)
- Congo DRC: SCMS 38.03% late (+17.46 avg delay)
- South Africa: CIPLA 36.07% late despite strong country average
- Nigeria: Orgenics 27.94% late despite strong country average

**Recommendation:**
SCMS from RDC requires global contract review — not country
specific intervention. CIPLA and Orgenics need country-specific
performance improvement plans in South Africa and Nigeria
respectively where they are single-handedly dragging down
otherwise reliable corridors.

---

### BQ-07 — Vendor Performance Trend Over Time
**Business Question:**
Are underperforming vendors improving or deteriorating
over time?

**SQL Reference:** 03_analysis.sql — Query 7
**Key Finding BQ-07:**
SCMS from RDC shows cyclical deterioration pattern —
not random variation but structural performance failure:
- 2007-2009: Reliable (under 4% late)
- 2010-2011: Crisis (peaked 34.10% in 2011)
- 2012: False recovery (9.00%)
- 2013-2014: Relapse (back to 32.21%)
- 2015: Partial improvement (24.53%)

Aurobindo Pharma shows genuine improvement trajectory —
25.69% peak in 2011 to 0% by 2014. Benchmark for
vendor recovery management.

Orgenics shows high volatility with no trend —
37.50% to 1.27% to 18.98% — unpredictable risk.

**Recommendation:**
SCMS contract renewal decisions should never be based
on single-year performance. Rolling 3-year average
required to distinguish genuine improvement from
temporary recovery. Aurobindo model should be studied
for vendor performance improvement programme design.

---

### BQ-08 — Above Average Delay Vendors
**Business Question:**
Which vendors consistently deliver later than the
overall average delay across all vendors?

**SQL Reference:** 03_analysis.sql — Query 8
**Key Finding:**
Overall average delivery delay is -6.02 days across all vendors
meaning the fleet delivers early on average. Vendors above this
threshold are not necessarily late — they may simply be less early.

Genuine underperformers (positive avg delay + high late rate):
- CIPLA LIMITED: +4.78 avg delay, 12.57% late rate
- Aurobindo Pharma: +4.41 avg delay, 12.13% late rate
- Orgenics Ltd: +0.84 avg delay, 10.21% late rate

False positives in this analysis (above average delay but 0% late):
- Bristol-Myers Squibb: 0.00 avg delay, 0% late
- Pharmacy Direct: 0.00 avg delay, 0% late
These vendors deliver exactly on schedule — above the early-delivery
average but not actually underperforming.

**Recommendation:**
Combine this query with late percentage filter (>5%) to isolate
genuine underperformers from vendors who simply don't over-expedite FOR  this you can add (AND ROUND(
    SUM(CASE WHEN On_Time_Delivery = 'Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
    2
) > 5) this filter in having clause in query 8 for additional understanding about vendor perfomance.

---

## Business Area 3 — Product and Geography

### BQ-09 — Product Group Performance
**Business Question:**
Which product groups have the worst delivery performance
and highest freight cost burden?

**SQL Reference:** 03_analysis.sql — Query 9
**Key Finding:**
ARV medicines (largest group, 4,615 shipments) have worst
on-time delivery rate at 87.71% — 12.29% of critical
HIV medicines arrive late. This is the highest-risk
product category by volume and clinical importance.

HRDT diagnostic kits perform better on delivery (94.46%)
but carry higher freight cost burden (8.94% vs ARV 5.15%).

ANTM antimalarials show extreme freight cost inefficiency
at 61.94% ratio — though small volume (19 shipments)
limits statistical significance.

**Recommendation:**
Prioritise ARV supply chain intervention given clinical
criticality. Even 1% improvement in ARV on-time rate
represents 46 additional on-time deliveries of HIV medicines.
Investigate ANTM freight cost — 61.94% ratio suggests
either very small/lightweight shipments or wrong mode selection.

---

### BQ-10 — Country Risk Scorecard
**Business Question:**
Which countries present the highest combined supply
chain risk across delay, late rate, and freight cost?

**SQL Reference:** 03_analysis.sql — Query 10
**Key Finding:**
Methodology note: Delivery metrics (delay, late rate) calculated
on ALL shipments. Freight cost metrics on Separate freight only.
Using single filter for both metrics creates selection bias —
validated through South Africa case where Separate-only filter
changed rank from 22 to 2 incorrectly.

Final composite risk ranking:
1. Congo DRC — score 20.87 (only positive avg delay country)
2. Burundi — score 14.49 (highest late rate 28.57%)
3. South Sudan — score 13.22 (highest freight cost ratio 35.70%)
22. South Africa — score 0.82 (benchmark corridor)

**Recommendation:**
Always separate delivery performance filters from cost filters
in multi-metric analysis. Single filter applied to composite
metrics creates misleading country risk profiles.
Top 3 countries require different interventions:
- Congo DRC: Logistics corridor improvement
- Burundi: Vendor reliability (SCMS from RDC dominant)
- South Sudan: Mode optimisation to reduce freight ratio

---

### BQ-11 — Country Procurement Value and Trend
**Business Question:**
Which countries receive the most procurement value and
how has that changed year over year?

**SQL Reference:** 03_analysis.sql — Query 11
**Key Finding:**
Nigeria: Largest and most consistent procurement country.
$160K in 2006 to $64.7M in 2015 — strongest growth trajectory.

South Africa paradox: Best delivery performance but procurement
collapsed 94% after 2011 peak of $67.7M. Now receives minimal
value despite being most reliable corridor.

Mozambique 2014 anomaly: 177% spike ($59.7M) followed by
55.76% decline — likely emergency procurement event.

Tanzania and Kenya show signs of procurement relationship
termination in 2014-2015.

**Recommendation:**
Investigate South Africa procurement collapse — if driven by
budget reallocation rather than performance issues, redirecting
volume back to this reliable corridor could improve overall
on-time rates. Monitor Tanzania and Kenya for complete exit.

---

## Business Area 4 — Time and Trend Analysis

### BQ-12 — Monthly Shipment Volume Trend
**Business Question:**
How has shipment volume changed month over month and
what is the cumulative procurement value over time?

**SQL Reference:** 03_analysis.sql — Query 12
**Key Finding:**
Total programme procurement value: $1.627 billion (2006-2015)

Key anomalies:
- August 2014: 271 shipments — largest single month (171% MoM spike)
- Late 2015: Near-complete shutdown (1 shipment in October)
- 2006-2012: Strong growth phase scaling from 2 to 200 shipments/month
- No clear seasonal pattern — demand-driven procurement

**Recommendation:**
August 2014 spike warrants investigation — emergency procurement
or planned stockpiling? Late 2015 decline suggests programme
transition. Running total confirms $1.6B+ programme scale —
significant investment requiring robust vendor management.

---

### BQ-13 — Quarterly On-Time Rate Trend
**Business Question:**
Is overall delivery performance improving or deteriorating
quarter by quarter? Where were the biggest single-quarter
drops and recoveries in programme history?

**Why It Matters:**
Quarterly tracking reveals whether performance interventions
are working in near-real-time. Annual averages hide crisis
periods — a quarter with 62% on-time rate averaged with
three good quarters still looks acceptable annually.
Quarterly granularity catches problems before they compound.

**Data Used:**
Scheduled_Delivery_Date, On_Time_Delivery

**SQL Reference:** 03_analysis.sql — Query 13

**Key Finding:**
Three distinct performance phases identified:

Phase 1 — Golden Period (2007-2009):
Consistently 94-100% on-time rate. QoQ changes mostly
within ±5 percentage points. Stable, well-managed programme.

Phase 2 — Crisis (Q3 2010 to Q2 2011):
Q3 2010: -7.76pp — first warning signal
Q4 2010: -18.43pp — catastrophic single-quarter collapse
Q2 2011: 62.00% — absolute worst quarter in programme history
Total decline from peak: approximately 38 percentage points

Phase 3 — Recovery and Instability (2012-2015):
Q3 2011: +22.47pp — largest single-quarter improvement,
suggesting a specific operational intervention occurred
2012: Gradual stabilisation toward 90-97% range
2013-2014: High volatility, swinging 77% to 95% with no
consistent trend — programme never fully stabilised

Critical correlation: Q4 2010 collapse and Q2 2011 bottom
align exactly with SCMS from RDC's peak late rate of 34.10%
in 2011 (BQ-07). Single vendor caused programme-wide crisis.

**Recommendation:**
Implement quarterly on-time rate monitoring with 85% as
minimum acceptable threshold and automatic vendor review
trigger. Q4 2010's -18.43pp single-quarter drop should
have triggered immediate intervention — real-time quarterly
dashboarding would have caught this 6 months earlier.

Investigate Q3 2011 recovery (+22.47pp) — what specific
operational change caused the largest single-quarter
improvement? Replicating that intervention is valuable
institutional knowledge for future crisis management.

---
### BQ-14 — Year Over Year Late Rate Change
**Business Question:**
How has the annual late shipment rate changed year over
year and which years represent genuine deterioration vs
improvement vs stable performance?

**Why It Matters:**
Annual YoY classification cuts through noise to give
executives a simple signal — is the programme getting
better or worse this year? Single percentage point
threshold separates meaningful change from normal
variation.

**Data Used:**
Scheduled_Delivery_Date, On_Time_Delivery

**SQL Reference:** 03_analysis.sql — Query 14

**Key Finding:**
Programme performance timeline:

2006-2009: Low baseline late rate (0-2.55%)
2010-2011: Crisis — four consecutive Deteriorating years
  - 2010: +11.07pp single year jump (0% to 13.62%)
  - 2011: Peak at 21.76% — 4x the acceptable baseline
2012: Largest single year recovery (-14.85pp)
2013: Immediate relapse (+8.34pp) — recovery not sustained
2014-2015: Gradual improvement trend

Critical finding: Programme ended in 2015 at 10.52%
late rate — never recovered to 2006-2009 baseline of
0-2.55%. Despite recovery efforts, permanent performance
degradation occurred after the 2010-2011 crisis.

Deteriorating years: 2007, 2009, 2010, 2011, 2013 (5 of 9)
Improving years: 2008, 2012, 2014, 2015 (4 of 9)

**Recommendation:**
The 2013 relapse after 2012 recovery confirms that
short-term performance fixes without structural vendor
changes are ineffective. SCMS from RDC contract should
have been restructured in 2012 during recovery — instead
2013 saw immediate relapse. Sustainable improvement
requires contract-level intervention, not operational
adjustments alone.

---

## Business Area 5 — Advanced Analysis

### BQ-15 — NTILE Vendor Segmentation
**Business Question:**
Can we segment all vendors into four performance tiers
based on late shipment rate to create a simple vendor
classification for procurement decisions and dashboard
filtering?

**Why It Matters:**
Binary good/bad vendor classification misses nuance.
Four-tier segmentation allows graduated intervention —
different contract terms for High Risk vs Medium Risk
vs immediate termination consideration for persistent
High Risk vendors. Also enables Power BI slicer for
filtering dashboard by vendor risk tier.

**Data Used:**
Vendor, On_Time_Delivery, Delivery_Delay_Days
Minimum threshold: 30+ shipments for statistical validity

**SQL Reference:** 03_analysis.sql — Query 15

**Key Finding:**
21 vendors with 30+ shipments segmented into four tiers:

High Risk (6 vendors): 10-15.30% late rate
- SCMS from RDC: 15.30% (5,404 shipments — highest volume risk)
- CIPLA LIMITED: 12.57%
- Aurobindo Pharma: 12.13%
- Orgenics Ltd: 10.21%

Medium Risk (5 vendors): 1.79-3.06% late rate
Low Risk (5 vendors): 0.63-1.15% late rate

Reliable (5 vendors): 0-0.36% late rate
- HETERO LABS: 277 shipments, 0.36%
- Trinity Biotech: 356 shipments, 0.28%
- Bristol-Myers Squibb: 67 shipments, 0% 
- Pharmacy Direct: 326 shipments, 0%
- Micro Labs: 35 shipments, 0%

**Recommendation:**
Immediate contract review for all 6 High Risk vendors.
Shift procurement volume from High Risk to Reliable tier
where capacity exists. Use Performance_Tier as a slicer
in Power BI dashboard to enable tier-based filtering
across all dashboard pages.

---

### BQ-16 — Shipment Classification Hierarchy
**Business Question:**
How do shipments break down across the product
classification hierarchy — from Product Group level
down to Sub Classification level? Which categories
dominate procurement volume and which are marginal?

**Why It Matters:**
Understanding volume distribution across the product
hierarchy guides procurement prioritisation. A product
group representing 83% of shipments deserves
proportionally more supply chain scrutiny than one
representing 0.08%. Hierarchy analysis also identifies
whether sub-categories within a group are balanced
or concentrated.

**Data Used:**
Product_Group, Sub_Classification

**SQL Reference:** 03_analysis.sql — Query 16

**Key Finding:**
Level 1 — Product Group Distribution:
- ARV (Antiretrovirals): 8,550 shipments — 82.82%
  Dominant category, nearly 5x all others combined
- HRDT (Diagnostic Test Kits): 1,728 shipments — 16.74%
  Second category, significant but much smaller
- ANTM, ACT, MRDT: Combined only 0.44% of shipments
  Marginal categories with minimal volume

Level 2 — Sub Classification Distribution:
- Adult ARV: 6,595 shipments — 63.88% of all shipments
  Single largest sub-category by far
- Pediatric ARV: 1,955 shipments — 18.94%
  Second largest — adult vs pediatric ARV = 82.82% combined
- HIV test (HRDT): 1,567 shipments — 15.18%
- All others: Combined under 2%

Critical concentration risk: Adult ARV alone represents
63.88% of all programme shipments. Any disruption to
this single sub-category — vendor failure, logistics
breakdown, or supply shortage — affects nearly 2 in 3
shipments programme-wide.

**Recommendation:**
Procurement risk management should weight interventions
by volume share. Adult ARV supply chain deserves
dedicated vendor monitoring given its 63.88% concentration.
Diversifying Adult ARV vendor base beyond current
dominant suppliers reduces single-point-of-failure risk.
Consider minimum 2-vendor policy for any sub-category
exceeding 20% of total shipment volume.

---

### BQ-17 — Stored Procedure: Vendor Performance Report
**Business Question:**
Can we create a reusable, on-demand report that generates
a complete vendor scorecard for any vendor instantly —
without requiring SQL knowledge from the end user?

**Why It Matters:**
Procurement managers need vendor scorecards regularly
for contract reviews, renewal decisions, and performance
meetings. A stored procedure democratises data access —
any authorised user can call CALL GetVendorReport('name')
and get a complete four-section report instantly without
writing any SQL.

**Data Used:**
All columns — Vendor, On_Time_Delivery, Delivery_Delay_Days,
Freight_Cost_USD, Freight_Type, Country,
Scheduled_Delivery_Date

**SQL Reference:** 03_analysis.sql — Query 17

**Procedure Name:** GetVendorReport
**Parameter:** vendor_name VARCHAR(200)

**Output Structure:**
Result Set 1 — Overall scorecard (1 row):
Total shipments, on-time rate, late rate, avg delay,
late shipments count, avg freight cost, countries served

Result Set 2 — Freight type distribution:
Separate vs Absorbed breakdown with late rate per type

Result Set 3 — Year by year performance trend:
Annual shipments, late rate, avg delay (2006-2015)

Result Set 4 — Country breakdown:
Per-country shipments, late rate, avg delay

**Usage Examples:**
CALL GetVendorReport('SCMS from RDC');
CALL GetVendorReport('CIPLA LIMITED');
CALL GetVendorReport('Trinity Biotech, Plc');

**Key Finding:**
Procedure successfully generates complete vendor intelligence
in one command. SCMS from RDC report confirms all previous
findings — 15.3% late rate, deteriorating trend 2010-2014,
active in 17+ countries.

**Recommendation:**
Make this procedure available to procurement team leads
for monthly vendor review meetings. Add to MySQL user
permissions so non-technical stakeholders can run it
directly. Consider extending with an email parameter
to automate monthly vendor report distribution.

---

### BQ-18 — Executive KPI Dashboard Query
**Business Question:**
What is the complete supply chain health summary in a
single view — all headline KPIs that an executive needs
for a programme overview in one result row?

**Why It Matters:**
Executive dashboards need a single source of truth for
headline metrics. This query powers the executive summary
page of the Power BI dashboard — all KPI cards draw
from this single query result. No aggregation needed
in Power BI for these metrics.

**Data Used:** All columns, excluding Unknown Shipment Mode

**SQL Reference:** 03_analysis.sql — Query 18

**Key Finding:**
Complete programme health snapshot:
- Scale: 9,964 shipments, 72 vendors, 43 countries
- Performance: 89.52% on-time, 10.48% late rate
- Efficiency: $1.587B procurement, $67.4M freight (4.25%)
- Delivery: -6.15 days average (fleet delivers early)
- Best vendor: Bristol-Myers Squibb (0% late rate)
- Worst vendor: SCMS from RDC (15.30% late rate)
- Best country: Vietnam (0.87% late rate)
- Worst country: Congo DRC (24.92% late rate)

**Recommendation:**
Use this as the Power BI executive summary page anchor.
All eight KPI card visuals on the dashboard home page
should reference this query result via the
vw_delivery_performance view created in Query 19.

---

## Business Area 6 — Power BI Views

### BQ-19 — View for Power BI Delivery Performance Dashboard
**Business Question:**
How can we provide Power BI with a clean, pre-filtered,
row-level dataset that enables flexible delivery performance
analysis without running complex SQL queries on every
dashboard refresh?

**Why It Matters:**
Power BI performs best with clean row-level views rather
than pre-aggregated tables. Row-level data allows DAX
measures to aggregate dynamically based on slicer
selections — if the data is pre-aggregated in SQL,
Power BI loses the ability to filter and slice flexibly.
A dedicated view also ensures consistent filtering
(Unknown Shipment Mode excluded) across all dashboard
visuals without repeating WHERE clauses in every query.

**Data Used:**
ID, Country, Vendor, Shipment_Mode, Scheduled_Delivery_Date,
Delivered_to_Client_Date, Delivery_Delay_Days, On_Time_Delivery,
Delivery_Status, Product_Group, Line_Item_Value,
Freight_Cost_USD, Freight_Type, Weight_Kilograms

**SQL Reference:** 04_views.sql — Query 19

**View Name:** vw_delivery_performance
**Row Count:** 9,964 (Unknown Shipment Mode excluded)

**Columns Added Beyond Base Table:**
- Year — extracted from Scheduled_Delivery_Date
- Quarter — extracted from Scheduled_Delivery_Date
- Month — extracted from Scheduled_Delivery_Date
- Freight_Cost_Ratio — Freight_Cost_USD as % of Line_Item_Value

**Design Decisions:**
Row-level view chosen over pre-aggregated view because:
1. DAX measures in Power BI need row-level data to
   calculate correctly with slicer context
2. Time intelligence DAX functions require date columns
   at row level not pre-grouped year/quarter columns
3. Drill-through pages in Power BI require row-level
   detail to show individual shipment records

**Verification:**
SELECT COUNT(*) FROM vw_delivery_performance → 9,964 rows
Matches executive KPI query total confirming filter
consistency across all analyses.

**Power BI Usage:**
This view connects to the following dashboard pages:
- Page 1: Executive Summary (KPI cards)
- Page 2: Delivery Performance (trend charts, mode comparison)
- Page 3: Country Analysis (map visual, risk ranking)

**Recommendation:**
Connect Power BI directly to this view via MySQL connector.
Refresh schedule: daily if live MySQL connection,
or export to CSV for static dashboard version.
All DAX measures should reference this view as
the primary fact table in the data model.

---

### BQ-20 — View for Power BI Vendor and Country Analysis
**Business Question:**
How can we provide Power BI with a dedicated dataset
optimised for vendor performance and country-level
analysis pages — including pre-calculated freight
cost ratios that would be complex to compute in DAX?

**Why It Matters:**
While vw_delivery_performance serves general delivery
analysis, vendor and country pages require additional
columns — Sub_Classification, Dosage_Applicable,
Weight_Kilograms, and pre-calculated Freight_Cost_Ratio.
Separating into two views keeps each view focused,
reduces column clutter in Power BI, and allows
independent refresh schedules if needed.

Pre-calculating Freight_Cost_Ratio in SQL rather than
DAX avoids a complex DAX DIVIDE measure that would
need to handle nulls and absorbed freight rows —
simpler and more reliable to compute at the data layer.

**Data Used:**
ID, Vendor, Country, Product_Group, Sub_Classification,
Shipment_Mode, Scheduled_Delivery_Date, Delivery_Delay_Days,
On_Time_Delivery, Delivery_Status, Freight_Type,
Freight_Cost_USD, Line_Item_Value, Dosage_Applicable,
Weight_Kilograms

**SQL Reference:** 04_views.sql — Query 20

**View Name:** vw_vendor_country_analysis
**Row Count:** 9,964 (Unknown Shipment Mode excluded)

**Columns Added Beyond Base Table:**
- Year — extracted from Scheduled_Delivery_Date
- Quarter — extracted from Scheduled_Delivery_Date
- Freight_Cost_Ratio — pre-calculated with NULLIF
  protection against division by zero

**Design Decisions:**
NULLIF(Line_Item_Value, 0) used in ratio calculation
to prevent division by zero errors on rows where
line item value is zero. Returns NULL instead of
error — Power BI handles NULL gracefully in visuals.

Dosage_Applicable included specifically for filtering
HRDT and MRDT product groups in vendor analysis —
these groups have no dosage and need separate
treatment in dashboard visuals.

**Verification:**
SELECT COUNT(*) FROM vw_vendor_country_analysis → 9,964 rows
Consistent with vw_delivery_performance confirming
both views apply identical base filtering.

**Power BI Usage:**
This view connects to the following dashboard pages:
- Page 3: Vendor Scorecard (vendor tier slicer,
  performance ranking table)
- Page 4: Country Risk Analysis (composite risk map,
  country comparison charts)

**Relationship in Power BI Data Model:**
Both views share the ID column — they can be related
in Power BI as two fact tables linked through
a shared ID key if needed for cross-page filtering.
Alternatively use as independent tables per page.

**Recommendation:**
Use Freight_Cost_Ratio from this view directly in
Power BI rather than recalculating in DAX. This
ensures consistent ratio calculation methodology
across SQL analysis and Power BI dashboard —
numbers will match exactly between your SQL output
and dashboard visuals, which is critical for
credibility when presenting to stakeholders.

---

## Summary of Key Findings
*Updated as queries are completed*

| BQ | Business Question | Status | Priority Finding |
|---|---|---|---|
| BQ-01 | On-time by mode | ✓ Complete | Ocean worst at 82.75% |
| BQ-02 | Vendor late ranking | ✓ Complete | SCMS RDC 15.3% late |
| BQ-03 | Country delay | ✓ Complete | Congo DRC crisis level |
| BQ-04 | Freight cost by mode | ✓ Complete | Air least efficient 8.48% |
| BQ-05 | Vendor scorecard |completed | |
| BQ-06 to BQ-20 | Various | 📋 completed | |

---

*Document maintained by Manohar Choudhary*
*Updated after each query is completed*