import pandas as pd
from sqlalchemy import create_engine
import os

# Create connection using SQLAlchemy
engine = create_engine(
    "mysql+pymysql://root:Mano%232002%40@localhost/supply_chain_db"
)

# Create output directory if it doesn't exist
os.makedirs("../data/processed_data", exist_ok=True)

# Export View 1
df1 = pd.read_sql("SELECT * FROM vw_delivery_performance", engine)
df1.to_csv("../data/processed_data/vw_delivery_performance.csv", index=False)
print(f"View 1 exported: {len(df1)} rows")

# Export View 2
df2 = pd.read_sql("SELECT * FROM vw_vendor_country_analysis", engine)
df2.to_csv("../data/processed_data/vw_vendor_country_analysis.csv", index=False)
print(f"View 2 exported: {len(df2)} rows")

engine.dispose()
print("Export complete. Files saved to data/processed_data/")


# Check what's in the processed folder
processed_path = "../data/processed_data"
print("Files in processed folder:")
for file in os.listdir(processed_path):
    print(file)

# Also print the absolute path so you know exactly where to look
print("\nAbsolute path:")
print(os.path.abspath(processed_path))
