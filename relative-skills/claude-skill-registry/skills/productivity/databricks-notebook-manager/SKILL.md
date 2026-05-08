---
name: databricks-notebook-manager
description: Create and manage Databricks notebooks programmatically. Use when generating ingestion code, creating ETL notebooks, executing Databricks workflows, or when user mentions notebook creation, job automation, or data pipeline implementation in Databricks. Handles notebook generation, execution, and results retrieval.
version: 1.0.0
---

# Databricks Notebook Manager Skill

## Overview

This skill enables programmatic creation and management of Databricks notebooks for data ingestion, transformation, and ETL workflows. It generates notebook code templates, manages notebook execution, and integrates with Unity Catalog.

## Use Cases

- Generate data ingestion notebooks from specifications
- Create ETL/ELT transformation pipelines
- Automate notebook creation for repetitive tasks
- Execute notebooks and monitor status
- Retrieve notebook outputs and results

## Notebook Code Templates

### 1. Basic Data Ingestion from Azure Blob

```python
# Databricks notebook source
# MAGIC %md
# MAGIC # Data Ingestion: Customer Sales Data
# MAGIC
# MAGIC **Source**: Azure Blob Storage
# MAGIC **Target**: Unity Catalog - main.sales.customer_revenue
# MAGIC **Format**: Parquet

# COMMAND ----------

# Configure Azure Blob Storage access
storage_account = "yourstorageaccount"
container = "sales-data"
blob_path = "2024/customer_sales.parquet"

# Set up authentication
spark.conf.set(
    f"fs.azure.account.key.{storage_account}.dfs.core.windows.net",
    dbutils.secrets.get(scope="azure-storage", key="account-key")
)

# COMMAND ----------

# Read data from Azure Blob
source_path = f"abfss://{container}@{storage_account}.dfs.core.windows.net/{blob_path}"

df = spark.read.format("parquet").load(source_path)

print(f"Loaded {df.count()} rows with {len(df.columns)} columns")
df.printSchema()

# COMMAND ----------

# Data transformations
from pyspark.sql.functions import col, current_timestamp

df_transformed = (df
    .filter(col("revenue").isNotNull())  # Remove nulls
    .dropDuplicates(["customer_id", "transaction_id"])  # Deduplicate
    .withColumn("ingestion_timestamp", current_timestamp())
)

print(f"After transformations: {df_transformed.count()} rows")

# COMMAND ----------

# Write to Unity Catalog
target_table = "main.sales.customer_revenue"

(df_transformed.write
    .format("delta")
    .mode("append")  # or "overwrite"
    .option("mergeSchema", "true")
    .saveAsTable(target_table)
)

print(f"Data written to {target_table}")

# COMMAND ----------

# Verify ingestion
result_count = spark.table(target_table).count()
print(f"Table {target_table} now has {result_count} rows")

# Show sample
spark.table(target_table).show(5)
```

### 2. CSV Ingestion with Schema Inference

```python
# Databricks notebook source

# COMMAND ----------

# Read CSV with schema inference
source_path = "abfss://container@account.dfs.core.windows.net/data.csv"

df = (spark.read
    .format("csv")
    .option("header", "true")
    .option("inferSchema", "true")
    .option("dateFormat", "yyyy-MM-dd")
    .load(source_path)
)

# COMMAND ----------

# Clean column names (remove spaces, special chars)
from pyspark.sql.functions import col

for old_col in df.columns:
    new_col = old_col.strip().replace(" ", "_").replace("-", "_").lower()
    df = df.withColumnRenamed(old_col, new_col)

# COMMAND ----------

# Write to Unity Catalog with partitioning
(df.write
    .format("delta")
    .mode("overwrite")
    .partitionBy("date")  # Partition by date column
    .option("overwriteSchema", "true")
    .saveAsTable("main.bronze.raw_data")
)
```

### 3. Incremental Load Pattern

```python
# Databricks notebook source

# COMMAND ----------

from delta.tables import DeltaTable
from pyspark.sql.functions import col, current_timestamp

# Read new data
new_data_path = "abfss://container@account.dfs.core.windows.net/incremental/"
df_new = spark.read.format("parquet").load(new_data_path)

# Add metadata
df_new = df_new.withColumn("load_timestamp", current_timestamp())

# COMMAND ----------

# Target table
target_table = "main.sales.transactions"

# Check if table exists
if spark.catalog.tableExists(target_table):
    # Merge (upsert) new data
    delta_table = DeltaTable.forName(spark, target_table)

    (delta_table.alias("target")
        .merge(
            df_new.alias("source"),
            "target.transaction_id = source.transaction_id"
        )
        .whenMatchedUpdateAll()
        .whenNotMatchedInsertAll()
        .execute()
    )

    print(f"Merged data into {target_table}")
else:
    # Create new table
    (df_new.write
        .format("delta")
        .mode("overwrite")
        .saveAsTable(target_table)
    )

    print(f"Created new table {target_table}")

# COMMAND ----------

# Optimize table
spark.sql(f"OPTIMIZE {target_table}")
spark.sql(f"VACUUM {target_table} RETAIN 168 HOURS")  # 7 days

print("Table optimized")
```

### 4. Data Quality Validation Notebook

