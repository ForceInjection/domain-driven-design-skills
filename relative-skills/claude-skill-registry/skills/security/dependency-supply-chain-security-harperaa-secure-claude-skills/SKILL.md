---
name: dependency-supply-chain-security
description: Manage dependencies and supply chain security to prevent vulnerable or malicious packages. Use this skill when you need to audit dependencies, update packages, check for vulnerabilities, understand supply chain attacks, or maintain dependency security. Triggers include "dependencies", "npm audit", "supply chain", "package security", "vulnerability", "npm update", "security audit", "outdated packages".
---

# Dependency & Supply Chain Security

## The Dependency Risk

Your application includes hundreds of npm packages. Each one is code written by someone else that runs in your application **with full privileges**.

### The Statistics Are Sobering

According to Sonatype's 2024 State of the Software Supply Chain Report:

- **245,000 malicious packages** published to npm (2023)
- **700% increase** in supply chain attacks (vs 2022)
- Average application has **200+ dependencies**
- Each dependency averages **5 transitive dependencies** (dependencies of dependencies)

### Real-World Supply Chain Attacks

**event-stream Incident (2018):**
A popular npm package (2 million downloads/week) was hijacked. The attacker added code that stole cryptocurrency wallet keys. **Thousands of applications were affected** before discovery.

**ua-parser-js Incident (2021):**
Package with 8 million weekly downloads was compromised. Attackers added cryptocurrency mining and password-stealing code.

**colors.js / faker.js Incident (2022):**
Maintainer intentionally corrupted packages in protest. Millions of applications broke. Demonstrated single-point-of-failure risk.

## Our Dependency Security Architecture

### Current Status

- ✅ All dependencies up-to-date
- ✅ Next.js 15.5.4 (latest stable)
- ✅ 0 known vulnerabilities (npm audit)
- ✅ Package-lock.json committed (reproducible builds)

### Why Next.js 15.5.4 Specifically

We updated from 15.3.5 to 15.5.4 to fix **three security vulnerabilities:**
- Cache Key Confusion (moderate)
- Content Injection (moderate)
- SSRF via Middleware Redirects (moderate)

**Keeping frameworks updated is critical.** According to Snyk's research, 80% of vulnerabilities have patches available within days, but **average time to patch is 148 days**.

## Implementation Files

- `scripts/security-check.sh` - Runs npm audit + shows outdated packages
- `package-lock.json` - Locks exact versions (supply chain consistency)

## Running Security Audits

### Basic Audit

```bash
# Check for vulnerabilities
npm audit

# Output shows:
# - Severity (critical, high, moderate, low)
# - Vulnerability description
# - Affected package
# - Recommended fix
```

### Production-Only Audit

```bash
# Only check production dependencies (ignores devDependencies)
npm audit --production
```

**Use this before every production deploy.** Must show: **0 vulnerabilities**

### Automated Security Check Script

```bash
# Run our comprehensive security check
bash scripts/security-check.sh
```

**What it does:**
1. Runs `npm audit` (shows vulnerabilities)
2. Runs `npm outdated` (shows outdated packages)
3. Provides fix commands

**Expected output:**
```
=== Security Audit ===
found 0 vulnerabilities

=== Outdated Packages ===
Package    Current  Wanted  Latest  Location
next       15.5.4   15.5.4  15.5.4  node_modules/next

✓ All packages up to date!
```

## Fixing Vulnerabilities

### Automatic Fixes (Safe)

```bash
# Fix vulnerabilities with patch/minor version updates
npm audit fix
```

**What it does:**
- Updates to latest patch version (e.g., 1.2.3 → 1.2.4)
- Updates to latest minor version (e.g., 1.2.3 → 1.3.0)
- **Safe:** No breaking changes

### Force Fixes (Risky)

```bash
# Fix vulnerabilities with major version updates
npm audit fix --force
```

⚠️ **WARNING:** This can introduce breaking changes!

**What it does:**
- Updates to latest major version (e.g., 1.2.3 → 2.0.0)
- **May break your code** if API changed

**After running --force:**
1. Check what changed: `git diff package.json package-lock.json`
2. Read migration guides for updated packages
3. Run tests: `npm test`
4. Test app manually
5. Commit only if everything works

### Manual Updates

