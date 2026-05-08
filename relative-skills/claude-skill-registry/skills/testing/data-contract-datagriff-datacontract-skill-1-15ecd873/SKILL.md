---
name: data-contract
description: Create, validate, test, and manage data contracts using the Open Data Contract Specification (ODCS) and the datacontract CLI. Use when working with data contracts, ODCS specifications, data quality rules, or when the user mentions datacontract CLI or data contract workflows.
---

# Data Contract Management

## Overview
This skill helps you work with data contracts following the Open Data Contract Specification (ODCS). You can execute the datacontract CLI directly to create, lint, test, and export data contracts.

## When to Use This Skill
- Creating new data contracts
- Validating contracts against ODCS specification
- Testing data quality rules
- Generating platform-specific artifacts (dbt, SQL, etc.)
- Working with data contract YAML files
- Discussing data quality patterns and SLAs

## Available CLI Commands

### Core Commands
- `datacontract init [--template PLATFORM]` - Initialize a new data contract
- `datacontract lint {description}-CONTRACT.yaml` - Validate against ODCS spec
- `datacontract test {description}-CONTRACT.yaml` - Run data quality tests
- `datacontract export {description}-CONTRACT.yaml --format FORMAT` - Export to other formats
- `datacontract lint {description}-CONTRACT.yaml` - Check for best practices
- `datacontract breaking {description}-CONTRACT.yaml CONTRACT_v2.yaml` - Check for breaking changes

### Supported Platforms
Templates available: snowflake, bigquery, redshift, databricks, postgres, s3, local

### Export Formats
Available formats: dbt, dbt-sources, dbt-staging-sql, odcs, jsonschema, sql, sqlalchemy, avro, protobuf, great-expectations, terraform, rdf

## Workflow Patterns

### Creating a New Data Contract

**Step 1: Gather Requirements**
Ask the user for:
- Data platform (Snowflake, BigQuery, Databricks, etc.)
- Schema details:
  - Database/dataset name
  - Table/model name
  - Column names, types, and descriptions
- Quality requirements:
  - Freshness expectations (how often data updates)
  - Completeness rules (which fields must not be null)
  - Uniqueness constraints (primary keys, unique fields)
  - Validity rules (patterns, ranges, allowed values)
- SLAs and policies:
  - Availability commitments
  - Retention policies
  - Access/privacy considerations

**Step 2: Initialize Contract**
```bash
datacontract init --template <platform>
```
This creates a basic contract template for the specified platform.

**Step 3: Customize the Contract**
Edit the generated YAML to include:
- Specific schema details
- Column definitions with types and descriptions
- Quality rules based on requirements
- SLA specifications

**Step 4: Lint**
```bash
datacontract lint {description}-contract.yaml
```
Always validate after creation or any modifications.

**Step 5: Iterate Based on Validation**
If validation fails:
- Parse error messages carefully
- Fix structural issues first (missing required fields, incorrect format)
- Then address semantic issues (invalid values, incorrect references)
- Re-validate after each fix
- Maximum 3 iteration cycles before asking user for guidance

### Validation Error Handling

When validation fails, follow this pattern:
1. **Read the error output** - Identify specific issues (missing fields, type mismatches, invalid values)
2. **Prioritize fixes**:
   - Required ODCS fields first (dataset, schema, columns)
   - Format/structure issues
   - Type and value constraints
3. **Fix one category at a time** - Don't try to fix everything at once
4. **Validate after each fix** - Ensures you're making progress
5. **Explain what you fixed** - Help the user understand the changes

### Testing Data Quality

```bash
datacontract test {description}-contract.yaml
```

Tests validate that actual data meets the quality rules defined in the contract. This requires:
- Access to the data platform
- Appropriate connection credentials
- Data actually existing at the specified location

If tests fail, help the user understand:
- Which quality rules failed
- Whether the contract needs adjustment or the data needs fixing

## ODCS Structure Essentials

### Required Top-Level Fields
Every data contract must include:
- `dataContractSpecification` - Version of ODCS (e.g., "0.9.3")
- `id` - Unique identifier for the contract
- `info` - Metadata (title, version, description, owner, contact)
- `servers` - Data platform connection details
- `schema` - The data model definition

