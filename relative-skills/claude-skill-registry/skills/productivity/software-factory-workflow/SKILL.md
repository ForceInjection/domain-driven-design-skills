---
name: Software Factory Workflow
description: Complete 5-agent workflow for transforming ideas into validated software
---

# Software Factory Workflow

## Directory Layout & versioning

```
project-idea/
├── index.md                    # Raw idea (source of truth)
└── amendments/                 # Additional idea files (optional)
    └── *.md

project-docs/
├── README.md                   # Workflow documentation
├── prd/                        # Product Requirements Documents (Refinery output)
│   ├── prd-v1.md
│   ├── prd-v2.md
│   └── prd-latest.md           # Copy of latest version
├── blueprint/                  # Technical Blueprints (Foundry output)
│   ├── blueprint-v1.md
│   └── blueprint-latest.md
├── work-orders/                # Implementation Tasks (Planner output)
│   ├── work-orders-v1.md
│   └── work-orders-latest.md
└── validation/                 # Validation Reports (Validator output)
    ├── validation-v1.md
    └── validation-latest.md

src/                            # Implementation code (Assembler output, git-versioned)
```

### Versioning Convention

| Skill | Directory | File Pattern | Input Source |
|-------|-----------|--------------|---------------|
| 🔥 Refinery | `project-docs/prd/` | `prd-v{N}.md` | `project-idea/` |
| 🏭 Foundry | `project-docs/blueprint/` | `blueprint-v{N}.md` | `prd-latest.md` |
| 📋 Planner | `project-docs/work-orders/` | `work-orders-v{N}.md` | `blueprint-latest.md` |
| ⚙️ Assembler | `src/` | Git commits | `work-orders-latest.md` |
| ✅ Validator | `project-docs/validation/` | `validation-v{N}.md` | PRD + Implementation |

### Iterative Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Edit idea in   │────▶│  Run Refinery   │────▶│  Review PRD     │
│  project-idea/  │     │  (generates     │     │  in project-docs│
│                 │◀────│   prd-v{N}.md)  │◀────│                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        ▲                                               │
        └───────────────── iterate ─────────────────────┘
```

### Commands

- **"Run Refinery"** — Read `project-idea/`, generate next `prd-v{N}.md`
- **"Run Foundry"** — Read `prd-latest.md`, generate next `blueprint-v{N}.md`
- **"Run Planner"** — Read `blueprint-latest.md`, generate next `work-orders-v{N}.md`
- **"Run Assembler"** — Read `work-orders-latest.md`, implement in `src/`
- **"Run Validator"** — Read PRD + implementation, generate next `validation-v{N}.md`

### Extended Commands (Iteration & Features)

- **"Add feature: X"** — Refinery adds new feature to PRD, triggers full pipeline
- **"Fix WO-XXX"** — Assembler re-implements specific work order
- **"Iterate until green"** — Assembler loops until all tests pass
- **"Debug WO-XXX"** — Assembler investigates failing work order
- **"Test WO-XXX"** — Run tests for specific work order

### Related Documentation

- `assembler-agent/ITERATION.md` — Iterative testing protocol
- `refinery-agent/FEATURES.md` — Adding new features protocol
- `project-docs/workflow/iteration-protocol.md` — Complete iteration guide

## Purpose

This skill provides a comprehensive overview of the complete Software Factory methodology - a systematic approach to software development that uses 5 specialized agents working in sequence to transform raw ideas into tested, validated software.

## When to Use This Workflow

Use the Software Factory workflow when:
- Starting a new software project from an idea
- Converting user requirements into implemented features
- Establishing a systematic development process
- Coordinating between multiple developers or AI agents
- Ensuring quality through validation and feedback loops

## The 5-Agent Pipeline

The Software Factory uses a linear pipeline with feedback loops:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Refinery  │───▶│   Foundry   │───▶│   Planner   │───▶│  Assembler  │───▶│  Validator  │
│    Agent    │    │    Agent    │    │    Agent    │    │    Agent    │    │    Agent    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                                     ▲                                        │
       └─────────────────────────────────────┴────────────────────────────────────────┘
                                    Feedback Loop
```

### Agent Responsibilities Summary

