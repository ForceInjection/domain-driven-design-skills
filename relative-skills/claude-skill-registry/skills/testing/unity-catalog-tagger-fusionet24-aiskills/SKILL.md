---
name: unity-catalog-tagger
description: Manage Unity Catalog metadata tags for data governance and classification. Use when applying tags to tables and columns, classifying data sensitivity (PII, PHI), marking data quality attributes, or when user mentions Unity Catalog tagging, metadata management, data governance, or compliance workflows.
version: 1.0.0
---

# Unity Catalog Tagger Skill

## Overview

This skill enables AI agents to manage Unity Catalog metadata tags for data governance, classification, and discovery. Tags can be applied to tables, columns, and other catalog objects to indicate data types, sensitivity levels, quality metrics, and compliance requirements.

## Purpose

- Apply metadata tags to Unity Catalog objects (tables, columns, schemas)
- Classify data sensitivity (PII, PHI, confidential, public)
- Mark data quality attributes (validated, requires_review, low_quality)
- Add business metadata (domain, owner, description)
- Support compliance and governance workflows

## When to Use This Skill

Use this skill when you need to:
- Tag columns with PII indicators (email, phone, SSN, credit card)
- Mark data quality status on columns or tables
- Apply business classifications (finance, marketing, operations)
- Add governance tags (GDPR, HIPAA, SOX compliance)
- Document data lineage and ownership

## Capabilities

### 1. Tag Column with Metadata

Apply tags to specific columns to indicate their purpose, sensitivity, or quality.

**Common Tag Types:**
- **Sensitivity**: `PII`, `PHI`, `CONFIDENTIAL`, `PUBLIC`, `INTERNAL`
- **Data Type**: `EMAIL`, `PHONE`, `SSN`, `CREDIT_CARD`, `IP_ADDRESS`, `UUID`
- **Quality**: `VALIDATED`, `REQUIRES_REVIEW`, `LOW_QUALITY`, `HIGH_QUALITY`
- **Business**: `CUSTOMER_DATA`, `FINANCIAL`, `MARKETING`, `OPERATIONAL`
- **Compliance**: `GDPR`, `HIPAA`, `SOX`, `PCI_DSS`

**Example: Tag email column as PII**
```python
from databricks.sdk import WorkspaceClient

w = WorkspaceClient()

# Apply PII tag to email column
w.catalog.update_column(
    full_name="main.bronze.customers.email",
    comment="Customer email address",
    tags={"sensitivity": "PII", "data_type": "EMAIL", "quality": "VALIDATED"}
)
```

### 2. Tag Table with Metadata

Apply tags to entire tables for high-level classification.

**Example: Tag table as containing PII**
```python
# Apply tags to table
w.catalog.update_table(
    full_name="main.bronze.customers",
    comment="Customer master data",
    tags={
        "contains_pii": "true",
        "domain": "customer",
        "owner": "data_platform_team",
        "quality_score": "95",
        "last_validated": "2025-12-17"
    }
)
```

### 3. Bulk Tag Columns

Tag multiple columns at once based on profiling results.

**Example: Tag multiple columns after profiling**
```python
# Profile results indicate which columns need tags
profile_results = {
    "email": {"pattern": "EMAIL", "contains_pii": True},
    "phone": {"pattern": "PHONE", "contains_pii": True},
    "customer_id": {"pattern": "UUID", "is_key": True},
    "purchase_amount": {"data_type": "CURRENCY", "quality": "high"}
}

# Apply tags based on profiling
for column_name, tags_info in profile_results.items():
    tags = {}

    if tags_info.get("contains_pii"):
        tags["sensitivity"] = "PII"

    if "pattern" in tags_info:
        tags["data_type"] = tags_info["pattern"]

    if tags_info.get("is_key"):
        tags["column_role"] = "PRIMARY_KEY"

    w.catalog.update_column(
        full_name=f"main.bronze.customers.{column_name}",
        tags=tags
    )
```

### 4. Add Column Comments

Add descriptive comments to columns for documentation.

**Example: Document column purpose**
```python
w.catalog.update_column(
    full_name="main.bronze.customers.customer_id",
    comment="Unique identifier for customer records. UUID format. Primary key.",
    tags={
        "data_type": "UUID",
        "column_role": "PRIMARY_KEY",
        "required": "true"
    }
)
```

### 5. Tag Schema

Apply organizational tags to schemas.

**Example: Tag schema for domain ownership**
```python
w.catalog.update_schema(
    full_name="main.bronze",
    comment="Bronze layer: Raw ingested data",
    tags={
        "layer": "bronze",
        "domain": "ingestion",
        "owner": "data_engineering",
        "retention_days": "90"
    }
)
```

## Integration with Data Quality Agent

The Data Quality Agent uses this skill to automatically tag columns based on validation results:

```python
# After running data quality tests
validation_results = {
    "email": {
        "test": "email_format_validation",
        "passed": True,
        "quality_score": 0.98
    },
    "phone": {
        "test": "phone_format_validation",
        "passed": True,
        "quality_score": 0.95
    },
    "age": {
        "test": "range_validation",
        "passed": False,
        "quality_score": 0.85,
        "issues": "5% of values outside valid range"
    }
}

# Apply quality tags
for column, result in validation_results.items():
    tags = {
        "quality_tested": "true",
        "last_test_date": "2025-12-17"
    }

    if result["passed"] and result["quality_score"] > 0.95:
        tags["quality_status"] = "HIGH_QUALITY"
        tags["validated"] = "true"
    elif result["quality_score"] > 0.85:
        tags["quality_status"] = "ACCEPTABLE"
    else:
        tags["quality_status"] = "REQUIRES_REVIEW"
        tags["quality_issues"] = result.get("issues", "Unknown")

    w.catalog.update_column(
        full_name=f"main.bronze.customers.{column}",
        tags=tags
    )
```

