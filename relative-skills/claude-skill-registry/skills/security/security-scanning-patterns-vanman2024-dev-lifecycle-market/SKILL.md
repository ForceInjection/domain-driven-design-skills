---
name: Security Scanning Patterns
description: Security vulnerability scanning, secret detection, dependency auditing, and OWASP best practices. Use when performing security audits, scanning for vulnerabilities, detecting exposed secrets, checking dependencies, validating security headers, implementing OWASP patterns, or when user mentions security, vulnerabilities, secrets, CVE, OWASP, npm audit, security headers, or penetration testing.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Security Scanning Patterns

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Comprehensive security scanning capabilities including secret detection, dependency vulnerability scanning, OWASP Top 10 pattern detection, security header validation, and automated security reporting. Supports multiple languages (JavaScript, TypeScript, Python, Go, Rust, Java) and provides actionable remediation guidance.

## Instructions

### 1. Secret Detection

Scan codebases for exposed credentials, API keys, tokens, and sensitive data:

**Process:**
1. Use `bash scripts/scan-secrets.sh <target-directory>` to scan for secrets
2. Reference `templates/secret-patterns.json` for comprehensive regex patterns
3. Check for AWS keys, GitHub tokens, API keys, passwords, private keys, certificates
4. Scan git history for previously committed secrets
5. Generate detailed findings with file paths and line numbers

**Patterns Detected:**
- AWS Access Keys (AKIA..., ASIA...)
- GitHub Personal Access Tokens (ghp_, gho_, ghs_)
- API Keys (generic patterns, vendor-specific)
- Private Keys (RSA, SSH, PGP)
- Database Connection Strings
- OAuth Tokens and Secrets
- JWT Tokens with sensitive data
- Hardcoded passwords and credentials

**Output:** JSON report with severity, location, and remediation steps

### 2. Dependency Vulnerability Scanning

Scan project dependencies for known CVEs across multiple ecosystems:

**Process:**
1. Use `bash scripts/scan-dependencies.sh <project-directory>` for multi-language scanning
2. Auto-detects package managers: npm, pip, cargo, go.mod, Maven, Gradle
3. Queries vulnerability databases (NVD, GitHub Advisory, OSV)
4. Reports CVE-IDs, CVSS scores, and affected versions

**Supported Ecosystems:**
- JavaScript/TypeScript: npm audit, yarn audit, pnpm audit
- Python: safety check, pip-audit
- Rust: cargo audit
- Go: govulncheck
- Java: Maven dependency-check, OWASP dependency-check
- Ruby: bundle audit

**Output:** Vulnerability report with severity ratings and upgrade paths

### 3. OWASP Top 10 Pattern Detection

Scan code for common OWASP Top 10 vulnerabilities:

**Process:**
1. Use `bash scripts/scan-owasp.sh <codebase-directory>` to detect patterns
2. Checks for SQL injection risks, XSS vulnerabilities, insecure deserialization
3. Identifies authentication/authorization flaws
4. Detects security misconfigurations and sensitive data exposure

**OWASP Categories Covered:**
- A01:2021 - Broken Access Control
- A02:2021 - Cryptographic Failures
- A03:2021 - Injection (SQL, NoSQL, Command, LDAP)
- A04:2021 - Insecure Design
- A05:2021 - Security Misconfiguration
- A06:2021 - Vulnerable and Outdated Components
- A07:2021 - Identification and Authentication Failures
- A08:2021 - Software and Data Integrity Failures
- A09:2021 - Security Logging and Monitoring Failures
- A10:2021 - Server-Side Request Forgery (SSRF)

**Output:** Categorized findings with OWASP reference links

### 4. Security Header Validation

Validate HTTP security headers for web applications:

**Process:**
1. Use `bash scripts/check-security-headers.sh <url-or-config>` to validate headers
2. Reference `templates/security-headers-config.json` for recommended settings
3. Checks for missing or misconfigured security headers
4. Provides configuration examples for common web servers

**Headers Validated:**
- Content-Security-Policy (CSP)
- Strict-Transport-Security (HSTS)
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection
- Referrer-Policy
- Permissions-Policy
- Cross-Origin-Opener-Policy (COOP)
- Cross-Origin-Resource-Policy (CORP)
- Cross-Origin-Embedder-Policy (COEP)

