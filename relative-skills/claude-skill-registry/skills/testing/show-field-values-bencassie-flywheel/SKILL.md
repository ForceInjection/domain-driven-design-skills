---
name: vault-field-values
description: Get all unique values for a specific frontmatter field. Triggers on "field values", "unique values for", "what X values exist", "list all X".
auto_trigger: true
trigger_keywords:
  - "field values"
  - "unique values for"
  - "what X values exist"
  - "list all"
  - "all values of"
  - "enumerate field"
  - "possible values"
  - "what types exist"
  - "what statuses exist"
  - "values of"
  - "what options"
  - "enumeration"
  - "list values"
  - "field options"
  - "value distribution"
  - "what can X be"
allowed-tools: mcp__flywheel__get_field_values
---

# Field Values Enumerator

Get all unique values for a specific frontmatter field across the vault.

## When to Use

Invoke when you want to:
- See all unique values a field has
- Discover field value patterns
- Plan value standardization
- Find value inconsistencies (typos, variants)

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `field` | Yes | The frontmatter field name (e.g., "type", "status", "project") |

## Process

### 1. Parse User Input

Identify the field being queried:
- "what values does 'type' have?"
- "list all status values"
- "what project values exist?"
- "enumerate the 'category' field"

### 2. Call MCP Tool

```
mcp__flywheel__get_field_values(
  field: "type"
)
```

### 3. Format Results

**Field with clear values:**
```
Field Values: type
=================================================

Found 8 unique values across 234 notes

Value Distribution:
-------------------------------------------------

  Value           Count    Percentage
  ──────────────────────────────────────────
  project         89       38%
  note            67       29%
  reference       34       15%
  person          23       10%
  meeting         12        5%
  template         5        2%
  index            3        1%
  undefined        1       <1%

-------------------------------------------------

Patterns Detected:
  - Most common: "project" (38%)
  - Possible typo: "undefined" (1 occurrence)
  - Good consistency: 8 distinct values

Suggestions:
  - Consider removing "undefined" value
  - Values look standardized ✓

=================================================
```

**Field with inconsistencies:**
```
Field Values: status
=================================================

Found 12 unique values across 156 notes

⚠️ Potential Inconsistencies Detected

Value Distribution:
-------------------------------------------------

  Value           Count    Issue
  ──────────────────────────────────────────
  active          67       -
  Active          12       Case mismatch with "active"
  done            45       -
  Done            8        Case mismatch with "done"
  completed       15       Synonym of "done"?
  in-progress     5        -
  in_progress     3        Variant of "in-progress"

-------------------------------------------------

Suggested Standardizations:
  1. "Active" → "active" (12 notes)
  2. "Done" → "done" (8 notes)
  3. "in_progress" → "in-progress" (3 notes)
  4. Consider: "completed" → "done" (15 notes)

=================================================
```

## Common Fields to Query

| Field | Purpose |
|-------|---------|
| `type` | Note classification |
| `status` | Lifecycle state |
| `project` | Project affiliation |
| `tags` | Note categorization |
| `author` | Creator attribution |
| `priority` | Importance ranking |
| `category` | Broad grouping |

## Use Cases

- **Value discovery**: "What project values do I have?"
- **Typo detection**: "Are there inconsistent status values?"
- **Standardization**: "What values should I consolidate?"
- **Reporting**: "How are my notes distributed by type?"

## Integration

Works well with other skills:
- **vault-schema**: Get overview of all fields first
- **vault-schema-check**: Find type inconsistencies
- **vault-search**: Query notes by specific field values

---

**Version:** 1.0.0
