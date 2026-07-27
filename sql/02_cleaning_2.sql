USE supply_chain_db;

select count(*) from scms_shipments;
SELECT 
    ID,
    Country,
    Vendor,
    Shipment_Mode,
    Scheduled_Delivery_Date,
    Delivered_to_Client_Date,
    Delivery_Delay_Days,
    Delivery_Status
FROM scms_shipments
LIMIT 10;
