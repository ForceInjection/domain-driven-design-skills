---
name: plan-tracking
description: Track working plans and tasks using Miller's mutable plan system. Activates when planning work, tracking progress, or managing multiple tasks. Provides working memory with atomic updates and one active plan enforcement.
allowed-tools: mcp__miller__plan, mcp__miller__fast_search
---

# Plan Tracking Skill

## Activation Announcement

**IMPORTANT**: When this skill activates, ALWAYS start your response with:

```
📋 **Plan Tracking Active**
Managing working memory with Miller's mutable plan system...
```

This provides a visual indicator to the user that the skill is running.

## Purpose
Use Miller's **mutable plan system** for working memory - track current tasks, update progress, manage active work.

## When to Activate
- Starting multi-step work (needs planning)
- Tracking task progress
- Switching between different efforts
- Organizing complex features
- Managing "what am I working on?"

## The Plan System

**Working Memory vs Knowledge Base:**
- **Checkpoints** = Immutable knowledge (what was done)
- **Plans** = Mutable working memory (what needs doing)

**One Active Plan Rule:**
- Only ONE plan can be "active" at a time
- Others are "pending" or "completed"
- Enforces focus, prevents context switching

## Plan Operations (6 Actions)

### 1. Save - Create New Plan

```
Starting work -> create plan

plan({
  action: "save",
  title: "Add Search Feature",
  content: "## Tasks\n- [ ] Design API\n- [ ] Implement backend\n- [ ] Add tests",
  activate: true  // defaults to true
})

-> Creates plan with ID
-> Auto-activates (deactivates other plans)
```

**When:** Starting new multi-step work that needs tracking

### 2. Get - Retrieve Specific Plan

```
Check plan status -> get by ID

plan({
  action: "get",
  id: "plan_add-search-feature"
})

-> Returns plan with current status, content, timestamp
```

### 3. List - See All Plans

```
See all plans -> list with optional filter

plan({
  action: "list",
  status: "active"  // optional: "active", "pending", "completed"
})

-> Returns plans sorted by timestamp (most recent first)
```

### 4. Activate - Switch Active Plan

```
Switch focus -> activate different plan

plan({
  action: "activate",
  id: "plan_refactor-database"
})

-> Sets this plan to "active"
-> Other plans become "pending"
-> Only ONE plan active at a time
```

### 5. Update - Modify Existing Plan

```
Update progress -> modify plan content/status

plan({
  action: "update",
  id: "plan_add-search-feature",
  content: "## Tasks\n- [x] Design API\n- [ ] Implement backend\n- [ ] Add tests"
})

-> Atomic update
-> Timestamp updated automatically
```

**When:** Progress made, tasks completed, content needs updating

### 6. Complete - Mark Plan Done

```
Work finished -> mark complete

plan({
  action: "complete",
  id: "plan_add-search-feature"
})

-> Sets status to "completed"
-> Plan archived from active work
```

## The Complete Plan Workflow

```
1. Save - Create Plan
   plan({ action: "save", title: "...", content: "## Tasks\n- [ ] ..." })
   -> Auto-activates (ONE active plan)
             |
             v
2. Work & Update Progress
   -> Complete tasks
   plan({ action: "update", id: "...", content: "- [x] Done\n- [ ] Next"})
   -> Update as you go
             |
             v
3. Complete When Done
   plan({ action: "complete", id: "..." })
   -> Status: "completed"
   -> Archived from active work
             |
             v
   Plan finished, checkpoint created!
```

## Plan Content Format (Markdown)

**Recommended structure:**

```markdown
## Tasks
- [ ] Task 1
- [ ] Task 2
- [x] Task 3 (completed)

## Notes
- Important decision: chose X over Y
- Blocked by: dependency Z

## Progress
Started: 2025-01-10
Updated: 2025-01-11
```

**Key points:**
- Use markdown checkboxes `- [ ]` and `- [x]`
- Task counts are automatically calculated from checkboxes
- Organize with headers
- Track blockers and notes

## Workflow Patterns

### Pattern 1: Feature Development

```
Start feature:
  plan({ action: "save", title: "User Profile Page",
         content: "## Tasks\n- [ ] Design\n- [ ] Backend\n- [ ] Frontend\n- [ ] Tests" })

During work:
  plan({ action: "update", id: "plan_user-profile-page",
         content: "## Tasks\n- [x] Design\n- [x] Backend\n- [ ] Frontend\n- [ ] Tests" })

When done:
  plan({ action: "complete", id: "plan_user-profile-page" })
  checkpoint({ description: "Completed user profile page", tags: ["feature"] })
```

### Pattern 2: Multi-Track Work

```
Have 3 efforts in flight:

  plan({ action: "list" })
  -> Shows all plans with status

Switch focus:
  plan({ action: "activate", id: "plan_urgent-bugfix" })
  -> Urgent work becomes active
  -> Other plans pending (still accessible)

Return to original work:
  plan({ action: "activate", id: "plan_refactor-database" })
  -> Resume where you left off
```

## Key Behaviors

### DO
- Create plan when starting multi-step work
- Update plan as progress is made
- Use ONE active plan at a time (focus!)
- Complete plans when done (closure)
- Use markdown checkboxes for tasks
- Checkpoint major milestones (complement plans)

### DON'T
- Create plans for single-step tasks (use checkpoint when done)
- Forget to update progress (stale plans are useless)
- Have multiple active plans (enforced by system anyway)
- Skip completing plans (mark closure!)
- Use plans as knowledge base (that's checkpoints)

## Success Criteria

This skill succeeds when:
- Plans track all active work
- Only ONE plan active at a time
- Plans updated as progress is made
- Completed plans archived properly
- Clear visibility into work streams
- Easy to switch focus between efforts
- Plans complement checkpoints (not duplicate)
