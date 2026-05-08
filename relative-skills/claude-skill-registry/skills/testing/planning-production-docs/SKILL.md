---
name: Planning Production Docs
description: Creates comprehensive PRDs, tech specs, task breakdowns, testing plans, and production checklists with proper task sequencing and MCP testing integration. Use when planning new features, structuring development workflows, or creating project documentation. Use PROACTIVELY after requirements discussions.
---

# Planning Architect

Create production-ready planning documents with proper task sequencing, testing strategy, and continuous validation.

## Quick Start

**Generate a complete planning package:**

```bash
# Create all planning docs for a feature
1. Create PRD - requirements and goals
2. Write tech spec - architecture and implementation
3. Generate task breakdown - with layer-based sequencing
4. Add testing plan - with MCP tool integration
5. Build production checklist - deployment readiness
```

## Core Documents (10 Types)

### 1. PRD - Product Requirements
**File**: `{feature}-prd.md`
**Purpose**: Defines WHAT and WHY

```markdown
# Feature Name - PRD

## Overview
[1-2 sentence summary]

## Goals
- Business goal
- Technical goal

## Use Cases
- Persona: [action] → [outcome]

## Scope
**In**: Feature A, B
**Out**: Feature X, Y

## Success Criteria
- Metric 1: target
- KPI: +X%
```

### 2. Tech Spec - Technical Specification
**File**: `{feature}-tech-spec.md`
**Purpose**: Explains HOW

Includes: Architecture, APIs, data models, security, dependencies

**See [reference/tech-spec-template.md](reference/tech-spec-template.md) for complete template**

### 3. Task Breakdown - Implementation Steps
**File**: `{feature}-tasks.md`
**Purpose**: Granular, sequenced implementation tasks

**Critical**: Use layer-based sequencing:
```
Layer 1: Database (Foundation)
  ↓
Layer 2: Backend (Logic)
  ↓
Layer 3: Frontend (UI)
  ↓
Layer 4: Testing (Continuous)
  ↓
Layer 5: Production (Deploy)
```

**See [reference/task-breakdown-template.md](reference/task-breakdown-template.md) for full template with testing integration**

### 4. Testing Plan - Quality Strategy
**File**: `{feature}-testing.md`

Includes:
- Unit tests (Vitest/Jest)
- Integration tests
- E2E tests (Playwright MCP)
- Visual regression
- MCP testing tools integration

**See [reference/testing-template.md](reference/testing-template.md)**

### 5. Production Checklist
**File**: `{feature}-production-checklist.md`

Pre-deploy validation:
- Code quality (TypeScript, linter, tests)
- Security (RLS, validation, no secrets)
- Performance (bundle size, Lighthouse)
- Testing (E2E, browser, manual QA)

**See [reference/production-checklist-template.md](reference/production-checklist-template.md)**

### 6-10. Additional Documents

**Roadmap** (`{feature}-roadmap.md`) - Milestones and timeline
**Progress Tracker** (`{feature}-progress.md`) - Status tracking
**API Reference** (`{feature}-api-reference.md`) - Endpoint docs
**Database Schema** (`{feature}-database-schema.md`) - ERD and migrations
**Prompt Templates** (`prompts/*.md`) - Claude implementation prompts

**See [reference/additional-docs.md](reference/additional-docs.md)**

## Task Sequencing Rules

**NEVER start Layer 2 before Layer 1 complete**
**ALWAYS test after each layer**
**REQUIRE Layer 4 tests pass before Layer 5**

Each task must have:
- Clear success criteria
- File paths
- Dependencies
- Testing validation

## MCP Testing Integration

### Playwright MCP (Browser Testing)
```
1. Navigate: mcp__playwright__browser_navigate
2. Snapshot: mcp__playwright__browser_snapshot
3. Click: mcp__playwright__browser_click
4. Assert: mcp__playwright__browser_wait_for
```

### Chrome DevTools MCP (Network Monitoring)
```
1. Navigate: mcp__chrome-devtools__navigate_page
2. Network: mcp__chrome-devtools__list_network_requests
3. Console: mcp__chrome-devtools__list_console_messages
4. Screenshot: mcp__chrome-devtools__take_screenshot
```

**See [reference/mcp-testing-guide.md](reference/mcp-testing-guide.md) for detailed examples**

## Workflow Patterns

### New Feature Workflow
1. Create PRD (requirements)
2. Write Tech Spec (architecture)
3. Generate Task Breakdown (implementation)
4. Build Testing Plan (validation)
5. Create Production Checklist (deploy)
6. Initialize Progress Tracker (monitoring)

### Database Change Workflow
1. Design schema (ERD)
2. Write migration (idempotent SQL)
3. Add RLS policies (security)
4. Create rollback (safety)
5. Test locally (validation)

**See [templates/](templates/) for prompt templates**

## File Organization

**Recommended structure:**
```
mvp-plan/{feature}/
├── prd.md
├── tech-spec.md
├── tasks.md
├── testing.md
├── production-checklist.md
├── progress.md
├── roadmap.md
├── prompts/
│   ├── 01-database.md
│   ├── 02-edge-function.md
│   ├── 03-component.md
│   └── 04-e2e-test.md
└── diagrams/
    └── architecture.mmd
```

## Best Practices

✅ **Do**:
- Break tasks into <1 day chunks
- Test after each layer
- Document dependencies explicitly
- Include rollback plans
- Use MCP tools for automation

❌ **Don't**:
- Create tasks without success criteria
- Skip testing until end
- Ignore task dependencies
- Write vague "implement feature" tasks

## Prompt Templates

Generate implementation prompts for Claude:

**Database Layer:**
```markdown
Task: Implement database schema for {feature}

Context: [DB details]
Instructions: [Step-by-step]
Success Criteria: [Validation]
Output: [Expected results]
```

**See [templates/prompt-templates.md](templates/prompt-templates.md) for all templates**

## Quick Reference

- **PRD**: What & Why (goals, use cases, scope)
- **Tech Spec**: How (architecture, APIs, data)
- **Tasks**: Implementation steps (layer-sequenced)
- **Testing**: Quality strategy (unit, E2E, MCP)
- **Checklist**: Production readiness (deploy validation)

---

*Create production-ready planning documentation with proper task sequencing and continuous testing validation.*
