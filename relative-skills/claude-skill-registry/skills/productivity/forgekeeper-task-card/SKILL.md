---
name: forgekeeper-task-card
description: Create Forgekeeper task cards following project conventions
tags: [forgekeeper, planning, tasks, documentation]
version: 1.0.0
author: forgekeeper-team
---

# Forgekeeper Task Card Creation

## Overview
This skill helps create well-structured task cards for the Forgekeeper project following the established conventions in `tasks.md`.

## When to Use
Use this skill when:
- User requests creating a new task or feature
- Planning new development work
- Need to document a bug fix or improvement
- Creating sprint or milestone tasks

## Prerequisites
- Access to `tasks.md` file (read to understand existing structure)
- Understanding of the feature being requested
- Sprint/milestone context (if applicable)

## Instructions

### Step 1: Identify Task Details
Gather the following information:
- **Task ID**: Next available T### number (read tasks.md to find latest)
- **Sprint/Milestone**: Which sprint or milestone this belongs to
- **Task Type**: feat, fix, chore, docs, test, refactor
- **Title**: Clear, concise description (< 80 characters)
- **Description**: Detailed explanation of what needs to be done

### Step 2: Structure the Task Card
Follow this template:

```markdown
### T### - [Title]

**Type**: [feat/fix/chore/docs/test/refactor]
**Sprint**: [Sprint name or number]
**Status**: [pending/in-progress/completed]
**Priority**: [high/medium/low]

**Description**:
[Detailed description of the task]

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Technical Notes**:
- Implementation approach
- Files to modify
- Dependencies or prerequisites

**Testing**:
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing steps

**Documentation**:
- [ ] Update CLAUDE.md if architecture changes
- [ ] Add/update comments
- [ ] Update relevant docs/

**Estimated Effort**: [hours or story points]
```

### Step 3: Validate Against Project Standards
Ensure the task card:
- Uses conventional commit prefixes (feat:, fix:, docs:, etc.)
- Includes all required sections
- Has clear acceptance criteria
- Specifies testing requirements
- Notes documentation needs

### Step 4: Place in Appropriate Milestone
Tasks should be organized under:
- **Active Sprints**: Current development work
- **Backlog**: Future work, not yet prioritized
- **Completed**: Finished tasks (moved to bottom)

## Expected Output
A complete task card entry that can be added to `tasks.md`, properly formatted and containing all necessary information for implementation.

## Error Handling

**Error**: Missing task ID
- **Cause**: Haven't read tasks.md to find next available number
- **Fix**: Read tasks.md and find the highest T### number, increment by 1

**Error**: Unclear acceptance criteria
- **Cause**: Task requirements not well defined
- **Fix**: Ask user for clarification on expected outcomes

**Error**: Missing sprint/milestone
- **Cause**: Task not associated with development plan
- **Fix**: Ask user which sprint or add to Backlog

## Examples

### Example 1: Feature Request
```
User request: "Add support for PostgreSQL connections in MCP"

Skill invocation:
1. Read tasks.md to find next ID (e.g., T415)
2. Identify as Sprint 4 task (Custom MCP Servers)
3. Create task card:

### T415 - Add PostgreSQL MCP Server Support

**Type**: feat
**Sprint**: Sprint 4 - Custom MCP Servers
**Status**: pending
**Priority**: medium

**Description**:
Add support for PostgreSQL database connections through a custom MCP server.
Users should be able to query databases, view schemas, and execute operations.

**Acceptance Criteria**:
- [ ] Create postgres-mcp-server in frontend/mcp/servers/
- [ ] Implement query execution tool
- [ ] Implement schema inspection tool
- [ ] Add connection pooling
- [ ] Handle connection errors gracefully

**Technical Notes**:
- Use pg library for PostgreSQL connections
- Follow MCP server protocol v1.0
- Support connection string from environment variable
- Implement query timeout (30s default)

**Testing**:
- [ ] Unit tests for query execution
- [ ] Integration tests with test database
- [ ] Error handling tests (connection failures, timeouts)
- [ ] Manual testing with local PostgreSQL

**Documentation**:
- [ ] Add to docs/mcp/PRE_BUILT_SERVERS.md
- [ ] Create example config in mcp-servers.example.json
- [ ] Update CLAUDE.md with Postgres server info

**Estimated Effort**: 8 hours
```

### Example 2: Bug Fix
```
User request: "Fix hot-reload not working for skills"

Skill invocation:
1. Read tasks.md to find next ID (e.g., T508)
2. Identify as Sprint 3 task (Skills System)
3. Create task card:

### T508 - Fix Skills Hot-Reload File Watching

**Type**: fix
**Sprint**: Sprint 3 - Skills System
**Status**: pending
**Priority**: high

**Description**:
File watching for skills hot-reload is not triggering when SKILL.md files
are modified. Need to debug and fix the file watcher in skills/registry.mjs.

**Acceptance Criteria**:
- [ ] File watcher detects changes to SKILL.md files
- [ ] Debounce works correctly (500ms delay)
- [ ] Skills reload when files change
- [ ] No duplicate reload triggers
- [ ] Works on Linux, macOS, and Windows

**Technical Notes**:
- Issue likely in skills/registry.mjs startWatcher()
- Check fs.watch vs fs.watchFile behavior
- May need recursive:true option
- Test with both file edits and new file creation

**Testing**:
- [ ] Unit test for watcher setup
- [ ] Integration test: modify skill, verify reload
- [ ] Test on multiple platforms
- [ ] Test with multiple rapid changes (debounce)

**Documentation**:
- [ ] Add troubleshooting section to docs/skills/README.md
- [ ] Document platform-specific watcher behavior

**Estimated Effort**: 3 hours
```

## Resources
- `tasks.md` - Main task tracking file
- `.git/logs/HEAD` - For commit message examples
- `CONTRIBUTING.md` - Contribution guidelines

## Notes
- Always read `tasks.md` first to understand current task numbering and structure
- Keep tasks focused and atomic (one clear objective)
- Link related tasks using "Depends on: T###" if needed
- Update task status as work progresses (pending → in-progress → completed)
- Move completed tasks to "Completed" section with completion date

## Version History
- **1.0.0** (2025-11-21): Initial release
