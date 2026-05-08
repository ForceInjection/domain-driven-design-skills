---
name: run-manager
description: Manage FABER workflow run lifecycle - create, query, resume, rerun runs
model: claude-opus-4-5
---

# FABER Run Manager Skill

<CONTEXT>
You are the **Run Manager Skill** for the FABER plugin. You manage the lifecycle of workflow runs, including:
- Generating unique run IDs
- Initializing run directories and state
- Emitting workflow events
- Supporting resume and rerun operations
- Querying run history and events

Every FABER workflow execution is a "run" identified by a unique run_id in the format:
`{org}/{project}/{uuid}`

This enables:
- Parallel execution without conflicts
- Step-level resume from failures
- Re-run with parameter changes
- Complete audit trail via events
</CONTEXT>

<CRITICAL_RULES>
**YOU MUST:**
1. Always generate run_id before any workflow execution
2. Initialize run directory before emitting events
3. Use atomic writes for state updates
4. Validate run_id format before operations
5. Emit events through the gateway (not directly)

**YOU MUST NOT:**
1. Allow multiple runs to share the same run_id
2. Modify events after they're written
3. Skip event sequence numbers
4. Delete run directories without archival
</CRITICAL_RULES>

<OPERATIONS>

## generate-id

Generate a new unique run identifier.

**Script:** `scripts/generate-run-id.sh`

**Parameters:**
- `org` (optional): Organization name (auto-detected from git)
- `project` (optional): Project name (auto-detected from git)

**Returns:**
```json
{
  "status": "success",
  "operation": "generate-id",
  "run_id": "fractary/claude-plugins/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

**Usage:**
```bash
RUN_ID=$(scripts/generate-run-id.sh)
```

---

## init-run

Initialize a new run directory with state and metadata.

**Script:** `scripts/init-run-directory.sh`

**Parameters:**
- `run_id` (required): Full run identifier
- `work_id` (required): Work item ID
- `target` (optional): Target artifact name
- `workflow` (optional): Workflow ID (default: "default")
- `autonomy` (optional): Autonomy level (default: "guarded")
- `phases` (optional): Comma-separated phases to execute
- `parent_run` (optional): Parent run ID (for resume)
- `rerun_of` (optional): Original run ID (for rerun)

**Returns:**
```json
{
  "status": "success",
  "operation": "init-run-directory",
  "run_id": "fractary/claude-plugins/a1b2c3d4-...",
  "run_dir": ".fractary/plugins/faber/runs/fractary/claude-plugins/a1b2c3d4-...",
  "work_id": "220",
  "files_created": [
    ".../metadata.json",
    ".../state.json",
    ".../events/.next-id"
  ]
}
```

**Creates:**
```
.fractary/plugins/faber/runs/{run_id}/
├── state.json         # Workflow state
├── metadata.json      # Run parameters and context
└── events/
    └── .next-id       # Event sequence counter
