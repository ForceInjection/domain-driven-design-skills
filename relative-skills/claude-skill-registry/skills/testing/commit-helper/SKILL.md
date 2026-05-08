---
name: Commit Helper
description: Generate clear conventional commit messages from git diffs. Use when writing commit messages, reviewing staged changes, or after completing TDD cycles.
---

# Commit Helper

This skill invokes the `commit-helper` agent to generate commit messages.

## Quick Reference

**Invoke:** `/commit-helper [options]`

**Options:**
- No argument = analyse staged changes, return message
- `--commit` = generate message AND create commit

## Conventional Commit Format

```
<type>: <summary>

[optional body]

[optional footer]
```

### Types

| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring (no behaviour change) |
| `test` | Adding/updating tests |
| `docs` | Documentation only |
| `chore` | Build, tooling, dependencies |

### Summary Rules

- Under 50 characters
- Imperative mood ("add" not "added")
- No period at end

## Examples

**Simple:**
```
Add user authentication endpoint
```

**With body:**
```
Extract validation logic to separate module

Moved input validation from UserController to ValidationService
to improve testability and reuse across endpoints.
```

**Breaking change:**
```
Change API response format

BREAKING CHANGE: responses now wrap data in `result` key
```

## Agent Behaviour

The commit-helper agent:
1. Checks git status for staged changes
2. Reads staged diff
3. Checks recent commits for style consistency
4. Analyses change type and scope
5. Generates conventional commit message

Runs autonomously without user interaction.

## Rules

- **NEVER** add contributors unless explicitly requested
- **NEVER** commit files containing secrets
