---
name: workflow-router
description: Determine next agent based on state machine rules. Use AFTER receiving any BAZINGA agent response to decide what to do next.
version: 1.0.0
author: BAZINGA Team
tags: [orchestration, routing, workflow]
allowed-tools: [Bash]
---

# Workflow Router Skill

You are the workflow-router skill. Your role is to determine the next action in the BAZINGA workflow by calling `workflow_router.py`, which reads from the state machine configuration.

## Overview

This skill determines what to do after receiving an agent response by:
- Reading transitions from database (seeded from transitions.json)
- Applying testing mode rules (skip QA if disabled/minimal)
- Applying escalation rules (escalate to SSE after N failures)
- Applying security rules (force SSE for security tasks)
- Returning JSON with next action

## Prerequisites

- Database must be initialized (`bazinga/bazinga.db` exists)
- Config must be seeded (run `config-seeder` skill at session start)

## When to Invoke This Skill

- **AFTER** receiving any agent response
- When orchestrator needs to decide what to do next based on agent's status code
- Examples:
  - Developer returned "READY_FOR_QA" → Route to QA Expert
  - QA returned "PASS" → Route to Tech Lead
  - Tech Lead returned "APPROVED" → Check phase, maybe route to PM

## Your Task

When invoked, you must:

### Step 1: Extract Parameters

Parse from the agent's response and current state:
- `current_agent`: Agent that just responded (developer, qa_expert, tech_lead, etc.)
- `status`: Status code from response (READY_FOR_QA, PASS, APPROVED, etc.)
- `session_id`: Current session ID
- `group_id`: Current group ID
- `testing_mode`: full, minimal, or disabled

### Step 2: Call the Python Script

```bash
python3 .claude/skills/workflow-router/scripts/workflow_router.py \
  --current-agent "{current_agent}" \
  --status "{status}" \
  --session-id "{session_id}" \
  --group-id "{group_id}" \
  --testing-mode "{testing_mode}"
```

### Step 3: Parse and Return Result

The script outputs JSON:

```json
{
  "success": true,
  "current_agent": "developer",
  "response_status": "READY_FOR_QA",
  "next_agent": "qa_expert",
  "action": "spawn",
  "model": "sonnet",
  "group_id": "AUTH",
  "session_id": "bazinga_xxx",
  "include_context": ["dev_output", "test_results"]
}
```

Return this JSON to the orchestrator.

## Actions Explained

| Action | What Orchestrator Should Do |
|--------|----------------------------|
| `spawn` | Use prompt-builder, then spawn single agent |
| `respawn` | Re-spawn same agent type with feedback |
| `spawn_batch` | Spawn multiple developers for `groups_to_spawn` |
| `validate_then_end` | Invoke bazinga-validator skill, then route based on verdict |
| `pause_for_user` | Surface clarification question to user |
| `end_session` | Mark session complete, no more spawns |

## Validator Workflow

When PM sends BAZINGA, the orchestrator invokes `bazinga-validator`. After validator returns:

**Orchestrator calls workflow-router skill:**
```
workflow-router, determine next action:
Current agent: validator
Status: ACCEPT  # or REJECT
Session ID: {session_id}
```
Then invoke: `Skill(command: "workflow-router")`

**Note:** Validator is session-scoped - omit `group_id` (not needed for routing).

**Transitions defined in `workflow/transitions.json` → `validator` section:**
- `ACCEPT` → `end_session` action → Complete shutdown protocol
- `REJECT` → `spawn` action with `next_agent: project_manager` → PM fixes issues

**🔴 CRITICAL:** After validator REJECT, orchestrator MUST spawn PM with the rejection details. Do NOT stop!

## Special Flags in Result

| Flag | Meaning |
|------|---------|
| `groups_to_spawn` | Array of group IDs to spawn in parallel |
| `escalation_applied` | True if escalated to SSE due to failures |
| `escalation_reason` | Why escalation happened |
| `skip_reason` | Why QA was skipped (testing mode) |
| `phase_check` | "continue" or "complete" after merge |
| `security_override` | True if security task forced SSE |
| `bypass_qa` | True if QA should be skipped (RE tasks) |

## Output Format

JSON object with routing decision. Parse and execute the `action`.

## Error Handling

| Error | Meaning |
|-------|---------|
| `success: false` | Unknown transition - check `fallback_action` |
| Unknown status | Route to Tech Lead for manual handling |
| Database not found | Cannot route - needs config seeding |

If routing fails, use the `fallback_action` in the error response.
