---
name: pal-secaudit
description: Comprehensive security audit with OWASP Top 10 analysis, compliance evaluation, and threat modeling using PAL MCP. Use for security reviews, vulnerability assessment, or compliance checks. Triggers on security audit requests, vulnerability scanning, or compliance reviews.
---

# PAL Security Audit

Systematic security audit covering OWASP Top 10, compliance, and threat modeling.

## When to Use

- Security vulnerability assessment
- OWASP Top 10 analysis
- Compliance evaluation (SOC2, PCI DSS, HIPAA, GDPR)
- Threat modeling
- Pre-deployment security review
- Dependency vulnerability scanning

## Quick Start

```python
result = mcp__pal__secaudit(
    step="OWASP Top 10 security audit of authentication system",
    step_number=1,
    total_steps=2,
    next_step_required=True,
    findings="Beginning vulnerability scan",
    audit_focus="owasp",
    threat_level="high",
    relevant_files=[
        "/app/auth/login.py",
        "/app/auth/session.py"
    ],
    confidence="exploring"
)
```

## Audit Focus Areas

| Focus | Description |
|-------|-------------|
| `owasp` | OWASP Top 10 vulnerabilities |
| `compliance` | Regulatory compliance |
| `infrastructure` | Cloud/server security |
| `dependencies` | Third-party vulnerabilities |
| `comprehensive` | All areas |

## Threat Levels

| Level | Description |
|-------|-------------|
| `low` | Internal tools, low-risk data |
| `medium` | Customer-facing, business data |
| `high` | Regulated, sensitive data |
| `critical` | Financial, healthcare, PII |

## Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `step` | string | Audit narrative |
| `step_number` | int | Current step |
| `total_steps` | int | Estimated total |
| `next_step_required` | bool | More audit needed? |
| `findings` | string | Vulnerabilities found |

## Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `audit_focus` | enum | owasp/compliance/infrastructure/dependencies/comprehensive |
| `threat_level` | enum | low/medium/high/critical |
| `security_scope` | string | Context (web, API, mobile, etc.) |
| `compliance_requirements` | list | ["SOC2", "PCI DSS", "HIPAA"] |
| `severity_filter` | enum | Minimum severity to report |
| `relevant_files` | list | Security-relevant files |
| `issues_found` | list | Vulnerabilities with severity |

## OWASP Top 10 Checklist

1. **Broken Access Control** - Authorization bypasses
2. **Cryptographic Failures** - Weak encryption, exposed secrets
3. **Injection** - SQL, NoSQL, OS command, LDAP
4. **Insecure Design** - Missing security controls
5. **Security Misconfiguration** - Default configs, verbose errors
6. **Vulnerable Components** - Outdated dependencies
7. **Auth Failures** - Weak passwords, session issues
8. **Data Integrity Failures** - Insecure deserialization
9. **Logging Failures** - Missing audit trails
10. **SSRF** - Server-side request forgery

## Example: Compliance Audit

```python
mcp__pal__secaudit(
    step="SOC2 and HIPAA compliance audit of patient data handling",
    step_number=1,
    total_steps=3,
    next_step_required=True,
    findings="Reviewing data encryption, access controls, audit logging",
    audit_focus="compliance",
    compliance_requirements=["SOC2", "HIPAA"],
    threat_level="critical",
    security_scope="Healthcare API handling PHI",
    relevant_files=[
        "/app/api/patients.py",
        "/app/models/medical_record.py",
        "/config/encryption.py"
    ],
    confidence="exploring"
)
```

## Issue Severity

```python
issues_found=[
    {"severity": "critical", "description": "Hardcoded API key in source"},
    {"severity": "high", "description": "Missing rate limiting on login"},
    {"severity": "medium", "description": "Verbose error messages expose stack"},
    {"severity": "low", "description": "Missing security headers"}
]
```
