---
name: SDK Bridge Patterns
description: |
  Use when user wants to "hand off to SDK", "run autonomous agent", "bridge CLI and SDK", "long-running tasks", "autonomous development", or mentions SDK bridge workflows. Provides comprehensive patterns for hybrid CLI/SDK development with the Claude Agent SDK.
version: 1.4.0
---

# SDK Bridge Patterns

Bridge Claude Code CLI and Agent SDK for seamless hybrid workflows. Hand off long-running tasks to autonomous agents, monitor progress, and resume in CLI when complete.

## Quick Reference

**Commands**:
- `/sdk-bridge:init` - Initialize project for SDK bridge
- `/sdk-bridge:handoff` - Hand off work to autonomous SDK agent
- `/sdk-bridge:status` - Monitor progress
- `/sdk-bridge:resume` - Resume in CLI after completion
- `/sdk-bridge:cancel` - Stop running SDK agent

**Workflow**: Plan → Init → Handoff → Monitor → Resume

## When to Use SDK Bridge

✅ **Use SDK Bridge when:**
- Task has 10+ well-defined features to implement
- You want autonomous progress while away
- Task benefits from multi-session iteration
- You've created a plan and want unattended execution
- Features are testable and have clear completion criteria

❌ **Don't use for:**
- Exploratory work (stay in CLI for interactivity)
- Tasks requiring frequent user input or decisions
- Simple single-feature changes
- When you need to iterate on prompts or approaches

## Core Workflow Pattern

### Phase 1: Plan in CLI (Interactive)

Work interactively to create a comprehensive plan:

```bash
# Create plan with feature list
/plan

# Review generated feature_list.json
cat feature_list.json | jq '.[] | {description, test}'

# Refine if needed
# Edit feature_list.json to clarify vague features
# Ensure each feature has clear test criteria

# Commit the plan
git add feature_list.json CLAUDE.md
git commit -m "Initial project plan"
```

**Best practices**:
- Make features specific and testable
- Order features by dependency
- Include test criteria in each feature
- 15-50 features is ideal (too few: not worth automation, too many: risk of drift)

### Phase 2: Initialize SDK Bridge

```bash
/sdk-bridge:init
```

This creates `.claude/sdk-bridge.local.md` with configuration:
- Model selection (Sonnet vs Opus)
- Session limits
- Progress stall threshold
- Auto-handoff settings

**Review and customize** the configuration for your project needs.

### Phase 3: Handoff to SDK (Autonomous)

```bash
/sdk-bridge:handoff
```

What happens:
1. **Validation**: Handoff-validator agent checks:
   - `feature_list.json` exists with failing features
   - Git repository initialized
   - Harness and SDK installed
   - No conflicting SDK processes
   - API authentication configured

2. **Launch**: If validation passes:
   - Harness starts in background with `nohup`
   - PID saved to `.claude/sdk-bridge.pid`
   - Output logged to `.claude/sdk-bridge.log`
   - Tracking created in `.claude/handoff-context.json`

3. **Autonomous Work**: SDK agent:
   - Reads `feature_list.json` and `claude-progress.txt`
   - Implements ONE feature per session
   - Tests implementation
   - Updates `passes: true` in `feature_list.json`
   - Logs progress to `claude-progress.txt`
   - Commits to git
   - Repeats until complete or limit reached

**You can close the CLI** - the SDK agent runs independently.

### Phase 4: Monitor (Optional)

```bash
/sdk-bridge:status
```

Shows:
- SDK agent process status (running/stopped)
- Feature completion progress (e.g., "28/50 passing")
- Session count (e.g., "8/20 sessions used")
- Recent log activity

**Monitoring options**:
- Periodic checks: `/sdk-bridge:status`
- Live logs: `tail -f .claude/sdk-bridge.log`
- Git commits: `git log --oneline`
- Feature progress: `jq '.[] | select(.passes==true) | .description' feature_list.json`

### Phase 5: Resume in CLI (Interactive)

```bash
/sdk-bridge:resume
```

What happens:
1. **Completion check**: Verifies `.claude/sdk_complete.json` exists
2. **Analysis**: Completion-reviewer agent:
   - Parses completion signal (reason, sessions used)
   - Analyzes feature progress
   - Reviews git commits
   - Runs tests and checks build
   - Identifies next features
   - Detects issues in logs

