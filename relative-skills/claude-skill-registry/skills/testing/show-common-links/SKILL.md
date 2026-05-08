---
name: vault-common
description: Find notes that two specified notes both link to (common neighbors). Triggers on "common references", "shared links", "what do X and Y both link to", "common neighbors".
auto_trigger: true
trigger_keywords:
  - "common references"
  - "shared links"
  - "what do X and Y both link to"
  - "common neighbors"
  - "shared references"
  - "both link to"
  - "mutual references"
  - "overlap between"
  - "common links"
  - "what do they share"
  - "in common"
  - "overlapping"
  - "shared context"
  - "both reference"
  - "intersection"
  - "common ground"
allowed-tools: mcp__flywheel__get_common_neighbors
---

# Common Neighbors Finder

Find notes that two specified notes both reference (shared context).

## When to Use

Invoke when you want to:
- Discover shared context between two notes
- Find overlapping references
- Identify common themes or topics
- Understand relationship through shared links

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `note_a` | Yes | First note (title or path) |
| `note_b` | Yes | Second note (title or path) |

## Process

### 1. Parse User Input

Identify the two notes:
- "common references between [[Project A]] and [[Project B]]"
- "what do [[React]] and [[Vue]] both link to"
- "shared links between daily note and weekly note"

### 2. Call MCP Tool

```
mcp__flywheel__get_common_neighbors(
  note_a: "path/to/first/note.md",
  note_b: "path/to/second/note.md"
)
```

### 3. Format Results

**Common Neighbors Found:**
```
Common Neighbors
=================================================

[[Project A]] and [[Project B]] share 8 references:

Technologies (3):
  - [[React]] - both use this framework
  - [[TypeScript]] - shared language
  - [[Docker]] - shared deployment

People (2):
  - [[Alice]] - contributes to both
  - [[Bob]] - reviews both

Concepts (3):
  - [[Authentication]] - both implement
  - [[REST API]] - shared pattern
  - [[Testing]] - both have test coverage

-------------------------------------------------

Insights:
  - High overlap (8 shared) suggests related projects
  - Both in the same technology stack
  - Consider linking them directly if not already

=================================================
```

**No Common Neighbors:**
```
Common Neighbors
=================================================

[[Note A]] and [[Note B]] share 0 references.

These notes link to completely different sets of notes.

Suggestions:
  - They may be in different knowledge domains
  - Check if they should share common references
  - Consider if intermediate connecting notes exist

=================================================
```

## Interpretation

| Shared Count | Interpretation |
|--------------|----------------|
| 10+ | Highly related (same domain/topic) |
| 5-9 | Moderately related |
| 2-4 | Some overlap |
| 1 | Minimal connection |
| 0 | Likely unrelated or different domains |

## Use Cases

- **Project comparison**: "What technologies do these projects share?"
- **Topic overlap**: "What concepts link these two areas together?"
- **Collaboration**: "What resources do these people both reference?"
- **Integration points**: "Where do these systems overlap?"

## Integration

Works well with other skills:
- **path**: Find how the two notes connect directly
- **strength**: Get quantitative relationship score
- **related**: Find other notes similar to either one
- **bidirectional**: Check if they link to each other

---

**Version:** 1.0.0
