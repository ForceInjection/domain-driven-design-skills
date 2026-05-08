---
name: "save-pattern"
description: "Store APPLICATION patterns (architecture, procedures, conventions) in AgentDB's skills table. NOT for swarm/transient memory."
---

# Save Pattern - Store Application Knowledge

## What This Skill Does

Stores **application patterns** to AgentDB's **skills table** with semantic embeddings. Patterns are searchable via `get-pattern` using `skill search`.

**Use this AFTER completing work** to share reusable knowledge with future agents.

---

## Quick Reference

```bash
# Store a new pattern
npx agentdb skill create "pattern-name" "description of the pattern" "optional details or code"

# Check existing patterns
npx agentdb db stats

# Search before creating (avoid duplicates)
npx agentdb skill search "pattern name" 3
```

---

## Primary Method: Skill Create

```bash
npx agentdb skill create "<name>" "<description>" "[code/details]"
```

### Parameters (positional)

| Position | Parameter | Description | Required |
|----------|-----------|-------------|----------|
| 1 | name | Pattern identifier (kebab-case) | Yes |
| 2 | description | Full pattern content | Yes |
| 3 | code | Optional implementation details | No |

---

## Examples

### Store Architecture Pattern

```bash
npx agentdb skill create \
  "domain-adapter-source" \
  "Domain Adapter Pattern for Data Sources: All data sources implement the Source trait for uniform handling. Steps: 1) Create struct implementing Source trait, 2) Implement fetch() -> Vec<TimeSeriesPoint>, 3) Implement health_check() -> HealthStatus. Related files: core/src/traits.rs, core/src/sources/http_poll.rs" \
  "tags: hexagonal, traits, source, architecture"
```

### Store Development Procedure

```bash
npx agentdb skill create \
  "add-data-stream" \
  "Add New Data Stream: Prerequisites - Stream config YAML ready, etcd running. Steps: 1) Create config/base/streams/{stream-id}/config.yaml, 2) Define fields array with name, source_path, unit, 3) Run ./deploy.sh sync, 4) Verify: etcdctl get /streams/{id}/config" \
  "tags: streams, config, etcd, development"
```

### Store Troubleshooting Pattern

```bash
npx agentdb skill create \
  "mqtt-data-not-appearing" \
  "MQTT Data Not Appearing - Symptoms: Sensor data not in Parquet files, no errors in logs. Root Causes: 1) Topic mismatch, 2) Missing stream_id in routing. Solution: 1) Check mosquitto_sub -t # for actual topics, 2) Verify config.yaml source.topics matches, 3) Ensure IngestionRouter tags stream_id" \
  "tags: mqtt, debugging, parquet, troubleshooting"
```

### Store Product Vision

```bash
npx agentdb skill create \
  "ndp-product-vision" \
  "The Neural Data Platform is a generic, extensible data ingestion and analytics system built in Rust. Uses Domain Adapter Pattern (hexagonal architecture) for pluggable sources/stores, configuration-driven stream management, Bronze->Silver->Gold data lake model." \
  "tags: vision, product, architecture"
```

---

## Pattern Categories

Use consistent naming prefixes:

| Category | Prefix | Examples |
|----------|--------|----------|
| Architecture | `arch-` | `arch-domain-adapter`, `arch-data-layers` |
| Development | `dev-` | `dev-add-stream`, `dev-implement-source` |
| Deployment | `deploy-` | `deploy-docker`, `deploy-raspberry-pi` |
| Troubleshooting | `debug-` | `debug-mqtt-issues`, `debug-parquet-errors` |
| Conventions | `conv-` | `conv-naming`, `conv-code-style` |

---

## Best Practices

### 1. Check First

Always search before creating to avoid duplicates:

```bash
npx agentdb skill search "pattern topic" 5
```

### 2. Be Specific

Include concrete details:
- **Good**: "Create config/base/streams/{id}/config.yaml with fields array containing name, source_path, unit"
- **Bad**: "Create a config file"

### 3. Include Tags

Add tags in the code/details field for better searchability:
```bash
"tags: category, topic1, topic2"
```

### 4. Reference Files

Mention actual code paths:
```
"Related files: core/src/traits.rs, docs/procedures/HOW_TO_ADD_STREAM.md"
```

### 5. Include Verification

How to confirm the pattern worked:
```
"Verify: Run cargo test, check logs for 'Source initialized'"
```

---

## Update vs. Create New

AgentDB tracks skill usage and success rates. To update a pattern:

1. **Search for existing**: `npx agentdb skill search "pattern-name" 3`
2. **If found with low success rate**: Create improved version with `-v2` suffix
3. **If found with high success rate**: Only create new if fundamentally different

```bash
# Original
npx agentdb skill create "add-stream" "Original approach..."

# Updated version (when original is insufficient)
npx agentdb skill create "add-stream-v2" "Updated approach with retention field requirement..."
```

---

## The Pattern Workflow

```
1. BEFORE work:  get-pattern  → Search for existing patterns
2. DURING work:  Note gaps, discover new approaches
3. AFTER work:   save-pattern → Store NEW discoveries (THIS SKILL)
                 reflexion    → Record if existing patterns helped
                 learner      → Auto-discover patterns from episodes
```

---

## Related Skills

- **`get-pattern`** - Search patterns BEFORE work (always check first)
- **`reflexion`** - Record feedback on pattern effectiveness
- **`learner`** - Auto-discover patterns from successful episodes

---

## What NOT to Use This For

| Don't Store | Use Instead |
|-------------|-------------|
| Swarm coordination state | claude-flow memory tools |
| Agent task status | claude-flow task tools |
| Temporary working memory | claude-flow memory with TTL |
| Session-specific context | claude-flow memory tools |
| Feedback on patterns | `reflexion` skill |

**Patterns are PERMANENT application knowledge, not transient swarm state.**
