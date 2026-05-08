---
name: audit-security-dependencies
description: "Use when adding packages, bumping versions, or responding to security alerts. Enforces supply chain security and vulnerability remediation."
author: "Claude Code Learning Flywheel Team"
allowed-tools: ["Bash", "Read", "Edit", "Grep", "Glob"]
version: 1.0.0
last_verified: "2026-01-01"
tags: ["security", "dependencies", "supply-chain", "cve"]
related-skills: ["pr-review-standards"]
---

# Skill: Audit Security Dependencies

## Purpose
Prevent supply chain vulnerabilities and dependency bloat. Enforce rigorous security checks before adding or updating packages, preventing the introduction of known CVEs or malicious dependencies.

## 1. Negative Knowledge (Anti-Patterns)

| Failure Pattern | Context | Why It Fails |
| :--- | :--- | :--- |
| Blind Upgrades | `npm update` without checking breaking changes | Production outage, unexpected behavior |
| Vulnerable Versions | Installing packages with known CVEs | Security breach, data exposure |
| Scope Creep | Adding heavy library for single utility function | Bundle bloat, performance degradation |
| Unvetted Packages | Installing packages without checking reputation | Malicious code, supply chain attack |
| Ignoring Peer Warnings | Installing despite peer dependency conflicts | Runtime errors, incompatibilities |
| Outdated Dependencies | Never updating dependencies | Accumulating security debt |
| Dev Deps in Production | Including devDependencies in production builds | Larger bundle, potential vulnerabilities |

## 2. Verified Security Procedure

### Phase 1: Before Adding a New Package

**Research the package first:**

```bash
# Check package metadata
npm view <package-name>

# Check weekly downloads (higher = more trusted)
npm view <package-name> dist.tarball | head -n 1

# Check last publish date (recently maintained?)
npm view <package-name> time

# Check for known vulnerabilities
npm audit --audit-level=moderate
```

**Evaluate the package:**

| Criteria | Good Sign | Red Flag |
| :--- | :--- | :--- |
| Downloads/week | >100k | <1k |
| Last publish | <6 months ago | >2 years ago |
| GitHub stars | >1k | <50 |
| Open issues | <50 | >500 unresolved |
| License | MIT, Apache-2.0, BSD | Unlicensed, Custom |
| Maintainers | >2 active | Single maintainer, inactive |
| Dependencies | <10 | >50 (dependency hell) |

**Run security check:**

```bash
# Use the zero-context script
python .claude/skills/audit-security-dependencies/scripts/check_cves.py \
  --package <package-name> \
  --severity high
```

### Phase 2: Installing a Package

**Install with explicit version:**

```bash
# ❌ BAD: Install latest without pinning
npm install lodash

# ✅ GOOD: Pin to specific version
npm install lodash@4.17.21

# Check what was actually installed
npm list lodash
```

**Verify package contents:**

```bash
# Check package.json for suspicious scripts
cat node_modules/<package-name>/package.json

# Look for postinstall scripts (potential malware vector)
grep -i "postinstall\|preinstall" node_modules/<package-name>/package.json
```

**Run security audit:**

```bash
# Check for vulnerabilities
npm audit

# Fix auto-fixable vulnerabilities
npm audit fix

# Review what will be changed
npm audit fix --dry-run
```

### Phase 3: Updating Dependencies

**Check for breaking changes before updating:**

```bash
# Check outdated packages
npm outdated

# For major version updates, read CHANGELOG
npm view <package-name> versions
# Visit GitHub releases page to read breaking changes
```

**Update process:**

```
1. Update ONE package at a time
2. Read the changelog/migration guide
3. Update the package
4. Run tests
5. Commit
6. Repeat for next package
```

**Example workflow:**

```bash
# Step 1: Check what's outdated
npm outdated
# Output: react 17.0.2 → 18.2.0 (major update)

# Step 2: Read migration guide
# Visit: https://react.dev/blog/2022/03/08/react-18-upgrade-guide

# Step 3: Update
npm install react@18.2.0 react-dom@18.2.0

# Step 4: Run tests
npm test
# Fix any breaking changes

# Step 5: Run app locally
npm run dev
# Verify app works

# Step 6: Commit
git add package.json package-lock.json
git commit -m "deps: upgrade react 17 → 18"
```

### Phase 4: Responding to Security Alerts

**When you receive a security alert:**

```bash
# 1. Assess severity
npm audit

# 2. Understand the vulnerability
# Read the CVE details in the audit output

# 3. Check if fix is available
npm audit fix --dry-run

# 4. Apply fix if safe
npm audit fix

# 5. If no auto-fix, update manually
npm install <package>@<safe-version>

# 6. If no safe version, consider alternatives
npm uninstall <vulnerable-package>
npm install <alternative-package>
```

**Severity levels:**

| Level | Action Required | Timeline |
| :--- | :--- | :--- |
| Critical | Immediate fix | Same day |
| High | Urgent fix | Within 1 week |
| Moderate | Scheduled fix | Within 1 month |
| Low | Next maintenance window | Opportunistic |

