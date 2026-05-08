---
name: Daily Workflow Automation
description: Automatically processes daily notes when user mentions diary entries, daily summaries, or end-of-day workflows. Extracts insights, contexts, and categorizes content from "### 🧠 Notes" sections. Use when user discusses daily notes, asks "what did I work on today", mentions end-of-day, or talks about extracting diary content.
---

# Daily Workflow Automation

Auto-process daily notes: extract entries → classify → route to appropriate files → update trackers.

## When This Runs

Auto-triggers when user:
- Mentions "today's diary", "daily note", "extract content"
- Asks "what did I work on today?"
- Natural end-of-day: "done for today", "wrapping up", "extract today"
- References "### 🧠 Notes" section

## Quick Workflow

1. Scan daily notes in `00 - Daily/` for unprocessed files
2. Extract entries from `### 🧠 Notes` sections
3. Classify each entry (Diary/Insight/Context/Idea) with AI
4. Analyze relevance to 24 context areas (business, tech, health, etc.)
5. Route to primary + secondary destinations (>80% confidence)
6. Transform diary narratives → factual knowledge (for context files)
7. Present routing plan with reasoning
8. Get user approval (y/n/edit)
9. Execute routing with cross-links
10. Update tracker (`.extract-daily-content-tracker.json`)
11. **Smart memory detection**: Suggest Serena/Graphiti updates

## Entry Classification

### Diary Entries
- **Primary**: `04-resources/diary.md` (always)
- **Secondary**: `[area]/diary-[area].md` (if >80% confidence)
- **Format**: Preserve original narrative with date headers

### Insights
- **Primary**: `01-areas/p-dev/insights.md` (always)
- **Secondary**: Never to context files (insights ≠ context)

### Context Entries
- **Primary**: `04-resources/context.md` (always)
- **Secondary**: Matching `CLAUDE.md` files (if >80% confidence)
- **Format**: Factual bullet points (no dates, no narrative)

### Ideas
- **Primary**: `04-resources/ideas.md` (always)
- **Secondary**: Never to context files

## Context Areas (24 files)

**Business** (8):
- `business/mokai/CLAUDE.md`
- `business/mokhouse/CLAUDE.md`
- `business/accounting/CLAUDE.md`
- `business/crypto/CLAUDE.md`
- `business/soletrader/CLAUDE.md`
- `business/SMSF/CLAUDE.md`
- `business/safia/CLAUDE.md`
- `business/trust/CLAUDE.md`

**Personal Development** (3):
- `p-dev/learning/CLAUDE.md`
- `p-dev/mindset/CLAUDE.md`
- `p-dev/psychedelics/CLAUDE.md`

**Health & Fitness** (4):
- `health-fitness/CLAUDE.md`
- `health-fitness/diet/CLAUDE.md`
- `health-fitness/medical/CLAUDE.md`
- `health-fitness/gym/CLAUDE.md`

**Tech** (5):
- `tech/CLAUDE.md`
- `tech/ableton/CLAUDE.md`
- `tech/mac/CLAUDE.md`
- `tech/ai/CLAUDE.md`
- `tech/ai/research-ai/context-engineering/CLAUDE.md`

**Other** (3):
- `claude-code/CLAUDE.md`
- `harry/CLAUDE.md`
- `people/CLAUDE.md`

## Diary → Context Transformation

**Original diary entry**:
```
"Today I built a Supabase database for financial tracking for MOKAI. Took forever to set up auth but got it working. Will use for invoice management."
```

**Context file format** (`tech/CLAUDE.md`):
```markdown
- Supabase: Financial tracking database with auth
  *From:* [[04-resources/diary#25-10-19 - Sun]]
  *Related:* [[business/mokai/context-mokai]]
```

**Context file format** (`business/mokai/CLAUDE.md`):
```markdown
- Financial tracking system: Supabase database for invoice management
  *From:* [[04-resources/diary#25-10-19 - Sun]]
  *Related:* [[tech/context-tech]]
```

**Transformations applied**:
- ✅ Extract topically relevant facts
- ✅ Rephrase to third-person
- ✅ Remove: dates, pronouns, temporal markers, feelings
- ✅ Format: Bullet points with cross-links
- ✅ Custom formulation for each context area

## Smart Memory Detection

After extraction, detect opportunities to update memory systems:

### Serena Memory Detection
**Triggers**: Technical patterns, workflows, commands, automation
**Keywords**: `workflow`, `pattern`, `convention`, `script`, `command`, `automation`, `process`

**Example**:
```
Entry: "Created new workflow using Supabase triggers for invoice automation"

Detection:
  System: Serena
  Memory: system_patterns_and_guidelines
  Confidence: 0.87
  Update: "Invoice automation: Supabase triggers reduce manual data entry"
```

### Graphiti Detection (3 instances)
**Triggers**: Strategic decisions, business events, personal insights
**Keywords**: `decided`, `strategy`, `planning`, `client`, `meeting`, `learned`, `insight`, `discovered`

**Routing**:
- `business/mokai/*` or `business/mokhouse/*` → **graphiti-mokai**
- `business/accounting/*`, `crypto/*`, `SMSF/*` → **graphiti-finance**
- Everything else → **graphiti-personal**

