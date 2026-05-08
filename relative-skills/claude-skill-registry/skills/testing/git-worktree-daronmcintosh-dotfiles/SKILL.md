---
name: git-worktree
description: Manage git worktrees with shell scripts for listing, creating, and deleting worktrees. Use when working with git repositories and need to create worktrees with new branches, delete existing worktrees, or view all worktrees. Particularly useful for parallel feature development or testing multiple branches simultaneously.
---

# Git Worktree Management

Manage git worktrees using dedicated shell scripts for listing, creating, and deleting worktrees.

## Quick Start

The skill provides three operations:

**List worktrees**: View all existing worktrees in the repository
```bash
scripts/list_worktrees.sh
```

**Create worktree**: Create a new worktree with a new branch
```bash
scripts/create_worktree.sh <path> <branch-name>
```

**Delete worktree**: Remove an existing worktree
```bash
scripts/delete_worktree.sh <path>
```

## Operations

### Listing Worktrees

Display all worktrees in the current repository with their paths and associated branches.

**Script**: `scripts/list_worktrees.sh`

**Usage**:
```bash
scripts/list_worktrees.sh
```

**Output**: Shows git worktree list with paths, commit hashes, and branch names.

### Creating Worktrees

Create a new worktree at a specified path with a new branch. The script ensures the path doesn't exist and the branch name is unique.

**Script**: `scripts/create_worktree.sh`

**Usage**:
```bash
scripts/create_worktree.sh <path> <branch-name>
```

**Parameters**:
- `<path>`: Directory path where the worktree will be created (e.g., `../feature-x`, `~/worktrees/bugfix-123`)
- `<branch-name>`: Name of the new branch to create (e.g., `feature-x`, `bugfix-123`)

**Validations**:
- Checks if path already exists
- Verifies branch name doesn't conflict with existing branches
- Confirms execution is within a git repository

**Example**:
```bash
scripts/create_worktree.sh ../feature-auth feature-auth
```

### Deleting Worktrees

Remove an existing worktree from the repository.

**Script**: `scripts/delete_worktree.sh`

**Usage**:
```bash
scripts/delete_worktree.sh <path>
```

**Parameters**:
- `<path>`: Path to the worktree to delete (must match a registered worktree)

**Validations**:
- Verifies the path is a registered worktree
- Shows current worktrees if path not found

**Example**:
```bash
scripts/delete_worktree.sh ../feature-auth
```

## Error Handling

All scripts include:
- Git repository validation
- Color-coded output (red for errors, green for success, yellow for warnings)
- Helpful error messages and usage tips
- Automatic worktree listing after operations

## Common Workflows

**Starting a new feature**:
```bash
# Create worktree for new feature
scripts/create_worktree.sh ../feature-user-profile feature-user-profile

# Work in the new worktree
cd ../feature-user-profile
# ... make changes, commit, push ...

# Return to main worktree
cd -

# Clean up when done
scripts/delete_worktree.sh ../feature-user-profile
```

**Viewing all active worktrees**:
```bash
scripts/list_worktrees.sh
```
