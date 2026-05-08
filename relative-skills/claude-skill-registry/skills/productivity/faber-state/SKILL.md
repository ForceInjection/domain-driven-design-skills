---
name: faber-state
description: Manage FABER workflow state (CRUD operations)
model: claude-opus-4-5
---

# FABER State Skill

<CONTEXT>
You are a focused utility skill for managing FABER workflow state files.
You provide deterministic CRUD operations for workflow state management.

State is stored at:
- **With run_id**: `.fractary/plugins/faber/runs/{run_id}/state.json`
- **Legacy (no run_id)**: `.fractary/plugins/faber/state.json`

State tracks: current phase, phase statuses, artifacts, retry counts, errors, last_event_id
</CONTEXT>

<CRITICAL_RULES>
**YOU MUST:**
- Use existing scripts from the core skill (located at `../core/scripts/`)
- Return structured JSON results for all operations
- Preserve existing state data when updating
- Use atomic writes to prevent corruption

**YOU MUST NOT:**
- Make decisions about workflow progression (that's the agent's job)
- Skip state validation
- Delete state without explicit request
</CRITICAL_RULES>

<STATE_STRUCTURE>
```json
{
  "run_id": "fractary/my-project/a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "plan_id": "fractary-claude-plugins-csv-export-20251208T160000",
  "work_id": "123",
  "workflow_id": "default",
  "workflow_version": "2.1",
  "status": "in_progress",
  "current_phase": "build",
  "current_step_index": 2,
  "steps_completed": ["generate-spec", "create-branch"],
  "last_event_id": 15,
  "started_at": "2025-12-03T10:00:00Z",
  "updated_at": "2025-12-03T10:30:00Z",
  "completed_at": null,
  "phases": {
    "frame": {
      "status": "completed",
      "started_at": "2025-12-03T10:00:00Z",
      "completed_at": "2025-12-03T10:05:00Z",
      "steps": [],
      "retry_count": 0
    },
    "architect": {
      "status": "completed",
      "started_at": "2025-12-03T10:05:00Z",
      "completed_at": "2025-12-03T10:15:00Z",
      "steps": [
        {"id": "generate-spec", "status": "completed", "started_at": "...", "completed_at": "...", "duration_ms": 5000}
      ],
      "retry_count": 0
    },
    "build": {
      "status": "in_progress",
      "started_at": "2025-12-03T10:15:00Z",
      "steps": [
        {"id": "implement", "status": "in_progress", "started_at": "..."},
        {"id": "commit", "status": "pending"}
      ],
      "retry_count": 0
    },
    "evaluate": {"status": "pending", "steps": [], "retry_count": 0},
    "release": {"status": "pending", "steps": [], "retry_count": 0}
  },
  "artifacts": {
    "spec_path": "specs/WORK-00123-feature.md",
    "branch_name": "feat/123-add-feature",
    "pr_url": null,
    "pr_number": null
  },
  "errors": []
}
```

**Note:** Steps in state use `id` field for identification. For backward compatibility with existing state files, `name` field is also supported during reads.
</STATE_STRUCTURE>

<OPERATIONS>

## init-state

Initialize a new workflow state file.

**Script:** `../core/scripts/state-init.sh`

**Parameters:**
- `work_id` (required): Work item identifier
- `run_id` (optional): Run identifier (format: org/project/uuid). If provided, state is stored in per-run directory.
- `workflow_id` (optional): Workflow to use (default: "default")
- `state_path` (optional): Path to state file (computed from run_id if provided)

**Returns:**
```json
{
  "status": "success",
  "operation": "init-state",
  "work_id": "123",
  "run_id": "fractary/my-project/a1b2c3d4-...",
  "workflow_id": "default",
  "state_path": ".fractary/plugins/faber/runs/fractary/my-project/a1b2c3d4-.../state.json"
}
```

**Execution:**
```bash
# With run_id (preferred for new workflows)
../core/scripts/state-init.sh --run-id "$RUN_ID" "$WORK_ID" "$WORKFLOW_ID"

# Legacy (without run_id)
../core/scripts/state-init.sh "$WORK_ID" "$WORKFLOW_ID" "$STATE_PATH"
```

---

## read-state

Read current workflow state.

**Script:** `../core/scripts/state-read.sh`

**Parameters:**
- `run_id` (optional): Run identifier. If provided, reads from per-run directory.
- `state_path` (optional): Path to state file (computed from run_id if provided)
- `query` (optional): jq query for specific field (e.g., `.current_phase`)

**Returns:**
```json
{
  "status": "success",
  "operation": "read-state",
  "state": { ... full state object ... }
}
```

Or with query:
```json
{
  "status": "success",
  "operation": "read-state",
  "query": ".current_phase",
  "result": "build"
}
```

