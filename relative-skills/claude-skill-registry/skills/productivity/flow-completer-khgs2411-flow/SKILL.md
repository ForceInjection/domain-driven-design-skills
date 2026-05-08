---
name: flow-completer
description: Mark tasks and phases complete after verification. Use when finishing tasks, closing phases, or marking work done. Ensures all work verified before completion.
---

# Flow Completer

Mark tasks and phases complete after verifying all work is done. This skill enforces completion gates to ensure nothing is forgotten before moving forward.

## When to Use This Skill

Activate when the user wants to finish work:
- "Finish this task"
- "Mark task complete"
- "Done with this task"
- "Complete the task"
- "Finish this phase"
- "Mark phase complete"
- "Done with this phase"
- "Close the task"
- "Close the phase"

## Completion Philosophy

**Flow's Core Principle**: Verify before closing. Every completion requires verification that all work is done, tested, and documented.

**Key Gates**:
- **Task Completion Gate**: All iterations ✅ COMPLETE (or ❌ CANCELLED/🔮 DEFERRED)
- **Phase Completion Gate**: All tasks ✅ COMPLETE (or ❌ CANCELLED)
- **Documentation Gate**: All changes documented, notes updated

**Completion Pattern**: Verify → Update Status → Advance Pointer → Report

## Task Completion Workflow

### Step 1: Read Task File

Before marking task complete, read the task file to understand current state:

**READ**: `.flow/phase-N/task-M.md`

**Extract**:
- Task name and status
- All iterations (if task has iterations)
- All action items (if standalone task)
- Current work status

### Step 2: Verify Task Completion

**Verification Checklist**:

```
IF task has iterations:
    FOR EACH iteration:
        IF status = ⏳ PENDING or 🚧 IN PROGRESS:
            ❌ FAIL: "Iteration N: [Name] is not complete"
        IF status = ❌ CANCELLED or 🔮 DEFERRED:
            ✅ PASS (acceptable, not blocking)
        IF status = ✅ COMPLETE:
            ✅ PASS
    IF ALL iterations are ✅/❌/🔮:
        ✅ PASS task verification

ELSE IF standalone task:
    IF any action items unchecked `- [ ]`:
        ❌ FAIL: "X action items incomplete"
    IF all action items checked `- [x]`:
        ✅ PASS task verification
```

**Additional Checks**:
- [ ] Implementation notes updated (if task had implementation)
- [ ] Files modified documented
- [ ] No unresolved blockers mentioned
- [ ] Verification section filled out

### Step 3: Mark Task Complete

If verification passes:

1. **Update task file**:
   ```markdown
   # Task N: Name

   **Status**: ✅ COMPLETE (2025-MM-DD)
   ```

2. **Update DASHBOARD.md**:
   - Find task in "Progress Overview"
   - Change marker: `⏳ Task N: Name` → `✅ Task N: Name`
   - Update phase completion percentage
   - Advance "Current Work" pointer to next pending task

3. **Report to user**:
   ```
   ✅ Task N: [Name] marked complete!

   Completed:
   - [X] iterations complete (or Y cancelled/deferred)
   - All action items verified
   - Documentation updated

   Next: [Next task or phase status]
   ```

### Step 4: Handle Incomplete Work

If verification fails:

1. **Report incomplete items**:
   ```
   ❌ Cannot mark task complete. Incomplete work found:

   Iterations:
   - ⏳ Iteration 2: [Name] - Status: PENDING
   - 🚧 Iteration 3: [Name] - Status: IN PROGRESS

   OR

   Action Items:
   - [ ] 3 unchecked action items

   Complete these first, then use `/flow-task-complete` again.
   ```

2. **Suggest actions**:
   - If iterations pending: "Use `/flow-next-iteration` to continue work"
   - If action items unchecked: "Complete remaining action items"
   - If user wants to defer: "Use `/flow-iteration-add` to mark iteration 🔮 DEFERRED"

## Phase Completion Workflow