**Output:** Header compliance report with configuration recommendations

### 5. Comprehensive Security Reporting

Generate aggregated security reports combining all scan results:

**Process:**
1. Use `bash scripts/generate-security-report.sh <scan-results-directory>` to aggregate
2. Choose output format: HTML (`templates/security-report-html.template`) or JSON (`templates/security-report-json.template`)
3. Includes executive summary, detailed findings, risk ratings, remediation priorities
4. Reference `templates/vulnerability-remediation.md` for fix guidance

**Report Sections:**
- Executive Summary (critical findings count, risk score)
- Secret Detection Results
- Dependency Vulnerabilities
- OWASP Compliance Status
- Security Header Analysis
- Detailed Findings (sorted by severity)
- Remediation Roadmap (prioritized action items)
- Compliance Mapping (OWASP, CWE, CVE references)

**Output Formats:** HTML dashboard, JSON data, Markdown summary, SARIF format

### 6. Security Checklist Validation

Use `templates/security-checklist.md` for comprehensive security reviews:

**Categories:**
- Authentication & Authorization
- Input Validation & Sanitization
- Data Protection & Encryption
- Session Management
- API Security
- Infrastructure Security
- Logging & Monitoring
- Incident Response Readiness

## Available Scripts

- **scripts/scan-secrets.sh**: Comprehensive secret and credential detection (100+ patterns)
- **scripts/scan-dependencies.sh**: Multi-language dependency vulnerability scanner
- **scripts/check-security-headers.sh**: HTTP security header validator
- **scripts/scan-owasp.sh**: OWASP Top 10 vulnerability pattern detector
- **scripts/generate-security-report.sh**: Aggregated security report generator

## Templates

- **templates/secret-patterns.json**: Comprehensive regex patterns for 50+ secret types
- **templates/security-report-html.template**: Professional HTML security report template
- **templates/security-report-json.template**: Structured JSON report schema
- **templates/security-checklist.md**: Comprehensive OWASP-based security checklist
- **templates/security-headers-config.json**: Recommended security header configurations
- **templates/vulnerability-remediation.md**: Remediation guides for common vulnerabilities

## Examples

- **examples/basic-secret-scanning.md**: Step-by-step secret scanning walkthrough
- **examples/dependency-scanning.md**: Multi-language dependency scanning examples
- **examples/owasp-compliance.md**: OWASP Top 10 compliance validation
- **examples/ci-cd-security-integration.md**: CI/CD pipeline security automation
- **examples/security-report-interpretation.md**: How to read and act on security reports

## Workflow

**Typical Security Audit Process:**

1. **Initial Scan:** Run all scanners against the codebase
   ```bash
   bash scripts/scan-secrets.sh ./project
   bash scripts/scan-dependencies.sh ./project
   bash scripts/scan-owasp.sh ./project
   bash scripts/check-security-headers.sh https://example.com
   ```

2. **Generate Report:** Aggregate results into comprehensive report
   ```bash
   bash scripts/generate-security-report.sh ./scan-results --format html
   ```

3. **Review Findings:** Analyze security-report.html, prioritize critical issues

4. **Remediate:** Use `templates/vulnerability-remediation.md` for fix guidance

5. **Validate:** Re-scan after fixes to confirm remediation

6. **CI/CD Integration:** Add security scans to pipeline (see `examples/ci-cd-security-integration.md`)

## Best Practices

- Run security scans before every release
- Integrate scans into CI/CD pipelines
- Treat critical vulnerabilities as build-breaking
- Maintain a security baseline and track improvements
- Review security checklists during code reviews
- Keep secret patterns updated with new services
- Subscribe to security advisories for dependencies
- Perform regular security audits (quarterly minimum)

## Requirements

- Bash 4.0+ for script execution
- curl or wget for HTTP header validation
- jq for JSON processing
- grep with PCRE support for pattern matching
- Language-specific tools: npm/yarn, pip, cargo, go (if scanning those languages)
- Internet connection for CVE database queries

## Integration Points

- Works with CI/CD tools: GitHub Actions, GitLab CI, Jenkins, CircleCI
- Exports to SARIF format for GitHub Security tab
- JSON output compatible with security dashboards
- Can trigger alerts via webhooks on critical findings
