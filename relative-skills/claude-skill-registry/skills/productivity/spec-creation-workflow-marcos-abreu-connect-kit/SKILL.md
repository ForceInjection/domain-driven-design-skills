---
name: spec-creation-workflow
description: Use when creating new spec or resuming incomplete spec - detects current phase, routes to appropriate phase skill (initialization, requirements, spec-writing, tasks-planning, verification), and manages phase transitions with validation checkpoints
---

# Spec Creation Workflow

## What It Does

Orchestrates spec creation through 5 phases with validation at each step:
1. **Initialization** - Create folder structure
2. **Requirements** - Gather details via Q&A
3. **Spec Writing** - Search codebase, write specification
4. **Tasks Planning** - Break into task groups
5. **Verification** - Validate before implementation

**Each phase completes → validates → moves to next.**

This skill detects the current phase, routes to the appropriate phase skill, and manages transitions between phases.

## The Process

### Step 1: Detect Current Phase

```bash
SPEC="specs/features/[spec-folder]"

if [ ! -f "$SPEC/planning/initialization.md" ]; then
  PHASE=1
elif [ ! -f "$SPEC/planning/requirements.md" ]; then
  PHASE=2
elif [ ! -f "$SPEC/spec.md" ]; then
  PHASE=3
elif [ ! -f "$SPEC/tasks.md" ]; then
  PHASE=4
elif [ ! -f "$SPEC/verification/spec-verification.md" ]; then
  PHASE=5
elif grep -q "Status.*Failed" "$SPEC/verification/spec-verification.md"; then
  PHASE=5  # Re-verify
else
  echo "Spec complete!"
fi
```

### Step 2: Execute Current Phase

Route to phase skill:

#### Phase 1: Initialization

```
Skill("spec-initialization")
```

Creates folder structure, saves initial idea.

**After completion:**
```
✅ Phase 1 Complete: Initialized

Created: specs/features/[dated-name]/
  └─ planning/initialization.md

Ready for Phase 2: Requirements

Continue? (yes/no)
```

#### Phase 2: Requirements Gathering

```
Skill("requirements-gathering")
```

Asks questions, checks visuals, gathers details.

**After completion:**
```
✅ Phase 2 Complete: Requirements gathered

Created: planning/requirements.md
Visuals: [X found / None]
Reusability: [Y identified / None]

Ready for Phase 3: Spec writing

Continue? (yes/no)
```

#### Phase 3: Spec Writing

```
Skill("spec-writing")
```

Searches codebase, writes spec in validated sections.

**After completion:**
```
✅ Phase 3 Complete: Spec created

Created: spec.md

Sections:
- Goal & User Stories
- [X] Specific Requirements
- Visual Design ([Y] mockups)
- Existing Code to Leverage
- Out of Scope

Ready for Phase 4: Tasks planning

Continue? (yes/no)
```

#### Phase 4: Tasks Planning

```
Skill("tasks-planning")
```

Creates task breakdown with dependencies.

**After completion:**
```
✅ Phase 4 Complete: Tasks planned

Created: tasks.md

Structure:
- [X] task groups
- [Y] total tasks
- Execution order defined

Ready for Phase 5: Verification

Continue? (yes/no)
```

#### Phase 5: Verification

```
Skill("spec-verification")
```

Validates completeness, accuracy, reusability.

**If PASSED:**
```
✅ Phase 5 Complete: Verified

Status: ✅ Passed
- Requirements accurate
- Visuals integrated
- Reusability leveraged
- Tasks complete

🎉 Spec ready for implementation!

Options:
1. Start implementation
2. Create another spec
3. Return to /catchup

What next?
```

**If FAILED:**
```
⚠️  Phase 5: Issues found

Status: ❌ [X] critical, [Y] important issues

Critical issues:
- [Issue 1]
- [Issue 2]

Options:
1. Review verification report
2. Fix automatically
3. Fix specific issues
4. I'll fix manually

What next?
```

### Step 3: Handle Verification Issues

**If fixing automatically:**

For each critical/important issue:
1. Identify affected phase
2. Use appropriate skill to fix, as indicated in step 2
3. Show changes
4. Re-verify

**After fixes:**
```
Applied [X] fixes. Re-verifying...

[Run verification again]
```

### Step 4: Phase Transition Pattern

Between each phase:
```
[Phase complete announcement]
[Summary of what was created]
[Preview of next phase]

Continue? (yes/no/pause)
```

**If "pause":**
```
Pausing at Phase [N].

Progress saved. Resume anytime with /catchup.

What would you like to do instead?
```

## Resuming Interrupted Specs

When resuming:
```
Resuming: [spec-name]

Progress:
✅ Phase 1: Initialization
✅ Phase 2: Requirements
🔄 Phase 3: Spec writing (IN PROGRESS)
⚪ Phase 4: Tasks planning
⚪ Phase 5: Verification

Continuing with spec writing.

Ready? (yes/no)
```

## Red Flags

**Never:**
- Skip phase validation
- Run multiple phases without checkpoints
- Assume user wants to continue
- Proceed with failed verification

**Always:**
- Use appropriate skill for each phase
- Wait for confirmation between phases
- Present clear summaries
- Handle verification failures before marking complete

## Integration

**Called by:**
- `sdd-orchestrator` for new/incomplete specs

**Uses:**
- `spec-initialization` (Phase 1)
- `requirements-gathering` (Phase 2)
- `spec-writing` (Phase 3)
- `tasks-planning` (Phase 4)
- `spec-verification` (Phase 5)

**Returns to:**
- `sdd-orchestrator` after verification passes

**Next workflow:**
- `spec-implementation-workflow` if user chooses to implement
