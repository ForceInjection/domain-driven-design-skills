---
name: worktree-helper
description: Guide for creating and working in Git worktrees with a consistent workflow. Use when a user wants to run a task in a separate worktree, create or clean up worktrees, migrate a repo into a main/worktrees layout, or implement work based on an issue ID using GitHub/GitLab tooling.
---

# Worktree Helper

## Overview

Use this skill to set up a clean worktree workflow, create new worktrees, and guide issue-based or task-based work. Keep the user in control for any destructive or structural change.

## Workflow Decision Tree

1) **Is the request issue-based?**
- Yes → Use `references/hosting.md` to fetch issue details (MCP → gh → glab → manual).
- No → Continue with the task description.

2) **Is the repo layout already `main/` + `worktrees/`?**
- Yes → Work from `main/`.
- No → Recommend migration and offer to run `scripts/migrate_to_main_layout.sh`.

3) **Run preflight checks** (clean tree, base branch, existing worktrees) using `references/workflow.md`.

4) **Create a worktree** using the naming rules in `references/workflow.md`.

5) **Implement the task** in the worktree, then review with the user.

6) **Finish**: merge or open a PR/MR, then clean up worktrees and branches.

## Required Checks

- Confirm the user wants to migrate before running any migration command.
- Confirm before deleting branches or removing worktrees.
- If tooling is missing for issue intake, ask the user to paste issue details.

## Core References

- `references/workflow.md` — step-by-step commands, naming, create/remove worktrees.
- `references/hosting.md` — MCP/CLI/manual issue intake and tooling detection.
- `references/troubleshooting.md` — common worktree errors and fixes.

## Bundled Scripts

- `scripts/migrate_to_main_layout.sh` — migrate a repo root into a `main/` + `worktrees/` layout. Use only with explicit user confirmation.
