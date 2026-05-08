---
name: branch-integration-workflow
description: "Safely review and merge remote branches into stable. Trigger when: (1) reviewing open PRs, (2) integrating feature branches, (3) checking for stale branches with potential conflicts."
author: Claude Code
date: 2024-12-31
---

# Branch Integration Workflow

## Experiment Overview
| Item | Details |
|------|---------|
| **Date** | 2024-12-31 |
| **Goal** | Safely review and integrate remote branches when gh CLI unavailable |
| **Environment** | Git repository with multiple remote feature branches |
| **Status** | Success |

## Context

**Problem**: Need to review and merge remote branches, but `gh` CLI may not be available. Must safely identify which branches can merge cleanly and which have conflicts.

**Solution**: Use git commands to analyze branches, test merges non-destructively, and integrate cleanly.

## Verified Workflow

### 1. Fetch All Remote Branches

```bash
# Update local references to all remote branches
git fetch --all

# List all remote branches
git branch -r
```

Example output:
```
origin/claude/python-3.14-upgrade-analysis-fmdvv
origin/claude/update-training-v2.7.0-Zl9eH
origin/feature/v3.0-multi-agent
origin/release/v2.3.0
origin/stable
```

### 2. Analyze Branch Status

Check how far behind/ahead each branch is relative to stable:

```bash
# For each branch, check commits ahead/behind stable
for branch in origin/claude/python-3.14-upgrade-analysis-fmdvv origin/feature/v3.0-multi-agent; do
  echo "=== $branch ==="
  git log $branch --oneline -3
  echo "Behind stable by:"
  git rev-list --count $branch..stable
  echo ""
done
```

### 3. Build Analysis Table

| Branch | Behind Stable | Content Summary | Recommendation |
|--------|---------------|-----------------|----------------|
| `claude/python-3.14-*` | 4 commits | Docs, CI updates | Merge |
| `claude/update-training-*` | 4 commits | Tests, notebook | Merge |
| `feature/v3.0-*` | 14 commits | Major feature | Review conflicts |
| `release/v2.3.0` | 105 commits | Old release | Delete |

### 4. Test Merge Non-Destructively

**CRITICAL**: Always test merge before actually merging.

```bash
# Ensure clean working directory
git stash  # if needed

# Create temporary test branch from stable
git checkout -b test-merge-branch stable

# Attempt merge without committing
git merge --no-commit --no-ff origin/branch-name
```

**Possible outcomes:**
- "Automatic merge went well" → Safe to merge
- "CONFLICT" → Needs manual resolution

```bash
# Check what would be merged
git diff --cached --stat

# Abort the test merge
git merge --abort

# Clean up test branch
git checkout stable
git branch -D test-merge-branch

# Restore stashed changes
git stash pop  # if stashed earlier
```

### 5. Merge Clean Branches

Once confirmed clean:

```bash
# Merge with automatic commit message
git merge origin/branch-name --no-edit

# Or with custom message
git merge origin/branch-name -m "Merge branch-name: description"
```

### 6. Run Tests After Merge

```bash
# Always verify after merge
python -m pytest tests/ -v --tb=short
```

### 7. Handle Branches with Conflicts

For branches that don't merge cleanly:

```bash
# Check specific conflicts
git checkout -b resolve-conflicts stable
git merge --no-commit origin/conflicting-branch

# See conflicted files
git status | grep "both modified"

# Example output:
# both modified: CLAUDE.md
# both modified: alpaca_trading/training/__init__.py
```

**Options:**
1. **Defer**: Complex conflicts may need dedicated session
2. **Resolve**: Simple conflicts can be fixed manually
3. **Rebase**: Branch author should rebase onto stable first

### 8. Delete Obsolete Branches

For branches significantly behind with no unique value:

```bash
# Delete local branch
git branch -D old-branch

# Delete remote branch (if authorized)
git push origin --delete old-branch
```

## Decision Matrix

| Commits Behind | Merges Cleanly | Action |
|----------------|----------------|--------|
| < 10 | Yes | Merge immediately |
| < 10 | No | Review conflicts, resolve if simple |
| 10-50 | Yes | Merge, verify tests carefully |
| 10-50 | No | Defer - significant conflict resolution needed |
| > 50 | Any | Likely obsolete - consider deleting |

## Failed Attempts

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| Merge without testing first | Conflicts discovered mid-merge, messy abort | Always test with `--no-commit` first |
| Merge multiple branches at once | Hard to identify which caused test failures | Merge one at a time, test between |
| Assume clean merge = safe | Tests can still fail after clean merge | Always run tests after merge |
| Force push to fix bad merge | Rewrites history, breaks collaborators | Never force push to shared branches |
| Skip stashing local changes | Test merge fails due to dirty working tree | Always start with clean working directory |

## Commands Reference

```bash
# List remote branches
git branch -r

# Check branch divergence
git rev-list --count stable..origin/branch  # Commits in branch not in stable
git rev-list --count origin/branch..stable  # Commits in stable not in branch

# Find common ancestor
git merge-base stable origin/branch

# See branch commit history
git log origin/branch --oneline -10

# Test merge (non-destructive)
git merge --no-commit --no-ff origin/branch

# See merge changes
git diff --cached --stat

# Abort test merge
git merge --abort

# Actual merge
git merge origin/branch --no-edit

# Delete remote branch
git push origin --delete branch-name
```

## Checklist

- [ ] Fetch all remote branches
- [ ] Analyze each branch (commits behind, content summary)
- [ ] Build decision table
- [ ] For each merge candidate:
  - [ ] Stash local changes if needed
  - [ ] Create test branch
  - [ ] Test merge with `--no-commit`
  - [ ] Review changes with `git diff --cached --stat`
  - [ ] Abort test merge
  - [ ] Delete test branch
  - [ ] Restore stash if needed
- [ ] Merge clean branches one at a time
- [ ] Run tests after each merge
- [ ] Push merged changes

## Key Insights

- **Test before merge**: `--no-commit --no-ff` is non-destructive
- **One at a time**: Merge branches individually to isolate issues
- **Tests are truth**: Clean merge doesn't guarantee working code
- **Old branches decay**: >50 commits behind usually means obsolete
- **Clean working tree**: Stash changes before testing merges

## References
- Git merge documentation: https://git-scm.com/docs/git-merge
- Example session: Merged `python-3.14-upgrade` and `update-training-v2.7.0` branches
