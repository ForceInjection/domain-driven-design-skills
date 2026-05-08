---
name: swarm-board
description: Interact with the swarm task board. Use when you need to query existing tasks, check backlog status, create new tasks, or understand the current project state.
---

# Swarm Task Board

This skill enables you to interact with the swarm task management system to query tasks, understand project state, and create new work items.

## Quick Reference

| Action | Command |
|--------|---------|
| List all tasks | `curl $MANAGER_URL/api/v1/tasks` |
| List by status | `curl "$MANAGER_URL/api/v1/tasks?status=Backlog"` |
| Get task details | `curl $MANAGER_URL/api/v1/tasks/{id}` |
| Create task | `curl -X POST $MANAGER_URL/api/v1/tasks -d '{...}'` |
| Get stats | `curl $MANAGER_URL/api/v1/stats` |

**Note**: `MANAGER_URL` is typically `http://manager:8080` inside containers.

## Querying Tasks

### List All Tasks

```bash
curl -s "$MANAGER_URL/api/v1/tasks" | jq
```

Response:
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Add user authentication",
    "description": "Feature: User Authentication\n  As a user...",
    "status": "Backlog",
    "priority": "High",
    "source": "user",
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

### Filter by Status

Valid statuses: `Backlog`, `InProgress`, `Review`, `Done`, `NeedsWork`

```bash
# Get backlog items
curl -s "$MANAGER_URL/api/v1/tasks?status=Backlog" | jq

# Get completed tasks
curl -s "$MANAGER_URL/api/v1/tasks?status=Done" | jq

# Get tasks in review
curl -s "$MANAGER_URL/api/v1/tasks?status=Review" | jq
```

### Get Single Task

Supports full UUID or partial ID prefix:

```bash
curl -s "$MANAGER_URL/api/v1/tasks/550e8400" | jq
```

### Get Statistics

```bash
curl -s "$MANAGER_URL/api/v1/stats" | jq
```

Response:
```json
{
  "total_tasks": 15,
  "backlog": 5,
  "in_progress": 2,
  "review": 1,
  "done": 7,
  "needs_work": 0,
  "active_agents": 3
}
```

## Creating Tasks

### Create a New Task

```bash
curl -X POST "$MANAGER_URL/api/v1/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Add password reset functionality",
    "description": "Feature: Password Reset\n  As a user\n  I want to reset my password\n  So that I can regain access to my account\n\n  Scenario: Request password reset\n    Given I am on the login page\n    When I click \"Forgot Password\"\n    And I enter my email address\n    Then I should receive a reset email\n\nTechnical Notes:\n- Use existing email service\n- Token expires in 1 hour\n\nAcceptance Criteria:\n- [ ] Reset email sent within 30 seconds\n- [ ] Token is single-use\n- [ ] Old password invalidated after reset",
    "priority": "Medium"
  }'
```

### Task Fields

| Field | Required | Values |
|-------|----------|--------|
| `title` | Yes | Short descriptive title |
| `description` | Yes | Gherkin format preferred |
| `priority` | No | `High`, `Medium` (default), `Low` |

### Gherkin Format

Tasks should use Gherkin format for clarity:

```gherkin
Feature: [Feature name]
  As a [user role]
  I want [goal]
  So that [benefit]

  Scenario: [Primary scenario]
    Given [precondition]
    When [action]
    Then [expected outcome]

Technical Notes:
- [Implementation detail 1]
- [Implementation detail 2]

Acceptance Criteria:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

## Building Context

Before creating new tasks, gather context:

### 1. Check Current Backlog

```bash
# See what's already planned
curl -s "$MANAGER_URL/api/v1/tasks?status=Backlog" | jq '.[].title'
```

### 2. Review Completed Work

```bash
# See what's been done recently
curl -s "$MANAGER_URL/api/v1/tasks?status=Done" | jq '.[-5:] | .[].title'
```

### 3. Check Work In Progress

```bash
# See what workers are doing
curl -s "$MANAGER_URL/api/v1/tasks?status=InProgress" | jq '.[].title'
```

### 4. Get Overall Stats

```bash
curl -s "$MANAGER_URL/api/v1/stats" | jq
```

## Avoiding Duplicates

Before creating a task, check if similar work exists:

1. **Check backlog** for similar titles
2. **Check completed tasks** - don't recreate finished work
3. **Check in-progress tasks** - don't duplicate active work

Example deduplication check:
```bash
# Search for tasks mentioning "authentication"
curl -s "$MANAGER_URL/api/v1/tasks" | jq '[.[] | select(.title | ascii_downcase | contains("auth"))]'
```

## Task Lifecycle

```
Backlog → InProgress (claimed by worker)
InProgress → Review (PR created)
Review → Done (approved & merged)
Review → NeedsWork (changes requested)
NeedsWork → InProgress (worker addresses feedback)
```

## Priority Guidelines

| Priority | Use When |
|----------|----------|
| **High** | Core functionality gaps, security issues, blocking bugs |
| **Medium** | Feature enhancements, performance improvements |
| **Low** | Technical debt, documentation, nice-to-have features |

## Best Practices

1. **Keep tasks focused** - 1-4 hours of work each
2. **Use Gherkin format** - Clear acceptance criteria
3. **Check for duplicates** - Query backlog before creating
4. **Set appropriate priority** - Don't make everything High
5. **Include technical notes** - Help workers understand context