### Schema Definition
The schema section defines your data model:
```yaml
schema:
  type: dbt | table | view | ...
  specification: dbt | bigquery | snowflake | ...
  <table_name>:
    type: table
    columns:
      <column_name>:
        type: <data_type>
        required: true|false
        description: "..."
        unique: true|false
        primary: true|false
```

### Quality Rules
Define quality expectations:
```yaml
quality:
  type: SodaCL | great-expectations | ...
  specification:
    checks for <table_name>:
      - freshness(<column>) < 24h
      - missing_count(<column>) = 0
      - duplicate_count(<column>) = 0
      - values in (<column>) must be in [list]
```

## Common Quality Patterns

### Freshness
How recently data was updated:
- `freshness(updated_at) < 1h` - Data updated within last hour
- `freshness(load_date) < 1d` - Daily updates

### Completeness
Ensuring required data exists:
- `missing_count(customer_id) = 0` - No nulls in required field
- `missing_percent(email) < 5%` - Allow some missing values

### Uniqueness
Preventing duplicates:
- `duplicate_count(order_id) = 0` - Primary keys must be unique
- `duplicate_count(user_id, timestamp) = 0` - Composite uniqueness

### Validity
Data meets expected patterns:
- `values in (status) must be in ['pending', 'completed', 'cancelled']`
- `invalid_percent(email) < 1%` - Email format validation
- `min(price) >= 0` - Range constraints
- `max_length(postal_code) = 5` - Length constraints

## Best Practices

### Contract Creation
1. Start with required ODCS fields to ensure valid structure
2. Use platform-appropriate data types (Snowflake: VARCHAR, BigQuery: STRING, etc.)
3. Include clear descriptions for all columns - aids documentation
4. Mark primary keys and required fields explicitly
5. Consider downstream dependencies when defining schema

### Quality Rules
1. Add quality rules incrementally - start with critical rules
2. Be realistic with thresholds - 100% quality isn't always achievable
3. Match rules to business requirements, not technical ideals
4. Test rules on actual data before finalizing
5. Document why specific thresholds were chosen

### Validation Workflow
1. Validate early and often
2. Fix structural issues before semantic ones
3. Keep validation output for reference
4. Re-validate after any change
5. Use lint command for additional best practice checks

### Platform-Specific Considerations
- **Snowflake**: Use fully qualified names (database.schema.table)
- **BigQuery**: Use dataset.table naming
- **Databricks**: Consider Unity Catalog structure
- **S3**: Include bucket and path information
- **Local**: Specify file paths clearly

## Exporting Contracts

Generate platform-specific artifacts:
```bash
datacontract export {description}-contract.yaml --format dbt
datacontract export {description}-contract.yaml --format sql
datacontract export {description}-contract.yaml --format great-expectations
```

Common use cases:
- **dbt**: Generate dbt model YAML and staging SQL
- **sql**: Create DDL statements for database setup
- **great-expectations**: Generate expectations for data validation
- **terraform**: Infrastructure as code for data resources

## Tips for Effective Use

1. **Be conversational** - Ask clarifying questions rather than guessing requirements
2. **Show your work** - Explain what commands you're running and why
3. **Parse errors carefully** - CLI output can be verbose; extract key issues
4. **Iterate transparently** - Show validation results and explain fixes
5. **Suggest improvements** - Recommend quality rules based on data types
6. **Reference documentation** - When unsure, mention you can look up ODCS spec details

## Example Interaction Flow

User: "Create a data contract for our customer orders table in Snowflake"

You should:
1. Ask about schema (columns, types), quality needs, and SLAs
2. Run: `datacontract init --template snowflake`
3. Explain the generated structure
4. Customize based on user's answers
5. Run: `datacontract lint {description}-contract.yaml`
6. If errors, fix and re-validate
7. Suggest quality rules based on the schema
8. Offer to test or export as needed

## Resources

When you need more details:
- ODCS Specification: https://datacontract.com
- CLI Documentation: https://cli.datacontract.com
- Example contracts in the datacontract repository

Remember: The datacontract CLI is your primary tool. Execute commands directly, parse output carefully, and guide the user through the process with clear explanations.