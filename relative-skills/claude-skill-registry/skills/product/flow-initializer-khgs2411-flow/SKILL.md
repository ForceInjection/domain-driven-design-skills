---
name: flow-initializer
description: Initialize Flow projects from scratch, migrate existing docs, or update old structures. Use when user says "start flow", "initialize", "migrate to flow", "set up flow project".
---

# Flow Initializer

Help users initialize new Flow projects, migrate existing documentation to Flow format, or update old Flow structures to current framework patterns. This is the entry point for getting started with Flow.

## When to Use This Skill

Activate when the user wants project initialization:
- "Start a new Flow project"
- "Set up Flow framework"
- "Initialize Flow in my project"
- "Migrate my TODO/PLAN to Flow"
- "Convert my docs to Flow format"
- "Create Flow structure"
- "Bootstrap Flow"
- "Update my old Flow plan"
- "My plan structure is outdated"

## Initialization Philosophy

**Three Paths to Flow**:
1. **Blueprint** - Create new project from scratch
2. **Migrate** - Convert existing docs (PRD, TODO, PLAN) to Flow
3. **Update** - Modernize old Flow structures to current patterns

**Multi-File Architecture**: Flow uses:
- `DASHBOARD.md` - Progress tracking (single source of truth)
- `PLAN.md` - Static context (overview, architecture, scope)
- `phase-N/task-M.md` - Work files with iterations

## Path 1: Blueprint (New Project)

### When to Use
User wants to create a brand new Flow project from scratch.

### Input Validation

**Step 1: Check for content** - Reject if empty or whitespace only

**Step 2: Detect blueprint mode**

**Mode A: SUGGEST Structure** (AI designs)
- Trigger: NO explicit structure markers
- Examples: "websocket server", "user auth system"
- Behavior: Ask questions, generate suggested structure

**Mode B: CREATE Explicit Structure** (User designed)
- Trigger: Contains numbered lists, "Phase N:", "Task N:", or bullets
- Behavior: Parse structure, show dry-run preview, get approval

**Step 3: Semantic check** (Mode A only) - If too vague, ask for clarification

**Step 4: Dry-run preview** (Mode B only) - Show what will be created, get approval

### Blueprint Workflow

**Mode A: SUGGEST Structure**
1. Gather requirements (ask about goals, phases, tasks)
2. Generate suggested structure
3. Get user approval before creating files

**Mode B: CREATE Explicit Structure**
1. Parse user's structure (phases, tasks, iterations, V1/V2 splits)
2. Show dry-run preview
3. Get user approval

### Files to Create

Use these template files for complete structures:
- [DASHBOARD_TEMPLATE.md](DASHBOARD_TEMPLATE.md) - Progress tracking structure
- [PLAN_TEMPLATE.md](PLAN_TEMPLATE.md) - Static context structure
- [TASK_TEMPLATES.md](TASK_TEMPLATES.md) - Task file structures (standalone, iterations, brainstorming)
- [OTHER_TEMPLATES.md](OTHER_TEMPLATES.md) - BACKLOG and CHANGELOG templates (optional)

### Creation Process

1. Check `.flow/` doesn't exist (unless user confirms overwrite)
2. Create directory structure: `.flow/` and `.flow/phase-1/`
3. Write DASHBOARD.md, PLAN.md, phase-1/task-1.md using templates
4. Confirm success with summary

## Path 2: Migrate (Convert Existing Docs)

### When to Use
User has existing documentation (PRD.md, TODO.md, PLAN.md, etc.) and wants to convert to Flow format.

### Discovery Phase

1. Check if user provided path in request
2. Otherwise search project root for common files: `PRD.md`, `PLAN.md`, `TODO.md`, `DEVELOPMENT.md`, `ROADMAP.md`, `TASKS.md`
3. If multiple found, ask which to migrate
4. If none found, offer to create new project instead

### Analysis Phase

**Detect structure type**:
- **STRUCTURED** (Path A): Has phases/tasks/iterations or similar hierarchy
- **FLAT_LIST** (Path B): Simple todo list or numbered items
- **UNSTRUCTURED** (Path C): Free-form notes, ideas, design docs

**Extract key information**: Project context, completed work, current position, remaining work, architecture, V1/V2 splits, deferred/cancelled items

### Backup Phase

Create timestamped backup before migration: `[original].pre-flow-backup-$(date +%Y-%m-%d-%H%M%S)`

### Migration Patterns

See [MIGRATION_PATTERNS.md](MIGRATION_PATTERNS.md) for detailed conversion patterns for each structure type:

**Path A: STRUCTURED** - Map phases→phase-N/, tasks→task-M.md, preserve status markers, extract sections to DASHBOARD/PLAN

**Path B: FLAT_LIST** - Group into phases (ask if unclear), convert items to tasks, detect status from markers

**Path C: UNSTRUCTURED** - Show preview, offer options: extract & suggest structure, create basic plan, or start fresh

### Post-Migration

Report what was created with summary of phases, tasks, current position, and next steps

## Path 3: Update (Modernize Old Flow Structure)

### When to Use
User has an existing Flow structure that's outdated and needs updating to current framework patterns.

