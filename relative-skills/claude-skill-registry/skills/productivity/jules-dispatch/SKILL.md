---
name: jules-dispatch
description: |
  Dispatches work to Jules agents via the CLI. Automatically generates context-rich prompts from Beads issues and spawns async sessions. Use when user says "send to jules", "assign to jules", "dispatch task", or "run in cloud".
tags: [workflow, jules, cloud, automation, dx]
allowed-tools:
  - Bash(jules:*)
  - Bash(python:*)
  - Read
  - mcp__plugin_beads_beads__*
---

# Jules Dispatch Skill

**Purpose:** Automate the handoff of Beads issues to Jules agents using the `jules` CLI.

## Activation

**Triggers:**
- "assign this to jules"
- "dispatch bd-123 to jules"
- "start jules session for X"
- "run these in the cloud"

**User provides:** Issue IDs (bd-xyz) OR prompt text.

## Core Workflow

### 1. Context Generation (The "Rich Prompt")
Jules needs the same context guidance as Claude Code Web. We will reuse/adapt the `parallelize-cloud-work` prompt logic.

**Prompt Structure:**
```
TASK: {issue_title} ({issue_id})
CONTEXT:
- Repo: {repo_name}
- Branch: feature-{issue_id}-jules

🚨 INSTRUCTIONS:
1. INVOKE SKILLS: {context_skills}
2. EXPLORE: Check {files_of_interest}
3. PLAN: Don't reimplement existing logic.
4. EXECUTE:
   - Checkout branch feature-{issue_id}-jules
   - Commit with Feature-Key: {issue_id}
   - Push and create PR
```

### 2. Dispatch Logic
The skill will wrap the `jules remote new` command.

**Command Template:**
```bash
jules remote new \
  --repo . \
  --session "{RICH_PROMPT}"
```

### 3. Loop & Parallelize
If multiple issues are provided:
```bash
# pseudocode
for issue_id in provided_issues:
  prompt = generate_rich_prompt(issue_id)
  jules remote new --repo . --session "$prompt"
```

## Workflow

### 1. Execute Dispatch Script

```bash
# Auto-discover from current repo
python ~/.agent/skills/jules-dispatch/dispatch.py

# Dry-run (print commands without executing)
python ~/.agent/skills/jules-dispatch/dispatch.py --dry-run

# Force dispatch specific issue (ignores label check)
python ~/.agent/skills/jules-dispatch/dispatch.py --action dispatch --issue bd-xyz --force
```

### 3. Monitor
Check status of active sessions:

```bash
python ~/.agent/skills/jules-dispatch/dispatch.py --action list
```

### 4. Pull & Apply (The Pull Pattern)
When a session is complete, retrieve the code into a local feature branch:

```bash
python ~/.agent/skills/jules-dispatch/dispatch.py --action pull --session <SESSION_ID>
```

### 2. Mega-Prompt Construction

For each candidate, the skill constructs a rich prompt:

```
TASK: {title} (ID: {issue_id})

DESCRIPTION:
{description}

DESIGN SPEC:
{design field from Beads issue}

----------
TECH PLAN / DOCS:
{Contents of docs/{issue_id}/TECH_PLAN.md if exists}
----------

CRITICAL INSTRUCTIONS:
1. Implement exactly per the DESIGN SPEC above.
2. If the Spec is ambiguous, PAUSE and ask key questions (do not guess).

DEFINITION OF DONE (REQUIRED):
1. Create a reproduction test case (or new unit test).
2. Run `make ci-lite` (or standard test suite) and fix ALL failures.
3. If this is a UI feature, verify no console errors.
4. Your PR description must include a "Verification" section with test logs.
```

### 3. Dispatch to Jules

The skill calls the Jules CLI:

```bash
jules remote new \
  --repo <owner>/<repo> \
  --session "<mega-prompt>"
```

## Usage Examples

### Example 1: Dispatch All Ready Tasks

```bash
# From any repo with Beads
python ~/.agent/skills/jules-dispatch/dispatch.py
```

Output:
```
Found 2 candidates.
🔍 Analyzing bd-4mot: Add Jules Health Check Endpoint...
🚀 Dispatching to Jules...
✅ Dispatched bd-4mot successfully.
🔍 Analyzing bd-ijk: Implement Rate Limiting...
🚀 Dispatching to Jules...
✅ Dispatched bd-ijk successfully.
```

