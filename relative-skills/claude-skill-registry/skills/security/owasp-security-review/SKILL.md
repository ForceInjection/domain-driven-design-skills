---
name: owasp-security-review
description: Security review and implementation support based on OWASP Cheat Sheet Series. Use for code review requests, security-related implementation/research, and vulnerability checks. Covers security topics such as XSS, SQL Injection, CSRF, and authentication/authorization.
compatibility:
  os: [darwin, linux]
  requirements:
    - git
    - network-access
allowed-tools:
  - shell_command
---

# OWASP Security Review

Perform code security reviews based on the OWASP Cheat Sheet Series, identifying vulnerabilities and providing remediation recommendations.

## Setup

If the Cheat Sheet repository has not been cloned:

```bash
bash scripts/setup_cheatsheets.sh
```

By default, it clones to `~/.local/share/owasp-cheatsheets`.

## Review Workflow

### 1. Identify Security Concerns

Identify relevant security categories from the code:

| Code Pattern | OWASP Top 10 Category |
|--------------|----------------------|
| User input handling | A03: Injection |
| SQL queries | A03: Injection |
| HTML output | A03: Injection (XSS) |
| Authentication logic | A07: Authentication Failures |
| Session handling | A07: Authentication Failures |
| Access control checks | A01: Broken Access Control |
| Cryptography, passwords | A02: Cryptographic Failures |
| File uploads | A05: Security Misconfiguration |
| External API calls | A10: SSRF |
| Deserialization | A08: Data Integrity Failures |
| Dependencies | A06: Vulnerable Components |
| Logging | A09: Logging Failures |

### 2. Load Relevant Cheat Sheets

Refer to [top10-mapping.md](references/top10-mapping.md) to identify the applicable Cheat Sheets.

Load a Cheat Sheet:

```bash
cat ~/.local/share/owasp-cheatsheets/cheatsheets/<CheatSheet_Name>.md
```

### 3. Review and Report

#### Output Format for Code Review

```markdown
## Security Review Summary

### Findings

#### [Severity: Critical/High/Medium/Low] Finding Title
- **Location**: file:line
- **Issue**: Description of the problem
- **OWASP Category**: A0X: Category Name
- **Reference**: Cheat Sheet name
- **Recommendation**: Remediation with code examples
```

#### Output Format for Implementation/Research

Present implementation guidance or research findings based on Cheat Sheet content. Always cite the source Cheat Sheet.

## Quick Reference

### Common Vulnerabilities Checklist

- [ ] SQL/NoSQL Injection: Use parameterized queries
- [ ] XSS: Output encoding, CSP
- [ ] CSRF: Token validation
- [ ] Authentication: Strong password policy, MFA
- [ ] Session: Secure settings, appropriate expiration
- [ ] Access Control: Consistent authorization checks
- [ ] Secrets: No hardcoded secrets
- [ ] File Upload: File type validation, storage location
- [ ] Error Handling: Prevent information leakage
- [ ] Logging: Exclude sensitive information
