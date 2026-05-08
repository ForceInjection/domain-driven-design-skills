---
name: npmrc-config
description: NPM registry configuration template (.npmrc.template) and validation logic for GitHub Packages authentication with pnpm hoisting settings. Includes 4 critical standards (GitHub Package Registry config with token placeholder, pnpm hoisting for monorepo compatibility, exact version management, security documentation). Use when creating or auditing .npmrc.template files to prevent token leakage.
---

# NPM Registry Configuration Skill

This skill provides .npmrc.template template and validation logic for NPM registry configuration with GitHub Packages authentication.

## Purpose

Manage .npmrc.template configuration to:

- Configure GitHub Package Registry for @metasaver scope
- Set up pnpm hoisting settings for monorepo compatibility
- Define dependency version management (exact versions)
- Document token replacement workflow
- Ensure secure authentication token handling

## Usage

This skill is invoked by the `npmrc-template-agent` when:

- Creating new .npmrc.template files
- Auditing existing NPM registry configurations
- Validating .npmrc.template against standards

## Template

The standard .npmrc.template is located at:

```
templates/.npmrc.template
```

## The 4 .npmrc.template Standards

### Rule 1: GitHub Package Registry Configuration (CRITICAL)

**Must configure GitHub Packages for @metasaver scope:**

```ini
# GitHub Package Registry for @metasaver packages
@metasaver:registry=https://npm.pkg.github.com

# Authentication token (replaced by setup script)
# Generate token at: https://github.com/settings/tokens
# Required scopes: read:packages
//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}
```

**Requirements:**

- Scoped registry for `@metasaver` pointing to `npm.pkg.github.com`
- Auth token placeholder using `${GITHUB_TOKEN}` variable
- **ALWAYS** use token placeholder - never commit real tokens (security requirement)

**Validation:**

```bash
# Check registry configuration
grep -q "@metasaver:registry=https://npm.pkg.github.com" .npmrc.template || echo "VIOLATION: Missing @metasaver registry"

# Check auth token placeholder
grep -q "//npm.pkg.github.com/:_authToken=\${GITHUB_TOKEN}" .npmrc.template || echo "VIOLATION: Missing auth token placeholder"

# Security check - ensure no real tokens
grep -E "ghp_[a-zA-Z0-9]{36}" .npmrc.template && echo "SECURITY VIOLATION: Real token detected"
```

### Rule 2: pnpm Hoisting Configuration (CRITICAL)

**Must configure pnpm for proper module resolution in monorepos:**

```ini
# pnpm Configuration
shamefully-hoist=true
strict-peer-dependencies=false
auto-install-peers=true
node-linker=hoisted
```

**Settings explained:**

- `shamefully-hoist=true` - Hoists all dependencies to root (fixes module resolution)
- `strict-peer-dependencies=false` - Relaxed peer dependency checking
- `auto-install-peers=true` - Automatically install peer dependencies
- `node-linker=hoisted` - Use hoisted node_modules structure

**Validation:**

```bash
# Check all required hoisting settings
grep -q "shamefully-hoist=true" .npmrc.template || echo "VIOLATION: Missing shamefully-hoist"
grep -q "node-linker=hoisted" .npmrc.template || echo "VIOLATION: Missing node-linker"
grep -q "auto-install-peers=true" .npmrc.template || echo "VIOLATION: Missing auto-install-peers (recommended)"
```

### Rule 3: Dependency Version Management

**Must configure exact version saving:**

```ini
# Dependency version management
save-exact=true
save-prefix=''
```

**Settings explained:**

- `save-exact=true` - Save exact versions (no `^` or `~`)
- `save-prefix=''` - Empty prefix (no symbols)

**Validation:**

```bash
# Check version management settings
grep -q "save-exact=true" .npmrc.template || echo "VIOLATION: Missing save-exact"
grep -q "save-prefix=''" .npmrc.template || echo "VIOLATION: Missing save-prefix"
```

### Rule 4: Documentation Header

**Must include setup instructions and warnings:**

