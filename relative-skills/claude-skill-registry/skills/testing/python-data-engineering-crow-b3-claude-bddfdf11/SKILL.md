---
name: python-data-engineering
description: Comprehensive Python data engineering patterns for AWS Data Lake, including PySpark, Pandas, Apache Airflow, AWS Glue, ETL pipelines, data quality, schema management, performance optimization, FastAPI services, streaming with Kafka/Kinesis, data validation with Great Expectations, testing strategies, error handling, logging, and production deployment on AWS EMR and Glue.
---

# Python Data Engineering Skill

## Purpose

Production-ready Python data engineering patterns for building scalable, reliable data pipelines on AWS Data Lake infrastructure. Covers PySpark, Pandas, Airflow, Glue, FastAPI, and modern data engineering best practices.

## When to Use This Skill

Auto-activates when working with:
- Python data pipeline development
- PySpark applications
- Apache Airflow DAGs
- AWS Glue jobs
- Pandas data transformations
- ETL/ELT processes
- Data quality validation
- FastAPI data services
- Streaming data processing

## Core Principles

### 1. Layered Architecture
```
API/Service Layer (FastAPI) → Orchestration (Airflow) → Processing (PySpark/Pandas) → Storage (S3)
```

### 2. Data Lake Zones (Medallion)
- **Bronze**: Raw, immutable data from sources
- **Silver**: Cleaned, validated, deduplicated
- **Gold**: Business-ready, aggregated, optimized

### 3. Schema Management
- Use Pydantic for data validation
- Maintain schema registry (AWS Glue Data Catalog)
- Version schemas with backward compatibility
- Validate early, fail fast

### 4. Error Handling & Resilience
- Idempotent operations
- Retry logic with exponential backoff
- Dead letter queues for failed records
- Comprehensive logging and monitoring

## Quick Start Examples

### FastAPI Data Service

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, Field, validator
from typing import List, Optional
import boto3
from datetime import datetime

app = FastAPI(title="Data Lake API")

class DataRequest(BaseModel):
    dataset_name: str = Field(..., regex="^[a-z0-9_]+$")
    partition_date: datetime
    limit: Optional[int] = Field(1000, gt=0, le=10000)

    @validator('partition_date')
    def validate_date(cls, v):
        if v > datetime.now():
            raise ValueError('partition_date cannot be in the future')
        return v

@app.get("/datasets/{dataset_name}/data")
async def get_dataset_data(dataset_name: str, request: DataRequest = Depends()):
    """Query data from S3 Data Lake with Athena."""
    try:
        athena = boto3.client('athena')

        query = f"""
        SELECT * FROM {dataset_name}
        WHERE partition_date = '{request.partition_date.strftime('%Y-%m-%d')}'
        LIMIT {request.limit}
        """

        response = athena.start_query_execution(
            QueryString=query,
            QueryExecutionContext={'Database': 'data_lake'},
            ResultConfiguration={'OutputLocation': 's3://query-results/'}
        )

        return {"query_execution_id": response['QueryExecutionId']}
    except Exception as e:
        logging.error(f"Query failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
```

### PySpark ETL Job Structure

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, lit, current_timestamp
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
import logging

class DataLakeETL:
    def __init__(self, app_name: str):
        self.spark = (SparkSession.builder
            .appName(app_name)
            .config("spark.sql.adaptive.enabled", "true")
            .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
            .getOrCreate())

        self.logger = logging.getLogger(__name__)

    def read_bronze(self, path: str, schema: StructType):
        """Read from raw/bronze zone with schema enforcement."""
        return (self.spark.read
            .schema(schema)
            .option("mode", "PERMISSIVE")
            .option("columnNameOfCorruptRecord", "_corrupt_record")
            .parquet(path))

    def transform_to_silver(self, df):
        """Clean and validate data for silver zone."""
        return (df
            .filter(col("_corrupt_record").isNull())  # Remove corrupt records
            .dropDuplicates(["id"])  # Deduplicate
            .withColumn("processed_at", current_timestamp())
            .withColumn("is_valid",
                when(col("value").isNotNull() & (col("value") > 0), True)
                .otherwise(False))
            .filter(col("is_valid")))  # Only valid records

    def write_silver(self, df, path: str, partition_cols: List[str]):
        """Write to processed/silver zone with partitioning."""
        (df.write
            .mode("overwrite")
            .partitionBy(*partition_cols)
            .parquet(path))

        self.logger.info(f"Written {df.count()} records to {path}")
```

### Airflow DAG Pattern

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,
}

