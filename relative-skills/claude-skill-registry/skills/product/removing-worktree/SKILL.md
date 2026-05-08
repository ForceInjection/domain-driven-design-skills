---
name: removing-worktree
description: Use when user wants to safely remove an autonomy worktree while preserving the branch
---

# Removing Worktree

## Overview

Safely remove an autonomy worktree directory while preserving the autonomy branch, all commits, and iteration history. Only removes the working directory; git history remains intact.

**Core principle:** Worktree removal is destructive for working directory but non-destructive for git history. Branch and all commits persist.

## When to Use

Use this skill when:
- User runs `/remove-worktree` command
- User finished with worktree and wants to clean up disk space
- User wants to recreate worktree from scratch
- User made mistakes in worktree and wants fresh start

**DO NOT use for:**
- Deleting branches (use git directly)
- Deleting iterations or journals (those are committed, can't be removed this way)
- Cleaning up non-autonomy worktrees

## Quick Reference

| Step | Action | Tool |
|------|--------|------|
| 1. Parse arguments | Extract --force flag and strategy-name | Manual |
| 2. Detect repository root | Find git root from anywhere | Bash |
| 3. Validate worktree exists | Check .worktrees/autonomy/<strategy-name>/ exists | Bash |
| 4. Safety checks | Check uncommitted changes (unless --force) | Bash |
| 5. Remove worktree | git worktree remove | Bash |
| 6. Cleanup metadata | git worktree prune | Bash |
| 7. Report success | Confirm removal, note branch persists | Direct output |

## Process

### Step 1: Parse Arguments

Extract arguments from command args:

**Format:** `[--force] <strategy-name>`

**Parse:**
```
force = false
strategy_name = ""

for arg in args:
  if arg == "--force":
    force = true
  else:
    if strategy_name != "":
      Error: "Multiple strategy names provided. Usage: /remove-worktree [--force] <strategy-name>"
    strategy_name = arg

if strategy_name == "":
  Error: "Strategy name required. Usage: /remove-worktree [--force] <strategy-name>"
```

**Normalize strategy-name:**
```bash
# Remove 'autonomy/' prefix if user included it
strategy_name=$(echo "$strategy_name" | sed 's/^autonomy\///')
```

### Step 2: Detect Repository Root

Find the git repository root (same logic as forking-worktree):

```bash
# Get common git directory
git_common_dir=$(git rev-parse --git-common-dir)

# Repository root is parent of .git directory
if [ -d "$git_common_dir" ]; then
  repo_root=$(cd "$git_common_dir/.." && pwd)
else
  echo "Error: Unable to determine repository root"
  exit 1
fi
```

### Step 3: Validate Worktree Exists

Check that the worktree actually exists:

```bash
worktree_path="$repo_root/.worktrees/autonomy/$strategy_name"

if [ ! -d "$worktree_path" ]; then
  echo "Error: Worktree not found: $worktree_path"
  echo ""
  echo "Available autonomy worktrees:"
  if [ -d "$repo_root/.worktrees/autonomy" ]; then
    ls -1 "$repo_root/.worktrees/autonomy"
  else
    echo "  (none)"
  fi
  echo ""
  echo "To see all worktrees: /list-worktrees"
  exit 1
fi
```

### Step 4: Safety Checks

Check for uncommitted changes (unless `--force`):

```bash
if [ "$force" = false ]; then
  # Change to worktree directory to check status
  cd "$worktree_path"

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "Error: Worktree has uncommitted changes"
    echo ""
    echo "Uncommitted changes in $worktree_path:"
    git status --short
    echo ""
    echo "Options:"
    echo "  1. Commit changes:"
    echo "     cd $worktree_path"
    echo "     /end-iteration  # or git commit"
    echo ""
    echo "  2. Force removal (discards changes):"
    echo "     /remove-worktree --force $strategy_name"
    exit 1
  fi

  # Check for untracked files (warn but allow)
  untracked_count=$(git ls-files --others --exclude-standard | wc -l)
  if [ "$untracked_count" -gt 0 ]; then
    echo "Warning: Worktree has $untracked_count untracked file(s)"
    echo ""
    git ls-files --others --exclude-standard | head -10
    echo ""
    echo "Proceeding with removal. Untracked files will be deleted."
    echo ""
  fi
fi
```

### Step 5: Remove Worktree

Remove the worktree using git:

```bash
# Return to repo root for git worktree commands
cd "$repo_root"

# Remove worktree
if [ "$force" = true ]; then
  git worktree remove --force ".worktrees/autonomy/$strategy_name"
else
  git worktree remove ".worktrees/autonomy/$strategy_name"
fi

# Check if removal succeeded
if [ $? -ne 0 ]; then
  echo "Error: git worktree remove failed"
  echo ""
  echo "Manual removal command:"
  echo "  cd $repo_root"
  echo "  git worktree remove --force .worktrees/autonomy/$strategy_name"
  echo "  git worktree prune"
  exit 1
fi
```

### Step 6: Cleanup Metadata

Prune stale worktree metadata:

```bash
# Clean up any stale administrative files
git worktree prune

# Verify worktree removed from git's list
if git worktree list | grep -q ".worktrees/autonomy/$strategy_name"; then
  echo "Warning: Worktree still appears in git worktree list"
  echo "Manual cleanup may be needed:"
  echo "  git worktree prune --verbose"
fi
```

### Step 7: Report Success

Announce successful removal with important notes:

```markdown
✓ Worktree removed successfully

Removed: .worktrees/autonomy/<strategy-name>/

Branch preserved:
- Branch: autonomy/<strategy-name>
- All commits and iteration tags remain in git history
- Can checkout branch later: git checkout autonomy/<strategy-name>
- Can create new worktree: /fork-worktree <strategy-name>  # (will fail if branch exists, use different name or delete branch first)

To delete the branch entirely:
  git branch -d autonomy/<strategy-name>  # Safe delete (only if merged)
  git branch -D autonomy/<strategy-name>  # Force delete
```

**If force was used:**
```markdown
⚠️  Force removal completed

Any uncommitted changes in the worktree were discarded.
```

## Important Notes

### Destructive vs Non-Destructive

**What gets destroyed (non-recoverable):**
- Worktree working directory (`.worktrees/autonomy/<strategy-name>/`)
- Any uncommitted changes in that directory
- Any untracked files in that directory

**What persists (safe):**
- Branch `autonomy/<strategy-name>` (can still git checkout)
- All committed iteration journals
- All iteration tags (`autonomy/<strategy-name>/iteration-NNNN`)
- All git history and commits

### Branch Still Exists

After worktree removal:
- Branch is "unlocked" (can be checked out elsewhere)
- All commits remain in git history
- Can checkout in main repo: `git checkout autonomy/<strategy-name>`
- Can create new worktree for same branch (but this skill creates new branch, not for existing)
- To work with existing branch in worktree: manual git command needed

### Force Flag Behavior

**Without `--force`:**
- Checks for uncommitted changes (fails if found)
- Warns about untracked files (but proceeds)
- Safe for preserving work

**With `--force`:**
- Skips all safety checks
- Discards uncommitted changes
- Deletes untracked files
- Use when worktree is broken or changes are intentional throwaways

### Cannot Remove Current Worktree

Git prevents removing the worktree you're currently in:

```bash
# This fails:
cd .worktrees/autonomy/experiment-a
/remove-worktree experiment-a
# Error: Cannot remove current working tree
```

**Solution:** Navigate to different directory first:
```bash
cd "$repo_root"  # Or any other directory
/remove-worktree experiment-a
```

### Locked Worktrees

If worktree was locked (via `git worktree lock`):
- Removal fails with error
- Must unlock first: `git worktree unlock .worktrees/autonomy/<strategy-name>`
- Then retry removal

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "This deletes the branch" | NO. Only removes worktree directory. Branch persists. |
| "This deletes iteration journals" | NO. Journals are committed. They persist in git history. |
| "I can remove worktree I'm currently in" | NO. Must navigate away first. |
| "Force is always safe" | NO. Force discards uncommitted work. Use carefully. |
| "After removal, branch is gone" | NO. Branch still exists. Can checkout or delete separately. |
| "I'll also clean up the branch" | NO. Worktree removal is separate from branch deletion. |

## After Removing Worktree

Once worktree is removed:
- Directory `.worktrees/autonomy/<strategy-name>/` no longer exists
- Branch `autonomy/<strategy-name>` still exists
- All iteration journals in git history
- All tags preserved
- Branch can be checked out in main repo or new worktree created for it
- Disk space freed

## Manual Recovery

If automated removal fails or worktree is in broken state:

```bash
# Manual removal commands
cd <repo-root>

# Force remove worktree
git worktree remove --force .worktrees/autonomy/<strategy-name>

# If that fails, manually delete directory then prune
rm -rf .worktrees/autonomy/<strategy-name>
git worktree prune

# Verify cleanup
git worktree list
```

## Relationship to Branch Deletion

**Worktree removal ≠ Branch deletion**

After removing worktree:
```bash
# Branch still exists
git branch -a | grep autonomy/<strategy-name>
# autonomy/<strategy-name>

# To also delete branch:
git branch -D autonomy/<strategy-name>

# This removes branch and all its commits from local repo
# (Tags remain unless explicitly deleted)
```

Use worktree removal for cleanup, branch deletion for ending exploration.