| Agent | Input | Output | Key Activities |
|-------|-------|--------|----------------|
| 🔥 **Refinery** | Raw ideas, sketches, descriptions | Product Requirements Document (PRD) | Parse inputs, extract requirements, create user stories, generate mockups |
| 🏭 **Foundry** | PRD | Technical Blueprint | Design architecture, select technologies, define data models, specify APIs |
| 📋 **Planner** | Blueprint | Work Orders | Break down tasks, map dependencies, prioritize, create execution plan |
| ⚙️ **Assembler** | Work Orders | Implemented Code | Write code, run tests, document, ensure quality |
| ✅ **Validator** | Implementation | Validation Report + Feedback | Test requirements, collect feedback, identify issues, create improvement loop |

## Complete Workflow Example

Let's walk through a complete example: **Building a Collaborative Task Manager**

### Stage 1: Refinery Agent 🔥

**Input**: Raw idea
```
"I want to build a task management app for small teams. 
Users should be able to create tasks, assign them to 
team members, and track progress."
```

**Process**:
1. Parse the idea to extract key concepts
2. Identify users (team members, team leads)
3. Identify features (tasks, assignment, progress tracking)
4. Generate user stories
5. Create UI mockups
6. Define acceptance criteria

**Output**: PRD (excerpt)
```markdown
# Collaborative Task Manager PRD

## Core Features

### F1: User Authentication (P0)
**User Story**: As a team member, I want to sign up and log in 
so that I can access my team's tasks.

**Acceptance Criteria**:
- [ ] Users can register with email/password
- [ ] Users can log in and log out
- [ ] Sessions persist across page reloads

### F2: Task Management (P0)
**User Story**: As a team member, I want to create tasks 
so that work can be tracked.

**Acceptance Criteria**:
- [ ] Users can create tasks with title and description
- [ ] Users can assign tasks to team members
- [ ] Tasks appear in the task list immediately
- [ ] Users can mark tasks as complete
```

**Handoff**: PRD → Foundry Agent

---

### Stage 2: Foundry Agent 🏭

**Input**: PRD from Refinery

**Process**:
1. Analyze requirements and constraints
2. Design system architecture
3. Select technology stack
4. Define data models
5. Design API endpoints
6. Create component structure

**Output**: Technical Blueprint (excerpt)
```markdown
# Technical Blueprint: Task Manager

## Architecture
**Type**: Monolithic web application
**Pattern**: Client-server with REST API

## Technology Stack
- **Frontend**: React + TypeScript, Tailwind CSS
- **Backend**: Node.js + Express
- **Database**: PostgreSQL
- **Auth**: JWT tokens
- **Deployment**: Docker on AWS

## Data Models

### User
```typescript
interface User {
  id: UUID;
  email: string;
  passwordHash: string;
  name: string;
  teamId: UUID;
  role: 'admin' | 'member';
}
```

### Task
```typescript
interface Task {
  id: UUID;
  title: string;
  description: string;
  status: 'todo' | 'in_progress' | 'done';
  assigneeId: UUID;
  teamId: UUID;
  createdBy: UUID;
  createdAt: Date;
}
```

## API Endpoints

### POST /api/tasks
Create a new task.
**Auth**: Required
**Request**: { title, description, assigneeId }
**Response 201**: { id, title, ... }
```

**Handoff**: Blueprint → Planner Agent

---

### Stage 3: Planner Agent 📋

**Input**: Technical Blueprint from Foundry

**Process**:
1. Parse blueprint components
2. Break down into work orders
3. Map dependencies
4. Assign priorities
5. Create execution phases

**Output**: Work Orders (excerpt)
```markdown
# Work Orders: Task Manager

## Phase 1: Foundation (Week 1)

### WO-000: Project Setup
**Priority**: P0 | **Estimated**: 2 hours | **Dependencies**: None
**Description**: Initialize project structure, configure tools
**Acceptance Criteria**:
- [ ] Git repository initialized
- [ ] Frontend and backend projects created
- [ ] TypeScript and ESLint configured
- [ ] Docker setup complete

### WO-001: Database Setup
**Priority**: P0 | **Estimated**: 4 hours | **Dependencies**: WO-000
**Description**: Set up PostgreSQL and migration system
**Acceptance Criteria**:
- [ ] PostgreSQL running in Docker
- [ ] Database connection configured
- [ ] Migration system set up
- [ ] Initial schema created

### WO-002: Authentication System
**Priority**: P0 | **Estimated**: 6 hours | **Dependencies**: WO-001
**Description**: Implement user registration and login
**Acceptance Criteria**:
- [ ] POST /api/auth/register endpoint
- [ ] POST /api/auth/login endpoint
- [ ] JWT token generation
- [ ] Password hashing with bcrypt
- [ ] Unit tests >80% coverage

## Phase 2: Core Features (Week 2-3)

### WO-003: Task CRUD API
**Priority**: P1 | **Estimated**: 6 hours | **Dependencies**: WO-002
[Details...]

### WO-004: Task Assignment API
**Priority**: P1 | **Estimated**: 4 hours | **Dependencies**: WO-003
[Details...]

[20 work orders total across 4 phases...]
```

