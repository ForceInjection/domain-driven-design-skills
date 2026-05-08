---
name: unity-catalog-governance
description: Unity Catalog governance patterns, permissions models, security best practices, and policy enforcement for enterprise data governance.
triggers:
  - unity catalog governance
  - catalog security
  - permissions management
  - data governance patterns
category: governance
---

# Unity Catalog Governance Skill

## Overview

Unity Catalog provides centralized governance for data and AI assets across Databricks workspaces. This skill covers governance patterns, security models, access control, and compliance frameworks.

## When to Use This Skill

Use this skill when you need to:
- Design Unity Catalog security architecture
- Implement RBAC/ABAC access controls
- Configure row-level security and column masking
- Set up data classification and tagging
- Implement compliance requirements (GDPR, HIPAA, SOC2)
- Audit permissions and access patterns

## Core Concepts

### Three-Level Namespace
```
catalog.schema.table
production.customers.profiles
```

### Securable Objects
- **Metastore**: Top-level container
- **Catalog**: Database container
- **Schema**: Table container
- **Table/View**: Data objects
- **Volume**: File storage
- **Function**: Callable routines
- **External Location**: External storage
- **Storage Credential**: Cloud credentials

### Privilege Model
```sql
-- Catalog privileges
USE CATALOG, CREATE SCHEMA, USE SCHEMA, CREATE TABLE,
CREATE FUNCTION, CREATE VOLUME, ALL PRIVILEGES, OWNERSHIP

-- Schema privileges
USE SCHEMA, CREATE TABLE, CREATE FUNCTION, CREATE VOLUME,
SELECT, MODIFY, READ FILES, WRITE FILES

-- Table privileges
SELECT, MODIFY, READ METADATA

-- Function privileges
EXECUTE

-- Volume privileges
READ FILES, WRITE FILES
```

## Governance Patterns

### Pattern 1: Environment Isolation
```sql
-- Separate catalogs per environment
CREATE CATALOG IF NOT EXISTS dev;
CREATE CATALOG IF NOT EXISTS staging;
CREATE CATALOG IF NOT EXISTS production;

-- Grant appropriate access
GRANT USE CATALOG, CREATE SCHEMA ON CATALOG dev TO `developers`;
GRANT USE CATALOG, USE SCHEMA ON CATALOG staging TO `testers`;
GRANT USE CATALOG, USE SCHEMA, SELECT ON CATALOG production TO `analysts`;
```

### Pattern 2: Data Domain Organization
```sql
-- Organize by business domain
CREATE CATALOG business_domains;
CREATE SCHEMA business_domains.customer_domain;
CREATE SCHEMA business_domains.financial_domain;
CREATE SCHEMA business_domains.product_domain;

-- Assign domain ownership
ALTER SCHEMA business_domains.customer_domain
  SET OWNER TO `customer_data_team`;

-- Domain-specific access
GRANT SELECT ON SCHEMA business_domains.customer_domain TO `customer_analytics`;
GRANT MODIFY ON SCHEMA business_domains.customer_domain TO `customer_engineering`;
```

### Pattern 3: Medallion with Security
```sql
-- Bronze: Raw data - limited access
CREATE SCHEMA production.bronze;
GRANT USE SCHEMA, SELECT, MODIFY ON SCHEMA production.bronze TO `data_engineers`;

-- Silver: Refined data - broader access
CREATE SCHEMA production.silver;
GRANT USE SCHEMA, SELECT ON SCHEMA production.silver TO `data_analysts`;
GRANT MODIFY ON SCHEMA production.silver TO `data_engineers`;

-- Gold: Business data - wide access
CREATE SCHEMA production.gold;
GRANT USE SCHEMA, SELECT ON SCHEMA production.gold TO `business_users`;
GRANT MODIFY ON SCHEMA production.gold TO `analytics_engineers`;
```

### Pattern 4: Row-Level Security
```sql
-- Regional data access control
CREATE FUNCTION governance.regional_filter(user_region STRING, data_region STRING)
RETURNS BOOLEAN
RETURN CASE
  WHEN IS_ACCOUNT_GROUP_MEMBER('global_access') THEN TRUE
  WHEN user_region = data_region THEN TRUE
  ELSE FALSE
END;

-- Apply row filter
ALTER TABLE production.customers.orders
SET ROW FILTER governance.regional_filter(current_user_region(), region);
```

### Pattern 5: Column Masking
```sql
-- Create masking function
CREATE FUNCTION governance.mask_email(email STRING)
RETURNS STRING
RETURN CASE
  WHEN IS_ACCOUNT_GROUP_MEMBER('pii_admin') THEN email
  WHEN IS_ACCOUNT_GROUP_MEMBER('pii_viewer') THEN
    CONCAT(SUBSTRING(email, 1, 3), '***@', SPLIT(email, '@')[1])
  ELSE 'REDACTED'
END;

-- Apply to column
ALTER TABLE production.customers.profiles
ALTER COLUMN email SET MASK governance.mask_email;
```

