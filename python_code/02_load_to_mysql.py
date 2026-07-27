import mysql.connector
import pandas as pd
import numpy as np

# Connect
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Your_mysql_password",  # Enter your mysql password
    database="supply_chain_db"
)
cursor = conn.cursor()
print("Connected successfully")

# Truncate first
cursor.execute("TRUNCATE TABLE scms_shipments")
conn.commit()
print("Table truncated")

# Load cleaned data
df = pd.read_csv(
    "../data/processed_data/scms_cleaned.csv",
    encoding="utf-8"
)

# Replace ALL variations of null with None
df = df.replace({np.nan: None, "nan": None, "NaN": None, "None": None})
print("Rows to insert:", len(df))

# INSERT query
insert_query = """
    INSERT INTO scms_shipments (
        ID, Project_Code, PQ_Number, PO_SO_Number, ASN_DN_Number,
        Country, Managed_By, Fulfill_Via, Vendor_INCO_Term, Shipment_Mode,
        PQ_First_Sent_to_Client, PO_Sent_to_Vendor, Scheduled_Delivery_Date,
        Delivered_to_Client_Date, Delivery_Recorded_Date, Product_Group,
        Sub_Classification, Vendor, Item_Description, Molecule_Test_Type,
        Brand, Dosage, Dosage_Form, Unit_of_Measure_Per_Pack,
        Line_Item_Quantity, Line_Item_Value, Pack_Price, Unit_Price,
        Manufacturing_Site, First_Line_Designation, Weight_Kilograms,
        Freight_Cost_USD, Line_Item_Insurance_USD, Freight_Type,
        Weight_Type, Delivery_Delay_Days,
On_Time_Delivery, Delivery_Status, Dosage_Applicable
    ) VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s
    )
"""

# Convert to list of tuples
rows = [tuple(row) for row in df.itertuples(index=False, name=None)]
print("Data prepared. Inserting...")

# Insert
cursor.executemany(insert_query, rows)
conn.commit()
print(f"Successfully inserted {cursor.rowcount} rows")

# Verify
cursor.execute("SELECT COUNT(*) FROM scms_shipments")
count = cursor.fetchone()[0]
print(f"Rows in MySQL: {count}")

# Close
cursor.close()
conn.close()
print("Connection closed")
