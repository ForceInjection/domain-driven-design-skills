---
name: task-delegation
description: Delegate user stories with complete context, clear acceptance criteria, and validation
version: 1.1.0
type: skill
---

# Task Delegation

Delegate user stories to specialized agents with complete context, clear ownership, and standardized workflow.

## What This Skill Provides

- **Delegation brief template**: Comprehensive task handoff format
- **Initialization script**: Auto-create delegation documents with story context
- **Validation**: Verify delegation completeness before handoff
- **AI-guided workflow**: Create complete delegation briefs with acceptance criteria

## When to Use

- Delegating story implementation to agents
- Creating delegation briefs for parallel workstreams
- Ensuring agents have complete context before starting
- Validating delegation readiness

## Quick Start

### 1. Initialize Delegation

```bash
# From project root
./scripts/init-delegation.sh us-001 fullstack-engineer
```

Creates:
```
specs/{feature}/stories/us-001/delegation/
└── fullstack-engineer.delegation.md  ← Fill this
```

Auto-extracts context from story tracker.

### 2. Fill Delegation Brief

Use AI-guided prompt:
```
/create-delegation-brief
```

Guides you through:
- Context and user value
- Acceptance criteria (agent-specific)
- Dependencies (what must be ready first)
- Technical details (files, architecture)
- Handoff requirements (what next story needs)
- Standards reference

### 3. Validate Completeness

```bash
./scripts/validate-delegation-brief.sh us-001 fullstack-engineer
```

Checks:
- [ ] All required sections present
- [ ] No [Fill] placeholders
- [ ] Acceptance criteria defined with checkboxes
- [ ] Branch/worktree assigned

Exit code 0 = passed, 1 = failed.

---

## Legacy Delegation Workflow (Reference)

### Core Principles

### 1. Complete Context Transfer

**Every delegation includes**:
- User story specification
- Acceptance criteria
- Dependencies (what must be ready first)
- Handoff requirements (what next story needs)
- Branch/worktree assignment
- Constitution/spec references

### 2. Clear Ownership

**One agent per story, no shared ownership**:
- Agent assigned to specific worktree
- Agent owns story from start to merge
- Agent responsible for tests and documentation
- Agent reports completion status

### 3. Structured Communication

**Standardized handoff format**:
- Delegation: Feature Lead → Agent
- Progress: Agent → Feature Lead
- Completion: Agent → Feature Lead
- Questions: Agent ↔ Feature Lead

---

## Delegation Workflow

### Phase 1: Story Assignment

**Command**: `/delegate.assign <story-id> <agent-id>`

**Delegation Package**:
```markdown
## Story Delegation: US1 - Natural Language Bird Search API

**Assigned To**: Agent-FullStack-A  
**Worktree**: `worktrees/feat-us1`  
**Branch**: `feat/us1-bird-search`  
**Estimated Effort**: 2 days  
**WIP Slot**: 1 of 3

### Story Context
From Feature: Natural Language Bird Search  
Spec Reference: `specs/001-bird-search-ui/spec.md`  
Constitution: `birdmate/AGENTS.md` (Principles I, II, III)

### User Story
**As a** birdwatcher  
**I want** to search for birds using natural language descriptions  
**So that** I can identify birds without knowing scientific names

**Acceptance Criteria**:
- [ ] POST /api/search endpoint accepts text query
- [ ] Returns top 5 matching bird species with confidence scores
- [ ] Query logged with timestamp (Constitution Principle IV)
- [ ] 80%+ test coverage (Constitution Principle III)
- [ ] Response time < 2s (NFR-001)

### Dependencies
**Prerequisites** (MUST be complete before starting):
- ✅ T010: Database schema created
- ✅ T016: OpenAI embeddings generated
- ✅ T022: Shared TypeScript types defined

**Provides to Next Story** (US2 - Search UI):
- API contract: POST /api/search (see contracts/api.openapi.yml)
- Response schema: BirdSearchResult[]
- Error codes: 400 (invalid query), 500 (search failed)

### Technical Guidance
**Stack**: Node.js + TypeScript + Express + SQLite + OpenAI SDK  
**Test Framework**: Vitest  
**Key Files**:
- `backend/src/api/routes/search.ts` (endpoint)
- `backend/src/services/searchService.ts` (logic)
- `backend/src/db/queries/vectorSearch.ts` (embeddings)
- `backend/tests/api/search.test.ts` (integration tests)

**Constitution Compliance**:
- Principle III: TDD mandatory (write tests first)
- Principle IV: Log all queries to search_queries table
- Principle II: Reference eBird taxonomy only

### Skills to Apply
- **tdd-workflow**: Red → Green → Refactor cycle
- **claude-framework**: Error handling, input validation, logging
- **fullstack-expertise**: Backend API design patterns

### Questions?
Contact Feature Lead via: `/delegate.question <story-id> <question>`
```

---

### Phase 2: Agent Acceptance

**Command**: `/delegate.accept <story-id>`