### Pattern 6: Data Classification
```sql
-- Create classification tags
CREATE TAG IF NOT EXISTS governance.sensitivity
  VALUES ('PUBLIC', 'INTERNAL', 'CONFIDENTIAL', 'RESTRICTED');

CREATE TAG IF NOT EXISTS governance.data_domain
  VALUES ('CUSTOMER', 'FINANCIAL', 'EMPLOYEE', 'PRODUCT');

-- Apply classification
ALTER TABLE production.customers.profiles
SET TAGS (
  'governance.sensitivity' = 'RESTRICTED',
  'governance.data_domain' = 'CUSTOMER'
);

ALTER TABLE production.customers.profiles
ALTER COLUMN ssn SET TAGS ('governance.sensitivity' = 'RESTRICTED');
```

## Security Best Practices

### 1. Least Privilege Access
```sql
-- ❌ BAD: Overly permissive
GRANT ALL PRIVILEGES ON CATALOG production TO `all_users`;

-- ✅ GOOD: Minimal required permissions
GRANT USE CATALOG ON CATALOG production TO `analysts`;
GRANT USE SCHEMA ON SCHEMA production.gold TO `analysts`;
GRANT SELECT ON SCHEMA production.gold TO `analysts`;
```

### 2. Separation of Duties
```python
# Define distinct roles
ROLES = {
    "data_consumer": ["USE CATALOG", "USE SCHEMA", "SELECT"],
    "data_producer": ["USE CATALOG", "USE SCHEMA", "SELECT", "MODIFY"],
    "data_steward": ["USE CATALOG", "USE SCHEMA", "SELECT", "MODIFY", "ALTER"],
    "platform_admin": ["ALL PRIVILEGES"]  # Minimal assignments
}
```

### 3. Service Principal Ownership
```sql
-- Use service principals for ownership, not individuals
ALTER SCHEMA production.customers
  SET OWNER TO `data-engineering-sp`;

-- Transfer from individual to service principal
ALTER TABLE production.customers.profiles
  SET OWNER TO `customer-domain-sp`;
```

### 4. Audit and Monitor
```sql
-- Query audit logs
SELECT
  user_identity.email,
  request_params.full_name_arg as object_accessed,
  action_name,
  event_time
FROM system.access.audit
WHERE event_date >= CURRENT_DATE - INTERVAL 7 DAYS
  AND action_name IN ('GET_TABLE', 'READ_TABLE')
ORDER BY event_time DESC;
```

### 5. Regular Access Reviews
```python
def quarterly_access_review(catalog: str):
    """Review and recertify access quarterly."""
    # Get all grants
    grants = spark.sql(f"SHOW GRANTS ON CATALOG {catalog}")

    # Identify excessive access
    excessive = grants.filter("privilege = 'ALL PRIVILEGES'")

    # Find unused permissions
    unused = find_unused_grants(grants)

    # Generate review report
    report = generate_review_report(excessive, unused)
    send_to_data_stewards(report)
```

## Compliance Frameworks

### GDPR Compliance Pattern
```python
class GDPRCompliance:
    """GDPR compliance implementation."""

    def setup_data_inventory(self):
        """Article 30: Records of processing."""
        # Tag all PII
        self.classify_pii_data()
        # Document processing purposes
        self.document_purposes()

    def implement_right_to_erasure(self):
        """Article 17: Right to erasure."""
        # Create deletion workflow
        self.create_deletion_api()
        # Setup cascade delete
        self.configure_lineage()

    def enable_data_portability(self):
        """Article 20: Right to data portability."""
        # Export user data
        self.create_export_api()
```

### HIPAA Compliance Pattern
```python
class HIPAACompliance:
    """HIPAA compliance implementation."""

    def implement_access_controls(self):
        """Technical Safeguards: Access Control."""
        # Unique user identification
        self.enforce_sso()
        # Automatic logoff
        self.configure_session_timeout()
        # Audit controls
        self.enable_comprehensive_logging()

    def enable_encryption(self):
        """Technical Safeguards: Encryption."""
        # Encryption at rest
        self.enable_catalog_encryption()
        # Encryption in transit
        self.enforce_tls()
```

## Templates

See `/templates/` directory for:
- **governance-framework**: Complete governance setup
- **rbac-configuration**: Role-based access control
- **compliance-checklist**: Regulatory compliance validation
- **audit-procedures**: Regular audit workflows

## Examples

See `/examples/` directory for:
- **regional-access-control**: Multi-region data isolation
- **pii-protection**: PII masking and encryption
- **compliance-reporting**: Automated compliance reports

## Related Skills

- `data-classification`: Data classification and tagging
- `compliance-automation`: Automated compliance checks
- `access-management`: RBAC/ABAC implementation

## References

- [Unity Catalog Documentation](https://docs.databricks.com/data-governance/unity-catalog/index.html)
- [Unity Catalog Best Practices](https://docs.databricks.com/data-governance/unity-catalog/best-practices.html)
- [Data Governance on Databricks](https://www.databricks.com/product/unity-catalog)
