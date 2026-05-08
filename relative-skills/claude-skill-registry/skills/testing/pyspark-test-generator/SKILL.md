---
name: pyspark-test-generator
description: Generate comprehensive PySpark-based data quality validation tests for Databricks tables. Use when creating automated tests for data completeness, accuracy, consistency, and conformity, or when user mentions test generation, data validation, quality monitoring, or PySpark test frameworks.
version: 1.0.0
---

# PySpark Test Generator Skill

## Overview

This skill enables AI agents to automatically generate comprehensive PySpark-based data quality validation tests for Databricks tables. It creates executable test suites that validate data completeness, accuracy, consistency, and conformity.

## Purpose

- Generate PySpark validation tests based on data profiling results
- Create reusable test frameworks for data quality monitoring
- Implement custom validation rules using PySpark SQL and DataFrame operations
- Produce detailed test reports with pass/fail metrics
- Support continuous data quality monitoring in production pipelines

## When to Use This Skill

Use this skill when you need to:
- Create automated data quality tests after ingestion
- Validate data against business rules and constraints
- Monitor data quality over time with repeatable tests
- Generate test code from profiling metadata
- Implement custom validation logic beyond simple assertions

## Test Categories

### 1. Completeness Tests

Validate that required data is present and non-null.

**Example: Check for null values**
```python
from pyspark.sql import functions as F

def test_completeness_customer_id(spark, table_name):
    """
    Test: customer_id column should have no null values
    Severity: CRITICAL
    """
    df = spark.table(table_name)
    total_rows = df.count()
    null_count = df.filter(F.col("customer_id").isNull()).count()

    null_percentage = (null_count / total_rows * 100) if total_rows > 0 else 0

    result = {
        "test_name": "completeness_customer_id",
        "column": "customer_id",
        "passed": null_count == 0,
        "total_rows": total_rows,
        "null_count": null_count,
        "null_percentage": null_percentage,
        "severity": "CRITICAL",
        "message": f"Found {null_count} null values ({null_percentage:.2f}%)" if null_count > 0
                   else "No null values found"
    }

    return result
```

### 2. Format/Pattern Tests

Validate data conforms to expected patterns (email, phone, UUID, etc.).

**Example: Email format validation**
```python
def test_format_email(spark, table_name, column_name="email"):
    """
    Test: Email addresses should match valid email pattern
    Severity: HIGH
    """
    df = spark.table(table_name)

    # Email regex pattern
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

    total_rows = df.count()
    invalid_count = df.filter(
        ~F.col(column_name).rlike(email_pattern) & F.col(column_name).isNotNull()
    ).count()

    invalid_percentage = (invalid_count / total_rows * 100) if total_rows > 0 else 0

    result = {
        "test_name": f"format_{column_name}",
        "column": column_name,
        "passed": invalid_count == 0,
        "total_rows": total_rows,
        "invalid_count": invalid_count,
        "invalid_percentage": invalid_percentage,
        "severity": "HIGH",
        "message": f"Found {invalid_count} invalid email addresses ({invalid_percentage:.2f}%)"
                   if invalid_count > 0 else "All email addresses are valid"
    }

    return result
```

### 3. Range/Boundary Tests

Validate numeric values fall within expected ranges.

**Example: Age range validation**
```python
def test_range_age(spark, table_name, min_value=0, max_value=120):
    """
    Test: Age should be between 0 and 120
    Severity: MEDIUM
    """
    df = spark.table(table_name)

    total_rows = df.count()
    out_of_range = df.filter(
        (F.col("age") < min_value) | (F.col("age") > max_value)
    ).count()

    out_of_range_percentage = (out_of_range / total_rows * 100) if total_rows > 0 else 0

    # Get min and max actual values
    stats = df.agg(
        F.min("age").alias("min_age"),
        F.max("age").alias("max_age")
    ).collect()[0]

    result = {
        "test_name": "range_age",
        "column": "age",
        "passed": out_of_range == 0,
        "total_rows": total_rows,
        "out_of_range_count": out_of_range,
        "out_of_range_percentage": out_of_range_percentage,
        "expected_range": f"{min_value}-{max_value}",
        "actual_range": f"{stats['min_age']}-{stats['max_age']}",
        "severity": "MEDIUM",
        "message": f"Found {out_of_range} values outside range {min_value}-{max_value}"
                   if out_of_range > 0 else f"All values within range {min_value}-{max_value}"
    }

    return result
```

