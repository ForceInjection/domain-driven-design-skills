---
name: husky-hooks-generator
description: Generate Husky Git hooks for pre-commit, pre-push, and commit-msg automation. Triggers on "create husky hooks", "generate git hooks", "husky setup", "pre-commit hooks".
---

# Husky Hooks Generator

Generate Husky Git hooks for automating code quality checks on commits.

## Output Requirements

**File Output:** `.husky/pre-commit`, `.husky/commit-msg`, `.husky/pre-push`
**Format:** Shell scripts
**Standards:** Husky 9.x

## When Invoked

Immediately generate Husky hook files for the specified automation tasks.

## Example Invocations

**Prompt:** "Create husky hooks for lint and test"
**Output:** Complete `.husky/pre-commit` with lint-staged and test commands.