```bash
# Update specific package
npm update package-name

# Update to specific version
npm install package-name@1.2.3

# Update all packages to latest (respecting semver)
npm update
```

## Dependency Update Strategy

### Monthly Routine (30 minutes)

```bash
# 1. Check for outdated packages
npm outdated

# 2. Review what's outdated and why
# Check changelogs for major updates

# 3. Update safe packages (patch/minor)
npm update

# 4. Run audit
npm audit

# 5. Fix vulnerabilities
npm audit fix

# 6. Test everything
npm test
npm run build

# 7. Commit if successful
git add package.json package-lock.json
git commit -m "chore: update dependencies"
```

### Before Every Production Deploy

```bash
# Must show 0 vulnerabilities
npm audit --production
```

**If vulnerabilities found:**
1. Run `npm audit fix`
2. Test thoroughly
3. If fix causes issues, investigate package alternatives
4. **Never deploy with known vulnerabilities**

### Major Framework Updates (Quarterly)

When Next.js releases major update (e.g., 15.x → 16.x):

```bash
# 1. Read upgrade guide
# https://nextjs.org/docs/upgrading

# 2. Create new branch
git checkout -b upgrade-nextjs-16

# 3. Update Next.js
npm install next@latest react@latest react-dom@latest

# 4. Follow migration guide
# Update deprecated APIs
# Test all features

# 5. Run full test suite
npm test
npm run build
npm run lint

# 6. Test locally
npm run dev
# Click through all features

# 7. Deploy to staging first
# Test in production-like environment

# 8. If successful, deploy to production
```

## Preventing Supply Chain Attacks

### 1. Package-lock.json (Always Commit)

```bash
# Package-lock.json ensures:
# - Exact versions installed
# - Reproducible builds
# - Detect tampering
```

✅ **DO commit package-lock.json to git**

❌ **DON'T add package-lock.json to .gitignore**

### 2. Verify Package Integrity

```bash
# npm automatically verifies package integrity using
# checksums from package-lock.json

# If integrity check fails:
# Error: integrity checksum failed
```

**This protects against:**
- Tampered packages on npm registry
- Man-in-the-middle attacks during download
- Corrupted packages

### 3. Audit New Packages Before Installing

**Before adding a new package:**

1. **Check npm page:** https://www.npmjs.com/package/PACKAGE_NAME
   - Weekly downloads (popular = more vetted)
   - Last update date (recently maintained?)
   - Number of dependents (widely used?)
   - GitHub stars/issues

2. **Check for typosquatting:**
   - `react` ✅ (correct)
   - `raect` ❌ (typo package - could be malicious)
   - `reacct` ❌ (typo package - could be malicious)

3. **Check package maintainers:**
   - Look for verified maintainers
   - Check GitHub profile
   - Multiple maintainers = better

4. **Check GitHub:**
   - Stars (popularity indicator)
   - Open issues (maintained?)
   - Recent commits
   - Code quality

5. **Run audit after installing:**
   ```bash
   npm install new-package
   npm audit
   ```

### 4. Use npm ci for Clean Installs

```bash
# In CI/CD pipelines, use:
npm ci

# Instead of:
npm install
```

**Why `npm ci`:**
- Installs from package-lock.json exactly
- Fails if package.json and package-lock.json are out of sync
- Removes node_modules before installing
- Faster and more reliable for CI/CD

### 5. Avoid Dangerous Packages

**Never install packages that:**
- Have very low download counts (< 100/week)
- Were just published (wait a few weeks)
- Have suspicious names (typosquatting)
- Request unusual permissions
- Have no source code visible

**Examples of dangerous packages (real incidents):**
- `crossenv` (typo of `cross-env` - was malicious)
- `babelcli` (typo of `babel-cli` - was malicious)
- `mongose` (typo of `mongoose` - was malicious)

## Dependency Confusion Attacks

### What It Is

Attacker publishes malicious package with same name as your internal package. npm might install malicious one instead.

### Real Example

```bash
# Internal package (not on npm)
"@mycompany/auth": "1.0.0"

# Attacker publishes to npm
"@mycompany/auth": "99.0.0"

# npm might install attacker's version!
```

### Prevention

1. **Use scoped packages for internal packages:**
   ```json
   {
     "name": "@mycompany/internal-package"
   }
   ```

