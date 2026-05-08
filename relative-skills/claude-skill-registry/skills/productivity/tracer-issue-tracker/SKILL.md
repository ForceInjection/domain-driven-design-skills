---
name: Tracer Issue Tracker
description: Manage tasks and dependencies with Tracer CLI. Use for issue tracking, dependency management, finding ready work, and AI agent workflows.
---

## Overview
Tracer is a blazing-fast, CLI-based issue tracker designed specifically for AI agents. It enables tracking tasks, managing dependencies, and discovering ready work—all from the command line with git-friendly JSONL storage.

## Key Features
- **Dependency-aware**: Track what blocks what, automatically discover ready work
- **Lightning-fast**: ~5ms per operation, built in Rust
- **AI-optimized**: JSON output on all commands for programmatic parsing
- **Git-native**: JSONL storage syncs via git, clean diffs
- **Distributed**: Share work across agents and sessions

## Installation
```bash
# Quick install
cargo install --git https://github.com/Abil-Shrestha/tracer

# Verify
tracer --version
tr --version  # Both commands work identically
```

Prerequisites: [Rust toolchain](https://rustup.rs/)

## Git Configuration

After initializing Tracer, configure git to track the JSONL file while ignoring the database:

```bash
# Add the database to .gitignore (only needs to be done once)
echo ".trace/bd.db" >> .gitignore

# Commit .gitignore if it's a new entry
git add .gitignore
git commit -m "Ignore Tracer database file"

# Always commit the JSONL file to share issues across sessions/agents
git add .trace/issues.jsonl
git commit -m "Update Tracer issues"
```

**Why this matters:**
- `.trace/issues.jsonl` - Human-readable, git-friendly, should be committed and shared
- `.trace/bd.db` - Binary database file, should NOT be committed (regenerated from JSONL)

## Quick Start

### Initialize a project
```bash
tracer init
```

### Learn interactively
```bash
tracer learn  # Interactive tutorial
```

## Core Commands

### Creating Issues
```bash
# Basic issue
tracer create "Fix login bug"

# With priority and type
tracer create "User authentication system" -p 1 -t epic
tracer create "Design database schema" -t task

# Get JSON output (essential for AI agents)
tracer create "New feature" --json
```

**Types**: `epic`, `task`, `bug`, `feature`
**Priorities**: `1` (highest) to `5` (lowest)

### Listing Issues
```bash
# List all open issues
tracer list

# Filter by status
tracer list --status open
tracer list --status in_progress
tracer list --status closed

# Filter by priority
tracer list --priority 1

# Get JSON output
tracer list --json
```

### Viewing Issue Details
```bash
tracer show <id>
tracer show test-42 --json
```

### Updating Issues
```bash
# Change status
tracer update <id> --status in_progress
tracer update <id> --status blocked

# Common statuses: open, in_progress, blocked, closed

# Update with JSON output
tracer update test-5 --status in_progress --json
```

### Closing Issues
```bash
tracer close <id> --reason "Completed"
tracer close test-10 --reason "Won't fix"
```

## Dependency Management

### Adding Dependencies
```bash
# "from" depends on "to"
tracer dep add <from> <to> --type blocks

# Example: API depends on schema being done first
tracer dep add test-3 test-2 --type blocks
```

**Dependency Types**:
- `blocks`: Task A blocks Task B (B can't start until A is done)
- `parent-child`: Hierarchical relationship
- `discovered-from`: B was discovered while working on A
- `related`: General relationship

### Viewing Dependencies
```bash
# Show dependency tree for an issue
tracer dep tree <id>
tracer dep tree test-5 --json
```

## Finding Work

### Ready Work (Unblocked Tasks)
```bash
# Show tasks with no blockers
tracer ready

# Limit results
tracer ready --limit 5

# Get JSON output
tracer ready --json
```

This is **crucial** for AI agents: Tracer automatically identifies which tasks can be started right now based on dependency chains.

### Blocked Tasks
```bash
# Show what's currently blocked
tracer blocked
tracer blocked --json
```

## Data Management

### Export
```bash
# Export to file
tracer export -o backup.jsonl

# Export to stdout
tracer export
```

### Statistics
```bash
tracer stats
tracer stats --json
```

## Workflow Examples

### 1. Building a Feature with Dependencies
```bash
# Create epic
tracer create "User authentication system" -t epic

# Create dependent tasks
tracer create "Design database schema" -t task
# → Returns test-1

tracer create "Build login API" -t task
# → Returns test-2

tracer create "Create login UI" -t task
# → Returns test-3

# Link dependencies
tracer dep add test-2 test-1 --type blocks  # API needs schema
tracer dep add test-3 test-2 --type blocks  # UI needs API

# Find what to work on
tracer ready
# → Shows test-1 (unblocked)

# Start work
tracer update test-1 --status in_progress

# Complete and move to next
tracer close test-1 --reason "Schema created"
tracer ready
# → Now shows test-2 (newly unblocked)
```

### 2. AI Agent Session Management
```bash
# Start of session - see what's ready
tracer ready --json

# Work on task
tracer update test-5 --status in_progress --json

# Discover new work while coding
tracer create "Refactor error handling" -t task --json
tracer dep add new-id test-5 --type discovered-from

# End of session
tracer update test-5 --status in_progress --json
tracer export -o session-backup.jsonl
```

### 3. Multi-Agent Collaboration
```bash
# First time setup (any agent, only once)
echo ".trace/bd.db" >> .gitignore
git add .gitignore
git commit -m "Ignore Tracer database"

# Agent 1: Creates and claims work
tracer create "Implement feature X" -t task
tracer update test-10 --status in_progress
git add .trace/issues.jsonl
git commit -m "Agent 1: Start feature X"
git push

# Agent 2: Pulls and finds available work
git pull  # Tracer auto-imports changes from JSONL
tracer ready  # test-10 won't show (in progress)
tracer create "Implement feature Y" -t task
tracer update test-11 --status in_progress
git add .trace/issues.jsonl
git commit -m "Agent 2: Start feature Y"
git push
```

## Best Practices for AI Agents

### 1. Always Use JSON Output
Add `--json` to commands when you need to parse results programmatically:
```bash
tracer ready --json
tracer list --status open --json
tracer show test-5 --json
```

### 2. Check Ready Work First
At the start of each session:
```bash
tracer ready --json
```
This ensures you work on unblocked tasks.

### 3. Track Work Discovered During Coding
When you discover new tasks while working:
```bash
tracer create "New subtask" -t task
tracer dep add new-id current-id --type discovered-from
```

### 4. Update Status Frequently
Keep the tracker current:
```bash
tracer update <id> --status in_progress  # When starting
tracer update <id> --status blocked --json  # When stuck
tracer close <id> --reason "Completed"  # When done
```

### 5. Commit Often
Tracer stores everything in `.trace/issues.jsonl` (commit this, NOT the `.trace/bd.db` file):
```bash
# Make sure .trace/bd.db is in .gitignore first (see Git Configuration section)
git add .trace/issues.jsonl
git commit -m "Update task status"
```

### 6. Use Priorities
Help the AI (or yourself) focus:
```bash
tracer list --priority 1 --json  # High-priority work
```

## Pro Tips

### Shorthand
Use `tr` instead of `tracer` for faster typing:
```bash
tr create "New task"
tr ready
tr list --json
```

### Auto-Discovery
Tracer auto-discovers the database from any subdirectory (like git):
```bash
cd src/components/
tr list  # Works from anywhere in project
```

### Performance
With 10,000 issues:
- Create: ~5ms
- List: ~15ms
- Ready query: ~10ms

### Cycle Detection
Tracer prevents dependency cycles:
```bash
tracer dep add test-2 test-1 --type blocks
tracer dep add test-1 test-2 --type blocks  # Will fail
```

## Common Patterns

### Daily Standup
```bash
# What did I work on?
tracer list --status in_progress

# What's ready for today?
tracer ready --limit 5

# What's blocked?
tracer blocked
```

### Project Planning
```bash
# Create epic
tracer create "Q4 Feature Release" -t epic -p 1

# Break down into tasks
tracer create "Backend API" -t task
tracer create "Frontend UI" -t task
tracer create "Testing" -t task

# Link dependencies
tracer dep add test-10 test-9 --type blocks
tracer dep add test-11 test-10 --type blocks
```

### Bug Triage
```bash
# Create bugs with priority
tracer create "Critical: Auth failing" -t bug -p 1
tracer create "UI alignment off" -t bug -p 3

# List by priority
tracer list --priority 1 --status open
```

## Integration with Claude

When helping users with Tracer:

1. **Suggest creating issues** for complex multi-step tasks
2. **Use dependency tracking** for tasks with clear ordering
3. **Check `tracer ready`** before suggesting what to work on
4. **Parse JSON output** when programmatic access is needed
5. **Remind to commit** `.trace/issues.jsonl` for version control

Example conversation flow:
```
User: "I need to build a login system"

Claude: Let's break this down with Tracer:

1. Create an epic for the feature:
   tracer create "User login system" -t epic -p 1

2. Create dependent tasks:
   tracer create "Database schema for users" -t task
   tracer create "Authentication API endpoints" -t task
   tracer create "Login UI component" -t task

3. Link dependencies:
   tracer dep add test-2 test-1 --type blocks
   tracer dep add test-3 test-2 --type blocks

4. See what's ready:
   tracer ready
   
This will show you should start with the database schema first.
```

## Resources

- [GitHub Repository](https://github.com/Abil-Shrestha/tracer)
- [Quick Start Guide](https://github.com/Abil-Shrestha/tracer/blob/main/QUICK_START.md)
- [AI Agent Guide](https://github.com/Abil-Shrestha/tracer/blob/main/AGENTS.md)

## Summary

Tracer is purpose-built for AI agents and developers who want a fast, git-friendly way to track work with dependency awareness. Key advantages:

- **Speed**: Operations in milliseconds
- **Simplicity**: Pure CLI, no server needed
- **Smart**: Automatic ready work detection
- **Portable**: JSONL files sync via git
- **AI-native**: JSON output on every command

Perfect for managing complex projects with multiple dependent tasks, especially when working with AI coding agents across sessions.
