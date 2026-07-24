import mysql.connector
import pandas as pd

# Connect
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Mano#2002@",
    database="supply_chain_db"
)
cursor = conn.cursor()
print("Connected successfully")

# Load cleaned data
df = pd.read_csv(
    "../data/processed/scms_cleaned.csv",
    encoding="utf-8"
)
df = df.where(pd.notna(df), None)
print("Rows to insert:", len(df))

# Fixed INSERT — 38 placeholders matching schema column order
insert_query = """
    INSERT INTO scms_shipments VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s
    )
"""

# Convert to list of tuples and insert
rows = [tuple(row) for row in df.values]
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
