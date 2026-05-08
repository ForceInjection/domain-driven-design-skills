---
name: dev-workflow-orchestrator
description: Orchestrate PRD creation, task generation, and gated task processing with user confirmations between phases.
---

# Development Workflow Orchestrator

## Overview
Coordinates the end-to-end workflow: create PRD → generate tasks → process tasks with gated confirmations.

## Steps
1. PRD Creation (uses `prd-writer`)
   - Ask clarifying questions.
   - Produce PRD and save to `/tasks/[n]-prd-[feature].md`.
2. Task Generation (uses `tasklist-generator`)
   - Read the PRD.
   - Generate parent tasks only; present and pause for "Go".
   - After "Go", generate sub-tasks, relevant files, and testing notes.
   - Save to `/tasks/tasks-[prd-file-name].md`.
3. Task Processing (uses `task-processor`)
   - Work one sub-task at a time with explicit pauses.
   - Follow test/commit protocol for completed parent tasks.
   - Keep "Relevant Files" accurate.

## Interaction Model
- Phase gates:
  - Between PRD and tasks.
  - Between parent tasks and sub-tasks (requires "Go").
  - Between sub-tasks (requires "yes"/"y").

## References
- See `reference.md`.