### 4. Uniqueness Tests

Validate columns that should have unique values (IDs, keys).

**Example: Primary key uniqueness**
```python
def test_uniqueness_customer_id(spark, table_name):
    """
    Test: customer_id should be unique
    Severity: CRITICAL
    """
    df = spark.table(table_name)

    total_rows = df.count()
    distinct_count = df.select("customer_id").distinct().count()
    duplicate_count = total_rows - distinct_count

    duplicate_percentage = (duplicate_count / total_rows * 100) if total_rows > 0 else 0

    result = {
        "test_name": "uniqueness_customer_id",
        "column": "customer_id",
        "passed": duplicate_count == 0,
        "total_rows": total_rows,
        "distinct_count": distinct_count,
        "duplicate_count": duplicate_count,
        "duplicate_percentage": duplicate_percentage,
        "severity": "CRITICAL",
        "message": f"Found {duplicate_count} duplicate values ({duplicate_percentage:.2f}%)"
                   if duplicate_count > 0 else "All values are unique"
    }

    return result
```

### 5. Referential Integrity Tests

Validate foreign key relationships between tables.

**Example: Foreign key validation**
```python
def test_referential_integrity_customer_id(spark, child_table, parent_table):
    """
    Test: All customer_ids in orders should exist in customers table
    Severity: HIGH
    """
    child_df = spark.table(child_table)
    parent_df = spark.table(parent_table)

    # Left anti join to find orphaned records
    orphaned = child_df.join(
        parent_df,
        child_df.customer_id == parent_df.customer_id,
        "left_anti"
    )

    total_child_rows = child_df.count()
    orphaned_count = orphaned.count()
    orphaned_percentage = (orphaned_count / total_child_rows * 100) if total_child_rows > 0 else 0

    result = {
        "test_name": "referential_integrity_customer_id",
        "column": "customer_id",
        "child_table": child_table,
        "parent_table": parent_table,
        "passed": orphaned_count == 0,
        "total_rows": total_child_rows,
        "orphaned_count": orphaned_count,
        "orphaned_percentage": orphaned_percentage,
        "severity": "HIGH",
        "message": f"Found {orphaned_count} orphaned records ({orphaned_percentage:.2f}%)"
                   if orphaned_count > 0 else "All foreign keys are valid"
    }

    return result
```

### 6. Statistical Tests

Validate data distributions and statistical properties.

**Example: Standard deviation check**
```python
def test_statistical_amount(spark, table_name, column_name="amount"):
    """
    Test: Amount should be within 3 standard deviations of mean
    Severity: MEDIUM
    """
    df = spark.table(table_name)

    # Calculate statistics
    stats = df.select(
        F.mean(column_name).alias("mean"),
        F.stddev(column_name).alias("stddev")
    ).collect()[0]

    mean_val = stats["mean"]
    stddev_val = stats["stddev"]

    # Find outliers (beyond 3 standard deviations)
    lower_bound = mean_val - (3 * stddev_val)
    upper_bound = mean_val + (3 * stddev_val)

    total_rows = df.count()
    outliers = df.filter(
        (F.col(column_name) < lower_bound) | (F.col(column_name) > upper_bound)
    ).count()

    outlier_percentage = (outliers / total_rows * 100) if total_rows > 0 else 0

    result = {
        "test_name": f"statistical_{column_name}",
        "column": column_name,
        "passed": outlier_percentage < 1.0,  # Pass if less than 1% outliers
        "total_rows": total_rows,
        "outlier_count": outliers,
        "outlier_percentage": outlier_percentage,
        "mean": mean_val,
        "stddev": stddev_val,
        "bounds": f"{lower_bound:.2f} to {upper_bound:.2f}",
        "severity": "MEDIUM",
        "message": f"Found {outliers} outliers ({outlier_percentage:.2f}%)"
                   if outliers > 0 else "Statistical distribution is normal"
    }

    return result
```

