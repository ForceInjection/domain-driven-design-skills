---
name: changelog-automation
description: "Apply changelog automation and semantic versioning patterns using Changesets or semantic-release: conventional commits, automated version bumping, release notes generation. Use when setting up release workflows, discussing versioning, or implementing changelog automation."
---

# Changelog Automation

Automated versioning and changelog generation using Changesets (monorepos) or semantic-release (single packages) with conventional commits.

## Philosophy

**Manual changelog maintenance is error-prone and time-consuming.** Automate version bumping, changelog updates, and release notes generation based on commit history or explicit change declarations.

**Two proven approaches:**
1. **Changesets**: PR-based workflow where developers declare intent in separate files (best for monorepos)
2. **Semantic-release**: Commit-based workflow using conventional commits (best for single packages)

Both enforce Semantic Versioning (SemVer) and integrate seamlessly with CI/CD.

## Semantic Versioning (SemVer)

All version numbers follow `MAJOR.MINOR.PATCH` format:

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, incompatible API changes
- **MINOR** (1.0.0 → 1.1.0): New features, backward-compatible additions
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward-compatible fixes

**Pre-release versions**: `1.0.0-beta.1`, `1.0.0-rc.2`, `1.0.0-alpha.3`

## Changesets (Recommended for Monorepos)

**Best for:**
- Monorepos with multiple packages
- Teams that want explicit change declarations
- Projects where commit messages may not be reliable
- Gradual migration (works alongside existing processes)

### Installation

```bash
# Install changesets
pnpm add -D @changesets/cli

# Initialize (creates .changeset directory and config)
pnpm changeset init
```

### Configuration

```javascript
// .changeset/config.json
{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,  // Don't auto-commit changesets
  "fixed": [],      // Packages that must version together
  "linked": [],     // Packages that share version numbers
  "access": "public",  // or "restricted" for private packages
  "baseBranch": "main",
  "updateInternalDependencies": "patch",  // Bump dependent packages
  "ignore": ["@repo/config", "@repo/tsconfig"]  // Skip these packages
}
```

### Workflow

#### 1. Developer Creates Changeset

When making changes, developer creates a changeset file:

```bash
# Create a changeset (interactive prompts)
pnpm changeset

# Example prompts:
# ? Which packages would you like to include? ›
#   ◉ @repo/ui
#   ◯ @repo/utils
#   ◯ @repo/config
#
# ? What kind of change is this for @repo/ui? ›
#   ◯ patch  - Bug fixes, internal changes
#   ◉ minor  - New features, backward-compatible
#   ◯ major  - Breaking changes
#
# ? Please enter a summary for this change:
# › Added dark mode toggle component
```

This creates `.changeset/random-name.md`:

```markdown
---
"@repo/ui": minor
---

Added dark mode toggle component with theme persistence
```

**Commit the changeset file** along with your code changes:

```bash
git add .changeset/random-name.md src/
git commit -m "feat: add dark mode toggle"
git push
```

#### 2. Automated Release (GitHub Actions)

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches:
      - main

concurrency: ${{ github.workflow }}-${{ github.ref }}

jobs:
  release:
    name: Release
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Create Release Pull Request or Publish
        id: changesets
        uses: changesets/action@v1
        with:
          # Creates a "Version Packages" PR that bumps versions
          # Or publishes to npm if PR is merged
          publish: pnpm release
          commit: "chore: version packages"
          title: "chore: version packages"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}  # If publishing to npm

      - name: Send Slack notification
        if: steps.changesets.outputs.published == 'true'
        run: |
          echo "New version published!"
          # Add Slack webhook call here
```

**What happens:**

1. When changesets are merged to `main`, GitHub Action creates a "Version Packages" PR
2. This PR updates `package.json` versions and `CHANGELOG.md` for each package
3. When you merge the "Version Packages" PR, packages are published automatically
4. Git tags are created for each release

#### 3. Manual Release

```bash
# Bump versions based on changesets
pnpm changeset version

# This updates package.json and CHANGELOG.md files
# Review changes, then commit
git add .
git commit -m "chore: version packages"

# Publish to npm
pnpm changeset publish

# Push tags to GitHub
git push --follow-tags
```

### Package.json Scripts

```json
{
  "scripts": {
    "changeset": "changeset",
    "changeset:version": "changeset version",
    "changeset:publish": "changeset publish",
    "release": "pnpm build && pnpm changeset publish"
  }
}
```

### Advantages

✅ **Explicit intent**: Developers declare what changed and why
✅ **Flexible timing**: Create changeset anytime, release when ready
✅ **Multi-package**: Handles complex monorepo dependencies automatically
✅ **PR-based**: Fits naturally into PR workflow
✅ **Gradual adoption**: Can coexist with other versioning strategies
✅ **Snapshot releases**: Easy to create pre-release versions for testing

### Example Changeset Files

**Bug fix (patch):**
```markdown
---
"@repo/api": patch
---

