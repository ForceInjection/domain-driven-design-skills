---
name: workbench-github
description: GitHub workflows for Workbench CLI. Use when creating pull requests from work items or wiring GitHub-specific actions.
---

## Key settings

- `.workbench/config.json`: github.owner, github.repository, github.host, git.defaultBaseBranch.
- Ensure GitHub auth is configured (token or `gh auth login`).

## Commands

Create a PR from a work item:
```bash
workbench github pr create TASK-0001 --fill
```

Create a draft PR targeting a base branch:
```bash
workbench github pr create TASK-0001 --draft --base main --fill
```

## Output

- PR URL printed to stdout or returned in JSON.
- Work item front matter updated with the PR link.

## Guardrails

- Prefer `workbench github pr create`; `workbench pr create` is deprecated.
- Use `--fill` to include the work item summary and acceptance criteria in the PR body.