with DAG(
    'data_lake_bronze_to_silver',
    default_args=default_args,
    description='Process raw data to silver zone',
    schedule_interval='0 2 * * *',  # Daily at 2 AM
    catchup=False,
    tags=['data-lake', 'etl', 'silver'],
) as dag:

    # Wait for source data
    wait_for_data = S3KeySensor(
        task_id='wait_for_bronze_data',
        bucket_name='data-lake-bronze',
        bucket_key='events/{{ ds }}/*.parquet',
        timeout=3600,
        poke_interval=300,
    )

    # Run Glue job
    process_data = GlueJobOperator(
        task_id='bronze_to_silver',
        job_name='bronze-to-silver-etl',
        script_args={
            '--input_path': 's3://data-lake-bronze/events/{{ ds }}/',
            '--output_path': 's3://data-lake-silver/events/',
            '--partition_date': '{{ ds }}',
        },
    )

    # Data quality checks
    def validate_silver_data(**context):
        """Validate silver zone data quality."""
        import boto3
        athena = boto3.client('athena')

        # Row count check
        query = f"""
        SELECT COUNT(*) as row_count
        FROM silver.events
        WHERE partition_date = '{context['ds']}'
        """
        # Execute and validate (simplified)
        # Add full implementation with quality checks

    quality_check = PythonOperator(
        task_id='data_quality_check',
        python_callable=validate_silver_data,
    )

    wait_for_data >> process_data >> quality_check
```

## Directory Structure

```
services/python/
├── data-ingestion/
│   ├── app/
│   │   ├── api/         # FastAPI routes
│   │   ├── services/    # Business logic
│   │   └── models/      # Pydantic models
│   ├── tests/
│   ├── Dockerfile
│   └── requirements.txt
├── etl-pipeline/
│   ├── jobs/            # PySpark jobs
│   ├── glue/            # Glue-specific code
│   ├── tests/
│   └── requirements.txt
└── airflow/
    ├── dags/            # Airflow DAGs
    ├── plugins/         # Custom operators
    └── requirements.txt
