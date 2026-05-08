---
name: conductor-development
description: Context-Driven Development skill for projects using Conductor. Use this skill when you detect a `conductor/` directory in the project, when working on tasks defined in a `plan.md` file, or when the user asks about tracks, specs, or plans. Automatically applies TDD workflow, tracks task completion, and follows the spec-driven methodology.
---

# Conductor Development Skill

This skill enables Claude to work effectively on projects managed by the Conductor framework - a spec-driven, structured development methodology.

## When This Skill Activates

Claude should automatically apply this skill when:
- A `conductor/` directory exists in the project root
- The user mentions "tracks", "conductor", "spec", or "plan" in the context of development
- Files like `conductor/tracks.md`, `conductor/workflow.md`, or `conductor/product.md` are present
- The user runs any `/conductor:*` command

## Core Principles

1. **The Plan is the Source of Truth:** All work must be tracked in `plan.md`
2. **Spec-Driven Development:** Understand the spec before implementing
3. **Test-Driven Development:** Write tests before implementation (Red-Green-Refactor)
4. **High Code Coverage:** Target >80% code coverage for all modules
5. **Track Progress:** Update task status markers (`[ ]` → `[~]` → `[x]`)

## Project Structure Understanding

When working on a Conductor project, familiarize yourself with:

```
conductor/
├── product.md              # Product vision and goals
├── product-guidelines.md   # Brand voice and communication style
├── tech-stack.md          # Technology choices and constraints
├── workflow.md            # Development methodology and procedures
├── tracks.md              # Master list of all tracks
├── code_styleguides/      # Language-specific style guides
│   ├── general.md
│   ├── python.md
│   └── [others]
└── tracks/                # Individual track folders
    └── <track_id>/
        ├── spec.md        # Feature specification
        ├── plan.md        # Implementation plan with tasks
        └── metadata.json  # Track metadata
```

## Task Execution Protocol

When implementing a task from a Conductor plan:

### 1. Select and Mark Task
- Find the next pending task (marked `[ ]`) in the track's `plan.md`
- Update its status to in-progress: `[~]`

### 2. Follow TDD Workflow
1. **Red Phase:** Write failing tests that define expected behavior
2. **Green Phase:** Write minimal code to make tests pass
3. **Refactor:** Improve code while keeping tests green

### 3. Complete the Task
1. Verify test coverage (>80%)
2. Follow code style guidelines from `conductor/code_styleguides/`
3. Commit with semantic message (e.g., `feat(auth): Add login form`)
4. Mark task complete: `[x]` and append commit SHA
5. Commit the plan update: `conductor(plan): Mark task 'X' as complete`

### 4. Phase Completion
When completing a phase:
1. Run full test suite
2. Provide manual verification steps to user
3. Create checkpoint commit with verification report
4. Update `plan.md` with checkpoint SHA

## Status Markers

- `[ ]` - Pending (not started)
- `[~]` - In Progress (currently working)
- `[x]` - Completed (done with commit SHA)

## Available Commands

Remind users of available Conductor commands:

- `/conductor:setup` - Initialize Conductor in a project
- `/conductor:new-track` - Create a new feature/bug track
- `/conductor:implement` - Execute tasks from the current track
- `/conductor:status` - Show project progress
- `/conductor:revert` - Git-aware revert of tracks/phases/tasks

## Context Loading

Before starting any implementation work, always load:
1. `conductor/workflow.md` - For task lifecycle procedures
2. `conductor/tech-stack.md` - For technology constraints
3. The active track's `spec.md` - For requirements
4. The active track's `plan.md` - For current task status

## Git Integration

Conductor tracks work through Git:
- Each task completion = one code commit + one plan commit
- Phase checkpoints create special commits with git notes
- SHAs are recorded in `plan.md` for traceability
- Use semantic commit messages following the project's conventions

## Error Handling

If something goes wrong:
1. Do not proceed without user confirmation
2. Announce the failure clearly
3. Suggest recovery options (e.g., `/conductor:revert`)
4. Wait for user instructions

## Quality Gates

Before marking any task complete, verify:
- All tests pass
- Code coverage meets requirements (>80%)
- Code follows project's style guidelines
- Public functions are documented
- No linting errors
- No security vulnerabilities introduced
