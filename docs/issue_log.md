# Data Issue Log — Supply Chain Performance & Risk Analytics
**Dataset:** USAID SCMS Delivery History Dataset
**Total Issues Found:** 9
**Total Issues Resolved:** 9
**Phase:** 1 — EDA & Cleaning

---

## Issue 001
**Column:** Freight Cost (USD)
**Problem:** Stored as object instead of float64. Contains mixed 
value types — numeric costs, reference strings (See DN-XXXX), 
and text entries (Freight Included in Commodity Cost).
**Discovery Method:** df.info() output
**Fix Applied:** Superseded by Issue 006 — see Issue 006 for 
complete resolution.
**Status:** Superseded by Issue 006

---

## Issue 002
**Column:** Shipment Mode
**Problem:** 360 null values (3.49% of data)
**Discovery Method:** df.isnull().sum() and value_counts(dropna=False)
**Investigation Finding:** All 360 null Shipment Mode rows have 
Freight_Type = Absorbed and Freight Cost = NaN. Missing mode 
correlates directly with absorbed freight — structural data gap, 
not random missingness. When freight is absorbed into commodity 
cost, shipment mode was not recorded.
**Fix Applied:** df["Shipment Mode"] = df["Shipment Mode"].fillna("Unknown")
Filled with "Unknown" to preserve rows for line item value analysis 
while correctly excluding from mode-based freight cost comparisons.
**Verified:** value_counts() shows Unknown: 360 after fix.
**Status:** Resolved

---

## Issue 003
**Column:** Dosage
**Problem:** 1736 null values (16.8% of data)
**Discovery Method:** df.isnull().sum() — highest null percentage 
in dataset, above safe filling threshold.
**Investigation Finding:** Cross-tabulation with Product Group 
revealed null Dosage belongs exclusively to HRDT (1728 rows) and 
MRDT (8 rows) product groups. ARV, ANTM, and ACT have zero null 
Dosage values. Groups never overlap — this is structural missingness, 
not random data entry error. HRDT and MRDT are diagnostic test kits 
where Dosage is not an applicable product attribute.
**Fix Applied:** Created Dosage_Applicable flag column.
df["Dosage_Applicable"] = np.where(
    df["Product Group"].isin(["HRDT", "MRDT"]),
    "Not Applicable", "Applicable"
)
Dosage nulls retained as NaN — they are correct and meaningful.
Filling with Unknown would be misleading as Dosage simply does 
not apply to these product types.
**Verified:** Dosage_Applicable shows Applicable: 8588, 
Not Applicable: 1736 — matches exactly.
**Status:** Resolved

---

## Issue 004
**Column:** Line Item Insurance (USD)
**Problem:** 287 null values (2.78% of data)
**Discovery Method:** df.isnull().sum() and df.info() output
**Investigation Finding:** describe() output showed min value = 0, 
confirming zero is a valid recorded value in this column. 
287 nulls investigated for two interpretations — data not recorded 
vs genuinely zero insurance cost. At 2.78%, below the 5% bias 
threshold. Zero already exists as a valid value (min = 0).
**Decision:** Filling with 0 treats missing insurance as no 
insurance cost recorded — conservative, transparent, documented.
**Fix Applied:** 
df["Line Item Insurance (USD)"] = df["Line Item Insurance (USD)"].fillna(0)
**Verified:** isnull().sum() returned 0 after fix.
**Status:** Resolved

---

## Issue 005
**Column:** Scheduled Delivery Date, Delivered to Client Date, 
Delivery Recorded Date
**Problem:** Three date columns stored as object instead of 
datetime64. Initial format assumption "%Y-%m-%d" was incorrect 
causing 100% NaT conversion failure.
**Discovery Method:** df.info() showed object dtype. 
Conversion failure discovered when all 10324 rows returned NaT.
**Investigation Finding:** Raw value inspection with .head(10) 
revealed actual format is "2-Jun-06" — day, abbreviated month 
name, 2-digit year. Correct format string: "%d-%b-%y".
**Fix Applied:** 
date_columns = ["Scheduled Delivery Date", 
                "Delivered to Client Date", 
                "Delivery Recorded Date"]
for col in date_columns:
    df[col] = pd.to_datetime(df[col], 
                             errors="coerce", 
                             format="%d-%b-%y")
**Verified:** All three columns show datetime64[ns] dtype. 
isnull().sum() = 0 for all three.
**Status:** Resolved

---

