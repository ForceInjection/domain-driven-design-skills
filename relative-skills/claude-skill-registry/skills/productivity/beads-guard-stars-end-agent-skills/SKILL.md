---
name: beads-guard
description: |
  Safe Beads workflow helper (warning-only). Use before bd sync/close/create to
  avoid JSONL conflicts. Ensures you are on a feature branch, up to date with
  origin/master, and stages Beads files cleanly with Feature-Key commits.
tags: [beads, dx, guardrail]
---

# Beads Guard

Avoid recurring .beads/issues.jsonl conflicts and master commits.

## How to run (manual steps)

```bash
# 0) Must be on a feature branch (not master)
git status -sb

# 1) Rebase to latest master
git fetch origin master
git rebase origin/master

# 2) Clear stale locks
rm -f .beads/bd.sock* || true

# 3) Pull Beads DB to JSONL
bd pull

# 4) Do your Beads op
#   bd close <id> --reason "..."
#   bd create "..." --type ... --priority ...
#   bd sync

# 5) Stage Beads files
git add .beads/issues.jsonl .beads/deletions.jsonl 2>/dev/null || true

# 6) Commit with Feature-Key trailer (on feature branch)
git commit -m "beads: <summary>\n\nFeature-Key: <id>\nAgent: claude-code\nRole: backend-engineer"

# 7) Push/PR as normal
git push
```

## Notes
- Warning-only flow; no hard blocks.
- If branch is behind master and Beads changed, rebase before committing.
- Keep Beads ops off master to avoid hook warnings.