### Step 1: List All Tasks in Phase

**READ**: `.flow/phase-N/` directory

**Extract**:
- All task files in phase directory
- Count total tasks
- Determine status of each task

### Step 2: Verify Phase Completion

**Verification Checklist**:

```
FOR EACH task in phase:
    IF task status = ⏳ PENDING or 🚧 IN PROGRESS:
        ❌ FAIL: "Task N: [Name] is not complete"
    IF task status = ❌ CANCELLED:
        ✅ PASS (acceptable, not blocking)
    IF task status = ✅ COMPLETE:
        ✅ PASS

IF ALL tasks are ✅/❌:
    ✅ PASS phase verification
```

**Additional Checks**:
- [ ] Phase goals achieved (check DASHBOARD.md phase description)
- [ ] All deliverables complete
- [ ] No pending work in any task

### Step 3: Mark Phase Complete

If verification passes:

1. **Update DASHBOARD.md**:
   - Find phase in "Progress Overview"
   - Change header: `### Phase N: Name` → `### Phase N: Name ✅`
   - Update phase status line
   - Advance "Current Work" to next phase

2. **Report to user**:
   ```
   ✅ Phase N: [Name] marked complete!

   Completed:
   - [X] tasks complete (Y cancelled)
   - All phase goals achieved

   Next Phase: Phase [N+1]: [Name]
   OR
   Project complete! 🎉
   ```

### Step 4: Handle Incomplete Work

If verification fails:

1. **Report incomplete tasks**:
   ```
   ❌ Cannot mark phase complete. Incomplete tasks found:

   Tasks:
   - ⏳ Task 2: [Name] - Status: PENDING
   - 🚧 Task 3: [Name] - Status: IN PROGRESS

   Complete these first, or cancel if scope changed.
   ```

2. **Suggest actions**:
   - "Use `/flow-task-start` to continue Task N"
   - "Use `/flow-task-complete` to finish Task N"
   - If scope changed: "Consider marking Task N as ❌ CANCELLED"

## Completion Slash Commands

### `/flow-task-complete`

**Use when**: All iterations/action items done for current task

**Prerequisites**:
- All iterations ✅ COMPLETE (or ❌/🔮)
- All action items checked off (if standalone)
- Documentation updated

**Effect**:
- Marks task ✅ COMPLETE with date
- Updates DASHBOARD.md progress
- Advances current work pointer

### `/flow-phase-complete`

**Use when**: All tasks done in current phase

**Prerequisites**:
- All tasks ✅ COMPLETE (or ❌ CANCELLED)
- Phase goals achieved

**Effect**:
- Marks phase ✅ COMPLETE
- Updates DASHBOARD.md
- Advances to next phase or project end

## Edge Cases

### Cancelled or Deferred Work

**Cancelled Iterations** (❌):
- Not blocking for task completion
- Document why cancelled in iteration notes
- Examples: Scope changed, not needed, replaced by better approach

**Deferred Iterations** (🔮):
- Not blocking for task completion
- Document why deferred (V2, future version)
- Examples: Nice-to-have, optimization, future enhancement

**Cancelled Tasks** (❌):
- Not blocking for phase completion
- Document why cancelled in task notes
- Examples: Duplicate work, scope change, no longer needed

### Partial Completion

**Scenario**: Task has 5 iterations, 3 complete, 2 deferred

```
✅ Iteration 1: Basic Implementation - COMPLETE
✅ Iteration 2: Core Features - COMPLETE
✅ Iteration 3: Testing - COMPLETE
🔮 Iteration 4: Advanced Features - DEFERRED (V2)
🔮 Iteration 5: Optimizations - DEFERRED (V2)
```

**Action**: Task can be marked complete! Deferred work doesn't block.

**Report**:
```
✅ Task can be marked complete!

Completed: 3/5 iterations
Deferred to V2: 2 iterations (documented)

This is valid - deferred work doesn't block completion.
```

### Blocked Work

