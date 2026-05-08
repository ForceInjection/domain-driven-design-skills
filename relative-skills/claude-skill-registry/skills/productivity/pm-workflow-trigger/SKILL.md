---
name: pm-workflow-trigger
description: Natural language wrapper for PM workflow commands - automatically triggers /pm:epic-start, /pm:issue-start, /pm:prd-parse when users express PM workflow intent
schema_version: 1.0
---

# pm-workflow-trigger

**Type:** WRITE-CAPABLE
**DAIC Modes:** IMPLEMENT only
**Priority:** High

## Trigger Reference

This skill activates on:
- **Keywords:** "start epic", "start issue", "work on epic", "begin issue", "parse PRD", "create PRD", "begin epic", "launch epic", "launch issue", "start working on epic", "start working on issue", "convert PRD"
- **Intent Patterns:** `(start|begin|launch|work on).*(epic|issue)`, `(parse|convert).*?PRD`, `create.*(PRD|product requirements)`, `work.*?on.*(epic|issue)`

From: `skill-rules.json` - pm-workflow-trigger configuration

## Purpose

Automatically trigger PM workflow commands (`/pm:epic-start`, `/pm:issue-start`, `/pm:prd-parse`, `/pm:prd-new`) when users express intent to start work on epics/issues or manage PRDs using natural language. This skill requires IMPLEMENT mode as it creates branches, modifies files, and updates project state.

## Core Behavior

When activated in IMPLEMENT mode with an active cc-sessions task:

1. **Workflow Detection**
   - Detect epic/issue/PRD workflow intent from natural language
   - Examples: "Start working on epic auth-system", "Parse PRD for dashboard"
   - Route to appropriate PM command based on intent

2. **Command Routing**
   - **Epic workflows:** "start epic X" → `/pm:epic-start X`
   - **Issue workflows:** "start issue #123" → `/pm:issue-start 123`
   - **PRD parsing:** "parse PRD X" → `/pm:prd-parse X`
   - **PRD creation:** "create PRD" → `/pm:prd-new`

3. **Execution**
   - Invoke appropriate PM command with extracted arguments
   - Commands create git branches, modify task files, sync with GitHub
   - Return status and next steps to user

## Natural Language Examples

**Triggers this skill:**
- ✓ "Start working on epic auth-system"
- ✓ "Begin issue #456"
- ✓ "Launch epic dashboard-redesign"
- ✓ "Work on issue 789"
- ✓ "Parse PRD for user-profiles"
- ✓ "Convert PRD to epic"
- ✓ "Create new PRD"
- ✓ "Start epic X"

**Does NOT trigger:**
- ✗ "What's the status of epic X?" (status query, not workflow start)
- ✗ "Show issue #123" (info display, not workflow start)
- ✗ "List epics" (listing, not starting work)

## Safety Guardrails

**WRITE-CAPABLE RULES:**
- ✓ Only execute in IMPLEMENT mode
- ✓ Verify active cc-sessions task exists
- ✓ Follow approved manifest/todos
- ✓ Never weaken write-gating or DAIC discipline
- ✓ Confirm git working directory is clean before creating branches

**Workflow Safety:**
- Verify epic/issue exists before starting work
- Check for GitHub sync status before proceeding
- Confirm no uncommitted changes exist
- Create branches from main (unless resuming work)
- Log workflow actions for traceability

## PM Commands Invoked

This skill routes to these PM commands:

| Intent | Command | Purpose |
|--------|---------|---------|
| Start epic | `/pm:epic-start <name>` | Create branch, launch parallel agents for epic tasks |
| Start issue | `/pm:issue-start <number>` | Begin work on GitHub issue |
| Parse PRD | `/pm:prd-parse <name>` | Convert PRD into epic with tasks |
| Create PRD | `/pm:prd-new` | Generate new product requirements document |

## Implementation Notes

This skill acts as a natural language wrapper around PM workflow commands. The actual PM logic lives in `.claude/commands/pm/*` files, which:
- Manage epic/issue lifecycle
- Sync with GitHub issues
- Create and manage git branches
- Coordinate parallel work streams
- Track task status and progress

This skill simply detects the intent, extracts arguments, and routes to the appropriate PM command with write-gating enforcement.
