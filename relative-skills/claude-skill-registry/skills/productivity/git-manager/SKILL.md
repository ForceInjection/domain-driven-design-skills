---
name: git-manager
description: Commit implementation changes to git with interactive branch selection and push confirmation. Use after completing implementation tasks, when all TODOs are marked complete, or when user requests to commit changes.
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion, EnterPlanMode
---

# Git Manager

Interactive git commit workflow with safety checks and user confirmation.

## Python Automation Scripts

This skill includes Python scripts for consistent automation. Invoke via:

```bash
uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts --format json <subcommand> [args]
```

### Available Subcommands

| Command | Description | Exit Codes |
|---------|-------------|------------|
| `identity` | Detect git identity (env → gh → SSH) | 0=found, 2=needs-input |
| `message` | Generate commit message from plans | 0=success, 1=no-changes |
| `auth-check` | Check remote authentication | 0=authenticated, 1=needs-auth |
| `sensitive-scan` | Scan for sensitive files | 0=clear, 1=found |
| `clean-locks` | Remove stale git lock files | 0=cleaned, 1=error |

### Example: Identity Detection

```bash
IDENTITY=$(uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts --format json identity --env-path ${CLAUDE_PATH}/.env)

# Parse: detected, source, name, email, needs_input
```

### Example: Auth Check (HTTPS + gh)

```bash
AUTH=$(uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts --format json auth-check)

# If needs_auth=true for HTTPS GitHub, guidance shows:
# "Run: gh auth login --git-protocol https --web"
```

### Example: Commit Message Generation

```bash
MSG=$(uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts --format json message \
  --plans-dir "$(pwd)/plans" \
  --claude-plans-dir ${CLAUDE_PATH}/plans)

# Returns: type, scope, subject, body, full_message, plan_reference, session_stats
```

### Example: Sensitive File Scan

```bash
SENSITIVE=$(uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts --format json sensitive-scan)

# If found=true, files[] contains detected sensitive files
```

### Example: Lock File Cleanup

```bash
# Clean stale locks (>5 seconds old) - run before git operations
uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts --format json clean-locks

# Force remove all locks regardless of age
uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts --format json clean-locks --force

# Returns: cleaned, files_removed[], files_skipped[], error
```

## Activation Triggers

- All plan TODOs marked complete (invoked via DIRECTIVE 040)
- User says "commit changes", "commit my work", "save to git"
- User explicitly invokes: "use the git-manager skill"

## Workflow

### Step 0: Git Identity Configuration

Before any git operations, ensure git identity is configured using this detection cascade:

#### 0.1 Load from .env (preferred)

```bash
source ${CLAUDE_PATH}/.env 2>/dev/null || true

if [ -n "$GIT_USER_EMAIL" ] && [ -n "$GIT_USER_NAME" ]; then
  git config user.email "$GIT_USER_EMAIL"
  git config user.name "$GIT_USER_NAME"
  # Identity configured, proceed silently to Step 1
fi
```

#### 0.2 Auto-detect from SSH (if .env empty)

If `.env` lacks credentials, attempt SSH-based detection:

```bash
# Extract GitHub username from SSH authentication
GIT_USER_NAME=$(ssh -T git@github.com 2>&1 | grep -oP 'Hi \K[^!]+' || echo "")

# Derive email using GitHub's noreply pattern
if [ -n "$GIT_USER_NAME" ]; then
  GIT_USER_EMAIL="${GIT_USER_NAME}@users.noreply.github.com"
fi
```

#### 0.3 Confirm detected values

If SSH detection succeeded, present to user via AskUserQuestion:

```json
{
  "question": "Git identity detected from SSH. Use these values?",
  "header": "Git ID",
  "options": [
    {"label": "Yes, use detected", "description": "{name} <{email}>"},
    {"label": "Enter custom", "description": "I'll ask for your preferred email/name"}
  ],
  "multiSelect": false
}
```

- If "Yes, use detected": Configure git and persist to .env
- If "Enter custom": Ask for free-form email/name (plain text per DIRECTIVE 080 exception)

#### 0.4 Persist to .env

After confirmation, append credentials to `${CLAUDE_PATH}/.env`:

```bash
echo "GIT_USER_NAME=${GIT_USER_NAME}" >> ${CLAUDE_PATH}/.env
echo "GIT_USER_EMAIL=${GIT_USER_EMAIL}" >> ${CLAUDE_PATH}/.env
```

