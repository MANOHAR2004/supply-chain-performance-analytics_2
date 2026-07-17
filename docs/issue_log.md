# Data Issue Log — Supply Chain Dataset

## Issue 001
**Column:** Freight Cost (USD)
**Problem:** Stored as object instead of float64. Likely contains non-numeric characters.
**Discovery Method:** df.info() output
**Fix Applied:** Strip non-numeric characters, convert to float64 using (df[
    pd.to_numeric(df["Freight Cost (USD)"], errors="coerce").isna()
])
**Status:** Resolved

## Issue 002
**Column:** Shipment Mode
**Problem:** 360 null values (3.5% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 003
**Column:** Dosage
**Problem:** 1736 null values (16.8% of data)
**Discovery Method:** df.info() output, and (df["Shipment Mode"].value_counts(dropna = False))
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 004
**Column:** Line Item Insurance (USD)
**Problem:** 287 null values (2.78% of data)
**Discovery Method:** df.isnull().sum() and df.info() output
**Investigation:** describe() output showed min value = 0, confirming 
zero is a valid recorded value in this column. 54 rows already 
recorded as 0 insurance. Null values investigated for two possible 
interpretations — data not recorded vs genuinely zero insurance cost.
**Decision Logic:** 2.78% is below the 5% bias threshold. Since zero 
is already a valid value and the percentage is small, filling with 0 
is conservative and does not meaningfully bias cost analysis.
**Fix Applied:** df["Line Item Insurance (USD)"].fillna(0, inplace=True)
**Verified:** isnull().sum() returned 0 after fix confirming all 
nulls resolved.
**Status:** Resolved

## Issue 005
**Column:** All date columns (5 columns)
**Problem:** Stored as object instead of datetime
**Discovery Method:** df.info() output
**Fix Applied:** **Fix Applied:** Converted all 5 date columns using pd.to_datetime() 
with format="%Y-%m-%d" in a loop. Verified output visually confirms 
correct 4-digit year parsing.
**Status:** Resolved


## Issue 006
**Column:** Freight Cost (USD)
**Problem:** Column contained three mixed value types — actual numeric 
costs, reference strings (See DN-XXXX), and text entries 
(Freight Included in Commodity Cost). Stored as object due to mixed types.
**Discovery Method:** df["Freight Cost (USD)"].unique() and visual inspection
**Fix Applied:** Created Freight_Type flag column using np.where() and 
regex to classify rows as Absorbed (text) or Separate (numeric). 
Then converted Freight Cost to numeric using pd.to_numeric(errors='coerce').
Absorbed rows become NaN in Freight Cost — intentional and documented.
**Business Note:** 4126 rows (39.9%) have absorbed freight — 
significant finding for cost analysis. These rows excluded from 
freight cost calculations but retained for delivery performance analysis.
**Status:** Resolved

## Issue 007
**Column:** Weight (Kilograms)
**Problem:** Mixed numeric and text values stored as object dtype.
Text values include "Weight Captured Separately" and reference strings.
**Discovery Method:** df["Weight (Kilograms)"].tail() inspection
**Fix Applied:** Created Weight_Type flag column using np.where() 
and str.contains() regex. Converted Weight to float64 using 
pd.to_numeric(errors='coerce'). Text rows become NaN intentionally.
**Status:** Resolved

## Issue 008
**Column:** Dosage
**Problem:** 1736 null values (16.8% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 009
**Column:** Line Item Insurance (USD)
**Problem:** 287 null values (2.8% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 010
**Column:** All date columns (5 columns)
**Problem:** Stored as object instead of datetime
**Discovery Method:** df.info() output
**Fix Applied:** Convert using pd.to_datetime()
**Status:** Pending

## Issue 011
**Column:** Freight Cost (USD)
**Problem:** Stored as object instead of float64. Likely contains non-numeric characters.
**Discovery Method:** df.info() output
**Fix Applied:** Strip non-numeric characters, convert to float64
**Status:** Pending

## Issue 012
**Column:** Shipment Mode
**Problem:** 360 null values (3.5% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 013
**Column:** Dosage
**Problem:** 1736 null values (16.8% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 014
**Column:** Line Item Insurance (USD)
**Problem:** 287 null values (2.8% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 015
**Column:** All date columns (5 columns)
**Problem:** Stored as object instead of datetime
**Discovery Method:** df.info() output
**Fix Applied:** Convert using pd.to_datetime()
**Status:** Pending

## Issue 016
**Column:** Freight Cost (USD)
**Problem:** Stored as object instead of float64. Likely contains non-numeric characters.
**Discovery Method:** df.info() output
**Fix Applied:** Strip non-numeric characters, convert to float64
**Status:** Pending

## Issue 002
**Column:** Shipment Mode
**Problem:** 360 null values (3.5% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 003
**Column:** Dosage
**Problem:** 1736 null values (16.8% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 004
**Column:** Line Item Insurance (USD)
**Problem:** 287 null values (2.8% of data)
**Discovery Method:** df.info() output
**Fix Applied:** TBD after investigation
**Status:** Pending

## Issue 005
**Column:** All date columns (5 columns)
**Problem:** Stored as object instead of datetime
**Discovery Method:** df.info() output
**Fix Applied:** Convert using pd.to_datetime()
**Status:** Pending