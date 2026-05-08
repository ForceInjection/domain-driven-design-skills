---
name: csv-data-synthesizer
description: Generate realistic CSV data files with proper headers, data types, and configurable row counts for testing, demos, and development. Triggers on "create CSV data", "generate CSV file", "fake CSV for", "sample data CSV", "test data spreadsheet".
---

# CSV Data Synthesizer

Generate production-realistic CSV data files with proper structure, realistic values, and consistent formatting.

## Output Requirements

**File Output:** `.csv` files with valid CSV structure
**Naming Convention:** `{dataset-name}-data.csv` (e.g., `customers-data.csv`)
**Encoding:** UTF-8
**Line Endings:** Unix (LF)

## When Invoked

Immediately generate a complete, valid CSV file. Default to 20 rows if count not specified.

## CSV Formatting Rules

### Headers
- First row is always headers
- Use snake_case: `first_name`, `order_total`, `created_at`
- No spaces in header names
- Descriptive but concise

### Quoting
- Quote fields containing commas, quotes, or newlines
- Escape internal quotes by doubling: `"She said ""hello"""`
- Prefer quoting text fields for safety

### Data Types
- Dates: `YYYY-MM-DD` format (2024-01-15)
- Datetimes: `YYYY-MM-DD HH:MM:SS` format
- Currency: Decimal without symbol (99.99)
- Booleans: `true`/`false` (lowercase)
- Empty values: Empty string, not NULL or N/A

## Domain Templates

### Customer/User Data
```csv
id,email,first_name,last_name,phone,company,created_at
1,john.doe@example.com,John,Doe,+1-555-0101,Acme Corp,2024-01-15
2,jane.smith@techstart.io,Jane,Smith,+1-555-0102,TechStart Inc,2024-01-16
```

**Fields available:** id, email, first_name, last_name, full_name, phone, company, job_title, department, address, city, state, country, postal_code, created_at, updated_at, status, tier

### E-commerce Orders
```csv
order_id,customer_id,order_date,status,subtotal,tax,shipping,total,items_count
ORD-001,CUST-123,2024-01-15,completed,89.99,7.20,5.99,103.18,3
ORD-002,CUST-456,2024-01-16,processing,149.50,11.96,0.00,161.46,2
```

**Fields available:** order_id, customer_id, customer_email, order_date, status, subtotal, tax, discount, shipping, total, items_count, payment_method, shipping_method, tracking_number

### Product Catalog
```csv
sku,name,category,price,cost,quantity,weight_kg,status
WBH-001,Wireless Headphones,Electronics,79.99,32.00,150,0.25,active
TPT-002,Thermal Printer,Office,299.99,145.00,45,2.10,active
```

**Fields available:** sku, product_id, name, description, category, subcategory, brand, price, cost, margin, quantity, reorder_point, weight_kg, dimensions, status, created_at

### Employee/HR Data
```csv
employee_id,email,first_name,last_name,department,job_title,hire_date,salary,manager_id
EMP001,john.doe@company.com,John,Doe,Engineering,Software Engineer,2022-03-15,95000,EMP010
EMP002,jane.smith@company.com,Jane,Smith,Marketing,Marketing Manager,2021-08-01,85000,EMP015
```

**Fields available:** employee_id, email, first_name, last_name, department, job_title, hire_date, salary, bonus, manager_id, location, status, performance_rating

### Financial Transactions
```csv
transaction_id,date,account_id,type,category,amount,balance,description
TXN-0001,2024-01-15,ACC-123,debit,utilities,-125.50,4874.50,Electric Company Payment
TXN-0002,2024-01-16,ACC-123,credit,salary,3500.00,8374.50,Monthly Salary Deposit
```

**Fields available:** transaction_id, date, account_id, type, category, amount, balance, description, merchant, reference_number, status

### Time Series / Metrics
```csv
timestamp,metric_name,value,unit,source
2024-01-15 00:00:00,cpu_usage,45.2,percent,server-01
2024-01-15 00:05:00,cpu_usage,52.8,percent,server-01
2024-01-15 00:10:00,cpu_usage,38.1,percent,server-01
```

**Fields available:** timestamp, date, metric_name, value, unit, source, environment, tags, min, max, avg

### Survey/Form Responses
```csv
response_id,submitted_at,q1_satisfaction,q2_recommend,q3_comments,nps_score
RSP-001,2024-01-15 14:30:00,5,yes,"Great service, very helpful",9
RSP-002,2024-01-15 15:45:00,4,yes,"Good but could be faster",7
```

## Data Generation Rules

### Realistic Distributions
- Don't make all values perfectly distributed
- Include some edge cases (empty optional fields, boundary values)
- Vary string lengths naturally
- Use realistic value ranges

### Consistency
- Related fields should be consistent (city matches postal code region)
- Dates should be chronologically sensible
- IDs should be unique
- Foreign keys should reference valid parent IDs

### Variation
- Mix case variations where appropriate
- Include international formats (phone, address) if specified
- Vary the "completeness" of records (some with all optional fields, some without)

## Validation Checklist

Before outputting, verify:
- [ ] Header row present
- [ ] Consistent column count across all rows
- [ ] Proper quoting for fields with commas
- [ ] No trailing commas
- [ ] UTF-8 encoding compatible
- [ ] Dates in consistent format
- [ ] Numbers without currency symbols
- [ ] No formula injection risks (fields starting with =, +, -, @)

## Example Invocations

**Prompt:** "Generate CSV with 50 customer records including address"
**Output:** Complete `customers-data.csv` with 50 rows, full address fields.

**Prompt:** "Create sample sales data CSV for Q1 2024"
**Output:** Complete `sales-q1-2024-data.csv` with daily sales records Jan-Mar.

**Prompt:** "CSV test data for employee database import"
**Output:** Complete `employees-data.csv` with realistic HR data structure.
