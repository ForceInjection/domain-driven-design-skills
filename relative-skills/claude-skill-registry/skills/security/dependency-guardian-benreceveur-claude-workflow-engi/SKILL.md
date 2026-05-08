---
name: dependency-guardian
description: Automated dependency management with security scanning, update orchestration, and compatibility validation
version: 1.0.0
author: Claude Memory System
tags: [dependencies, security, vulnerabilities, updates, automation, npm, pip, cargo]
---

# Dependency Guardian Skill

## Purpose
Automatically manage project dependencies with security scanning, intelligent updates, breaking change detection, and license compliance validation.

## When to Use
- Weekly dependency health checks
- Security vulnerability scanning
- Before major releases
- After security advisories
- Automated dependency updates
- License compliance audits

## Supported Package Managers

### JavaScript/TypeScript
- **npm**: Node.js packages
- **yarn**: Alternative Node.js package manager
- **pnpm**: Fast, disk-efficient package manager

### Python
- **pip**: Python package installer
- **poetry**: Modern dependency management
- **pipenv**: Virtual environments + dependencies

### Rust
- **cargo**: Rust package manager

### Go
- **go mod**: Go modules

### Ruby
- **bundler**: Ruby gem dependencies

### Java/JVM
- **maven**: Apache Maven
- **gradle**: Gradle build tool

## Operations

### 1. Scan Vulnerabilities
- Check dependencies against CVE databases
- Identify critical, high, medium, low severity
- Report vulnerable transitive dependencies
- Generate remediation recommendations

### 2. Check for Updates
- Find outdated dependencies
- Classify updates (major, minor, patch)
- Detect breaking changes
- Calculate update priority

### 3. Update Dependencies
- Apply safe updates automatically
- Create separate PRs for major vs minor
- Run tests after updates
- Rollback on failure

### 4. License Compliance
- Detect dependency licenses
- Flag incompatible licenses
- Generate license report
- Check OSS license compatibility

### 5. Dependency Audit
- Generate dependency tree
- Identify duplicate dependencies
- Detect circular dependencies
- Calculate total dependency count

## Scripts

### main.py
```bash
# Scan for vulnerabilities
python scripts/main.py scan --project-dir=.

# Check for updates
python scripts/main.py check-updates --project-dir=.

# Update dependencies (safe updates only)
python scripts/main.py update --type=patch --auto-merge

# Generate audit report
python scripts/main.py audit --output=audit-report.json

# Check license compliance
python scripts/main.py licenses --allow=MIT,Apache-2.0,BSD-3-Clause
```

### Subcommands

**scan**: Vulnerability scanning
```bash
python scripts/main.py scan --severity=high,critical
# Output: List of vulnerabilities with remediation
```

**check-updates**: Find outdated dependencies
```bash
python scripts/main.py check-updates --include-dev
# Output: Available updates grouped by type
```

**update**: Apply updates
```bash
python scripts/main.py update --type=patch --dry-run
# Output: Preview of updates (no changes)
```

**audit**: Generate dependency report
```bash
python scripts/main.py audit --format=markdown
# Output: Complete dependency analysis
```

**licenses**: License compliance check
```bash
python scripts/main.py licenses --check-compatibility
# Output: License compatibility report
```

## Configuration

### Project Configuration
Create `.dependency-guardian.json`:
```json
{
  "updateSchedule": "weekly",
  "autoMerge": {
    "patch": true,
    "minor": false,
    "major": false
  },
  "allowedLicenses": [
    "MIT",
    "Apache-2.0",
    "BSD-3-Clause",
    "ISC"
  ],
  "ignoredPackages": [
    "legacy-package-name"
  ],
  "severityThreshold": "high"
}
```

