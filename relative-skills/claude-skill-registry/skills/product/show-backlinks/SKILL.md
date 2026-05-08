---
name: vault-backlinks
description: Show all backlinks and forward links for a note. Triggers when user mentions "backlinks", "who links here", "links to", "connections".
auto_trigger: true
trigger_keywords:
  - "backlinks"
  - "who links here"
  - "what links to"
  - "links to"
  - "show connections"
  - "note connections"
  - "linked from"
  - "links from"
  - "show links"
  - "what points to"
  - "references this"
  - "mentions of"
  - "incoming links"
  - "who cites"
  - "referencing"
allowed-tools: mcp__flywheel__get_backlinks, mcp__flywheel__get_forward_links, Read
---

# Backlinks Navigator

Show bidirectional link connections for any note.

## When to Use

Invoke when you want to:
- See what notes link TO a note (backlinks)
- See what notes this note links TO (forward links)
- Understand note's position in knowledge graph
- Find bidirectional vs one-way relationships

## Process

### 1. Detect Target Note
Options for specifying the note:
- **Current note**: "backlinks" (auto-detect from context)
- **Specific note**: "backlinks for MyProject"
- **File path**: "backlinks for work/projects/MyProject.md"

### 2. Get Backlinks
Call `mcp__flywheel__get_backlinks(note_path)` to retrieve:
- All notes that link TO this note
- Line numbers where links appear
- Context around each link

### 3. Get Forward Links
Call `mcp__flywheel__get_forward_links(note_path)` to retrieve:
- All notes this note links TO
- Whether targets exist
- Resolved file paths

### 4. Analyze Relationships
Identify connection patterns:
- **Bidirectional**: A links to B AND B links to A (strong connection)
- **One-way incoming**: Others link here but we don't link back
- **One-way outgoing**: We link there but they don't link back
- **Broken**: We link but target doesn't exist

### 5. Format Report
Display comprehensive connection view:

```
Connections for [[MyProject]]
═══════════════════════════════════════════════

📊 Overview:
  • Backlinks: 50 notes link here
  • Forward Links: 20 notes linked from here
  • Bidirectional: 15 mutual connections
  • One-way: 35 incoming, 5 outgoing

⬅️ BACKLINKS (Top 20 of 50):

Bidirectional (mutual links):
  1. [[Related Project]] (line 23, 67)
     ↔ Strong connection (15 mutual refs)

  2. [[Technology Used]] (line 12, 45)
     ↔ Mutual (10 refs each way)

One-way incoming (they link here, we don't link back):
  3. [[Planning Doc]] (line 5)
     → Suggestion: Link back if relevant

➡️ FORWARD LINKS (All 20):

Bidirectional (mutual):
  1. [[Related Project]] ✅ exists
  2. [[Technology Used]] ✅ exists

Broken (target doesn't exist):
  3. [[Old Feature]] ❌ broken
     → Run /vault-fix-links to repair

═══════════════════════════════════════════════

💡 Insights:
  • Highly connected hub (50 backlinks)
  • Consider linking back to: Planning Doc
  • Fix 1 broken outgoing link
```

## Bidirectional Analysis

Identify relationship strength:

```
Bidirectional Strength Score:
- Count mutual references
- Calculate ratio of back-to-forward links
- Higher score = stronger connection

Strong bidirectional: >80% ratio
Moderate: 40-80% ratio
Weak: 20-40% ratio
Asymmetric: <20% ratio
```

## Output Format

Always use the branded format:

```
Connections for [[Note]]
═══════════════════════════════════════════════

[Connection details]

═══════════════════════════════════════════════
```

## Performance

- **Backlinks query**: 1-2 seconds
- **Forward links query**: 1-2 seconds
- **Total**: ~3-5 seconds for both queries
- **Scalability**: Works fast even for high-hub notes

## Integration

Works well with other skills:
- **fix-links**: Repair broken forward links detected
- **bidirectional**: Deeper analysis of one-way relationships
- **orphans**: Find notes with 0 backlinks
- **hubs**: Find notes with many backlinks
- **suggest**: Add more forward links to isolated notes
