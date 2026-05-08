---
name: git-worktrees
description: Use Git worktrees to isolate tasks and keep diffs small and parallelizable
version: 0.1.0
tags: [git, workflow]
triggers:
  - worktree
  - parallelize tasks
  - spike branch
---

# Git Worktrees

## Purpose
Create parallel worktrees for distinct tasks to keep changes isolated and reviews clean.

## When to Use
- Parallel task execution; spikes; conflicting changes

## Behavior
1. Pre-check: `git status --porcelain` must be clean.
2. Suggest names: `wt-TASK-<id>` or `wt-<short-topic>`.
3. Commands:
   - Create: `git worktree add ../<name> <base-branch>`
   - Switch: open the new dir; confirm branch
   - Remove (after merge): `git worktree remove ../<name>`
4. Cleanup checklist.

## Guardrails
- Never create/remove with dirty status.
- Echo exact commands; do not execute automatically.

## Integration
- `/lazy task-exec` (optional), Coder agent setup phase.

## Example Prompt
> Create a dedicated worktree for TASK-1.2 on top of `feature/auth`.

