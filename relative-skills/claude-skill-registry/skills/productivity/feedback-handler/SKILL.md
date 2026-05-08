---
name: feedback-handler
description: Handles FABER workflow feedback requests - posting to issues and tracking responses
model: claude-opus-4-5
---

# Feedback Handler Skill

<CONTEXT>
You are the feedback-handler skill responsible for managing human-in-the-loop (HITL) feedback requests in FABER workflows. You handle:

1. **Posting feedback requests** to issue comments when feedback is needed
2. **Tracking feedback state** in run state files
3. **Formatting feedback requests** with clear context and options

You work with the work plugin (comment-creator) to post comments and the run-manager to update state.
</CONTEXT>

<CRITICAL_RULES>
1. ALWAYS emit decision_point event when requesting feedback
2. ALWAYS update run state with feedback_request details
3. ALWAYS format feedback comments with clear context and options
4. ALWAYS include example @faber command in issue comments (for future integration)
5. NEVER post feedback request without updating state first
6. ALWAYS track notification_sent status in state
</CRITICAL_RULES>

<INPUTS>
## request-feedback operation

Request feedback from user and optionally post to issue.

```json
{
  "operation": "request-feedback",
  "parameters": {
    "run_id": "fractary/claude-plugins/abc-123-...",
    "work_id": "258",
    "phase": "architect",
    "step": "design-review",
    "feedback_type": "approval",
    "prompt": "Please review the architectural design and approve to proceed.",
    "options": ["approve", "reject", "request_changes"],
    "context": {
      "artifact_path": "/specs/WORK-00258-design.md",
      "summary": "Design proposes 3-layer architecture with handler pattern"
    },
    "post_to_issue": true,
    "cli_prompt": true
  }
}
```

**Parameters:**
- `run_id` (required): FABER run identifier
- `work_id` (optional): Issue ID for posting comment
- `phase` (required): Current workflow phase
- `step` (required): Current workflow step
- `feedback_type` (required): Type of feedback (see FEEDBACK_TYPES)
- `prompt` (required): Human-readable question/request
- `options` (required): Array of valid response options
- `context` (optional): Additional context for the decision
- `post_to_issue` (optional, default: true if work_id present): Post as issue comment
- `cli_prompt` (optional, default: true): Show prompt in CLI

## process-response operation

Process a feedback response and update state.

```json
{
  "operation": "process-response",
  "parameters": {
    "run_id": "fractary/claude-plugins/abc-123-...",
    "request_id": "fr-20251206-001",
    "response": "approve",
    "comment": "Looks good, proceed with implementation",
    "source": "cli",
    "user": "jmcwilliam"
  }
}
```
</INPUTS>

<FEEDBACK_TYPES>
| Type | Description | Default Options |
|------|-------------|-----------------|
| `approval` | Binary approval decision | ["approve", "reject"] |
| `confirmation` | Confirm destructive action | ["confirm", "cancel"] |
| `selection` | Choose from options | [custom list required] |
| `clarification` | Request information | [free text accepted] |
| `review` | Review with feedback option | ["approve", "request_changes", "reject"] |
| `error_resolution` | Error occurred, decide action | ["retry", "skip", "abort"] |
</FEEDBACK_TYPES>

<WORKFLOW>
## request-feedback Operation

1. **Generate request ID**
   ```
   request_id = "fr-" + timestamp + "-" + short_uuid
   Example: fr-20251206-a1b2c3
   ```

2. **Build feedback request object**
   ```json
   {
     "request_id": "fr-20251206-a1b2c3",
     "type": "approval",
     "prompt": "Please review the design...",
     "options": ["approve", "reject", "request_changes"],
     "context": { ... },
     "requested_at": "2025-12-06T18:00:00Z",
     "notification_sent": {
       "cli": false,
       "issue_comment": false,
       "comment_url": null
     }
   }
   ```

3. **Emit decision_point event**
   ```bash
   plugins/faber/skills/run-manager/scripts/emit-event.sh \
     --run-id "{run_id}" \
     --type "decision_point" \
     --phase "{phase}" \
     --step "{step}" \
     --message "Awaiting feedback: {prompt}" \
     --metadata '{"request_id": "{request_id}", "type": "{feedback_type}", "options": {options}}'
   ```

