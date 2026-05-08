---
name: ln-300-task-coordinator
description: Orchestrates task operations. Analyzes Story, builds optimal plan (1-6 implementation tasks), delegates to ln-301-task-creator (CREATE/ADD) or ln-302-task-replanner (REPLAN). Auto-discovers team ID.
---

# Linear Task Planner (Orchestrator)

Coordinates creation or replanning of implementation tasks for a Story. Builds the ideal plan first, then routes to workers.

## Purpose & Scope
- Auto-discover Team ID, load Story context (AC, Technical Notes, Context)
- Build optimal implementation task plan (1-6 implementation tasks; NO test/refactoring tasks) in Foundation-First order
- Detect mode and delegate: CREATE/ADD -> ln-301-task-creator, REPLAN -> ln-302-task-replanner
- Strip any Non-Functional Requirements; only functional scope becomes tasks
- Never creates/updates Linear or kanban directly (workers do)

## When to Use
- Need tasks for a Story with clear AC/Technical Notes
- Story requirements changed and existing tasks must be updated
- NOT for test tasks (created by ln-500 -> ln-510) or refactoring tasks (created by ln-500)

## Workflow (concise)
- **Phase 1 Discovery:** Auto-discover Team ID (docs/tasks/kanban_board.md); parse Story ID from request.
- **Phase 2 Decompose (always):** Load Story (AC, Technical Notes, Context), assess complexity, build IDEAL plan (1-6 implementation tasks only), apply Foundation-First execution order, extract guide links.
- **Phase 3 Check & Detect Mode:** Query Linear for existing tasks (metadata only). Detect mode by count + user keywords (add/replan).
- **Phase 4 Delegate:** Call the right worker with Story data, IDEAL plan/append request, guide links, existing task IDs if any; autoApprove=true.
- **Phase 5 Verify:** Ensure worker returns URLs/summary and updated kanban_board.md; report result.

## Mode Matrix
| Condition | Mode | Delegate | Payload |
|-----------|------|----------|---------|
| Count = 0 | CREATE | ln-301-task-creator | taskType=implementation, Story data, IDEAL plan, guideLinks |
| Count > 0 AND "add"/"append" | ADD | ln-301-task-creator | taskType=implementation, appendMode=true, newTaskDescription, guideLinks |
| Count > 0 AND replan keywords | REPLAN | ln-302-task-replanner | taskType=implementation, Story data, IDEAL plan, guideLinks, existingTaskIds |
| Count > 0 AND ambiguous | ASK | Clarify with user | — |

**TodoWrite format (mandatory):**
Add phases to todos before starting:
```
- Phase 1: Discovery (in_progress)
- Phase 2: Decompose & Build IDEAL Plan (pending)
- Phase 3: Check Existing & Detect Mode (pending)
- Phase 4: Delegate to ln-301/ln-302 (pending)
- Phase 5: Verify worker result (pending)
```
Mark each as in_progress when starting, completed when done.

## Critical Rules
- Decompose-first: always build IDEAL plan before looking at existing tasks.
- Foundation-First execution order: DB -> Repository -> Service -> API -> Frontend.
- Task limits: 1-6 implementation tasks, 3-5h each; cap total at 6. Test task created later by ln-500 -> ln-510.
- Linear creation must be sequential: create one task, confirm success, then create the next (no bulk) to catch errors early.
- This skill creates ONLY implementation tasks (taskType=implementation). Test and refactoring tasks are created by ln-500-story-quality-gate.
- No code snippets in descriptions; workers own task documents and Linear/kanban updates.
- Language preservation: keep Story language (EN/RU) in any generated content by workers.

## Definition of Done (orchestrator)
- Team ID discovered; Story ID parsed.
- Story loaded; IDEAL plan built (1-6 implementation tasks only) with Foundation-First order and guide links.
- Existing tasks counted; mode selected (CREATE/ADD/REPLAN or ask).
- Worker invoked with correct payload and autoApprove=true.
- Worker summary received (Linear URLs/operations) and kanban update confirmed.
- Next steps returned (ln-310-story-validator then ln-410-story-executor).

## Reference Files
- Templates owned by ln-301-task-creator: `../ln-301-task-creator/references/task_template_implementation.md`
- Replan algorithm details: `../ln-302-task-replanner/references/replan_algorithm.md`
- Auto-discovery notes: `CLAUDE.md`, `docs/tasks/kanban_board.md`

---
**Version:** 3.0.0
**Last Updated:** 2025-12-23