### Example 2: Dry Run

```bash
python ~/.agent/skills/jules-dispatch/dispatch.py --dry-run
```

Output:
```
Found 1 candidates.
🔍 Analyzing bd-4mot: Add Jules Health Check Endpoint...
  [DRY RUN] Would execute:
  jules remote new --repo stars-end/prime-radiant-ai --session "..."
  [Prompt Length]: 842 chars
```

### Example 3: Force Dispatch Specific Issue

```bash
python ~/.agent/skills/jules-dispatch/dispatch.py --action dispatch --issue bd-xyz --force
```

### Example 4: Monitor Progress

```bash
# List active Jules sessions
python ~/.agent/skills/jules-dispatch/dispatch.py --action list

# Pull code from completed session
python ~/.agent/skills/jules-dispatch/dispatch.py --action pull --session 123456

```

## Preparing Issues for Jules

### 1. Add Design Spec

Use Beads to add a design spec:

```
mcp__plugin_beads_beads__update(
  issue_id="bd-xyz",
  design="### Endpoint\nGET /health/jules\n### Response\nJSON: {'status': 'ok'}"
)
```

### 2. Add TECH_PLAN (Optional)

Create detailed context in `docs/{issue_id}/TECH_PLAN.md`:

```markdown
# Tech Plan: bd-xyz

## Overview
...

## Implementation Details
...

## Testing Strategy
...
```

### 3. Apply Label

```
mcp__plugin_beads_beads__update(
  issue_id="bd-xyz",
  labels=["jules-ready"]
)
```

## Environment Setup (Per-Repo)

Each repo needs a `scripts/jules_setup.sh` that Jules runs first:

```bash
#!/bin/bash
# scripts/jules_setup.sh - Bootstraps repo toolchain for Jules

# Install toolchain via mise
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"
mise trust
mise install --yes

# Install dependencies
cd backend && poetry install --no-interaction
cd ../frontend && pnpm install

# Generate mock .env
cat <<EOF > .env
DB_HOST=localhost
USE_MOCK_DATA=true
EOF

echo "✅ Environment ready"
```

Jules configuration in the Jules UI:
- **Setup Script**: `bash scripts/jules_setup.sh`
- **Environment Variables**: Add `RAILWAY_TOKEN` (for database access if needed)

## Integration with Beads

**Before dispatch:**
- Issue must exist in Beads
- Recommended: Add `design` field and/or TECH_PLAN doc
- Apply `jules-ready` label

**After dispatch:**
- Jules creates feature branch: `feature-{issue_id}-jules-{session_id}`
- Jules commits with `Feature-Key: {issue_id}` trailer
- Jules creates PR on completion

**Post-merge cleanup:**
```
mcp__plugin_beads_beads__close(
  issue_id="bd-xyz",
  reason="Completed via Jules: PR#123 merged"
)
```

## CLI Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Print commands without executing |
| `--issue ID` | Dispatch specific issue only |
| `--force` | Ignore `jules-ready` label check |
| `--repo OWNER/NAME` | Override auto-detected repo |

## Troubleshooting

### "No 'jules-ready' tasks found"

Either no issues have the label, or you're not in a Beads-enabled repo.

```bash
# Check Beads is initialized
ls .beads/issues.jsonl

# Check for labeled issues
grep "jules-ready" .beads/issues.jsonl
```

### "'jules' CLI not found"

Install the Jules CLI:

```bash
# Via npm (if packaged)
npm install -g @google/jules-cli

# Or via mise
mise use -g npm:@google/jules-cli
```

### "Failed to dispatch"

Check Jules authentication:

```bash
jules auth status
jules auth login
```

### "Session started but no PR created"

Check Jules session status:

```bash
python ~/.agent/skills/jules-dispatch/dispatch.py --action list
```

## Version History

- **v2.0.0** (2025-12-15): Major upgrade
  - Cross-repo support (works from any Beads-enabled repo)
  - JSONL auto-discovery for jules-ready tasks
  - Rich mega-prompt with TECH_PLAN support
  - Per-repo setup script pattern
  - Centralized in agent-skills

- **v1.0.0** (2025-12-10): Initial implementation
  - Basic dispatch via bd CLI
  - Manual issue ID arguments