### 7. Custom Business Rule Tests

Validate domain-specific business logic.

**Example: Order total validation**
```python
def test_business_rule_order_total(spark, table_name):
    """
    Test: Order total should equal sum of line items
    Severity: HIGH
    """
    df = spark.table(table_name)

    # Calculate discrepancies
    with_calculated = df.withColumn(
        "calculated_total",
        F.col("quantity") * F.col("unit_price")
    ).withColumn(
        "discrepancy",
        F.abs(F.col("order_total") - F.col("calculated_total"))
    )

    total_rows = with_calculated.count()
    discrepancies = with_calculated.filter(F.col("discrepancy") > 0.01).count()  # Allow 1 cent rounding

    discrepancy_percentage = (discrepancies / total_rows * 100) if total_rows > 0 else 0

    result = {
        "test_name": "business_rule_order_total",
        "columns": ["order_total", "quantity", "unit_price"],
        "passed": discrepancies == 0,
        "total_rows": total_rows,
        "discrepancy_count": discrepancies,
        "discrepancy_percentage": discrepancy_percentage,
        "severity": "HIGH",
        "message": f"Found {discrepancies} orders with incorrect totals ({discrepancy_percentage:.2f}%)"
                   if discrepancies > 0 else "All order totals are correct"
    }

    return result
```

## Complete Test Suite Generator

Generate a complete test suite from profiling results:

