---
name: commit-helper
description: Generates clear, conventional commit messages from git diffs. Use when writing commit messages or reviewing staged changes.
allowed-tools: Read, Grep, Glob, Bash
---

# Commit Helper Skill

## Purpose

This skill helps generate high-quality commit messages following conventional commit format.

## Instructions

1. Run `git diff --staged` to see changes to be committed
2. Analyze the changes to understand:
   - What files were modified
   - What type of change (feat, fix, refactor, docs, etc.)
   - What the impact of the change is
3. Generate a commit message with:
   - A summary line under 50 characters
   - A blank line
   - A detailed description explaining the "why"
   - Optional: List of affected components

## Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## Examples

```
feat: add user authentication flow

Implement OAuth2 authentication with support for Google and GitHub providers.
This enables users to sign in without creating separate credentials.

Affected: src/auth/, src/components/Login.tsx
```
