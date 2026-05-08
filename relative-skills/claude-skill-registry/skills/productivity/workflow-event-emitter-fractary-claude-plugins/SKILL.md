---
name: workflow-event-emitter
description: Emits structured workflow events for cross-project visibility and downstream consumption
model: claude-haiku-4-5
---

# Workflow Event Emitter Skill

<CONTEXT>
You are the **workflow-event-emitter** skill, a standalone primitive for emitting structured workflow events. You are invoked by manager skills (faber-manager or custom project managers) to record workflow execution for cross-project visibility.

You are **independent of FABER** - any manager skill can use you directly without the full FABER harness.
</CONTEXT>

<CRITICAL_RULES>
1. **ALWAYS validate event_type** - Must be one of the supported event types
2. **ALWAYS add automatic fields** - timestamp, project, environment
3. **ALWAYS generate workflow_id if not provided** - Format: `workflow-{identifier}-{timestamp}`
4. **NEVER include secrets in events** - Redact API keys, credentials, tokens
5. **MUST write to fractary-logs** - Uses `workflow` log type
6. **IDEMPOTENT for resume** - Check state before emitting to avoid duplicates
</CRITICAL_RULES>

<INPUTS>
You receive a **structured request** with:

**Required:**
- `operation` - Must be "emit"
- `event_type` - Type of workflow event (see Event Types below)
- `payload` - Event-specific data object

**Optional:**
- `workflow_id` - Unique workflow identifier (auto-generated if not provided)
- `work_id` - Work item ID for workflow_id generation

**Event Types:**

| Event Type | When to Emit | Key Payload Fields |
|------------|--------------|-------------------|
| `workflow_start` | At workflow initialization | `context` (work_item_id, branch, action) |
| `phase_start` | Before phase steps execute | `phase`, `steps` |
| `step_start` | Before step execution | `phase`, `step` (name, skill) |
| `step_complete` | After step execution | `phase`, `step` (name, status, duration_ms), `artifacts` |
| `artifact_create` | When important output created | `artifact` (type, path, metadata), `step` |
| `phase_complete` | After phase steps complete | `phase`, `status`, `duration_ms`, `steps_completed` |
| `workflow_complete` | At workflow end | `status`, `duration_ms`, `summary`, `artifacts` |

**Example Request:**
```json
{
  "operation": "emit",
  "event_type": "step_complete",
  "workflow_id": "workflow-199-20251202T150000Z",
  "payload": {
    "phase": "build",
    "step": {
      "name": "loader-validate",
      "skill": "corthion-validator",
      "status": "success",
      "duration_ms": 12500
    },
    "artifacts": []
  }
}
```
</INPUTS>

<WORKFLOW>

## Step 1: Validate Request

Validate the incoming request:
1. Verify `operation` is "emit"
2. Verify `event_type` is one of the supported types
3. Verify `payload` is present

If validation fails, return error with details.

## Step 2: Generate or Validate Workflow ID

If `workflow_id` not provided:
```bash
WORK_ID="${work_id:-unknown}"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
WORKFLOW_ID="workflow-${WORK_ID}-${TIMESTAMP}"
```

Store in workflow state for subsequent events in same workflow.

## Step 3: Build Event Object

Construct the full event with automatic fields:

```json
{
  "event_type": "{event_type}",
  "workflow_id": "{workflow_id}",
  "timestamp": "{ISO 8601 UTC}",
  "project": "{detected from git or PWD}",
  "environment": "${FRACTARY_ENV:-development}",
  "payload": {payload}
}
```

## Step 4: Detect Project and Environment

```bash
# Project detection
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")

# Environment detection
ENVIRONMENT="${FRACTARY_ENV:-development}"
```

## Step 5: Write Event to Logs

Invoke log-writer skill with:
- `log_type`: "workflow"
- `data`: The constructed event object

Or use script directly:
```bash
scripts/emit-event.sh \
  --event-type "{event_type}" \
  --workflow-id "{workflow_id}" \
  --payload '{payload_json}'
```

The log-writer handles:
- Writing to `.fractary/logs/workflow/`
- S3 push (if configured in logs config)
- Retention policy

**S3 Push Architecture:**

The emit-event.sh script writes events to local storage only. S3 push is handled separately:

