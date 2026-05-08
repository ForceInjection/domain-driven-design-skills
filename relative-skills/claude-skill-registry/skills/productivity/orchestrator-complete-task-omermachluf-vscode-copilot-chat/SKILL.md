---
name: orchestrator-complete-task
description: Workflow for parent agents completing child tasks including pulling changes, merging branches, deleting worker branches, and marking tasks complete
keywords: a2a, parent agent, child task, task completion, a2a_reportCompletion, orchestrator_completeTask, branch management, merge workflow, worktree integration, subtask integration
---

This skill provides the workflow for parent agents to properly complete and integrate work from child/worker tasks.

## When to Use This Skill

**Load this skill when:**
- You spawned a subtask via `a2a_spawn_subtask` or `a2a_spawn_parallel_subtasks`
- You receive a completion notification from your child/worker
- The notification says: `[SUBTASK UPDATE] Task "task-name" completed successfully`
- Your child called `a2a_reportCompletion`

**Applies to:**
- Orchestrators managing plan tasks
- Parent agents coordinating child workers
- Any agent that spawned subtasks and needs to integrate their work

## Critical Understanding

**Child task completion is a MULTI-STEP process that YOU (the parent) control!**

When a child worker calls `a2a_reportCompletion`, this does **NOT**:
- Automatically integrate their changes into your work
- Mark the task as complete (for orchestrators)
- Deploy dependent tasks

**You must:** Review, integrate, and explicitly complete the task following the steps below.

## Step-by-Step Completion Process

### 1. Child Reports Completion

**What happens:**
- Child worker commits their changes to their worktree branch
- Child calls `a2a_reportCompletion` (NOT `orchestrator_completeTask`)
- You receive: `[SUBTASK UPDATE] Task "implement-core" completed successfully`

**What this means:**
- The child has finished their work
- Changes are committed in their branch
- Work is isolated in their worktree until you integrate it
- For orchestrators: Task is still "running" in the plan until you complete it

### 2. Review Child's Output

**Actions:**
- Read the completion message carefully
- Verify the child accomplished the task goals
- Check if there are obvious issues or concerns

**Red flags:**
- Child mentions failures or partial completion
- Error messages in the completion note
- Child indicates uncertainty about their work
- Output doesn't match what you requested

### 3. Pull Child's Changes

Use `a2a_pull_subtask_changes` to fetch the child's changes into your worktree:

```json
{
  "subtaskWorktree": "/path/to/child/worktree"
}
```

**Note:** This pulls their branch into your worktree but doesn't merge it yet. You can review the changes before merging.

### 4. Review Code & Provide Feedback (CRITICAL)

**Before merging, you MUST review the code:**
- Inspect the files changed by the worker.
- Does the code meet the requirements?
- Is it clean and idiomatic?
- **If you are unsure:** Spawn a `@reviewer` subtask to review the changes for you.

**Decision Point:**

**A. If work is SUBSTANDARD:**
- **DO NOT** proceed to merge or complete.
- Send feedback to the worker:
  ```json
  // a2a_send_message_to_worker
  {
    "workerId": "worker-id",
    "message": "I reviewed your changes. The error handling in `api.ts` is missing. Please add try/catch blocks and retry."
  }
  ```
- The worker will continue working. Wait for their next completion report.

**B. If work is GOOD:**
- Proceed to Step 5 (Merge to Main).

### 5. Merge to Main

**Decision point:** Do dependent tasks need this code?

| Scenario | Merge? | Reason |
|----------|--------|--------|
| Dependent task modifies same files | YES | Prevent conflicts |
| Dependent task imports/uses this code | YES | They need the code |
| Tasks independent, different modules | Optional | No code dependencies |
| Parallel tasks, no overlap | Not required | No integration needed |

**If merging:**

```bash
# Switch to main branch
git checkout main

# Merge the worker's branch
git merge <worker-branch-name>

# If conflicts occur:
git status
git checkout --theirs <file>  # Accept worker's version (common pattern)
# OR manually resolve conflicts
git add .
git commit -m "Integrate task: implement-core"
```

