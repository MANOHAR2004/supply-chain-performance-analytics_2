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

**SQL Reference:** 03_analysis.sql — Query 2

**Key Finding:**
- SCMS from RDC: 15.30% late rate (827 late from 5,404
  shipments — single largest risk vendor)
- BIO-RAD LABORATORIES: 14.29% late rate
- CIPLA LIMITED: 12.57% late rate
- Aurobindo Pharma: 12.13% late rate (high volume risk)

**Recommendation:**
SCMS from RDC handles 52% of all shipments with 15.3%
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
Is overall delivery performance improving or
deteriorating over time on a quarterly basis?

**SQL Reference:** 03_analysis.sql — Query 13
**Key Finding:** [Pending]
**Recommendation:** [Pending]

---

### BQ-14 — Year Over Year Late Rate Change
**Business Question:**
Which years had the worst delivery performance and
what was the rate of change between years?

**SQL Reference:** 03_analysis.sql — Query 14
**Key Finding:** [Pending]
**Recommendation:** [Pending]

---

## Business Area 5 — Advanced Analysis

### BQ-15 — Vendor NTILE Segmentation
**Business Question:**
Can we segment all vendors into performance tiers
(High Risk, Medium Risk, Low Risk, Reliable) based
on combined delivery and cost metrics?

**SQL Reference:** 03_analysis.sql — Query 15
**Key Finding:** [Pending]
**Recommendation:** [Pending]

---

### BQ-16 — Shipment Classification Hierarchy
**Business Question:**
How do shipments break down across the classification
hierarchy from Product Group to Sub Classification?

**SQL Reference:** 03_analysis.sql — Query 16
**Key Finding:** [Pending]
**Recommendation:** [Pending]

---

### BQ-17 — Stored Procedure: Vendor Report
**Business Question:**
Can we create a reusable report that generates
complete performance metrics for any vendor on demand?

**SQL Reference:** 03_analysis.sql — Query 17
**Key Finding:** [Reusable procedure — no static finding]
**Recommendation:** [Pending]

---

### BQ-18 — Executive KPI Dashboard Query
**Business Question:**
What is the single-query executive summary of all
supply chain health metrics?

**SQL Reference:** 03_analysis.sql — Query 18
**Key Finding:** [Pending]
**Recommendation:** [Pending]

---

## Business Area 6 — Power BI Views

### BQ-19 — Delivery Performance View
**Purpose:** Pre-aggregated view for Power BI delivery
performance dashboard page.
**SQL Reference:** 04_views.sql — View 1

### BQ-20 — Vendor and Country Analysis View
**Purpose:** Pre-aggregated view for Power BI vendor
and geography dashboard pages.
**SQL Reference:** 04_views.sql — View 2

---

## Summary of Key Findings
*Updated as queries are completed*

| BQ | Business Question | Status | Priority Finding |
|---|---|---|---|
| BQ-01 | On-time by mode | ✓ Complete | Ocean worst at 82.75% |
| BQ-02 | Vendor late ranking | ✓ Complete | SCMS RDC 15.3% late |
| BQ-03 | Country delay | ✓ Complete | Congo DRC crisis level |
| BQ-04 | Freight cost by mode | ✓ Complete | Air least efficient 8.48% |
| BQ-05 | Vendor scorecard | 🔄 In Progress | |
| BQ-06 to BQ-20 | Various | 📋 Pending | |

---

*Document maintained by Manohar Choudhary*
*Updated after each query is completed*