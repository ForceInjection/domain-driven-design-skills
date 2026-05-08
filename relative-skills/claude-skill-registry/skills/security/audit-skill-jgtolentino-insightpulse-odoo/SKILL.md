---
name: audit-skill
description: Comprehensive audit capabilities for security, code quality, module structure, compliance, and performance analysis. Use this skill when performing security audits, code reviews, vulnerability assessments, module structure validation, or generating audit reports.
license: LGPL-3.0
allowed-tools:
  - bash
  - view
  - edit
  - create
metadata:
  version: "1.0.0"
  author: "InsightPulse Team"
  category: "security-compliance"
  odoo-version: "19.0"
---

# Audit Skill for Odoo InsightPulse

A comprehensive skill for performing multi-dimensional audits on Odoo codebases, including security vulnerabilities, code quality, module structure compliance, and performance analysis.

## When to Use This Skill

Use this skill when you need to:

- **Security Audits**: Identify vulnerabilities, hardcoded credentials, weak authentication, exposed secrets
- **Code Quality Reviews**: Check coding standards, detect code smells, validate OCA compliance
- **Module Structure Audits**: Verify module manifests, dependencies, and Odoo best practices
- **Compliance Checks**: Validate LGPL-3.0 licensing, GDPR requirements, data privacy
- **Performance Analysis**: Identify N+1 queries, missing indexes, inefficient algorithms
- **Dependency Audits**: Check for outdated packages, security vulnerabilities in dependencies
- **Configuration Audits**: Validate production readiness, environment configurations
- **Database Audits**: Check filesystem vs database module state, orphaned records

## Core Capabilities

### 1. Security Audits

**Critical Vulnerability Detection**:
- Hardcoded credentials (passwords, API keys, tokens)
- Exposed database credentials
- Weak encryption implementations
- Missing authentication/authorization
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) risks
- CSRF token validation
- Insecure file uploads
- Path traversal vulnerabilities

**Secret Detection Patterns**:
```python
# Hardcoded passwords
admin_passwd = "password123"
db_password = "secret"

# API keys in code
OPENAI_API_KEY = "sk-..."
GITHUB_TOKEN = "ghp_..."

# Base64 encoded secrets
SECRET = "YWRtaW46cGFzc3dvcmQ="
```

**Security Best Practices**:
- Environment variable usage
- Secret rotation policies
- Encryption at rest and in transit
- Principle of least privilege
- Row-level security (RLS) policies
- Audit trail logging

### 2. Code Quality Audits

**OCA Compliance Checks**:
- Module structure validation
- Manifest (`__manifest__.py`) completeness
- Security rules (`ir.model.access.csv`)
- Model naming conventions
- View structure and inheritance
- Python code style (PEP 8)
- Docstring completeness

**Code Smell Detection**:
- Duplicate code blocks
- Long methods (>50 lines)
- Deep nesting (>4 levels)
- God classes (>500 lines)
- Unused imports and variables
- Magic numbers
- Missing error handling
- Poor naming conventions

**Anti-Patterns**:
```python
# Anti-pattern: Direct SQL queries
self.env.cr.execute("SELECT * FROM users")

# Better: Use ORM
self.env['res.users'].search([])

# Anti-pattern: No error handling
result = external_api_call()

# Better: Proper exception handling
try:
    result = external_api_call()
except Exception as e:
    _logger.error(f"API call failed: {e}")
    raise UserError(_("External service unavailable"))
```

### 3. Module Structure Audits

**Required Files Check**:
- `__manifest__.py` (required)
- `__init__.py` (required)
- `README.md` (recommended)
- `security/ir.model.access.csv` (if has models)
- `views/` directory (if has UI)
- `models/` directory (if has models)
- `data/` directory (if has data files)
- `tests/` directory (recommended)

**Manifest Validation**:
```python
# Required keys
{
    'name': 'Module Name',
    'version': '19.0.1.0.0',
    'category': 'Category',
    'summary': 'Short description',
    'description': 'Long description',
    'author': 'Author Name',
    'website': 'https://...',
    'license': 'LGPL-3',
    'depends': ['base', 'mail'],
    'data': [
        'security/ir.model.access.csv',
        'views/menu.xml',
    ],
    'installable': True,
    'application': False,
    'auto_install': False,
}
```

**Dependency Validation**:
- Circular dependency detection
- Missing dependency declarations
- Unused dependencies
- Version compatibility

