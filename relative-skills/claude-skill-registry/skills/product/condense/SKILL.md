---
name: condense
description: Deduplicate and consolidate CLAUDE.md memory files. Trigger when user says "condense my CLAUDE.md files", "deduplicate CLAUDE.md", "clean up my memory files", or "consolidate my instructions". Removes redundancy within files and across the file hierarchy.
---

# CLAUDE.md Condensation

Deduplicate and consolidate CLAUDE.md memory files to remove redundancy.

## Workflow

### Phase 1: Discovery

**Find all CLAUDE.md files:**
```bash
python ../reflect/scripts/find_claude_md.py
```

**Read all discovered files and analyze for:**
1. Intra-file duplication (same instruction repeated within a file)
2. Cross-file duplication (same instruction in multiple files)
3. Misplaced instructions (subdirectory files containing project-wide content)

### Phase 2: Analysis

**Intra-file duplication:**
- Identify repeated bullet points or instructions
- Find semantically similar content (different wording, same meaning)

**Cross-file duplication:**
- Root CLAUDE.md should contain project-wide instructions
- Subdirectory CLAUDE.md should only contain directory-specific instructions
- If an instruction appears in both root and subdirectory, keep only in root
- If an instruction in subdirectory applies to whole project, move to root

**Misplaced instructions:**
- Subdirectory file contains instructions that apply project-wide → move to root
- Root file contains instructions only relevant to one directory → move to subdirectory

### Phase 3: Interaction

Present findings using AskUserQuestion with checkboxes.

**For each issue found:**
1. Show the duplicated or misplaced content
2. Identify which files are affected
3. Propose the consolidation (delete, move, or merge)

**Example:**
```
Issue: "Use 2-space indentation" appears in both ./CLAUDE.md and ./src/CLAUDE.md
Proposal: Remove from ./src/CLAUDE.md (already covered by root)
```

Wait for user approval before implementing.

### Phase 4: Implementation

For approved changes:

1. **Remove duplicates** - Delete redundant entries, keeping the most appropriate location
2. **Move misplaced content** - Transfer instructions to correct hierarchy level
3. **Merge similar items** - Combine semantically similar instructions into one

**Hierarchy rules:**
- `./CLAUDE.md` - Project-wide instructions (highest priority)
- `./.claude/rules/*.md` - Topic-specific rules (modular)
- `./subdir/CLAUDE.md` - Only instructions specific to that subdirectory
- `~/.claude/CLAUDE.md` - Personal preferences across all projects
- `./CLAUDE.local.md` - Personal project-specific (not shared)

## Resources

Uses shared resources from the reflect skill:
- `../reflect/scripts/find_claude_md.py` - Locate all CLAUDE.md files
- `../reflect/references/memory-locations.md` - Memory hierarchy details
- `../reflect/references/anti-patterns.md` - What to avoid when writing instructions
