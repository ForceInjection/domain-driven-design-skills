---
name: jj
description: Use the jj version control system. Always use it when the user mentions jj.
---

## jj

## Common Commands Cheat Sheet

### Basic Operations
- `jj status` - Show current status
- `jj log` - Show commit history
- `jj diff` - Show changes in current revision (@)
- `jj diff --git` - Show changes in git format
- `jj show` - View changes in current revision (same as diff)

### Making Changes
- `jj desc -m "msg"` - Add description to current change
- `jj commit -m "msg"` - Add description and start a new change
- `jj new` - Finalize current change and start a new one
- `jj new -r main` - Start a new change from main
- `jj squash` - Combine changes with parent
- `jj squash -i` - Interactive squash (select specific changes)
- `jj split` - Split current change into multiple parts
- `jj abandon` - Discard current change

### Navigation
- `jj edit <change-id>` - Switch to and edit a specific change
- `jj edit @-` - Move to previous change
- `jj next --edit` - Move to next change

### Branches (Bookmarks)
- `jj bookmark create <name>` / `jj b c <name>` - Create bookmark at current revision
- `jj b c -r@ <name>` - Create bookmark at @ (current revision)

### Rebasing & Merging
- `jj rebase -b@ -dmain` - Rebase current branch onto main
- `jj rebase -s <source> -d <dest>` - Rebase source onto destination
- `jj new <change1> <change2> -m "msg"` - Merge multiple changes

### Git Integration
- `jj git init` - Initialize jj repository with git backend
- `jj git fetch` - Fetch from remote (updates tracked bookmarks)
- `jj git push` - Push bookmarks to remote
- `jj git push --allow-new` - Push including new bookmarks

### Utilities
- `jj undo` - Undo last jj command
- `jj restore <file>` - Restore file from a revision
- `jj resolve` - Open conflict resolution UI
- `jj file annotate <file>` - Show file annotation (like git blame)

### Key Concepts
- `@` = the working copy (current revision)
- No staging area - all changes are automatically in @
- Changes are mutable until pushed
- Bookmarks = Git branches

## Advanced

To understand the syntax of the jj revset language (-r flag), use the following command: `jj help -k revsets`