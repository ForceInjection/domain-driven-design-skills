---
name: release-orchestrator
description: End-to-end release automation with semantic versioning, changelog generation, and multi-environment deployment
version: 1.0.0
author: Claude Memory System
tags: [release, deployment, versioning, changelog, automation, cicd]
---

# Release Orchestrator Skill

## Purpose
Automate the entire release process from version calculation to deployment, ensuring consistent and reliable releases across environments.

## When to Use
- Creating new releases
- Generating changelogs
- Deploying to staging/production
- Tagging releases in git
- Publishing packages to registries
- Creating GitHub/GitLab releases

## Supported Workflows

### Semantic Versioning
- **MAJOR**: Breaking changes (v1.0.0 → v2.0.0)
- **MINOR**: New features (v1.0.0 → v1.1.0)
- **PATCH**: Bug fixes (v1.0.0 → v1.0.1)
- **Pre-release**: Alpha, beta, rc (v1.0.0-alpha.1)

### Commit Conventions
- **Conventional Commits**: feat:, fix:, chore:, docs:, etc.
- **Breaking Changes**: BREAKING CHANGE in commit body
- **Scope**: feat(api): add authentication

### Package Types
- **npm/yarn**: JavaScript/TypeScript packages
- **PyPI**: Python packages
- **RubyGems**: Ruby packages
- **Cargo**: Rust crates
- **Go Modules**: Go packages
- **Docker**: Container images
- **GitHub Releases**: Binary assets

## Operations

### 1. Calculate Version
- Analyze git history since last tag
- Detect breaking changes, features, fixes
- Apply semantic versioning rules
- Handle pre-release versions

### 2. Generate Changelog
- Parse conventional commits
- Group by type (Features, Bug Fixes, Breaking Changes)
- Include commit authors
- Link to issues/PRs
- Generate markdown format

### 3. Build Release Assets
- Compile binaries (platform-specific)
- Bundle JavaScript/TypeScript
- Package Python wheels
- Create Docker images
- Generate checksums

### 4. Create Git Release
- Create and push git tag
- Update version in package files
- Commit version bump
- Create GitHub/GitLab release

### 5. Deploy to Environments
- Staging deployment (automatic)
- Production deployment (with approval)
- Rollback capability
- Health checks

## Scripts

### main.py
```bash
# Calculate next version
python scripts/main.py version --calculate

# Generate changelog
python scripts/main.py changelog --from=v1.0.0 --to=HEAD

# Create full release
python scripts/main.py release --type=minor

# Deploy to environment
python scripts/main.py deploy --environment=staging

# Rollback release
python scripts/main.py rollback --version=v1.2.3
```

### Subcommands

**version**: Calculate semantic version
```bash
python scripts/main.py version --calculate
# Output: v1.3.0 (current: v1.2.5)
```

**changelog**: Generate changelog
```bash
python scripts/main.py changelog --from=v1.2.0 --to=HEAD
# Output: CHANGELOG.md with grouped commits
```

**release**: Create complete release
```bash
python scripts/main.py release --type=minor --dry-run
# Output: Preview of release (no changes)
```

**deploy**: Deploy to environment
```bash
python scripts/main.py deploy --environment=production --confirm
# Output: Deployment status and health checks
```

## Configuration

### Project Configuration
Create `.release.json` in project root:
```json
{
  "versionFiles": [
    "package.json",
    "pyproject.toml",
    "Cargo.toml"
  ],
  "changelogFile": "CHANGELOG.md",
  "commitTypes": {
    "feat": "Features",
    "fix": "Bug Fixes",
    "docs": "Documentation",
    "perf": "Performance",
    "refactor": "Refactoring"
  },
  "deployments": {
    "staging": {
      "type": "kubernetes",
      "namespace": "staging",
      "autoPromote": false
    },
    "production": {
      "type": "kubernetes",
      "namespace": "production",
      "requiresApproval": true
    }
  }
}
```

### Memory Integration
Stores release history:
```json
{
  "topic": "release-history",
  "scope": "repository",
  "value": {
    "last_release": "v1.2.5",
    "release_date": "2025-10-15T10:00:00Z",
    "releases": [
      {
        "version": "v1.2.5",
        "date": "2025-10-15",
        "commits": 23,
        "type": "minor"
      }
    ],
    "deploy_preferences": {
      "auto_staging": true,
      "production_approval": true,
      "rollback_window": "24h"
    }
  }
}
```

## Integration Points

### With Test-First Change Skill
- Run test suite before release
- Block release if tests fail
- Include test coverage in changelog

### With PR Author/Reviewer Skill
- Generate release PR
- Include changelog in PR description
- Require approvals for production

### With Memory Hygiene Skill
- Track release frequency
- Monitor success rates
- Record deployment patterns

### With Dependency Guardian Skill
- Check for vulnerable dependencies
- Block release if critical CVEs found
- Include dependency updates in changelog

## Examples

### Example 1: Calculate Next Version

**Current version**: v1.2.5

**Recent commits**:
```
feat(api): add user authentication
fix(ui): button alignment issue
chore: update dependencies
```

**Command**:
```bash
python scripts/main.py version --calculate
```

