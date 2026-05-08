---
name: security-audit-checklist
description: Provides exhaustive security vulnerability checklists with severity classifications, point deductions, and detection commands. Use when performing security audits, code reviews, penetration testing preparation, or checking OWASP compliance.
---

# Security Audit Checklist

Comprehensive security vulnerability checklists organized by severity with quantified point deductions for code review scoring.

## Quick Start

**Full security audit:**
```
Run a complete security audit using the OWASP Top 10 checklist with severity scoring.
```

**Language-specific scan:**
```
Check this Node.js codebase for injection vulnerabilities and authentication issues.
```

## Severity Classification

| Severity | Multiplier | Point Range | Response Time |
|----------|------------|-------------|---------------|
| **Critical** | 2.0x | 2.0-4.0 | Immediate (block deploy) |
| **High** | 1.5x | 1.0-2.0 | 24 hours |
| **Medium** | 1.0x | 0.5-1.0 | 1 week |
| **Low** | 0.5x | 0.25-0.5 | Next sprint |

---

## Critical Vulnerabilities (P0)

### SQL Injection

**Base Deduction:** 2.0 points | **Severity:** Critical (2.0x) | **Total:** 4.0 points

**Detection Commands:**
```bash
# String interpolation in queries
grep -rn "\`SELECT.*\${" src/
grep -rn "\"SELECT.*\" \+" src/
grep -rn "query.*\`.*\${" src/
grep -rn "execute.*f\"" src/  # Python f-strings

# Raw queries without parameterization
grep -rn "\.raw\(" src/
grep -rn "\.rawQuery\(" src/
grep -rn "createQuery.*\+" src/  # Java JPA
```

**Evidence Template:**
```
Location: {file}:{line}
Pattern: Unparameterized SQL with user input
Measurement: {count} injection vectors
Impact: Full database compromise, data exfiltration
```

---

### Remote Code Execution (RCE)

**Base Deduction:** 2.0 points | **Severity:** Critical (2.0x) | **Total:** 4.0 points

**Detection Commands:**
```bash
# Command injection
grep -rn "exec\(" src/
grep -rn "eval\(" src/
grep -rn "spawn.*shell.*true" src/
grep -rn "subprocess.*shell=True" src/
grep -rn "os\.system\(" src/

# Unsafe deserialization
grep -rn "pickle\.loads\(" src/
grep -rn "yaml\.load\(" src/ | grep -v "safe_load"
grep -rn "ObjectInputStream" src/
grep -rn "unserialize\(" src/
```

**Evidence Template:**
```
Location: {file}:{line}
Pattern: {exec|eval|deserialization} with user-controlled input
Measurement: {count} RCE vectors
Impact: Complete server compromise, lateral movement
```

---

### Hardcoded Secrets

**Base Deduction:** 2.0 points | **Severity:** Critical (2.0x) | **Total:** 4.0 points

**Detection Commands:**
```bash
# API keys and tokens
grep -rn "AKIA[0-9A-Z]{16}" src/
grep -rn "sk_live_" src/
grep -rn "gh[pousr]_[A-Za-z0-9_]" src/
grep -rn "xox[baprs]-" src/

# Generic patterns
grep -rn "password\s*=\s*['\"]" src/
grep -rn "api_key\s*=\s*['\"]" src/
grep -rn "secret\s*=\s*['\"]" src/
grep -rn "token\s*=\s*['\"][^'\"]*['\"]" src/

# Private keys
grep -rn "BEGIN.*PRIVATE KEY" src/
grep -rn "BEGIN RSA PRIVATE" src/
```

**Evidence Template:**
```
Location: {file}:{line}
Pattern: {AWS key|Stripe key|generic secret} hardcoded
Measurement: {count} secrets exposed
Impact: Credential theft, financial fraud, account takeover
```

---

### Authentication Bypass

**Base Deduction:** 2.0 points | **Severity:** Critical (2.0x) | **Total:** 4.0 points

**Detection Commands:**
```bash
# Missing auth middleware
grep -rn "app\.\(get\|post\|put\|delete\)" src/ | grep -v "auth\|protect\|require"

# JWT issues
grep -rn "algorithm.*none" src/
grep -rn "verify.*false" src/
grep -rn "ignoreExpiration.*true" src/

# Session issues
grep -rn "session\.secret.*=.*['\"]" src/
grep -rn "secure.*false" src/ | grep -i cookie
```

