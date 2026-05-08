---
name: TODOs
description: TODO list management using org-mode. USE WHEN user wants to view, add, update, or manage TODOs in their org-mode files.
---

# TODO Management with Org-Mode

## Purpose
Help manage TODO items in ~/desktop/org/todos.org and ~/desktop/org/inbox.org following org-mode best practices and your personal workflow.

### Context Detection

**This skill activates when:**
- User asks to add, view, update, or manage TODOs
- User mentions tasks, action items, or things to do
- Working with files: `~/desktop/org/todos.org` or `~/desktop/org/inbox.org`
- User asks about work items, projects, or personal tasks
- User mentions scheduling, deadlines, or priorities

## Workflow Routing

When the user's request matches specific TODO operations, route to the appropriate workflow:

| Workflow | Trigger | File |
|----------|---------|------|
| **Add** | "add todo", "create task", "new todo", "capture item" | `workflows/Add.md` |
| **View** | "show todos", "what's next", "active tasks", "scheduled items" | `workflows/View.md` |
| **Update** | "mark done", "update todo", "change priority", "reschedule" | `workflows/Update.md` |
| **ReviewInbox** | "review inbox", "analyze inbox", "suggest refile targets" | `workflows/ReviewInbox.md` |
| **Refile** | "refile", "move todo", "organize item", "file to project" | `workflows/Refile.md` |
| **Archive** | "archive done", "clean up", "archive completed" | `workflows/Archive.md` |
| **Review** | "daily review", "weekly review", "plan week", "review system" | `workflows/Review.md` |
| **Project** | "create project", "multi-step task", "project with subtasks" | `workflows/Project.md` |
| **Recurring** | "recurring task", "repeating todo", "habit", "weekly meeting" | `workflows/Recurring.md` |

## File Structure

### ~/desktop/org/todos.org

Your main TODO file with these top-level sections:

#### 1. Work
- **Archive**: `archive/work::`
- **Category**: `work`
- Generic work todos and tasks

#### 2. Projects
- **Archive**: `archive/projects::`
- Holds both personal and work projects
- Each project is a sub-heading with its own tasks

#### 3. Systems
- **Archive**: `archive/systems::`
- **Category**: `systems`
- Related to homelab, infrastructure, and system configurations

#### 4. Personal
- **Archive**: `archive/personal::`
- **Category**: `personal`
- Personal tasks and life management

#### 5. Routines
- **Archive**: `archive/routines::`
- Recurring meetings, scheduled events, and habits

#### 6. Appointments
- **Archive**: `archive/appointments::`
- **Category**: `appointments`
- Specific appointments and time-based events

#### 7. Health
- **Archive**: `archive/health::`
- **Category**: `health`
- Health-related tasks and tracking

### ~/desktop/org/inbox.org

Capture inbox for quick entries before refiling to todos.org sections.

## TODO States

### Active States
- **TODO**: Not started, dormant
- **NEXT**: Next action to take
- **STRT** (Started): Currently working on it
- **WAIT**: Waiting on external dependency

### Completed States
- **DONE**: Completed successfully
- **CANX** (Cancelled): Cancelled or no longer relevant

## Priority System

Use priority cookies: `[#1]` through `[#5]`

