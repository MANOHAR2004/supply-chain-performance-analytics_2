import mysql.connector
import pandas as pd
import numpy as np

# Connect
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Your_mysql_password",  # type you mysql password
    database="supply_chain_db"
)
cursor = conn.cursor()
print("Connected successfully")

# Load cleaned data
df = pd.read_csv(
    "../data/processed_data/scms_cleaned.csv",
    encoding="utf-8"
)

# Replace ALL variations of null with None
df = df.replace({np.nan: None, "nan": None, "NaN": None, "None": None})
print("Rows to insert:", len(df))

# INSERT query — 38 placeholders
insert_query = """
    INSERT INTO scms_shipments VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s,%s
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