**Output**:
```json
{
  "current": "1.2.5",
  "next": "1.3.0",
  "bump": "minor",
  "reason": "New features detected",
  "commits": {
    "features": 1,
    "fixes": 1,
    "chores": 1
  }
}
```

### Example 2: Generate Changelog

**Command**:
```bash
python scripts/main.py changelog --from=v1.2.0 --to=HEAD --output=CHANGELOG.md
```

**Output** (CHANGELOG.md):
```markdown
# Changelog

## [1.3.0] - 2025-10-20

### Features
- **api**: add user authentication (#123) @johndoe
- **ui**: implement dark mode toggle (#124) @janedoe

### Bug Fixes
- **ui**: button alignment issue (#125) @johndoe
- **api**: fix rate limiting bug (#126) @janedoe

### Chores
- update dependencies (#127) @johndoe
```

### Example 3: Create Release

**Command**:
```bash
python scripts/main.py release --type=minor --dry-run=false
```

**Steps executed**:
1. ✅ Calculate version: v1.2.5 → v1.3.0
2. ✅ Generate changelog
3. ✅ Update version in package.json
4. ✅ Commit changes: "chore: release v1.3.0"
5. ✅ Create git tag: v1.3.0
6. ✅ Push to origin
7. ✅ Create GitHub release
8. ✅ Upload assets (if configured)

**Output**:
```json
{
  "success": true,
  "version": "1.3.0",
  "tag": "v1.3.0",
  "release_url": "https://github.com/user/repo/releases/tag/v1.3.0",
  "assets": []
}
```

### Example 4: Deploy to Staging

**Command**:
```bash
python scripts/main.py deploy --environment=staging --version=v1.3.0
```

**Output**:
```json
{
  "success": true,
  "environment": "staging",
  "version": "v1.3.0",
  "deployment_id": "deploy-xyz123",
  "status": "healthy",
  "url": "https://staging.example.com",
  "health_checks": {
    "http": "passed",
    "database": "passed",
    "redis": "passed"
  }
}
```

## Token Economics

**Without Skill** (Agent-driven release):
- Analyze commits: 3,000 tokens
- Calculate version: 2,000 tokens
- Generate changelog: 4,000 tokens
- Create release steps: 3,000 tokens
- Explain process: 2,000 tokens
- **Total**: 14,000 tokens

**With Skill** (Code execution):
- Metadata: 50 tokens
- SKILL.md: 350 tokens
- Script execution: 0 tokens (returns result)
- Result parsing: 150 tokens
- **Total**: 550 tokens

**Savings**: 96.1% (13,450 tokens saved per release)

## Success Metrics

### Performance
- Version calculation: <1 second
- Changelog generation: <5 seconds
- Full release process: <2 minutes
- Deployment time: <5 minutes

### Quality
- Release automation rate: >95%
- Failed releases: <5%
- Rollback success: 100%
- Changelog accuracy: 100%

### Adoption
- Projects using Skill: >80%
- Manual releases: <10%
- Developer satisfaction: >4.5/5

## Safety Checks

### Pre-Release
1. ✅ All tests pass
2. ✅ No uncommitted changes
3. ✅ On default branch (main/master)
4. ✅ No vulnerable dependencies (critical/high)
5. ✅ Previous release successful

### Post-Release
1. ✅ Tag created successfully
2. ✅ Version files updated
3. ✅ Changelog generated
4. ✅ Release notes published
5. ✅ Deployment health checks pass

### Rollback Conditions
- Health checks fail
- Error rate exceeds threshold
- Manual rollback request
- Deployment timeout

## Error Handling

### Git Errors
```
❌ No commits since last release (v1.2.5)
Recommendation: Make changes before creating release
```

### Version Conflicts
```
❌ Version v1.3.0 already exists
Recommendation: Delete tag or increment version
```

### Deployment Failures
```
❌ Deployment to staging failed: Connection timeout
Health checks: http=failed, database=passed
Recommendation: Check staging environment connectivity
Rollback: python scripts/main.py rollback --environment=staging
```

## Advanced Features

### Pre-release Versions
```bash
# Create alpha release
python scripts/main.py release --type=minor --prerelease=alpha
# Output: v1.3.0-alpha.1

# Create beta release
python scripts/main.py release --type=minor --prerelease=beta
# Output: v1.3.0-beta.1

# Promote to stable
python scripts/main.py release --type=minor
# Output: v1.3.0
```

### Multi-Platform Builds
```json
{
  "builds": [
    {"platform": "linux-x64", "output": "bin/app-linux"},
    {"platform": "darwin-x64", "output": "bin/app-macos"},
    {"platform": "windows-x64", "output": "bin/app-windows.exe"}
  ]
}
```

### Deployment Strategies
- **Blue-Green**: Zero downtime deployments
- **Canary**: Gradual rollout (10% → 50% → 100%)
- **Rolling**: Update instances incrementally

## Limitations

- Requires conventional commit format for best results
- Cannot automatically resolve merge conflicts
- Manual approval needed for production deployments
- Rollback may require manual intervention for database migrations

## References

See `references/` for:
- `conventional-commits.md` - Commit format specification
- `versioning-guide.md` - Semantic versioning rules
- `deployment-strategies.md` - Deployment patterns
- `troubleshooting.md` - Common issues and solutions

---

*Release Orchestrator Skill v1.0.0 - Ship with confidence*
