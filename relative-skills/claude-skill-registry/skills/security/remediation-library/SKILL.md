---
name: remediation-library
description: Index of security remediation skills. Routes to specialized skills for injection, cryptography, authentication, and configuration vulnerabilities.
---

# Remediation Library

This skill is an index to modular remediation guides. Use the specialized skills below for focused remediation guidance.

## When to Use This Skill

- **Finding the right remediation skill** - Use this index to route to the appropriate specialized skill
- **Overview of available fixes** - Quick reference of what's available

## When NOT to Use This Skill

- **Detecting vulnerabilities** - Use vulnerability-patterns skill
- **Specific remediation** - Use the specialized skills directly (faster)

---

## Specialized Remediation Skills

### `remediation-injection`
**Covers**: SQL Injection, Command Injection, XSS
**CWEs**: CWE-89, CWE-78, CWE-79
**Use when**: Fixing injection vulnerabilities, code review feedback

### `remediation-crypto`
**Covers**: Weak Cryptography, Insecure Randomness, TLS Issues
**CWEs**: CWE-327, CWE-330, CWE-295
**Use when**: Fixing crypto vulnerabilities, upgrading algorithms

### `remediation-auth`
**Covers**: Hardcoded Credentials, JWT Security, Deserialization, Access Control
**CWEs**: CWE-798, CWE-347, CWE-502, CWE-862
**Use when**: Fixing auth issues, secrets management, authorization

### `remediation-config`
**Covers**: Path Traversal, Debug Mode, Security Headers
**CWEs**: CWE-22, CWE-489, CWE-693
**Use when**: Fixing deployment issues, hardening configuration

---

## Quick Routing Guide

| Vulnerability Type | Skill to Use |
|-------------------|--------------|
| SQL Injection | `remediation-injection` |
| Command Injection | `remediation-injection` |
| XSS | `remediation-injection` |
| Weak hashing (MD5/SHA1) | `remediation-crypto` |
| Insecure randomness | `remediation-crypto` |
| TLS disabled | `remediation-crypto` |
| Hardcoded secrets | `remediation-auth` |
| JWT issues | `remediation-auth` |
| Unsafe deserialization | `remediation-auth` |
| Missing access control | `remediation-auth` |
| Path traversal | `remediation-config` |
| Debug in production | `remediation-config` |
| Missing headers | `remediation-config` |

---

## OWASP Mapping

| OWASP 2021 | Primary Skill |
|------------|---------------|
| A01 Broken Access Control | `remediation-auth` |
| A02 Cryptographic Failures | `remediation-crypto` |
| A03 Injection | `remediation-injection` |
| A04 Insecure Design | Multiple |
| A05 Security Misconfiguration | `remediation-config` |
| A06 Vulnerable Components | N/A |
| A07 Auth Failures | `remediation-auth` |
| A08 Data Integrity Failures | `remediation-auth` |
| A09 Logging Failures | `remediation-config` |
| A10 SSRF | `remediation-injection` |

---

## See Also

- `vulnerability-patterns` - Detection patterns
- `asvs-requirements` - ASVS compliance mapping
- `audit-report` - Report formatting
