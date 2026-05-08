---
name: listing-worktrees
description: Use when user wants to see all autonomy worktrees with their status
---

# Listing Worktrees

## Overview

List all autonomy worktrees in the repository, showing their branch, location, HEAD commit, and lock status. Helps users navigate and manage multiple parallel worktrees.

**Core principle:** Worktrees are working directories, not branches. This lists checked-out worktrees only, not all autonomy branches.

## When to Use

Use this skill when:
- User runs `/list-worktrees` command
- User wants to see which autonomy branches have active worktrees
- User needs to find worktree paths for navigation
- User wants to identify locked or stale worktrees

**DO NOT use for:**
- Listing all autonomy branches (use `/list-branches` instead)
- Analyzing branch status or progress (use `/branch-status`)
- Comparing branches (use `/compare-branches`)

## Quick Reference

| Step | Action | Tool |
|------|--------|------|
| 1. Get all worktrees | Run git worktree list | Bash |
| 2. Filter to autonomy | Keep only .worktrees/autonomy/ paths | Bash |
| 3. Format output | Create table with branch, path, HEAD, lock status | Manual |
| 4. Provide guidance | Add navigation and management hints | Direct output |

## Process

### Step 1: Get All Worktrees

Retrieve complete worktree list from git:

```bash
# Get porcelain format for machine parsing
worktree_list=$(git worktree list --porcelain)

# Format:
# worktree /path/to/worktree
# HEAD <commit-hash>
# branch refs/heads/<branch-name>
#
# worktree /path/to/another
# ...
```

**Parse porcelain output:**
```bash
# Extract worktree information
# Each worktree is separated by blank line
# Fields: worktree, HEAD, branch, detached, locked

# Example parsing with awk:
git worktree list --porcelain | awk '
  /^worktree / { path = substr($0, 10) }
  /^HEAD / { head = substr($0, 6); head_short = substr(head, 1, 7) }
  /^branch / { branch = substr($0, 8); gsub("refs/heads/", "", branch) }
  /^locked/ { locked = "yes" }
  /^$/ {
    if (path != "") {
      print path "|" head_short "|" branch "|" locked
      path = ""; head = ""; head_short = ""; branch = ""; locked = "no"
    }
  }
  END {
    if (path != "") {
      print path "|" head_short "|" branch "|" locked
    }
  }
'
```

### Step 2: Filter to Autonomy Worktrees

Keep only worktrees in `.worktrees/autonomy/`:

```bash
# Filter parsed output to autonomy worktrees only
autonomy_worktrees=$(echo "$all_worktrees" | grep "\.worktrees/autonomy/")

# Count autonomy worktrees
count=$(echo "$autonomy_worktrees" | grep -c "^" || echo "0")

if [ "$count" -eq 0 ]; then
  echo "No autonomy worktrees found."
  echo ""
  echo "Autonomy branches exist in main repository or without worktrees."
  echo ""
  echo "To create a worktree:"
  echo "  /fork-worktree <strategy-name>"
  echo ""
  echo "To see all autonomy branches:"
  echo "  /list-branches"
  exit 0
fi
```

### Step 3: Format Output Table

Create readable table with worktree information:

```markdown
Autonomy Worktrees:

Branch                    Path                                      HEAD       Locked
autonomy/experiment-a     .worktrees/autonomy/experiment-a          a1b2c3d
autonomy/experiment-b     .worktrees/autonomy/experiment-b          d4e5f6g    🔒
autonomy/cdn-optimize     .worktrees/autonomy/cdn-optimize          h7i8j9k

Total: 3 autonomy worktrees
```

**Column specifications:**
- **Branch**: Full branch name (`autonomy/<strategy-name>`)
- **Path**: Relative path from repository root
- **HEAD**: Short commit hash (7 chars)
- **Locked**: 🔒 if locked, empty otherwise

**Implementation:**
```bash
# Print header
printf "%-25s %-41s %-10s %s\n" "Branch" "Path" "HEAD" "Locked"

# Print each worktree
echo "$autonomy_worktrees" | while IFS='|' read -r path head branch locked; do
  # Make path relative to repo root if absolute
  rel_path=$(realpath --relative-to="$repo_root" "$path" 2>/dev/null || echo "$path")

  # Lock indicator
  lock_icon=""
  if [ "$locked" = "yes" ]; then
    lock_icon="🔒"
  fi

  # Print row
  printf "%-25s %-41s %-10s %s\n" "$branch" "$rel_path" "$head" "$lock_icon"
done
```

