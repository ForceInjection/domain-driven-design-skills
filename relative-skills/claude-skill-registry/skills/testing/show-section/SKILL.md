---
name: vault-section
description: Get the content under a specific heading in a note without reading the entire file. Triggers on "extract section", "get section", "content under heading", "section content".
auto_trigger: true
trigger_keywords:
  - "extract section"
  - "get section"
  - "content under heading"
  - "section content"
  - "heading content"
  - "show section"
  - "read section"
  - "get the X section"
  - "content under"
  - "text in section"
  - "what's under heading"
  - "pull section"
  - "section text"
  - "under the heading"
allowed-tools: mcp__flywheel__get_section_content
---

# Section Content Extractor

Extract content from a specific heading without reading the entire note.

## When to Use

Invoke when you want to:
- Get just one section from a large note
- Extract references, notes, or specific headings
- Avoid reading entire files when you know what section you need
- Surgically retrieve content for processing

## Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `path` | Yes | - | Path to the note |
| `heading` | Yes | - | Heading text to find (e.g., "References") |
| `include_subheadings` | No | true | Include content under sub-headings |

## Process

### 1. Parse User Input

Identify the note and heading:
- "get the References section from [[Project Alpha]]"
- "extract the ## Notes heading from daily note"
- "show me the 'Implementation' section of architecture.md"

### 2. Call MCP Tool

```
mcp__flywheel__get_section_content(
  path: "projects/Project Alpha.md",
  heading: "References",
  include_subheadings: true
)
```

### 3. Format Results

**Section Found:**
```
Section Content
=================================================

Note: [[Project Alpha]]
Heading: ## References

-------------------------------------------------

Content (including subheadings):

### Internal Links
- [[Architecture Overview]]
- [[API Documentation]]
- [[Testing Strategy]]

### External Resources
- [React Docs](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

### Papers
- Smith et al. 2024, "Modern Architecture Patterns"

-------------------------------------------------

Stats:
  Lines: 12
  Links: 5 (3 internal, 2 external)
  Characters: 342

=================================================
```

**Heading Not Found:**
```
Section Content
=================================================

Note: [[Project Alpha]]
Heading: "Appendix"

⚠️ Heading not found in note

Available headings:
  - ## Overview
  - ## Features
  - ## References
  - ## Status

Did you mean: "References"?

=================================================
```

## Why Use This Over Read?

| Approach | Token Cost | Use Case |
|----------|------------|----------|
| `Read(full_file)` | High | Need entire note content |
| `get_section_content` | Low | Need specific section only |

**Example savings:**
- Full note: 5,000 tokens
- Just "References" section: 200 tokens
- Savings: 96%

## Use Cases

- **Reference extraction**: "Get the references from this paper note"
- **Rollup processing**: "Extract the achievements section from daily notes"
- **Template sections**: "Get the template structure from this note"
- **Targeted editing**: "Show me just the TODO section"

## Integration

Works well with other skills:
- **vault-find-sections**: Find all notes with a specific heading first
- **vault-backlinks**: Understand what links to this note
- **vault-search**: Find notes to extract sections from

---

**Version:** 1.0.0
