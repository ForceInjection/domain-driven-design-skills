---
name: forking-worktree
description: Use when user wants to create new autonomy branch with dedicated worktree for parallel agent workflows
---

# Forking Worktree

## Overview

Create new autonomy branch with dedicated worktree for running parallel Claude agents on different branches simultaneously. All worktrees created at repository root level (`.worktrees/autonomy/`), regardless of where command is invoked.

**Core principle:** Worktrees represent branches, not iterations. Multiple iterations happen within same worktree. Worktrees enable parallel exploration with isolated working directories.

## When to Use

Use this skill when:
- User runs `/fork-worktree` command
- User wants to run multiple agents in parallel on different autonomy branches
- User wants isolated working directory for new exploration branch
- User wants to create autonomy branch without disturbing current working directory

**DO NOT use for:**
- Creating branches without worktrees (use forking-iteration instead)
- Creating non-autonomy branches (use git directly)
- Starting iterations (use starting-an-iteration instead)

## Quick Reference

| Step | Action | Tool |
|------|--------|------|
| 1. Parse arguments | Extract iteration (optional) and strategy-name | Manual |
| 2. Detect repository root | Find git root from anywhere (main repo or worktree) | Bash |
| 3. Validate | Check strategy-name, branch, and worktree path availability | Bash |
| 4. Resolve fork point | Find iteration tag or use HEAD | Bash |
| 5. Create worktree | Create branch + worktree at root level | Bash |
| 6. Report success | Confirm creation with navigation instructions | Direct output |

## Process

### Step 1: Parse and Validate Arguments

Extract arguments from command args:

**Format:** `[iteration] <strategy-name>`

**Parse:**
```
If args contains only one word:
  iteration = None
  strategy_name = args
Else if args contains two words:
  iteration = first word
  strategy_name = second word
Else:
  Error: "Invalid arguments. Usage: /fork-worktree [iteration] <strategy-name>"
```

**Validate strategy-name:**
- Must be kebab-case (lowercase, hyphens, no special chars)
- Must not be empty
- Should be descriptive (warn if too generic like "test" or "new")

**Normalize strategy-name:**
```bash
# Convert to lowercase, replace invalid chars with hyphens
strategy_name=$(echo "$strategy_name" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]-' '-' | sed 's/^-*//; s/-*$//')
```

### Step 2: Detect Repository Root

Find the git repository root, regardless of whether we're in main repo or inside a worktree:

```bash
# Get common git directory (works from anywhere, including worktrees)
git_common_dir=$(git rev-parse --git-common-dir)

# Repository root is parent of .git directory
# For main repo: .git is directory -> parent is repo root
# For worktree: .git is file pointing to .git/worktrees/X -> common-dir points back to main .git
if [ -d "$git_common_dir" ]; then
  repo_root=$(cd "$git_common_dir/.." && pwd)
else
  echo "Error: Unable to determine repository root"
  exit 1
fi
```

**Why this matters:**
- Ensures all worktrees created at `.worktrees/autonomy/` relative to repo root
- Prevents nested worktrees (`.worktrees/autonomy/experiment-a/.worktrees/...`)
- Works whether invoked from main repo or from within another worktree

### Step 3: Validate Branch and Worktree Availability

Check that we can create the new branch and worktree:

**Check branch doesn't exist:**
```bash
if git branch -a | grep -q "autonomy/$strategy_name\$"; then
  echo "Error: Branch 'autonomy/$strategy_name' already exists."
  echo ""
  echo "To work on existing branch:"
  echo "  git checkout autonomy/$strategy_name"
  echo ""
  echo "To create worktree for existing branch:"
  echo "  cd $repo_root"
  echo "  git worktree add .worktrees/autonomy/$strategy_name autonomy/$strategy_name"
  echo ""
  echo "Available autonomy branches:"
  git branch -a | grep autonomy/
  exit 1
fi
```

**Check worktree path doesn't exist:**
```bash
worktree_path="$repo_root/.worktrees/autonomy/$strategy_name"

if [ -e "$worktree_path" ]; then
  echo "Error: Worktree directory already exists: $worktree_path"
  echo ""
  echo "Remove it first:"
  echo "  /remove-worktree $strategy_name"
  echo "Or:"
  echo "  git worktree remove .worktrees/autonomy/$strategy_name"
  exit 1
fi
```

**Create parent directory if needed:**
```bash
mkdir -p "$repo_root/.worktrees/autonomy"
```

### Step 4: Resolve Fork Point

Determine what commit to fork from (same logic as forking-iteration):

**If iteration specified:**
```bash
# Search for iteration tag in current branch history
matching_tags=$(git tag --merged HEAD | grep "iteration-$(printf '%04d' $iteration)\$")

tag_count=$(echo "$matching_tags" | grep -c '^' || echo "0")

if [ "$tag_count" -eq 0 ]; then
  echo "Error: Iteration $iteration not found in current branch history."
  echo ""
  echo "Most recent iterations in current branch:"
  git tag --merged HEAD | grep 'iteration-' | tail -5
  exit 1
elif [ "$tag_count" -eq 1 ]; then
  fork_point="$matching_tags"
  fork_description="iteration $iteration (tag: $matching_tags)"
else
  # Multiple matches (shouldn't happen with branch-namespaced tags)
  echo "Multiple iteration tags found for iteration $iteration:"
  echo "$matching_tags"
  echo ""
  echo "Please specify which tag to fork from."
  exit 1
fi
```

**If iteration NOT specified:**
```bash
# Fork from current HEAD
fork_point=$(git rev-parse HEAD)
fork_description="current commit ($(git rev-parse --short HEAD))"
```

