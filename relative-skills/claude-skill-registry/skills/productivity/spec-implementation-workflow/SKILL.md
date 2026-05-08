---
name: spec-implementation-workflow
description: Use when spec verified and ready for implementation to orchestrate development using isolated workspace and quality gates - sets up worktree, executes tasks via subagent-driven or sequential approach, verifies completion, and finishes development branch
---

# Spec Implementation Workflow

## What It Does

1. Loads spec, tasks, requirements, visuals
2. Presents implementation approach options
3. Sets up isolated workspace (worktree)
4. Executes tasks with chosen approach
5. Tracks progress (updates tasks.md, creates reports)
6. Runs implementation verification
7. Completes development (merge/PR/etc.)

**Uses Superpowers patterns for quality gates.**

## The Process

### Step 1: Load Context

```bash
SPEC="[provided by orchestrator]"

cat "$SPEC/spec.md"
cat "$SPEC/tasks.md"
cat "$SPEC/planning/requirements.md"
ls -la "$SPEC/planning/visuals/"
cat specs/product/tech-stack.md
```

**Analyze:**
- Task groups and dependencies
- Reusability notes
- Visual assets
- Tech stack

### Step 2: Present Approach Options

```
Ready to implement: [Spec Name]

Task breakdown:
[X] task groups:
1. [Group 1] - [Y tasks]
2. [Group 2] - [Z tasks]
3. [Group 3] - [A tasks]
4. [Group 4] - Verification

Implementation approach:

**Option A: Subagent-Driven Development** (Recommended)
- Fresh subagent per task group
- Code review after each group
- Fast iteration with quality gates
- Less human intervention
- Best for: Independent task groups

**Option B: Sequential Execution**
- Batch execution with checkpoints
- You review between batches
- More hands-on control
- Best for: Tightly coupled tasks

Which approach?
```

**WAIT for choice.**

### Step 3: Set Up Isolated Workspace

**Use Superpowers skill:**

```
Skill("using-git-worktrees")
  feature_name: [spec-name]
  branch_name: feature/[spec-name]
```

**Skill handles:**
- Directory selection (.worktrees vs global)
- .gitignore verification
- Worktree creation
- Project setup (npm install, etc.)
- Clean test baseline

**After setup:**
```
✅ Workspace ready

Worktree: [path]
Branch: feature/[spec-name]
Baseline tests: [X passing, 0 failures]

Ready to implement.
```

### Step 4: Execute Based on Approach

#### **Approach A: Subagent-Driven**

**Use Superpowers skill:**

```
Skill("subagent-driven-development")
  spec_path: [spec-path]
  tasks_file: [spec-path]/tasks.md
  working_directory: [worktree-path]
```

**Skill handles:**
1. Loads tasks.md
2. For each task group:
   - Dispatches fresh subagent
   - Subagent follows TDD
   - Code review after group
   - Fixes issues from review
   - Marks tasks complete
3. Final code review
4. Reports completion

**Subagents use `verification-before-completion` before claiming done.**

#### **Approach B: Sequential**

**Use Superpowers skill:**

```
Skill("executing-plans")
  plan_file: [spec-path]/tasks.md
  working_directory: [worktree-path]
```

**Skill handles:**
1. Loads tasks.md as plan
2. Executes first batch (first task group)
3. Reports results
4. Waits for your feedback
5. Continues to next batch
6. Repeats until complete

**You review between batches.**

### Step 5: Track Progress

During implementation:

**Update tasks.md:**
```bash
# Mark completed tasks
sed -i 's/^- \[ \] \([0-9]\.[0-9]\)/- [x] \1/' "$SPEC/tasks.md"
```

**Create implementation reports:**
```bash
cat > "$SPEC/implementation/[N]-[group]-implementation.md" <<'EOF'
# Implementation Report: [Group Name]

## Date
[Current date]

## Implementer
[Subagent or sequential]

## Tasks Completed
- [x] Task N.1
- [x] Task N.2

## Files Changed
[List]

## Tests Written
- Total: [X] tests
- All passing: [Yes/No]
- Test files: [list]

## Issues Encountered
[Any issues]

## Notes
[Decisions made]
EOF
```

