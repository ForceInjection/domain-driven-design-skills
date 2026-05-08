---
name: external-memory
description: Context persistence system for long-running multi-agent tasks. Saves research plans, findings, and checkpoints to prevent context loss at token limits.
type: workflow
priority: high
triggers:
  - token_threshold: 150000
  - phase_transition: true
  - agent_completion: true
---

# External Memory System

## Purpose

Enable long-running multi-agent tasks to persist context beyond token limits, supporting:
- Research plan preservation
- Intermediate findings storage
- Checkpoint-based recovery
- Context snapshots for fresh agent handoffs

## Directory Structure

```
.temp/memory/
├── research_plans/         # Active research strategies
│   └── {task_id}.md        # Current approach and goals
├── findings/               # Subagent results
│   ├── {agent}_{ts}.md     # Individual findings
│   └── merged_{ts}.md      # Synthesized results
├── checkpoints/            # Recovery points
│   └── cp_{phase}_{ts}.json
└── context_snapshots/      # Token limit saves
    └── snap_{ts}.md
```

## When to Use

### Automatic Triggers
1. **Token Threshold (150K)**: Save before running out of context
2. **Phase Transition**: After completing exploration/planning/implementation
3. **Agent Completion**: When subagent returns significant findings
4. **Before Spawning**: Before large parallel agent batch

### Manual Triggers
- User requests "save progress"
- Complex decision point reached
- Uncertainty about next steps

## Memory Types

### 1. Research Plans
**Purpose**: Preserve strategic direction across context limits

```markdown
# Research Plan: {task_id}

## Objective
{What we're trying to accomplish}

## Strategy
{High-level approach}

## Key Questions
- [ ] Question 1
- [x] Question 2 (answered)

## Progress
- Completed: {list}
- In Progress: {list}
- Pending: {list}

## Constraints
- {constraint_1}
- {constraint_2}

## Next Actions
1. {action_1}
2. {action_2}
```

### 2. Findings
**Purpose**: Capture subagent discoveries for synthesis

```markdown
# Findings: {agent_name}
**Task**: {task_description}
**Timestamp**: {ISO timestamp}
**Status**: completed|partial|failed

## Summary
{2-3 sentence summary}

## Key Discoveries
1. {discovery_1}
2. {discovery_2}

## Files Modified/Created
- `path/to/file.ts` - {description}

## Open Questions
- {question_1}

## Recommendations
- {recommendation_1}
```

### 3. Checkpoints
**Purpose**: Enable recovery from failures

```json
{
  "checkpoint_id": "cp_implementation_20250104T120000",
  "task_id": "feature_xyz",
  "phase": "implementation",
  "timestamp": "2025-01-04T12:00:00Z",
  "state": {
    "completed_subtasks": ["task_1", "task_2"],
    "pending_subtasks": ["task_3", "task_4"],
    "active_agents": ["mobile-ui-specialist"],
    "blocked_agents": [],
    "findings_count": 3
  },
  "context_summary": "Implementing station detail feature. UI components done, backend integration in progress.",
  "next_action": "Wait for backend-integration-specialist to complete API service",
  "recovery_instructions": "Resume by checking workspace metadata for pending agents"
}
```

### 4. Context Snapshots
**Purpose**: Full context save before token limit

```markdown
# Context Snapshot
**Timestamp**: {ISO timestamp}
**Token Count**: ~{estimated_count}
**Reason**: {token_limit|manual|phase_end}

## Conversation Summary
{Key points from conversation so far}

## Current State
- Task: {current_task}
- Phase: {exploration|planning|implementation|review}
- Agents: {active_agents}

## Important Context
{Critical information that must not be lost}

## Files in Play
- `file_1.ts` - {status}
- `file_2.ts` - {status}

## Pending Decisions
- {decision_1}

## Resume Instructions
{How to continue from this point}
```

## Operations

### Save Research Plan
```bash
# Create/update research plan
.temp/memory/research_plans/{task_id}.md
```

### Save Findings
```bash
# After subagent completion
.temp/memory/findings/{agent}_{timestamp}.md

# Merge multiple findings
.temp/memory/findings/merged_{timestamp}.md
```

### Create Checkpoint
```bash
# At phase boundaries
.temp/memory/checkpoints/cp_{phase}_{timestamp}.json
```

### Save Context Snapshot
```bash
# Before token limit or handoff
.temp/memory/context_snapshots/snap_{timestamp}.md
```

### Load for Recovery
1. Check latest checkpoint: `ls -t .temp/memory/checkpoints/`
2. Read checkpoint JSON
3. Load relevant findings
4. Resume from `next_action`

## Best Practices

### 1. Save Early, Save Often
- Don't wait until 150K tokens
- Save after each significant discovery
- Checkpoint at every phase transition

### 2. Write Actionable Summaries
- Include "what" and "why"
- List concrete next steps
- Reference specific files and line numbers

### 3. Keep Findings Focused
- One finding per significant discovery
- Don't dump entire conversations
- Extract key insights only

### 4. Structure for Retrieval
- Use consistent naming conventions
- Include timestamps for ordering
- Tag with task_id for filtering

### 5. Clean Up Old Memory
- Archive completed task memory
- Delete stale checkpoints (>24h)
- Consolidate related findings

## Integration with Orchestrator

The Lead Orchestrator should:

1. **Initialize Memory** at task start
   ```
   Create: .temp/memory/research_plans/{task_id}.md
   ```

2. **Save After Subagent Batch**
   ```
   For each completed agent:
     Save: .temp/memory/findings/{agent}_{ts}.md
   Create: .temp/memory/checkpoints/cp_{phase}_{ts}.json
   ```

3. **Monitor Token Usage**
   ```
   If tokens > 150K:
     Save: .temp/memory/context_snapshots/snap_{ts}.md
     Option: Spawn fresh agent with context file
   ```

4. **Recover on Failure**
   ```
   Read: latest checkpoint
   Load: relevant findings
   Resume: from recorded state
   ```

## Token Estimation

Rough estimates for planning:
- 1 word ≈ 1.3 tokens
- 1 line of code ≈ 10 tokens
- 1 file read ≈ 500-2000 tokens
- 1 agent response ≈ 1000-3000 tokens

**Warning Zone**: 120K tokens (80% of 150K)
**Save Zone**: 150K tokens (trigger snapshot)

## Example Usage

### Starting a Complex Task
```markdown
1. Create research plan
   └── .temp/memory/research_plans/station_feature.md

2. After exploration phase
   └── .temp/memory/checkpoints/cp_exploration_*.json
   └── .temp/memory/findings/exploration_*.md

3. After spawning UI + Backend agents
   └── .temp/memory/findings/mobile-ui_*.md
   └── .temp/memory/findings/backend-integration_*.md

4. Merge and checkpoint
   └── .temp/memory/findings/merged_*.md
   └── .temp/memory/checkpoints/cp_implementation_*.json

5. Final review
   └── .temp/memory/checkpoints/cp_review_*.json
```

---

**Version**: 1.0 | **Last Updated**: 2025-01-04
