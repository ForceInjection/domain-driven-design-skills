---
name: wikilink-apply
description: Apply wikilink suggestions to current or specified note. Triggers on "apply wikilinks", "add wikilinks", "wikilink this note".
auto_trigger: true
trigger_keywords:
  - "apply wikilinks"
  - "add wikilinks"
  - "wikilink this note"
  - "wikilink this file"
  - "apply wiki links"
  - "suggest wikilinks"
allowed-tools: Read, Edit, Glob
---

# Wikilink Application Skill

Scan a note for entities that should be wikilinked and automatically apply [[brackets]] to them.

## When to Use

Triggers when you say:
- "apply wikilinks" - Process current daily note
- "wikilink this note" - Process current context
- "apply wikilinks to [file]" - Process specific file

## Process

### 1. Identify Target File
- If argument provided: Use specified file path
- If no argument: Use today's daily note (from config `paths.daily_notes`)

### 2. Load Known Entities from Cache
Load wikilinks from the cache file for fast lookup:
- Read `.claude/wikilink-entities.json`
- Load all categories (technologies, people, projects, acronyms, etc.)
- Build comprehensive set of known entities
- **Fallback**: If cache doesn't exist, scan vault directly

### 3. Scan Target File for Unlinkable Text
Find plain text that matches known entities:

**Detection patterns:**
- Exact matches of existing wikilinks (case-insensitive)
- Capitalized multi-word phrases (2-4 words) that exist in entity list
- Known acronyms (2-6 uppercase letters) that exist in entity list

**Skip these areas:**
- Inside code blocks (```)
- Inside inline code (`text`)
- Already wikilinked text ([[already linked]])
- URLs (http://, https://)
- YAML frontmatter (between --- markers)

### 4. Categorize Detected Entities
Group by type for reporting:
- **People/Entities**: Mixed-case multi-word names
- **Technologies**: Tech-related terms
- **Projects**: Project names
- **Acronyms**: Uppercase abbreviations

### 5. Show Preview
Display what will be linked:
```
🔗 Applying Wikilinks to: 2025-12-29.md
────────────────────────────────────────
People/Entities (3):
  • Person Name → [[Person Name]]

Technologies (4):
  • Databricks → [[Databricks]]
  • Claude Code → [[Claude Code]]

Projects (2):
  • ProjectName → [[ProjectName]]
────────────────────────────────────────
Total: 9 entities will be wikilinked
```

### 6. Apply Wikilinks
Use Edit tool to wrap detected entities with `[[brackets]]`:
- Process entities from longest to shortest (avoid partial replacements)
- Use word boundaries to ensure exact matches
- Preserve original capitalization
- Don't re-link already wikilinked text

### 7. Report Results
Confirm what was changed:
```
✓ Successfully applied 9 wikilinks to 2025-12-29.md

Categories updated:
  • People/Entities: 3
  • Technologies: 4
  • Projects: 2
```

## Critical Rules

### Detection Rules
- **Case-insensitive matching**: "databricks" matches [[Databricks]]
- **Word boundaries only**: Don't link partial words
- **Existing links preserved**: Never re-link `[[already linked]]` text
- **Code blocks protected**: Never link inside ``` or ` marks

### Application Rules
- **Longest match first**: Apply longer entity names before shorter ones
- **One pass only**: Don't run multiple replacement passes
- **Preserve spacing**: Maintain original whitespace
- **Original caps**: Use exact match from entity list for wikilink

### Safety Rules
- **Read before edit**: Always read file first
- **Validate paths**: Ensure file exists before processing
- **Non-destructive**: Only adds [[brackets]], doesn't change text

## Example Transformation

### Before:
```markdown
## Log
- Met with team to discuss Databricks optimization
- Deployed project to production
- Fixed API configuration issue
```

### After:
```markdown
## Log
- Met with team to discuss [[Databricks]] optimization
- Deployed project to production
- Fixed [[API]] configuration issue
```

## Performance Considerations

- **Cache load**: Fast regex-based matching
- **Single edit**: One Edit operation per file
- **Idempotent**: Safe to run multiple times (won't double-link)
- **Cache refresh**: Run `/rebuild-wikilink-cache` if suggestions seem outdated

## Integration with Hook

Works seamlessly with `wikilink-auto.py` hook:
1. Hook auto-applies wikilinks (after Edit/Write)
2. If hook is disabled, user can run this skill manually
3. Skill applies detected wikilinks
4. Hook runs again (but finds no new entities since they're now linked)

## Edge Cases

**Ambiguous entities**: If "API" could mean multiple things, prefer exact match
**Partial matches**: "APIs" won't match [[API]] (word boundary protection)
**Already linked aliases**: Don't re-link `[[Entity|Alias]]` usage
**Case variations**: "databricks", "Databricks", "DATABRICKS" all link to [[Databricks]]

## Six Gates Compliance

| Gate | Implementation |
|------|----------------|
| 1. Read Before Write | Reads file before applying wikilinks (step 3) |
| 2. File Exists | Validates target file exists before processing |
| 3. Chain Validation | N/A (single operation) |
| 4. Mutation Confirmation | Shows preview of entities to be linked (step 5) |
| 5. Health Check | Uses cache or MCP for entity resolution |
| 6. Post Validation | Reports count of wikilinks applied (step 7) |
