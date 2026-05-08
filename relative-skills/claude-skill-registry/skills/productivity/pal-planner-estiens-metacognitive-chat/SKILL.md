---
name: pal-planner
description: Interactive task planning with revision and branching using PAL MCP. Use for complex project planning, system design, migration strategies, and breaking down large tasks. Triggers on planning requests, task breakdown, or strategy development.
---

# PAL Planner - Task Planning

Break down complex tasks through interactive, sequential planning with revision and branching.

## When to Use

- Complex project planning
- System design and architecture
- Migration strategies
- Feature implementation planning
- Breaking down large tasks
- Exploring alternative approaches

## Quick Start

```python
# Start planning
result = mcp__pal__planner(
    step="""
    Task: Implement user authentication system

    Scope:
    - Email/password login
    - OAuth (Google, GitHub)
    - JWT tokens with refresh
    - Password reset flow
    """,
    step_number=1,
    total_steps=4,
    next_step_required=True
)

# Continue planning
result = mcp__pal__planner(
    step="Step 2: Database schema and models",
    step_number=2,
    total_steps=4,
    next_step_required=True,
    continuation_id=result["continuation_id"]
)
```

## Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `step` | string | Planning content for this step |
| `step_number` | int | Current step |
| `total_steps` | int | Estimated total steps |
| `next_step_required` | bool | More planning needed? |

## Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `is_step_revision` | bool | Revising a previous step? |
| `revises_step_number` | int | Which step being revised |
| `is_branch_point` | bool | Creating an alternative branch? |
| `branch_id` | string | Name for this branch |
| `branch_from_step` | int | Step this branch starts from |
| `more_steps_needed` | bool | Need more steps than estimated? |
| `continuation_id` | string | Continue session |
| `model` | string | Override model |

## Branching for Alternatives

Explore different approaches:

```python
# Create a branch for alternative approach
mcp__pal__planner(
    step="Alternative: Use session-based auth instead of JWT",
    step_number=3,
    total_steps=5,
    next_step_required=True,
    is_branch_point=True,
    branch_id="session-auth",
    branch_from_step=2,
    continuation_id=result["continuation_id"]
)
```

## Revising Steps

Update earlier decisions:

```python
mcp__pal__planner(
    step="Revised: Add rate limiting to auth endpoints",
    step_number=2,
    total_steps=4,
    next_step_required=True,
    is_step_revision=True,
    revises_step_number=2,
    continuation_id=result["continuation_id"]
)
```

## Planning Structure

### Step 1: Define Task & Scope
```python
step="""
Task: [What needs to be done]

Scope:
- [Requirement 1]
- [Requirement 2]

Constraints:
- [Timeline, resources, etc.]

Success Criteria:
- [How we know it's done]
"""
```

### Subsequent Steps
```python
step="""
Phase 2: [Phase Name]

Tasks:
1. [Specific task]
2. [Specific task]

Dependencies:
- Requires: [Previous phase]
- Blocks: [Next phase]

Risks:
- [Potential issues]
"""
```

## Example: Migration Planning

```python
# Step 1: Define migration
mcp__pal__planner(
    step="""
    Task: Migrate from PostgreSQL to MongoDB

    Scope:
    - User data (500K records)
    - Order history (2M records)
    - Product catalog (50K records)

    Constraints:
    - Maximum 4 hours downtime
    - Must maintain data integrity
    - Rollback capability required
    """,
    step_number=1,
    total_steps=6,
    next_step_required=True
)

# Step 2: Data mapping
mcp__pal__planner(
    step="""
    Phase 2: Schema Mapping

    Transformations:
    - users table → users collection (denormalize addresses)
    - orders table → orders collection (embed line items)
    - products table → products collection (embed categories)

    Challenges:
    - Many-to-many relationships need restructuring
    - Foreign keys → document references
    """,
    step_number=2,
    total_steps=6,
    next_step_required=True,
    continuation_id=result["continuation_id"]
)
```

## Best Practices

1. **Start with scope** - Clear boundaries prevent scope creep
2. **Identify dependencies** - Know what blocks what
3. **Plan for rollback** - Every step should be reversible
4. **Use branches** - Explore alternatives before committing
5. **Revise freely** - Plans should evolve with understanding
6. **Include risks** - Anticipate what could go wrong
