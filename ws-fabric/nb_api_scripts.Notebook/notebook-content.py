# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "d30f246b-9e69-460c-a99d-dd4b10c28d9b",
# META       "default_lakehouse_name": "lh_api_gld",
# META       "default_lakehouse_workspace_id": "973280da-7f1d-40c9-abd7-94df0d48dc03",
# META       "known_lakehouses": [
# META         {
# META           "id": "d30f246b-9e69-460c-a99d-dd4b10c28d9b"
# META         },
# META         {
# META           "id": "19f2860e-7f0e-4264-91ba-ca5c41b08fe4"
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
workspace_id = "973280da-7f1d-40c9-abd7-94df0d48dc03"
lakehouse_gld_id = "d30f246b-9e69-460c-a99d-dd4b10c28d9b"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Display hostname for debugging/verification
import socket
hostname = socket.gethostname()
print(f"Running on: {hostname}01")
print(f"Hello from {environment} environment!")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Install prerequisites
%pip install azure-identity deltalake pandas

# Login to Azure (run in terminal if not already logged in)
import subprocess
import sys
from azure.identity import AzureCliCredential

try:
    # Check if already logged in
    result = subprocess.run(["az", "account", "show"], capture_output=True, text=True)
    if result.returncode == 0:
        print("✓ Already logged in to Azure")
    else:
        print("Please run 'az login' in the terminal")
except FileNotFoundError:
    print("Azure CLI not found. Please install from: https://aka.ms/installazurecliwindows")

print("\nPrerequisites installed!")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Query 10 rows from OneLake
from deltalake import DeltaTable

# OneLake ABFS path - uses parameters defined above
abfs_path = f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/{lakehouse_gld_id}/Tables/dbo/time_logs"

# Authenticate and query
credential = AzureCliCredential()
storage_options = {
    "bearer_token": credential.get_token("https://storage.azure.com/.default").token,
    "use_fabric_endpoint": "true"
}

dt = DeltaTable(abfs_path, storage_options=storage_options)
df = dt.to_pandas()

# Display first 10 rows
print(f"Total rows: {len(df)}")
df.head(10)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.sql("SELECT * FROM lh_api_slv.dbo.time_logs LIMIT 10")
display(df)


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.sql("SELECT * FROM lh_api_gld.dbo.time_logs LIMIT 10")
display(df)


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