**Scenario**: Task has iteration marked ❌ BLOCKED

```
✅ Iteration 1: Setup - COMPLETE
❌ Iteration 2: Implementation - BLOCKED (external dependency unavailable)
⏳ Iteration 3: Testing - PENDING
```

**Action**: Cannot mark task complete - blocked iteration needs resolution

**Report**:
```
❌ Cannot mark task complete. Found blocked work:

Iteration 2: Implementation - ❌ BLOCKED
Blocker: External dependency unavailable

Resolution options:
1. Unblock iteration and complete it
2. Mark iteration ❌ CANCELLED if no longer needed
3. Mark iteration 🔮 DEFERRED if can be done later
```

## Completion Verification Patterns

### Pattern 1: Task with All Iterations Complete

```
✅ Iteration 1: Skeleton - COMPLETE (2025-10-15)
✅ Iteration 2: Veins - COMPLETE (2025-10-18)
✅ Iteration 3: Flesh - COMPLETE (2025-10-22)
```

**Verification**: ✅ PASS - All iterations complete

**Action**: Mark task complete

### Pattern 2: Task with Mixed Status

```
✅ Iteration 1: Basic Feature - COMPLETE (2025-10-15)
❌ Iteration 2: Advanced Feature - CANCELLED (scope change)
🔮 Iteration 3: Optimization - DEFERRED (V2)
```

**Verification**: ✅ PASS - No pending/in-progress iterations

**Action**: Mark task complete (cancelled and deferred are acceptable)

### Pattern 3: Standalone Task

```
Action Items:
- [x] Create component
- [x] Add tests
- [x] Update documentation
- [x] Deploy to staging
```

**Verification**: ✅ PASS - All action items checked

**Action**: Mark task complete

### Pattern 4: Phase with All Tasks Done

```
### Phase 2: Core Features
- ✅ Task 1: User Authentication - COMPLETE
- ✅ Task 2: API Endpoints - COMPLETE
- ❌ Task 3: Admin Dashboard - CANCELLED (out of V1 scope)
- ✅ Task 4: Error Handling - COMPLETE
```

**Verification**: ✅ PASS - No pending/in-progress tasks

**Action**: Mark phase complete

## Best Practices

**DO**:
- ✅ Verify ALL iterations/tasks before marking complete
- ✅ Check documentation is updated
- ✅ Update both task file AND DASHBOARD.md
- ✅ Advance current work pointer after completion
- ✅ Report summary of what was completed

**DON'T**:
- ❌ Skip verification checks
- ❌ Mark incomplete work as complete
- ❌ Forget to update DASHBOARD.md
- ❌ Leave current work pointer on completed item
- ❌ Ignore blocked or pending iterations

## Examples

### Example 1: Completing Task with All Iterations Done

```
User: "Mark this task complete"

AI Process:
1. Read task file (task-2.md)
2. Find 3 iterations, all marked ✅ COMPLETE
3. Verify documentation updated
4. All checks pass

AI Response:
"✅ Task 2: API Integration marked complete!

Verification Results:
✅ All 3 iterations complete:
  - Iteration 1: Basic Setup (2025-10-15)
  - Iteration 2: Error Handling (2025-10-18)
  - Iteration 3: Testing (2025-10-22)
✅ Implementation notes updated
✅ 12 files modified documented
✅ Tests passing

Updated DASHBOARD.md - Phase 2 now 50% complete (2/4 tasks done)

Next: Task 3: Database Integration (⏳ PENDING)"
```

### Example 2: Cannot Complete - Found Incomplete Work