```ini
# ==============================================
# MetaSaver NPM Registry Configuration Template
# ==============================================
# This is a TEMPLATE file - ALWAYS copy before editing directly
#
# Setup Instructions:
# 1. Copy .env.example to .env
# 2. Add your GITHUB_TOKEN to .env
# 3. Run: pnpm setup:npmrc
#
# The setup script will replace ${GITHUB_TOKEN} with your actual token
# and generate .npmrc (which is gitignored)
# ==============================================
```

**Requirements:**

- Clear "TEMPLATE" warning
- Step-by-step setup instructions
- Explanation of token replacement
- Note that .npmrc is gitignored

**Validation:**

```bash
# Check documentation header
grep -q "MetaSaver NPM Registry Configuration Template" .npmrc.template || echo "VIOLATION: Missing documentation header"
grep -q "Setup Instructions" .npmrc.template || echo "VIOLATION: Missing setup instructions"
grep -q "pnpm setup:npmrc" .npmrc.template || echo "VIOLATION: Missing setup command reference"
```

## Validation

To validate .npmrc.template configuration:

1. Check that .npmrc.template exists at repository root
2. Read .npmrc.template content
3. Validate against 4 standards
4. Check for security violations (real tokens)
5. Verify completeness of documentation
6. Report violations

### Validation Approach

```bash
# Check file exists
[ -f ".npmrc.template" ] || echo "VIOLATION: Missing .npmrc.template at root"

# Rule 1: GitHub Package Registry
grep -q "@metasaver:registry=https://npm.pkg.github.com" .npmrc.template || echo "VIOLATION: Missing @metasaver registry"
grep -q "//npm.pkg.github.com/:_authToken=\${GITHUB_TOKEN}" .npmrc.template || echo "VIOLATION: Missing auth token placeholder"

# Security check
if grep -E "ghp_[a-zA-Z0-9]{36}" .npmrc.template; then
  echo "SECURITY VIOLATION: Real GitHub token detected (should use \${GITHUB_TOKEN} placeholder)"
  exit 1
fi

# Rule 2: pnpm hoisting
grep -q "shamefully-hoist=true" .npmrc.template || echo "VIOLATION: Missing shamefully-hoist"
grep -q "node-linker=hoisted" .npmrc.template || echo "VIOLATION: Missing node-linker"

# Rule 3: Version management
grep -q "save-exact=true" .npmrc.template || echo "VIOLATION: Missing save-exact"
grep -q "save-prefix=''" .npmrc.template || echo "VIOLATION: Missing save-prefix"

# Rule 4: Documentation
grep -q "Setup Instructions" .npmrc.template || echo "VIOLATION: Missing setup instructions"
```

## Repository Type Considerations

- **Consumer Repos**: Standard .npmrc.template enforced (all 4 rules)
- **Library Repos**: May have additional registry configurations
- **All Repos**: Must have .npmrc.template at root (not in subdirectories)

## Best Practices

1. Always create .npmrc.template at repository root only
2. Never include real tokens (use `${GITHUB_TOKEN}` placeholder)
3. Document setup process clearly
4. Use exact version saving for consistency
5. Configure pnpm hoisting for monorepo compatibility
6. Reference pnpm setup:npmrc script in documentation
7. Ensure .npmrc is in .gitignore (actual file, not template)
8. Re-audit after making changes

## Security Notes

**CRITICAL:** .npmrc.template must ALWAYS use token placeholders and never contain real authentication tokens.

**Correct:**

```ini
//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}
```

**WRONG (Security Violation):**

```ini
//npm.pkg.github.com/:_authToken=ghp_abc123xyz789...
```

**Token detection pattern:**

```bash
# GitHub Personal Access Token pattern
grep -E "ghp_[a-zA-Z0-9]{36}" .npmrc.template
```

## Integration

This skill integrates with:

- Repository type provided via `scope` parameter. If not provided, use `/skill scope-check`
- `/skill audit-workflow` - Bi-directional comparison workflow
- `/skill remediation-options` - Conform/Update/Ignore choices
- `pnpm-workspace-agent` - For monorepo package manager setup
- `package-scripts-agent` - For setup:npmrc script validation
