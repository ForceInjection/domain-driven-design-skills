---
name: dependency-vulnerability-scanner
description: Scans dependencies for known vulnerabilities (npm audit, pip-audit, etc.), generates reports, and suggests fixes. Use when user asks to "check vulnerabilities", "security scan", "audit dependencies", "check CVEs", or "vulnerable packages".
allowed-tools: [Read, Write, Bash, Glob]
---

# Dependency Vulnerability Scanner

Scans project dependencies for known security vulnerabilities and provides remediation guidance.

## When to Use

- "Check for vulnerable dependencies"
- "Security audit my dependencies"
- "Scan for CVEs"
- "Check npm/pip vulnerabilities"
- "Update vulnerable packages"

## Instructions

### 1. Detect Package Manager

```bash
# Node.js
[ -f "package.json" ] && echo "npm/yarn"

# Python
[ -f "requirements.txt" ] && echo "pip"

# Ruby
[ -f "Gemfile" ] && echo "bundler"

# Go
[ -f "go.mod" ] && echo "go modules"

# Rust
[ -f "Cargo.toml" ] && echo "cargo"
```

### 2. Run Security Audit

## npm (Node.js)

**Basic audit:**
```bash
npm audit

# Output:
# found 3 vulnerabilities (2 moderate, 1 high)
# run `npm audit fix` to fix them
```

**Detailed report:**
```bash
npm audit --json > audit-report.json
npm audit --production  # Only production dependencies
```

**Auto-fix:**
```bash
npm audit fix            # Safe fixes
npm audit fix --force    # May introduce breaking changes
```

## Yarn

```bash
yarn audit

# Fix vulnerabilities
yarn upgrade-interactive

# Generate report
yarn audit --json > audit-report.json
```

## pip (Python)

```bash
# Install pip-audit
pip install pip-audit

# Run audit
pip-audit

# With fix suggestions
pip-audit --fix

# Check requirements file
pip-audit --requirement requirements.txt

# Output JSON
pip-audit --format json > audit-report.json
```

## Safety (Python alternative)

```bash
pip install safety

# Check installed packages
safety check

# Check requirements
safety check --file requirements.txt

# Full report
safety check --full-report
```

## Bundle Audit (Ruby)

```bash
gem install bundler-audit

# Update vulnerability database
bundle audit update

# Run audit
bundle audit check

# Auto-update
bundle audit check --update
```

## Snyk (Multi-language)

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test project
snyk test

# Monitor continuously
snyk monitor

# Fix vulnerabilities
snyk fix
```

## OWASP Dependency-Check

```bash
# Download
wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.0.0/dependency-check-8.0.0-release.zip
unzip dependency-check-8.0.0-release.zip

# Run scan
./dependency-check/bin/dependency-check.sh \
  --project "My Project" \
  --scan ./

# Generate HTML report
--format HTML --out ./reports
```

### 3. Parse and Categorize Results

**Severity levels:**
- **Critical**: Immediate action required
- **High**: Fix ASAP
- **Moderate**: Plan to fix
- **Low**: Monitor and assess

**Example output analysis:**
```json
{
  "vulnerabilities": [
    {
      "name": "lodash",
      "severity": "high",
      "via": ["prototype-pollution"],
      "fixAvailable": {
        "name": "lodash",
        "version": "4.17.21"
      }
    }
  ]
}
```

### 4. Generate Security Report

```markdown
# Dependency Vulnerability Report

**Date:** 2024-01-15
**Project:** my-app
**Total Dependencies:** 250
**Vulnerabilities Found:** 12

## Summary

- Critical: 1
- High: 3
- Moderate: 5
- Low: 3

## Critical Vulnerabilities

### 1. Prototype Pollution in lodash (CVE-2020-8203)

**Severity:** Critical
**Package:** lodash@4.17.15
**Fixed in:** lodash@4.17.21
**CVSS Score:** 9.8

**Description:**
Prototype pollution vulnerability allows attackers to modify object prototypes.

**Impact:**
Remote code execution possible if attacker controls input to vulnerable functions.

**Remediation:**
```bash
npm install lodash@4.17.21
```

**Priority:** Immediate (deploy within 24 hours)

## High Vulnerabilities

### 2. Regular Expression Denial of Service in trim (CVE-2020-7753)

**Severity:** High
**Package:** trim@0.0.1
**Fixed in:** trim@1.0.1
**CVSS Score:** 7.5

**Description:**
ReDoS vulnerability in input parsing.

**Remediation:**
```bash
npm install trim@1.0.1
```

**Priority:** High (fix this week)

[... more vulnerabilities ...]

## Recommendations

1. **Immediate Actions (Critical)**
   - Update lodash to 4.17.21
   - Test thoroughly
   - Deploy to production

2. **Short-term (High)**
   - Update trim, axios, express
   - Review indirect dependencies
   - Run integration tests

3. **Long-term (Moderate/Low)**
   - Schedule updates for moderate issues
   - Monitor low severity issues
   - Consider alternative packages

