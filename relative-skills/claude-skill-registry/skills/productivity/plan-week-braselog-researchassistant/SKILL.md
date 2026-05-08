---
name: plan-week
description: Create a focused weekly plan based on tasks, priorities, and your work patterns. Use when the user types /plan_week, after a weekly review, at the start of a new week, or when feeling overwhelmed by options.
---

# Weekly Planning

> Create a focused weekly plan based on tasks, priorities, and your work patterns.

## When to Use
- After `/weekly_review`
- Start of a new week
- When feeling overwhelmed by options
- After a meeting that added new tasks

## Prerequisites
- `~/.researchAssistant/researcher_telos.md` for work preferences
- `.research/project_telos.md` for current priorities
- `tasks.md` for pending tasks
- Recent weekly review (recommended)

## Execution Steps

### 1. Gather Context

Read these files:
- `~/.researchAssistant/researcher_telos.md` - Productive hours, preferences
- `.research/project_telos.md` - Current phase, goals, blockers
- `.research/phase_checklist.md` - What's needed for current phase
- `tasks.md` - Pending tasks
- `.research/logs/weekly/` - Most recent weekly review
- GitHub Issues (if integrated) - Open issues

### 2. Assess Available Capacity

Ask or infer:
```
Let's plan your week. First, some logistics:

1. Any days off or unusual schedule this week?
2. Any deadlines I should know about?
3. Any meetings already scheduled that will take significant time?
4. On a scale of 1-5, how much deep work time do you expect to have?
```

### 3. Prioritize Tasks

Categorize all pending work:

```markdown
## Work Inventory

### Must Do This Week (Critical)
<!-- Blockers, deadlines, dependencies -->
- [ ] [Task] - Due: [date] | Blocks: [what]
- [ ] [Task] - Due: [date]

### Should Do (High Priority)
<!-- Important for progress but not urgent -->
- [ ] [Task] - Supports: [aim/goal]
- [ ] [Task] - Supports: [aim/goal]

### Could Do (Normal Priority)
<!-- Good to do if time allows -->
- [ ] [Task]
- [ ] [Task]

### Backlog (Not This Week)
<!-- Explicitly deprioritized -->
- [ ] [Task] - Why not: [reason]
```

### 4. Create Daily Plan

Based on user's productivity patterns:

```markdown
# Weekly Plan: [Week of DATE]

## Focus for the Week
**Primary goal**: [One clear goal for the week]
**Theme**: [e.g., "Pipeline completion", "Writing push", "Analysis sprint"]

---

## Monday
*Energy: [Based on researcher_telos.md]*

### Morning (High focus)
- [ ] [Deep work task - most important]

### Afternoon
- [ ] [Medium focus task]
- [ ] [Smaller task]

### End of Day
- [ ] Quick commit and log progress

---

## Tuesday
*Energy: [Pattern]*

### Morning
- [ ] [Task]

### Afternoon
- [ ] [Task]

---

## Wednesday
*Energy: [Pattern]*

### Morning
- [ ] [Task]

### Afternoon
- [ ] [Task]

---

## Thursday
*Energy: [Pattern]*

### Morning
- [ ] [Task]

### Afternoon
- [ ] [Task]

---

## Friday
*Energy: [Typically lower - plan accordingly]*

### Morning
- [ ] [Wrap-up or lighter task]

### Afternoon
- [ ] Weekly review prep
- [ ] Documentation catch-up
- [ ] Plan ahead for next week

---

## Buffer Time
*Unscheduled time for unexpected needs*
- 2-4 hours reserved for surprises

## This Week's Boundaries
- [ ] Will NOT work on: [Explicitly out of scope]
- [ ] Limiting: [What to time-box]
```

### 5. Account for User Patterns

From `researcher_telos.md`:

| If User Is... | Then... |
|---------------|---------|
| Morning person | Schedule deep work before noon |
| Afternoon person | Protect afternoon focus time |
| Procrastinates writing | Schedule writing first, not last |
| Forgets to commit | Add commit reminders |
| Scope creep tendency | Set explicit boundaries |
| Documentation avoider | Pair docs with coding tasks |

### 6. Present Plan

```
Here's your weekly plan:

📌 **Weekly Focus**: [Primary goal]

**Critical (Must complete)**:
1. [Task] - Monday morning
2. [Task] - By Wednesday
3. [Task] - Before Friday

**High Priority**:
4. [Task]
5. [Task]

**If Time Allows**:
6. [Task]
7. [Task]

**Explicitly NOT this week**:
- [Deprioritized item]

Does this look right? Any adjustments needed?

A) Accept this plan
B) Move something up in priority
C) Remove something (too ambitious)
D) Add something I missed
```

### 7. Save Plan

Save to `.research/logs/weekly/YYYY-MM-DD-plan.md`

## Planning Principles

1. **Start with the hardest/most important thing**
   - Don't bury critical work on Friday

2. **Time-box, don't open-end**
   - "Work on analysis" → "2 hours on analysis: complete X"

3. **Build in buffer**
   - Things always take longer
   - Unexpected issues arise

4. **Match energy to task**
   - Deep work when fresh
   - Admin when tired

5. **End-of-day ritual**
   - Commit code
   - Log progress
   - Clear desk for tomorrow

6. **Protect focus time**
   - Identify and block best hours

## Related Skills

- `weekly-review` - Review last week first
- `next` - Get immediate next action
- `monthly-review` - Bigger picture priority setting

## Notes

- Plans are guides, not contracts
- Adjust as the week unfolds
- Celebrate completing the critical items
- It's okay to not finish everything
