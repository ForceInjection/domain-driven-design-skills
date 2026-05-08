---
name: kanban-review-loop
description: Kanban continuous health monitoring daemon. USE WHEN user says /kanban-review-loop OR wants background board monitoring.
---

# Kanban Review Loop - Continuous Health Monitoring

You are starting the **Review Loop** - a background daemon that continuously monitors Kanban board health.

## Arguments

- `/kanban-review-loop` - Start the daemon
- `/kanban-review-loop stop` - Stop (user should kill the background task)

## Behavior

This runs as a background process that:
1. Checks board health every 5 minutes
2. Detects and reports issues
3. Auto-spawns QA if review backlog grows
4. Alerts on stale or blocked tasks

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
You are the KANBAN REVIEW LOOP DAEMON.

## Main Loop (repeat continuously)

### Step 1: Health Check
Run: kanban_health_check with role: "architect", staleThresholdHours: 24

### Step 2: Analyze & Alert

Check for issues:

- **Stale tasks** (in_progress > 24h): Log "ALERT: Task [title] stale for [hours]h"
- **QA backlog > 3**: Spawn QA sub-agent to clear backlog
- **Overloaded agents** (> 5 tasks): Log "ALERT: Agent [id] overloaded"
- **Low backlog** (< 3 tasks): Log "INFO: Backlog low, plan more work"
- **Critical tasks not started**: Log "ALERT: Critical task [title] waiting"

### Step 3: Auto-Remediation

If QA backlog > 3, spawn QA agent (NOT in background):
  subagent_type: "general-purpose"
  prompt: "You are QA. Clear the backlog: kanban_qa_list, then approve/reject each."

### Step 4: Report Status

Output:
---
[TIME] Review Loop Check #N
Health: [OK | ISSUES]
- Backlog: X | In Progress: Y | Blocked: Z | Pending QA: W
Issues: [list]
Actions: [any remediation taken]
Next check in 5 minutes...
---

### Step 5: Sleep
Wait 5 minutes, then repeat from Step 1.
```

## Monitoring

After starting:
1. Note the task ID returned
2. Check status: `TaskOutput with task_id, block: false`
3. Stop: User kills the background task

## Examples

```
User: "/kanban-review-loop"
-> Spawn background daemon
-> Report task ID for monitoring
-> Daemon runs continuously checking health
```