4. **Update run state**
   ```json
   {
     "status": "awaiting_feedback",
     "current_phase": "{phase}",
     "current_step": "{step}",
     "feedback_request": { ... request object ... },
     "resume_point": {
       "phase": "{phase}",
       "step": "{step}",
       "step_index": {current_step_index}
     }
   }
   ```

5. **Post to issue** (if work_id present and post_to_issue=true)
   - Use comment-creator skill
   - Format using ISSUE_COMMENT_TEMPLATE
   - Store comment_url in notification_sent

6. **Show CLI prompt** (if cli_prompt=true)
   - Use AskUserQuestion tool
   - Present options from feedback_request

7. **Return request details**
   ```json
   {
     "status": "success",
     "operation": "request-feedback",
     "result": {
       "request_id": "fr-20251206-a1b2c3",
       "state_updated": true,
       "notifications": {
         "cli": true,
         "issue_comment": true,
         "comment_url": "https://..."
       }
     }
   }
   ```

## process-response Operation

1. **Load current state**
   - Verify status is "awaiting_feedback"
   - Verify request_id matches pending request

2. **Validate response**
   - Check response is in options list (or accept free text for clarification type)

3. **Emit feedback_received event**
   ```bash
   plugins/faber/skills/run-manager/scripts/emit-event.sh \
     --run-id "{run_id}" \
     --type "feedback_received" \
     --phase "{phase}" \
     --step "{step}" \
     --message "Feedback received: {response}" \
     --metadata '{"request_id": "{request_id}", "response": "{response}", "user": "{user}", "source": "{source}"}'
   ```

4. **Update state**
   - Clear feedback_request
   - Set status to "in_progress"
   - Add to feedback_history array

5. **Return processed response**
   ```json
   {
     "status": "success",
     "operation": "process-response",
     "result": {
       "request_id": "fr-20251206-a1b2c3",
       "response": "approve",
       "action": "continue",
       "resume_point": { ... }
     }
   }
   ```
</WORKFLOW>

<ISSUE_COMMENT_TEMPLATE>
When posting feedback requests to GitHub issues:

```markdown
## Feedback Requested

**Workflow Run**: `{run_id}`
**Phase**: {phase}
**Step**: {step}
**Requested**: {timestamp} UTC

### Decision Needed

{prompt}

{#if context.summary}
**Summary**:
{context.summary}
{/if}

{#if context.artifact_path}
**Artifact**: [{artifact_filename}]({context.artifact_path})
{/if}

### Options

{#each options}
{index}. **{option}** - {option_description}
{/each}

### How to Respond

Reply to this issue with your decision. Include `@faber resume` in your comment to trigger workflow continuation.

**Example response:**
```
I approve this design. The approach looks good.

@faber resume
```

---
_This feedback request will remain open until addressed._
_Run ID: `{run_id}` | Request ID: `{request_id}`_
```

**Option Descriptions** (based on type):

For `approval`:
- approve: Continue to next phase
- reject: Cancel this workflow run

For `review`:
- approve: Continue to next phase
- request_changes: Provide feedback for revision
- reject: Cancel this workflow run

For `error_resolution`:
- retry: Attempt the step again
- skip: Skip this step and continue
- abort: Cancel this workflow run

For `confirmation`:
- confirm: Proceed with the action
- cancel: Do not proceed
</ISSUE_COMMENT_TEMPLATE>

<OUTPUTS>
## request-feedback Success

```json
{
  "status": "success",
  "operation": "request-feedback",
  "message": "Feedback request created",
  "details": {
    "request_id": "fr-20251206-a1b2c3",
    "type": "approval",
    "phase": "architect",
    "step": "design-review"
  },
  "notifications": {
    "cli": true,
    "issue_comment": true,
    "comment_url": "https://github.com/fractary/claude-plugins/issues/258#issuecomment-xyz"
  }
}
```

## process-response Success

```json
{
  "status": "success",
  "operation": "process-response",
  "message": "Feedback processed: approve",
  "details": {
    "request_id": "fr-20251206-a1b2c3",
    "response": "approve",
    "action": "continue",
    "resume_point": {
      "phase": "architect",
      "step": "design-review"
    }
  }
}
```
</OUTPUTS>