**Handoff**: Work Orders → Assembler Agent

---

### Stage 4: Assembler Agent ⚙️

**Input**: Work Orders from Planner

**Process** (for each work order):
1. Read work order and gather context
2. Plan implementation approach
3. Generate/write code
4. Write tests
5. Run tests and verify
6. Document code
7. Create implementation report

**Output**: Implemented Code + Report (for WO-002)
```markdown
# Implementation Report: WO-002

## Status
✅ Completed - 4.5 hours actual

## Files Created
- `src/api/auth.ts` - Auth endpoints
- `src/services/authService.ts` - Business logic
- `src/utils/jwt.ts` - JWT utilities
- `tests/unit/authService.test.ts` - Unit tests
- `tests/integration/authApi.test.ts` - Integration tests

## Acceptance Criteria
✅ POST /api/auth/register endpoint
✅ POST /api/auth/login endpoint
✅ JWT token generation
✅ Password hashing with bcrypt
✅ Unit tests 92% coverage (target >80%)

## Tests
- Unit tests: 15/15 passing
- Integration tests: 8/8 passing
```

**Code Example**:
```typescript
// src/api/auth.ts
router.post('/register', async (req, res) => {
  const { email, password, name } = req.body;
  
  try {
    const user = await authService.register({ email, password, name });
    const token = generateToken(user.id);
    res.status(201).json({ user, token });
  } catch (error) {
    if (error instanceof ValidationError) {
      res.status(400).json({ error: error.message });
    } else {
      res.status(500).json({ error: 'Registration failed' });
    }
  }
});
```

**Handoff**: Implementation → Validator Agent

---

### Stage 5: Validator Agent ✅

**Input**: Completed implementation from Assembler

**Process**:
1. Load PRD and verify requirements
2. Run all test suites
3. Perform manual testing
4. Collect user feedback
5. Identify issues and gaps
6. Generate validation report
7. Create feedback loop actions

**Output**: Validation Report (excerpt)
```markdown
# Validation Report: Task Manager

## Executive Summary
✅ Status: Mostly Passing (85%)

**Ready for Deployment**: ❌ Not yet
**Critical Issues**: 2
**Blockers**: Authorization bug, missing password reset

## Requirements Verification

### From PRD: Authentication (P0)
✅ Users can register - Verified
✅ Users can log in - Verified
❌ Password reset - NOT IMPLEMENTED
   Impact: High - Users can't recover accounts
   Action: Create WO-020

### From PRD: Task Management (P0)
✅ Users can create tasks - Verified
❌ Users can assign tasks - BROKEN (500 error)
   Impact: Critical - Core feature unusable
   Action: Create urgent WO-021

## Test Results
- Unit tests: 135/142 passing (95%)
- Integration tests: 28/35 passing (80%)
- E2E tests: 14/18 passing (78%)

## Critical Issues

**Issue #1: Authorization Vulnerability**
- Severity: Critical (Security)
- Users can access other teams' tasks
- Action: Create urgent WO-022

**Issue #2: Task Assignment Broken**
- Severity: Critical (Functionality)
- POST /api/tasks/:id/assign returns 500
- Action: Create urgent WO-023

## User Feedback (15 responses)
- Overall satisfaction: 4.1/5
- Common request: "Need notifications" (8 mentions)
- Common issue: "Assignment UI unclear" (6 mentions)

## Recommendations

### Immediate (This Week)
1. ❗ Fix authorization vulnerability (WO-022)
2. ❗ Fix task assignment bug (WO-023)
3. ⚠️ Implement password reset (WO-020)

### Feedback Loop Actions

→ Refinery Agent: Update PRD
- Add missing requirement: Email notifications
- Clarify UX for task assignment

→ Planner Agent: Create new work orders
- WO-020: Implement password reset (6h)
- WO-021: Fix task assignment (3h)
- WO-022: Fix authorization (2h)

→ Foundry Agent: Architecture feedback
- Add notification service to architecture
- Review authorization strategy
```

**Handoff**: Validation Report → Feedback Loop

---

### Feedback Loop 🔄

The Validator's findings create feedback to earlier stages:

