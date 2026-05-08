---
name: todo-manage
description: Manage and organize TODO.md at project root - plan features, track progress, mark tasks complete, and clean up completed items. Use when planning tasks, organizing work, reviewing priorities, or managing the project TODO list. Access via /dipeotodos command.
---

# TODO List Manager

Manage and organize the project TODO list (`TODO.md` at project root). Create comprehensive, phase-based task plans for complex projects.

**Access**: View current TODO.md via `/dipeotodos` command

## Core Responsibilities

### 1. Task Planning & Organization
- Break down features into specific, actionable tasks
- Organize by phases (3-5 recommended) based on dependencies
- Add effort estimates (Small/Medium/Large with hours)
- Note files affected and acceptance criteria
- Include risks and mitigation strategies

### 2. Task Tracking & Updates
- Mark tasks complete when finished
- Update status and progress notes
- Add blockers or dependencies
- Maintain timestamps

### 3. Cleanup & Maintenance
- Remove completed tasks after 1-2 weeks
- Consolidate duplicate tasks
- Remove stale/obsolete items
- Keep file focused and current

## What Makes TODO Management "Comprehensive"

Use comprehensive format for projects with 3+ phases or 10+ tasks:

### Required Elements
1. **Phase-based organization** (3-5 phases)
2. **Task details**: Action verb, effort estimate, files affected, acceptance criteria
3. **Summary section**: Total effort, task count, files, risks
4. **Clear context**: Goal, why this work, target outcome

### Quick Format Structure

```markdown
# DiPeO Project Todos

## [Project Name] (Priority Level)

**Goal**: One-sentence description
**Context**: Why this work is needed
**Target**: End state

### Phase 1: [Phase Name] ([Estimated Effort])
[Phase description]

- [ ] [Action verb task description]
  - [Implementation approach]
  - Estimated effort: Medium (2-3 hours)
  - Files: `path/to/file.py`
  - Risk: Low/Medium/High

### Phase 2: [Phase Name] ([Estimated Effort])
[Tasks...]

---

## Summary
**Total estimated effort**: X-Y hours
**Total tasks**: N tasks across M phases
**Primary files affected**:
- `file1.py` (major)
- `file2.py` (minor)
**Risk**: Low/Medium/High - [explanation]
**Mitigation**: [how to reduce risk]
```

## Phase Organization

Typical phase structure:
- **Phase 1**: Investigation/Foundation (2-3 hours)
- **Phase 2**: Core Implementation (5-7 hours)
- **Phase 3**: Integration & Testing (3-4 hours)
- **Phase 4**: Documentation & Cleanup (2-3 hours)
- **Phase 5**: Validation & Deployment (1-2 hours)

## Scope Management

**Workflow**:
1. Read TODO.md first
2. Break down into 3-5 phases with detailed tasks
3. Communicate plan (task count, phases, effort, risks)
4. Execute or iterate based on feedback

**Scope Sizing**:
- **Small (1-5 tasks)**: Simple format, proceed directly
- **Medium (6-15 tasks)**: Comprehensive format, 3-4 phases
- **Large (15+ tasks)**: Comprehensive format, 4-5 phases
- **Very Large (30+ tasks)**: Break into epics

## Quality Control

Every comprehensive TODO must have:
- ✅ 3-5 phases with effort estimates
- ✅ Task details (action verb, effort, files)
- ✅ Summary section (totals, files, risks)
- ✅ Consistent format (`- [ ]` checkboxes)
- ✅ Communication back to user with plan

## Quick Example

### ✅ Good (Comprehensive)
```markdown
## MCP SDK Migration (High Priority)

**Goal**: Migrate from legacy to official SDK
**Context**: Running dual implementations
**Target**: SDK-only with HTTP transport

### Phase 1: Investigation (2-3 hours)
- [ ] Investigate SDK HTTP transport support
  - Check if native HTTP available
  - Estimated effort: Small (1-2 hours)
  - Files: N/A (research)

### Phase 2: Implementation (5-7 hours)
- [ ] Enable SDK integration
  - Implement FastAPI integration
  - Create /mcp/messages endpoint
  - Estimated effort: Medium (3-4 hours)
  - Files: `mcp_sdk_server.py`
  - Risk: Medium

---

## Summary
**Total effort**: 14-18 hours
**Total tasks**: 12 tasks across 5 phases
**Files**: `mcp_sdk_server.py` (major), `router.py` (minor)
**Risk**: Medium - breaking changes
**Mitigation**: Maintain endpoint URL compatibility
```

### ❌ Bad (Not Comprehensive)
```markdown
## MCP Migration
- [ ] Use SDK
- [ ] Remove old code
- [ ] Update docs
```

Problems: No phases, estimates, files, context, or summary.

## Operational Guidelines

1. **Always read TODO.md first**
2. **Be specific**: Clear, actionable tasks
3. **Maintain context**: Enough detail for future reference
4. **Regular cleanup**: Remove completed tasks after 1-2 weeks
5. **Prioritize ruthlessly**: Not everything is high priority

## Decision Framework

**When adding tasks**:
- Specific and actionable?
- Clear success criteria?
- Appropriate priority?
- Dependencies noted?

**When cleaning up**:
- Completed >2 weeks ago?
- Still relevant?
- Related tasks to consolidate?

**When prioritizing**:
- Business/user impact?
- Blocking dependencies?
- Effort-to-value ratio?

## Edge Cases

- **No TODO.md exists**: Create at project root with "# DiPeO Project Todos"
- **Conflicting priorities**: Ask for clarification
- **Unclear tasks**: Break into subtasks or ask questions
- **Large cleanup needed**: Summarize and ask for confirmation

For detailed examples, format templates, and comparison of good vs bad TODO lists, see [references/format-guide.md](references/format-guide.md).
