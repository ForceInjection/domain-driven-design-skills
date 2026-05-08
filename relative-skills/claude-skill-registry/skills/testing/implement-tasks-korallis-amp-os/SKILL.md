---
name: implement-tasks
description: Implement tasks from tasks.md using multi-agent orchestration. Use when ready to implement a spec's tasks, supports both single-agent and multi-agent modes via Task tool.
---

# Implement Tasks

Execute implementation using structured task groups with optional multi-agent support.

## When to Use
- tasks.md is complete
- Ready to write code
- Need TDD-first implementation workflow

## Workflow

1. **Load Context**
   - Read `amp-os/specs/[feature]/tasks.md`
   - Read `amp-os/specs/[feature]/spec.md`
   - Load relevant standards: `amp-os-standards-global`, backend/frontend as needed

2. **For Each Task Group** (in dependency order)

   ### a. Write Tests First
   - Write all tests defined for the group
   - Tests should initially fail
   
   ### b. Implement
   - Complete each sub-task
   - Run group-specific tests frequently
   
   ### c. Verify Group
   - All group tests pass
   - Update tasks.md to mark complete

3. **Track Progress**
   - Use `todo_write` to update task status
   - Update tasks.md checkboxes

## Implementation Modes

### Single-Agent Mode (Default)
Process task groups sequentially yourself.

### Multi-Agent Mode (Complex Features)
Use `Task` tool to delegate task groups:

```
Task: "Implement Task Group 1 (Database Layer) from amp-os/specs/[feature]/tasks.md"

Include in prompt:
- Load amp-os-standards-backend skill
- Follow TDD: write tests first
- Run only group-specific tests
- Report completion status
```

## Resources
- [Implementation Workflow](resources/implementation-workflow.md)

## Amp Tools to Use
- `Task` - Delegate to sub-agents
- `todo_write` / `todo_read` - Track progress
- `finder` - Find related code
- Standard file editing tools

## Important Rules
1. **Tests first** - Always write tests before implementation
2. **Group isolation** - Only run tests for current group
3. **No skipping** - Complete groups in dependency order
4. **Update tracking** - Mark tasks complete in tasks.md and todos
