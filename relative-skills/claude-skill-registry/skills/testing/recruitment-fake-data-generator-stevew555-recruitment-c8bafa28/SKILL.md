---
name: recruitment-fake-data-generator
description: This skill should be used when users need to generate realistic fake/test data for recruitment systems including clients, candidates, jobs, and placements. Generates UK-focused CSV data matching ProActive People's business model with customizable record counts and industry sectors.
---

# Recruitment Fake Data Generator

Generate realistic test data for recruitment automation systems with UK-specific details matching ProActive People's business domains.

## Purpose

This skill generates comprehensive fake data for testing and development of recruitment systems, including:
- Client/company records with full contact and commercial details
- Candidate profiles with skills, experience, and qualifications
- Job postings with requirements and specifications
- Placement records linking candidates to jobs and clients

All data uses UK-specific formatting (postcodes, phone numbers, addresses, company structures) and reflects ProActive People's business domains: Sales, Technical, Contact Centre, Accountancy, and Commercial.

## When to Use This Skill

Use this skill when users request:
- "Generate 50 fake clients"
- "Create test candidate data"
- "I need sample recruitment data for testing"
- "Generate a fake client database with 100 companies"
- "Create fake candidate CVs for the system"
- "Generate test data for jobs and placements"

## How to Use This Skill

### Step 1: Identify Data Type and Parameters

Parse the user's request to determine:
- **Data type**: clients, candidates, jobs, placements, or "all"
- **Record count**: Number of records to generate (default: 50 for specific types, 25 each for "all")
- **Industry focus**: Specific sectors or "mix" (default: mix of all ProActive People domains)
- **Complexity**: "simple" for basic fields, "complex" for full details (default: complex)

### Step 2: Generate Data Using Scripts

Execute the appropriate generation script from `scripts/`:

**For client data:**
```bash
python scripts/generate_clients.py --count <number> --output <filename.csv>
```

**For candidate data:**
```bash
python scripts/generate_candidates.py --count <number> --output <filename.csv>
```

**For job data:**
```bash
python scripts/generate_jobs.py --count <number> --output <filename.csv>
```

**For placement data:**
```bash
python scripts/generate_placements.py --count <number> --output <filename.csv>
```

**For all data types:**
```bash
python scripts/generate_all.py --count <number> --output-dir <directory>
```

### Step 3: Reference Documentation

When generating data, refer to:
- `references/uk_data.md` - UK-specific data patterns (postcodes, phone formats, cities)
- `references/schema_definitions.md` - Complete field definitions for each data type
- `references/industry_sectors.md` - ProActive People business domains and specialties

### Step 4: Validate Output

After generation:
1. Verify CSV structure matches expected schema
2. Check UK-specific formatting (postcodes like "BS1 6DZ", phones like "0117 555 1234")
3. Confirm industry sectors align with ProActive People domains
4. Ensure referential integrity for linked data (placements reference real clients/candidates/jobs)

### Step 5: Present Results

Inform the user:
- Number of records generated
- Output file location(s)
- Brief summary of data characteristics
- Any customizations applied

## Script Details

### generate_clients.py
Generates fake client/company records with:
- Company details (name, legal entity, industry, size)
- Primary and secondary contacts
- Full UK addresses
- Service lines used (Recruitment, Assessment, Training, etc.)
- Account status and tier (Active/Inactive, Bronze/Silver/Gold/Platinum)
- Financial details (revenue, payment terms, credit limits)
- Recruitment preferences (specialties, work models, hiring frequency)
- Interview processes and requirements

### generate_candidates.py
Generates fake candidate profiles with:
- Personal details (name, contact info, UK address)
- Professional experience (job history with dates)
- Skills and certifications
- Education and qualifications
- Desired roles and salary expectations
- Work preferences (remote, hybrid, office)
- Availability and notice period

### generate_jobs.py
Generates fake job postings with:
- Job title and description
- Client company reference
- Location and work model
- Salary range and benefits
- Required skills and experience
- Job specifications
- Application deadline
- Recruitment consultant assigned

### generate_placements.py
Generates fake placement records with:
- Candidate and job references
- Client reference
- Placement dates (start, end if temporary)
- Contract type (permanent, temporary, contract)
- Salary/rate details
- Fee information
- Rebate and guarantee periods
- Placement status

### generate_all.py
Orchestrates generation of all data types with referential integrity:
- Creates clients first
- Generates jobs linked to clients
- Creates candidates
- Generates placements linking candidates to jobs
- Ensures data consistency across all tables

## Customization Options

### Industry Sector Filtering
To generate data for specific sectors, use `--sectors` flag:
```bash
python scripts/generate_clients.py --count 30 --sectors "Technical,Sales" --output tech_sales_clients.csv
```

Available sectors:
- Sales (Business Development, Telesales, Field Sales, Fundraising)
- Technical (IT Support, Cloud, Software Engineering, Development)
- Contact Centre (Customer Service, Telesales, Charity Fundraising)
- Accountancy (Corporate Tax, Audit, General Practice)
- Commercial (Management, Office Support, Engineering, PR)

### Complexity Levels
- **Simple**: Core fields only (name, contact, basic details)
- **Complex** (default): All fields including notes, culture details, extended attributes

### Data Realism
All generated data uses:
- Real UK city names and valid postcode formats
- Proper Bristol-area phone numbers (0117, 01934, 01275 prefixes)
- Realistic company names combining business terms + descriptors
- UK business structures (Ltd, PLC, Limited, LLP)
- Appropriate job titles and salary ranges for UK market
- ProActive People's actual service lines and business model

## Example Usage Patterns

**User**: "Generate 100 fake clients for testing"
**Action**: Execute `generate_clients.py --count 100 --output fake_clients.csv`

**User**: "Create 50 technical candidates"
**Action**: Execute `generate_candidates.py --count 50 --sectors Technical --output technical_candidates.csv`

**User**: "I need a complete test database with clients, candidates, jobs, and placements"
**Action**: Execute `generate_all.py --count 50 --output-dir test_data/`

**User**: "Generate simple client data without all the extra fields"
**Action**: Execute `generate_clients.py --count 30 --complexity simple --output simple_clients.csv`

## Output Format

All scripts generate CSV files with:
- Header row with column names
- UTF-8 encoding
- Comma-separated values
- Quoted fields containing commas
- Consistent date formats (YYYY-MM-DD)
- UK-specific formatting throughout

Sample outputs are available in `assets/sample_output/` for reference.
