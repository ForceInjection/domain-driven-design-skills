---
name: followup
description: Schedule a follow-up reminder for a specific date. Use when user wants to set a reminder to follow up on a project, task, question, or any item. Adds entries to _Followups.md which get pulled into daily notes.
---

# Follow-up Scheduler

Schedule follow-up reminders that appear in daily notes on the specified date.

## Usage

`/followup [date] [description]`

Examples:
- `/followup 2025-12-23 Check deployment status`
- `/followup next monday Ask Alex about hiring decision`
- `/followup +3 Review PR feedback`

## Date Formats

Accept flexible date input:
- ISO format: `2025-12-23`
- Relative: `tomorrow`, `next monday`, `next friday`
- Offset: `+3` (3 days from now), `+1w` (1 week from now)

## Workflow

1. Parse the date from input (first argument)
2. Parse the description (remaining arguments)
3. Convert to ISO date format (YYYY-MM-DD)
4. Append to `_Followups.md` in the vault

## File Location

- Vault: `/Users/larslevie/Library/Mobile Documents/iCloud~md~obsidian/Documents/Real Geeks/`
- File: `_Followups.md`

## Entry Format

Markdown table row:

```markdown
| 2025-12-23 | Check deployment status | pending |
```

Status values: `pending`, `done`

## Implementation

```python
import datetime
import re

def parse_date(date_str):
    today = datetime.date.today()

    # ISO format
    if re.match(r'\d{4}-\d{2}-\d{2}', date_str):
        return date_str

    # Relative days
    if date_str == 'tomorrow':
        return (today + datetime.timedelta(days=1)).isoformat()

    # Offset: +N or +Nw
    if date_str.startswith('+'):
        if date_str.endswith('w'):
            weeks = int(date_str[1:-1])
            return (today + datetime.timedelta(weeks=weeks)).isoformat()
        else:
            days = int(date_str[1:])
            return (today + datetime.timedelta(days=days)).isoformat()

    # next [weekday]
    if date_str.startswith('next '):
        weekday = date_str[5:].lower()
        days = {'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3,
                'friday': 4, 'saturday': 5, 'sunday': 6}
        target = days.get(weekday)
        if target is not None:
            current = today.weekday()
            diff = (target - current + 7) % 7
            if diff == 0:
                diff = 7
            return (today + datetime.timedelta(days=diff)).isoformat()

    return None
```

## After Adding

1. Read current `_Followups.md`
2. Insert new row before the empty line after the table header
3. Confirm to user with the parsed date and description

Example confirmation:
```
Added follow-up for 2025-12-23: "Check deployment status"
```