2. **Configure npm to only use internal registry for your scope:**
   ```bash
   # .npmrc
   @mycompany:registry=https://npm.mycompany.com
   ```

3. **Don't publish internal packages to public npm**

## Scripts/security-check.sh

```bash
#!/bin/bash

echo "================================="
echo "Security & Dependency Check"
echo "================================="
echo ""

echo "=== Security Audit ==="
npm audit --production

echo ""
echo "=== Outdated Packages ==="
npm outdated

echo ""
echo "================================="
echo "To fix vulnerabilities:"
echo "  npm audit fix              (safe patch/minor updates)"
echo "  npm audit fix --force      (risky major updates)"
echo ""
echo "To update outdated packages:"
echo "  npm update                 (respects semver)"
echo "  npm update package-name    (specific package)"
echo "================================="
```

## Using Snyk for Enhanced Security

### Install Snyk

```bash
npm install -g snyk

# Authenticate
snyk auth
```

### Scan for Vulnerabilities

```bash
# Test project
snyk test

# Monitor project (continuous monitoring)
snyk monitor

# Test specific package before installing
snyk test package-name
```

### Add to CI/CD

```yaml
# .github/workflows/security.yml
name: Security Audit

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    # Run daily at 2am
    - cron: '0 2 * * *'

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run npm audit
        run: npm audit --production

      - name: Check for outdated packages
        run: npm outdated || true

      - name: Run Snyk test
        run: npx snyk test --severity-threshold=high
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## Monitoring for New Vulnerabilities

### GitHub Dependabot

**Enable in GitHub:**
1. Go to repository Settings
2. Security & analysis
3. Enable "Dependabot alerts"
4. Enable "Dependabot security updates"

**What it does:**
- Scans dependencies daily
- Creates PR when vulnerability found
- Automatically updates to fix version
- You review and merge

### npm Audit in CI/CD

```bash
# Add to CI/CD pipeline
npm audit --production --audit-level=moderate
```

**Fails build if:**
- Any moderate or higher vulnerabilities found
- Forces you to fix before deploy

## What Dependency Security Prevents

✅ **Known vulnerability exploitation** - Regular audits catch CVEs
✅ **Malicious package injection** - Verification prevents tampering
✅ **Supply chain attacks** - Package-lock.json + verification
✅ **Dependency confusion** - Scoped packages + registry config
✅ **Typosquatting attacks** - Manual verification before install
✅ **Outdated vulnerable code** - Regular update routine
✅ **Zero-day exploitation window** - Fast patching reduces risk

## Common Mistakes to Avoid

❌ **DON'T ignore npm audit warnings**
❌ **DON'T use deprecated packages**
❌ **DON'T skip testing after dependency updates**
❌ **DON'T add package-lock.json to .gitignore**
❌ **DON'T install packages without checking them first**
❌ **DON'T run npm audit fix --force without testing**

✅ **DO run npm audit before every deploy**
✅ **DO commit package-lock.json**
✅ **DO verify new packages before installing**
✅ **DO update dependencies monthly**
✅ **DO enable Dependabot alerts**
✅ **DO use npm ci in CI/CD**

## Quick Reference Commands

```bash
# Check for vulnerabilities
npm audit
npm audit --production

# Fix vulnerabilities
npm audit fix              # Safe
npm audit fix --force      # Risky, test thoroughly

# Check outdated packages
npm outdated

# Update packages
npm update                 # All packages
npm update package-name    # Specific package

# Install from lock file (CI/CD)
npm ci

# Run security check script
bash scripts/security-check.sh

# Test with Snyk
npx snyk test
```

## References

- npm Audit Documentation: https://docs.npmjs.com/cli/v8/commands/npm-audit
- OWASP Dependency Check: https://owasp.org/www-project-dependency-check/
- Sonatype Supply Chain Report: https://www.sonatype.com/state-of-the-software-supply-chain
- Snyk: https://snyk.io/
- GitHub Dependabot: https://docs.github.com/en/code-security/dependabot

## Next Steps

- For pre-deployment checks: Use `security-testing` skill
- For CI/CD integration: Add npm audit to pipeline
- For monitoring: Enable GitHub Dependabot alerts
- For enhanced scanning: Install Snyk
