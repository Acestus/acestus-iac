# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "9ff4c31a-221d-4395-88d0-eeb01d0ab46e",
# META       "default_lakehouse_name": "lh_api_brz",
# META       "default_lakehouse_workspace_id": "973280da-7f1d-40c9-abd7-94df0d48dc03",
# META       "known_lakehouses": [
# META         {
# META           "id": "19f2860e-7f0e-4264-91ba-ca5c41b08fe4"
# META         },
# META         {
# META           "id": "9ff4c31a-221d-4395-88d0-eeb01d0ab46e"
# META         }
# META       ]
# META     }
# META   }
# META }

# PARAMETERS CELL ********************

# Environment parameters - can be overridden when calling from pipeline
environment = "dev"  # dev, stg, prd
source_container = "container-development"  # container-development, container-staging, container-production
storage_account = "<your-storage-account>"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Create sample data directory and files
import os
import json
from datetime import datetime, timedelta

# Create directory structure
os.makedirs("Files/api", exist_ok=True)

# Create sample JSON data
sample_data = []
base_time = datetime.now()

for i in range(10):
    record = {
        "message": f"Sample log message {i+1}",
        "timestamp": (base_time - timedelta(hours=i)).isoformat(),
        "utcTimestamp": (base_time - timedelta(hours=i)).isoformat()
    }
    sample_data.append(record)

# Write sample data to JSON file
with open("Files/api/sample_logs.json", "w") as f:
    json.dump(sample_data, f, indent=2)

print("Sample data created in Files/api/sample_logs.json")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
