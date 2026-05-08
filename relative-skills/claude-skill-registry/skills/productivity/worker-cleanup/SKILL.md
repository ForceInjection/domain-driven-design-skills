---
name: worker-cleanup
description: Remove completed or abandoned worker worktrees and their branches. Use to clean up after workers finish their tasks.
allowed-tools: Bash, Read
---

# Worker Cleanup Skill

Remove completed or abandoned worker worktrees.

## Usage

```
/worker-cleanup [worktree-path-or-branch]
/worker-cleanup --all-merged
/worker-cleanup --all
```

## Examples

```
/worker-cleanup ../artemis-issue-42
/worker-cleanup feat/issue-42-retry
/worker-cleanup --all-merged
```

## Instructions

### Single Worktree Cleanup

When given a specific worktree or branch:

1. **Check for uncommitted changes**
   ```bash
   cd <worktree> && git status --porcelain
   ```
   If dirty, warn user and ask for confirmation.

2. **Check if branch was merged**
   ```bash
   git branch --merged main | grep <branch>
   ```
   If not merged, warn user about unmerged commits.

3. **Remove worktree**
   ```bash
   git worktree remove <worktree-path>
   ```

4. **Delete branch if merged**
   ```bash
   git branch -d <branch>  # Safe delete (fails if unmerged)
   ```

### Cleanup All Merged (`--all-merged`)

Find and remove all worktrees whose branches are merged to main:

```bash
# Get merged branches
MERGED=$(git branch --merged main | grep -v main)

# For each, remove worktree and branch
for branch in $MERGED; do
  worktree=$(git worktree list | grep "$branch" | awk '{print $1}')
  if [ -n "$worktree" ]; then
    git worktree remove "$worktree"
    git branch -d "$branch"
  fi
done
```

### Cleanup All (`--all`)

**DANGEROUS** - Removes all non-main worktrees:

1. List all worktrees
2. Show uncommitted/unmerged status for each
3. Require explicit confirmation
4. Remove each worktree and optionally delete branches

### Output

Show cleanup summary:
```
Cleaned up 3 worktrees:
  - ../artemis-issue-42 (feat/issue-42-retry) - merged, deleted
  - ../artemis-feat-logging (feat/add-logging) - merged, deleted
  - ../artemis-old-experiment (test/old) - unmerged, branch kept

Remaining worktrees: 1
  - ../artemis-wip (feat/work-in-progress) - has uncommitted changes
```

## Safety

- Never remove main worktree
- Warn before removing worktrees with uncommitted changes
- Keep unmerged branches by default (use `-D` flag to force)
- Always show what will be deleted before confirming