**Why merge before completing:**
- Workers operate in isolated worktrees from `main`
- If Task B depends on Task A's code, A MUST be merged before B starts
- Otherwise B works on stale code → conflicts, duplicates, errors

### 6. Delete the Child's Branch

**CRITICAL STEP - Always delete after integrating:**

```bash
# Delete the child's branch after merging
git branch -d <child-branch-name>

# If branch wasn't merged and you want to force delete:
git branch -D <child-branch-name>
```

**Why this is mandatory:**
- Proves you've "folded" the worktree back into your work
- For orchestrators: `orchestrator_completeTask` will **FAIL** if branch still exists
- Prevents accumulation of stale branches
- Signals that the child's work is fully integrated

### 7. Mark Task Complete in Plan (Orchestrators Only)

**⚠️ This step only applies if you are an orchestrator managing a plan!**

If you're a regular parent agent (not managing an orchestrator plan), skip to step 8.

**For orchestrators only - after reviewing, merging, and deleting branch:**

```json
{
  "taskId": "implement-core"
}
```

**Tool:** `orchestrator_completeTask`

**What this does:**
- Marks task as "completed" in the plan
- Removes the worker
- Fires completion event
- Triggers deployment of dependent tasks

**Important:** This tool verifies the branch was deleted. If you get an error about the branch still existing, go back to step 6.

### 8. Continue Your Work

**For orchestrators:**
- The orchestrator service automatically deploys any tasks whose dependencies are now satisfied
- Dependent tasks will start with merged changes from main
- Wait for health monitoring to inject updates about new workers
- Monitor progress of newly deployed tasks
- Continue the cycle for each completion

**For regular parent agents:**
- You can now use the integrated code in your work
- Continue executing your own task with the child's changes available
- If you spawned multiple children, repeat this process for each completion
- When all your children are integrated, you can complete your own task

## Common Mistakes to Avoid

❌ **DON'T:**
- Assume task is complete when you receive the notification
- Call `orchestrator_completeTask` before pulling and reviewing changes
- Forget to delete the branch before marking complete
- Skip merging when dependent tasks need the code
- **Accept substandard work without review**

✅ **DO:**
- Follow all 8 steps in order
- Review completion messages carefully
- **Review the actual code changes**
- Provide feedback if work is not good enough
- Merge to main when tasks have dependencies
- Delete branches after merging
- Verify branch deletion before calling `orchestrator_completeTask`

## Quick Reference

**Orchestrator Flow:**
```
Child calls a2a_reportCompletion
    ↓
You receive notification
    ↓
Review output
    ↓
Pull changes (a2a_pull_subtask_changes)
    ↓
Merge to main (if needed)
    ↓
Delete branch (git branch -d)
    ↓
Mark complete (orchestrator_completeTask) ← Orchestrator only
    ↓
Dependent tasks auto-deploy
```

**Regular Parent Agent Flow:**
```
Child calls a2a_reportCompletion
    ↓
You receive notification
    ↓
Review output
    ↓
Pull changes (a2a_pull_subtask_changes)
    ↓
Merge to your branch (if needed)
    ↓
Delete child's branch (git branch -d)
    ↓
Continue your work with integrated changes
```

## Error Recovery

**If `orchestrator_completeTask` fails:**

Error: "Worker branch still exists"
- Check: `git branch --list <branch-name>`
- Fix: `git branch -d <branch-name>`
- Retry: Call `orchestrator_completeTask` again

**If merge conflicts occur:**
- Use `git status` to see conflicted files
- Common pattern: `git checkout --theirs <file>` (accept worker's version)
- Or manually resolve conflicts in files
- `git add .` and `git commit` to complete merge

**If child reported partial completion:**
- Don't complete the task yet
- Send feedback via `a2a_send_message_to_worker` with guidance
- For orchestrators: Retry the task with `orchestrator_retryTask`
- Or spawn a new child to finish remaining work
- Review what was completed vs what's still needed
