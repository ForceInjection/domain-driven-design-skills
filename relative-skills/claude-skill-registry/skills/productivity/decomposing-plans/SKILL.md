---
name: decomposing-plans
description: Use after writing-plans to decompose monolithic plan into individual task files and identify tasks that can run in parallel (up to 2 subagents simultaneously)
allowed-tools: [Read, Write, Bash]
---

# Decomposing Plans for Parallel Execution

Run immediately after `/write-plan` to break monolithic plan into task files and identify parallelization opportunities.

**Core principle:** Individual task files save context + parallel batches save time = efficient execution

## When to Use

Use after `/write-plan` when you have a monolithic implementation plan and want to:
- Split it into individual task files (saves context tokens for subagents)
- Identify which tasks can run in parallel (up to 2 simultaneous subagents)
- Prepare for parallel-subagent-driven-development

## Prerequisites

**REQUIRED:** Must have monolithic plan file at `docs/plans/YYYY-MM-DD-<feature-name>.md`

## The Process

### Step 1: Locate Plan File

User provides plan file path, or find most recent:
```bash
ls -t docs/plans/*.md | head -1
```

### Step 2: Run Decomposition Script

Execute Python helper script:
```bash
python superpowers/skills/decomposing-plans/decompose-plan.py <plan-file>
```

**Script does:**
1. Parses monolithic plan to extract tasks
2. Analyzes dependencies (file-based and task-based)
3. Identifies parallel batches (max 2 tasks at once)
4. Creates individual task files
5. Generates manifest.json
6. Reports statistics

### Step 3: Review Generated Files

Check output directory `docs/plans/tasks/<plan-name>/`:
- Individual task files: `<feature>-task-NN.md`
- Execution manifest: `<feature>-manifest.json`

**Example structure:**
```
docs/plans/
├── 2025-01-18-user-auth.md          # Monolithic plan
└── tasks/
    └── 2025-01-18-user-auth/         # Plan-specific subfolder
        ├── user-auth-task-01.md
        ├── user-auth-task-02.md
        ├── user-auth-task-03.md
        └── user-auth-manifest.json
```

### Step 4: Verify Task Decomposition

Read a few task files to verify:
- Tasks are correctly extracted
- Dependencies are accurate
- Files to modify are identified
- Verification checklists are present

### Step 5: Review Manifest

Read `<feature>-manifest.json` to verify:
- Parallel batches make sense
- No conflicting tasks in same batch
- Dependencies are correct

### Step 6: Adjust if Needed

If decomposition needs adjustment:
- Manually edit task files
- Manually edit manifest.json parallel_batches array
- Update dependencies if needed

### Step 7: Announce Results

Tell the user:
```
✅ Plan decomposed successfully!

Total tasks: N
Parallel batches: M
  - Pairs (2 parallel): X
  - Sequential: Y
Estimated speedup: Z%

Task files: docs/plans/tasks/<plan-name>/<feature>-task-*.md
Manifest: docs/plans/tasks/<plan-name>/<feature>-manifest.json

Next: Use parallel-subagent-driven-development skill
```

## Task File Format

Each task file created:

```markdown
# Task NN: [Task Name]

## Dependencies
- Previous tasks: [list or "none"]
- Must complete before: [list or "none"]

## Parallelizable
- Can run in parallel with: [task numbers or "none"]

## Implementation

[Exact steps from monolithic plan for THIS task only]

## Files to Modify
- path/to/file1.ts
- path/to/file2.ts

## Verification Checklist
- [ ] Implementation complete
- [ ] Tests written (TDD - test first!)
- [ ] All tests pass
- [ ] Lint/type check clean
- [ ] Code review requested
- [ ] Code review passed
```

## Manifest Format

```json
{
  "plan": "docs/plans/2025-01-18-feature.md",
  "feature": "feature-name",
  "created": "2025-01-18T10:00:00Z",
  "total_tasks": 5,
  "tasks": [
    {
      "id": 1,
      "title": "Implement user model",
      "file": "docs/plans/tasks/feature-task-01.md",
      "dependencies": [],
      "blocks": [3],
      "files": ["src/models/user.ts"],
      "status": "pending"
    },
    {
      "id": 2,
      "title": "Implement logger",
      "file": "docs/plans/tasks/feature-task-02.md",
      "dependencies": [],
      "blocks": [],
      "files": ["src/utils/logger.ts"],
      "status": "pending"
    },
    {
      "id": 3,
      "title": "Add user validation",
      "file": "docs/plans/tasks/feature-task-03.md",
      "dependencies": [1],
      "blocks": [],
      "files": ["src/models/user.ts"],
      "status": "pending"
    }
  ],
  "parallel_batches": [
    [1, 2],  // Tasks 1 and 2 can run together
    [3]      // Task 3 must wait for task 1
  ]
}
```

## Dependency Analysis

**Script analyzes three types of dependencies:**

### 1. Explicit Task Dependencies
If task content mentions "after task N" or "depends on task N":
```
Task 3: "After task 1 completes, add validation..."
→ Task 3 depends on Task 1
```

### 2. File-Based Dependencies
If tasks modify the same file:
```
Task 1: Modifies src/models/user.ts
Task 3: Modifies src/models/user.ts
→ Task 3 depends on Task 1 (sequential)
```