**Back to Refinery** 🔥:
- Missing requirements discovered (notifications)
- Requirements needing clarification (assignment UX)

**Back to Planner** 📋:
- New work orders for bugs and missing features
- Priority adjustments based on user feedback

**Back to Foundry** 🏭:
- Architecture gaps identified (notification service)
- Technology choice reassessment if needed

**The cycle continues** until validation passes and software is ready for deployment.

## Workflow Phases

### Phase 1: Requirements (Days 1-2)
**Active Agent**: Refinery
**Input**: Raw ideas, stakeholder input
**Output**: Complete PRD
**Duration**: 1-2 days for medium project
**Iteration**: May need 2-3 PRD revisions based on stakeholder feedback

### Phase 2: Design (Days 3-4)
**Active Agent**: Foundry
**Input**: Approved PRD
**Output**: Technical blueprint
**Duration**: 1-2 days for medium project
**Iteration**: May need architecture review and revision

### Phase 3: Planning (Day 5)
**Active Agent**: Planner
**Input**: Technical blueprint
**Output**: Work orders
**Duration**: 0.5-1 day for medium project
**Iteration**: Adjust as implementation reveals new info

### Phase 4: Implementation (Weeks 2-4)
**Active Agent**: Assembler
**Input**: Work orders
**Output**: Working code
**Duration**: 3-4 weeks for medium project
**Iteration**: Continuous - implement → test → fix → next task

### Phase 5: Validation (Ongoing + End)
**Active Agent**: Validator
**Input**: Implementations
**Output**: Validation reports
**Duration**: Continuous during implementation + 2-3 days at end
**Iteration**: Multiple validation cycles

### Phase 6: Refinement (As Needed)
**Active Agents**: All agents via feedback loop
**Input**: Validation issues
**Output**: Fixes and improvements
**Duration**: Varies by issues found
**Iteration**: Repeat until quality gates pass

## Coordination Patterns

### Sequential Pattern (Linear)
```
Refinery → Foundry → Planner → Assembler → Validator
```
**Use when**: Starting fresh, clear requirements, single-track development

### Iterative Pattern (Sprints)
```
[Refinery + Foundry + Planner] for Feature Set 1
    → [Assembler + Validator] for Feature Set 1
    → Feedback → [Planner] updates for Feature Set 2
    → [Assembler + Validator] for Feature Set 2
    → Continue...
```
**Use when**: Agile development, learning as you go, user feedback is critical

### Parallel Pattern (Multi-track)
```
Track 1: Refinery → Foundry → Planner → Assembler (Backend)
Track 2: Refinery → Foundry → Planner → Assembler (Frontend)
Both → Validator (Integration testing)
```
**Use when**: Multiple independent work streams, larger team

### Continuous Pattern (DevOps)
```
All agents in continuous cycle:
- Refinery: Continuously refining backlog
- Foundry: Architecture evolves with new features
- Planner: Work orders generated continuously
- Assembler: Continuous implementation
- Validator: Continuous testing and validation
```
**Use when**: Mature product, continuous delivery, established process

## Success Metrics

Track these metrics to measure workflow effectiveness:

### Throughput
- **Time from idea to deployed feature**: Target < 2 weeks for small features
- **Work orders completed per week**: Measure implementation velocity
- **PRD approval time**: How quickly requirements are validated

### Quality
- **Requirements met on first implementation**: Target > 85%
- **Critical bugs found in validation**: Target < 2 per feature
- **Test coverage**: Target > 80%
- **User satisfaction**: Target > 4.0/5

### Efficiency
- **Rework rate**: Features requiring major rework: Target < 15%
- **Work order estimation accuracy**: Actual vs. estimated time: Target ±25%
- **Validator pass rate**: Implementation passing validation first time: Target > 70%

### Feedback Loop
- **Time to fix critical issues**: Target < 1 day
- **PRD update frequency**: How often validation uncovers missing requirements
- **Architecture revision frequency**: How often design gaps are found

## Common Workflow Challenges

### Challenge 1: Ambiguous Requirements
**Symptom**: Validator finds missing features, Assembler unsure what to build
**Solution**: 
- Refinery: Be more thorough with acceptance criteria
- Planner: Add clarification tasks before implementation
- Use "Definition of Ready" checklist before moving to next stage

### Challenge 2: Over-Engineering
**Symptom**: Implementation takes 3x longer than estimated
**Solution**:
- Foundry: Design for current requirements, not future ones
- Planner: Break large work orders into smaller pieces
- Assembler: Implement MVP first, enhance later

