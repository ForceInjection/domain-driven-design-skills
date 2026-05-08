---
name: manage-planning
description: MUST INVOKE this skill when creating executable plans in .prompts/planning/ with Brief → Roadmap → Phases structure. Expert patterns for hierarchical project plans.
---

# Objective

Create hierarchical project plans that agents can execute with fresh context.

## Quick Start

**Use the [create-new-plan workflow](workflows/create-new-plan.md)** to:

1. **Determine plan type** (Lite vs Standard)
2. **Gather project context** (vision, constraints, stakeholders)
3. **Create plan files** (BRIEF.md, ROADMAP.md, phase PLAN.md files)
4. **Validate quality** (self-contained, atomic tasks, checkpoints)

This workflow provides step-by-step guidance with templates for creating executable plans that subagents can run with fresh context.

# Plan Types

## Lite Plan
Single `PLAN.md` with 2-3 tasks for smaller projects.

**Use when**: Simple feature, quick task, focused work

## Standard Plan
Hierarchical structure with BRIEF.md + ROADMAP.md + phased PLAN.md files

**Use when**: Complex project, multiple phases, team coordination

# Directory Structure

```
.prompts/planning/
├── BRIEF.md        # Project vision, constraints, scope
├── ROADMAP.md      # Architecture, phases, progress tracking
└── phases/
    ├── {number}-{phase-name}/
    │   ├── PLAN.md      # Executable tasks for this phase
    │   └── SUMMARY.md   # Phase summary
    └── ...
```

# Key Methodology

## Plans Are Executable Prompts
- NOT documentation for humans
- Prompts that subagents RUN to do work
- Must be self-contained (subagents know nothing)

## Context Management (Critical)
Subagents know NOTHING - every plan MUST:
- Explicitly list required files with paths
- Include @ references: `@src/database/schema.ts`
- Provide the "why" not just the "what"
- Be fully self-contained

## Scope Control
- **2-3 tasks per plan** maximum
- **~50% context budget** for references
- One phase ≈ one agent execution

## Checkpoints
Include `**[CHECKPOINT]**` for:
- Architecture decisions
- Major milestones
- Risk points

# Plan Numbering

Auto-increment from existing phases:
```bash
find .prompts/planning/phases -type d | wc -l
```

# File Structure

## BRIEF.md
- Project vision and goals
- Constraints and scope boundaries
- Success criteria
- Key stakeholders

## ROADMAP.md
- Architecture overview
- Phase breakdown
- Dependencies between phases
- Progress tracking

## PLAN.md (Phased)
```markdown
# Execution Context
Files to read before starting

# Tasks
Checkbox list of actions

# Checkpoints
Items with **[CHECKPOINT]** markers

# Success Criteria
Definition of done
```

# Reference Files

- `references/plan-format.md` - Detailed PLAN.md structure
- `templates/brief.md` - BRIEF.md template
- `templates/roadmap.md` - ROADMAP.md template
- `templates/phase-prompt.md` - Phase PLAN.md template
- `references/scope-estimation.md` - How to size plans
