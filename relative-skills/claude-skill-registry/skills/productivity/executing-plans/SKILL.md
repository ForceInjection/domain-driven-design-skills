---
name: executing-plans
description: Use when partner provides a complete implementation plan to execute in controlled batches with review checkpoints - loads plan, reviews critically, executes tasks in batches, reports for review between batches
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## Execution Strategy

This skill checks for decomposition and chooses execution method:

### Detection

Check for manifest file before choosing execution:

```bash
if [[ -f "docs/plans/tasks/YYYY-MM-DD-<feature>/manifest.json" ]]; then
  # Manifest exists → Use parallel execution
  EXECUTION_MODE="parallel"
else
  # No manifest → Use sequential execution
  EXECUTION_MODE="sequential"
fi
```

### Parallel Execution (manifest exists)

**When:** `manifest.json` found in tasks directory

**Process:**
1. Load plan manifest from `docs/plans/tasks/YYYY-MM-DD-<feature>/manifest.json`
2. Invoke `parallel-subagent-driven-development` skill with manifest
3. Execute tasks in parallel batches (up to 2 concurrent subagents)
4. Code review gate after each batch
5. Continue until all tasks complete

**Benefits:**
- Up to 2 tasks run concurrently per batch
- ~40% faster for parallelizable plans
- 90% context reduction per task

### Sequential Execution (no manifest)

**When:** No `manifest.json` found

**Process:**
1. Load monolithic plan from `docs/plans/YYYY-MM-DD-<feature>.md`
2. Invoke `subagent-driven-development` skill
3. Execute tasks sequentially (one at a time)
4. Code review gate after each task
5. Continue until all tasks complete

**Use case:**
- Simple plans (1-3 tasks)
- Sequential work that can't parallelize
- Prefer simplicity over speed

### CRITICAL Constraint

⚠️ **Cannot use parallel-subagent-driven-development without manifest.json**

If manifest does not exist → MUST use sequential mode (subagent-driven-development)

### Recommendation

Always decompose plans with 4+ tasks to enable parallel execution.
Run `/cc:parse-plan` to create manifest before execution.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Batch
**Default: First 3 tasks**

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Report
When batch complete:
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

### Step 4: Continue
Based on feedback:
- Apply changes if needed
- Execute next batch
- Repeat until complete

### Step 5: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