**Evidence Template:**
```
Location: {file}:{line}
Pattern: {missing auth check|weak JWT|insecure session}
Measurement: {count} unprotected endpoints
Impact: Unauthorized access, privilege escalation
```

---

## High Vulnerabilities (P1)

### Cross-Site Scripting (XSS)

**Base Deduction:** 1.5 points | **Severity:** High (1.5x) | **Total:** 2.25 points

**Detection Commands:**
```bash
# React dangerouslySetInnerHTML
grep -rn "dangerouslySetInnerHTML" src/

# Template injection
grep -rn "<%- " src/  # EJS unescaped
grep -rn "\|safe" src/  # Django/Jinja unescaped
grep -rn "v-html" src/  # Vue
grep -rn "{!! " src/  # Laravel Blade

# DOM manipulation
grep -rn "\.innerHTML\s*=" src/
grep -rn "document\.write\(" src/
```

**Evidence Template:**
```
Location: {file}:{line}
Pattern: {dangerouslySetInnerHTML|innerHTML|unescaped template}
Measurement: {count} XSS vectors
Impact: Session hijacking, credential theft, defacement
```

---

### Insecure Direct Object Reference (IDOR)

**Base Deduction:** 1.5 points | **Severity:** High (1.5x) | **Total:** 2.25 points

**Detection Commands:**
```bash
# Direct ID usage without ownership check
grep -rn "params\.id\|req\.params\.id" src/
grep -rn "findById.*req\.params" src/
grep -rn "findOne.*id.*=.*req" src/

# Check if ownership validation exists nearby
```

**Audit Questions:**
- [ ] Does every resource access check ownership?
- [ ] Are UUIDs used instead of sequential IDs?
- [ ] Is there row-level security in the database?

---

### Server-Side Request Forgery (SSRF)

**Base Deduction:** 1.5 points | **Severity:** High (1.5x) | **Total:** 2.25 points

**Detection Commands:**
```bash
# URL from user input
grep -rn "fetch\(.*req\." src/
grep -rn "axios\.\(get\|post\).*req\." src/
grep -rn "requests\.get\(.*request\." src/
grep -rn "http\.get\(.*params" src/

# Redirects
grep -rn "redirect\(.*req\." src/
```

**Evidence Template:**
```
Location: {file}:{line}
Pattern: HTTP request with user-controlled URL
Measurement: {count} SSRF vectors
Impact: Internal network scanning, cloud metadata access
```

---

### Missing Rate Limiting

**Base Deduction:** 1.0 points | **Severity:** High (1.5x) | **Total:** 1.5 points

**Detection Commands:**
```bash
# Check for rate limiter middleware
grep -rn "rateLimit\|rate-limit\|RateLimiter" src/

# Sensitive endpoints without rate limiting
grep -rn "login\|register\|password\|forgot\|reset" src/routes/
```

**Audit Questions:**
- [ ] Are login endpoints rate-limited?
- [ ] Is password reset rate-limited?
- [ ] Are API endpoints throttled per user?

---

## Medium Vulnerabilities (P2)

### Missing Input Validation

**Base Deduction:** 0.75 points | **Severity:** Medium (1.0x) | **Total:** 0.75 points

**Detection Commands:**
```bash
# Direct body/query usage without validation
grep -rn "req\.body\." src/ | head -20
grep -rn "req\.query\." src/ | head -20
grep -rn "request\.json\(\)" src/

# Check for validation libraries
grep -rn "zod\|yup\|joi\|validator\|pydantic" package.json src/
```

---

### Weak Cryptography

**Base Deduction:** 0.75 points | **Severity:** Medium (1.0x) | **Total:** 0.75 points

**Detection Commands:**
```bash
# Weak hash algorithms
grep -rn "md5\|MD5" src/
grep -rn "sha1\|SHA1" src/ | grep -v "sha1.*integrity"

# Weak encryption
grep -rn "DES\|3DES\|RC4\|ECB" src/

# Insecure random
grep -rn "Math\.random\(\)" src/
grep -rn "random\.random\(\)" src/
```

---

### Missing Security Headers

**Base Deduction:** 0.5 points | **Severity:** Medium (1.0x) | **Total:** 0.5 points

