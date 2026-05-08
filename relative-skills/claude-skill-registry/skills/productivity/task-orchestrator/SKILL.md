---
name: task-orchestrator
description: Plan and organize complex multi-step tasks with optimal sequential and parallel ordering. Use this skill when the user requests multi-part work requiring dependency analysis. Produces a sorted task plan—execution only on explicit user approval.
license: MIT
---

This skill transforms complex requests into optimally-ordered task plans, identifying parallelism opportunities while respecting dependencies. **Plans only—never executes without explicit user confirmation.**

## Orchestrator Thinking

Before outputting the plan, build the task graph:
- **Dependencies**: Which tasks block others? Map the critical path explicitly.
- **Parallelism**: Which tasks share NO dependencies? These form concurrent batches.
- **Granularity**: Is each task atomic enough for a single subagent? Split compound tasks.
- **Ordering**: What's the minimum-latency execution order given the dependency graph?

**CRITICAL**: This skill produces a PLAN, not execution. Output a numbered task list grouped by execution batch. Parallel tasks appear in the same batch. Sequential tasks appear in separate batches. Ask user "Execute this plan?" before invoking anything.

## Orchestration Guidelines

Focus on:
- **Dependency Graph**: Build explicit `task_a → task_b` edges. Visualize blocking relationships. Circular dependencies are bugs—detect and surface.
- **Batch Grouping**: Group zero-dependency tasks into Batch 1. Tasks unblocked after Batch 1 form Batch 2. Label each batch clearly with `[parallel]` or `[sequential]` tags.
- **Plan Output Format**: Present as numbered list with batch headers. Include brief rationale for ordering. End with "Proceed with execution?" prompt.
- **Execution Gate**: ONLY invoke subagents after user confirms. Confirmations: "yes", "execute", "proceed", "go". Anything else means wait or revise.
- **Revision Support**: If user wants changes, regenerate plan. Don't partially execute then ask—plan is atomic until approved.

NEVER auto-execute without user confirmation (violates planning-only contract), present flat lists without batch structure (loses parallelism visibility), skip the confirmation prompt (user must opt-in to execution), execute partial plans (all-or-nothing after approval), assume "sounds good" means execute (require explicit action words).