```python
# Databricks notebook source

# COMMAND ----------

from pyspark.sql.functions import count, when, col

# COMMAND ----------

# Define data quality checks
target_table = "main.sales.customer_revenue"
df = spark.table(target_table)

# COMMAND ----------

# Check 1: No nulls in key columns
null_check = df.select(
    [count(when(col(c).isNull(), c)).alias(c) for c in ["customer_id", "revenue"]]
).collect()[0]

print("Null counts:")
for col_name, null_count in null_check.asDict().items():
    print(f"  {col_name}: {null_count}")
    assert null_count == 0, f"Found {null_count} nulls in {col_name}"

# COMMAND ----------

# Check 2: No duplicates

duplicate_count = (df
    .groupBy("customer_id", "transaction_id")
    .agg(count("*").alias("count"))
    .filter(col("count") > 1)
    .count()
)

print(f"Duplicate records: {duplicate_count}")
assert duplicate_count == 0, f"Found {duplicate_count} duplicates"

# COMMAND ----------

# Check 3: Date range validation
from pyspark.sql.functions import min, max, datediff

date_stats = df.select(
    min("date").alias("min_date"),
    max("date").alias("max_date")
).collect()[0]

print(f"Date range: {date_stats['min_date']} to {date_stats['max_date']}")

# COMMAND ----------

# All checks passed
print("✓ All data quality checks passed")
```

### 5. Parameterized Notebook with Widgets

```python
# Databricks notebook source

# COMMAND ----------

# Define notebook widgets for parameterization
dbutils.widgets.text("date", "2024-01-01", "Processing Date")
dbutils.widgets.dropdown("mode", "append", ["append", "overwrite"], "Write Mode")
dbutils.widgets.text("table_name", "main.sales.daily_summary", "Target Table")

# Get widget values
processing_date = dbutils.widgets.get("date")
write_mode = dbutils.widgets.get("mode")
target_table = dbutils.widgets.get("table_name")

print(f"Parameters: date={processing_date}, mode={write_mode}, table={target_table}")

# COMMAND ----------

# Read data for specific date
source_path = f"abfss://container@account.dfs.core.windows.net/data/date={processing_date}/"

df = spark.read.format("parquet").load(source_path)
print(f"Loaded {df.count()} rows for {processing_date}")

# COMMAND ----------

# Apply transformations
from pyspark.sql.functions import col, lit, current_timestamp

df_transformed = (df
    .withColumn("processing_date", lit(processing_date))
    .withColumn("load_timestamp", current_timestamp())
)

# COMMAND ----------

# Write to target table
(df_transformed.write
    .format("delta")
    .mode(write_mode)
    .saveAsTable(target_table)
)

print(f"Data written to {target_table} in {write_mode} mode")
```

## Notebook Generation Pattern

```python
def generate_ingestion_notebook(spec: dict) -> str:
    """
    Generate Databricks notebook code from ingestion spec.

    Args:
        spec: Dataset specification dictionary

    Returns:
        Notebook code as string (Databricks notebook format)
    """
    source_type = spec['source']['type']
    source_location = spec['source']['location']
    target_table = spec['target']['table']
    format_type = spec['metadata']['format']

    notebook_code = f"""# Databricks notebook source
# MAGIC %md
# MAGIC # Data Ingestion: {spec.get('title', 'Dataset')}
# MAGIC
# MAGIC **Source**: {source_location}
# MAGIC **Target**: {target_table}
# MAGIC **Format**: {format_type}

# COMMAND ----------

# Read source data
source_path = "{source_location}"

df = spark.read.format("{format_type}").load(source_path)

print(f"Loaded {{df.count()}} rows")
df.printSchema()

# COMMAND ----------

# Apply transformations
"""

    # Add transformations based on recommendations
    if 'transformations' in spec:
        for transform in spec['transformations']:
            if "deduplicate" in transform.lower():
                key_cols = spec.get('schema', {}).get('key_columns', ['id'])
                notebook_code += f"\ndf = df.dropDuplicates({key_cols})"
            elif "remove null" in transform.lower():
                notebook_code += "\ndf = df.na.drop()"

    notebook_code += f"""

# COMMAND ----------

# Write to Unity Catalog
df.write.format("delta").mode("append").saveAsTable("{target_table}")

print(f"Data written to {target_table}")
"""

    return notebook_code
```

## Notebook Execution

To execute notebooks programmatically, you would typically use the Databricks REST API or SDK:

```python
from databricks.sdk import WorkspaceClient

client = WorkspaceClient()

# Create or update notebook
client.workspace.import_(
    path="/Users/user@example.com/ingestion_notebook",
    content=notebook_code,
    language="PYTHON",
    format="SOURCE",
    overwrite=True
)

# Run notebook as a job
# notebook_params maps to widget parameters defined in the notebook (see template #5)
# The "date" key corresponds to dbutils.widgets.text("date", ...) in the notebook
job_run = client.jobs.run_now(
    job_id=job_id,  # Existing job ID
    notebook_params={"date": "2024-01-01"}
)

print(f"Job run ID: {job_run.run_id}")
```

## Best Practices

1. **Parameterize**: Use widgets for notebook parameters
2. **Modular**: Break complex logic into multiple notebooks
3. **Error Handling**: Add try/except blocks for robustness
4. **Logging**: Print progress and status messages
5. **Idempotent**: Design for safe re-execution
6. **Optimize**: Add OPTIMIZE and VACUUM commands

## Integration with Architecture Swarm

When generating notebooks:
1. Create notebook code based on approved ingestion spec
2. Submit generated code to Architecture Swarm for review
3. Upon approval, create notebook in Databricks workspace
4. Execute and validate results
5. Report completion status

## Security Considerations

- Use Databricks Secrets for credentials
- Never hardcode access keys in notebooks
- Apply least-privilege access to Unity Catalog
- Enable audit logging for notebook execution
- Use service principals for production jobs