### Step 4: Provide Guidance

Add helpful navigation and management instructions:

```markdown
To navigate to a worktree:
  cd .worktrees/autonomy/<strategy-name>

To remove a worktree:
  /remove-worktree <strategy-name>

To create a new worktree:
  /fork-worktree <strategy-name>

Note: This lists worktrees only. To see all autonomy branches (including those without worktrees):
  /list-branches
```

**Additional context:**
```markdown
Locked worktrees (🔒):
- Cannot be removed without unlocking
- To unlock: git worktree unlock .worktrees/autonomy/<strategy-name>
```

## Important Notes

### Worktrees vs Branches

**This command shows worktrees, not branches:**
- A branch may exist without a worktree (created via `/fork-iteration`)
- A branch with worktree can also be checked out in main repo (though git prevents this)
- Use `/list-branches` to see all autonomy branches regardless of worktrees

**Example scenario:**
```
Branches in repo:
- autonomy/experiment-a (has worktree)
- autonomy/experiment-b (has worktree)
- autonomy/experiment-c (no worktree, created via /fork-iteration)

/list-worktrees shows: experiment-a, experiment-b
/list-branches shows: experiment-a, experiment-b, experiment-c
```

### Main Worktree

The main repository working directory is technically a worktree, but NOT listed here:
- We filter to `.worktrees/autonomy/` only
- Main repo worktree is not part of parallel agent workflow
- Focus on dedicated worktrees for clarity

### Locked Worktrees

Worktrees can be locked to prevent accidental removal:

```bash
# Lock a worktree
git worktree lock .worktrees/autonomy/<strategy-name>

# Lock with reason
git worktree lock --reason "Long-running experiment" .worktrees/autonomy/<strategy-name>

# Unlock
git worktree unlock .worktrees/autonomy/<strategy-name>
```

**When locked:**
- `/remove-worktree` fails
- Must unlock manually before removal
- Useful for protecting important worktrees

### Relative Paths

Paths displayed are relative to repository root:
- `.worktrees/autonomy/experiment-a` (not absolute `/home/user/repo/.worktrees/...`)
- Easier to copy-paste for `cd` commands
- Consistent regardless of where command invoked

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "This shows all autonomy branches" | NO. Only branches with worktrees. Use /list-branches for all branches. |
| "Main repo appears in list" | NO. Only dedicated worktrees in .worktrees/autonomy/. |
| "I can see iteration progress here" | NO. This is just worktree metadata. Use /branch-status for iteration progress. |
| "I'll parse git worktree list directly" | YES, but use --porcelain for reliable parsing. |
| "All worktrees are unlocked" | NO. Check locked field; some may be locked. |

## After Listing Worktrees

User can:
- Navigate to worktree: `cd .worktrees/autonomy/<strategy-name>`
- Remove worktree: `/remove-worktree <strategy-name>`
- View branch status: `/branch-status <strategy-name>`
- Compare worktrees: `/compare-branches <strategy-a> <strategy-b>`

## Integration with Other Commands

**Relationship to other autonomy commands:**

| Command | Shows | Purpose |
|---------|-------|---------|
| `/list-worktrees` | Worktrees only | Navigate to worktree directories |
| `/list-branches` | All autonomy branches | See all exploration branches |
| `/branch-status` | Single branch details | Iteration progress and status |
| `/compare-branches` | Two branches comparison | Compare different approaches |

**Typical workflow:**
```bash
# See which worktrees exist
/list-worktrees

# Navigate to one
cd .worktrees/autonomy/experiment-a

# Work on iteration
/start-iteration
# ... work ...
/end-iteration

# Check all branches (including ones without worktrees)
/list-branches

# Clean up worktree when done
cd <repo-root>
/remove-worktree experiment-a
```

## Empty State

When no autonomy worktrees exist:
```markdown
No autonomy worktrees found.

Autonomy branches may exist in main repository or without worktrees.

To create a worktree:
  /fork-worktree <strategy-name>

To see all autonomy branches:
  /list-branches

To work on autonomy branch in main repo:
  /fork-iteration <strategy-name>
  /start-iteration
```
