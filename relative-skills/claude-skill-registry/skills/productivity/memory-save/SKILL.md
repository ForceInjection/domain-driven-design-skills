---
name: memory-save
description: Execute when you see "[MEMORY_KEEPER]" in hook output. Follow the numbered steps exactly to save session memory.
---

# Memory Save Skill (v7.0.0)

This skill activates when `[MEMORY_KEEPER]` appears in conversation.

## Memory Structure

```
.claude/memory/
  project.md        <- Project overview (stable)
  architecture.md   <- Architecture decisions (stable)
  conventions.md    <- Coding conventions (stable)
  memory.md         <- Rolling session log (last 50 lines loaded)
  facts.json        <- Structured facts with concepts index
  sessions/         <- Individual session files
```

## Trigger Message

```
═══════════════════════════════════════════════════════════════
[MEMORY_KEEPER] AUTO-SAVE TRIGGERED - N tool uses reached
═══════════════════════════════════════════════════════════════
```

## Required Actions

### Step 1: Save to memory.md
```bash
echo -e "\n## 2025-12-21_0300\n[1-2 sentence summary]" >> ".claude/memory/memory.md"
```

### Step 2: Save session file (EXACT FORMAT)
```bash
cat > ".claude/memory/sessions/2025-12-21_0300.md" << 'ENDSESSION'
# Session 2025-12-21_0300

## Summary
[What was accomplished in 2-3 sentences]

## Decisions
- [architecture|technology|approach] Decision content: Reason why
  - files: path/to/file1.ts, path/to/file2.ts
  - concepts: authentication, state-management

## Patterns
- [convention|best-practice] Pattern description
  - concepts: testing, workflow

## Issues
- [bugfix|performance|security] Issue description: open|resolved
  - files: path/to/fixed-file.ts
  - concepts: performance

ENDSESSION
```

**Privacy:** Use `<private>API key here</private>` to exclude sensitive data.
**Files/Concepts:** Optional sub-items for better organization and search.

### Step 3: Extract facts
```bash
node "scripts/counter.js" extract-facts 2025-12-21_0300
```

## Session End (Stop Hook)

Additional step:
```bash
node "scripts/counter.js" compress
```

## Optional: Update Hierarchical Memory

If major project understanding changed, update stable memory files:
```bash
node "scripts/counter.js" memory-set project "Updated project description..."
node "scripts/counter.js" memory-set architecture "Updated architecture..."
node "scripts/counter.js" memory-set conventions "Updated conventions..."
```

**When to update:**
- `project.md`: New project scope, goals, or tech stack
- `architecture.md`: New architecture decisions or patterns
- `conventions.md`: New coding standards or workflows

**View current memory:**
```bash
node "scripts/counter.js" memory-list
node "scripts/counter.js" memory-get project
```

## Format Rules

- `## Decisions` - Each line: `- [type] Content: Reason`
  - Types: architecture, technology, approach, other
  - Optional: `  - files: path1, path2` and `  - concepts: tag1, tag2`
- `## Patterns` - Each line: `- [type] Pattern description`
  - Types: convention, best-practice, anti-pattern, other
- `## Issues` - Each line: `- [type] Issue: open|resolved`
  - Types: bugfix, performance, security, feature, other
- **Privacy**: `<private>...</private>` content excluded from facts.json
- **Search**: `node counter.js search --concept=X --file=Y --type=Z`

## Critical

- **DO NOT SKIP** any steps
- **USE EXACT FORMAT** for session file (extract-facts parses it)
- Counter resets automatically (no manual reset needed)

## How Extraction Works

```
session.md                              facts.json
──────────────────                     ────────────
## Decisions                           "decisions": [
- [architecture] Use CLI: Reliable     {
  - files: src/cli.ts               ───>  "type":"architecture",
  - concepts: cli, reliability            "content":"Use CLI",
                                          "files":["src/cli.ts"],
                                          "concepts":["cli","reliability"]
                                        }]

Privacy: <private>sk-xxx</private> ───> [PRIVATE]
Concepts index auto-updated: {"cli":["d001"], "reliability":["d001"]}
```

See [Architecture](../../docs/ARCHITECTURE.md) for full details.
