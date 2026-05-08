---
name: "learner"
description: "Auto-discover patterns from reflexion episodes. Run post-feature to consolidate successful approaches into reusable patterns and skills."
---

# Learner - Auto-Discover Patterns

## What This Skill Does

Analyzes reflexion episodes to automatically discover:
1. **Causal patterns** - What actions lead to successful outcomes
2. **Skills** - Reusable procedures from successful episodes
3. **Patterns needing review** - Low-performing or conflicting patterns

**Run this AFTER completing a feature** to consolidate learnings.

---

## Quick Reference

```bash
# Discover causal patterns from episodes
npx agentdb learner run 3 0.6 0.7

# Consolidate skills from successful episodes
npx agentdb skill consolidate 3 0.7 7 true

# Prune old/low-quality data
npx agentdb reflexion prune 90 0.5

# View database statistics
npx agentdb db stats
```

---

## Primary Method: Discover Patterns

Auto-discover causal patterns from reflexion episodes:

```bash
npx agentdb learner run 3 0.6 0.7
```

### Parameters (positional)

| Position | Parameter | Default | Description |
|----------|-----------|---------|-------------|
| 1 | min-attempts | 3 | Minimum times pattern was tried |
| 2 | min-success-rate | 0.6 | Minimum success rate |
| 3 | min-confidence | 0.7 | Statistical confidence threshold |

### Examples

**Standard discovery:**
```bash
npx agentdb learner run 3 0.6 0.7
```

**Aggressive (more patterns, lower thresholds):**
```bash
npx agentdb learner run 2 0.5 0.6
```

**Conservative (fewer, higher-confidence patterns):**
```bash
npx agentdb learner run 5 0.8 0.9
```

**Dry run (preview without storing):**
```bash
npx agentdb learner run 3 0.6 0.7 true
```

---

## Consolidate Skills

Automatically creates reusable skills from successful episodes:

```bash
npx agentdb skill consolidate 3 0.7 7 true
```

### Parameters (positional)

| Position | Parameter | Default | Description |
|----------|-----------|---------|-------------|
| 1 | min-attempts | 3 | Pattern must appear 3+ times |
| 2 | min-reward | 0.7 | Only high-success episodes |
| 3 | time-window-days | 7 | Look back window |
| 4 | extract-patterns | true | Use ML pattern extraction |

### Examples

**Standard consolidation:**
```bash
npx agentdb skill consolidate 3 0.7 7 true
```

**Higher thresholds, longer window:**
```bash
npx agentdb skill consolidate 5 0.8 14 true
```

---

## Query Discovered Patterns

### View Causal Edges

```bash
npx agentdb causal query
```

With filters:
```bash
# Filter by cause
npx agentdb causal query "Source trait" "" 0.7 0.1 20

# Filter by minimum confidence and uplift
npx agentdb causal query "" "" 0.8 0.2 10
```

### Search Skills

```bash
npx agentdb skill search "data ingestion" 5
```

---

## Prune Low-Quality Data

### Prune Old Episodes

```bash
# Remove episodes older than 90 days with reward < 0.5
npx agentdb reflexion prune 90 0.5
```

### Prune Low-Confidence Causal Edges

```bash
# Remove edges with confidence < 0.5, uplift < 0.05, older than 90 days
npx agentdb learner prune 0.5 0.05 90
```

### Prune Underperforming Skills

```bash
# Remove skills with < 3 uses, < 40% success rate, older than 60 days
npx agentdb skill prune 3 0.4 60
```

---

## Memory Optimization

Consolidate and compress pattern memory:

```bash
npx agentdb optimize-memory --compress true --consolidate-patterns true
```

---

## Post-Feature Workflow

Run after completing a feature:

```bash
# 1. Discover causal patterns
npx agentdb learner run 3 0.7 0.8

# 2. Consolidate skills
npx agentdb skill consolidate 3 0.7 7 true

# 3. View what was learned
npx agentdb db stats

# 4. (Optional) Search discovered skills
npx agentdb skill search "feature-topic" 5
```

---

## Understanding Results

### Causal Edges

Learner creates cause-effect relationships:

```
Cause: "Using Source trait with health_check"
Effect: "Reliable data ingestion with automatic recovery"
Uplift: 0.35 (35% improvement)
Confidence: 0.92
```

### Skills

Consolidated from successful episodes:

```
Name: "http-source-implementation"
Description: "Implement HTTP polling source with retry"
Success Rate: 0.89
Uses: 7
```

---

## Thresholds Guide

### For min-attempts

| Value | Use Case |
|-------|----------|
| 2 | Aggressive learning, small dataset |
| 3 | Standard (recommended) |
| 5 | Conservative, high confidence needed |

### For min-success-rate

| Value | Use Case |
|-------|----------|
| 0.5 | Include partial successes |
| 0.7 | Standard (recommended) |
| 0.9 | Only proven patterns |

### For min-confidence

| Value | Use Case |
|-------|----------|
| 0.6 | Exploratory, more patterns |
| 0.8 | Standard (recommended) |
| 0.95 | Production-critical |

---

## Maintenance Schedule

| Frequency | Action | Command |
|-----------|--------|---------|
| **Post-feature** | Discover patterns | `npx agentdb learner run` |
| **Weekly** | Consolidate skills | `npx agentdb skill consolidate` |
| **Monthly** | Review stats | `npx agentdb db stats` |
| **Quarterly** | Prune stale data | `npx agentdb reflexion prune` |

---

## Advanced: Causal Experiments

For A/B testing approaches:

```bash
# Create experiment
npx agentdb causal experiment create "batch-size-test" "batch_size_1000" "memory_usage"

# Add observations
npx agentdb causal experiment add-observation 1 true 0.15   # treatment
npx agentdb causal experiment add-observation 1 false 0.45  # control

# Calculate results
npx agentdb causal experiment calculate 1
```

---

## The Pattern Workflow

```
1. BEFORE work:  get-pattern  → Search for relevant patterns
2. DURING work:  Apply patterns, note gaps
3. AFTER work:   reflexion    → Record what helped
                 save-pattern → Store NEW discoveries manually
                 learner      → Auto-discover patterns (THIS SKILL)
```

---

## Related Skills

- **`get-pattern`** - Search patterns BEFORE work
- **`save-pattern`** - Store NEW patterns manually
- **`reflexion`** - Record feedback that feeds learner

---

## What NOT to Use This For

| Don't Use For | Use Instead |
|---------------|-------------|
| Storing specific patterns | `save-pattern` |
| Recording work feedback | `reflexion` |
| Searching patterns | `get-pattern` |

**Learner is for AUTOMATIC discovery, not manual pattern management.**
