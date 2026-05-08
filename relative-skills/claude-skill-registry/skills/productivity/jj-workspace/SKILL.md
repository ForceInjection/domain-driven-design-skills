---
name: jj-workspace
description: Create a jj workspace before starting work to enable parallel Claude sessions. Use this skill when starting a new task that should be isolated from other concurrent work. Triggers include "jj workspace", "parallel work", "create workspace", "isolated workspace".
metadata:
  short-description: Create jj workspace for parallel work
---

# JJ Workspace

Create a dedicated jj workspace before starting any task. This allows multiple Claude sessions to work in parallel without conflicts.

## Steps

1. Generate a short, descriptive workspace name based on the task (e.g., `workspace-add-login` or `workspace-fix-typo`)
2. Run `jj workspace add <workspace-name>` to create the workspace
3. Change into the workspace directory: `cd <workspace-name>`
4. Describe the change: `jj describe -m '<brief task description>'`
5. Continue all subsequent work within this workspace directory

If no task is provided, ask the user for a task description.