**Example**:
```
Entry: "Discussed the future direction of MOKAI with Jack and Brie over dinner"

Detection:
  System: Graphiti
  Instance: graphiti-mokai
  Confidence: 0.85
  Episode: "MOKAI strategic planning session with Jack and Brie discussing future business direction and growth opportunities"
```

## File References

- Daily note template: [reference/templates.md](reference/templates.md)
- Formatting rules: [reference/formatting-rules.md](reference/formatting-rules.md)
- Extraction script: `scripts/extract_content.py <date>`

## MCP Integration

**Serena MCP** (preferred for file operations):
- `mcp__serena__list_dir` - Find daily notes
- `mcp__serena__search_for_pattern` - Extract ### 🧠 Notes sections
- `mcp__serena__find_file` - Locate context files
- `mcp__serena__write_memory` - Update Serena memories

**Graphiti MCP** (knowledge graph storage):
- `mcp__graphiti__add_memory` - Store strategic insights

**Use Serena for pattern matching** (faster than Read tool)

## Tracker System

**Location**: `.claude/commands/.extract-daily-content-tracker.json`

**Tracks**:
- Last scan timestamp
- Processed files (with modification times)
- Entries processed per file
- Routing decisions with confidence scores

**View tracker**:
```bash
cat .claude/commands/.extract-daily-content-tracker.json | jq '.processed_files | to_entries | last'
```

**Reset tracker** (force re-extraction):
```bash
rm .claude/commands/.extract-daily-content-tracker.json
```

## Critical Rules

- ✅ **Always preserve frontmatter** (date, event) in daily notes
- ✅ **Use Serena MCP** for pattern matching (faster than Read)
- ✅ **Deduplicate insights** before storing in Graphiti
- ✅ **Never delete original content** during extraction
- ✅ **Transform diary → factual** for context files
- ✅ **Preserve narrative** for diary files
- ✅ **Require >80% confidence** for secondary routing
- ✅ **Create cross-links** bidirectionally
- ✅ **Auto-create diary files** with proper frontmatter
- ✅ **Get user approval** before memory updates

## User Approval Flow

After extraction, user chooses:

**[a] Update all** - Update all suggested memories (confidence >0.80)

**[s] Selective** - Choose which memories to update:
```
Which memories to update? (comma-separated)

1. Serena (system_patterns_and_guidelines) - Confidence: 0.87
2. Graphiti-MOKAI (strategic planning) - Confidence: 0.85
3. Graphiti-Personal (health insight) - Confidence: 0.78

Your choice: 2
```

**[n] Skip** - No memory updates

**[l] Later** - Queue for end-of-day batch review

## Example Workflow

**User**: "What did I work on today?"

**Claude**:
1. Scans `00 - Daily/` for today's note
2. Extracts entries from `### 🧠 Notes`
3. Classifies each entry
4. Presents routing plan:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Extraction Plan for [[25-10-21 - Mon]]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Entry 1: "MOKAI uses Indigenous procurement..."
  Type: Context (96% confidence)
    Reason: Factual business practice information

  Primary: 04-resources/context.md
  Secondary:
    ✓ business/mokai/CLAUDE.md (98%)
      → Direct MOKAI business strategy reference
    ✓ harry/CLAUDE.md (87%)
      → Personal Indigenous identity context

Entry 2: "Finished mixing Nintendo track..."
  Type: Diary (94% confidence)
    Reason: Daily activity log, project completion

  Primary: 04-resources/diary.md
  Secondary:
    ✓ business/mokhouse/diary-mokhouse.md (97%)
      → MOK HOUSE client project completion

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Actions: [y]es / [n]o / [e]dit / [s]kip entry
```

5. User approves: `y`
6. Executes routing with cross-links
7. Updates tracker
8. Detects memory opportunities:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 Memory System Detection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Graphiti (MOKAI):
  Episode: "MOKAI Indigenous procurement strategy"
  Confidence: 0.96
  Reason: Strategic business positioning

Would you like to update memory systems?
  [a] Update all suggested memories
  [s] Selective (choose which to update)
  [n] Skip memory updates
  [l] Later (remind me at EOD)
```

## Troubleshooting

**Issue**: AI misclassifies entries
- **Solution**: Use edit mode to correct, AI learns from patterns

**Issue**: Too many secondary destinations
- **Solution**: Increase confidence threshold (currently 0.8)

**Issue**: Diary files not created
- **Solution**: Verify auto-creation logic, check file permissions

**Issue**: Missing cross-links
- **Solution**: Verify append operations, check for write errors

**Issue**: Memory detection missing opportunities
- **Solution**: Review detection keywords, adjust confidence threshold

**Issue**: Wrong Graphiti instance selected
- **Solution**: Manually specify instance in selective mode

## Related Commands

- Fallback: `/extract-daily-content` (manual trigger)
- Memory: `/update-serena-memory`
- Documentation: `/report:document-system`

## Success Criteria

- ✅ Correctly classify entry types (>90% accuracy)
- ✅ Route to appropriate areas with good confidence
- ✅ Show clear reasoning for routing decisions
- ✅ Allow easy manual override
- ✅ Create valid cross-links bidirectionally
- ✅ Auto-create diary files with proper frontmatter
- ✅ Track all routing decisions
- ✅ Handle incremental runs efficiently
- ✅ Maintain file integrity across all destinations
- ✅ Respect >80% confidence threshold for secondary routing