3. **Report**: Presents comprehensive summary:
   - What was completed
   - Test/build status
   - Remaining work
   - Issues found
   - Recommended next steps

4. **Continue**: You're back in interactive CLI mode
   - Can continue manually
   - Can fix issues
   - Can hand off again

## File Structure

During SDK bridge workflows, these files coordinate state:

```
project/
├── feature_list.json          # Source of truth for features (SDK reads/writes)
├── claude-progress.txt        # Session-to-session memory (SDK writes)
├── CLAUDE.md                  # Session protocol (SDK reads)
├── init.sh                    # Environment bootstrap (SDK executes)
├── .git/                      # Version control (SDK commits)
└── .claude/
    ├── sdk-bridge.local.md    # Configuration (plugin reads)
    ├── handoff-context.json   # Handoff tracking (plugin writes)
    ├── sdk-bridge.log         # SDK output (harness writes)
    ├── sdk-bridge.pid         # Process ID (plugin writes)
    ├── sdk-checkpoint.json    # Crash recovery state (harness writes) [v1.4.0]
    └── sdk_complete.json      # Completion signal (harness/plugin writes)
```

## Configuration

Edit `.claude/sdk-bridge.local.md` to customize:

```markdown
---
enabled: true
model: claude-sonnet-4-5-20250929  # or claude-opus-4-5-20251101
max_sessions: 20
reserve_sessions: 2
progress_stall_threshold: 3
auto_handoff_after_plan: false
log_level: INFO                    # DEBUG, INFO, WARNING, ERROR [v1.4.0]
webhook_url:                       # Optional webhook for notifications [v1.4.0]
---

# SDK Bridge Configuration

[Your project-specific notes]
```

### Configuration Options

**`model`**: Which Claude model SDK uses
- `claude-sonnet-4-5-20250929` (default) - Fast, capable, cost-effective
- `claude-opus-4-5-20251101` - Most capable, slower, more expensive
- Use Sonnet for standard features, Opus for complex/creative work

**`max_sessions`**: Total sessions before stopping (default: 20)
- 1 session = 1 complete feature implementation attempt
- Recommend: 15-30 for small projects, 30-50 for large projects
- SDK stops at `max_sessions - reserve_sessions`

**`reserve_sessions`**: Keep N for manual intervention (default: 2)
- Reserved for wrap-up or recovery
- SDK stops early to leave these available

**`progress_stall_threshold`**: Stop if no progress for N sessions (default: 3)
- Prevents wasted sessions on blocked features
- If same feature fails 3 times in a row → stop

**`auto_handoff_after_plan`**: Auto-launch after /plan (default: false)
- `true`: Immediately hand off after plan creation
- `false`: Manual handoff with `/sdk-bridge:handoff`

**`log_level`** [v1.4.0]: Logging verbosity (default: INFO)
- `DEBUG`: Verbose output including API auth method, agent responses
- `INFO`: Standard progress messages
- `WARNING`: Only warnings and errors
- `ERROR`: Only error messages

**`webhook_url`** [v1.4.0]: Optional webhook for notifications
- Receives POST requests with JSON payloads
- Events: `feature_complete`, `error`, `completion`
- Leave empty to disable

## Common Patterns

### Pattern 1: Standard Long-Running Development

```bash
# Day 1: Planning
/plan
# Create 40 features for a new web app

/sdk-bridge:init
/sdk-bridge:handoff
# Close laptop, go home

# Day 2: Check progress
/sdk-bridge:status
# 32/40 features passing, 12 sessions used

# Day 3: SDK completes
/sdk-bridge:resume
# Review: 38/40 done, 2 features need clarification
# Fix issues manually, continue development
```

### Pattern 2: Iterative Refinement

```bash
# Round 1: Bulk implementation
/sdk-bridge:handoff
# ... SDK completes 30/50 features ...
/sdk-bridge:resume

# Review quality, fix issues
# Improve implementations, add tests
git commit -m "Refine SDK implementations"

# Round 2: Continue remaining features
/sdk-bridge:handoff
# ... SDK completes remaining 20 ...
/sdk-bridge:resume
```

### Pattern 3: Feature Batching