**Required Headers Checklist:**
- [ ] `Content-Security-Policy`
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `X-Frame-Options: DENY`
- [ ] `Strict-Transport-Security`
- [ ] `Referrer-Policy`
- [ ] `Permissions-Policy`

**Detection Commands:**
```bash
# Check for helmet or manual headers
grep -rn "helmet\|setHeader.*Content-Security" src/
grep -rn "X-Frame-Options\|X-Content-Type" src/
```

---

### CORS Misconfiguration

**Base Deduction:** 0.5 points | **Severity:** Medium (1.0x) | **Total:** 0.5 points

**Detection Commands:**
```bash
# Dangerous CORS patterns
grep -rn "origin.*\*\|origin.*true" src/
grep -rn "Access-Control-Allow-Origin.*\*" src/
grep -rn "credentials.*true" src/ | grep -i cors

# Check for origin reflection
grep -rn "origin.*req\.headers\.origin" src/
```

---

## Low Vulnerabilities (P3)

### Verbose Error Messages

**Base Deduction:** 0.25 points | **Severity:** Low (0.5x) | **Total:** 0.125 points

**Detection Commands:**
```bash
# Stack traces exposed
grep -rn "error\.stack\|err\.stack" src/
grep -rn "res\.send.*error\|res\.json.*error" src/

# Debug mode in production
grep -rn "DEBUG.*true\|debug.*=.*true" src/
```

---

### Missing Audit Logging

**Base Deduction:** 0.25 points | **Severity:** Low (0.5x) | **Total:** 0.125 points

**Audit Questions:**
- [ ] Are authentication events logged?
- [ ] Are authorization failures logged?
- [ ] Are sensitive data access events logged?
- [ ] Do logs include user ID, action, timestamp, IP?

---

### Outdated Dependencies

**Base Deduction:** 0.25-1.0 points | **Severity:** Varies

**Detection Commands:**
```bash
# NPM security audit
npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities'

# Check for outdated
npm outdated 2>/dev/null

# Python
pip-audit 2>/dev/null
safety check 2>/dev/null
```

**Scoring:**
| CVE Severity | Deduction |
|--------------|-----------|
| Critical | 1.0 per CVE |
| High | 0.5 per CVE |
| Medium | 0.25 per CVE |
| Low | 0.1 per CVE |

---

## Language-Specific Checklists

### Node.js/JavaScript

See [references/nodejs-security.md](references/nodejs-security.md) for:
- Prototype pollution patterns
- Event emitter leaks
- Path traversal in file serving
- Child process injection
- Regular expression DoS (ReDoS)

### Python

See [references/python-security.md](references/python-security.md) for:
- Pickle/YAML deserialization
- Template injection (Jinja2, Django)
- OS command injection
- Path traversal

### Go

See [references/go-security.md](references/go-security.md) for:
- SQL injection with database/sql
- Path traversal in http.FileServer
- Race conditions
- Unsafe pointer usage

### Java

See [references/java-security.md](references/java-security.md) for:
- XXE in XML parsers
- Deserialization gadget chains
- JNDI injection
- Expression Language injection

---

## Audit Report Template

```markdown
## Security Audit Summary

| Severity | Count | Total Deduction |
|----------|-------|-----------------|
| Critical | {n} | {n * 4.0} |
| High | {n} | {n * 2.25} |
| Medium | {n} | {n * 0.75} |
| Low | {n} | {n * 0.125} |
| **Total** | **{sum}** | **{sum} points** |

### Critical Findings (P0)

#### Finding 1: {Title}
| Field | Value |
|-------|-------|
| Location | `{file}:{line}` |
| Vulnerability | {type} |
| OWASP | A0{n}:{name} |
| CVSS | {score} |
| Deduction | {points} |

**Evidence:**
```{lang}
{code snippet}
```

**Remediation:**
{specific fix with code example}

---

{Repeat for all findings}
```

## Integration with Brutal Reviewer

This skill provides the Security category scoring for the brutal-reviewer agent:

- **Weight:** 12% of total score
- **Maximum Deduction:** 9.0 points (capped)
- **Grade Thresholds:**
  - A: 0 critical, 0 high
  - B: 0 critical, 1-2 high
  - C: 0 critical, 3+ high OR 1 critical (fixed quickly)
  - D: 1-2 critical
  - F: 3+ critical OR any actively exploitable