### 4. Database Audits

**Module State Verification**:
- Filesystem modules vs database records
- Installed vs uninstalled modules
- Modules requiring upgrade
- Orphaned database records
- Missing security rules

**Performance Analysis**:
- Missing database indexes
- Inefficient queries
- N+1 query patterns
- Large table scans
- Slow view computations

### 5. Configuration Audits

**Production Readiness**:
- Environment variables properly set
- Debug mode disabled
- Secure admin password
- Database connection pooling
- Resource limits configured
- Backup strategy in place
- Monitoring enabled
- Log rotation configured

**Docker Configuration**:
- Multi-stage builds
- Non-root user
- Health checks
- Resource limits
- Volume mounts
- Network isolation

### 6. Compliance Audits

**LGPL-3.0 License**:
- License file present
- License headers in files
- Third-party notices
- No proprietary dependencies

**GDPR Compliance**:
- Personal data identification
- Data retention policies
- Right to erasure implementation
- Consent management
- Data portability
- Privacy policy

## Audit Execution Workflow

### Step 1: Initialize Audit

```bash
# Set audit context
AUDIT_TYPE="security"  # or: code-quality, module-structure, performance
AUDIT_SCOPE="full"     # or: module-name, directory-path
AUDIT_OUTPUT="json"    # or: markdown, csv
```

### Step 2: Run Automated Checks

```bash
# Security audit
./scripts/audit-security.sh --scope "$AUDIT_SCOPE" --output "$AUDIT_OUTPUT"

# Module structure audit
./scripts/audit-modules.sh odoo_db --output table

# Code quality audit
flake8 addons/ --config .flake8
pylint addons/ --rcfile .pylintrc-mandatory
```

### Step 3: Manual Review

- Review flagged files
- Validate findings
- Assess severity (Critical, High, Medium, Low)
- Calculate CVSS scores
- Document remediation steps

### Step 4: Generate Report

**Report Structure**:
1. Executive Summary
2. Overall Risk Score
3. Critical Vulnerabilities
4. High Priority Issues
5. Medium Priority Issues
6. Low Priority Issues
7. Recommendations
8. Remediation Timeline

### Step 5: Track Remediation

- Create issues for each finding
- Assign severity and priority
- Set remediation deadlines
- Track progress
- Re-audit after fixes

## Audit Report Template

```markdown
# Security Audit Report
**Project**: InsightPulse Odoo
**Date**: YYYY-MM-DD
**Auditor**: Agent Name
**Scope**: Full codebase / Specific module

## Executive Summary

Overall Risk Score: X.X/10 (Critical/High/Medium/Low)

- Critical: X vulnerabilities
- High: X vulnerabilities  
- Medium: X vulnerabilities
- Low: X vulnerabilities

## Critical Vulnerabilities

### 1. Hardcoded Credentials
**Location**: `/path/to/file.py:line`
**Risk**: CVSS 9.8 (Critical)
**Description**: Admin password exposed in configuration
**Remediation**:
- Use environment variables
- Rotate credentials immediately
- Implement secret management

## Recommendations

1. Immediate actions (Critical/High)
2. Short-term improvements (Medium)
3. Long-term enhancements (Low)

## Compliance Status

- [x] LGPL-3.0 License
- [ ] GDPR Compliance
- [x] Security Best Practices
- [ ] Code Quality Standards
```

## Integration with Existing Tools

### Security Scanners

```bash
# Bandit - Python security linter
bandit -r addons/ -f json -o security-audit.json

# Safety - Dependency vulnerability scanner
safety check --json

# Semgrep - Static analysis
semgrep --config=auto addons/
```

### Code Quality Tools

```bash
# Flake8 - Style guide enforcement
flake8 addons/ --max-line-length=88 --extend-ignore=E203

# Pylint - Code quality checker
pylint addons/ --output-format=json

# Black - Code formatter (check only)
black addons/ --check
```

### Odoo-Specific Tools

```bash
# OCA maintainer tools
oca-autopep8 -ri addons/
oca-isort -rc addons/

# Odoo module analyzer
./scripts/audit-modules.sh odoo_db --output json
```

## Best Practices

### Security

1. **Never commit secrets**: Use `.env` files with `.gitignore`
2. **Rotate credentials**: After any exposure or quarterly
3. **Least privilege**: Grant minimum necessary permissions
4. **Encrypt sensitive data**: At rest and in transit
5. **Audit trails**: Log all security-relevant actions
6. **Regular scans**: Automated security checks in CI/CD