```

## Resource Files

For detailed information on specific topics:

### [resources/pyspark-patterns.md](resources/pyspark-patterns.md)
- PySpark job structure and optimization
- Window functions and aggregations
- Join strategies and optimization
- Partition management
- Performance tuning
- Catalyst optimizer usage

### [resources/airflow-best-practices.md](resources/airflow-best-practices.md)
- DAG design patterns
- Task dependencies and sensors
- Dynamic DAG generation
- XComs and task communication
- Backfilling strategies
- Error handling and retries

### [resources/aws-glue-integration.md](resources/aws-glue-integration.md)
- Glue job development
- Glue Data Catalog usage
- DynamicFrames vs DataFrames
- Bookmarks for incremental processing
- Cost optimization
- Security and IAM

### [resources/data-quality-validation.md](resources/data-quality-validation.md)
- Great Expectations integration
- Schema validation
- Data profiling
- Anomaly detection
- SLA monitoring
- Quality metrics

### [resources/fastapi-data-services.md](resources/fastapi-data-services.md)
- API design for data services
- Authentication and authorization
- Query optimization
- Pagination and filtering
- Async processing
- Caching strategies

### [resources/streaming-processing.md](resources/streaming-processing.md)
- Kafka consumer patterns
- Kinesis integration
- Structured Streaming (PySpark)
- Exactly-once semantics
- Windowing and watermarks
- State management

### [resources/testing-strategies.md](resources/testing-strategies.md)
- Unit testing PySpark
- Integration testing pipelines
- Data quality tests
- Mocking AWS services
- Test data generation
- CI/CD for data pipelines

### [resources/error-handling-logging.md](resources/error-handling-logging.md)
- Structured logging
- Error handling patterns
- Retry logic
- Dead letter queues
- Monitoring with CloudWatch
- Alerting strategies

### [resources/performance-optimization.md](resources/performance-optimization.md)
- Spark tuning parameters
- Partition optimization
- Broadcast joins
- Caching strategies
- S3 read/write optimization
- Cost optimization

### [resources/schema-management.md](resources/schema-management.md)
- Schema evolution strategies
- Avro, Parquet, ORC formats
- Glue Data Catalog management
- Backward/forward compatibility
- Schema registry patterns

## Common Patterns

### 1. Idempotent ETL Processing
```python
def process_partition(partition_date: str, force_reprocess: bool = False):
    """Process data idempotently."""
    output_path = f"s3://silver/{partition_date}/"

    # Check if already processed
    if not force_reprocess and path_exists(output_path):
        logger.info(f"Partition {partition_date} already processed, skipping")
        return

    # Process data
    df = read_bronze(partition_date)
    df_clean = transform_to_silver(df)

    # Atomic write (write to temp, then move)
    temp_path = f"{output_path}_temp/"
    df_clean.write.parquet(temp_path)

    # Move to final location (atomic on S3)
    move(temp_path, output_path)
```

### 2. Error Handling with DLQ
```python
def process_record_safe(record):
    """Process with error handling and DLQ."""
    try:
        # Validation
        validated = validate_schema(record)

        # Processing
        result = transform(validated)

        return ("success", result)
    except ValidationError as e:
        logger.warning(f"Validation failed: {e}")
        return ("dlq", {"record": record, "error": str(e), "type": "validation"})
    except Exception as e:
        logger.error(f"Processing failed: {e}")
        return ("dlq", {"record": record, "error": str(e), "type": "processing"})

# Process batch
results = df.rdd.map(process_record_safe).collect()
success_records = [r for status, r in results if status == "success"]
dlq_records = [r for status, r in results if status == "dlq"]

# Write DLQ records for investigation
if dlq_records:
    write_to_dlq(dlq_records)
```

## Best Practices Checklist

- Use Pydantic for data validation at API layer
- Implement schema enforcement in PySpark reads
- Partition data by date for optimal query performance
- Use broadcast joins for small dimension tables
- Cache intermediate DataFrames when reused
- Write idempotent processing logic
- Implement dead letter queues for failed records
- Use structured logging with correlation IDs
- Monitor data quality metrics continuously
- Optimize Spark configurations for workload
- Use S3 partitioning aligned with query patterns
- Implement incremental processing with bookmarks
- Test with realistic data volumes
- Use type hints throughout Python code
- Follow PEP 8 style guidelines

## Tools & Libraries

- **PySpark**: 3.5+
- **Pandas**: 2.0+ (for small-medium datasets)
- **FastAPI**: 0.100+ (async support)
- **Pydantic**: 2.0+ (validation)
- **Apache Airflow**: 2.7+
- **Great Expectations**: Data quality
- **boto3**: AWS SDK for Python
- **pytest**: Testing framework
- **black**: Code formatting
- **mypy**: Static type checking

## Monitoring & Observability

```python
import logging
from pythonjsonlogger import jsonlogger

# Structured logging
logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    '%(timestamp)s %(level)s %(name)s %(message)s %(correlation_id)s'
)
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)

# Usage with context
def process_with_context(data_id: str):
    with log_context(correlation_id=data_id):
        logger.info("Processing started", extra={"record_count": len(data)})
        # Process data
        logger.info("Processing completed")
```

---

**Status**: Production-Ready
**Last Updated**: 2025-11-04
**Follows**: Anthropic 500-line rule, progressive disclosure pattern
