---
name: tasks-system
description: Manage the llm-do task tracker stored under tasks/ (backlog, active, completed, recurring) including creating new tasks, updating current state, moving tasks between stages, and applying the standard templates when planning or resuming work.
---

# llm-do Task Tracker

Use this skill whenever a request involves creating, editing, or reviewing work items in the `tasks/` directory. Tasks capture in-flight work for agents so they can pause/resume reliably.

## Directory Layout

- `tasks/backlog/` — lightweight ideas; use the backlog template.
- `tasks/active/` — scoped work currently in progress; follow the full active template.
- `tasks/completed/` — finished items (purge as needed; permanent learnings belong in docs/code).
- `tasks/done/` — historical snapshots imported from previous systems (rarely touched).
- `tasks/recurring/` — periodic reviews/work; contains the recurring template.

Each entry is a Markdown file named `<id>-<slug>.md` when possible so IDs remain stable during edits.

## Standard Workflow

1. **Capture an idea**  
   - Create `tasks/backlog/<slug>.md`.  
   - Use the backlog template (Idea/Why/Rough Scope/Why Not Now/Trigger to Activate).  
   - Keep it short; only promote to active once ready.

2. **Activate a task**  
   - Move the file into `tasks/active/`.  
   - Fill out every heading in the active template: Status, Prerequisites (with checkboxes linking dependent tasks), Goal, Context (files, related work, verification plan), Decision Record (even if "none yet"), Tasks checklist, Current State narrative, Notes.  
   - Status is one of `information gathering`, `ready for implementation`, or `waiting for <dependency>`.

3. **Work / resume**  
   - Before editing code, update **Prerequisites** and **Tasks** checkboxes to show the next actionable step.  
   - Keep **Current State** fresh; treat it as the handoff note for the next agent session.  
   - Log decisions inline. If a decision grows large or spans efforts, spin off a dedicated task and cross-link it.

4. **Complete**  
   - When done, move the file to `tasks/completed/` (or delete if noise).  
   - Replace open checkboxes with `[x]`.  
   - Note merged PRs or docs in **Current State** or **Notes** for historical traceability.

5. **Recurring reviews**  
   - For periodic audits (UI, security, etc.), create files in `tasks/recurring/` with the recurring template (Scope, Checklist, Output instructions, Last Run).  
   - Update **Last Run** with `YYYY-MM` plus a short finding summary at the end of each run.

## Templates

Canonical templates live in `tasks/README.md`. Copy/paste from there when bootstrapping new entries:

- **Backlog Template** — Idea, Why, Rough Scope, Why Not Now, Trigger.
- **Active Task Template** — Status, Prerequisites, Goal, Context, Decision Record, Tasks checklist, Current State, Notes.
- **Recurring Template** — Scope listing paths/scripts reviewed, Checklist, Output pointer, Last Run log.

## Task Review

When asked to review a task, carefully analyze the task file and propose revisions for:

- **Goal clarity** — Is the goal well-defined and achievable?
- **Scope** — Should it be split, expanded, or narrowed?
- **Architecture** — Better technical approach, cleaner design
- **Missing steps** — Gaps in the Tasks checklist
- **Prerequisites** — Unidentified dependencies or blockers
- **Verification** — Is "How to verify" concrete and testable?
- **Risk/edge cases** — Failure modes not yet considered

**Resolve open questions:** Identify questions the task creator left unaddressed or assumptions that need validation. Research available sources (codebase, docs, web) to answer them rather than just flagging them.

For each proposed change, provide:
1. **What** — The specific change being proposed
2. **Why** — Detailed rationale and justification
3. **Trade-offs** — Any downsides or costs to consider
4. **Priority** — Must-have vs nice-to-have

Focus on substantive improvements. Challenge assumptions and identify gaps.

## Authoring Guidelines

- Keep each task to a single coherent goal; split unrelated efforts.  
- Add links to relevant files (`path/to/file.py`) and related tasks so agents can `rg` quickly.  
- Always state **How to verify** within Context.  
- Prefer `Prerequisites: none` unless genuinely blocked.  
- Notes capture gotchas encountered during execution; migrate durable learnings to `AGENTS.md`, inline code comments, or docs afterward.  
- Completed tasks are not documentation — if a decision matters broadly, extract it to docs before archiving.

## Helpful Commands

- `rg -n "<Task Name>" tasks/` — find all references to a task ID/slug.  
- `mv tasks/backlog/foo.md tasks/active/` — promote backlog to active when planning begins.  
- `rg -l "Prerequisites" tasks/active` — quickly audit tasks missing prerequisite updates.

Refer to `tasks/README.md` whenever instructions or templates need the full detail beyond this summary.
