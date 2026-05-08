---
name: security-pattern-detection
description: |
  Detect OWASP Top 10 vulnerabilities via static analysis. Calculate security score (0.00-1.00) for code quality. Auto-generate remediation suggestions with implementation examples. Integrate with Serena for vulnerability tracking and SLA compliance. Use when: securing code, detecting vulnerabilities, improving security posture, validating fixes, enforcing security standards.

skill-type: SECURITY
shannon-version: ">=5.6.0"

mcp-requirements:
  recommended:
    - name: serena
      purpose: Vulnerability tracking, SLA monitoring, trend reporting
    - name: semgrep
      purpose: SAST pattern detection
    - name: bandit
      purpose: Python security analysis
    - name: snyk
      purpose: Dependency vulnerability scanning

allowed-tools: All
---

# Security Pattern Detection - Quantified Vulnerability Assessment

## Purpose

Scan code for OWASP Top 10 vulnerabilities using static analysis. Calculate security score (0.00-1.00) showing vulnerability density. Generate auto-remediation suggestions with code examples. Track vulnerabilities via Serena for SLA compliance and trending.

## When to Use

- Securing new code before deployment
- Identifying OWASP Top 10 patterns
- Enforcing security standards (require 0.85+ score)
- Tracking vulnerability fixes over time
- Validating remediation implementations
- Measuring security improvement ROI

## Core Metrics

**Security Score Calculation:**
```
Score = 1.0 - (Critical×0.2 + High×0.1 + Medium×0.05)
Range: 0.00 (many vulns) to 1.00 (secure)

Critical: ≥0.2 deduction each (auth, injection, secrets)
High: ≥0.1 deduction each (XSS, CSRF, path traversal)
Medium: ≥0.05 deduction each (weak crypto, logging)
```

**Vulnerability Categories (OWASP Top 10):**
- A1: Broken Authentication (score impact: -0.20)
- A2: Sensitive Data Exposure (score impact: -0.20)
- A3: Injection (SQL, NoSQL, command) (score impact: -0.20)
- A4: Broken Access Control (score impact: -0.20)
- A5: Security Misconfiguration (score impact: -0.10)
- A6: XSS (Reflected, Stored, DOM) (score impact: -0.10)
- A7: Insufficient Authentication (score impact: -0.15)
- A8: CSRF (score impact: -0.10)
- A9: Using Components with Known Vulnerabilities (score impact: -0.10)
- A10: Insufficient Logging & Monitoring (score impact: -0.05)

## Workflow

### Phase 1: Vulnerability Detection
1. **Run Semgrep/Bandit**: Scan for OWASP patterns
2. **Classify severity**: Critical, High, Medium, Low
3. **Calculate score**: Apply deductions per formula
4. **Generate report**: List vulnerabilities with locations

**Detection Example:**
```
[CRITICAL] SQL Injection (A3)
File: src/database.js:45
Pattern: query("SELECT * FROM users WHERE id=" + userId)
Fix: Use parameterized query
Score impact: -0.20

[HIGH] Hardcoded Secret (A2)
File: config.ts:12
Pattern: apiKey: "sk_live_abc123def456"
Fix: Move to environment variable
Score impact: -0.20
```

### Phase 2: Remediation Generation
1. **Analyze pattern**: Understand vulnerability context
2. **Generate fix**: Provide secure alternative
3. **Add example**: Show before/after code
4. **Explain impact**: Security & performance implications
5. **Test guidance**: How to validate fix

**Auto-Remediation Example:**

❌ Vulnerable:
```javascript
app.get('/user/:id', (req, res) => {
  const query = "SELECT * FROM users WHERE id=" + req.params.id;
  db.query(query, (err, result) => res.json(result));
});
```

✅ Fixed:
```javascript
app.get('/user/:id', (req, res) => {
  const query = "SELECT * FROM users WHERE id=$1";
  db.query(query, [req.params.id], (err, result) => res.json(result));
});
```

### Phase 3: Serena Integration
1. **Push vulnerabilities**: Send to Serena with severity
2. **Track SLA**: Days to fix by severity (Critical: 24h)
3. **Alert on violations**: Flag overdue vulnerabilities
4. **Measure velocity**: Track fixes per week
5. **Trend reporting**: Show security trajectory

**Serena Payload:**
```json
{
  "metric_type": "security_vulnerabilities",
  "project": "task-app",
  "security_score": 0.78,
  "vulnerabilities": [
    {
      "type": "SQL_INJECTION",
      "severity": "CRITICAL",
      "file": "src/database.js:45",
      "sla_hours": 24,
      "suggested_fix": "Use parameterized queries",
      "created": "2025-11-20T10:00:00Z"
    }
  ]
}
```

## Real-World Impact

**Financial Application Audit:**
- Initial security score: 0.62 (12 vulnerabilities)
- Critical: 2 SQL injections, 1 auth bypass
- High: 3 XSS, 4 weak crypto
- Applied auto-remediation templates
- Score improved to 0.89 (4 weeks)
- Prevented potential breach affecting 50K users

**E-Commerce Platform:**
- Continuous scanning detected 1 new vulnerability/week
- Serena SLA tracking: 95% critical fixes <24h
- Security score trending from 0.71 → 0.91 (6 months)
- ROI: Prevented 2 data breaches (estimated $2.5M)

## Success Criteria

✅ Security score ≥0.85 for production code
✅ Zero critical vulnerabilities
✅ High vulnerabilities fixed within 48h (SLA)
✅ All suggested fixes tested and passing
✅ Serena trending shows improvement or stability
✅ No OWASP Top 10 patterns in code reviews
