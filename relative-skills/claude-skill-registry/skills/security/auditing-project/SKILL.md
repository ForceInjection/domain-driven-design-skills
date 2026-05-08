---
name: auditing-project
description: Audits the project for consistency issues that may arise from manual editing. Checks package scripts, tsconfig paths, README tables, and other conventions.
---

# Auditing Project

Check for inconsistencies that may have been introduced by manual editing.

## Steps

Run each audit script with `--check` flag:

1. **Package scripts**: `.claude/skills/authoring-global-scripts/scripts/sync-package-scripts.ts --check`
2. **TSConfig paths**: `.claude/skills/syncing-tsconfig-paths/scripts/sync-tsconfig-paths.ts --check`

If issues are found, run the corresponding skill to fix them.

## Reference

### What Gets Checked

| Check | Detects |
|-------|---------|
| Package scripts | Scripts out of sync with `_:*` template, extra scripts |
| TSConfig paths | Paths not matching package.json imports |

### When to Use

- After manual editing of package.json, tsconfig.json
- Before committing changes
- When something "feels wrong" after out-of-band edits
- CI verification (all checks should pass)

## Notes

- Each audit exits non-zero if issues found
- Prefer running audits over blindly syncing - understand what changed
- If audit finds issues, the corresponding sync skill will fix them