```bash
# Implement core features first
jq '.[0:20]' all-features.json > feature_list.json
git add feature_list.json && git commit -m "Phase 1 features"

/sdk-bridge:handoff
# ... SDK completes 20 features ...
/sdk-bridge:resume

# Add next batch
jq '.[20:40]' all-features.json > feature_list.json
git add feature_list.json && git commit -m "Phase 2 features"

/sdk-bridge:handoff
# ... continue ...
```

### Pattern 4: Emergency Cancel and Recovery

```bash
# SDK heading wrong direction
/sdk-bridge:status
# Only 3/50 passing after 10 sessions - something's wrong

/sdk-bridge:cancel

# Review what happened
git log --oneline -10
tail -100 .claude/sdk-bridge.log
cat claude-progress.txt

# Identify issue: Feature #1 was too vague
vim feature_list.json
# Clarify feature descriptions, add better test criteria

git commit -m "Clarify feature requirements"

# Try again with better guidance
/sdk-bridge:handoff
```

### Pattern 5: Auto-Handoff

```markdown
# .claude/sdk-bridge.local.md
---
auto_handoff_after_plan: true
---
```

```bash
/plan
# Automatically hands off immediately
# Check progress later with /sdk-bridge:status
```

## Best Practices

### 1. Write Clear, Testable Features

**Good**:
```json
{
  "description": "User can register with email and password",
  "passes": false,
  "test": "POST /api/register with valid data returns 201 and JWT token"
}
```

**Bad**:
```json
{
  "description": "Authentication",
  "passes": false,
  "test": "it works"
}
```

### 2. Order Features by Dependency

Put foundational features first:
1. Database schema
2. Core models
3. API endpoints
4. Business logic
5. UI components
6. Edge cases
7. Polish

### 3. Use Progressive Complexity

Start simple, add complexity:
- Feature 1: "Basic user model with email/password"
- Feature 10: "Password reset flow with email"
- Feature 20: "OAuth integration with Google"

### 4. Monitor Periodically

Check status every few hours:
```bash
/sdk-bridge:status

# If progress seems slow
tail -50 .claude/sdk-bridge.log

# If stuck on one feature
grep "Feature #N" claude-progress.txt
```

### 5. Commit Often (Manually)

Before handoff, commit your plan:
```bash
git add .
git commit -m "Initial plan with 40 features"
```

After resume, review and commit:
```bash
git log --oneline -20  # Review SDK commits
# If satisfied
git commit -m "SDK completed features 1-38"
# If not
git reset --hard HEAD~5  # Revert last 5 commits
```

### 6. Reserve Sessions Wisely

If SDK uses 18/20 sessions and stops:
- 2 sessions reserved for you to:
  - Manually complete hard features
  - Fix issues SDK couldn't resolve
  - Wrap up and test

### 7. Use Stall Detection

If SDK attempts same feature 3+ times:
- Feature description likely too vague
- Feature may be blocked on external dependency
- Edit `feature_list.json` to clarify or skip

### 8. Test Before Large Handoffs

Try with a small test:
```bash
# Create 5-feature test plan
echo '[...]' > feature_list.json

/sdk-bridge:handoff
# Wait 15 minutes
/sdk-bridge:status
# If working well, scale up to full plan
```

## Troubleshooting

### SDK Won't Start

```bash
# Check logs
cat .claude/sdk-bridge.log

# Common issues:
# 1. API key not set
echo $ANTHROPIC_API_KEY  # Should not be empty
# Or use OAuth: claude setup-token

# 2. SDK not installed
python3 -c "import claude_agent_sdk"

# 3. Harness missing
ls ~/.claude/skills/long-running-agent/harness/autonomous_agent.py
# If missing: /user:lra-setup

# 4. Git not initialized
git status
# If not a repo: git init
```

### Progress Stalled

```bash
/sdk-bridge:status
# Sessions: 10/20, Features: 3/50 (only 3 done in 10 sessions!)

# Check what's failing
tail -100 .claude/sdk-bridge.log
cat claude-progress.txt | tail -50

# Common causes:
# - Feature too vague
# - Tests failing repeatedly
# - External dependency missing

# Fix:
/sdk-bridge:cancel
vim feature_list.json  # Clarify or skip stuck feature
git commit -m "Clarify feature requirements"
/sdk-bridge:handoff
```

### Tests Failing After Resume

```bash
/sdk-bridge:resume
# Shows: "❌ Tests failing"

# Check which tests
npm test  # or pytest

# Common issues:
# - SDK implemented feature but tests need update
# - Edge cases not covered
# - Environment differences (API keys, DB)

# Fix:
# Update tests or implementation
git add .
git commit -m "Fix edge cases found by tests"
```