### Detection

**Read current structure**: Read DASHBOARD.md, PLAN.md, list phase directories, sample 2-3 task files

**Identify what needs updating**:
- Missing sections in DASHBOARD.md (📍 Current Work, 📊 Progress Overview)
- Missing sections in PLAN.md (Architecture, Testing Strategy)
- Outdated status markers
- Incorrect task structure (action items + iterations in same task)
- Missing CHANGELOG.md or BACKLOG.md

### Backup Phase

Create timestamped backup in `.flow/backup-[timestamp]/` before making changes

### Update Process

**DASHBOARD.md updates**: Ensure required sections exist, update timestamps and pointers

**PLAN.md updates**: Ensure Overview/Architecture/Testing sections exist, remove detailed tasks (move to task files)

**Task Files updates**: Ensure Task Overview and Iterations sections exist, convert standalone tasks to iteration format, fix status markers

**Missing Files**: Create CHANGELOG.md and/or BACKLOG.md if needed

### Report Changes

Show summary of what was updated in each file and guide user to next steps

## Validation Gates

**Before creating**: Check `.flow/` doesn't exist (unless overwrite confirmed), verify minimum viable content

**Before migrating**: Verify source docs exist, confirm backup created

**After creation/migration/update**: Verify DASHBOARD.md and PLAN.md exist with required sections, at least one phase directory exists, current work pointer is valid

## Examples

### Example 1: New Project from Scratch (Mode A: AI Suggests Structure)

```
User: "Set up Flow for my WebSocket chat app"

AI Process:
1. Detect Mode A (no explicit structure)
2. Ask: "What are the main phases? For example: Backend setup, WebSocket integration, Frontend, Testing"
3. User: "Backend, then frontend"
4. Generate suggested structure with 2 phases
5. Get approval, create files

Files Created:
- .flow/DASHBOARD.md (current: Phase 1, Task 1)
- .flow/PLAN.md (Purpose: WebSocket chat, Architecture: [TBD])
- .flow/phase-1/task-1.md (Backend setup)
- .flow/phase-2/task-1.md (Frontend)
```

### Example 2: Migrating TODO.md to Flow

```
User: "Migrate my TODO.md to Flow"

AI Process:
1. Read TODO.md
2. Detect structure type: FLAT_LIST (12 tasks)
3. Create backup: TODO.md.pre-flow-backup-[timestamp]
4. Group tasks: Phase 1 (Foundation, 4 tasks), Phase 2 (Features, 5 tasks), Phase 3 (Polish, 3 tasks)
5. Ask approval, migrate

Files Created:
- .flow/DASHBOARD.md (shows Phase 2, Task 2 in progress)
- .flow/PLAN.md (Purpose extracted, Architecture [TBD])
- .flow/phase-1/ (3 tasks complete, 1 pending)
- .flow/phase-2/ (2 in progress, 3 pending)
- .flow/phase-3/ (3 pending)
```

### Example 3: Updating Old Flow Single-File Plan

```
User: "Update my plan structure"

AI Process:
1. Read existing .flow/DASHBOARD.md and PLAN.md
2. Detect outdated patterns: missing sections, wrong task structure
3. Create backup: .flow/backup-[timestamp]/
4. Update DASHBOARD.md: Add "📍 Current Work" section
5. Update PLAN.md: Add Testing Strategy, move tasks to files
6. Update task files: Convert 2 standalone tasks to iteration format

Report:
✅ Updated to current patterns
- DASHBOARD.md: Added Current Work section
- PLAN.md: Added Testing Strategy
- Tasks: Converted 2 to iteration format
```

## Interaction with Other Flow Skills

**After Initialization**:
- flow-planner adds new phases/tasks/iterations
- flow-designer fills in Architecture during brainstorming
- flow-builder executes iterations
- flow-navigator shows current status

## Key Reminders

**Before**: Understand which path, validate input/detect sources, get user approval for structure

**During**: Create backups (migrate/update), follow multi-file architecture, use correct status markers (✅ ⏳ 🚧), mark [TBD] for unknowns

**After**: Verify files created, report summary, guide user to next steps

## References

- **Multi-File Architecture**: .flow/framework/DEVELOPMENT_FRAMEWORK.md lines 82-169
- **File Templates**:
  - [DASHBOARD_TEMPLATE.md](DASHBOARD_TEMPLATE.md) - Complete DASHBOARD.md structure
  - [PLAN_TEMPLATE.md](PLAN_TEMPLATE.md) - Complete PLAN.md structure
  - [TASK_TEMPLATES.md](TASK_TEMPLATES.md) - Task file structures
  - [OTHER_TEMPLATES.md](OTHER_TEMPLATES.md) - BACKLOG and CHANGELOG
- **Migration Patterns**: [MIGRATION_PATTERNS.md](MIGRATION_PATTERNS.md) - Conversion strategies for different doc types
- **Status Markers**: .flow/framework/DEVELOPMENT_FRAMEWORK.md lines 1872-1968
- **Task Structure Rules**: .flow/framework/DEVELOPMENT_FRAMEWORK.md lines 238-566