- **[#1]**: Highest priority / most important
- **[#2]**: High priority
- **[#3]**: Medium priority
- **[#4]**: Low priority
- **[#5]**: Lowest priority

Lower numbers = higher importance (relative priority).

## Scheduling and Deadlines

### SCHEDULED
When you plan to start working on the task.

```org
** TODO Implement feature X
SCHEDULED: <2025-12-05 Fri>
```

### DEADLINE
When the task must be completed by.

```org
** TODO Submit report
DEADLINE: <2025-12-10 Wed>
```

### Repeating Tasks
Use repeaters for recurring tasks:

```org
** TODO Weekly review
SCHEDULED: <2025-12-08 Mon ++1w>
:PROPERTIES:
:STYLE:    habit
:LAST_REPEAT: [2025-12-01 Mon 13:40]
:END:
```

**Repeater syntax**:
- `+1w`: Repeat every week from the original date
- `++1w`: Repeat every week from completion date
- `.+1w`: Repeat every week, skip if missed

## Properties

Common properties used in your TODOs:

```org
:PROPERTIES:
:CREATED:       [2025-12-04 Thu 14:17]
:ID:       unique-id-here
:CUSTOM_ID: h:readable-id-here
:CATEGORY: work
:ARCHIVE:  archive/work::
:END:
```

- **CREATED**: When the TODO was created
- **ID**: Unique identifier for org-roam links
- **CUSTOM_ID**: Human-readable ID for links
- **CATEGORY**: Categorization (work, systems, personal, etc.)
- **ARCHIVE**: Where to archive when done

## Logbook Tracking

Track state changes, notes, and rescheduling:

```org
:LOGBOOK:
- State "DONE"       from "STRT"       [2025-12-04 Thu 11:18]
- Rescheduled from "[2025-12-03 Wed]" on [2025-12-04 Thu 17:12]
- Note taken on [2025-12-04 Thu 14:18] \\
  Additional context about this task
:END:
```

## Organization Best Practices

### 1. Capture to Inbox First
Quick capture to `inbox.org`, then refile to appropriate section:

```bash
# Quick capture
echo "* TODO Fix bug in authentication" >> ~/desktop/org/inbox.org
```

Then refile using workflows or Emacs.

### 2. Use Sub-headings for Projects
Projects should have their own section with sub-tasks:

```org
** TODO Keyboard firmware improvements

*** DONE Handle altgr+shift on moonlander
CLOSED: [2025-11-25 Tue 23:23]

*** TODO Make nav/media/mouse layouts consistent
SCHEDULED: <2025-12-05 Fri>

*** TODO Use leader keys on both keyboards
```

### 3. Keep Active Tasks Visible
- **Active tasks**: NEXT, STRT, SCHEDULED, or with DEADLINE
- **Inactive tasks**: TODO or WAIT without scheduling

### 4. Archive Regularly
Move DONE and CANX items to archive sections to keep the main file clean.

## Common TODO Patterns

### Work Task
```org
** TODO [#2] Review upstream pull request
SCHEDULED: <2025-12-05 Fri>
:PROPERTIES:
:CREATED:       [2025-12-04 Thu 11:17]
:CATEGORY: work
:END:

Link to PR: https://github.com/org/repo/pull/123
```

### Project with Subtasks
```org
** STRT Personal finance tracking [0/3]
:PROPERTIES:
:CREATED:       [2025-11-03 Mon 15:49]
:END:

*** TODO Setup hledger configuration
*** TODO Download bank statements
*** TODO Create initial accounts structure
```

### System/Infrastructure Task
```org
** TODO [#3] Setup MQTT broker on rhea
:PROPERTIES:
:CREATED:       [2025-11-27 Thu 21:49]
:CATEGORY: systems
:END:

- Install mosquitto
- Configure authentication
- Setup firewall rules
```

### Personal Task
```org
** TODO Schedule dentist appointment
DEADLINE: <2025-12-15 Mon>
:PROPERTIES:
:CATEGORY: personal
:END:
```

### Recurring Meeting
```org
** STRT 1:1 with Manager
SCHEDULED: <2025-12-11 Thu 10:45 +1w>
:PROPERTIES:
:LAST_REPEAT: [2025-12-04 Thu 11:18]
:CATEGORY: work
:END:
:LOGBOOK:
- State "DONE"       from "STRT"       [2025-12-04 Thu 11:18]
:END:

Meeting notes: https://docs.example.com/...
```

## Linking TODOs

### Link to Notes
```org
** TODO Write blog post about NixOS setup

From: [[file:~/desktop/org/notes/20251203T151822--nixos-configuration__nixos.org][NixOS Configuration Note]]
```

### Link to Other TODOs
```org
** TODO Deploy new configuration
:PROPERTIES:
:CREATED:       [2025-12-04 Thu 22:33]
:END:

Depends on: [[file:todos.org::*Backup current configuration][Backup current configuration]]
```

### Link to Code
```org
** TODO Fix bug in authentication module

See: [[file:~/src/myproject/src/auth/login.ts::42][login.ts:42]]
```

## Emacs Org-Mode Integration

If you're using Emacs, these commands are available:

### Quick Capture
- `C-c c` - Org capture (opens capture template)

### TODO Management
- `C-c C-t` - Cycle TODO state
- `C-c C-s` - Schedule task
- `C-c C-d` - Set deadline
- `C-c C-w` - Refile to another heading

### Agenda Views
- `C-c a a` - Weekly agenda view
- `C-c a t` - Global TODO list
- `C-c a m` - Match tags/properties

### Navigation
- `C-c C-j` - Jump to heading
- `TAB` - Cycle visibility
- `S-TAB` - Global cycle visibility

## Using the Org Skill for TODO Operations

This skill integrates with the **Org skill** for programmatic org-mode manipulation. The Org skill provides the `org-manager` tool for reliable TODO operations.

### Tool Location
`~/.config/claude/skills/Org/tools/org-manager`

### Common Operations

**List TODOs:**
```bash
# All NEXT tasks
org-manager list ~/desktop/org/todos.org --state=NEXT

# All STRT tasks
org-manager list ~/desktop/org/todos.org --state=STRT

# Tasks scheduled for today
org-manager scheduled ~/desktop/org/todos.org

# High priority tasks (1-2)
org-manager list ~/desktop/org/todos.org --priority=1,2

# Tasks in specific section
org-manager by-section ~/desktop/org/todos.org "Work"
```

**Modify TODOs:**
```bash
# Add new TODO
org-manager add ~/desktop/org/todos.org "Task description" \
  --section=Work --priority=2 --scheduled=2025-12-10

# Update state
org-manager update-state ~/desktop/org/todos.org "Task heading" DONE

# Schedule task
org-manager schedule ~/desktop/org/todos.org "Task heading" 2025-12-10

# Set priority
org-manager priority ~/desktop/org/todos.org "Task heading" 2

# Archive completed
org-manager archive ~/desktop/org/todos.org
```

**Statistics:**
```bash
# Count by state
org-manager count ~/desktop/org/todos.org

# Get all sections
org-manager sections ~/desktop/org/todos.org

# Search for term
org-manager search ~/desktop/org/todos.org "wireguard"
```

All commands return JSON for easy parsing:
```bash
org-manager list ~/desktop/org/todos.org --state=NEXT | jq -r '.data[] | "[\(.todo)] \(.heading)"'
```

### Fallback: Direct Command Line (Legacy)

If org-manager is not available, you can use grep/sed:

```bash
# All NEXT tasks
grep -n "^\*\* NEXT" ~/desktop/org/todos.org

# Tasks scheduled for today
today=$(date +"%Y-%m-%d")
grep -B1 "SCHEDULED: <$today" ~/desktop/org/todos.org

# High priority tasks
grep "^\*\* TODO \[#[12]\]" ~/desktop/org/todos.org
```

## Suggested Workflows

### 1. Daily Review
Morning routine to plan your day:
1. Check inbox.org - refile items
2. Review SCHEDULED items for today
3. Check DEADLINE items coming up
4. Pick 2-3 NEXT actions from TODO
5. Mark one as STRT to start working

### 2. Weekly Review
End of week cleanup:
1. Archive all DONE and CANX items
2. Review all NEXT tasks - are they still relevant?
3. Reschedule stale items or cancel them
4. Plan next week's priorities
5. Update project progress

### 3. Quick Capture
When something comes up:
1. Add to inbox.org immediately
2. Don't worry about perfect formatting
3. Refile during daily/weekly review

### 4. Project Planning
Starting a new project:
1. Create project heading in Projects section
2. Break down into 3-7 sub-tasks
3. Set SCHEDULED date for first task
4. Link related notes and resources

### 5. Task Completion
When finishing a task:
1. Mark as DONE (automatically timestamps)
2. Add closing note if valuable context
3. Create follow-up tasks if needed
4. Archive during weekly review

## Tips and Best Practices

1. **Keep TODO specific**: "Fix authentication bug" > "Work on auth"
2. **One task per TODO**: Break large tasks into sub-tasks
3. **Use NEXT sparingly**: 3-5 next actions maximum
4. **Schedule realistically**: Don't over-schedule
5. **Review regularly**: Daily and weekly reviews keep system healthy
6. **Archive often**: Move DONE items out of sight
7. **Link liberally**: Connect TODOs to notes, code, docs
8. **Add context**: Brief note about why/what when not obvious
9. **Use properties**: CREATED, CATEGORY help with organization
10. **Trust the system**: Capture everything, review regularly

## Common Grep Patterns

### Find Overdue Items
```bash
# Items with past deadlines (requires date math)
grep "DEADLINE:" ~/desktop/org/todos.org | grep -v "$(date +%Y)"
```

### Find Unscheduled TODOs
```bash
# TODOs without SCHEDULED or DEADLINE
awk '/^\*\* TODO/ {p=1; todo=$0}
     p && /SCHEDULED:|DEADLINE:/ {p=0}
     p && /^$/ {print todo; p=0}' ~/desktop/org/todos.org
```

### Find Tasks Created This Week
```bash
# Tasks created this week
week_start=$(date -d "last monday" +%Y-%m-%d)
grep -A5 "CREATED:" ~/desktop/org/todos.org | grep "$week_start"
```

## Integration with Other Tools

### Create TODO from Git Commit
```bash
# After making a commit, create follow-up task
echo "** TODO Test deployment of new feature
:PROPERTIES:
:CREATED:       [$(date +'%Y-%m-%d %a %H:%M')]
:CATEGORY: work
:END:

From commit: $(git log -1 --oneline)
" >> ~/desktop/org/inbox.org
```

### Create TODO from Note
When working in denote notes, reference TODOs:

```org
* Implementation Plan

See TODO: [[file:~/desktop/org/todos.org::*Implement feature X][Implement feature X]]
```

## Summary

**Your TODO system is organized around**:
- **Work**: Job-related tasks
- **Projects**: Both personal and work projects
- **Systems**: Homelab and infrastructure
- **Personal**: Life management
- **Routines**: Recurring events
- **Appointments**: Scheduled appointments
- **Health**: Health tracking

**Key practices**:
- Capture to inbox first, refile later
- Use states: TODO → NEXT → STRT → DONE
- Priority with [#1] to [#5]
- SCHEDULED for start date, DEADLINE for due date
- Archive completed tasks regularly
- Link to notes, code, and documentation

**Active task indicators**:
- NEXT or STRT state
- Has SCHEDULED date
- Has DEADLINE
- Otherwise considered dormant (TODO, WAIT)

## Examples

**Example 1: Listing today's TODOs**
```
User: "What do I need to do today?"
→ Searches org files for TODO and NEXT states
→ Filters by today's date and SCHEDULED items
→ Shows high-priority items first
→ Includes deadlines and time estimates
→ Result: Prioritized list of today's tasks
```

**Example 2: Creating TODO from conversation**
```
User: "Remind me to review the Tekton PRs tomorrow"
→ Creates TODO in appropriate org file
→ Sets SCHEDULED date for tomorrow
→ Adds context and links
→ Tags appropriately (:tekton:review:)
→ Result: TODO captured for tomorrow
```

**Example 3: Completing and archiving TODOs**
```
User: "Mark all backport tasks as done"
→ Finds TODOs matching "backport"
→ Changes state to DONE
→ Adds CLOSED timestamp
→ Archives completed items
→ Updates project status
→ Result: Clean TODO list with completed work archived
```