**Execution:**
```bash
# With run_id (preferred)
../core/scripts/state-read.sh --run-id "$RUN_ID" "$QUERY"

# Legacy
../core/scripts/state-read.sh "$STATE_PATH" "$QUERY"
```

---

## update-phase

Update a phase's status and data.

**Script:** `../core/scripts/state-update-phase.sh`

**Parameters:**
- `run_id` (optional): Run identifier. If provided, updates per-run state.
- `phase` (required): Phase name (frame, architect, build, evaluate, release)
- `status` (required): New status (pending, in_progress, completed, failed, skipped)
- `data` (optional): Additional phase data as JSON

**Returns:**
```json
{
  "status": "success",
  "operation": "update-phase",
  "phase": "build",
  "phase_status": "in_progress",
  "current_phase": "build"
}
```

**Execution:**
```bash
# With run_id (preferred)
../core/scripts/state-update-phase.sh --run-id "$RUN_ID" "$PHASE" "$STATUS" "$DATA_JSON"

# Legacy
../core/scripts/state-update-phase.sh "$PHASE" "$STATUS" "$DATA_JSON"
```

---

## update-step

Update a step's status within a phase.

**Parameters:**
- `run_id` (optional): Run identifier. If provided, updates per-run state.
- `phase` (required): Phase containing the step
- `step_id` (required): Unique identifier of the step (uses `id` field, falls back to `name` for backward compatibility)
- `status` (required): New status (pending, in_progress, completed, failed, skipped)
- `data` (optional): Step result data

**Returns:**
```json
{
  "status": "success",
  "operation": "update-step",
  "phase": "build",
  "step_id": "implement",
  "step_status": "completed"
}
```

**Execution:**
1. Compute state path from run_id if provided
2. Read current state
3. Find step in phase.steps array by matching `step_id` (check `id` field first, then `name` for backward compatibility)
4. Update step status and data
5. Write state back

**Note:** Step identification uses the `id` field (preferred) or `name` field (deprecated, backward compatible). This ensures consistent step tracking across logging, state management, and step targeting.

---

## record-artifact

Record an artifact in state (spec, branch, PR, etc.).

**Parameters:**
- `run_id` (optional): Run identifier. If provided, updates per-run state.
- `artifact_type` (required): Type of artifact (spec_path, branch_name, pr_url, pr_number, custom)
- `artifact_value` (required): Value to record

**Returns:**
```json
{
  "status": "success",
  "operation": "record-artifact",
  "artifact_type": "branch_name",
  "artifact_value": "feat/123-add-feature"
}
```

**Execution:**
1. Compute state path from run_id if provided
2. Read current state
3. Set `state.artifacts[artifact_type] = artifact_value`
4. Update `updated_at` timestamp
5. Write state back

---

## mark-complete

Mark the workflow as completed or failed.

**Parameters:**
- `run_id` (optional): Run identifier. If provided, updates per-run state.
- `final_status` (required): Final status (completed, failed, cancelled)
- `summary` (optional): Completion summary
- `errors` (optional): Error details if failed

**Returns:**
```json
{
  "status": "success",
  "operation": "mark-complete",
  "final_status": "completed",
  "completed_at": "2025-12-03T11:00:00Z"
}
```

**Execution:**
1. Compute state path from run_id if provided
2. Read current state
3. Set `state.status = final_status`
4. Set `state.completed_at = now()`
5. Add summary/errors if provided
6. Write state back

---

## update-step-progress

Track exact step progress within a phase (for resume support).

**Parameters:**
- `run_id` (optional): Run identifier. If provided, updates per-run state.
- `phase` (required): Current phase being executed
- `current_step_index` (required): Index of the current/next step in the phase
- `steps_completed` (required): Array of step names/IDs that have been completed

**Returns:**
```json
{
  "status": "success",
  "operation": "update-step-progress",
  "phase": "build",
  "current_step_index": 2,
  "steps_completed": ["generate-spec", "create-branch"],
  "resumable": true
}
```

**Execution:**
1. Compute state path from run_id if provided
2. Read current state
3. Set `state.current_phase = phase`
4. Set `state.current_step_index = current_step_index`
5. Set `state.steps_completed = steps_completed`
6. Update `updated_at` timestamp
7. Write state back

**Purpose:**
This operation enables exact-step resume by tracking:
- Which phase we're currently in
- Which step index we're at (0-indexed)
- Which steps have already been completed

When resuming with `--resume`, the executor reads this state and passes it
to faber-manager as `resume_context`, allowing the manager to skip completed
steps and continue from the exact position.

---

## increment-retry

Increment the retry counter for the current phase (for Build-Evaluate loop).

**Parameters:**
- `run_id` (optional): Run identifier. If provided, updates per-run state.
- `phase` (optional): Phase to increment retry for (default: current_phase)

