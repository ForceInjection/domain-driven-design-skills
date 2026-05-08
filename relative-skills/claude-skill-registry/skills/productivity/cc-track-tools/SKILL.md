---
name: cc-track-tools
description: Provides paths to cc-track utility scripts for validation, task completion, and git operations. Use when a cc-track command needs to run a script.
---

# cc-track Tools

This skill provides access to cc-track's utility scripts. When invoked, you receive the base directory path which you use to run scripts.

## How to Use

1. Note the base directory provided when this skill loads
2. Run scripts using: `bun {base_directory}/scripts/{script-name}.ts [args]`
3. Scripts return JSON output - parse and interpret the results

## Available Scripts

### prepare-completion.ts

Runs validation suite (TypeScript, lint, tests, knip) for the active task.

```bash
bun {base_directory}/scripts/prepare-completion.ts
```

### complete-task.ts

Completes the active task: updates metadata, squashes WIP commits, creates PR.

```bash
bun {base_directory}/scripts/complete-task.ts
```

### specify.ts

Creates spec infrastructure: git branch, spec folder, metadata, CLAUDE.md update, GitHub issue.

```bash
bun {base_directory}/scripts/specify.ts "Feature title"
```

### backlog.ts

Add items to the project backlog or list existing items.

```bash
# Add an item
bun {base_directory}/scripts/backlog.ts "Your backlog item text"

# List all items
bun {base_directory}/scripts/backlog.ts --list
```

### git-session.ts

Git session utilities for managing WIP commits.

```bash
# Squash WIP commits with a message
bun {base_directory}/scripts/git-session.ts squash "commit message"

# Show diff since last user commit
bun {base_directory}/scripts/git-session.ts diff

# Show WIP commits
bun {base_directory}/scripts/git-session.ts wip

# Prepare for push (run lint/tests)
bun {base_directory}/scripts/git-session.ts prepare-push
```

## Requirements

- **bun**: Scripts are TypeScript and require bun to run
- **Project context**: Most scripts expect to run from a cc-track enabled project