Fixed race condition in authentication middleware
```

**New feature (minor):**
```markdown
---
"@repo/ui": minor
"@repo/utils": patch
---

Added new `DataTable` component with sorting and filtering.
Updated `formatDate` utility to handle more formats.
```

**Breaking change (major):**
```markdown
---
"@repo/api": major
---

BREAKING: Renamed `getUser()` to `fetchUser()` for consistency.
Migration: Replace all `getUser()` calls with `fetchUser()`.
```

## Semantic-release (Recommended for Single Packages)

**Best for:**
- Single-package repositories
- Teams committed to conventional commits
- Fully automated release process
- Strict versioning discipline

### Installation

```bash
pnpm add -D semantic-release @semantic-release/git @semantic-release/changelog
```

### Configuration

```javascript
// .releaserc.js
module.exports = {
  branches: ['main'],
  plugins: [
    // Analyze commits to determine version bump
    '@semantic-release/commit-analyzer',

    // Generate release notes
    '@semantic-release/release-notes-generator',

    // Update CHANGELOG.md
    '@semantic-release/changelog',

    // Update package.json version
    '@semantic-release/npm',

    // Commit updated files
    [
      '@semantic-release/git',
      {
        assets: ['package.json', 'CHANGELOG.md'],
        message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
      },
    ],

    // Create GitHub release
    '@semantic-release/github',
  ],
}
```

### Conventional Commits

Semantic-release requires conventional commit format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types that trigger releases:**
- `feat`: New feature (bumps MINOR)
- `fix`: Bug fix (bumps PATCH)
- `perf`: Performance improvement (bumps PATCH)
- `BREAKING CHANGE:` in footer (bumps MAJOR)

**Types that don't trigger releases:**
- `docs`: Documentation changes
- `style`: Code style (formatting, semicolons)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**

```bash
# Patch release (1.0.0 → 1.0.1)
git commit -m "fix: resolve authentication timeout issue"

# Minor release (1.0.0 → 1.1.0)
git commit -m "feat: add dark mode support"

# Major release (1.0.0 → 2.0.0)
git commit -m "feat: redesign API

BREAKING CHANGE: Renamed all `get*` methods to `fetch*` for consistency"

# No release
git commit -m "docs: update README with new examples"
git commit -m "chore: upgrade dependencies"
```

### GitHub Actions Workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches:
      - main

jobs:
  release:
    name: Release
    runs-on: ubuntu-latest

    permissions:
      contents: write  # To push tags and releases
      issues: write    # To comment on released issues
      pull-requests: write  # To comment on released PRs

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Fetch all history for changelog
          persist-credentials: false

      - name: Setup pnpm
        uses: pnpm/action-setup@v2

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build
        run: pnpm build

      - name: Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
        run: pnpm semantic-release
```

### Advantages

✅ **Fully automated**: No manual version bumping or changelog updates
✅ **Commit-based**: Version determined from commit messages
✅ **Consistent**: Enforces conventional commits
✅ **Immediate**: Release happens automatically on merge to main
✅ **Rich integrations**: GitHub releases, npm publishing, Slack notifications

### Disadvantages

⚠️ **Strict commits required**: Team must follow conventional commits religiously
⚠️ **Less control**: Version bump determined by commits, not explicit choice
⚠️ **Single package focus**: Monorepos need additional configuration
⚠️ **Can't defer releases**: Every merge to main triggers analysis

## Enforcing Conventional Commits

Both approaches benefit from enforcing conventional commit format:

### Commitlint Setup

```bash
# Install commitlint
pnpm add -D @commitlint/cli @commitlint/config-conventional
```

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Formatting
        'refactor', // Code refactoring
        'perf',     // Performance
        'test',     // Tests
        'build',    // Build system
        'ci',       // CI configuration
        'chore',    // Maintenance
        'revert',   // Revert commit
      ],
    ],
    'scope-case': [2, 'always', 'kebab-case'],
    'subject-case': [2, 'always', 'sentence-case'],
    'header-max-length': [2, 'always', 72],
  },
}
```

### Lefthook Integration

```yaml
# lefthook.yml
commit-msg:
  commands:
    commitlint:
      run: pnpm commitlint --edit {1}
```

Now every commit is validated:

```bash
git commit -m "add new feature"
# ❌ Error: subject may not be empty [subject-empty]