### 3. Default Sequential
Unless marked "independent" or "parallel", tasks depend on previous task:
```
Task 1: ...
Task 2: (no explicit dependency mentioned)
→ Task 2 depends on Task 1
```

## Parallel Batch Identification

**Algorithm:**
1. Find tasks with no unsatisfied dependencies
2. Group up to 2 tasks that:
   - Have no mutual dependencies
   - Don't modify same files
   - Don't block each other
3. Create batch
4. Repeat until all tasks scheduled

**Max 2 tasks per batch** (constraint for code review quality)

## Benefits

### Context Savings
- Before: Each subagent reads ~5000 tokens (monolithic plan)
- After: Each subagent reads ~500 tokens (task file)
- **90% context reduction per subagent**

### Time Savings
- Before: 5 tasks × 10 min = 50 min
- After: 3 batches × 10 min = 30 min (if 2 parallel pairs)
- **40% time reduction for parallelizable plans**

### Clarity
- Each subagent has focused, bounded scope
- Clear verification checklist per task
- No confusion about which task to implement

## Red Flags

**Never:**
- Skip running the decomposition script (manual decomposition error-prone)
- Proceed with decomposed plan without reviewing manifest
- Ignore dependency conflicts flagged by script
- Skip verifying parallel batches make sense

**If script fails:**
- Check plan file format (needs clear task sections)
- Verify plan has recognizable task markers ("## Task N:", etc.)
- Manually create task files if plan format is unusual
- Report issue for script improvement

## Integration

**Required prerequisite:**
- **writing-plans** - REQUIRED: Creates monolithic plan that this skill decomposes

**This skill enables:**
- **parallel-subagent-driven-development** - REQUIRED NEXT: Executes the decomposed plan with parallel subagents

**Alternative workflow:**
- **subagent-driven-development** - Use if you DON'T want parallel execution (works with monolithic plan)

## Example Output

```bash
$ python superpowers/skills/decomposing-plans/decompose-plan.py docs/plans/2025-01-18-user-auth.md

📖 Reading plan: docs/plans/2025-01-18-user-auth.md
✓ Found 5 tasks

🔍 Analyzing dependencies...
  Task 1: No dependencies
  Task 2: No dependencies
  Task 3: Depends on task 1 (file conflict: src/models/user.ts)
  Task 4: Depends on task 3
  Task 5: No dependencies

⚡ Identifying parallelization opportunities...
  Batch 1: Tasks 1, 2 (parallel)
  Batch 2: Tasks 3, 5 (parallel)
  Batch 3: Task 4 (sequential)

📝 Writing 5 task files to docs/plans/tasks/2025-01-18-user-auth/
  ✓ user-auth-task-01.md
  ✓ user-auth-task-02.md
  ✓ user-auth-task-03.md
  ✓ user-auth-task-04.md
  ✓ user-auth-task-05.md

📋 Writing execution manifest...
  ✓ user-auth-manifest.json

============================================================
✅ Plan decomposition complete!
============================================================
Total tasks: 5
Parallel batches: 3
  - Pairs (2 parallel): 2
  - Sequential: 1
Estimated speedup: 40.0%

Manifest: docs/plans/tasks/2025-01-18-user-auth/user-auth-manifest.json

Next: Use parallel-subagent-driven-development skill
```

## Troubleshooting

### Script Can't Parse Tasks

**Problem:** Script reports "Found 0 tasks"

**Solutions:**
1. Check plan format - needs clear task markers:
   - `## Task 1: Title`
   - `## 1. Title`
   - `**Task 1:** Title`
2. Manually add task markers if plan uses different format
3. Run script with `--verbose` for debug output

### Incorrect Dependencies

**Problem:** Script identifies wrong dependencies

**Solutions:**
1. Review manifest.json parallel_batches
2. Manually edit manifest to fix dependencies
3. Add explicit dependency markers in plan ("depends on task N")

### Too Conservative (Too Many Sequential)

**Problem:** Script creates too many sequential batches

**Solutions:**
1. Mark tasks as "independent" in plan text
2. Manually edit manifest parallel_batches to add parallelization
3. Verify file paths are correctly extracted

## Next Steps

After decomposition:
1. Review task files for accuracy
2. Review manifest for correct dependencies
3. Announce results to user
4. Proceed to parallel-subagent-driven-development skill

## After Decomposition

After decomposition completes successfully, prompt user:

```
Plan decomposed into X tasks across Y parallel batches.

Manifest: `docs/plans/tasks/YYYY-MM-DD-<feature>/manifest.json`
Tasks: `docs/plans/tasks/YYYY-MM-DD-<feature>/<task-files>`

Options:
A) Review the plan with plan-review
B) Execute immediately with parallel-subagent-driven-development
C) Save and exit (resume later with /cc:resume)

Choose: (A/B/C)
```

**If user chooses A:**
- Invoke `plan-review` skill
- After review completes and plan approved
- Return to this prompt (offer B or C)

**If user chooses B:**
- Proceed directly to `parallel-subagent-driven-development` skill
- Begin executing tasks in parallel batches

**If user chooses C:**
- Invoke `state-persistence` skill to save execution checkpoint
- Save as `YYYY-MM-DD-<feature>-execution.md` with:
  - Plan reference and manifest location
  - Status: ready to execute, 0 tasks complete
  - Next step: Resume with `/cc:resume` and execute
- Exit workflow after save completes
