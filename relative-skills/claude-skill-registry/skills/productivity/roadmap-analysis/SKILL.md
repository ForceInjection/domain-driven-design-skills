---
name: roadmap-analysis
description: ROADMAP.md analysis and management. Use for finding pending tasks and updating completion status.
---

# ROADMAP Analysis

## 1. ROADMAP.md Format

### Checkboxes
- `[ ]` - not done
- `[x]` - completed

### NO task numbers in ROADMAP!
- Only feature/idea names
- OpenSpec numbers go in openspec/changes/

## 2. Finding Pending Items

### Search pattern
```
[ ]
```

### Check current phase
- Phase 0, Phase 1, etc.
- Priority: top to bottom within section

## 3. Proposing Tasks

When user has no idea:

1. Read ROADMAP.md
2. Find current phase section
3. Select 3 uncompleted items `[ ]`
4. Present to user:
   ```
   Pending items from ROADMAP:
   1. [Item name] - brief description
   2. [Item name] - brief description
   3. [Item name] - brief description

   Which one would you like to work on?
   ```
5. Wait for user selection

## 4. Updating ROADMAP

### When feature is complete
```markdown
Before:
- [ ] Add statistics panel

After:
- [x] Add statistics panel
```

### Rules
- ONLY mark [x] when feature is fully done
- Do NOT add task numbers
- Do NOT add OpenSpec references
- Keep it simple: just checkboxes

## 5. ROADMAP Sections

### Typical structure
```markdown
# ROADMAP

## Phase 0 - Foundation
- [x] Project setup
- [x] Basic GUI
- [ ] Settings dialog

## Phase 1 - Core Editor
- [ ] Rich text editing
- [ ] Document structure
...
```

## 6. Cross-Reference with CHANGELOG

When updating ROADMAP:
1. Also add entry to CHANGELOG.md [Unreleased]
2. Use same feature name
3. Keep descriptions consistent