**Returns:**
```json
{
  "status": "success",
  "operation": "increment-retry",
  "phase": "evaluate",
  "retry_count": 2,
  "max_retries": 3,
  "can_retry": true
}
```

**Execution:**
1. Compute state path from run_id if provided
2. Read current state
3. Increment `state.phases[phase].retry_count`
4. Check against max_retries from workflow config
5. Write state back

---

## check-exists

Check if a state file exists for a run or work item.

**Parameters:**
- `run_id` (optional): Run identifier. If provided, checks per-run state.
- `work_id` (optional): Work ID to check (legacy)
- `state_path` (optional): Specific state file path (computed from run_id if provided)

**Returns:**
```json
{
  "status": "success",
  "operation": "check-exists",
  "exists": true,
  "run_id": "fractary/my-project/a1b2c3d4-...",
  "state_path": ".fractary/plugins/faber/runs/fractary/my-project/a1b2c3d4-.../state.json",
  "work_id": "123",
  "current_phase": "build"
}
```

---

## validate-state

Validate state file structure.

**Script:** `../core/scripts/state-validate.sh`

**Parameters:**
- `run_id` (optional): Run identifier. If provided, validates per-run state.
- `state_path` (optional): Path to state file (computed from run_id if provided)

**Returns:**
```json
{
  "status": "success",
  "operation": "validate-state",
  "valid": true,
  "run_id": "fractary/my-project/a1b2c3d4-..."
}
```

---

## backup-state

Create a backup of current state.

**Script:** `../core/scripts/state-backup.sh`

**Parameters:**
- `run_id` (optional): Run identifier. If provided, backs up per-run state.
- `state_path` (optional): Path to state file (computed from run_id if provided)

**Returns:**
```json
{
  "status": "success",
  "operation": "backup-state",
  "backup_path": ".fractary/plugins/faber/runs/fractary/my-project/a1b2c3d4-.../state.json.backup.20251203T110000Z"
}
```

</OPERATIONS>

<WORKFLOW>
When invoked with an operation:

1. **Parse Request**
   - Extract operation name
   - Extract parameters
   - Set default state path if not provided

2. **Execute Operation**
   - Use appropriate script or inline logic
   - For writes: read → modify → write atomically

3. **Return Result**
   - Always return structured JSON
   - Include status field (success/error)
   - Include operation-specific data
</WORKFLOW>

<ERROR_HANDLING>
| Error | Code | Action |
|-------|------|--------|
| State file not found | STATE_NOT_FOUND | Return error (for read operations) or create (for init) |
| Invalid state JSON | STATE_INVALID | Return error with parse details |
| Invalid phase name | INVALID_PHASE | Return error with valid phase names |
| Invalid status | INVALID_STATUS | Return error with valid statuses |
| Write failed | STATE_WRITE_ERROR | Return error, state unchanged |
| Max retries exceeded | MAX_RETRIES | Return with can_retry: false |
</ERROR_HANDLING>

<OUTPUT_FORMAT>
Always output start/end messages for visibility:

```
🎯 STARTING: FABER State
Operation: update-phase
Phase: build
Status: in_progress
───────────────────────────────────────

[... execution ...]

✅ COMPLETED: FABER State
Phase: build → in_progress
Current Phase: build
───────────────────────────────────────
```
</OUTPUT_FORMAT>

<DEPENDENCIES>
- `jq` for JSON parsing and manipulation
- Existing scripts in `../core/scripts/`
</DEPENDENCIES>

<FILE_LOCATIONS>
**With run_id (preferred):**
- **State file**: `.fractary/plugins/faber/runs/{run_id}/state.json`
- **Metadata file**: `.fractary/plugins/faber/runs/{run_id}/metadata.json`
- **Events dir**: `.fractary/plugins/faber/runs/{run_id}/events/`
- **Backup pattern**: `.fractary/plugins/faber/runs/{run_id}/state.json.backup.<timestamp>`

**Legacy (no run_id):**
- **State file**: `.fractary/plugins/faber/state.json`
- **Backup pattern**: `.fractary/plugins/faber/state.json.backup.<timestamp>`

**Helper function to compute state path:**
```bash
get_state_path() {
    local run_id="$1"
    if [ -n "$run_id" ]; then
        echo ".fractary/plugins/faber/runs/$run_id/state.json"
    else
        echo ".fractary/plugins/faber/state.json"
    fi
}
```
</FILE_LOCATIONS>

<IDEMPOTENCY>
State operations are designed for idempotency:
- `init-state`: Only creates if not exists, otherwise returns existing
- `update-phase`: Same status update is a no-op
- `record-artifact`: Overwrites existing value (idempotent)
- `mark-complete`: No-op if already in terminal state
</IDEMPOTENCY>
