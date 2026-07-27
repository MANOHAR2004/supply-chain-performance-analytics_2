-- CREATE DATABASE supply_chain_db;
USE supply_chain_db;

-- CREATE TABLE scms_shipments (
--     -- Identifiers
--     ID                          INT,
--     Project_Code                VARCHAR(50),
--     PQ_Number                   VARCHAR(50),
--     PO_SO_Number                VARCHAR(50),
--     ASN_DN_Number               VARCHAR(50),

--     -- Geography and Management
--     Country                     VARCHAR(100),
--     Managed_By                  VARCHAR(100),
--     Fulfill_Via                 VARCHAR(100),
--     Vendor_INCO_Term            VARCHAR(50),

--     -- Shipment
--     Shipment_Mode               VARCHAR(50),

--     -- Dates
--     PQ_First_Sent_to_Client     DATE,
--     PO_Sent_to_Vendor           DATE,
--     Scheduled_Delivery_Date     DATE,
--     Delivered_to_Client_Date    DATE,
--     Delivery_Recorded_Date      DATE,

--     -- Product Details
--     Product_Group               VARCHAR(50),
--     Sub_Classification          VARCHAR(100),
--     Vendor                      VARCHAR(200),
--     Item_Description            VARCHAR(500),
--     Molecule_Test_Type          VARCHAR(200),
--     Brand                       VARCHAR(200),
--     Dosage                      VARCHAR(100),
--     Dosage_Form                 VARCHAR(100),
--     Unit_of_Measure_Per_Pack    INT,

--     -- Quantities and Values
--     Line_Item_Quantity          INT,
--     Line_Item_Value             DECIMAL(15,2),
--     Pack_Price                  DECIMAL(10,4),
--     Unit_Price                  DECIMAL(10,4),

--     -- Manufacturing
--     Manufacturing_Site          VARCHAR(200),
--     First_Line_Designation      VARCHAR(50),

--     -- Weight and Freight
--     Weight_Kilograms            DECIMAL(10,2),
--     Freight_Cost_USD            DECIMAL(12,2),
--     Line_Item_Insurance_USD     DECIMAL(10,2),

--     -- Engineered Flag Columns
--     Freight_Type                VARCHAR(20),
--     Weight_Type                 VARCHAR(30),
--     Dosage_Applicable           VARCHAR(20),

--     -- Engineered KPI Columns
--     Delivery_Delay_Days         INT,
--     On_Time_Delivery            VARCHAR(10),
--     Delivery_Status             VARCHAR(10)
-- );



-- Add PRIMARY KEY after table creation
ALTER TABLE scms_shipments
MODIFY ID INT NOT NULL;

ALTER TABLE scms_shipments
ADD PRIMARY KEY (ID);

DESCRIBE scms_shipments;

ALTER TABLE scms_shipments
MODIFY PQ_First_Sent_to_Client VARCHAR(50),
MODIFY PO_Sent_to_Vendor VARCHAR(50);

ALTER TABLE scms_shipments
MODIFY Freight_Cost_USD VARCHAR(50),
MODIFY Weight_Kilograms VARCHAR(50),
MODIFY Delivery_Delay_Days VARCHAR(50),
MODIFY Unit_of_Measure_Per_Pack VARCHAR(50),
MODIFY Line_Item_Quantity VARCHAR(50),
MODIFY Line_Item_Value VARCHAR(50),
MODIFY Pack_Price VARCHAR(50),
MODIFY Unit_Price VARCHAR(50),
MODIFY Line_Item_Insurance_USD VARCHAR(50);


truncate table scms_shipments;
select count(*) from scms_shipments;

ALTER TABLE scms_shipments
MODIFY Delivery_Status VARCHAR(20),
MODIFY On_Time_Delivery VARCHAR(20);

DESCRIBE scms_shipments;


SET SESSION wait_timeout = 600;
SET SESSION interactive_timeout = 600;
SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;

TRUNCATE TABLE scms_shipments;

ALTER TABLE scms_shipments
MODIFY Delivery_Status VARCHAR(20),
MODIFY On_Time_Delivery VARCHAR(20);
