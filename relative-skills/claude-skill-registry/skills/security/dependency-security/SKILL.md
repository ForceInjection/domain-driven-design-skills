---
name: dependency-security
description: Dependency security scanning. Use when auditing npm packages for vulnerabilities.
---

# Dependency Security Skill

This skill covers security scanning for npm dependencies.

## When to Use

Use this skill when:
- Auditing project dependencies
- Setting up security CI/CD
- Responding to vulnerability alerts
- Evaluating new dependencies

## Core Principle

**DEFENSE IN DEPTH** - Use multiple tools for security scanning. No single tool catches everything.

## npm audit

### Basic Usage

```bash
# Run audit
npm audit

# JSON output for parsing
npm audit --json

# Only high/critical
npm audit --audit-level=high

# Production dependencies only
npm audit --omit=dev
```

### Auto-Fix

```bash
# Safe fixes (semver-compatible)
npm audit fix

# Force fixes (may have breaking changes)
npm audit fix --force

# Dry run
npm audit fix --dry-run
```

### Understanding Output

```
# vulnerabilities found

Severity: high
Package: example-package
Dependency of: my-dep
Path: my-dep > sub-dep > example-package
More info: https://npmjs.com/advisories/XXXXX
```

## Snyk

### Installation

```bash
npm install -g snyk
snyk auth
```

### Usage

```bash
# Test for vulnerabilities
snyk test

# Monitor project (continuous)
snyk monitor

# High severity only
snyk test --severity-threshold=high

# Specific package
snyk test --package-manager=npm
```

### CI Integration

```yaml
- name: Snyk Security Scan
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high
```

## Socket.dev

### Installation

```bash
npm install -g @socketsecurity/cli
```

### Usage

```bash
# Scan for supply chain issues
npx @socketsecurity/cli scan

# Detailed report
npx @socketsecurity/cli report
```

### What Socket Detects

- Typosquatting attacks
- Protestware
- Malicious packages
- Unexpected behavior
- Network access
- Shell access

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| Critical | RCE, data breach | Fix immediately |
| High | Privilege escalation | Fix within 24 hours |
| Moderate | DoS, info disclosure | Fix within 1 week |
| Low | Minor issues | Fix when convenient |

## Security Audit Workflow

### 1. Initial Assessment

```bash
# Full audit
npm audit

# Check for outdated packages
npm outdated
```

### 2. Vulnerability Analysis

For each vulnerability:
1. Check if it affects your usage
2. Look for patches or updates
3. Evaluate alternative packages
4. Document if accepted risk

### 3. Remediation

```bash
# Update specific package
npm update package-name

# Update to latest
npm install package-name@latest

# Replace package
npm uninstall vulnerable-package
npm install alternative-package
```

### 4. Verification

```bash
# Re-run audit
npm audit

# Run tests
npm test
```

## Lock File Security

### Verify Lock File Integrity

```bash
# Verify package-lock.json
npm ci  # Clean install from lock file

# Check for lock file modifications
git diff package-lock.json
```

### Lock File Best Practices

1. **Always commit lock files**
2. **Use `npm ci` in CI/CD**
3. **Review lock file changes in PRs**
4. **Never manually edit lock files**

## Dependency Evaluation

### Before Adding Dependencies

1. **Check npm page** - Downloads, maintenance, issues
2. **Check Snyk DB** - Known vulnerabilities
3. **Check Socket.dev** - Supply chain risks
4. **Check license** - Compatibility

### Evaluation Checklist

- [ ] Active maintenance (recent commits)
- [ ] High download count
- [ ] No critical vulnerabilities
- [ ] Acceptable license
- [ ] Reasonable dependency tree
- [ ] Type definitions available

## Automated Security

### Dependabot Configuration

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    groups:
      dev-dependencies:
        dependency-type: "development"
```

### Renovate Configuration

```json
{
  "extends": ["config:base"],
  "packageRules": [
    {
      "matchUpdateTypes": ["minor", "patch"],
      "automerge": true
    }
  ]
}
```

## CI Pipeline Security

```yaml
name: Security

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 * * *'  # Daily

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '22'

      - name: Install dependencies
        run: npm ci

      - name: npm audit
        run: npm audit --audit-level=high

      - name: Snyk scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## Handling Vulnerabilities

### When Patch Available

```bash
npm audit fix
# or
npm update vulnerable-package
```

### When No Patch Available

1. **Check if vulnerability applies** - May not affect your usage
2. **Use override** - Force specific version

```json
{
  "overrides": {
    "vulnerable-package": "2.0.0"
  }
}
```

3. **Replace dependency** - Find alternative
4. **Accept risk** - Document and track

### Documentation

```markdown
## Security Exceptions

### vulnerable-package@1.0.0
- **Vulnerability**: CVE-2024-XXXXX
- **Reason Accepted**: Only used in tests, not production
- **Review Date**: 2024-12-01
- **Assignee**: @developer
```

## Best Practices Summary

1. **Run audit regularly** - At least weekly
2. **Use multiple tools** - npm audit + Snyk + Socket
3. **Automate updates** - Dependabot or Renovate
4. **Review before merge** - Check lock file changes
5. **Document exceptions** - Track accepted risks
6. **Monitor dependencies** - Snyk monitor
7. **Keep dependencies minimal** - Fewer deps = smaller attack surface

## Code Review Checklist

- [ ] npm audit passes with no high/critical
- [ ] Lock file committed
- [ ] New dependencies evaluated
- [ ] Vulnerable dependencies documented
- [ ] CI security checks configured
- [ ] Dependabot/Renovate enabled
