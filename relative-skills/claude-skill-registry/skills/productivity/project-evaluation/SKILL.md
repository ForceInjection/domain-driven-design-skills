---
name: "Project Evaluation"
description: "Comprehensive project status evaluation using hive-mind coordination, GOAP planning, neural analysis, and AgentDB memory. Use when assessing architecture health, planning refactoring, or generating status reports."
---

# Project Evaluation Skill

## What This Skill Does

Orchestrates comprehensive project evaluation using all Claude Flow systems:
- **Hive-Mind**: Collective intelligence coordination
- **AgentDB**: Persistent memory across sessions
- **Neural Training**: Pattern learning from evaluations
- **GOAP Planning**: Action planning for improvements
- **Skill Creation**: Document learnings as reusable skills

## Prerequisites

- Claude Flow v2.0+ (`npx claude-flow@alpha`)
- Initialized hive-mind (`npx claude-flow hive-mind init`)
- Project with prior session memory

## Quick Start

```bash
# 1. Retrieve prior session state
npx claude-flow memory retrieve --namespace hive-mind --key "session/*"

# 2. Initialize evaluation swarm
npx claude-flow swarm init --topology hierarchical --agents 5

# 3. Spawn evaluation agents
# Use Claude Code Task tool:
Task("Architecture Agent", "Evaluate architecture health...", "system-architect")
Task("GOAP Agent", "Generate improvement plan...", "code-goal-planner")
```

## Evaluation Framework

### Phase 1: Memory Retrieval
```typescript
// Retrieve prior session state
const session = await memory.retrieve('session/*/completed', 'hive-mind');
const worldState = await memory.retrieve('goap/world-state/final', 'goap');
```

### Phase 2: Agent Spawning
```javascript
// Spawn evaluation agents via Task tool
[Parallel]:
  Task("system-architect", "Evaluate architecture against assessment...")
  Task("code-goal-planner", "Generate GOAP plan for Grade A...")
  Task("tester", "Analyze test coverage and quality...")
```

### Phase 3: Neural Analysis
```typescript
// Train on evaluation patterns
await neuralTrain({
  pattern_type: "coordination",
  training_data: { metrics: ["architecture", "testing", "performance"] }
});
```

### Phase 4: Results Storage
```typescript
// Store in AgentDB for persistence
await memory.store('evaluation/architecture-grade', results, 'agentdb');
await memory.store('evaluation/goap-plan', plan, 'goap');
```

## Evaluation Metrics

| Category | Metrics |
|----------|---------|
| Architecture | Grade, critical issues, domain separation |
| Testing | File count, coverage %, pass rate |
| Performance | Bundle size, build time, store LOC |
| Tech Debt | Deprecated code, uncommitted changes |

## Output Format

```json
{
  "evaluation": {
    "previousGrade": "B-",
    "currentGrade": "B+",
    "criticalIssuesResolved": 3,
    "criticalIssuesRemaining": 0
  },
  "goapPlan": {
    "totalCost": 13,
    "actions": ["commit", "test", "delete", "optimize"],
    "successProbability": "85%"
  },
  "metrics": {
    "storeLOC": 3678,
    "testFiles": 67,
    "uncommittedFiles": 19
  }
}
```

## Integration with Other Skills

- `store-migration-workflow` - For refactoring execution
- `hive-mind-advanced` - For collective coordination
- `agentdb-memory-patterns` - For persistence
- `goap-planning` - For action sequencing

## Best Practices

1. **Always retrieve prior session state** before evaluation
2. **Store all findings** in AgentDB for cross-session persistence
3. **Train neural patterns** on successful evaluations
4. **Generate GOAP plans** for actionable next steps
5. **Create skills** from recurring evaluation patterns

---

**Created**: 2025-12-03
**Version**: 1.0.0
**Category**: Project Management
