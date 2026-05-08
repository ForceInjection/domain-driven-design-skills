---
name: tickets
description: Track work using the tickets system. Use when the user wants to create, list, update, or complete tickets for tracking work in progress, ideas, or recurring tasks.
---

# Tickets System

Manage work tracking through the `tickets/` directory. Use this skill when the user mentions:
- Creating a new ticket
- Tracking work or ideas
- Listing current tickets
- Completing or closing tickets
- Managing backlog items
- Recurring reviews or audits

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `tickets/active/` | Work in progress or planned next |
| `tickets/backlog/` | Ideas worth tracking, not yet planned |
| `tickets/completed/` | Finished work (can be purged periodically) |
| `tickets/recurring/` | Periodic tasks run repeatedly |

## Operations

### Creating a Ticket

1. Determine location: `active/` for immediate work, `backlog/` for ideas
2. Use kebab-case filename: `feature-name.md`
3. Apply the appropriate template (see below)
4. Fill in known details, mark unknowns for follow-up
5. **Resolve open questions**: After creating the ticket, review any incomplete Decision Record items or Prerequisites with the user. Use AskUserQuestion to clarify options, get decisions, and update the ticket until Status can progress beyond "information gathering"

### Listing Tickets

1. Read files from requested directory (default: `active/`)
2. Extract Status and Goal from each file
3. Present as a summary list

### Completing a Ticket

1. Move file from `active/` to `completed/`
2. Update Status to "completed"
3. Add completion note to Current State with date

### Updating a Ticket

1. Read the ticket file
2. Update the relevant section (Status, Tasks, Current State, Notes)
3. Keep the update focused and timestamped if relevant

## Templates

### Active Ticket Template

```markdown
# Ticket Name

## Status
information gathering | ready for implementation | waiting for <dependency>

## Prerequisites
- [ ] other-ticket-name (dependency on another ticket)
- [ ] design decision needed (new design / approval)
- [ ] none

## Goal
One sentence: what "done" looks like.

## Context
- Relevant files/symbols:
- Related tickets/notes/docs:
- How to verify / reproduce:

## Decision Record
- Decision:
- Inputs:
- Options:
- Outcome:
- Follow-ups:

## Tasks
- [x] completed step
- [ ] next step
- [ ] future step

## Current State
Where things stand right now. Update as work progresses.

## Notes
- Short observations, gotchas, things tried
- Reference external docs for longer explanations
```

### Backlog Template

```markdown
# Feature Name

## Idea
What this would do.

## Why
Why it might be valuable.

## Rough Scope
High-level bullets of what's involved.

## Why Not Now
What's blocking or why it's not a priority.

## Trigger to Activate
What would make this worth doing.
```

### Recurring Template

```markdown
# Review: Area Name

Brief description of what this review covers.

## Scope

- `path/to/module/` - Description
- `path/to/file.py` - Description

## Checklist

- [ ] Check item 1
- [ ] Check item 2
- [ ] Check item 3

## Output

Record findings in `docs/notes/reviews/review-<area>.md`.

## Last Run

YYYY-MM (brief note about findings)
```

## Guidelines

- Keep tickets focused - one coherent unit of work
- Front-load background gathering so tickets are startable without extra research
- Prefer `Prerequisites: none` unless blocked by new design or another ticket
- Record decisions in the ticket body
- Update Current State frequently
- Notes prevent repeating mistakes after recovery
- Delete or archive when done - this is not documentation
