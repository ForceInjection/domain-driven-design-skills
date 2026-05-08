---
name: clear-memory
description: Clean up old memory files
---

# Clear Memory

Clean up old session files and optionally reset facts.

## Usage

```
/memory-keeper:clear-memory [all|old]
```

## Actions

### Archive old files (recommended):
```bash
node "scripts/counter.js" compress
```

This archives session files older than 30 days into monthly archives:
```
sessions/2025-10-15_0300.md -> sessions/archive/2025-10.md
```

### Clear facts only:
```bash
node "scripts/counter.js" clear-facts
```

Clears all facts (decisions, patterns, issues, concepts) but keeps `_meta`.

### Clear everything (manual):

**WARNING: Destructive operation**

```bash
# Remove all session files
rm -rf .claude/memory/sessions/*.md
rm -rf .claude/memory/sessions/*.jsonl

# Reset facts
node "scripts/counter.js" clear-facts

# Optionally clear memory.md
rm .claude/memory/memory.md
```

## Recommendations

1. **Regular maintenance**: Run `compress` monthly
2. **Before major changes**: Create backup first
3. **Keep hierarchical files**: Don't delete project.md, architecture.md, conventions.md

## Notes

- `compress` is non-destructive (archives, doesn't delete)
- `clear-facts` preserves counter state in `_meta`
- Archived files can be manually reviewed in `sessions/archive/`
