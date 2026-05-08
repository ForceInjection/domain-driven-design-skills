---
name: task-plan-skill
description: Use when starting a new feature that needs planning - runs brainstorming then creates numbered task folder in _tasks/
---

# Task Planning Skill

Explores requirements via brainstorming, then creates structured task folder for implementation.

**REQUIRED SUB-SKILL:** Use `superpowers:brainstorming` FIRST to explore requirements before creating files.

## When to Use

- Starting a feature that spans multiple files
- Work that needs design before implementation
- Complex changes requiring step-by-step planning

## Workflow

### 1. Run Brainstorming

**MANDATORY:** Invoke `superpowers:brainstorming` skill first to:
- Clarify user intent and requirements
- Explore technical approaches
- Identify edge cases and constraints
- Get user approval on design direction

Only proceed to step 2 after brainstorming is complete.

### 2. Determine Next Folder Number

Check existing folders in `_tasks/`:

```bash
ls _tasks/
```

Find highest `{NN}-*` number and use next one (e.g., if `12-replace-alerts` exists, use `13`).

### 3. Create Folder and Task File

Create folder and write `_tasks/{NN}-{feature-name}/01-task.md` with brainstorming output:

```markdown
**Date:** YYYY-MM-DD
**Subject:** {Feature description from brainstorming}
**Status:** Planning

## Goal

{Goal refined during brainstorming}

## Requirements

{Requirements gathered during brainstorming}

## Technical Notes

{Constraints and considerations from brainstorming}
```

### 4. Create Plan File

Use `superpowers:writing-plans` to create detailed implementation plan, then write to `_tasks/{NN}-{feature-name}/02-plan.md`:

```markdown
# {Feature Name} Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** {One-line summary}

**Architecture:** {High-level approach}

---

## Task 1: {Description}

**Files:**
- Modify: `path/to/file`
- Create: `path/to/new/file`

**Steps:**
1. {Step details}
2. {Step details}

**Verification:** {How to verify this task is complete}

---

## Task 2: ...
```

### 5. Commit Planning Docs

```bash
git add _tasks/{NN}-{feature-name}/
git commit -m "docs: add task and plan for {feature-name}"
```

## File Naming Convention

| File | Purpose |
|------|---------|
| `01-task.md` | Requirements, goals, context |
| `02-plan.md` | Step-by-step implementation plan |
| `02-design.md` | Alternative: architecture/design doc |
| `03+` | Additional docs as needed |

## Notes

- Always commit planning docs BEFORE starting implementation
- Reference tech debt if task originates from `_TECH_DEBT/`
- Keep plans actionable with specific file paths and verification steps