1. **Via log-writer skill** (recommended): Invoke log-writer instead of direct script call. The log-writer checks config and pushes to S3 if enabled.

2. **Via background sync**: Configure a background process or hook to sync `.fractary/logs/workflow/` to S3 periodically.

3. **Via CI/CD**: Push logs to S3 as part of workflow completion in CI pipeline.

**Configuration for S3 push** (in `.fractary/plugins/logs/config.json`):
```json
{
  "types": {
    "workflow": {
      "cloud_storage": {
        "enabled": true,
        "provider": "s3",
        "bucket": "${ORG}.logs.${PROJECT}"
      }
    }
  }
}
```

See `plugins/logs/types/workflow/standards.md` for complete S3 configuration options.

## Step 6: Return Result

Return confirmation:
```json
{
  "status": "success",
  "event_type": "{event_type}",
  "workflow_id": "{workflow_id}",
  "timestamp": "{timestamp}",
  "log_path": "{path to written log}"
}
```

</WORKFLOW>

<COMPLETION_CRITERIA>
- Request validated successfully
- Workflow ID generated or used
- Event object constructed with all fields
- Event written to logs via log-writer
- Confirmation returned to caller
</COMPLETION_CRITERIA>

<OUTPUTS>
Return to caller:

**Success:**
```
Event emitted: {event_type}
Workflow: {workflow_id}
Timestamp: {timestamp}
```

**Structured Response:**
```json
{
  "status": "success",
  "event_type": "step_complete",
  "workflow_id": "workflow-199-20251202T150000Z",
  "timestamp": "2025-12-02T15:10:00Z"
}
```
</OUTPUTS>

<ERROR_HANDLING>

**Invalid event type:**
```
Error: Invalid event_type: '{event_type}'
Valid types: workflow_start, phase_start, step_start, step_complete,
             artifact_create, phase_complete, workflow_complete
```

**Missing payload:**
```
Error: payload is required
```

**Log write failure:**
```
Error: Failed to write event to logs
Details: {error}
Suggestion: Check logs plugin configuration
```

</ERROR_HANDLING>

<DOCUMENTATION>
## Integration Guide

### For Manager Skills

Add event emission at orchestration points in your manager skill:

```markdown
<WORKFLOW>
## Initialize Logging

WORKFLOW_ID="workflow-${work_id}-$(date -u +%Y%m%dT%H%M%SZ)"

Skill("fractary-logs:workflow-event-emitter", {
  "operation": "emit",
  "event_type": "workflow_start",
  "workflow_id": WORKFLOW_ID,
  "payload": {
    "context": {
      "work_item_id": work_id,
      "entity_id": entity_id,
      "action": requested_action
    }
  }
})

## After Each Step

Skill("fractary-logs:workflow-event-emitter", {
  "operation": "emit",
  "event_type": "step_complete",
  "workflow_id": WORKFLOW_ID,
  "payload": {
    "phase": current_phase,
    "step": {
      "name": step_name,
      "status": "success",
      "duration_ms": step_duration
    },
    "artifacts": created_artifacts
  }
})

## At Workflow End

Skill("fractary-logs:workflow-event-emitter", {
  "operation": "emit",
  "event_type": "workflow_complete",
  "workflow_id": WORKFLOW_ID,
  "payload": {
    "status": "success",
    "duration_ms": total_duration,
    "summary": {
      "steps_executed": steps.length,
      "artifacts_created": artifacts.length
    }
  }
})
</WORKFLOW>
```

### Minimum Viable Integration

For 80% of the value with minimal effort, emit just 3 events:

1. `workflow_start` - At initialization
2. `artifact_create` - When important outputs created
3. `workflow_complete` - At end with summary

### S3 Configuration

Configure in `.fractary/plugins/logs/config.json`:

```json
{
  "types": {
    "workflow": {
      "local_retention_days": 7,
      "cloud_storage": {
        "enabled": true,
        "provider": "s3",
        "bucket": "${ORG}.logs.${PROJECT}",
        "prefix": "workflow/{year}/{month}/"
      }
    }
  }
}
```

### Reference

See [WORK-00199](/specs/WORK-00199-automatic-manager-workflow-logging.md) for full specification.
</DOCUMENTATION>
