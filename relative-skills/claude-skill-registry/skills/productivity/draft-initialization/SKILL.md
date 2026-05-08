---
name: draft-initialization
description: Initialize fiction draft cycles following the Spec-Kit workflow (idea → clarify → plan → tasks). Use when creating new drafts, planning rewrites, breaking down episodes, or structuring story changes. Triggers include requests like "create draft", "new draft folder", "plan episode", "rewrite breakdown", "draft tasks", "initialize draft", "start new draft".
---

# Draft Initialization

Initialize a new fiction draft cycle following the Fiction Kit's Spec-Kit-style workflow.

## When to Use This Skill

Use this skill when you need to:
- Create a new draft folder and artifacts
- Break down a rewrite or story change into structured tasks
- Plan an episode from outline to execution
- Generate checkbox tasks from a high-level plan

## Workflow Stages

A complete draft follows this sequence:

1. **Idea** (`idea.md`) - Capture rewrite intent (WHAT/WHY)
2. **Clarify** (`clarify.md`) - Ask up to 5 questions to reduce ambiguity
3. **Plan** (`plan.md`) - Create structural blueprint (HOW)
4. **Tasks** (`tasks.md`) - Generate actionable checkbox tasks with acceptance criteria

## Stage 1: Create Draft Folder

Determine the next draft number and create folder structure:

```
drafts/###-kebab-case-name/
├── idea.md
├── clarify.md
├── plan.md
├── tasks.md
├── analyze.md
└── feedback.md
```

Use the `drafts/_template/` folder as reference for file structure.

## Stage 2: Populate idea.md

Write structured intent summary with these required sections:

### Required Sections
- **Intent Summary** (3-5 sentences: WHAT needs to change and WHY)
- **Motivation** (Why this change is needed now)
- **Scope** (Which episodes/scenes/files/characters affected)
- **Desired Outcome** (What success looks like)

### Critical Rules
- Do NOT propose solutions or write prose
- This is specification only, not implementation
- Stay focused on user's original intent
- If user provides vague request, ask for specifics before writing

### Example idea.md

```markdown
# Draft Idea

**Intent Summary:** Tighten Act 2 pacing in episode 3 by compressing the investigation montage from 4 scenes to 2 scenes. Currently the middle drags and reader interest drops.

**Motivation:** Beta feedback indicates Act 2 loses momentum. Scenes 8-11 feel repetitive and the investigation stalls visually. Need faster escalation to the reveal in scene 15.

**Scope:**
- Episode 3, scenes 8-11 (investigation montage)
- May affect: Eddie's character arc (less screen time), Baxter's methods
- Files: `content/episodes/episode-03-*.md` scenes 8-11

**Desired Outcome:**
- Act 2 maintains reader engagement
- Investigation escalates more rapidly
- Scene count reduced by 2 without losing critical discoveries
- Baxter's competence still established but more efficiently
```

## Stage 3: Run Clarification Gate

Read `idea.md` and identify missing details that would materially change the plan.

