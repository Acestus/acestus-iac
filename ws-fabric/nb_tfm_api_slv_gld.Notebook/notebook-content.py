# Fabric notebook source

# METADATA ********************

# META {
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
timezone = "<your-timezone>"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col, from_utc_timestamp

# Read from silver and add local time columns into gold.
df = spark.read.format("delta").load("Tables/dbo/time_logs")
df_local = (
	df.withColumn("timestamp_local", from_utc_timestamp(col("timestamp"), timezone))
)

(
	df_local.write.format("delta")
	.mode("overwrite")
	.option("overwriteSchema", "true")
	.saveAsTable("dbo.time_logs")
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
