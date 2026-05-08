---
name: search-memory
description: Search past sessions and facts
---

# Search Memory

Search through saved facts and session history.

## Usage

```
/memory-keeper:search-memory [query]
```

## Actions

### Search with query:
```bash
node "scripts/counter.js" search "query"
```

### Search with filters:
```bash
# By type
node "scripts/counter.js" search --type=architecture

# By concept
node "scripts/counter.js" search --concept=authentication

# By file
node "scripts/counter.js" search --file=src/auth

# Combined
node "scripts/counter.js" search "react" --type=technology --concept=frontend
```

### Show summary (no query):
```bash
node "scripts/counter.js" search
```

Output:
```
[MEMORY_KEEPER] Memory Summary:
  Decisions: 5
  Patterns: 3
  Issues: 2
  Sessions: 12
  Decision types: architecture(2), technology(3)
  Concepts: authentication, state-management, testing...
```

## Examples

```bash
# Find all architecture decisions
node scripts/counter.js search --type=architecture

# Find facts about authentication
node scripts/counter.js search --concept=authentication

# Find facts mentioning specific file
node scripts/counter.js search --file=counter.js

# Free text search
node scripts/counter.js search "hooks"
```

## Notes

- Searches decisions, patterns, and issues in facts.json
- Use `grep` for raw session file search:
  ```bash
  grep -r -i "keyword" .claude/memory/sessions/*.md
  ```
