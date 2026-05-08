---
name: quality-gates
description: Run ruff + pytest and fix issues minimally.
allowed-tools: Bash, Read, Grep, Glob, Write
---

# Quality Gates Skill

## When to use
- After implementing a meaningful chunk
- Before creating a PR or switching tasks

## Procedure
1) Run scripts/quality_gate.ps1
2) If failures:
   - fix smallest diff
   - re-run
3) Stop if the fix is risky and propose options.