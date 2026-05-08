---
name: task-slicer
description: Split features into atomic 2–4h tasks with independent tests and minimal dependencies
version: 0.1.0
tags: [planning, tasks]
triggers:
  - break into tasks
  - task list
  - estimates
---

# Task Slicer

## Purpose
Turn a user story into small, testable tasks with clear inputs/outputs.

## Behavior
1. Create 3–10 tasks, each 2–4 hours.
2. For each task: description, files, test focus, dependencies, estimate.
3. Name files `TASK-US-<id>-<n>.md` and reference the story ID.

## Guardrails
- Prefer independence; minimize cross-task dependencies.
- Split or merge tasks to hit target size.

## Integration
- Project Manager agent; `/lazy create-feature` task generation step.

## Example Prompt
> Slice US-20251027-001 into executable tasks.