### Step 6: Run Implementation Verification

After all task groups complete:

**Use SDD skill:**

```
Skill("implementation-verification")
  spec_path: [spec-path]
```

**Skill handles:**
1. Verifies all tasks marked complete
2. Updates roadmap
3. Runs entire test suite
4. Creates final verification report

**After verification:**

**If PASSED:**
```
✅ Implementation Verified

All tasks: ✅
Roadmap: Updated ✅
Tests: [X passing, 0 failures]

Report: verification/final-verification.md

Ready to complete work.
```

**If FAILED:**
```
⚠️  Implementation Issues

Tasks: [Status]
Tests: [X passing, Y failures]

Failed tests:
1. [Test]

Options:
1. Review failures and fix
2. See full report
3. Return to implementation

What next?
```

### Step 7: Complete Development

**Use Superpowers skill:**

```
Skill("finishing-development-branch")
  branch: feature/[spec-name]
  base_branch: main
```

**Skill handles:**
1. Verifies tests pass
2. Presents options:
   - Merge locally
   - Create PR
   - Keep as-is
   - Discard
3. Executes choice
4. Cleans up worktree

**After completion:**
```
✅ Implementation Complete!

Summary:
- Spec: [spec-name]
- Task groups: [X] complete
- Tests: [Y] passing
- Branch: [Status]

Returned to /catchup.
```

## Resuming Mid-Implementation

**If partially complete:**

```
Resuming: [spec-name]

Progress:
✅ Task Group 1: [Name] ([X/Y])
✅ Task Group 2: [Name] ([A/B])
🔄 Task Group 3: [Name] ([C/D]) IN PROGRESS
⚪ Task Group 4: Verification

Worktree: [Found at path / Not found]

Options:
1. Continue in existing worktree
2. Create fresh worktree
3. Work in current directory

Which?
```

## Checkpoints Between Groups

```
✅ Task Group [N] Complete

Implemented:
- [List tasks]

Tests:
- [X] tests written
- All passing: [Yes/No]

Code review: [Status]

Ready for Task Group [N+1]?

Options:
1. Continue
2. Review implementation
3. Pause (resume later)

What next?
```

## Browser Testing (Optional)

**If UI tasks and browser tools available:**

```
Browser testing available for UI.

After UI task group:
1. Test in browser, capture screenshots
2. Skip browser testing (rely on automated tests)

Preference?
```

**If yes:**
```bash
mkdir -p "$SPEC/verification/screenshots"
# Take screenshots via browser MCP tools
# Store in verification/screenshots/
```

## Red Flags

**Never:**
- Skip worktree setup without approval
- Mix approaches mid-implementation
- Proceed with failing tests
- Skip verification
- Forget roadmap update
- Auto-merge without confirmation

**Always:**
- Present approach options first
- Use Superpowers skills for workflow
- Create implementation reports
- Verify all tests pass
- Update tasks.md and roadmap
- Use finishing-development-branch

## Integration

**Called by:**
- `sdd-orchestrator` when spec ready

**Uses Superpowers skills:**
- `using-git-worktrees` (Step 3 - REQUIRED)
- `subagent-driven-development` (Step 4A - Optional)
- `executing-plans` (Step 4B - Optional)
- `finishing-development-branch` (Step 7 - REQUIRED)

**Subagents should use:**
- `verification-before-completion` principles (before marking tasks done)

**Uses SDD skill:**
- `implementation-verification` (Step 6 - REQUIRED)

**May use:**
- Browser MCP tools (Optional for UI testing)

**Returns to:**
- `sdd-orchestrator` after completion

**Updates:**
- `[spec]/tasks.md` - Checkboxes
- `[spec]/implementation/*.md` - Reports
- `[spec]/verification/final-verification.md` - Final report
- `specs/product/roadmap.md` - Completed items