**Validate fork point exists:**
```bash
if ! git rev-parse "$fork_point" >/dev/null 2>&1; then
  echo "Error: Fork point '$fork_point' not found in git history."
  exit 1
fi
```

### Step 5: Create Worktree

Create the branch and worktree in a single git command:

```bash
# Navigate to repository root (important for relative path resolution)
cd "$repo_root"

# Create branch + worktree together
# -b creates new branch
# path is relative to repo root: .worktrees/autonomy/<strategy-name>
# fork_point is where to create the branch from
git worktree add -b "autonomy/$strategy_name" \
  ".worktrees/autonomy/$strategy_name" \
  "$fork_point"

# Verify worktree created successfully
if [ ! -d "$worktree_path" ]; then
  echo "Error: Failed to create worktree at $worktree_path"
  exit 1
fi

# Verify branch exists
if ! git branch -a | grep -q "autonomy/$strategy_name\$"; then
  echo "Error: Failed to create branch 'autonomy/$strategy_name'"
  exit 1
fi
```

**What this does:**
- Creates new branch `autonomy/<strategy-name>` at fork point
- Creates worktree directory at `.worktrees/autonomy/<strategy-name>/`
- Checks out the new branch in the worktree (not in current directory)
- Current directory remains unchanged

### Step 6: Report Success

Announce successful worktree creation with navigation instructions:

```markdown
✓ Worktree created successfully

Branch: autonomy/<strategy-name>
Worktree: .worktrees/autonomy/<strategy-name>/
Forked from: [fork_description]

Next steps:
1. Navigate to worktree:
   cd .worktrees/autonomy/<strategy-name>

2. Start iteration:
   /start-iteration

The worktree is an isolated working directory where you can work on this branch independently of other branches.
```

**Calculate relative path for convenience:**
```bash
# If we're already in a worktree, provide sibling navigation
current_dir=$(pwd)
if [[ "$current_dir" == *"/.worktrees/autonomy/"* ]]; then
  # In a worktree, provide relative navigation to sibling
  echo "From your current location:"
  echo "  cd ../$strategy_name"
fi
```

## Important Notes

### Repository Root Detection

**Works from anywhere:**
- Main repository working directory
- Inside any worktree (including deeply nested work)
- Detached HEAD state
- Any subdirectory

**All worktrees created at same level:**
```
repo-root/
├── .git/
├── .worktrees/
│   └── autonomy/
│       ├── experiment-a/    # Created from main repo
│       ├── experiment-b/    # Created from experiment-a worktree
│       └── experiment-c/    # Created from experiment-b worktree
```

### Branch and Worktree Lifecycle

**Branch persists after worktree removal:**
- Removing worktree (via `/remove-worktree`) deletes directory
- Branch `autonomy/<strategy-name>` and all commits persist
- Can create new worktree for same branch later
- All iteration tags remain in git history

**One branch per worktree:**
- Git enforces: branch can only be checked out in one worktree at a time
- Attempting to create worktree for already-checked-out branch fails
- This is a feature, not a bug (prevents conflicting changes)

### Worktrees Are Optional

**Existing workflows unchanged:**
- `/fork-iteration` still creates branches without worktrees
- All autonomy skills work in both main repo and worktrees
- Worktrees are enhancement for parallel agent workflows
- Use worktrees when beneficial, ignore when not needed

### Isolation and Independence

**Each worktree is independent:**
- Separate working directory with own file state
- Can have uncommitted changes independent of other worktrees
- Can be at different commits (though shares branch history)
- Perfect for running multiple Claude agents in parallel

**Shared git metadata:**
- All commits immediately visible across all worktrees
- Tags created in one worktree visible in all worktrees
- Branch operations (create, delete) affect all worktrees
- `.git` directory is shared

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Create worktree in current directory" | NO. Always create at repo root `.worktrees/autonomy/` regardless of where invoked. |
| "I'll use relative path .worktrees/..." | YES, but must cd to repo_root first. Path is relative to repo root. |
| "Branch exists, I'll create worktree for it" | NO. This skill creates NEW branches. Existing branch = error. |
| "I'll also start the iteration" | NO. Worktree creation is separate. User navigates and runs /start-iteration. |
| "I'll checkout the branch in current directory" | NO. Branch checked out in worktree, current directory unchanged. |
| "Nested worktrees are fine" | NO. All worktrees must be at root level `.worktrees/autonomy/`. |
| "I'll use git rev-parse --show-toplevel" | NO. That gives worktree root, not repo root. Use --git-common-dir. |

## After Creating Worktree

Once worktree is created:
- New directory exists at `.worktrees/autonomy/<strategy-name>/`
- Branch `autonomy/<strategy-name>` checked out in that directory
- Current working directory unchanged (still in main repo or original worktree)
- User must navigate to worktree: `cd .worktrees/autonomy/<strategy-name>`
- User runs `/start-iteration` to begin work
- All autonomy skills work normally in worktree

## Integration with Parallel Agents

**Typical workflow:**
```bash
# Terminal 1: First agent
/fork-worktree experiment-a
cd .worktrees/autonomy/experiment-a
/start-iteration
# Agent 1 works here

# Terminal 2: Second agent (can run while agent 1 is working)
/fork-worktree experiment-b
cd .worktrees/autonomy/experiment-b
/start-iteration
# Agent 2 works here independently

# Terminal 3: Analysis (from anywhere)
/list-branches
/compare-branches experiment-a experiment-b
```

Each agent has:
- Isolated working directory
- Independent iteration journals
- Separate uncommitted changes
- Shared git history and tags
