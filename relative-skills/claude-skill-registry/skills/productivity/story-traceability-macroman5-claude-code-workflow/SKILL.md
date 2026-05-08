---
name: story-traceability
description: Ensure Acceptance Criteria map to Tasks and Tests for PR-per-story workflow
version: 0.1.0
tags: [planning, QA]
triggers:
  - acceptance criteria
  - user story
  - traceability
---

# Story Traceability

## Purpose
Create a clear AC → Task → Test mapping to guarantee coverage and reviewability.

## Behavior
1. Build a table: AC | Task(s) | Test(s) | Notes.
2. Insert into `USER-STORY.md`; add brief references into each `TASK-*.md`.
3. Call out missing mappings; propose test names.

## Guardrails
- Every AC must have ≥1 task and ≥1 test.
- Keep table compact; link file paths precisely.

## Integration
- Project Manager agent; `/lazy create-feature` output phase.

## Example Prompt
> Add traceability for US-20251027-001.

