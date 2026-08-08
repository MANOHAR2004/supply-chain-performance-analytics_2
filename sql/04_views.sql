USE supply_chain_db;

-- 19) Business Question: Create a pre-aggregated view that Power BI can connect to directly for the delivery performance dashboard page — so the dashboard loads fast without running complex queries every time.       
-- Query 19 — View for Power BI Delivery Performance

CREATE VIEW vw_delivery_performance AS
SELECT 
    ID,
    Country,
    Vendor,
    Shipment_Mode,
    YEAR(Scheduled_Delivery_Date) AS Year,
    QUARTER(Scheduled_Delivery_Date) AS Quarter,
    MONTH(Scheduled_Delivery_Date) AS Month,
    Scheduled_Delivery_Date,
    Delivered_to_Client_Date,
    Delivery_Delay_Days,
    On_Time_Delivery,
    Delivery_Status,
    Product_Group,
    Line_Item_Value,
    Freight_Cost_USD,
    Freight_Type,
    Weight_Kilograms,
    ROUND(
        Freight_Cost_USD * 100.0 / NULLIF(Line_Item_Value, 0), 2
    ) AS Freight_Cost_Ratio
FROM scms_shipments
WHERE Shipment_Mode != 'Unknown';


-- 20) Business Question: Create a second view specifically for the vendor and country analysis pages of the Power BI dashboard — pre-filtered and structured for those specific visuals.

-- Query 20 — View for Vendor and Country Analysis

CREATE VIEW vw_vendor_country_analysis AS
SELECT
    ID,
    Vendor,
    Country,
    Product_Group,
    Sub_Classification,
    Shipment_Mode,
    YEAR(Scheduled_Delivery_Date) AS Year,
    QUARTER(Scheduled_Delivery_Date) AS Quarter,
    Delivery_Delay_Days,
    On_Time_Delivery,
    Delivery_Status,
    Freight_Type,
    Freight_Cost_USD,
    Line_Item_Value,
    ROUND(
        Freight_Cost_USD * 100.0 / NULLIF(Line_Item_Value, 0), 2
    ) AS Freight_Cost_Ratio,
    Dosage_Applicable,
    Weight_Kilograms
FROM scms_shipments
WHERE Shipment_Mode != 'Unknown';



SELECT * FROM vw_delivery_performance LIMIT 5;
SELECT COUNT(*) FROM vw_delivery_performance;

SELECT * FROM vw_vendor_country_analysis LIMIT 5;
SELECT COUNT(*) FROM vw_vendor_country_analysis;