#### 0.5 Fallback (no SSH)

If SSH detection fails (no keys, no GitHub access):
- Ask user for email and name using plain text (free-form input exception)
- Persist to `.env` after receiving values
- Configure git and proceed

### Step 1: Status Check

Run `git status` to detect changes:

- If no changes: Inform user "No uncommitted changes detected" and exit
- If changes exist: Proceed to Step 1.5

### Step 1.5: Mode Selection

Use AskUserQuestion to present commit mode options:

```json
{
  "question": "How would you like to commit?",
  "header": "Mode",
  "options": [
    {"label": "Commit & Plan (Recommended)", "description": "Commit to current branch, skip push, enter plan mode"},
    {"label": "Auto commit & push", "description": "Generate message, commit to current branch, push immediately"},
    {"label": "Interactive", "description": "Review changes, confirm branch, edit message"},
    {"label": "Cancel", "description": "Exit without committing"}
  ],
  "multiSelect": false
}
```

#### Commit & Plan Mode

When "Commit & Plan (Recommended)" selected:

1. Run lock cleanup (Step 4.6)
2. Run sensitive file detection - if found, fall back to Interactive mode
3. Auto-generate commit message using conventional commit format
4. Display summary: show `git diff --stat` and generated message
5. Stage all changes: `git add -A`
6. Commit with generated message
7. Skip push confirmation entirely
8. Invoke `EnterPlanMode` immediately
9. **STOP** - Do NOT ask follow-up questions. Wait silently for user input.

This is the recommended workflow for iterative development - commit your work and immediately enter plan mode. The user will provide the next task when ready.