### Code Quality

1. **Follow OCA guidelines**: Module structure and naming
2. **Write tests**: Minimum 80% coverage for new code
3. **Document code**: Clear docstrings for all public methods
4. **Handle errors**: Proper exception handling with logging
5. **Avoid anti-patterns**: No direct SQL, use ORM
6. **Keep it DRY**: Don't repeat yourself

### Performance

1. **Add indexes**: On frequently queried fields
2. **Optimize queries**: Avoid N+1 patterns
3. **Use computed fields**: With proper `store=True`
4. **Cache when possible**: For expensive operations
5. **Profile bottlenecks**: Use Odoo profiler
6. **Monitor resources**: CPU, memory, database connections

## Common Issues and Solutions

### Issue: Hardcoded Credentials

**Detection**:
```bash
grep -r "password\s*=\s*['\"]" addons/ --include="*.py"
```

**Solution**:
```python
# Bad
db_password = "mysecret"

# Good
import os
db_password = os.environ.get('DB_PASSWORD')
```

### Issue: Missing Security Rules

**Detection**:
```python
# Check for models without access rules
models_with_no_access = []
for model in self.env['ir.model'].search([]):
    access_count = self.env['ir.model.access'].search_count([
        ('model_id', '=', model.id)
    ])
    if access_count == 0:
        models_with_no_access.append(model.model)
```

**Solution**:
Create `security/ir.model.access.csv`:
```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_my_model_user,my.model.user,model_my_model,base.group_user,1,0,0,0
access_my_model_manager,my.model.manager,model_my_model,base.group_system,1,1,1,1
```

### Issue: N+1 Query Pattern

**Detection**:
```python
# Bad - N+1 queries
for order in orders:
    print(order.partner_id.name)  # Separate query for each order
```

**Solution**:
```python
# Good - Single query with prefetch
orders = self.env['sale.order'].search([]).with_prefetch(['partner_id'])
for order in orders:
    print(order.partner_id.name)
```

### Issue: Missing Database Indexes

**Detection**:
```bash
# Analyze slow queries in PostgreSQL logs
grep "duration:" /var/log/postgresql/postgresql.log | sort -t: -k2 -n | tail -20
```

**Solution**:
```python
class MyModel(models.Model):
    _name = 'my.model'
    
    reference = fields.Char(string='Reference', index=True)  # Add index
    date = fields.Date(string='Date', index=True)
```

## Severity Classification

### Critical (9.0-10.0 CVSS)
- Remote code execution
- Authentication bypass
- Exposed credentials
- Data breach potential

### High (7.0-8.9 CVSS)
- SQL injection
- XSS vulnerabilities
- Privilege escalation
- Missing authentication

### Medium (4.0-6.9 CVSS)
- Information disclosure
- CSRF vulnerabilities
- Insecure configurations
- Missing input validation

### Low (0.1-3.9 CVSS)
- Code quality issues
- Missing documentation
- Performance concerns
- Minor security hardening

## Quick Reference

### Run Security Audit
```bash
cd /home/runner/work/insightpulse-odoo/insightpulse-odoo
grep -r "password\s*=\s*['\"]" . --include="*.py" --include="*.conf"
bandit -r addons/ -ll
safety check
```

### Run Module Audit
```bash
./scripts/audit-modules.sh odoo_db --output table
```

### Run Code Quality Audit
```bash
flake8 addons/ --config .flake8
pylint addons/ --rcfile .pylintrc-mandatory
```

### Generate Full Report
```bash
./scripts/comprehensive-audit.sh --output-dir ./audit-reports
```

## Related Documentation

- [Security Audit Report](../../../SECURITY_AUDIT_REPORT.md)
- [Module Audit Script](../../../scripts/audit-modules.sh)
- [OCA Guidelines](https://github.com/OCA/odoo-community.org/blob/master/website/Contribution/CONTRIBUTING.rst)
- [Odoo Security](https://www.odoo.com/documentation/19.0/developer/reference/backend/security.html)

## Skill Maintenance

This skill should be updated when:
- New vulnerability patterns are discovered
- OCA guidelines change
- Odoo version upgrades (new APIs, deprecated features)
- New audit tools become available
- Compliance requirements evolve

---

**Version**: 1.0.0
**Last Updated**: 2025-11-01
**Maintainer**: InsightPulse Team