**Ask up to 5 questions (prioritized):**
1. Target & scope (which episodes/scenes exactly?)
2. Intended outcome (what should feel different?)
3. Non-negotiables (constraints beyond checklist?)
4. Continuity details (time/place/who's present?)
5. Serial beat requirements (hook/turn/cliffhanger needs?)

### After User Answers
- Append "Clarifications" section to `idea.md` with date + Q→A pairs
- Also log in `clarify.md` for reference

### If No Questions Needed
State what is sufficiently specified (1-3 bullets).

## Stage 4: Generate Plan

Read `idea.md` (including clarifications) and create `plan.md`.

### Required Plan Sections

1. **Element Changes**
   - Which elements files need updates? (`characters/`, `plot.md`, `outline.md`, etc.)
   - What specific changes to each?

2. **Content Changes**
   - Scenes to add/edit/delete/reorder
   - Episode structure modifications

3. **Directory Changes**
   - Folders to create/rename/delete in `content/`
   - File renaming/numbering changes

4. **Sequence of Work**
   - Step-by-step execution order
   - What must happen first, second, etc.

5. **Dependencies**
   - What requires what (e.g., "character file update before scene edit")

6. **Serial Episode Beats** (if applicable)
   - Hook placement
   - Escalation/turn timing
   - End-button or cliffhanger strategy

### Constraints to Check

**BEFORE writing plan, read:**
- `voice/format.md` - File structure and serial fiction rules
- `elements/checklist.md` - Non-negotiable requirements
- `elements/tone.md` - Tone constraints
- `elements/pov.md` - POV rules

### Output Format

Output ONLY the plan content as markdown ready to save to `plan.md`.

## Stage 5: Generate Tasks

Convert `plan.md` into actionable checkbox tasks in `tasks.md`.

### Task Format (CRITICAL)

**EVERY task must use this exact format:**

```markdown
- [ ] **T###: [Task Name]** — [Brief description]
  - **Files/Directories Affected:** [Specific paths]
  - **Action:** [What to do]
  - **Acceptance Criteria:**
    - [ ] Criterion 1
    - [ ] Criterion 2
  - **Dependencies:** [Task IDs that must complete first, or "None"]
```

### Task Numbering
- Sequential IDs: T001, T002, T003, etc.
- Setup tasks first (T001: scaffold folders)
- Content tasks middle (scenes/episodes)
- QA/validation tasks last (T020+: continuity check, compile)

### Task Categories

**Setup Tasks (T001-T003)**
- Create directories
- Scaffold files
- Update elements

**Content Tasks (T004-T0XX)**
- One task per scene/chapter
- Edit existing content
- Reorder scenes

**QA Tasks (Final 3-5)**
- Validate against checklist
- Run continuity check
- Compile episode (if applicable)

### Example tasks.md

```markdown
# Tasks

- [ ] **T001: Setup Episode Directory** — Create episode folder structure
  - **Files/Directories Affected:** `content/episodes/episode-03-investigation/`
  - **Action:** Create directory with proper naming convention
  - **Acceptance Criteria:**
    - [ ] Directory named `episode-03-investigation`
    - [ ] Directory exists at correct path
  - **Dependencies:** None

- [ ] **T002: Draft Scene 08 — Baxter Montage** — Write compressed investigation scene
  - **Files/Directories Affected:** `content/episodes/episode-03-investigation/08-baxter-montage.md`
  - **Action:** Write new scene combining beats from old scenes 8-9
  - **Acceptance Criteria:**
    - [ ] Scene opens mid-action (McDonald rule)
    - [ ] Baxter's competence established
    - [ ] Key discoveries included
    - [ ] Word count 1200-1500
  - **Dependencies:** T001

- [ ] **T020: Validate Episode Against Checklist** — QA pass
  - **Files/Directories Affected:** `elements/checklist.md`, all episode scenes
  - **Action:** Verify all checklist requirements met
  - **Acceptance Criteria:**
    - [ ] All checklist items verified
    - [ ] No POV violations
    - [ ] McDonald rule compliance
  - **Dependencies:** T002-T019
```

## Validation

After generating any artifact, validate using `scripts/validate_draft.py`:

```bash
python .github/skills/draft-initialization/scripts/validate_draft.py drafts/###-name/
```

Checks:
- [ ] Draft folder uses naming: `###-kebab-case`
- [ ] All template files scaffolded
- [ ] idea.md has all required sections
- [ ] Clarifications logged if questions asked
- [ ] plan.md references constraint files
- [ ] tasks.md uses checkbox format (`- [ ]`)
- [ ] Task IDs sequential (T001, T002, ...)
- [ ] Each task has acceptance criteria
- [ ] Dependencies correctly specified

## Output Format

For each stage, output ONLY a single file section ready to save:

```markdown
### drafts/<draft-folder>/<file>.md
```
[followed by full file contents]

## Next Step

After `tasks.md` is complete, tasks can be executed. Use **scene-writing** skill for prose drafting and **draft-validation** skill for QA.