```

---

## emit-event

Emit a workflow event to the run's event log.

**Script:** `scripts/emit-event.sh`

**Parameters:**
- `run_id` (required): Run identifier
- `type` (required): Event type (see Event Types)
- `phase` (optional): Current phase
- `step` (optional): Current step
- `status` (optional): Event status
- `message` (optional): Human-readable message
- `data` (optional): JSON metadata
- `artifacts` (optional): JSON array of artifacts

**Event Types:**
- Workflow: `workflow_start`, `workflow_complete`, `workflow_error`, `workflow_cancelled`, `workflow_resumed`, `workflow_rerun`
- Phase: `phase_start`, `phase_skip`, `phase_complete`, `phase_error`
- Step: `step_start`, `step_complete`, `step_error`, `step_retry`
- Artifacts: `artifact_create`, `artifact_modify`
- Git: `commit_create`, `branch_create`, `pr_create`, `pr_merge`
- Other: `checkpoint`, `skill_invoke`, `decision_point`, `retry_loop_enter`, `retry_loop_exit`

**Returns:**
```json
{
  "status": "success",
  "operation": "emit-event",
  "event_id": 15,
  "type": "step_complete",
  "run_id": "...",
  "timestamp": "2025-12-04T10:15:00Z",
  "event_path": ".../events/015-step_complete.json"
}
```

---

## get-run

Get run metadata and current state.

**Script:** `scripts/get-run.sh`

**Parameters:**
- `run_id` (required): Run identifier
- `include_events` (optional): Include event count (default: false)

**Returns:**
```json
{
  "status": "success",
  "operation": "get-run",
  "run_id": "...",
  "metadata": { ... },
  "state": { ... },
  "event_count": 45
}
```

---

## list-runs

List runs for a project or work item.

**Script:** `scripts/list-runs.sh`

**Parameters:**
- `work_id` (optional): Filter by work item
- `status` (optional): Filter by status (pending, running, completed, failed)
- `limit` (optional): Max results (default: 20)
- `org` (optional): Organization filter
- `project` (optional): Project filter

**Returns:**
```json
{
  "status": "success",
  "operation": "list-runs",
  "runs": [
    {
      "run_id": "...",
      "work_id": "220",
      "status": "completed",
      "created_at": "2025-12-04T10:00:00Z",
      "completed_at": "2025-12-04T11:30:00Z"
    }
  ],
  "total": 5
}
```

---

## resume-run

Prepare a run for resumption from failure point.

**Script:** `scripts/resume-run.sh`

**Parameters:**
- `run_id` (required): Run to resume

**Returns:**
```json
{
  "status": "success",
  "operation": "resume-run",
  "run_id": "...",
  "resumable": true,
  "resume_from": {
    "phase": "build",
    "step": "implement",
    "event_id": 12
  },
  "completed_phases": ["frame", "architect"],
  "completed_steps": {
    "build": ["setup"]
  }
}
```

**Validation:**
- Run must exist
- Run must not be completed
- Run must not be archived

---

## rerun-run

Create a new run based on an existing run with optional parameter changes.

**Script:** `scripts/rerun-run.sh`

**Parameters:**
- `run_id` (required): Original run to rerun
- `work_id` (optional): Override work_id
- `autonomy` (optional): Override autonomy level
- `phases` (optional): Override phases

**Returns:**
```json
{
  "status": "success",
  "operation": "rerun-run",
  "original_run_id": "...",
  "new_run_id": "fractary/claude-plugins/new-uuid-...",
  "parameter_changes": {
    "autonomy": { "from": "guarded", "to": "autonomous" }
  }
}
```

---

## reconstruct-state

Rebuild state.json from event history (for corruption recovery).

**Script:** `scripts/reconstruct-state.sh`

**Parameters:**
- `run_id` (required): Run to reconstruct
- `dry_run` (optional): Show changes without applying

**Returns:**
```json
{
  "status": "success",
  "operation": "reconstruct-state",
  "run_id": "...",
  "events_processed": 45,
  "state_diff": { ... },
  "applied": true
}
```

---

## consolidate-events

Consolidate event files to JSONL for archival.

**Script:** `scripts/consolidate-events.sh`

**Parameters:**
- `run_id` (required): Run to consolidate
- `output` (optional): Output path (default: events.jsonl in run dir)

**Returns:**
```json
{
  "status": "success",
  "operation": "consolidate-events",
  "run_id": "...",
  "events_consolidated": 45,
  "output_path": ".../events.jsonl",
  "size_bytes": 15234
}
```

</OPERATIONS>

<WORKFLOW>
When invoked with an operation:

1. **Parse Request**
   - Extract operation name
   - Validate required parameters
   - Set defaults for optional parameters

2. **Validate Context**
   - For operations requiring run_id: validate format
   - For write operations: check run exists and is writable
   - For resume/rerun: validate eligibility

3. **Execute Operation**
   - Call appropriate script
   - Handle errors with recovery guidance

4. **Return Result**
   - Always return structured JSON
   - Include status field (success/error)
   - Include operation-specific data
</WORKFLOW>

<ERROR_HANDLING>
| Error | Code | Recovery |
|-------|------|----------|
| Run not found | RUN_NOT_FOUND | Check run_id, use list-runs |
| Run already exists | RUN_EXISTS | Use existing or generate new ID |
| Invalid run_id format | INVALID_RUN_ID | Use generate-id |
| Run not resumable | NOT_RESUMABLE | Check run status |
| Event write failed | EVENT_WRITE_ERROR | Check disk space, retry |
| State corruption | STATE_CORRUPTED | Use reconstruct-state |
</ERROR_HANDLING>

<OUTPUT_FORMAT>
```
🎯 STARTING: Run Manager
Operation: {operation}
Run ID: {run_id}
───────────────────────────────────────

[... execution ...]

✅ COMPLETED: Run Manager
{operation-specific summary}
───────────────────────────────────────
```
</OUTPUT_FORMAT>

<DIRECTORY_STRUCTURE>
```
.fractary/plugins/faber/runs/
└── {org}/
    └── {project}/
        └── {uuid}/
            ├── state.json         # Current workflow state
            ├── metadata.json      # Run parameters & context
            └── events/
                ├── .next-id       # Sequence counter
                ├── 001-workflow_start.json
                ├── 002-phase_start.json
                ├── ...
                └── 045-workflow_complete.json
```
</DIRECTORY_STRUCTURE>

<STATE_SCHEMA>
```json
{
  "run_id": "org/project/uuid",
  "work_id": "220",
  "workflow_version": "2.1",
  "status": "in_progress",
  "current_phase": "build",
  "last_event_id": 15,
  "started_at": "2025-12-04T10:00:00Z",
  "updated_at": "2025-12-04T10:30:00Z",
  "completed_at": null,
  "phases": {
    "frame": {"status": "completed", "steps": [...]},
    "architect": {"status": "completed", "steps": [...]},
    "build": {"status": "in_progress", "steps": [...]},
    "evaluate": {"status": "pending", "steps": [], "retry_count": 0},
    "release": {"status": "pending", "steps": []}
  },
  "artifacts": {
    "spec_path": "specs/SPEC-00108.md",
    "branch": "feat/220-run-id-system"
  },
  "errors": []
}
```
</STATE_SCHEMA>

<METADATA_SCHEMA>
```json
{
  "run_id": "org/project/uuid",
  "work_id": "220",
  "target": "run-id-system",
  "workflow_id": "default",
  "autonomy": "guarded",
  "source_type": "github",
  "phases": ["frame", "architect", "build", "evaluate", "release"],
  "created_at": "2025-12-04T10:00:00Z",
  "created_by": "developer",
  "relationships": {
    "parent_run_id": null,
    "rerun_of": null,
    "child_runs": []
  },
  "environment": {
    "hostname": "dev-machine",
    "git_branch": "feat/220-run-id-system",
    "git_commit": "abc123...",
    "working_directory": "/path/to/project"
  }
}
```
</METADATA_SCHEMA>

<INTEGRATION>
## Used By
- `faber-director`: Generates run_id, initializes run
- `faber-manager`: Emits events, updates state
- `faber:run` command: Resume and rerun operations

## Interacts With
- `faber-state` skill: State updates go through run-manager
- MCP Event Gateway: Events routed through gateway
- S3 Archive: Consolidated events archived to S3
</INTEGRATION>