```
User: "Finish this task"

AI Process:
1. Read task file (task-3.md)
2. Find 4 iterations: 2 complete, 1 in progress, 1 pending
3. Verification FAILS

AI Response:
"❌ Cannot mark task complete. Found incomplete work:

Iterations Status:
✅ Iteration 1: Schema Design - COMPLETE
✅ Iteration 2: Migrations - COMPLETE
🚧 Iteration 3: Data Access Layer - IN PROGRESS (60% done)
⏳ Iteration 4: Testing - PENDING

Complete Iteration 3 and 4 first, then use `/flow-task-complete`.

Current action items for Iteration 3:
- [x] Create User repository
- [x] Create Post repository
- [ ] Create Comment repository (← CURRENT)
- [ ] Add transaction support
- [ ] Add error handling"
```

### Example 3: Completing Phase

```
User: "Mark Phase 2 complete"

AI Process:
1. List all tasks in phase-2/ directory
2. Find 5 tasks: 4 complete, 1 cancelled
3. Verify phase goals achieved
4. All checks pass

AI Response:
"✅ Phase 2: Core Features marked complete!

Verification Results:
✅ All tasks done:
  - Task 1: User Auth - COMPLETE
  - Task 2: API Endpoints - COMPLETE
  - Task 3: Data Layer - COMPLETE
  - Task 4: Error Handling - COMPLETE
  - Task 5: Admin Panel - CANCELLED (scope change, documented)
✅ Phase goals achieved:
  - User authentication working
  - API fully functional
  - Data persistence implemented
  - Error handling in place

Phase 2 Duration: 3 weeks (Oct 1 - Oct 22)

Updated DASHBOARD.md - Project now 66% complete (2/3 phases done)

Next Phase: Phase 3: Testing & Polish (⏳ PENDING)"
```

### Example 4: Completing Task with Deferred Work

```
User: "Complete this task"

AI Process:
1. Read task file (task-4.md)
2. Find 5 iterations: 3 complete, 2 deferred to V2
3. Verification PASSES (deferred is acceptable)

AI Response:
"✅ Task 4: Performance Optimization can be marked complete!

Verification Results:
✅ Core iterations complete (3/5):
  - Iteration 1: Identify Bottlenecks - COMPLETE
  - Iteration 2: Database Indexing - COMPLETE
  - Iteration 3: Caching Layer - COMPLETE
🔮 Deferred to V2 (2/5):
  - Iteration 4: Advanced Caching - DEFERRED (nice-to-have)
  - Iteration 5: Load Balancing - DEFERRED (premature optimization)

This is valid! Deferred work doesn't block task completion.

Updated task status to ✅ COMPLETE (2025-10-22)
Phase 3 now 75% complete (3/4 tasks done)

Next: Task 5: Documentation (⏳ PENDING)"
```

## Interaction with Other Flow Skills

**Build Stage** (flow-builder Skill):
- `/flow-implement-complete` - Marks iteration complete
- That feeds into this skill's task completion checks

**Complete Stage** (This Skill):
- `/flow-task-complete` - Mark task done ← YOU ARE HERE
- `/flow-phase-complete` - Mark phase done ← YOU ARE HERE

**Navigate Stage** (flow-navigator Skill):
- `/flow-status` - Check what's left before completing
- `/flow-next` - See next work after completing

## References

- **Task Completion Pattern**: DEVELOPMENT_FRAMEWORK.md lines 1837-1871
- **Status Markers**: DEVELOPMENT_FRAMEWORK.md lines 1872-1968
- **Phase Management**: DEVELOPMENT_FRAMEWORK.md lines 170-237

## Completion Gate Checklist

### Before Completing Task

```
[ ] All iterations ✅ COMPLETE (or ❌/🔮)
[ ] OR all action items checked (standalone task)
[ ] Implementation notes updated
[ ] Files modified documented
[ ] No unresolved blockers
[ ] Verification section complete
```

If ALL checked → Use `/flow-task-complete`

If ANY unchecked → Complete remaining work first

### Before Completing Phase

```
[ ] All tasks ✅ COMPLETE (or ❌ CANCELLED)
[ ] Phase goals achieved
[ ] All deliverables done
[ ] No pending work in phase
```

If ALL checked → Use `/flow-phase-complete`

If ANY unchecked → Complete remaining tasks first
