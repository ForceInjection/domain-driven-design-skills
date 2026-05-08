---
name: piter-setup
description: Set up PITER framework elements for AFK agent systems. Use when configuring prompt input sources, triggers, environments, and review processes for autonomous agent workflows.
allowed-tools: Read, Grep, Glob
---

# PITER Setup

Guide for setting up the PITER framework elements to enable AFK (Away From Keyboard) agent systems.

## When to Use

- Configuring GitHub as prompt input source
- Setting up webhook or cron triggers
- Preparing a dedicated agent environment
- Designing the review process
- Moving from in-loop to out-of-loop agentic coding

## PITER Overview

| Element | Question | Common Implementation |
| --- | --- | --- |
| **P** | Where do tasks come from? | GitHub Issues |
| **I** | What type of work is this? | LLM Classification |
| **T** | When does work start? | Webhooks / Cron |
| **E** | Where do agents run? | Dedicated VM/Sandbox |
| **R** | How is work validated? | Pull Requests |

## Setup Workflow

### 1. Configure Prompt Input (P)

#### GitHub Issues Setup

```bash
# Verify GitHub CLI is authenticated
gh auth status

# Test issue creation
gh issue create --title "Test Issue" --body "Testing ADW prompt input"

# Test issue fetching
gh issue view 1 --json title,body,labels
```

Issue structure becomes the prompt:

```text
Title: Add user authentication
Body: We need OAuth with Google provider...
Labels: feature, priority-high

→ Becomes: "/feature Add user authentication..."
```

### 2. Configure Classification (I)

Create `/classify-issue` command:

```markdown
# Issue Classification

Analyze the issue and respond with exactly one of:
- /chore - for maintenance, updates, cleanup
- /bug - for defects, errors, unexpected behavior
- /feature - for new functionality

## Issue
$ARGUMENTS
```

Test classification:

```bash
claude -p "/classify-issue 'Fix login button not working'"
# Expected: /bug

claude -p "/classify-issue 'Update dependencies'"
# Expected: /chore
```

### 3. Configure Trigger (T)

#### Option A: Cron Polling

```python
# trigger_cron.py (simplified)
import time

POLL_INTERVAL = 20  # seconds

while True:
    issues = get_unprocessed_issues()
    for issue in issues:
        run_adw(issue.number)
    time.sleep(POLL_INTERVAL)
```

Unprocessed = no comments OR latest comment is "adw"

#### Option B: Webhook

```python
# trigger_webhook.py (simplified)
from flask import Flask, request

app = Flask(__name__)

@app.route("/gh-webhook", methods=["POST"])
def handle_webhook():
    event = request.json
    if is_new_issue(event):
        run_adw(event["issue"]["number"])
    return "OK"
```

Webhook setup:

1. Set up tunnel (ngrok/cloudflare)
2. Configure webhook in GitHub repo settings
3. Select events: Issues, Issue comments

### 4. Configure Environment (E)

Environment checklist:

```bash
# Verify Claude Code
claude --version

# Verify API key
echo $ANTHROPIC_API_KEY | head -c 10

# Verify GitHub access
gh auth status

# Verify repository
git remote -v

# Test templates
claude -p "/chore test" --dry-run
```

Create `.env` file (never commit):

```bash
ANTHROPIC_API_KEY=sk-ant-...
GITHUB_TOKEN=ghp_...
CLAUDE_CODE_PATH=claude
```

### 5. Configure Review (R)

PR-based review:

```bash
# Test PR creation
gh pr create \
  --title "Test PR" \
  --body "Testing ADW review process" \
  --base main \
  --head feature-test
```

Branch protection (recommended):

- Require pull request reviews
- Require status checks to pass
- Require linear history

## Validation Checklist

### Prompt Input (P)

- [ ] GitHub CLI authenticated
- [ ] Can create issues
- [ ] Can fetch issue details
- [ ] Issue format understood

### Classification (I)

- [ ] `/classify-issue` command works
- [ ] Correctly classifies chores
- [ ] Correctly classifies bugs
- [ ] Correctly classifies features

### Trigger (T)

- [ ] Trigger method chosen (cron/webhook)
- [ ] Trigger script running
- [ ] Events detected correctly
- [ ] ADW invoked on trigger

### Environment (E)

- [ ] Dedicated environment available
- [ ] API keys configured
- [ ] Claude Code accessible
- [ ] Templates tested
- [ ] Permissions configured

### Review (R)

- [ ] PR creation works
- [ ] Issue linking works
- [ ] Branch protection configured
- [ ] Review process documented

## Quick Test Workflow

```bash
# 1. Create test issue
gh issue create --title "Test: Update README" --body "Add installation section"

# 2. Manually run ADW
python adws/adw_plan_build.py <issue_number>

# 3. Verify PR created
gh pr list --state open

# 4. Review and close
gh pr view <pr_number>
```

## Common Issues

### Authentication Failures

```bash
# Refresh GitHub auth
gh auth login

# Verify API key
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
  https://api.anthropic.com/v1/models
```

### Webhook Not Receiving

- Check tunnel is running
- Verify webhook URL in GitHub settings
- Check webhook secret matches
- Look at GitHub webhook delivery logs

### Classification Accuracy

- Improve prompt with examples
- Add edge case handling
- Consider multi-label issues

## Related Memory Files

- @piter-framework.md - Full PITER reference
- @adw-anatomy.md - ADW structure
- @outloop-checklist.md - Deployment checklist

## Version History

- **v1.0.0** (2025-12-26): Initial release

---

## Last Updated

**Date:** 2025-12-26
**Model:** claude-opus-4-5-20251101