**CRITICAL**: Unlike Auto and Interactive modes, Commit & Plan does NOT proceed to Step 7 (What's next?). The workflow ends after invoking EnterPlanMode.

#### Auto Mode

When "Auto commit & push" selected:

1. Use current branch (skip branch selection)
2. Run sensitive file detection - if found, fall back to Interactive mode
3. Auto-generate commit message using conventional commit format
4. Display summary: show `git diff --stat` and generated message
5. Stage all changes: `git add -A`
6. Commit with generated message
7. Push immediately: `git push origin {current_branch}`
8. Proceed to Step 7 (What's next?)

#### Interactive Mode

When "Interactive" selected:
- Continue to Step 2 (full interactive workflow)

#### Cancel

When "Cancel" selected:
- Exit without committing

### Step 2: Branch Selection (Interactive Mode Only)

Use AskUserQuestion to present branch options:

- Current branch: {current_branch_name}
- Create new branch (I'll ask for name)
- Cancel commit

If "Create new branch" selected:

- Ask for branch name using AskUserQuestion
- Create and checkout: `git checkout -b {branch_name}`

### Step 3: Review Changes

Display summary of changes:

- Run `git diff --stat` to show file changes
- List modified, new, and deleted files

### Step 4: Generate Commit Message

#### 4.1 Context Gathering

Gather information from multiple sources:

1. **Plan file** (if exists): Read from `{CWD}/plans/` or `.claude/plans/`
   - Extract summary section
   - Extract completed TODO items
   - Note the problem statement if present
2. **Conversation context**: Review recent implementation discussion
3. **File changes**: Analyze `git diff --stat` for scope

#### 4.2 Commit Message Template

Generate commit message using this professional format:

```markdown
{type}({scope}): {short-summary}

## Summary

{2-3 sentence description of what was implemented and why}

## Changes

- {bullet point for each significant change}
- {grouped by logical category if many changes}

## Plan Reference

{If plan file exists: "Implementation of: {plan-topic}"}
{Optional: Link to related issue/ticket if mentioned}

## Files Modified

{count} files changed

## Session Statistics

- **Tokens**: {input} input / {output} output
- **Cache**: {cache_read} read / {cache_created} created
- **Cost**: ${estimated_cost}
- **Duration**: {session_duration}
- **API Calls**: {api_call_count}
- **Tool Calls**: {tool_call_count}
- **Model**: {model_name}
```

> **Note**: Session statistics are automatically extracted from Claude Code transcripts
> and included in every commit message. Statistics may be omitted if the transcript
> is unavailable.

#### 4.3 Conventional Commit Types

- `feat:` - New features or capabilities
- `fix:` - Bug fixes
- `docs:` - Documentation changes only
- `refactor:` - Code restructuring without behavior change
- `chore:` - Maintenance, dependencies, config
- `test:` - Adding or updating tests
- `perf:` - Performance improvements
- `style:` - Formatting, whitespace (no logic change)

#### 4.4 Scope Inference

Infer scope from changed files:
- `auth` - Authentication related
- `api` - API endpoints
- `ui` - User interface
- `db` - Database/models
- `config` - Configuration
- `skill` - Claude skill files
- `agent` - Claude agent files
- `hook` - Claude hook files

#### 4.5 Confirmation

Use AskUserQuestion to confirm or edit:

- Accept this message
- Edit message (I'll ask for new text)
- Cancel commit

### Step 4.6: Lock Cleanup (Automatic)

Before staging, clean any stale git lock files to prevent "index.lock exists" errors:

```bash
uv run --directory ${CLAUDE_SKILLS_PATH}/git-manager \
  python -m scripts clean-locks --force
```

This handles:
- Crashed git processes that left stale locks
- Submodule lock files (`.git/modules/*/index.lock`)
- Prevents common "Another git process seems to be running" errors

### Step 5: Stage and Commit

1. Stage all changes: `git add -A`
2. Commit with message using HEREDOC format:

```bash
git commit -m "$(cat <<'EOF'
{commit_message}
EOF
)"
```

### Step 6: Push Confirmation

#### 6.1 Pre-Push Authentication Check

Before offering push options, verify authentication based on remote URL:

```bash
# Get remote URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

# Check if HTTPS GitHub URL
if [[ "$REMOTE_URL" == https://github.com/* ]]; then
  # Verify GitHub CLI authentication
  if ! gh auth status &>/dev/null; then
    # Not authenticated - inform user
    echo "HTTPS remote detected but GitHub CLI not authenticated"
    echo "Run: gh auth login"
    # Do NOT suggest changing remote URL
    # Exit push flow, keep commit local
  fi
fi
```

**CRITICAL**: If HTTPS authentication fails:
- Inform user to run `gh auth login`
- Keep commit local (do not push)
- **NEVER suggest changing the remote URL to SSH**

#### 6.2 Push Confirmation

If authentication verified (or SSH remote), use AskUserQuestion:

- Yes, push to origin/{branch}
- No, keep local only

If yes: `git push -u origin {branch}` (use -u for new branches)

### Step 7: Workflow Completion

**CRITICAL:** After presenting next action options and receiving user selection, you MUST invoke `EnterPlanMode`. This is mandatory for ALL selections - do not skip this step.

After commit is complete (whether pushed or kept local), present next action options.

Use AskUserQuestion:

```json
{
  "question": "What would you like to do next?",
  "header": "Next",
  "options": [
    {"label": "Done for now", "description": "Enter plan mode for next task"},
    {"label": "Plan next feature", "description": "Define new functionality to build"},
    {"label": "Plan bug fix", "description": "Identify and fix an issue"},
    {"label": "Plan refactoring", "description": "Improve existing code structure"},
    {"label": "Plan documentation", "description": "Update or create documentation"}
  ],
  "multiSelect": false
}
```

| Selection | Action |
|-----------|--------|
| Done for now | Invoke EnterPlanMode |
| Plan next feature | Invoke EnterPlanMode |
| Plan bug fix | Invoke EnterPlanMode |
| Plan refactoring | Invoke EnterPlanMode |
| Plan documentation | Invoke EnterPlanMode |

**All selections invoke EnterPlanMode.** The skill always exits to plan mode for the next task.

## Safety Rules

**NEVER**:

- **Modify git remote URLs** (NEVER change between HTTPS/SSH - this is CRITICAL)
- Force push (`--force`, `-f`)
- Skip hooks (`--no-verify`)
- Commit files matching these patterns:
  - `.env`, `.env.*` (except `.env.example`)
  - `*credentials*`, `*secret*`, `*.pem`, `*.key`
  - `aws-exports.js`
  - Files in `.gitignore`
- Amend commits not created in this session
- Push to main/master without explicit user confirmation

**ALWAYS**:

- Verify `.gitignore` is respected
- Check for sensitive file patterns before staging
- Confirm branch before committing
- Use standard push (never force)

## Error Handling

- **Not a git repo**: Inform user "This directory is not a git repository" and exit
- **Conflicts detected**: Inform user about conflicts, provide guidance, exit workflow
- **Command failure**: Display error message, do not retry automatically
- **No remote**: Report error, commit preserved locally
- **Lock file exists**: Run `clean-locks --force` and retry the operation
- **HTTPS auth failure**:
  - Inform user: "GitHub CLI not authenticated for HTTPS push"
  - Provide guidance: "Run `gh auth login` to authenticate"
  - Keep commit local (do NOT push)
  - **NEVER suggest changing remote URL to SSH**

## Sensitive File Detection

Before staging, scan for sensitive patterns:

```bash
git status --porcelain | grep -E '\.(env|pem|key)$|credentials|secret'
```

If found:

- Warn user about detected sensitive files
- Ask whether to exclude them from commit
- Use `git add` with explicit file list instead of `-A`

## Example Flows

### Auto Mode Example

```text
User: [completes implementation, all TODOs done]

Claude: I'll help commit these changes.
[Runs git status: 5 files modified, 2 new]

Claude: How would you like to commit?
[AskUserQuestion: Auto commit & push | Interactive | Cancel]
User: [selects Auto commit & push]

Claude: [Checks gh auth status for HTTPS remote - authenticated]
Auto-committing to main...

Changes:
 src/auth.py    | 45 +++++++++
 src/config.py  | 12 ++-
 tests/test_auth.py | 78 ++++++++++++++++

Generated message:
---
feat(auth): implement OAuth2 login flow

## Summary

Add OAuth2 authentication with Google provider. Users can now login
using their Google account with secure token handling.

## Changes

- Add OAuth2 provider configuration
- Create login callback handler
- Implement session management
- Add user model provider fields

## Plan Reference

Implementation of: oauth2-authentication

## Files Modified

5 files changed
---

Committed and pushed to origin/main.
What would you like to do next?
[AskUserQuestion: Done for now | Plan feature | Plan bug fix | Plan refactor | Plan docs]

User: [selects "Done for now"]

Claude: Commit complete. Entering plan mode...
[Invokes EnterPlanMode]
```

### Interactive Mode Example

```text
User: [completes implementation, all TODOs done]

Claude: I'll help commit these changes.
[Runs git status: 5 files modified, 2 new]

Claude: How would you like to commit?
[AskUserQuestion: Auto commit & push | Interactive | Cancel]
User: [selects Interactive]

Claude: Where should I commit?
[AskUserQuestion: Current branch: feature/auth | Create new | Cancel]
User: [selects Current branch]

Claude: Changes to commit:
 src/auth.py    | 45 +++++++++
 src/config.py  | 12 ++-
 tests/test_auth.py | 78 ++++++++++++++++

Claude: Proposed commit message:
---
feat(auth): implement OAuth2 login flow

## Summary

Add OAuth2 authentication with Google provider. Users can now login
using their Google account with secure token handling.

## Changes

- Add OAuth2 provider configuration
- Create login callback handler
- Implement session management
- Add user model provider fields

## Plan Reference

Implementation of: oauth2-authentication

## Files Modified

5 files changed
---
[AskUserQuestion: Accept | Edit | Cancel]
User: [selects Accept]

Claude: [Checks HTTPS remote auth: gh auth status - OK]
Committed! Push to origin/feature/auth?
[AskUserQuestion: Yes | No]
User: [selects Yes]

Claude: Changes pushed to origin/feature/auth.
        What would you like to do next?
[AskUserQuestion: Done for now | Plan feature | Plan bug fix | Plan refactor | Plan docs]

User: [selects "Done for now"]

Claude: Commit complete. Entering plan mode...
[Invokes EnterPlanMode]
```

### HTTPS Auth Failure Example

```text
Claude: Committed! Push to origin/main?
[AskUserQuestion: Yes | No]
User: [selects Yes]

Claude: [Checks HTTPS remote: https://github.com/user/repo.git]
[Runs: gh auth status]
[Result: Not authenticated]

Claude: GitHub CLI not authenticated for HTTPS push.
Your commit is saved locally. To push, authenticate first:

    gh auth login

Then retry the push with: git push origin main

Note: Your remote is configured for HTTPS. This is preserved.
[Does NOT suggest changing to SSH]

What would you like to do next?
[AskUserQuestion: Done for now | Plan feature | ...]
```
