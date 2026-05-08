---
name: pal-thinkdeep
description: Multi-stage deep investigation and reasoning for complex problems using PAL MCP. Use for architecture decisions, complex analysis, performance challenges, or when you need thorough reasoning. Triggers on complex problems requiring deep thought, hypothesis testing, or expert analysis.
---

# PAL ThinkDeep - Deep Investigation

Systematic multi-stage investigation for complex problem analysis.

## When to Use

- Complex architectural decisions
- Performance challenges requiring analysis
- Security concerns needing investigation
- Problems requiring hypothesis testing
- When surface-level analysis isn't enough
- Strategic technical planning

## Quick Start

```python
result = mcp__pal__thinkdeep(
    step="Investigating intermittent performance degradation under load",
    step_number=1,
    total_steps=3,
    next_step_required=True,
    findings="Beginning systematic investigation",
    problem_context="API response times spike from 50ms to 5s randomly",
    focus_areas=["performance", "database", "caching"],
    hypothesis="Unknown - needs investigation",
    confidence="exploring"
)
```

## Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `step` | string | Current investigation narrative |
| `step_number` | int | Current step |
| `total_steps` | int | Estimated total |
| `next_step_required` | bool | More investigation needed? |
| `findings` | string | Evidence and insights |

## Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hypothesis` | string | Current theory |
| `confidence` | enum | exploring → certain |
| `focus_areas` | list | ["architecture", "performance", "security"] |
| `problem_context` | string | Background and constraints |
| `relevant_files` | list | Key files (absolute paths) |
| `files_checked` | list | All files examined |
| `issues_found` | list | Problems with severity |
| `continuation_id` | string | Continue session |
| `thinking_mode` | enum | minimal/low/medium/high/max |

## Investigation Process

```
Step 1: Define problem and scope
        ↓
Step 2: Gather evidence, form hypotheses
        ↓
Step 3: Test hypotheses with data
        ↓
Step 4: Refine or pivot based on evidence
        ↓
Step N: Reach conclusion with confidence
```

## Confidence Progression

| Level | Evidence | Action |
|-------|----------|--------|
| `exploring` | None yet | Gather data |
| `low` | Initial clues | Form hypothesis |
| `medium` | Supporting evidence | Test hypothesis |
| `high` | Strong evidence | Verify conclusion |
| `very_high` | Confirmed | Document findings |
| `certain` | Proven | Skip validation |

## Example: Architecture Decision

```python
# Step 1: Frame the problem
mcp__pal__thinkdeep(
    step="Should we adopt event sourcing for the order system?",
    step_number=1,
    total_steps=4,
    next_step_required=True,
    findings="""
    Current state:
    - CRUD-based order management
    - 50K orders/day, growing 20%/month
    - Audit trail requirements from compliance
    - Complex order lifecycle (10 states)

    Questions to investigate:
    - Performance implications at scale
    - Team learning curve
    - Migration complexity
    - Operational overhead
    """,
    problem_context="Evaluating event sourcing vs enhanced CRUD",
    focus_areas=["architecture", "scalability", "complexity"],
    hypothesis="Event sourcing may be over-engineering for current scale",
    confidence="exploring"
)

# Step 2: Analyze trade-offs
mcp__pal__thinkdeep(
    step="Analyzing event sourcing trade-offs for our context",
    step_number=2,
    total_steps=4,
    next_step_required=True,
    findings="""
    Evidence gathered:

    FOR event sourcing:
    - Built-in audit trail (compliance requirement)
    - Temporal queries for analytics
    - Replay capability for debugging

    AGAINST event sourcing:
    - Team has no ES experience (3-6 month learning)
    - Infrastructure complexity (event store, projections)
    - 50K orders/day is manageable with CRUD + audit table

    Middle ground discovered:
    - Audit table with change tracking gives 80% of benefits
    - Can evolve to ES later if needed
    """,
    problem_context="Weighing complexity vs benefits",
    hypothesis="Audit table + CDC is sufficient for current needs",
    confidence="medium",
    continuation_id=result["continuation_id"]
)
```

## Focus Area Guidelines

### Architecture
- System boundaries and responsibilities
- Data flow and dependencies
- Coupling and cohesion
- Scalability patterns

### Performance
- Bottleneck identification
- Resource utilization
- Query optimization
- Caching strategies

### Security
- Attack surface analysis
- Data protection
- Authentication/authorization
- Compliance requirements

## Best Practices

1. **Start with questions** - What do we need to learn?
2. **Gather evidence first** - Don't jump to conclusions
3. **Consider alternatives** - Challenge your assumptions
4. **Document reasoning** - Future you will thank you
5. **Update confidence honestly** - Uncertainty is information
6. **Use continuation_id** - Preserve context across steps