<ERROR_HANDLING>
| Error | Code | Action |
|-------|------|--------|
| Missing run_id | 1 | Return error, cannot proceed |
| Invalid feedback_type | 2 | Return error, list valid types |
| State not awaiting_feedback | 3 | Return error, nothing to process |
| Request ID mismatch | 4 | Return error, may be stale request |
| Invalid response option | 5 | Re-prompt with valid options |
| Issue comment failed | 6 | Warn but continue (non-critical) |
| State update failed | 7 | Return error (critical) |
</ERROR_HANDLING>

<COMPLETION_CRITERIA>
**request-feedback complete when:**
- Decision_point event emitted
- State updated to awaiting_feedback
- Notification sent (CLI and/or issue comment)
- Request details returned

**process-response complete when:**
- Response validated
- Feedback_received event emitted
- State updated to in_progress
- Action determined and returned
</COMPLETION_CRITERIA>

<DOCUMENTATION>
## Start/End Messages

**request-feedback Start:**
```
🎯 STARTING: Feedback Handler (request-feedback)
Run ID: fractary/claude-plugins/abc-123-...
Type: approval
Phase: architect
Step: design-review
───────────────────────────────────────
```

**request-feedback End:**
```
✅ COMPLETED: Feedback Handler (request-feedback)
Request ID: fr-20251206-a1b2c3
Notifications: CLI ✓, Issue Comment ✓
Comment URL: https://github.com/...
───────────────────────────────────────
Status: awaiting_feedback
Next: User must provide feedback to continue
```

**process-response Start:**
```
🎯 STARTING: Feedback Handler (process-response)
Request ID: fr-20251206-a1b2c3
Response: approve
───────────────────────────────────────
```

**process-response End:**
```
✅ COMPLETED: Feedback Handler (process-response)
Action: continue
Resume Point: architect:design-review
───────────────────────────────────────
Next: Workflow will resume from design-review
```

## Integration Points

**Called By:**
- faber-manager agent (at autonomy gates)
- faber-manager agent (on step failure for error_resolution)

**Invokes:**
- run-manager scripts (emit-event.sh)
- comment-creator skill (for issue comments)

**State Files:**
- Reads/Writes: `.fractary/plugins/faber/runs/{run_id}/state.json`

**Scripts:**
- `scripts/generate-request-id.sh` - Generate unique feedback request ID
- `scripts/format-feedback-comment.sh` - Format feedback request as markdown
- `scripts/update-feedback-state.sh` - Update run state with feedback details

## Script Usage

### generate-request-id.sh

```bash
# Generate a new request ID
./scripts/generate-request-id.sh
# Output: fr-20251206-a1b2c3
```

### format-feedback-comment.sh

```bash
./scripts/format-feedback-comment.sh \
  --run-id "fractary/claude-plugins/abc-123" \
  --request-id "fr-20251206-a1b2c3" \
  --type "approval" \
  --phase "architect" \
  --step "design-review" \
  --prompt "Please review the design" \
  --options '["approve", "reject"]' \
  --context '{"summary": "3-layer architecture"}'
# Outputs formatted markdown comment to stdout
```

### update-feedback-state.sh

```bash
# Set awaiting_feedback status
./scripts/update-feedback-state.sh \
  --run-id "fractary/claude-plugins/abc-123" \
  --operation set-awaiting \
  --request-id "fr-20251206-a1b2c3" \
  --type "approval" \
  --prompt "Please review" \
  --options '["approve", "reject"]' \
  --phase "architect" \
  --step "design-review"

# Clear awaiting status after feedback
./scripts/update-feedback-state.sh \
  --run-id "fractary/claude-plugins/abc-123" \
  --operation clear-awaiting \
  --phase "architect" \
  --step "design-review"

# Add to feedback history
./scripts/update-feedback-state.sh \
  --run-id "fractary/claude-plugins/abc-123" \
  --operation add-history \
  --request-id "fr-20251206-a1b2c3" \
  --type "approval" \
  --response "approve" \
  --user "jmcwilliam" \
  --source "cli"
```

## Comment-Creator Integration

To post feedback request to issue:

```markdown
Invoke Skill: fractary-work:comment-creator
Operation: create-comment
Parameters:
  issue_id: "{work_id}"
  message: "{formatted_markdown}"  # From format-feedback-comment.sh output
  author_context: "ops"
```

The comment-creator returns `comment_url` which should be stored in the run state via `update-feedback-state.sh --comment-url`.
</DOCUMENTATION>
