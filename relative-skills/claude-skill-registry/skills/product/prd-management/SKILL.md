---
name: prd-management
description: Automatic PRD lifecycle management, organization, and status tracking. Use when working with Product Requirements Documents (PRDs) or Feature Requirements Documents (FRDs) for proper naming, directory structure, and status transitions.
---

# PRD Management Skill

This skill automatically activates when working with Product Requirements Documents (PRDs) or Feature Requirements Documents (FRDs). It ensures proper lifecycle management, organization, and tracking.

## Automatic Behaviors

When this skill activates, Claude will automatically:

1. **Apply PRD Naming Conventions**
   - Full Product PRDs: `<product-name>-prd.md`
   - Feature PRDs: `<feature-name>-frd.md`
   - Simple Feature PRDs: `<feature-name>-simple-frd.md`
   - Task Lists: `<prd-name>-tasks.md`

2. **Maintain Directory Structure**
   ```
   product-docs/
   ├── prds/
   │   ├── active/           # Currently being implemented
   │   │   ├── product-prds/ # Full product PRDs
   │   │   └── feature-prds/ # Feature-specific PRDs
   │   ├── review/           # Under review/approval
   │   ├── approved/         # Approved, awaiting implementation
   │   └── archive/          # Completed/deprecated
   ├── personas/             # User personas
   ├── positioning/          # Product positioning docs
   └── tasks/               # Generated task lists
   ```

3. **Enforce Status Lifecycle**
   - DRAFT → REVIEW → APPROVED → ACTIVE → COMPLETE → ARCHIVED
   - Validate status transitions
   - Update metadata on status changes

4. **Include Required Metadata**
   ```yaml
   ---
   status: DRAFT
   version: 1.0
   created: YYYY-MM-DD
   last_updated: YYYY-MM-DD
   author:
   approved_by:
   approved_date:
   task_file: ./tasks/<name>-tasks.md
   ---
   ```

## PRD-to-Task Linking

When creating or updating PRDs:

1. **In the PRD**, add Implementation Tracking section:
   ```markdown
   ## Implementation Tracking

   Task List: ./tasks/<filename>-tasks.md
   Generated: YYYY-MM-DD
   Status: See task file for current progress
   ```

2. **In task files**, reference source PRD:
   ```markdown
   Source PRD: ../prds/active/<filename>.md
   Generated: YYYY-MM-DD
   Total Tasks: X
   Completed: 0
   ```

## Quality Checks

Before marking any PRD as APPROVED, verify:
- [ ] Executive summary is clear and concise
- [ ] Problem statement is specific and validated
- [ ] Success metrics are quantifiable
- [ ] User personas are detailed
- [ ] Technical requirements are complete
- [ ] All required sections are filled

## Archival Rules

Archive PRDs when:
1. Implementation is 100% complete
2. PRD is superseded by newer version
3. Project/feature is cancelled
4. PRD is over 1 year old and inactive

Add archive metadata:
```yaml
archive_date: YYYY-MM-DD
archive_reason: Implementation complete
final_task_completion: 100%
implementation_duration: X days
```