### Memory Integration
Stores vulnerability history and preferences:
```json
{
  "topic": "dependency-guardian-config",
  "scope": "repository",
  "value": {
    "last_scan": "2025-10-20T10:00:00Z",
    "vulnerabilities_found": 3,
    "vulnerabilities_fixed": 2,
    "update_preferences": {
      "auto_patch": true,
      "test_before_merge": true,
      "create_pr": true
    },
    "license_policy": {
      "allowed": ["MIT", "Apache-2.0", "BSD-3-Clause"],
      "blocked": ["GPL-3.0", "AGPL-3.0"]
    }
  }
}
```

## Integration Points

### With Security Scanner Skill
- Share vulnerability database
- Coordinate security scanning
- Cross-reference CVE findings

### With Test-First Change Skill
- Run tests after updates
- Validate no regressions
- Block merge on test failure

### With PR Author/Reviewer Skill
- Create update PRs automatically
- Include vulnerability details
- Add security review checklist

### With Release Orchestrator Skill
- Block releases with critical CVEs
- Include dependency updates in changelog
- Verify dependencies before deployment

## Examples

### Example 1: Scan for Vulnerabilities

**Project**: Node.js app with outdated dependencies

**Command**:
```bash
python scripts/main.py scan --project-dir=/path/to/project
```

**Output**:
```json
{
  "success": true,
  "project_type": "npm",
  "vulnerabilities": [
    {
      "package": "lodash",
      "version": "4.17.15",
      "severity": "high",
      "cve": "CVE-2020-8203",
      "title": "Prototype Pollution",
      "fixed_in": "4.17.19",
      "recommendation": "Update to lodash@4.17.19 or higher"
    },
    {
      "package": "axios",
      "version": "0.19.0",
      "severity": "medium",
      "cve": "CVE-2020-28168",
      "title": "SSRF vulnerability",
      "fixed_in": "0.21.1",
      "recommendation": "Update to axios@0.21.1 or higher"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 1,
    "medium": 1,
    "low": 0,
    "total": 2
  }
}
```

### Example 2: Check for Updates

**Command**:
```bash
python scripts/main.py check-updates --project-dir=.
```

**Output**:
```json
{
  "success": true,
  "project_type": "npm",
  "updates": {
    "patch": [
      {
        "package": "express",
        "current": "4.17.1",
        "latest": "4.17.3",
        "type": "patch"
      }
    ],
    "minor": [
      {
        "package": "react",
        "current": "17.0.2",
        "latest": "17.2.0",
        "type": "minor"
      }
    ],
    "major": [
      {
        "package": "webpack",
        "current": "4.46.0",
        "latest": "5.75.0",
        "type": "major",
        "breaking_changes": true
      }
    ]
  },
  "summary": {
    "total": 15,
    "patch": 8,
    "minor": 5,
    "major": 2
  }
}
```

### Example 3: Update Dependencies (Patch Only)

**Command**:
```bash
python scripts/main.py update --type=patch --dry-run=false
```

**Output**:
```json
{
  "success": true,
  "updates_applied": 8,
  "packages": [
    {"name": "express", "from": "4.17.1", "to": "4.17.3"},
    {"name": "lodash", "from": "4.17.15", "to": "4.17.21"},
    {"name": "moment", "from": "2.29.1", "to": "2.29.4"}
  ],
  "tests_run": true,
  "tests_passed": true,
  "pr_created": true,
  "pr_url": "https://github.com/user/repo/pull/123"
}
```

### Example 4: License Audit

**Command**:
```bash
python scripts/main.py licenses --check-compatibility
```

**Output**:
```json
{
  "success": true,
  "total_packages": 247,
  "licenses": {
    "MIT": 189,
    "Apache-2.0": 31,
    "BSD-3-Clause": 18,
    "ISC": 7,
    "UNLICENSED": 2
  },
  "issues": [
    {
      "package": "some-gpl-package",
      "license": "GPL-3.0",
      "severity": "high",
      "reason": "GPL-3.0 not in allowed list",
      "recommendation": "Find alternative or add license exception"
    }
  ]
}
```

### Example 5: Dependency Audit

**Command**:
```bash
python scripts/main.py audit --format=json
```

