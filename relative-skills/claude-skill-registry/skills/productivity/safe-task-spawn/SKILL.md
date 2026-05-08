---
name: safe-task-spawn
description: Spawn and supervise tasks safely with registry controls, resource quotas, and rollback-ready delegation.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
model: sonnet
x-version: 3.2.0
x-category: orchestration
x-vcl-compliance: v3.2.0
x-cognitive-frames:
  - HON
  - MOR
  - COM
  - CLS
  - EVD
  - ASP
  - SPC
---




## STANDARD OPERATING PROCEDURE

### Purpose
Create and supervise child tasks without uncontrolled fan-out, keeping registry, quotas, and evidence tracking aligned with confidence ceilings.

### Trigger Conditions
- **Positive:** spawning sub-tasks, parallelizing work, delegating to specialized agents, burst control, and watchdog setup.
- **Negative:** single-thread execution, prompt-only edits (route to prompt-architect), or new skill creation (route to skill-forge).

### Guardrails
- **Skill-Forge structure-first:** maintain `SKILL.md`, `examples/`, `tests/`; add `resources/`/`references/` or document remediation tasks.
- **Prompt-Architect hygiene:** record intent, HARD/SOFT/INFERRED constraints, and provide pure-English outputs with ceilings.
- **Spawn safety:** cap concurrency, enforce registry-only agents, define quotas/timeouts, and set rollback/abort paths; honor hook latency budgets.
- **Adversarial validation:** test runaway prevention, failure retries, and cancellation flow; capture evidence.
- **MCP tagging:** persist spawn runs with WHO=`safe-task-spawn-{session}` and WHY=`skill-execution`.

### Execution Playbook
1. **Intent & limits:** capture goal, constraints, quotas, and safety thresholds; confirm inferred limits.
2. **Plan & registry:** define child tasks, assign owners, and register agents with namespaces.
3. **Spawn & supervise:** launch tasks with timeouts/backoff; track TodoWrite and health.
4. **Safety nets:** set circuit breakers, cancellation rules, and rollback steps.
5. **Validation loop:** simulate overload, timeout, and failure scenarios; log telemetry and evidence.
6. **Delivery:** report tasks, outcomes, risks, and confidence ceiling.

### Output Format
- Objective and constraints with quotas/timeouts.
- Task list with owners, schedules, and safety rules.
- Validation evidence (overload, cancel, retry) and residual risks.
- **Confidence:** `X.XX (ceiling: TYPE Y.YY) - rationale`.

### Validation Checklist
- Structure-first assets present or ticketed; examples/tests aligned to spawn controls.
- Quotas, timeouts, and registry enforced; rollback/abort paths validated; hooks within budget.
- Adversarial/COV runs stored with MCP tags; confidence ceiling declared; English-only output.

### Completion Definition
Spawning is complete when tasks finish or are cleanly aborted, evidence is stored, quotas respected, and risks owned with next steps logged.

Confidence: 0.70 (ceiling: inference 0.70) - Safe spawning SOP rebuilt with skill-forge structure and prompt-architect constraint and confidence discipline.