### Challenge 3: Validation Bottleneck
**Symptom**: Validator can't keep up with Assembler output
**Solution**:
- Validate continuously during implementation, not just at end
- Automate validation where possible
- Split validation into unit/integration/E2E with different cadences

### Challenge 4: Feedback Not Incorporated
**Symptom**: Same issues appear repeatedly
**Solution**:
- Refinery: Maintain "lessons learned" section in PRDs
- Planner: Create work orders to address systemic issues
- Review validation reports before starting new features

### Challenge 5: Lost Context Between Stages
**Symptom**: Later stages miss important details from earlier stages
**Solution**:
- Maintain document chain: PRD → Blueprint → Work Orders
- Cross-reference: "This work order implements PRD requirement F2.3"
- Use session state to track entire workflow

## Best Practices

### DO:
- **Maintain document chain**: Always reference what stage before
- **Validate assumptions early**: Don't wait until Validator to find gaps
- **Iterate quickly**: Small cycles better than big bang
- **Close feedback loops**: Issues found should become actions
- **Track metrics**: Measure to improve
- **Adapt the process**: Tailor workflow to project needs

### DON'T:
- **Skip stages**: Each agent adds value
- **Ignore feedback**: Validator findings must be addressed
- **Rush requirements**: Bad PRD = wasted implementation effort
- **Over-plan**: Start implementing before perfect plan
- **Forget documentation**: Future you needs to understand decisions
- **Treat as rigid**: Workflow should flex to project needs

## Tailoring the Workflow

### For Small Projects (< 1 week)
- **Compress stages**: Refinery + Foundry in 1 day
- **Fewer work orders**: 5-10 work orders max
- **Continuous validation**: Validate as you build
- **Minimal documentation**: Focus on essentials

### For Medium Projects (1-4 weeks)
- **Standard workflow**: Follow all 5 stages
- **10-20 work orders**: Reasonable granularity
- **Phase-based validation**: Validate after each phase
- **Standard documentation**: PRD, Blueprint, Work Orders

### For Large Projects (> 1 month)
- **Extended stages**: More time in Refinery and Foundry
- **Hierarchical work orders**: Epics → Work Orders → Tasks
- **Continuous validation**: Dedicated validation cycles
- **Comprehensive documentation**: Include architecture decision records

### For AI-Driven Development
- **Detailed work orders**: AI agents need clear specifications
- **Automated validation**: Leverage AI for testing
- **Iterative refinement**: AI generates, human reviews, repeat
- **Clear acceptance criteria**: AI needs testable criteria

### For Human Teams
- **Collaborative stages**: Team reviews at each handoff
- **Flexible work orders**: Developers can adapt as needed
- **Manual validation**: Human testing and feedback
- **Communication emphasis**: More documentation and sync

## Integration with Existing Workflows

### With Agile/Scrum
```
Sprint Planning:
- Refinery: Refine backlog items into PRDs
- Foundry + Planner: Create sprint work orders

Sprint Execution:
- Assembler: Implement work orders
- Validator: Continuous testing

Sprint Review:
- Validator: Demo and collect feedback

Sprint Retro:
- All agents: Process improvements
```

### With Kanban
```
Backlog → Refinery → Foundry → Planner → Ready for Dev
Ready for Dev → Assembler → In Progress
In Progress → Assembler → In Review
In Review → Validator → Done

Feedback loop back to Backlog
```

### With Waterfall
```
Requirements Phase: Refinery
Design Phase: Foundry
Planning Phase: Planner
Implementation Phase: Assembler
Testing Phase: Validator
```

## Summary

The Software Factory workflow is a systematic approach to software development that ensures:

✅ **Requirements are clear** (Refinery)
✅ **Design is sound** (Foundry)
✅ **Work is well-planned** (Planner)
✅ **Implementation is quality** (Assembler)
✅ **Product meets needs** (Validator)
✅ **Continuous improvement** (Feedback loops)

Use this workflow when you want predictable, high-quality software development with clear stages and continuous validation.

## Quick Reference

| Stage | Agent | Key Question | Primary Output |
|-------|-------|--------------|----------------|
| 1 | 🔥 Refinery | What should we build? | PRD |
| 2 | 🏭 Foundry | How should we build it? | Blueprint |
| 3 | 📋 Planner | What should we build next? | Work Orders |
| 4 | ⚙️ Assembler | Build it | Code |
| 5 | ✅ Validator | Does it work? Is it right? | Validation Report |
| Loop | All | How do we improve? | Feedback Actions |