**Output**:
```json
{
  "success": true,
  "project_type": "npm",
  "dependencies": {
    "production": 87,
    "development": 160,
    "total": 247
  },
  "depth": {
    "direct": 42,
    "transitive": 205,
    "max_depth": 7
  },
  "duplicates": [
    {
      "package": "semver",
      "versions": ["5.7.1", "6.3.0", "7.3.5"],
      "count": 3
    }
  ],
  "size": {
    "total_mb": 156.3,
    "largest": [
      {"package": "typescript", "size_mb": 34.2},
      {"package": "webpack", "size_mb": 12.8}
    ]
  }
}
```

## Token Economics

**Without Skill** (Agent-driven dependency check):
- Read package file: 1,500 tokens
- Query vulnerability database: 4,000 tokens
- Analyze updates: 3,000 tokens
- Generate recommendations: 2,500 tokens
- Explain process: 2,000 tokens
- **Total**: 13,000 tokens

**With Skill** (Code execution):
- Metadata: 50 tokens
- SKILL.md: 400 tokens
- Script execution: 0 tokens (returns result)
- Result parsing: 200 tokens
- **Total**: 650 tokens

**Savings**: 95.0% (12,350 tokens saved per scan)

## Success Metrics

### Performance
- Vulnerability scan: <30 seconds
- Update check: <15 seconds
- License audit: <10 seconds
- Dependency update: <2 minutes (including tests)

### Quality
- Vulnerability detection rate: >99%
- False positive rate: <5%
- Update success rate: >95%
- Test pass rate after updates: >90%

### Security
- Time to patch critical CVEs: <24 hours
- Percentage of dependencies up-to-date: >80%
- License compliance: 100%

## Safety Checks

### Pre-Update
1. ✅ Backup package lock file
2. ✅ Check for breaking changes
3. ✅ Verify tests exist
4. ✅ Create git branch for updates
5. ✅ Check CI status

### Post-Update
1. ✅ Run full test suite
2. ✅ Verify build succeeds
3. ✅ Check for new vulnerabilities
4. ✅ Generate dependency diff
5. ✅ Create PR with details

### Rollback Conditions
- Tests fail after update
- Build fails
- New vulnerabilities introduced
- Circular dependency detected

## Error Handling

### Missing Package Manager
```
❌ Package manager not detected
Supported: npm, yarn, pnpm, pip, poetry, cargo, go mod
Recommendation: Ensure package manifest exists (package.json, requirements.txt, etc.)
```

### Vulnerability Database Unavailable
```
⚠️  Cannot connect to vulnerability database
Falling back to local cache (may be outdated)
Recommendation: Check internet connection
```

### Breaking Change Detected
```
⚠️  Major update detected: webpack 4.46.0 → 5.75.0
Breaking changes: Module federation, Asset modules
Recommendation: Review migration guide before updating
```

## Advanced Features

### Automatic PR Creation
```json
{
  "auto_pr": {
    "enabled": true,
    "branch_prefix": "deps/",
    "labels": ["dependencies", "security"],
    "assign_to": ["@security-team"],
    "require_reviews": 1
  }
}
```

### Grouped Updates
```json
{
  "grouping": {
    "patch_updates": "single-pr",
    "minor_updates": "separate-prs",
    "major_updates": "separate-prs"
  }
}
```

### Custom Vulnerability Sources
```json
{
  "vulnerability_sources": [
    "npm-audit",
    "snyk",
    "github-advisory",
    "ossindex"
  ]
}
```

## Limitations

- Requires internet connection for vulnerability database
- Cannot automatically fix all breaking changes
- Manual review recommended for major updates
- License detection accuracy depends on package metadata

## References

See `references/` for:
- `vulnerability-databases.md` - CVE and security advisory sources
- `breaking-changes-guide.md` - How to handle major updates
- `license-compatibility.md` - OSS license compatibility matrix
- `troubleshooting.md` - Common issues and solutions

---

*Dependency Guardian Skill v1.0.0 - Keep your dependencies secure and up-to-date*