### Completion Not Detected

```bash
# SDK stopped but no completion signal
ps aux | grep autonomous_agent  # Not running

# Check logs for errors
tail -100 .claude/sdk-bridge.log

# Manually check progress
jq '.[] | select(.passes==false) | .description' feature_list.json

# If work complete, manually resume
cat > .claude/sdk_complete.json << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "reason": "manual_completion",
  "session_count": 15
}
EOF

/sdk-bridge:resume
```

### High API Costs

```bash
# Use Sonnet instead of Opus
# Edit .claude/sdk-bridge.local.md:
model: claude-sonnet-4-5-20250929

# Reduce max sessions
max_sessions: 15  # Instead of 30

# Better features = fewer retries
# Make feature descriptions clearer
```

## Advanced Patterns

### Custom Completion Signals

SDK can signal early completion:

```json
{
  "timestamp": "2025-12-15T10:30:00Z",
  "reason": "blocked_on_external_dependency",
  "session_count": 8,
  "exit_code": 2,
  "message": "Need Stripe API keys before continuing",
  "blocking_features": [23, 24, 25]
}
```

This allows graceful handback when SDK encounters blockers.

### Project-Specific Protocols

Create `.claude/CLAUDE.md` with project-specific guidance:

```markdown
# Project Protocol

## Code Standards
- Use TypeScript strict mode
- All functions must have JSDoc comments
- Tests required for all public APIs

## Testing
- Run `npm test` after each feature
- Feature passes only if all tests pass
- Add tests before implementation

## Git
- Commit after each passing feature
- Use conventional commit format
- Never force push
```

The SDK reads this before each session.

### Multi-Agent Workflows

Use different models for different work:

```bash
# Use Opus for complex features
model: claude-opus-4-5-20251101
/sdk-bridge:handoff
# ... completes complex features ...
/sdk-bridge:resume

# Switch to Sonnet for simple features
# Edit .claude/sdk-bridge.local.md:
model: claude-sonnet-4-5-20250929
/sdk-bridge:handoff
# ... completes remaining simple features ...
```

## Version 1.4.0 Features

SDK Bridge 1.4.0 introduces several production-quality improvements to the autonomous agent harness.

### Retry Logic with Exponential Backoff

The harness now automatically retries failed sessions with exponential backoff delays:

- **3 retry attempts** per session on transient errors
- **Exponential backoff**: 1s, 2s, 4s delays between retries
- Only retries on exceptions/errors, not on feature implementation failures
- Prevents API rate limiting and handles temporary network issues

```
[2025-01-06 10:30:00] [WARNING] Session attempt 1 failed with error: Connection timeout
[2025-01-06 10:30:01] [INFO] Retry attempt 2/3 after 1s delay
[2025-01-06 10:30:03] [INFO] Retry attempt 3/3 after 2s delay
```

### Progress Persistence Across Crashes

State is now saved to `.claude/sdk-checkpoint.json` after each feature, enabling recovery after crashes:

**Checkpoint file format**:
```json
{
  "current_session": 5,
  "features_completed": 4,
  "consecutive_failures": 0,
  "current_feature": "User authentication flow",
  "project_dir": "/path/to/project",
  "model": "claude-sonnet-4-5-20250929",
  "max_iterations": 20,
  "checkpoint_time": "2025-01-06T10:30:00Z"
}
```

**Recovery behavior**:
- On restart, harness checks for existing checkpoint
- Resumes from last saved session state
- Checkpoint is cleared on successful completion
- Uses atomic writes (temp file + rename) to prevent corruption

### Structured Logging

Replaced print-based logging with Python's `logging` module:

**Log levels**: DEBUG, INFO, WARNING, ERROR

**Configuration**:
```yaml
# .claude/sdk-bridge.local.md
---
log_level: DEBUG  # or INFO (default), WARNING, ERROR
---
```

**Or via command line**:
```bash
python autonomous_agent.py --project-dir . --log-level DEBUG
```

