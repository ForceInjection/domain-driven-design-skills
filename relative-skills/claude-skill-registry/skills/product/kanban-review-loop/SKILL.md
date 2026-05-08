---
name: kanban-review-loop
description: Kanban continuous health monitoring daemon. USE WHEN user says /kanban-review-loop OR wants background board monitoring.
---

# Kanban Review Loop - Continuous Health Monitoring

You are starting the **Review Loop** - a background daemon that continuously monitors Kanban board health with Ralph Wiggum awareness and **session tracking** for cross-context-window continuity.

## Arguments

- `/kanban-review-loop` - Start the daemon
- `/kanban-review-loop stop` - Stop (user should kill the background task)

## Behavior

This runs as a background process that:
1. Checks board health every 5 minutes
2. **Monitors escalated tasks** (exceeded max iterations)
3. Detects and reports issues
4. Auto-spawns QA if review backlog grows
5. Alerts on stale or blocked tasks
6. **Tracks sprint progress**
7. **Generates session summaries** for context bridging

## Start the Daemon

**Run in background using Task tool:**

```
Task tool:
  subagent_type: "general-purpose"
  run_in_background: true
  description: "Kanban review loop daemon"
  prompt: [See daemon instructions below]
```

## Daemon Instructions

```
You are the KANBAN REVIEW LOOP DAEMON with Ralph Wiggum awareness and session tracking.

## Main Loop (repeat continuously)

### Step 0: Session Check (once at start)
Start session: kanban_session_start with agentId: "review-loop-daemon"
This gives you context about recent activity and any continuity notes.

### Step 1: Board Health Verification
Run: kanban_verify_board_health
This returns structured health status with recommendation.

### Step 2: Full Health Check
Run: kanban_health_check with role: "architect", staleThresholdHours: 24

### Step 3: Check Escalations
Run: kanban_get_escalated_tasks with role: "architect"

### Step 4: Check Active Sprint
Run: kanban_sprint_list with role: "architect"
For each active sprint, check iteration count vs maxIterations.

### Step 5: Analyze & Alert

Check for issues:

**CRITICAL ALERTS:**
- **Escalated tasks** (exceeded maxIterations):
  Log "CRITICAL: Task [title] escalated after [N] iterations - needs human review"
- **Critical tasks not started**:
  Log "ALERT: Critical task [title] waiting"

**WARNING ALERTS:**
- **High iteration tasks** (iteration >= maxIterations - 1):
  Log "WARNING: Task [title] at iteration [N]/[max] - at risk of escalation"
- **Stale tasks** (in_progress > 24h):
  Log "WARNING: Task [title] stale for [hours]h"
- **Sprint at risk** (iteration near max):
  Log "WARNING: Sprint [goal] at iteration [N]/[max]"

**INFO ALERTS:**
- **QA backlog > 3**:
  Log "INFO: QA backlog high, spawning QA agent"
- **Overloaded agents** (> 5 tasks):
  Log "INFO: Agent [id] overloaded with [N] tasks"
- **Low backlog** (< 3 tasks):
  Log "INFO: Backlog low, plan more work"

### Step 6: Auto-Remediation

If QA backlog > 3, spawn QA agent (NOT in background):
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are QA. Clear the backlog.
    1. kanban_session_start with agentId: "qa-auto"
    2. kanban_qa_list with role: "qa"
    3. For each task:
       - kanban_get_task_detail to see iteration history
       - Review and approve/reject with structured feedback
    4. kanban_session_end with summary
```

### Step 7: Generate Summary
Run: kanban_generate_summary
This updates the session-summary.md file for other agents.

### Step 8: Report Status

Output:
---
[TIME] Review Loop Check #N
Health: [OK | WARNING | CRITICAL]

Sprint Status:
- [Sprint goal]: Iteration [N]/[max] - [status]

Board:
- Backlog: X | In Progress: Y | Blocked: Z | Done: W
- Pending QA: Q
- Escalated: E

Issues:
- [list of alerts]

Actions Taken:
- [any remediation]

Next check in 5 minutes...
---

### Step 9: Sleep
Wait 5 minutes, then repeat from Step 1.

### On Shutdown
When loop is stopped:
```
kanban_session_end with:
  agentId: "review-loop-daemon"
  sessionNotes: "Review loop stopped. X checks performed."
  cleanState: true
```
```

## Monitoring

After starting:
1. Note the task ID returned
2. Check status: `TaskOutput with task_id, block: false`
3. Stop: User kills the background task

## Alert Priority

| Level | Action |
|-------|--------|
| CRITICAL | Immediate notification, needs human intervention |
| WARNING | Soon to become critical, monitor closely |
| INFO | Informational, auto-remediation if possible |

## Examples

```
User: "/kanban-review-loop"
-> Spawn background daemon
-> Report task ID for monitoring
-> Daemon runs continuously:
   -> kanban_session_start (once)
   -> Checks board health with kanban_verify_board_health
   -> Monitors escalations
   -> Tracks sprint iterations
   -> Alerts on issues
   -> Auto-spawns QA when needed (with session protocols)
   -> kanban_generate_summary (updates file)
   -> Sleep 5 minutes, repeat
-> On stop: kanban_session_end
```