## Prevention

- Enable Dependabot/Renovate
- Run audits in CI/CD
- Review dependencies before adding
- Keep dependencies up to date
```

### 5. Automated Scanning in CI/CD

**GitHub Actions:**
```yaml
name: Security Audit

on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly
  pull_request:
  push:
    branches: [main]

jobs:
  audit:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Run npm audit
        run: |
          npm audit --audit-level=moderate
          npm audit --json > audit-report.json

      - name: Upload audit report
        uses: actions/upload-artifact@v3
        with:
          name: audit-report
          path: audit-report.json

      - name: Fail on high vulnerabilities
        run: npm audit --audit-level=high
```

**With Snyk:**
```yaml
- name: Run Snyk
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high
```

### 6. Dependabot Configuration

`.github/dependabot.yml`:
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"
    commit-message:
      prefix: "chore"
      include: "scope"

  # Security updates only
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 5
    allow:
      - dependency-type: "direct"
    versioning-strategy: increase-if-necessary
```

### 7. License Compliance

**Check licenses:**
```bash
# Install license-checker
npm install -g license-checker

# Check all licenses
license-checker

# Generate report
license-checker --json > licenses.json

# Check for problematic licenses
license-checker --onlyAllow 'MIT;Apache-2.0;BSD-3-Clause'
```

**Python:**
```bash
pip install pip-licenses

pip-licenses

# Format as table
pip-licenses --format=markdown

# Check compatibility
pip-licenses --fail-on 'GPL'
```

### 8. Supply Chain Security

**Verify package integrity:**
```bash
# npm
npm audit signatures

# Check for suspicious packages
npx socket npm i lodash
```

**Monitor for typosquatting:**
```bash
# Install confused
npm install -g confused

# Check for dependency confusion
confused -l package.json
```

### 9. Continuous Monitoring

**Setup alerts:**

```javascript
// In package.json
{
  "scripts": {
    "audit": "npm audit",
    "audit:fix": "npm audit fix",
    "audit:report": "npm audit --json > reports/audit-$(date +%Y%m%d).json",
    "precommit": "npm audit --audit-level=high"
  }
}
```

**Husky hook:**
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "npm audit --audit-level=high"
    }
  }
}
```

### 10. Best Practices

**DO:**
- Run audits regularly (weekly minimum)
- Fix critical/high vulnerabilities immediately
- Review audit reports before releases
- Use automated tools (Dependabot, Renovate)
- Monitor security advisories
- Document exceptions/accepted risks
- Test fixes in staging first

**DON'T:**
- Ignore audit warnings
- Use --force without understanding impact
- Skip security updates
- Add packages without review
- Disable audit checks
- Use outdated dependencies unnecessarily

### Common Vulnerability Types

**1. Prototype Pollution**
```javascript
// Vulnerable code
function merge(target, source) {
  for (let key in source) {
    target[key] = source[key]
  }
}

// Attack
merge({}, JSON.parse('{"__proto__":{"isAdmin":true}}'))

// Fix: Use Object.create(null) or hasOwnProperty
```

**2. Regular Expression DoS (ReDoS)**
```javascript
// Vulnerable regex
/^(a+)+$/

// Attack: Long string of 'a's causes catastrophic backtracking

// Fix: Avoid nested quantifiers, use atomic groups
```

**3. SQL Injection**
```javascript
// Vulnerable
db.query(`SELECT * FROM users WHERE id = ${userId}`)

// Fix: Use parameterized queries
db.query('SELECT * FROM users WHERE id = ?', [userId])
```

**4. Cross-Site Scripting (XSS)**
```javascript
// Vulnerable
element.innerHTML = userInput

// Fix: Use textContent or sanitize
element.textContent = userInput
// or
element.innerHTML = DOMPurify.sanitize(userInput)
```

### Remediation Priority Matrix

| Severity | Exploitability | Priority | Timeline |
|----------|----------------|----------|----------|
| Critical | High | P0 | 24 hours |
| Critical | Medium | P1 | 1 week |
| High | High | P1 | 1 week |
| High | Medium | P2 | 2 weeks |
| Moderate | High | P2 | 2 weeks |
| Moderate | Medium | P3 | 1 month |
| Low | Any | P4 | Next cycle |

### Compliance Requirements

**SOC 2:**
- Regular vulnerability scanning
- Documented remediation process
- Evidence of timely fixes

**PCI DSS:**
- Monthly vulnerability scans
- Fix critical vulnerabilities within 30 days
- Patch management process

**HIPAA:**
- Regular security assessments
- Document risk analysis
- Timely vulnerability remediation

### Tools Comparison

| Tool | Languages | Cost | Features |
|------|-----------|------|----------|
| npm audit | Node.js | Free | Basic, fast |
| Snyk | Multi | Free tier | Advanced, auto-fix |
| Dependabot | Multi | Free | Auto PRs |
| WhiteSource | Multi | Paid | Enterprise features |
| Sonatype | Multi | Paid | Policy enforcement |