git commit -m "feat: add dark mode"
# ✅ Success
```

## Comparison: Changesets vs Semantic-release

| Feature | Changesets | Semantic-release |
|---------|-----------|------------------|
| **Best for** | Monorepos | Single packages |
| **Workflow** | PR-based (explicit files) | Commit-based (conventional commits) |
| **Automation** | Semi-automated | Fully automated |
| **Control** | High (manual declaration) | Low (commit-driven) |
| **Flexibility** | Create changeset anytime | Must follow commit conventions |
| **Learning curve** | Low | Medium (conventional commits) |
| **Monorepo support** | Excellent | Requires plugins |
| **Release timing** | When "Version Packages" PR merged | Immediately on merge to main |
| **Team discipline** | Low (just create changeset files) | High (strict commit format) |

**Recommendation:**
- **Monorepo with 2+ packages**: Use Changesets
- **Single package, disciplined team**: Use semantic-release
- **Single package, less strict team**: Use Changesets
- **Need gradual adoption**: Use Changesets

## Example Workflows

### Changesets: New Feature

```bash
# 1. Create feature branch
git checkout -b feat/dark-mode

# 2. Make changes
# ... edit code ...

# 3. Create changeset
pnpm changeset
# Select packages, choose "minor", add description

# 4. Commit everything
git add .
git commit -m "feat: add dark mode toggle"

# 5. Push and create PR
git push origin feat/dark-mode

# 6. After PR review and merge to main:
# - GitHub Action creates "Version Packages" PR automatically
# - Review version bumps and changelog
# - Merge "Version Packages" PR to publish
```

### Semantic-release: Bug Fix

```bash
# 1. Create fix branch
git checkout -b fix/auth-timeout

# 2. Make changes
# ... edit code ...

# 3. Commit with conventional format
git commit -m "fix: resolve authentication timeout issue

The JWT validation was not accounting for clock skew.
Added 30-second tolerance window."

# 4. Push and create PR
git push origin fix/auth-timeout

# 5. After PR review and merge to main:
# - semantic-release automatically:
#   * Bumps version (1.0.0 → 1.0.1)
#   * Updates CHANGELOG.md
#   * Creates GitHub release
#   * Publishes to npm (if configured)
```

## Best Practices

### Do ✅

- **Choose one approach**: Either Changesets OR semantic-release, not both
- **Enforce conventional commits**: Use commitlint for consistency
- **Automate with CI/CD**: GitHub Actions for releases
- **Write clear changeset descriptions**: Future you will thank you
- **Review version bumps**: Check generated changelog before releasing
- **Use semantic versioning**: Follow MAJOR.MINOR.PATCH strictly
- **Tag releases**: Create git tags for every release
- **Generate release notes**: Automate from changeset files or commits

### Don't ❌

- **Don't manually edit CHANGELOG.md**: Let automation handle it
- **Don't skip changesets**: Every PR should have a changeset (if using Changesets)
- **Don't ignore breaking changes**: Always document in changeset/commit
- **Don't publish without CI**: Automate to prevent human error
- **Don't version together unnecessarily**: Independent versioning where possible
- **Don't forget to build**: Run build before publish

## Quick Setup Guide

### For Changesets (Monorepo)

```bash
# 1. Install
pnpm add -D @changesets/cli
pnpm changeset init

# 2. Configure .changeset/config.json
# (see configuration section above)

# 3. Add GitHub Action
# (see workflow section above)

# 4. Add scripts to package.json
# "changeset": "changeset"
# "release": "pnpm build && pnpm changeset publish"

# 5. Document workflow in README
# How to create changesets, review process, etc.
```

### For semantic-release (Single Package)

```bash
# 1. Install
pnpm add -D semantic-release @semantic-release/git @semantic-release/changelog

# 2. Create .releaserc.js
# (see configuration section above)

# 3. Install commitlint
pnpm add -D @commitlint/cli @commitlint/config-conventional

# 4. Configure lefthook for commit-msg hook
# (see commitlint section above)

# 5. Add GitHub Action
# (see workflow section above)

# 6. Document commit conventions in CONTRIBUTING.md
```

## Philosophy

**"Versioning should be automatic, not an afterthought."**

Manual changelog maintenance leads to:
- Forgotten changes
- Incorrect version bumps
- Inconsistent release notes
- Wasted developer time

Automated changelog generation ensures:
- Every change is documented
- Versions follow semantic versioning
- Release notes are comprehensive
- Developers focus on code, not process

Choose the tool that fits your workflow, then trust the automation.

---

When agents design release processes, they should:
- Recommend Changesets for monorepos with multiple packages
- Recommend semantic-release for single-package repositories
- Enforce conventional commits with commitlint + Lefthook
- Automate versioning and changelog with GitHub Actions
- Follow semantic versioning (MAJOR.MINOR.PATCH) strictly
- Generate release notes from changesets or commits
- Create git tags for every release
- Document workflow clearly for team