### Phase 5: Dependency Hygiene

**Regular maintenance tasks:**

```bash
# Check for unused dependencies
npx depcheck

# Remove unused dependencies
npm uninstall <unused-package>

# Check for duplicate dependencies (bundle bloat)
npm dedupe

# Verify lockfile integrity
npm ci
```

**Lockfile discipline:**

```
✅ DO:
- Commit package-lock.json / yarn.lock
- Use `npm ci` in CI/CD (not `npm install`)
- Update lockfile with every dependency change

❌ DON'T:
- Delete lockfile to "fix" issues
- Edit lockfile manually
- Use different package managers in same project
```

## 3. Zero-Context Scripts

### check_cves.py

Located at: `.claude/skills/audit-security-dependencies/scripts/check_cves.py`

**Purpose:** Check npm/pip packages for known CVEs with strict thresholds.

**Usage:**
```bash
# Check a specific package
python check_cves.py --package express --severity high

# Check all dependencies
python check_cves.py --check-all --severity moderate

# Get JSON report
python check_cves.py --check-all --format json
```

**Output:**
```
Security Audit Report
═══════════════════════════════════════
Package: express
Version: 4.16.0

⚠️  HIGH SEVERITY VULNERABILITIES FOUND: 2

CVE-2022-24999: Regular Expression Denial of Service
  Severity: High
  Fixed in: 4.17.3
  Description: The qs module before 6.10.3 has a ReDoS vulnerability

CVE-2024-29041: Path Traversal
  Severity: High
  Fixed in: 4.19.2
  Description: Express allows attackers to traverse the filesystem

RECOMMENDATION: Upgrade to express@4.19.2 or later

Exit code: 1 (vulnerabilities found)
```

## 4. Dependency Decision Tree

**When considering adding a dependency:**

```
Is it a trivial utility (<20 lines of code)?
├─ YES → Write it yourself (avoid leftpad syndrome)
└─ NO → Continue

Does it have >100k weekly downloads?
├─ NO → Research thoroughly, consider alternatives
└─ YES → Continue

Has it been updated in the last 6 months?
├─ NO → Consider if maintained, check for forks
└─ YES → Continue

Does it have known HIGH or CRITICAL CVEs?
├─ YES → Find alternative or wait for patch
└─ NO → Continue

Does it add <100KB to bundle size?
├─ NO → Evaluate if worth the bloat
└─ YES → Safe to add (still run audit)
```

## 5. Extended Scenarios and Package Lists

**For detailed scenarios and command examples, see [reference.md](./reference.md):**

- **Scenario 1**: Security Alert in Production - Assess, test, deploy urgently
- **Scenario 2**: No Safe Version Available - Find alternatives, vendor, or fork
- **Scenario 3**: Dependency Conflict - Resolve peer dependency issues

**Approved packages:** date-fns, zod, vitest, pino (see reference.md for full list)
**Red flags:** Packages with eval(), obfuscated code, or typosquatting (see reference.md)

## 7. Failed Attempts (Negative Knowledge Evolution)

| Attempt | Context | Learning |
| :--- | :--- | :--- |
| Auto-update all deps weekly | Automated PRs broke production 3x | Update deliberately, read changelogs |
| Ignore low severity CVEs | Only fixed high/critical | Fix all CVEs, they can be chained |
| Add packages for single functions | Installed is-even, added 5 deps | Write simple utilities yourself |
| Use wildcard versions | Set "*" in package.json | Always pin versions, use exact or ~tilde |

## 8. Security Checklist

Before committing dependency changes:

- [ ] **Audit Clean**: `npm audit` shows no high/critical vulnerabilities
- [ ] **Tests Pass**: Full test suite passes
- [ ] **Bundle Size**: Check bundle size didn't increase unreasonably
- [ ] **Lockfile Updated**: package-lock.json is committed
- [ ] **Changelog Read**: For major updates, read migration guide
- [ ] **Alternatives Considered**: Evaluated if package is necessary
- [ ] **License Compatible**: Package license is compatible with project
- [ ] **Maintainer Vetted**: Package is actively maintained

## 9. Tools & Commands Reference

**For comprehensive command references, see [reference.md](./reference.md):**

- NPM: `npm audit`, `npm audit fix`, `npm outdated`, `npm view <package>`
- Yarn: `yarn audit`, `yarn upgrade-interactive`, `yarn why <package>`
- pnpm: `pnpm audit`, `pnpm update`, `pnpm why <package>`
- Python: `pip-audit`, `pip list --outdated`, `pip show <package>`
- Security Scanners: snyk, Socket.dev, npm-check, bundlephobia

## 10. Governance
- **Token Budget:** ~390 lines (within 400 recommended limit)
- **Dependencies:** Python 3.8+ for CVE checking script, npm/pip
- **Pattern Origin:** OWASP Top 10, Supply Chain Security Best Practices
- **Maintenance:** Update vulnerability patterns monthly
- **Verification Date:** 2026-01-01
