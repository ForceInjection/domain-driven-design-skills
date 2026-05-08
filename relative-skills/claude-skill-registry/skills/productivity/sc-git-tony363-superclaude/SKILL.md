---
name: sc-git
description: Git operations with intelligent commit messages and workflow optimization. Use when committing changes, managing branches, or optimizing git workflows.
---

# Git Operations Skill

Intelligent git operations with smart commit generation.

## Quick Start

```bash
# Status analysis
/sc:git status

# Smart commit
/sc:git commit --smart-commit

# Interactive merge
/sc:git merge feature-branch --interactive
```

## Behavioral Flow

1. **Analyze** - Check repository state and changes
2. **Validate** - Ensure operation is appropriate
3. **Execute** - Run git command with automation
4. **Optimize** - Apply smart messages and patterns
5. **Report** - Provide status and next steps

## Flags

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--smart-commit` | bool | false | Generate conventional commit message |
| `--interactive` | bool | false | Guided operation mode |

## Evidence Requirements

This skill does NOT require hard evidence. Git operations are self-documenting through:
- Commit history
- Branch state
- Repository logs

## Operations

### Status Analysis
```
/sc:git status
# Repository state with change summary
# Actionable recommendations
```

### Smart Commit
```
/sc:git commit --smart-commit
# Analyzes changes
# Generates conventional commit message
# Format: type(scope): description
```

### Branch Operations
```
/sc:git branch feature/new-feature
/sc:git checkout main
/sc:git merge feature-branch
```

### Interactive Operations
```
/sc:git merge feature --interactive
# Guided merge with conflict resolution
# Step-by-step assistance
```

## Commit Message Format

Smart commits follow Conventional Commits:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `refactor` - Code restructuring
- `test` - Test additions
- `chore` - Maintenance

## Examples

### Analyze Changes
```
/sc:git status
# Summary of staged/unstaged changes
# Recommended next actions
```

### Commit with Analysis
```
/sc:git commit --smart-commit
# Scans diff, generates message:
# feat(auth): add JWT token refresh mechanism
```

### Guided Merge
```
/sc:git merge feature/auth --interactive
# Conflict detection and resolution guidance
# Step-by-step assistance
```

## Tool Coordination

- **Bash** - Git command execution
- **Read** - Repository state analysis
- **Grep** - Log parsing
- **Write** - Commit message generation