## Common Tagging Patterns

### Pattern 1: PII Detection and Tagging

```python
# Detect PII patterns from data profiler
pii_patterns = {
    "email": "EMAIL",
    "phone": "PHONE",
    "ssn": "SSN",
    "credit_card": "CREDIT_CARD"
}

for column, pattern in pii_patterns.items():
    w.catalog.update_column(
        full_name=f"{table_full_name}.{column}",
        tags={
            "sensitivity": "PII",
            "data_type": pattern,
            "requires_masking": "true",
            "compliance": "GDPR"
        }
    )
```

### Pattern 2: Data Quality Scoring

```python
# Apply quality score tags after validation
quality_results = run_data_quality_tests(table_name)

table_quality_score = sum(r["score"] for r in quality_results) / len(quality_results)

w.catalog.update_table(
    full_name=table_name,
    tags={
        "quality_score": str(int(table_quality_score * 100)),
        "quality_tests_run": str(len(quality_results)),
        "quality_tests_passed": str(sum(1 for r in quality_results if r["passed"])),
        "last_quality_check": datetime.now().isoformat()
    }
)
```

### Pattern 3: Business Domain Classification

```python
# Tag columns by business domain
business_domains = {
    "customer_id": "customer",
    "order_id": "sales",
    "product_id": "product",
    "payment_method": "finance"
}

for column, domain in business_domains.items():
    w.catalog.update_column(
        full_name=f"{table_full_name}.{column}",
        tags={
            "business_domain": domain,
            "owner": f"{domain}_team"
        }
    )
```

### Pattern 4: Compliance Tagging

```python
# Tag for regulatory compliance
compliance_columns = {
    "email": ["GDPR", "CCPA"],
    "health_info": ["HIPAA"],
    "financial_data": ["SOX", "PCI_DSS"]
}

for column, regulations in compliance_columns.items():
    w.catalog.update_column(
        full_name=f"{table_full_name}.{column}",
        tags={
            "compliance_required": ",".join(regulations),
            "requires_audit": "true",
            "retention_required": "true"
        }
    )
```

## Best Practices

1. **Consistent Naming**: Use standardized tag names across your organization
2. **Automation**: Tag automatically during ingestion and profiling
3. **Version Control**: Track tag changes in your lineage system
4. **Documentation**: Document what each tag means in your governance framework
5. **Regular Updates**: Re-validate and update quality tags periodically

## Tag Hierarchy Recommendations

```
Sensitivity Levels:
├── PUBLIC (no restrictions)
├── INTERNAL (company-only)
├── CONFIDENTIAL (restricted access)
├── PII (personal information)
└── PHI (protected health information)

Quality Levels:
├── HIGH_QUALITY (>95% validation pass)
├── ACCEPTABLE (85-95% validation pass)
├── REQUIRES_REVIEW (70-85% validation pass)
└── LOW_QUALITY (<70% validation pass)

Data Types:
├── Identifiers: UUID, ID, KEY
├── Contact: EMAIL, PHONE, ADDRESS
├── Financial: CURRENCY, CREDIT_CARD, ACCOUNT_NUMBER
├── Personal: SSN, DOB, NAME
└── Technical: IP_ADDRESS, URL, TIMESTAMP
```

## Error Handling

```python
from databricks.sdk.errors import ResourceDoesNotExist, PermissionDenied

try:
    w.catalog.update_column(
        full_name="main.bronze.customers.email",
        tags={"sensitivity": "PII"}
    )
except ResourceDoesNotExist:
    print("Column does not exist - check table and column names")
except PermissionDenied:
    print("Insufficient permissions to update catalog metadata")
except Exception as e:
    print(f"Error tagging column: {e}")
```

## Integration Example: Complete Workflow

```python
# Complete workflow: Profile → Validate → Tag

# 1. Profile data
from data_profiler import profile_table
profile = profile_table("main.bronze.customers")

# 2. Run quality tests
quality_results = run_quality_tests(profile)

# 3. Tag based on results
for column_name, column_profile in profile["columns"].items():
    tags = {}

    # Add data type tags
    if "EMAIL" in column_profile.get("patterns", []):
        tags["data_type"] = "EMAIL"
        tags["sensitivity"] = "PII"

    # Add quality tags
    if column_name in quality_results:
        quality_score = quality_results[column_name]["score"]
        if quality_score > 0.95:
            tags["quality_status"] = "HIGH_QUALITY"
        else:
            tags["quality_status"] = "REQUIRES_REVIEW"

    # Apply tags
    w.catalog.update_column(
        full_name=f"main.bronze.customers.{column_name}",
        tags=tags
    )
```

## Output

Tags are stored in Unity Catalog metadata and can be:
- Searched in Databricks UI
- Queried via SQL: `DESCRIBE EXTENDED table_name`
- Used for access control policies
- Leveraged in data discovery tools
- Exported for compliance reporting

## Notes

- Requires appropriate Unity Catalog permissions (`USE CATALOG`, `USE SCHEMA`, `SELECT` on tables)
- Tags are key-value pairs with string values only
- Maximum tag key length: 255 characters
- Maximum tag value length: 256 characters
- Tags are case-sensitive
- Use `databricks-sdk` version 0.20.0 or higher
