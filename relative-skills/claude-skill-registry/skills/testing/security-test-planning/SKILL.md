---
name: security-test-planning
description: Plan security testing strategies including OWASP testing, penetration test scoping, SAST/DAST integration, and threat-based test case design.
allowed-tools: Read, Write, Glob, Grep, Task, WebSearch, WebFetch
---

# Security Test Planning

## When to Use This Skill

Use this skill when:

- **Security Test Planning tasks** - Planning security testing strategies for applications
- **Planning or design** - Need guidance on OWASP testing, pen test scoping, SAST/DAST
- **Best practices** - Want to follow established security testing standards

## Overview

Security testing validates that applications are protected against threats and vulnerabilities. A comprehensive security test strategy combines automated scanning, manual testing, and threat-based test case design.

---

## Security Testing Pyramid

```text
                    ┌───────────┐
                   /  Pentest    \         Manual, Expert
                  /   Red Team    \        (Quarterly)
                 /─────────────────\
                /      DAST          \     Dynamic Scanning
               /    (Runtime)         \    (Weekly/Release)
              /───────────────────────\
             /         SAST             \  Static Analysis
            /      (Build Time)          \ (Every Commit)
           /─────────────────────────────\
          /      Secret Scanning           \ Pre-Commit
         /     Dependency Scanning          \ (Continuous)
        └───────────────────────────────────┘
```

---

## Quick Reference: Testing Layers

| Layer | Tools | Frequency | Gate |
|-------|-------|-----------|------|
| Layer 1 (CI/CD) | Gitleaks, SonarQube, Snyk, Trivy | Every commit | Block Critical |
| Layer 2 (Periodic) | OWASP ZAP, Burp, 42Crunch | Weekly/Release | Block High+ |
| Layer 3 (Manual) | Penetration testing, Code review | Quarterly | Block All |

---

## OWASP Top 10 Quick Coverage

| Category | Testing Approach |
|----------|------------------|
| A01: Broken Access Control | Manual + Automated |
| A02: Cryptographic Failures | Code review + SAST |
| A03: Injection | SAST + DAST + Manual |
| A04: Insecure Design | Threat modeling |
| A05: Security Misconfiguration | Config scanning |
| A06: Vulnerable Components | SCA |
| A07: Auth Failures | Manual + Automated |
| A08: Data Integrity | Manual testing |
| A09: Logging Failures | Log review |
| A10: SSRF | DAST + Manual |

---

## Remediation SLAs

| Severity | SLA | Verification |
|----------|-----|--------------|
| Critical | 24 hours | Immediate retest |
| High | 7 days | Next sprint retest |
| Medium | 30 days | Quarterly scan |
| Low | 90 days | Annual review |

---

## References

| Reference | Content | When to Load |
| --- | --- | --- |
| [security-strategy-template.md](references/security-strategy-template.md) | Full strategy template, scope, compliance, metrics | Planning security test strategy |
| [owasp-testing.md](references/owasp-testing.md) | WSTG test categories, test case template | Writing OWASP-aligned test cases |
| [dotnet-security-tests.md](references/dotnet-security-tests.md) | Auth, input validation, rate limiting tests | Implementing .NET security tests |
| [sast-dast-integration.md](references/sast-dast-integration.md) | CI/CD gates, ZAP integration, tool comparison | Setting up automated security scanning |

---

## Integration Points

**Inputs from**:

- Threat model → Test priorities
- Security requirements → Coverage targets
- `test-strategy-planning` skill → Overall strategy

**Outputs to**:

- CI/CD pipeline → Security gates
- `devsecops-practices` skill (security plugin) → Remediation
- Compliance reporting → Evidence

---

## Test Scenarios

### Scenario 1: Planning security test strategy

**Query:** "Help me create a security test plan for our web application"

**Expected:** Skill activates, provides strategy template, guides through scope and layers

### Scenario 2: OWASP-aligned testing

**Query:** "What OWASP tests should I run for authentication?"

**Expected:** Skill activates, loads owasp-testing.md reference, provides WSTG-ATHN tests

### Scenario 3: .NET security tests

**Query:** "Show me how to test for SQL injection in .NET"

**Expected:** Skill activates, loads dotnet-security-tests.md reference, provides code examples

---

**Last Updated:** 2025-12-28

## Version History

- **v1.1.0** (2025-12-28): Refactored to progressive disclosure - extracted tests/templates to references/
- **v1.0.0** (2025-12-26): Initial release
