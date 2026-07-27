
-- ══════════════════════════════════════════
-- Phase 2 — Data Type Conversion
-- ══════════════════════════════════════════

USE supply_chain_db;

ALTER TABLE scms_shipments
MODIFY Scheduled_Delivery_Date DATE,
MODIFY Delivered_to_Client_Date DATE,
MODIFY Delivery_Recorded_Date DATE;

-- PQ and PO dates have mixed text — keep as VARCHAR
-- MODIFY PQ_First_Sent_to_Client VARCHAR(50) NO NEED TO CONVERTION ALREADY CORRECT DATA TYPE
-- MODIFY PO_Sent_to_Vendor VARCHAR(50) NO NEED TO CONVERTION ALREADY CORRECT DATA TYPE


-- Convert integer columns
ALTER TABLE scms_shipments
MODIFY Unit_of_Measure_Per_Pack INT,
MODIFY Line_Item_Quantity INT,
MODIFY Delivery_Delay_Days INT;

-- Convert decimal columns
ALTER TABLE scms_shipments
MODIFY Line_Item_Value DECIMAL(15,2),
MODIFY Pack_Price DECIMAL(10,4),
MODIFY Unit_Price DECIMAL(10,4),
MODIFY Weight_Kilograms DECIMAL(10,2),
MODIFY Freight_Cost_USD DECIMAL(12,2),
MODIFY Line_Item_Insurance_USD DECIMAL(10,2);

DESCRIBE scms_shipments;