**Agent acknowledges delegation and confirms**:
```markdown
## Story Accepted: US1

**Agent**: Agent-FullStack-A  
**Acknowledged**: 2025-12-23 10:00 AM  
**Clarifications Needed**: None  
**Estimated Start**: Immediately  
**Estimated Completion**: 2025-12-25 EOD

**Setup Verified**:
- ✅ Worktree created: `worktrees/feat-us1`
- ✅ Branch checked out: `feat/us1-bird-search`
- ✅ Dependencies confirmed complete
- ✅ Tests run successfully (0 implemented yet)
- ✅ Constitution reviewed

**Next Steps**:
1. Write API endpoint tests (TDD)
2. Implement search service
3. Integrate OpenAI embeddings
4. Run test suite (target: 80%+ coverage)
5. Update API documentation
```

---

### Phase 3: Progress Reporting

**Command**: `/delegate.progress <story-id> <status>`

**Daily progress updates**:
```markdown
## Progress Update: US1 - Day 1

**Date**: 2025-12-23  
**Status**: 🔄 In Progress (40% complete)  
**Blockers**: None  

**Completed Today**:
- ✅ Wrote API endpoint tests (15 test cases)
- ✅ Implemented basic search route handler
- ✅ Integrated OpenAI embedding similarity search
- ✅ Test coverage: 45% (target: 80%)

**Planned for Tomorrow**:
- ⏳ Implement query logging (Constitution Principle IV)
- ⏳ Add error handling for invalid queries
- ⏳ Increase test coverage to 80%+
- ⏳ Update API documentation

**Risks**:
- OpenAI API rate limiting (handling with exponential backoff)

**Questions**:
- Should we cache embedding similarity results? (Performance NFR-001)
```

---

### Phase 4: Story Completion

**Command**: `/delegate.complete <story-id>`

**Completion checklist**:
```markdown
## Story Completion: US1 - Natural Language Bird Search API

**Agent**: Agent-FullStack-A  
**Completed**: 2025-12-25 3:00 PM  
**Branch**: `feat/us1-bird-search`  
**Pull Request**: #123

### Acceptance Criteria ✅
- ✅ POST /api/search endpoint accepts text query
- ✅ Returns top 5 matching bird species with confidence scores
- ✅ Query logged with timestamp (Constitution Principle IV)
- ✅ 82% test coverage (exceeds 80% target)
- ✅ Response time: 1.2s average (meets < 2s requirement)

### Constitution Compliance ✅
- ✅ Principle III: TDD applied (tests written first)
- ✅ Principle IV: All queries logged to search_queries table
- ✅ Principle II: eBird taxonomy referenced correctly

### Deliverables
**Code Changes**:
- `backend/src/api/routes/search.ts` (new)
- `backend/src/services/searchService.ts` (new)
- `backend/src/db/queries/vectorSearch.ts` (new)
- `backend/tests/api/search.test.ts` (new, 18 tests)

**Documentation**:
- Updated: `contracts/api.openapi.yml` (POST /api/search)
- Updated: `README.md` (API usage examples)

**Tests**:
- Unit tests: 12 passing
- Integration tests: 6 passing
- Coverage: 82% (backend/src/services/)

### Handoff to Next Story (US2)
**Provides**:
- API endpoint: POST /api/search
- Request schema: `{ query: string }`
- Response schema: `BirdSearchResult[]` (see shared/types/index.ts)
- Error codes: 400 (invalid), 429 (rate limit), 500 (server error)
- Example queries: See tests/api/search.test.ts

**Dependencies Resolved**:
- ✅ API contract matches contracts/api.openapi.yml
- ✅ Response types exported from shared/types/
- ✅ CORS configured for frontend integration

**Known Limitations**:
- Caching not implemented (defer to US3)
- Rate limiting: 10 requests/min (may need adjustment)

### Ready for Merge
- ✅ All tests passing
- ✅ Branch synced with main (no conflicts)
- ✅ Code review requested
- ✅ Documentation complete
```

---

### Phase 5: Handoff Review

**Command**: `/delegate.review <story-id>`

**Feature lead validates completion**:
```markdown
## Story Review: US1

**Reviewer**: Feature Lead  
**Review Date**: 2025-12-25 4:00 PM  
**Status**: ✅ APPROVED

### Validation Checklist
- ✅ Acceptance criteria met (5/5)
- ✅ Constitution compliance verified
- ✅ Test coverage adequate (82% > 80%)
- ✅ Handoff documentation complete
- ✅ No merge conflicts with main
- ✅ API contract matches spec

### Cross-Story Consistency
- ✅ No conflicts with US2 (UI implementation)
- ✅ No conflicts with US3 (caching layer)
- ✅ Shared types properly exported

### Merge Approved
**Action**: Merge `feat/us1-bird-search` → `main`  
**Next**: Assign Agent-FullStack-A to US4 (WIP slot available)

**Feedback to Agent**:
- Excellent test coverage
- Good error handling
- Suggestion: Consider adding query validation schemas for future stories
```

---

## Delegation Patterns

### Pattern 1: Sequential Stories (Dependent)

**Story 1** → **Story 2** → **Story 3**

