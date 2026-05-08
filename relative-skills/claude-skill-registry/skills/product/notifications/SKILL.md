---
name: notifications
description: System for alerting the user when attention is needed. Use when you need to get the user's attention for questions, approvals, or when stuck.
---

# Notification System

Automatasaurus includes a notification system to alert the user when their attention is needed.

## Automatic Notifications

The system automatically sends notifications on stop based on context:
- **Questions**: When Claude asks a question and waits for input
- **Approvals**: When approval is needed to proceed
- **Stuck**: When an agent encounters an issue
- **Complete**: When all work is done

## Explicit Notification Request

When you need to explicitly alert the user, use:

```bash
.claude/hooks/request-attention.sh <type> "<message>"
```

### Notification Types

| Type | When to Use | Sound |
|------|-------------|-------|
| `question` | You have a question that needs answering | Submarine |
| `approval` | You need approval before proceeding | Submarine |
| `stuck` | You've encountered an issue you can't resolve | Basso (alert) |
| `complete` | All assigned work is finished | Hero (success) |
| `info` | General notification | Glass |
| `error` | An error occurred | Basso (alert) |

### Examples

```bash
# Question needs answering
.claude/hooks/request-attention.sh question "Should I use PostgreSQL or MySQL for this project?"

# Approval needed
.claude/hooks/request-attention.sh approval "PR #42 is ready for review"

# Got stuck
.claude/hooks/request-attention.sh stuck "Cannot access the GitHub API - authentication failed"

# Work complete
.claude/hooks/request-attention.sh complete "All 5 user stories have been implemented and tested"

# Error occurred
.claude/hooks/request-attention.sh error "Build failed with 3 errors"
```

## When to Notify

### Always Notify For:
- Questions that block progress
- Security-related approvals
- When you've been stuck for more than one attempt
- Completion of significant milestones
- Errors that require human intervention

### Don't Notify For:
- Minor progress updates
- Self-recoverable errors
- Questions you can answer from context

## Configuration

Notifications can be configured via environment variables:

```bash
# Disable sound
AUTOMATASAURUS_SOUND=false

# Custom log location
AUTOMATASAURUS_LOG=/path/to/custom.log
```

## Platform Support

- **macOS**: Native notifications with sound
- **Linux**: Uses `notify-send` if available
- **Windows**: PowerShell message box

## Logging

All notifications are logged to `$AUTOMATASAURUS_LOG` (default: `/tmp/automatasaurus.log`):

```
[2025-01-02 14:30:45] [question] Automatasaurus: Which database should we use?
[2025-01-02 14:35:12] [complete] Automatasaurus: Feature implementation complete
```
