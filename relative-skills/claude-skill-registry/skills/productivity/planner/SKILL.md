---
name: planner
description: Interactive planning and execution for complex tasks. Use when user asks to use or invoke planner skill.
---

# Planner Skill

Two-phase workflow: **planning** (create plans) and **execution** (implement
plans).

## Activation

When this skill activates, IMMEDIATELY invoke the corresponding script. The
script IS the workflow.

| Mode      | Intent                             | Command                                                                |
| --------- | ---------------------------------- | ---------------------------------------------------------------------- |
| planning  | "plan", "design", "architect"      | `python3 scripts/planner.py --phase planning --step 1 --total-steps 4` |
| review    | "review plan" (after plan written) | `python3 scripts/planner.py --phase review --step 1 --total-steps 3`   |
| execution | "execute", "implement", "run plan" | `python3 scripts/executor.py --step 1 --total-steps 7`                 |

## When to Use

Use when task has:

- Multiple milestones with dependencies
- Architectural decisions requiring documentation
- Complexity benefiting from forced reflection pauses

Skip when task is:

- Single-step with obvious implementation
- Quick fix or minor change
- Already well-specified by user

## Resources

| Resource                              | Contents                   | Read When                                       |
| ------------------------------------- | -------------------------- | ----------------------------------------------- |
| `resources/diff-format.md`            | Unified diff specification | Writing code changes in milestones              |
| `resources/temporal-contamination.md` | Comment hygiene heuristics | Writing comments in code snippets               |
| `resources/default-conventions.md`    | Structural conventions     | Making decisions without explicit user guidance |
| `resources/plan-format.md`            | Plan template structure    | Completing planning phase (injected by script)  |

## Workflow Summary

**Planning phase**: 4+ steps:

1. Context Discovery - explore, gather requirements
2. Approach Generation - generate options with tradeoffs
3. Assumption Surfacing - user confirmation of choices
4. Approach Selection & Milestones - decide, write milestones

**Review phase**: 3 steps:

1. Parallel QR (completeness + code)
2. TW documentation scrub
3. QR-Docs validation

**Execution phase**: 7 steps:

1. Execution planning
2. Reconciliation (conditional)
3. Milestone execution via execute-milestone.py
4. Post-implementation QR
5. QR issue resolution (conditional)
6. Documentation
7. Retrospective

Scripts inject step-specific guidance. Invoke and follow output.