```python
from datetime import datetime

def generate_test_suite(table_name, profile_results):
    """
    Generate complete test suite based on profiling results.

    Args:
        table_name: Full table name (catalog.schema.table)
        profile_results: Dictionary from data-profiler skill

    Returns:
        Complete test suite as Python code string
    """

    tests = []

    for column_name, column_profile in profile_results["columns"].items():
        # Completeness test for non-nullable columns
        if not column_profile.get("nullable", True):
            tests.append(f"""
def test_completeness_{column_name}(spark):
    '''Test: {column_name} should have no null values'''
    df = spark.table("{table_name}")
    null_count = df.filter(F.col("{column_name}").isNull()).count()
    return {{"test": "completeness_{column_name}", "passed": null_count == 0, "null_count": null_count}}
""")

        # Pattern tests based on detected patterns
        patterns = column_profile.get("patterns", [])
        if "EMAIL" in patterns:
            tests.append(f"""
def test_format_{column_name}_email(spark):
    '''Test: {column_name} should contain valid email addresses'''
    df = spark.table("{table_name}")
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{{2,}}$'
    invalid = df.filter(~F.col("{column_name}").rlike(email_pattern) & F.col("{column_name}").isNotNull()).count()
    return {{"test": "format_{column_name}_email", "passed": invalid == 0, "invalid_count": invalid}}
""")

        # Uniqueness test for primary keys
        if column_profile.get("is_unique", False):
            tests.append(f"""
def test_uniqueness_{column_name}(spark):
    '''Test: {column_name} should contain unique values'''
    df = spark.table("{table_name}")
    total = df.count()
    distinct = df.select("{column_name}").distinct().count()
    return {{"test": "uniqueness_{column_name}", "passed": total == distinct, "duplicates": total - distinct}}
""")

        # Range test for numeric columns
        if column_profile.get("data_type") in ["int", "float", "double", "decimal"]:
            min_val = column_profile.get("min", 0)
            max_val = column_profile.get("max", 0)
            # Add 10% buffer
            buffer = (max_val - min_val) * 0.1
            tests.append(f"""
def test_range_{column_name}(spark):
    '''Test: {column_name} should be within expected range'''
    df = spark.table("{table_name}")
    out_of_range = df.filter((F.col("{column_name}") < {min_val - buffer}) | (F.col("{column_name}") > {max_val + buffer})).count()
    return {{"test": "range_{column_name}", "passed": out_of_range == 0, "out_of_range": out_of_range}}
""")

    # Generate complete test file
    test_suite = f'''
"""
Auto-generated Data Quality Tests for {table_name}
Generated: {datetime.now().isoformat()}

This test suite validates data quality for the {table_name} table.
Tests are generated based on data profiling results.
"""

from pyspark.sql import SparkSession, functions as F
from datetime import datetime
import json

# Test functions
{"".join(tests)}

def run_all_tests(spark):
    """Run all data quality tests and return results."""
    results = []

    test_functions = [
        {", ".join([f"test_{t.split('def test_')[1].split('(')[0]}" for t in tests if t.strip()])}
    ]

    for test_func in test_functions:
        try:
            result = test_func(spark)
            result["status"] = "SUCCESS"
            results.append(result)
        except Exception as e:
            results.append({{
                "test": test_func.__name__,
                "status": "ERROR",
                "error": str(e)
            }})

    return results

def generate_report(results):
    """Generate test report summary."""
    total_tests = len(results)
    passed_tests = sum(1 for r in results if r.get("passed", False))
    failed_tests = total_tests - passed_tests

    report = {{
        "table": "{table_name}",
        "timestamp": datetime.now().isoformat(),
        "total_tests": total_tests,
        "passed": passed_tests,
        "failed": failed_tests,
        "pass_rate": (passed_tests / total_tests * 100) if total_tests > 0 else 0,
        "results": results
    }}

    return report

if __name__ == "__main__":
    spark = SparkSession.builder.appName("DataQualityTests").getOrCreate()
    results = run_all_tests(spark)
    report = generate_report(results)

    print(json.dumps(report, indent=2))
'''

    return test_suite
```

## Usage Example

```python
# 1. Get profiling results
from data_profiler import profile_table
profile = profile_table("main.bronze.customers")

# 2. Generate test suite
test_suite_code = generate_test_suite("main.bronze.customers", profile)

# 3. Save to file
with open("tests/test_customers_quality.py", "w") as f:
    f.write(test_suite_code)

# 4. Run tests
results = run_all_tests(spark)

# 5. Generate report
report = generate_report(results)
print(f"Pass rate: {report['pass_rate']:.1f}%")
```

## Output Format

Test results are returned in a standardized format:

```python
{
    "table": "main.bronze.customers",
    "timestamp": "2025-12-17T10:30:00",
    "total_tests": 15,
    "passed": 13,
    "failed": 2,
    "pass_rate": 86.7,
    "results": [
        {
            "test_name": "completeness_customer_id",
            "column": "customer_id",
            "passed": True,
            "severity": "CRITICAL",
            "message": "No null values found"
        },
        {
            "test_name": "format_email",
            "column": "email",
            "passed": False,
            "invalid_count": 23,
            "severity": "HIGH",
            "message": "Found 23 invalid email addresses (0.23%)"
        }
    ]
}
```

## Best Practices

1. **Test Severity**: Assign appropriate severity levels (CRITICAL, HIGH, MEDIUM, LOW)
2. **Tolerance Levels**: Allow small percentages of failures for non-critical tests
3. **Performance**: Use sampling for large tables during development
4. **Incremental Testing**: Test only new data in incremental scenarios
5. **Alerting**: Integrate with monitoring systems for failed tests

## Notes

- Tests run in Databricks environment with PySpark
- Generated code is production-ready and executable
- Tests can be scheduled as Databricks jobs
- Results can be stored in Delta tables for historical tracking
- Compatible with Databricks SQL and Unity Catalog
