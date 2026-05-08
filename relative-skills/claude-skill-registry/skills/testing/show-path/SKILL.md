---
name: vault-path
description: Find the shortest path of links between two notes. Triggers on "path between", "how do X and Y connect", "connection chain", "link path".
auto_trigger: true
trigger_keywords:
  - "path between"
  - "how do X and Y connect"
  - "connection chain"
  - "link path"
  - "shortest path"
  - "how are X and Y connected"
  - "trace path"
  - "find path"
  - "path from X to Y"
  - "what links"
  - "connection from"
  - "how do I get from"
  - "graph path"
  - "find route"
  - "what's between"
  - "trace link"
  - "show connection between"
allowed-tools: mcp__flywheel__get_link_path
---

# Link Path Finder

Find the shortest connection path between any two notes in your vault.

## When to Use

Invoke when you want to:
- Discover how two seemingly unrelated notes connect
- Trace the knowledge path between concepts
- Understand relationship chains (A -> B -> C)
- Verify indirect connections in your knowledge graph

## Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `from_note` | Yes | - | Starting note (title or path) |
| `to_note` | Yes | - | Destination note (title or path) |
| `max_depth` | No | 10 | Maximum path length to search |

## Process

### 1. Parse User Input

Identify the two notes from user request:
- "path between [[Project A]] and [[Technology X]]"
- "how does my daily note connect to [[MCP]]"
- "path from work/projects/Alpha.md to tech/frameworks/React.md"

### 2. Call MCP Tool

```
mcp__flywheel__get_link_path(
  from: "path/to/first/note.md",
  to: "path/to/second/note.md",
  max_depth: 10
)
```

### 3. Format Results

**Path Found:**
```
Link Path: [[Note A]] to [[Note Z]]
=================================================

Path Found (4 hops):

  [[Note A]]
       |
       v  (links via "See also")
  [[Note B]]
       |
       v  (links via "References")
  [[Note C]]
       |
       v  (links via "Technology used")
  [[Note Z]]

-------------------------------------------------

Summary:
  - Path length: 4 hops
  - Intermediate notes: 2
  - Connection strength: Moderate (4+ hops = indirect)

Insights:
  - These notes connect through [[Note B]] and [[Note C]]
  - Consider adding a direct link if frequently related

=================================================
```

**No Path Found:**
```
Link Path: [[Note A]] to [[Note Z]]
=================================================

No path found within 10 hops.

These notes are not connected in your knowledge graph.

Suggestions:
  - They may be in different knowledge domains
  - Consider if they should be connected
  - Check if intermediate notes are missing

=================================================
```

## Path Interpretation

| Path Length | Interpretation |
|-------------|----------------|
| 1 hop | Direct link (strong connection) |
| 2 hops | One intermediary (moderate connection) |
| 3-4 hops | Indirect connection |
| 5+ hops | Weak/distant connection |
| No path | Disconnected (different knowledge islands) |

## Use Cases

- **Knowledge archaeology**: "How did I connect machine learning to cooking?"
- **Project tracing**: "How does this bug report relate to the architecture doc?"
- **Learning paths**: "What's the path from basics to advanced concepts?"
- **Graph debugging**: "Why can't I find the connection I expected?"

## Integration

Works well with other skills:
- **backlinks**: See all connections for either endpoint
- **common**: Find notes that both endpoints reference
- **strength**: Get a quantitative relationship score
- **clusters**: Identify which clusters each note belongs to

---

**Version:** 1.0.0
