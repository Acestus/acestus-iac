"""
Spark Job: Transform api Silver to Gold
Reads from silver lakehouse and writes to gold lakehouse with timezone conversion
"""
import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_utc_timestamp


def main(source_table=None, target_table=None, timezone="America/Chicago"):
    """
    Transform time_logs data from silver to gold with local timezone conversion
    
    Args:
        source_table: Source table path (default: Tables/dbo/time_logs)
        target_table: Target table name (default: dbo.time_logs)
        timezone: Timezone for conversion (default: America/Chicago)
    """
    # Initialize Spark session
    spark = SparkSession.builder.appName("API_SLV_to_GLD_Transform").getOrCreate()
    
    # Set defaults if not provided
    if source_table is None:
        source_table = "Tables/dbo/time_logs"
    if target_table is None:
        target_table = "dbo.time_logs"
    
    print(f"Reading from: {source_table}")
    print(f"Writing to: {target_table}")
    print(f"Timezone: {timezone}")
    
    # Read from silver lakehouse
    df = spark.read.format("delta").load(source_table)
    
    # Add local time column with timezone conversion
    df_local = df.withColumn(
        "timestamp_local", 
        from_utc_timestamp(col("timestamp"), timezone)
    )
    
    # Write to gold lakehouse
    (
        df_local.write.format("delta")
        .mode("overwrite")
        .option("overwriteSchema", "true")
        .saveAsTable(target_table)
    )
    
    print(f"Successfully transformed {df_local.count()} records")
    
    spark.stop()


if __name__ == "__main__":
    # Parse command line arguments
    # Expected format: python script.py [source_table] [target_table] [timezone]
    
    source = sys.argv[1] if len(sys.argv) > 1 else None
    target = sys.argv[2] if len(sys.argv) > 2 else None
    tz = sys.argv[3] if len(sys.argv) > 3 else "America/Chicago"
    
    main(source_table=source, target_table=target, timezone=tz)
