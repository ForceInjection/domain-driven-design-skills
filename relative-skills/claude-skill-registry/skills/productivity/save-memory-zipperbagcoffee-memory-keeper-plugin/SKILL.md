---
name: save-memory
description: Manually save current session memory to files
---

# Save Memory

Force immediate save of session memory.

## Usage

```
/memory-keeper:save-memory
```

## Actions

1. **Save to memory.md:**
```bash
echo -e "\n## $(date +%Y-%m-%d_%H%M)\n[Summary of current session progress]" >> ".claude/memory/memory.md"
```

2. **Create session file:**
```bash
cat > ".claude/memory/sessions/$(date +%Y-%m-%d_%H%M).md" << 'ENDSESSION'
# Session TIMESTAMP

## Summary
[What has been accomplished so far]

## Decisions
- [type] Decision: Reason
  - files: affected files
  - concepts: relevant concepts

## Patterns
- [type] Pattern observed
  - concepts: tags

## Issues
- [type] Issue: open|resolved
  - files: affected files

ENDSESSION
```

3. **Extract facts:**
```bash
node "scripts/counter.js" extract-facts TIMESTAMP
```

## Notes

- Uses same format as auto-save
- Does NOT reset counter (auto-save will still trigger normally)
- Use when you want to checkpoint progress mid-session