```markdown
Story 2 CANNOT start until Story 1 completes.

Example:
- US1: Build API endpoint
- US2: Build UI that calls API (depends on US1)
- US3: Add caching to API (depends on US1)

Delegation Timing:
- Assign US1 immediately
- Assign US2 after US1 merge
- Assign US3 after US1 merge (parallel with US2)
```

### Pattern 2: Parallel Stories (Independent)

**Story 1** || **Story 2** || **Story 3**

```markdown
All stories can run simultaneously (no dependencies).

Example:
- US1: Build backend API
- US2: Build frontend UI (mocked API)
- US3: Setup deployment pipeline

Delegation Timing:
- Assign all 3 stories immediately
- Use worktrees: feat-us1, feat-us2, feat-us3
- Merge in any order
```

### Pattern 3: Mixed Dependencies

```markdown
     US1 (API)
      ↓
  ┌───┴───┐
  ↓       ↓
 US2     US3
(UI)   (Cache)
  ↓       ↓
  └───┬───┘
      ↓
    US4
  (E2E Tests)

Delegation Strategy:
1. Assign US1 (slot 1)
2. Wait for US1 completion
3. Assign US2 and US3 simultaneously (slots 1, 2)
4. Wait for both completions
5. Assign US4 (slot 1)
```

---

## Communication Protocols

### Agent → Feature Lead

**Status Updates** (daily):
```markdown
/delegate.progress us1 "40% complete, on track, no blockers"
```

**Questions**:
```markdown
/delegate.question us1 "Should we cache embedding results for performance?"
```

**Blocked**:
```markdown
/delegate.blocked us1 "Waiting for US3 API contract definition"
```

**Completion**:
```markdown
/delegate.complete us1
```

### Feature Lead → Agent

**Delegation**:
```markdown
/delegate.assign us2 agent-fullstack-b
```

**Clarification**:
```markdown
/delegate.clarify us1 "Yes, implement caching in US3, not US1. Keep US1 simple."
```

**Priority Change**:
```markdown
/delegate.reprioritize us2 "HIGH - blocking frontend demo"
```

---

## WIP Limit Enforcement

**Maximum 3 concurrent delegations**:

```markdown
## WIP Tracker

| Slot | Story | Agent | Status | Branch |
|------|-------|-------|--------|--------|
| 1    | US1   | Agent-A | 🔄 WIP | feat-us1 |
| 2    | US2   | Agent-B | 🔄 WIP | feat-us2 |
| 3    | US3   | Agent-C | 🔄 WIP | feat-us3 |

❌ CANNOT delegate US4 - all slots full
✅ Wait for US1, US2, or US3 completion
```

**When story completes**:
1. Free up WIP slot
2. Select next story from backlog
3. Delegate to available agent
4. Update WIP tracker

---

## Commands Reference

### AI-Assisted Prompts

| Prompt | Purpose | Who Uses |
|--------|---------|----------|
| `/delegate.assign` | Assign story to agent with complete context | Feature Lead |
| `/delegate.review` | Review completed story for merge readiness | Feature Lead |
| `/delegate.clarify` | Answer agent questions and provide clarifications | Feature Lead |
| `/delegate.reprioritize` | Change story priority and resequence backlog | Feature Lead |

### Communication Flow

| Action | Command | Direction |
|--------|---------|-----------|
| Assign story | `/delegate.assign` | Feature Lead → Agent |
| Report progress | Agent update | Agent → Feature Lead |
| Mark complete | Agent notification | Agent → Feature Lead |
| Review story | `/delegate.review` | Feature Lead validates |
| Ask question | Agent request | Agent → Feature Lead |
| Answer question | `/delegate.clarify` | Feature Lead → Agent |
| Change priority | `/delegate.reprioritize` | Feature Lead decision |

### Quick Reference

| Scenario | Use This Prompt |
|----------|-----------------|
| Starting new story | `/delegate.assign us[N] agent-name` |
| Story completed | `/delegate.review us[N]` |
| Agent blocked | `/delegate.clarify us[N]` |
| Priorities change | `/delegate.reprioritize` |

---

## Best Practices

### ✅ Do This

- **Complete context**: Include all dependencies, specs, and acceptance criteria
- **Clear ownership**: One agent per story, no ambiguity
- **Daily updates**: Require progress reports from all agents
- **Early questions**: Agents should ask clarifications immediately
- **Handoff documentation**: Every story documents what next story needs

### ❌ Don't Do This

- **Partial delegation**: Don't assign stories without complete context
- **Shared ownership**: Never split one story across multiple agents
- **Silent agents**: Require daily progress updates
- **Scope creep**: Keep story boundaries clear and enforced
- **Skip handoffs**: Every story must document outputs

---

## Success Metrics

- ✅ **Zero ambiguity**: All agents understand their assignments
- ✅ **WIP limit respected**: Never exceed 3 concurrent stories
- ✅ **Daily visibility**: Progress updates from all agents
- ✅ **Smooth handoffs**: Next story has everything it needs
- ✅ **High completion rate**: Stories merge successfully without rework