**Log format**:
```
[2025-01-06 10:30:00] [INFO] Starting autonomous agent in /project
[2025-01-06 10:30:00] [INFO] Model: claude-sonnet-4-5-20250929, Max iterations: 20
[2025-01-06 10:30:01] [DEBUG] Using auth: CLAUDE_CODE_OAUTH_TOKEN
[2025-01-06 10:30:05] [INFO] Feature completed successfully: User login
[2025-01-06 10:30:05] [WARNING] Webhook failed: Connection refused
```

Logs are written to both console and `.claude/sdk-bridge.log`.

### Webhook Notifications

Optional webhook support for completion, error, and progress notifications:

**Configuration**:
```yaml
# .claude/sdk-bridge.local.md
---
webhook_url: https://your-server.com/webhook
---
```

**Webhook events**:

1. **Feature completion**:
```json
{
  "event": "feature_complete",
  "timestamp": "2025-01-06T10:30:00Z",
  "data": {
    "feature": "User authentication flow",
    "session": 5
  }
}
```

2. **Error notification**:
```json
{
  "event": "error",
  "timestamp": "2025-01-06T10:30:00Z",
  "data": {
    "error": "Stall detected",
    "feature": "Complex feature"
  }
}
```

3. **Completion notification**:
```json
{
  "event": "completion",
  "timestamp": "2025-01-06T10:30:00Z",
  "data": {
    "reason": "success",
    "features_completed": 45,
    "total_features": 50
  }
}
```

**Use cases**:
- Slack/Discord notifications
- CI/CD pipeline triggers
- Monitoring dashboards
- Email alerts via webhook-to-email services

### Feature Priority Ordering

Control execution order with the `priority` field in `feature_list.json`:

**Feature list with priorities**:
```json
[
  {
    "description": "Set up database schema",
    "test": "migrations run successfully",
    "passes": false,
    "priority": 100
  },
  {
    "description": "User authentication",
    "test": "login/logout works",
    "passes": false,
    "priority": 90
  },
  {
    "description": "Nice-to-have feature",
    "test": "works as expected",
    "passes": false,
    "priority": 10
  },
  {
    "description": "Default priority feature",
    "test": "works correctly",
    "passes": false
  }
]
```

**Priority behavior**:
- Higher numbers execute first (100 before 90 before 10)
- Default priority is 0 if not specified
- Features with same priority preserve original order
- Completed features are skipped regardless of priority

**Best practices**:
- Use 100 for critical infrastructure (DB, auth)
- Use 50 for core features
- Use 10 for nice-to-haves
- Use 0 (default) for unordered features

### New State Files

Version 1.4.0 adds:

| File | Purpose | Managed By |
|------|---------|------------|
| `.claude/sdk-checkpoint.json` | Crash recovery state | Harness |

### Configuration Reference (1.4.0)

New configuration options in `.claude/sdk-bridge.local.md`:

```yaml
---
enabled: true
model: claude-sonnet-4-5-20250929
max_sessions: 20
reserve_sessions: 2
progress_stall_threshold: 3
auto_handoff_after_plan: false
# New in 1.4.0:
log_level: INFO           # DEBUG, INFO, WARNING, ERROR
webhook_url: https://...  # Optional webhook endpoint
---
```

## Resources

**Examples**:
- `examples/workflow-example.md` - Complete end-to-end workflow
- `examples/handoff-scenarios.md` - Common handoff patterns

**References**:
- `references/state-files.md` - State file formats and meanings
- `references/configuration.md` - Complete configuration reference

**Scripts**:
- `scripts/launch-harness.sh` - Harness subprocess management
- `scripts/monitor-progress.sh` - Progress tracking
- `scripts/parse-state.sh` - State file parsing

## Integration with Long-Running Agent Skill

SDK Bridge wraps the existing long-running-agent harness:

**Relationship**:
- **Harness**: `~/.claude/skills/long-running-agent/harness/autonomous_agent.py`
- **SDK Bridge**: CLI-friendly plugin wrapper

**Direct harness use**:
```bash
python ~/.claude/skills/long-running-agent/harness/autonomous_agent.py \
    --project-dir . \
    --spec ./requirements.txt
```

**SDK Bridge use**:
```bash
/sdk-bridge:handoff  # Wraps the above
```

**Coexistence**:
- Both approaches work
- SDK Bridge adds: validation, monitoring, resume, hooks
- Direct harness gives: full control, custom arguments

Choose SDK Bridge for ease of use, direct harness for advanced control.

---

For detailed examples and references, see the `examples/` and `references/` directories in this skill.
