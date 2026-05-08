---
name: execute-project
description: "The ONLY way to interact with existing projects. Load when user references ANY project by name, ID, or number. Includes: continue, resume, status, progress, check, review, work on [existing project]. NEVER read project files directly."
---

## 🎯 Onboarding Awareness (CONTEXTUAL SUGGESTIONS)

**During project execution, AI should watch for teachable moments:**

### Onboarding Suggestions During Execution

Check `learning_tracker.completed` in user-config.yaml for contextual suggestions:

**If user encounters repeating patterns:**
```yaml
learn_skills: false  → Suggest when user does something that could be a skill
```
Pattern detection: If user asks to do something similar to what they've done before,
or creates similar outputs repeatedly → gently suggest 'learn skills':
```
💡 I notice this task is similar to [previous task]. If you do this regularly,
it might be worth learning about Skills (reusable workflows). Run 'learn skills'
(10 min) when you have time.
```

**If user asks about integrations during execution:**
```yaml
learn_integrations: false  → Suggest when user mentions external tools
```
```
💡 You mentioned [tool]. If you work with external tools often, 'learn integrations'
(10 min) teaches how Nexus connects to services like Notion, GitHub, etc.
```

**On project completion (100%):**
If multiple onboarding skills incomplete, suggest the next logical one:
```
🎉 Project complete! You're getting the hang of Nexus.

💡 Next learning opportunity: 'learn skills' - turn repeating work into
reusable workflows (10 min). Or 'learn nexus' for system mastery (15 min).
```

### DO NOT Suggest If:
- User is mid-task and focused (wait for natural breaks)
- User has explicitly dismissed learning suggestions
- All onboarding already complete

---

# Skill: Execute Project

**Purpose**: Systematically execute project work with continuous progress tracking and task completion validation.

**Load When**:
- User says: "execute project [ID/name]"
- User says: "continue [project-name]"
- User says: "work on [project-name]"
- Orchestrator detects: Project continuation (IN_PROGRESS status)

**Core Value**: Ensures work stays aligned with planned tasks and provides continuous visibility into progress.

---

## Quick Reference

**What This Skill Does**:
1. ✅ Loads project context (planning files, current progress)
2. ✅ Identifies current phase/section and next uncompleted task
3. ✅ Executes work systematically (section-by-section or task-by-task)
4. ✅ Continuously updates task completion using bulk-complete-tasks.py
5. ✅ Validates progress after each section/checkpoint
6. ✅ Handles pause-and-resume gracefully
7. ✅ Auto-triggers close-session when done

**Key Scripts Used**:
- `nexus-loader.py --project [ID]` - Load project context
- `bulk-complete-tasks.py --project [ID] --section [N]` - Complete section
- `bulk-complete-tasks.py --project [ID] --tasks [range]` - Complete specific tasks
- `bulk-complete-tasks.py --project [ID] --all` - Complete all (when project done)

---

## Prerequisites

**Before using this skill, ensure**:
- ✅ Project exists in `02-projects/` with valid metadata
- ✅ Planning files exist: `overview.md`, `plan.md` (or `design.md`), `steps.md` (or `tasks.md`)
- ✅ Tasks file has checkbox format: `- [ ] Task description`
- ✅ Project status is `IN_PROGRESS` or `PLANNING` (ready to execute)

**If prerequisites not met**:
- Missing project → Use `create-project` skill first
- Missing planning → Complete planning phase before execution
- Invalid task format → Validate with `validate-system` skill

---

## Workflow: 7-Step Execution Process

### Step 1: Initialize Progress Tracking

**Action**: Create comprehensive TodoWrite with ALL workflow steps

**Template**:
```markdown
1. Load project context
2. Identify current phase/section
3. Execute Section 1
4. Bulk-complete Section 1
5. Execute Section 2
6. Bulk-complete Section 2
... (repeat for all sections)
N. Project completion validation
N+1. Trigger close-session
```

**Purpose**: Provides user visibility into entire execution workflow

**Mark complete when**: TodoWrite created with all steps

---

### Step 2: Load Project Context

**Action**: Load complete project context using nexus-loader.py

**Commands**:
```bash
# Load project with full content (overview, plan, steps, etc.)
python 00-system/core/nexus-loader.py --project [project-id]
```

**The loader returns**:
- File paths for all planning files (overview.md, plan.md, steps.md, etc.)
- YAML metadata extracted from each file
- Output file listings
- `_usage.recommended_reads` - list of paths to read

**Then use Read tool in parallel** to load the file contents:
```
Read: {path from recommended_reads[0]}
Read: {path from recommended_reads[1]}
Read: {path from recommended_reads[2]}
```