## Issue 006
**Column:** Freight Cost (USD)
**Problem:** Column contained three mixed value types stored 
as object dtype:
1. Actual numeric freight costs (e.g. 780.34, 4521.50)
2. Reference strings (e.g. See DN-4307 ID#83920)
3. Text entries (Freight Included in Commodity Cost)
**Discovery Method:** df["Freight Cost (USD)"].tail() inspection 
after df.info() flagged object dtype.
**Investigation Finding:** 4126 rows (39.9%) contain non-numeric 
text. Nearly 40% of shipments have freight absorbed into commodity 
cost — significant business finding, not just a data quality issue.
**Fix Applied:** 
Step 1 — Created Freight_Type flag before conversion:
df["Freight_Type"] = np.where(
    df["Freight Cost (USD)"].str.contains(r"[A-Za-z]", na=False),
    "Absorbed", "Separate"
)
Step 2 — Converted to numeric, text becomes NaN intentionally:
df["Freight Cost (USD)"] = pd.to_numeric(
    df["Freight Cost (USD)"], errors="coerce"
)
**Business Note:** 4126 Absorbed rows excluded from freight cost 
calculations but retained for delivery performance analysis. 
Absorbed freight rows correlate with null Shipment Mode (Issue 002).
**Verified:** Freight_Type shows Separate: 6198, Absorbed: 4126. 
Null count in Freight Cost = 4126 — matches exactly.
**Status:** Resolved

---

## Issue 007
**Column:** Weight (Kilograms)
**Problem:** Same mixed-type pattern as Freight Cost (Issue 006). 
Contains numeric weights, reference strings (See DN-XXXX), 
and text entries (Weight Captured Separately). Stored as object.
**Discovery Method:** df["Weight (Kilograms)"].tail() inspection.
**Fix Applied:**
Step 1 — Created Weight_Type flag before conversion:
df["Weight_Type"] = np.where(
    df["Weight (Kilograms)"].str.contains(r"[A-Za-z]", na=False),
    "Captured Separately", "Recorded"
)
Step 2 — Converted to numeric, text becomes NaN intentionally:
df["Weight (Kilograms)"] = pd.to_numeric(
    df["Weight (Kilograms)"], errors="coerce"
)
**Verified:** Weight_Type shows Recorded: 6372, 
Captured Separately: 3952. Null count in Weight = 3952 — 
matches exactly.
**Status:** Resolved

---

## Issue 008
**Column:** Entire Dataset
**Problem:** CSV file uses latin1 encoding. Loading with default 
UTF-8 encoding causes UnicodeDecodeError on special characters 
in country names and vendor descriptions.
**Discovery Method:** FileNotFoundError investigation revealed 
encoding mismatch when loading file.
**Fix Applied:** Added encoding="latin1" parameter to pd.read_csv():
df = pd.read_csv(
    "../data/raw_data/SCMS_Delivery_History_Dataset_20150929.csv",
    encoding="latin1"
)
**Status:** Resolved and completed 

---

## Issue 009
**Column:** PQ First Sent to Client Date, PO Sent to Vendor Date
**Problem:** Columns contain placeholder text instead of dates 
in most rows. PQ First Sent contains "Pre-PQ Process" and 
PO Sent to Vendor contains "Date Not Captured". Sparse real 
dates use MM/DD/YYYY format — different from other date columns.
**Discovery Method:** Raw value inspection with .head(10) after 
100% NaT conversion failure when using "%d-%b-%y" format.
**Investigation Finding:** These columns represent process stages 
that were incomplete or not tracked for most shipments. Real 
dates that exist use format "11/13/2006" = "%m/%d/%Y".
**Fix Applied:**
mixed_date_columns = ["PQ First Sent to Client Date",
                      "PO Sent to Vendor Date"]
for col in mixed_date_columns:
    df[col] = pd.to_datetime(df[col], 
                             errors="coerce", 
                             format="%m/%d/%Y")
Placeholder text becomes NaT intentionally via errors="coerce".
These columns excluded from delivery delay calculations.
**Verified:** PQ First Sent: 2681 non-null dates recovered.
PO Sent to Vendor: 4592 non-null dates recovered.
**Status:** Resolved

---

## Feature Engineering Log

### Feature 001 — Delivery_Delay_Days
**Formula:** Delivered to Client Date − Scheduled Delivery Date
**Type:** Integer (days)
**Business Use:** Core KPI — measures actual delivery performance 
against schedule. Positive = late, Negative = early, Zero = exact.
**Code:**
df["Delivery_Delay_Days"] = (
    df["Delivered to Client Date"] - df["Scheduled Delivery Date"]
).dt.days

### Feature 002 — On_Time_Delivery
**Formula:** Delivery_Delay_Days <= 2 → "On Time" else "Late"
**Type:** Categorical (On Time / Late)
**Business Use:** Binary KPI for dashboard headline metric. 
2-day tolerance window accounts for last-mile variability.
**Finding:** 9278 On Time (89.9%), 1046 Late (10.1%)
**Code:**
df["On_Time_Delivery"] = np.where(
    df["Delivery_Delay_Days"] <= 2, "On Time", "Late"
)

### Feature 003 — Delivery_Status
**Formula:** Three-way classification — Early / On Time / Late
**Type:** Categorical (Early / On Time / Late)
**Business Use:** Granular delivery performance segmentation. 
Early deliveries indicate over-expediting — a cost concern. 
Late deliveries indicate supplier or logistics risk.
**Finding:** Early: 2814 (27.3%), On Time: 6464 (62.6%), 
Late: 1046 (10.1%)
**Code:**
df["Delivery_Status"] = np.where(
    df["Delivery_Delay_Days"] < 0, "Early",
    np.where(df["Delivery_Delay_Days"] <= 2, "On Time", "Late")
)

---
*Phase 1 completed — cleaned data exported to data/processed/scms_cleaned.csv*
*Final shape: 10324 rows × 38 columns*