---
name: fix-pr-automation
description: Work with the automated PR fixer and its CLI, including prompts and workflow configuration. Use when diagnosing failed CI auto-fixes, running the fix-pr CLI locally, or updating the fix-pr prompt or workflow.
---

# Fix PR Automation

## Overview
Run or adjust the automated PR fixer that proposes patches for failing CI jobs.

## Workflow
1. Read `docs/FIX-PR.md` for the end-to-end workflow and safety constraints.
2. Run locally from `dev/packages/release-scripts`: `pnpm fix:pr`.
3. Provide required secrets (`GITHUB_TOKEN` and `OPENAI_API_KEY` or `CODEX_API_KEY`) and verify the CLI output.
4. Update the prompt at `dev/packages/release-scripts/scripts/fix-pr/prompt.md` and the workflow at `.github/workflows/fix-pr.yml` when behavior changes are needed.