**Display Project Summary**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECT: [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: IN_PROGRESS
Progress: [X]/[Y] tasks complete ([Z]%)

Current Section: Section [N] - [Name]
Next Task: [Task description]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Mark complete when**: All planning files loaded, summary displayed

---

### Step 3: Identify Current Phase

**Action**: Parse tasks file to determine current state

**Detection Logic**:
```python
# Parse tasks.md or steps.md
tasks = extract_all_tasks(content)
sections = extract_sections(content)

# Find first uncompleted section
current_section = find_first_uncompleted_section(sections, tasks)

# Find next uncompleted task
next_task = find_next_uncompleted_task(tasks)

# Calculate progress
total_tasks = len(tasks)
completed_tasks = count_completed(tasks)
progress_pct = (completed_tasks / total_tasks) * 100
```

**Display Current State**:
```
📍 CURRENT STATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Progress: [15/40 tasks] (37.5%)

✅ Section 1: Planning (Tasks 1-8) - COMPLETE
✅ Section 2: Setup (Tasks 9-12) - COMPLETE
🔄 Section 3: Implementation (Tasks 13-28) - IN PROGRESS
   ├─ Next: Task 15 - "Implement scoring logic"
   └─ Remaining: 14 tasks in this section
⬜ Section 4: Testing (Tasks 29-35) - NOT STARTED
⬜ Section 5: Deployment (Tasks 36-40) - NOT STARTED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Ask User**:
```
Ready to continue Section 3: Implementation?

Options:
1. Continue from Task 15 (recommended)
2. Review completed work first
3. Jump to different section
4. Exit and save progress
```

**Mark complete when**: Current state identified and displayed

---

### Step 4: Execute Work with Continuous Tracking

**CRITICAL PATTERN**: Section-based execution with automatic bulk-complete

**For each section**:

#### 4A. Show Section Overview
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SECTION 3: IMPLEMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goal: [Section goal from tasks.md]
Tasks: 13-28 (16 tasks total)
Estimate: [Time estimate if available]

Uncompleted tasks in this section:
  [ ] Task 15: Implement scoring logic
  [ ] Task 16: Create validation rules
  [ ] Task 17: Build API endpoints
  ... (show all uncompleted)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 4B. Execute Tasks in Section
```
Starting Task 15: Implement scoring logic...

[Execute work]
[Show outputs, code, decisions]

✅ Task 15 complete!

Starting Task 16: Create validation rules...
```

**Adaptive Granularity** (see `references/adaptive-granularity.md`):
- **Small sections** (≤5 tasks): Execute all, then bulk-complete
- **Large sections** (>15 tasks): Checkpoint every 5-7 tasks
- **Unstructured** (no sections): Checkpoint every 10 tasks

#### 4C. Section Completion Checkpoint
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SECTION 3: IMPLEMENTATION - COMPLETE! 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tasks completed in this section: 16/16
All work validated and ready to mark complete.

Ready to bulk-complete Section 3?
  ✅ Marks tasks 13-28 as [x] in steps.md
  ✅ Updates progress automatically
  ✅ Validates by re-reading file

Type 'yes' to proceed, or 'review' to check work first.
```

#### 4D. Bulk-Complete Section
```bash
# User confirms → Execute bulk-complete
python 00-system/skills/bulk-complete/scripts/bulk-complete.py \
  --project [project-id] \
  --section 3 \
  --no-confirm
```

**Validation Output**:
```
[INFO] Using task file: steps.md
Project: 05-lead-qualification
Tasks: 12 uncompleted, 28 completed (Total: 40)

[MODE] Complete 12 uncompleted tasks in Section/Phase 3

[AUTO-CONFIRM] Proceeding without confirmation (--no-confirm flag)

[SUCCESS] Successfully completed 12 tasks!
Updated: 40/40 tasks now complete (100%)
✅ VALIDATED: Re-read file shows 0 uncompleted, 40 completed
File: 02-projects/05-lead-qualification/01-planning/steps.md
```

#### 4E. Show Updated Progress
```
✅ Section 3 complete!

Updated Progress: 28/40 tasks (70%)

Remaining sections:
  ⬜ Section 4: Testing (Tasks 29-35) - 7 tasks
  ⬜ Section 5: Deployment (Tasks 36-40) - 5 tasks

Continue to Section 4, or pause for today?
```

**Mark complete when**: Section executed and bulk-completed with validation

---

### Step 5: Incremental Progress Updates

**After each section/checkpoint**:

**Display Progress Bar**:
```
Progress: [████████░░] 80% (32/40 tasks)

Completed:
  ✅ Section 1: Planning (8 tasks)
  ✅ Section 2: Setup (4 tasks)
  ✅ Section 3: Implementation (16 tasks)
  ✅ Section 4: Testing (4 tasks)

Remaining:
  ⬜ Section 5: Deployment (8 tasks)
```

**Ask User**:
```
Options:
1. Continue to Section 5: Deployment
2. Pause and save progress (will resume here next session)
3. Review completed work
4. Jump to different section
```

**Mark complete when**: Progress updated and user decides next step

---

### Step 6: Handle Partial Completion

**When user says "pause" or "done for today"**:

**Offer Partial Task Completion**:
```
Current progress: 25/40 tasks (62.5%)

Do you want to mark any completed tasks before pausing?

Options:
1. Bulk-complete specific tasks (e.g., "1-10,15-20")
2. Bulk-complete current section (Section 3)
3. No, save current state as-is
```

**If user wants bulk-complete**:
```bash
# Example: User completed tasks 20-25 but not full section
python 00-system/skills/bulk-complete/scripts/bulk-complete.py \
  --project [project-id] \
  --tasks 20-25 \
  --no-confirm
```

**Then trigger close-session**:
```
Saving progress...

[Trigger close-session skill]

✅ Session saved!
✅ Progress: 25/40 tasks complete (62.5%)
✅ Next session will resume at: Section 3, Task 26

See you next time! 👋
```

**Mark complete when**: Partial completion handled, close-session triggered

---

### Step 7: Project Completion

**When all sections done**:

**Final Validation**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECT COMPLETE! 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All sections executed:
  ✅ Section 1: Planning (8 tasks)
  ✅ Section 2: Setup (4 tasks)
  ✅ Section 3: Implementation (16 tasks)
  ✅ Section 4: Testing (7 tasks)
  ✅ Section 5: Deployment (5 tasks)

Total: 40/40 tasks (100%)

Ready to finalize project completion?
  ✅ Mark all tasks complete
  ✅ Update project status to COMPLETE
  ✅ Archive project
  ✅ Trigger close-session

Type 'yes' to proceed.
```

**Execute Final Bulk-Complete**:
```bash
# Complete any remaining tasks
python 00-system/skills/bulk-complete/scripts/bulk-complete.py \
  --project [project-id] \
  --all \
  --no-confirm
```

**Update Project Status**:
```bash
# Update overview.md metadata
status: COMPLETE
last_worked: [today's date]
```

**Trigger close-session**:
```
✅ Project marked COMPLETE!
✅ All 40/40 tasks checked off
✅ Ready to archive (use 'archive-project' skill)

[Trigger close-session skill]

Congratulations on completing this project! 🎉
```

**Mark complete when**: Project finalized, status updated, close-session triggered

---

## Advanced Features

### Adaptive Granularity

**Auto-detects project size and adjusts tracking granularity**:

```python
# Small projects (≤15 tasks)
→ Task-by-task execution with real-time updates

# Medium projects (16-30 tasks, with sections)
→ Section-based execution with bulk-complete per section

# Large projects (>30 tasks, with sections)
→ Section-based with periodic checkpoints (every 5-7 tasks)

# Unstructured projects (no sections)
→ Checkpoint every 10 tasks
```

**See**: `references/adaptive-granularity.md` for complete logic

---

### Mental Models Integration (Proactive Offering)

**When to Offer**: At key decision points during execution (section completion, risk assessment, design choices)

**Pattern**: AI runs select_mental_models.py, reviews output, and offers 2-3 relevant models to user

**Mental Models Skill Integration**:

The execute-project skill automatically references mental-models at decision points for:
- **Risk analysis** at section checkpoints
- **Decision-making** when multiple approaches exist
- **Problem decomposition** when stuck on complex tasks
- **Systems thinking** for dependency validation

**Required Workflow**:
1. Run script to get available models:
   ```bash
   python 00-system/mental-models/scripts/select_mental_models.py --format brief
   ```
2. Select 2-3 relevant models based on context
3. Offer to user with brief descriptions
4. Load individual model file only after user selects

**Offering Pattern**:

```markdown
# At Section Completion Checkpoint
Section 3 complete! Before bulk-completing, I've reviewed the mental models catalog and recommend:

1. **Pre-Mortem** – Imagine failure modes before implementation
   Best for: High-stakes sections, risk mitigation

2. **Systems Thinking** – Analyze interdependencies and feedback loops
   Best for: Complex integrations, dependency validation

3. **Force Field Analysis** – Identify driving vs restraining forces
   Best for: Understanding obstacles and enablers

Which approach sounds most useful? Or continue without structured analysis?

[User picks option]

If user picks a model:
→ Read: 00-system/mental-models/models/diagnostic/pre-mortem.md
→ Apply model questions before bulk-completing section
```

**Benefits**:
- ✅ **Proactive** - AI runs script to identify relevant options
- ✅ **User Choice** - User picks which model (or none) to apply
- ✅ **Contextual** - Offered at decision points only
- ✅ **Individual files** - Each model has its own file with full details
- ✅ **Efficient** - Descriptions are brief (3-7 words) but descriptive

**When to Skip Offering**:
- ❌ Routine, straightforward sections (offer only at complex/risky points)
- ❌ User explicitly requests speed over depth
- ❌ Simple task execution (no major decisions)

**See**: [`mental-models framework`](../../mental-models/mental-models.md) for full catalog and offering guidance

---

### Error Handling

**Common Issues**:

**Issue**: Tasks file not found
**Solution**: Validate project structure with `validate-system` skill

**Issue**: No uncompleted tasks
**Solution**: Display "All tasks complete!" and offer to mark project COMPLETE

**Issue**: Invalid task format (no checkboxes)
**Solution**: Show error with example format: `- [ ] Task description`

**Issue**: Bulk-complete script fails
**Solution**: Fallback to manual Edit tool, log error for debugging

**See**: `references/error-handling.md` for complete troubleshooting guide

---

## Integration with Other Skills

### create-project → execute-project
```
Session 1: create-project
  → Creates planning files (overview, plan, steps)
  → Status: PLANNING
  → close-session saves state

Session 2: execute-project
  → Loads planning files
  → Executes work systematically
  → Status: IN_PROGRESS
  → Continuously updates tasks
  → close-session saves progress
```

### execute-project → close-session
```
execute-project (in progress)
  → User says "done for today"
  → execute-project offers partial bulk-complete
  → Triggers close-session
  → close-session:
      - Reads current task state
      - Creates session report
      - Saves progress
      - Prepares for next session
```

### execute-project → archive-project
```
execute-project (100% complete)
  → Marks project status: COMPLETE
  → Suggests: "Use 'archive-project' skill to move to archive"
  → User invokes archive-project
  → Project moved to 05-archived/
```

---

## Success Criteria

**This skill succeeds when**:

- ✅ Project context loaded with all planning files
- ✅ Current phase/section identified correctly
- ✅ Work executed systematically (not ad-hoc)
- ✅ Tasks bulk-completed after each section
- ✅ Progress validated after every bulk-complete
- ✅ User sees continuous progress updates
- ✅ Partial completion handled gracefully (pause/resume)
- ✅ Project completion triggers final validation
- ✅ close-session auto-triggered at appropriate times

---

## Example Interaction

**User**: "Continue project 05-lead-qualification"

**AI**:
```
Loading project 05-lead-qualification...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECT: Lead Qualification Workflow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: IN_PROGRESS
Progress: 12/40 tasks complete (30%)

Current Section: Section 2 - Implementation
Next Task: Task 13 - "Implement scoring logic"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to continue Section 2?
```

**User**: "Yes"

**AI**:
```
Starting Section 2: Implementation...

Task 13: Implement scoring logic
[Executes work, shows code]
✅ Task 13 complete!

Task 14: Create validation rules
[Executes work]
✅ Task 14 complete!

... (continues through Section 2)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SECTION 2: IMPLEMENTATION - COMPLETE! 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tasks completed: 16/16
Ready to bulk-complete Section 2?
```

**User**: "Yes"

**AI**:
```
Running bulk-complete for Section 2...
[SUCCESS] Successfully completed 16 tasks!
✅ VALIDATED: 28/40 tasks now complete (70%)

Updated Progress: [███████░░░] 70%

Continue to Section 3: Testing, or pause?
```

**User**: "Pause"

**AI**:
```
Saving progress...
[Triggers close-session]

✅ Session saved!
✅ Progress: 28/40 tasks (70%)
✅ Next session: Section 3, Task 29

See you next time! 👋
```

---

## Reference Documents

**For detailed implementation guidance**:

- **[workflow.md](references/workflow.md)** - Complete 7-step workflow with examples
- **[task-tracking.md](references/task-tracking.md)** - Task parsing and bulk-complete logic
- **[adaptive-granularity.md](references/adaptive-granularity.md)** - Smart detection for project size
- **[error-handling.md](references/error-handling.md)** - Troubleshooting common issues

---

**Version**: 1.0
**Created**: 2025-01-22
**Status**: Production Ready
**Author**: Nexus-v3 System
