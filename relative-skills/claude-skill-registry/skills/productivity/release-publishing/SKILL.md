---
name: release-publishing
description: Release workflow with changesets, version bumping, changelog generation, and npm publishing. Use when preparing releases, managing versions, or publishing to npm.
license: MIT
metadata:
  author: liaison-toolkit
  version: "1.0"
  keywords: "release, changesets, semver, changelog, npm, publishing"
---

# Release Publishing

Complete workflow for managing releases using Changesets, semantic versioning, changelog generation, and npm/Bun package publishing.

## When to use this skill

Use this skill when:
- Preparing a new release
- Bumping version numbers
- Generating changelog entries
- Publishing to npm or GitHub releases
- Creating changesets for changes
- Coordinating releases in monorepos

## Changesets Workflow

### Adding a Changeset

```bash
# Start changeset wizard
bun changeset

# Select change type
? What kind of change is this? … (Use arrow keys, type to select)
❯ patch
  minor
  major

# Provide description
? What is the summary of this change? …
> Fixed skill validation bug

# Choose affected packages
? Which packages should this change affect? …
❯ packages/liaison
  packages/opencode_config
  packages/liaison-coordinator
```

### Changeset File Format

```markdown
# .changeset/release-2024-12-26.md
---
"packages/liaison": patch
---

Fixed skill validation bug in supportsSymlinks function.
```

### Bumping Version with Changesets

```bash
# Update versions and create CHANGELOG.md
bun changeset version

# This will:
# - Update package.json versions based on changesets
# - Consolidate changesets into CHANGELOG.md
# - Delete processed changesets
```

## Semantic Versioning

### Version Number Format

```
MAJOR.MINOR.PATCH

MAJOR - Breaking API changes
MINOR - New features, backward compatible
PATCH - Bug fixes
```

### Versioning Decision Tree

| Type | Example | Impact |
|-------|---------|---------|
| `major` | 1.0.0 → 2.0.0 | Breaking changes, require migration |
| `minor` | 1.2.0 → 1.3.0 | New features, optional to upgrade |
| `patch` | 1.2.3 → 1.2.4 | Bug fixes, recommended to upgrade |

### Pre-release Versions

```json
// package.json
{
  "version": "1.0.0-alpha.1",
  "version": "1.0.0-beta.2",
  "version": "1.0.0-rc.1"
}
```

## Changelog Generation

### Changeset Changelog Format

```markdown
# CHANGELOG.md

## [1.0.0] - 2024-12-26

### Added
- New skill management CLI commands
- Agent Skills standard support

### Changed
- Migrated from tsc to Bun build system

### Fixed
- Skill validation bug in supportsSymlinks
- Type definition duplications in skills.ts

### Patched
- Security issue with fixed /tmp path in symlink testing

## [0.9.0] - 2024-12-20

### Added
- Initial Agent Skills implementation
```

### Manual Changelog Entry

```markdown
### Fixed

- Skill validation now properly handles nested YAML metadata in frontmatter
- Improved error messages for invalid skill names
```

## Pre-release Checklist

```bash
# Run all checks before release
bun run pre-release

# Should verify:
# - All tests passing
# - Coverage at 80%+
# - No linting errors
# - Build succeeds
# - Documentation updated
```

### Version Verification

```bash
# Check version is consistent across monorepo
turbo run check-versions

# Verify no unpublished changesets remain
bun changeset status
```

## Publishing to npm

### Publishing with Bun

```bash
# Build packages
bun run build

# Publish to npm
bun publish

# Publish with specific tag
bun publish --tag next

# Publish from package directory
cd packages/liaison && bun publish
```

### Publishing with npm (alternative)

```bash
# Build
bun run build

# Publish
npm publish

# Publish from directory
npm publish --directory ./packages/liaison
```

### Publishing with Access Token

```bash
# Set npm token
export NPM_TOKEN="your-token-here"

# Publish with token
bun publish --access public --token $NPM_TOKEN
```

### Dry Run Publishing

```bash
# Test publishing without actually uploading
bun publish --dry-run

# Check what would be published
bun pack
```

## GitHub Releases

### Creating GitHub Release

```bash
# Using gh CLI
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes "## What's Changed\n- Added Agent Skills\n- Fixed bugs" \
  --generate-notes
```

### Automated Release Notes

```bash
# Auto-generate notes from CHANGELOG.md
gh release create v1.0.0 --notes-file CHANGELOG.md

# Or use changeset
bun changeset publish
```

### Release Assets

```bash
# Attach build artifacts
gh release upload v1.0.0 ./dist/*.tgz

# Create and upload checksums
sha256sum dist/*.tgz > checksums.txt
gh release upload v1.0.0 checksums.txt
```

## Monorepo Publishing

### Publishing All Packages

```bash
# Publish all changed packages in monorepo
bun changeset publish

# This will:
# - Detect which packages changed
# - Update versions
# - Build packages
# - Publish to npm
# - Create GitHub release
```

### Turbo Build Order

```bash
# Build in dependency order
turbo run build

# Or build only changed packages
turbo run build --filter=liaison
```

### Version Coordination

```bash
# Ensure all packages reference compatible versions
turbo run check-versions

# Update cross-package dependencies
bun changeset version
```

## Post-release Tasks

### Tagging Releases

```bash
# Create and push git tag
git tag v1.0.0
git push origin v1.0.0

# Annotated tag with message
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Branch Management

```bash
# Merge release branch to main
git checkout main
git merge release/v1.0.0

# Delete release branch
git branch -d release/v1.0.0

# Delete remote release branch
git push origin --delete release/v1.0.0
```

### Announcements

```markdown
## Example Release Announcement

**Version 1.0.0 is now available!**

### What's New
- Agent Skills support with CLI commands
- 4 bundled skills: library-research, git-automation, liaison-workflows, bun-development
- Cross-platform symlinks for all major agent platforms

### Upgrading

```bash
bun upgrade @liaison-toolkit/liaison
```

### Migration Notes

No breaking changes in this release. Upgrade is optional.
```

## Verification

After releasing:
- [ ] All published packages install correctly
- [ ] npm registry shows new version
- [ ] GitHub release created with correct tag
- [ ] Changelog.md updated with all changes
- [ ] Version numbers are consistent across packages
- [ ] Post-release announcements sent
- [ ] Documentation updated for new features

## Examples from liaison-toolkit

### Example 1: Creating a Patch Release

```bash
# 1. Add changeset for bug fix
bun changeset
# Choose: packages/liaison, patch, "Fixed validation bug"

# 2. Bump version
bun changeset version
# Output: packages/liaison 0.1.0 → 0.1.1

# 3. Build
bun run build

# 4. Publish
bun publish

# 5. Tag
git tag v0.1.1
git push origin v0.1.1
```

### Example 2: Monorepo Release

```bash
# 1. Add changesets for all changed packages
bun changeset

# 2. Version and build all changed packages
bun changeset version
bun run build

# 3. Publish to npm and GitHub
bun changeset publish

# This handles:
# - Dependency version coordination
# - Build order
# - npm publishing
# - GitHub release creation
```

## Related Resources

- [Changesets Documentation](https://github.com/changesets/changesets)
- [Semantic Versioning 2.0.0](https://semver.org)
- [Bun Publishing](https://bun.sh/docs/cli/publish)
- [Turbo Monorepos](https://turbo.build/repo/docs)
- [GitHub CLI](https://cli.github.com/manual/gh_release_create)
