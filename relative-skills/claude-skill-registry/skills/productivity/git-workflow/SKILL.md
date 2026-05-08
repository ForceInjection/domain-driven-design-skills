---
name: git-workflow
description: Enforce branch-based workflow with draft PRs for emoji_gen. Use when starting new work, creating branches, or opening pull requests. Mentions of "new feature", "bug fix", "start work", "create PR", or "pull request" should trigger this Skill.
allowed-tools: Bash, Read
---

# Git Workflow for emoji_gen

This Skill enforces the branch-based workflow with draft PRs required for all non-trivial changes.

## Core Principle

**ALWAYS use feature branches and draft PRs** for any non-trivial work.

## Complete Workflow

### 1. Start New Work

**Before making any changes:**

```bash
# Ensure you're on main and up-to-date
git checkout main
git pull origin main

# Create feature branch with conventional naming
git checkout -b <type>/<descriptive-name>
```

### 2. Branch Naming Convention

Use Conventional Commits prefixes:

| Prefix | Use For | Example |
|--------|---------|---------|
| `feat/` | New features | `feat/add-emoji-categories` |
| `fix/` | Bug fixes | `fix/negative-count-validation` |
| `docs/` | Documentation | `docs/update-readme-install` |
| `build/` | Build/CI changes | `build/add-msrv-check` |
| `test/` | Test additions | `test/add-pool-size-validation` |
| `refactor/` | Code refactoring | `refactor/extract-selection-logic` |
| `perf/` | Performance | `perf/optimize-emoji-lookup` |
| `chore/` | Maintenance | `chore/update-dependencies` |

**Examples:**
```bash
git checkout -b feat/add-emoji-filtering
git checkout -b fix/unicode-encoding-bug
git checkout -b docs/docker-workflow
git checkout -b build/ci-coverage-reporting
```

### 3. Make Changes and Commit

Work on your changes, committing as you go:

```bash
# Stage your changes
git add <files>

# Create commit following Conventional Commits
# (Use the conventional-commits Skill for proper formatting)
git commit -m "..."

# Push commits to remote
git push
```

### 4. Create Draft Pull Request

**After first commit:**

```bash
# Push branch to remote
git push -u origin <branch-name>

# Create draft PR
gh pr create --draft --title "<type>: descriptive title" --body "$(cat <<'EOF'
## Summary

[Brief description of changes and motivation]

## Changes

- [Bullet point list of key changes]
- [Another change]

## Test Plan

- [ ] [Testing step 1]
- [ ] [Testing step 2]
- [ ] Run `./docker-dev.sh test`
- [ ] Run `./docker-dev.sh clippy`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Shortcut for auto-generated title/body:**
```bash
gh pr create --draft --fill
```

See `pr-template.md` for the full PR description template.

### 5. Continue Working

Push additional commits to the branch:

```bash
# Make more changes
git add .
git commit -m "..."
git push
```

The PR automatically updates with each push.

### 6. Mark PR as Ready

When work is complete and CI passes:

```bash
gh pr ready
```

### 7. Merge After Review

After CI passes and review is complete:

```bash
# Via GitHub CLI
gh pr merge --squash

# Or use GitHub web UI
gh pr view --web
```

## When to Use This Workflow

**ALWAYS use feature branches and draft PRs for:**
- ✅ New features
- ✅ Bug fixes
- ✅ Refactoring
- ✅ Documentation updates
- ✅ CI/CD changes
- ✅ Any non-trivial changes

**Direct commits to main are ONLY acceptable for:**
- ❌ Emergency hotfixes (use with extreme caution)
- ❌ Version bumps for releases

## PR Best Practices

### Title Format
Follow Conventional Commits format:
```
feat: add emoji category filtering
fix: correct negative count validation
docs: update installation instructions
build(ci): add MSRV verification workflow
```

### Description Structure

See `pr-template.md`, but include:

1. **Summary**: What changed and why
2. **Changes**: Bulleted list of key changes
3. **Test Plan**: How to verify the changes work
4. **Breaking Changes**: If applicable
5. **Related Issues**: Link any related issues

### Before Marking Ready

**Checklist:**
- [ ] All commits follow Conventional Commits format
- [ ] Tests pass: `./docker-dev.sh test`
- [ ] Linting passes: `./docker-dev.sh clippy`
- [ ] Documentation updated if needed
- [ ] PR description is complete
- [ ] CI checks are passing

## Common Commands

```bash
# View PR status
gh pr status

# View PR in browser
gh pr view --web

# Check current branch
git branch --show-current

# See what would be in PR
git log main..HEAD

# See diff vs main
git diff main...HEAD
```

## Workflow Example

```bash
# 1. Start new feature
git checkout main
git pull origin main
git checkout -b feat/add-emoji-categories

# 2. Make changes
# ... edit files ...
git add src/lib.rs
git commit -m "feat: add emoji category support"

# 3. Push and create draft PR
git push -u origin feat/add-emoji-categories
gh pr create --draft --title "feat: add emoji category filtering" \
  --body "Implements emoji categorization and filtering by category"

# 4. Continue working
# ... make more changes ...
git add .
git commit -m "feat: add category tests"
git push

# 5. When ready
gh pr ready

# 6. After CI and review
gh pr merge --squash
```

## Error Prevention

**DO NOT:**
- Start work without creating a branch
- Commit directly to main
- Create PRs that aren't marked as draft initially
- Push without running tests locally first
- Skip the PR process for non-trivial changes

**DO:**
- Always start from updated main
- Use descriptive branch names
- Create draft PRs early in the process
- Keep PRs focused on a single change
- Ensure CI passes before marking ready
