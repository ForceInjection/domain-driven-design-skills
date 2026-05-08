---
name: openspec-workflow
description: OpenSpec task management workflow. Use for creating, tracking, and closing tasks.
---

# OpenSpec Workflow

## 1. Folder Structure

```
openspec/
└── changes/
    └── NNNNN-name/
        ├── proposal.md
        └── tasks.md
```

## 2. Numbering

### Find last number
```bash
ls openspec/changes/ | sort -r | head -1
```

### New number
- Last number + 1
- Format: 5 digits with leading zeros
- Examples: 00001, 00027, 00128

## 3. proposal.md Template

```markdown
# NNNNN: Change Name

## Status
PENDING | IN_PROGRESS | DEPLOYED

## Goal
What do we want to achieve?

## Scope
### Included
- Item 1
- Item 2

### Excluded
- Item 1

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Design
(Added by architect agent)

### Files to Modify
- `path/to/file1.cpp`
- `path/to/file2.h`

### New Files
- `path/to/new_file.cpp`
- `path/to/new_file.h`

### Class Diagram
(If needed)

## Notes
Additional context or decisions.
```

## 4. tasks.md Template

```markdown
# Tasks for #NNNNN

## Implementation
- [ ] Task 1 description
- [ ] Task 2 description
- [ ] Task 3 description

## Testing
- [ ] Write unit tests
- [ ] Manual testing

## Documentation
- [ ] Update CHANGELOG.md
- [ ] Update ROADMAP.md (if new feature)
```

## 5. Status Lifecycle

```
PENDING → IN_PROGRESS → DEPLOYED
```

### PENDING
- Proposal created
- Requirements gathered
- Waiting for design

### IN_PROGRESS
- Design complete
- Implementation ongoing
- Testing ongoing

### DEPLOYED
- All tasks complete
- Code reviewed
- Tests passed
- Documentation updated
- Committed to git

## 6. Creating a Task

1. User says "new task" or similar
2. Ask if user has an idea:
   - YES → Step 4
   - NO → Step 3
3. Read ROADMAP.md:
   - Find 3 uncompleted items [ ]
   - Propose to user
   - Wait for selection
4. Gather requirements:
   - GOAL: What to achieve?
   - SCOPE: What's in/out?
   - CRITERIA: How to verify done?
   - Ask until user says "OK" or "enough"
5. Find last OpenSpec number
6. Create folder: `openspec/changes/NNNNN-name/`
7. Generate proposal.md
8. Generate tasks.md
9. Report:
   - "Created OpenSpec #NNNNN"
   - "Next: architect will analyze"

## 7. Tracking Progress

1. Find active OpenSpec (Status = IN_PROGRESS)
2. Check tasks.md:
   - Count [x] vs [ ]
3. Report:
   - "OpenSpec #NNNNN: 4/7 tasks done"
   - "Next step: [description]"

## 8. Closing a Task

1. Verify completeness:
   - [ ] All checkboxes in tasks.md = [x]?
   - [ ] Code review passed?
   - [ ] Tests passed?
2. Verify documentation:
   - [ ] CHANGELOG.md has entry in [Unreleased]?
   - [ ] ROADMAP.md has checkbox [x] (if feature)?
3. If missing → report what's missing
4. If OK:
   - Change status → DEPLOYED
   - Propose commit message
   - "Task #NNNNN ready to close"
