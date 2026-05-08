---
name: tasklist-generator
description: Generate high-level tasks and gated sub-tasks from a PRD, with relevant files and testing guidance.
---

# Task List Generator

## Goal
Create a detailed, step-by-step task list from a given PRD to guide implementation.

## Output
- Format: Markdown (.md)
- Location: `/tasks/`
- Filename: `tasks-[prd-file-name].md` (e.g., `tasks-0001-prd-user-profile-editing.md`)

## Process
1. Receive PRD reference (specific file path).
2. Analyze PRD (functional requirements, user stories, etc.).
3. Assess current state of the codebase to identify relevant patterns/components and candidate files.
4. Phase 1: Generate parent (high-level) tasks only. Present them to the user and pause.
5. Wait for user confirmation: proceed only if user replies "Go".
6. Phase 2: Expand each parent task into actionable sub-tasks.
7. Identify relevant files (to create/modify) and associated tests.
8. Write tests: ensure unit/integration tests are included where relevant.
9. Generate final output and save to `/tasks/` with required filename.

## Output Format
```
## Relevant Files

- `path/to/potential/file1.ts` - Brief reason.
- `path/to/file1.test.ts` - Unit tests for `file1.ts`.
- `path/to/another/file.tsx` - Brief reason.
- `path/to/another/file.test.tsx` - Unit tests for `another/file.tsx`.
- `lib/utils/helpers.ts` - Utility functions.
- `lib/utils/helpers.test.ts` - Unit tests for helpers.

### Notes
- Unit tests co-located with code when possible.
- Use project test runner (e.g., Jest) per repo conventions.

## Tasks

- [ ] 1.0 Parent Task Title
  - [ ] 1.1 Sub-task description
  - [ ] 1.2 Sub-task description
- [ ] 2.0 Parent Task Title
  - [ ] 2.1 Sub-task description
- [ ] 3.0 Parent Task Title
```

## Interaction Model
- Explicit pause after parent tasks; proceed with sub-tasks only after "Go".
- Target audience: junior developer.

## References
- See `reference.md`.
