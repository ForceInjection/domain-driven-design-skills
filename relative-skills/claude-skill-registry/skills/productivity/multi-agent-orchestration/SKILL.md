---
name: multi-agent-orchestration
description: Enable Claude to orchestrate complex tasks by spawning and managing specialized sub-agents for parallel or sequential decomposition. Use when tasks have clear independent subtasks, require specialized approaches for different components, benefit from parallel processing, need fault isolation, or involve complex state management across multiple steps. Best for data pipelines, code analysis workflows, content creation pipelines, and multi-stage processing tasks.
---

# Multi-Agent Orchestration

Orchestrate complex tasks through specialized sub-agents with parallel or sequential execution.

## Core Principles

1. **Minimal Context**: Each sub-agent receives only task-specific data
2. **Clear Contracts**: Explicit input/output for all agents
3. **File-Based Communication**: Use filesystem for data exchange between agents
4. **Graceful Failure**: Errors isolated to individual agents
5. **Resource Limits**: Track concurrent operations and token usage

## When to Use

✅ **Use for:**
- Data pipelines with extraction → transformation → analysis stages
- Code analysis with parallel linting, security scanning, performance checks
- Content creation with research → outline → writing → editing phases
- Multi-source data aggregation requiring parallel fetches

❌ **Don't use for:**
- Simple linear tasks
- Tasks where coordination overhead exceeds benefits
- Real-time interactions requiring constant back-and-forth

## Quick Start

### 1. Import the Orchestrator

```python
from scripts.orchestrator import Orchestrator, AgentTask, AgentStatus
```

### 2. Define Agent Tasks

```python
orchestrator = Orchestrator(max_concurrent=3)

# Parallel extraction
orchestrator.register_task(AgentTask(
    agent_id="extract_api",
    role="API Data Extractor",
    context={"endpoint": "api.example.com/data"},
    instructions="Extract data and save to data/api_data.json"
))

orchestrator.register_task(AgentTask(
    agent_id="extract_db", 
    role="Database Extractor",
    context={"query": "SELECT * FROM users"},
    instructions="Extract data and save to data/db_data.json"
))

# Sequential transformation (depends on extraction)
orchestrator.register_task(AgentTask(
    agent_id="transform",
    role="Data Transformer",
    context={"input_files": ["data/api_data.json", "data/db_data.json"]},
    instructions="Merge data and save to data/transformed.json",
    dependencies=["extract_api", "extract_db"]
))
```

### 3. Execute

```python
results = await orchestrator.execute_chain()

if results["transform"].status == AgentStatus.SUCCESS:
    print(f"Output: {results['transform'].output}")
```

## Execution Patterns

### Parallel Execution
Independent tasks run simultaneously:
```python
results = await orchestrator.execute_parallel()
```

### Sequential Chain
Tasks execute respecting dependencies:
```python
results = await orchestrator.execute_chain()
```

### Mixed Workflow
Combine patterns - parallel stages with sequential dependencies between stages.

## Agent Context Isolation

Each agent receives minimal context:

```python
context = {
    "input_file": "data.csv",
    "operation": "filter_nulls",
    "output_file": "filtered.csv"
}
```

**Never pass:**
- Full orchestrator state
- Other agents' results (unless explicit dependency)
- Entire conversation history

## File-Based Communication

Agents communicate via filesystem:

```python
# Agent 1 writes
with open("data/stage1_output.json", "w") as f:
    json.dump(results, f)

# Agent 2 reads (via dependency)
context = {"input_file": "data/stage1_output.json"}
```

Use workspace directory structure:
```
/tmp/orchestration_workspace/
├── agent1/
│   ├── input.json
│   └── output.json
├── agent2/
│   └── results.json
└── shared/
    └── common_data.json
```

## Error Handling

```python
# Automatic retry with exponential backoff
orchestrator = Orchestrator(max_retries=3)

# Check results
for agent_id, result in results.items():
    if result.status == AgentStatus.FAILED:
        print(f"Agent {agent_id} failed: {result.error}")
```

## Resource Management

```python
# Limit concurrent agents
orchestrator = Orchestrator(max_concurrent=5)

# Track token usage
orchestrator = TokenAwareOrchestrator(token_budget=100000)
```

## Common Patterns

### Data Pipeline
```
Extract (parallel) → Transform (sequential) → Analyze (sequential)
```

### Code Analysis
```
Lint + Security Scan + Performance Check (parallel) → Report (sequential)
```

### Content Creation
```
Research → Outline → [Intro + Body + Conclusion] (parallel) → Edit
```

## Implementation Details

See `references/implementation-guide.md` for:
- Complete class implementations
- Advanced patterns (hierarchical delegation, message bus)
- Integration with Claude Code subprocess execution
- Monitoring and debugging strategies

See `scripts/orchestrator.py` for ready-to-use orchestrator classes.

## Best Practices

1. **Start small**: Test with 2-3 agents before scaling
2. **Profile execution**: Log timing to identify bottlenecks
3. **Use timeouts**: Set reasonable limits per agent
4. **Cleanup workspace**: Remove temporary files after completion
5. **Log everything**: Maintain execution log for debugging
