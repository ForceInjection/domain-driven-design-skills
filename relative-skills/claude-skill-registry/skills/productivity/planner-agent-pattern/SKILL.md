---
name: Planner Agent Pattern
description: Convert technical blueprints into actionable work orders and implementation tasks
model: opus-4.5
---

# Planner Agent Pattern

## File Paths & Versioning

**Input:**
- `project-docs/blueprint/blueprint-latest.md` — Latest blueprint from Foundry

**Output:**
- `project-docs/work-orders/work-orders-v{N}.md` — Versioned work orders
- `project-docs/work-orders/work-orders-latest.md` — Copy of the latest version

**Workflow:**
1. Read `project-docs/blueprint/blueprint-latest.md`
2. Detect next version number (check existing `work-orders-v*.md` files)
3. Generate `work-orders-v{N}.md`
4. Update `work-orders-latest.md` to match

**Version Header:** Each work orders file includes:
```markdown
---
version: 1
date: 2025-12-18
blueprint_version: 1
changes_from_previous: null | "Summary of changes"
---
```

## Purpose

The Planner Agent is the third stage in the software factory workflow. It takes technical blueprints and breaks them down into concrete, actionable work orders that can be executed by developers or coding agents. It's the bridge between "how to build it" and "what to build next."

## When to Use This Pattern

Use the Planner Agent pattern when:
- You have a technical blueprint that needs to be broken into tasks
- You need to create a sprint or iteration plan
- You want to parallelize development work across team members
- You need to sequence tasks based on dependencies

## Core Responsibilities

### 1. Blueprint Analysis
**Parse the technical blueprint:**
- Identify all components and features
- Extract implementation requirements
- Understand architecture dependencies
- Note technical specifications

### 2. Task Decomposition
**Break down the blueprint into work orders:**
- Create granular, actionable tasks
- Define clear success criteria
- Estimate complexity and effort
- Identify task dependencies

### 3. Dependency Mapping
**Establish task relationships:**
- Determine which tasks must complete before others
- Identify parallel work streams
- Plan critical path
- Flag blocking dependencies

### 4. Prioritization
**Order tasks for optimal flow:**
- Foundation first (infrastructure, data models)
- Core features before enhancements
- High-value items prioritized
- Risk reduction through early validation

### 5. Work Order Generation
**Create detailed, executable work packages:**
- Clear description of what to build
- Acceptance criteria
- Technical specifications
- File paths and code structure
- Testing requirements

## Implementation Approach

### Step 1: Parse the Blueprint

```
Blueprint → Component Analysis → Implementation Units
```

**Extract from blueprint:**
- Data models and schemas
- API endpoints
- UI components
- Infrastructure components
- Configuration and setup tasks

**Questions to answer:**
- What are the foundational pieces (database, auth)?
- What can be built in parallel?
- What are the critical path items?
- Where are the integration points?

### Step 2: Create Work Order Hierarchy

```
Implementation Units → Task Breakdown → Work Order Tree
```

**Levels of granularity:**

**Level 1: Epics** (large features)
```
Epic: User Authentication System
- Multi-day effort
- Multiple related work orders
```

**Level 2: Work Orders** (implementable units)
```
Work Order: Implement JWT authentication
- 2-4 hours of focused work
- Single developer can complete
- Has clear acceptance criteria
```

**Level 3: Subtasks** (implementation details)
```
Subtask: Create JWT utility functions
- < 1 hour
- Part of larger work order
```

**Aim for work orders at Level 2** - not too big, not too granular.

### Step 3: Define Work Order Structure

```
Task Description → Detailed Specification → Complete Work Order
```

**Each work order includes:**

```json
{
  "id": "WO-001",
  "title": "Implement User Authentication API",
  "description": "Create the backend API endpoints for user registration, login, and logout",
  "priority": "P0",
  "complexity": "medium",
  "estimated_hours": 4,
  "dependencies": ["WO-000"],
  "acceptance_criteria": [
    "POST /api/auth/register endpoint creates new user",
    "POST /api/auth/login returns JWT token",
    "POST /api/auth/logout invalidates token",
    "All endpoints have input validation",
    "Unit tests cover all endpoints with >80% coverage"
  ],
  "technical_details": {
    "files_to_create": [
      "src/api/auth.ts",
      "src/services/authService.ts",
      "src/utils/jwt.ts"
    ],
    "files_to_modify": [
      "src/api/index.ts"
    ],
    "technologies": ["Express", "jsonwebtoken", "bcrypt"],
    "external_dependencies": ["jsonwebtoken@^9.0.0", "bcrypt@^5.1.0"]
  },
  "testing_requirements": [
    "Unit tests for auth endpoints",
    "Integration test for registration flow",
    "Test invalid credentials handling",
    "Test token expiration"
  ],
  "documentation_requirements": [
    "API endpoint documentation",
    "JWT token structure documentation"
  ]
}
```

### Step 4: Map Dependencies

```
Work Orders → Dependency Analysis → Dependency Graph
```

**Dependency types:**

**Hard dependencies** (blocking):
```
WO-002 "Create User API" depends on WO-001 "Setup Database"
→ Cannot start WO-002 until WO-001 is complete
```

**Soft dependencies** (helpful):
```
WO-005 "Dashboard UI" benefits from WO-003 "User API" being done
→ Can mock WO-003 to start WO-005 early
```

**No dependencies** (parallel):
```
WO-010 "Email Service" has no dependencies
→ Can start immediately, work in parallel
```

**Visualize dependencies:**
```
WO-000: Project Setup
├── WO-001: Database Setup
│   ├── WO-002: User Model
│   │   ├── WO-003: User API
│   │   └── WO-004: Auth Service
│   └── WO-005: Task Model
│       └── WO-006: Task API
└── WO-007: Frontend Setup
    ├── WO-008: Auth UI
    └── WO-009: Dashboard UI
```

### Step 5: Prioritize Work Orders

```
Dependency Graph → Priority Assignment → Execution Plan
```

**Priority levels:**

**P0 (Critical)** - Blocks everything else:
- Project setup and configuration
- Database schema and migrations
- Authentication system
- Core data models

**P1 (High)** - Core functionality:
- Primary user flows
- Essential API endpoints
- Main UI components

**P2 (Medium)** - Important but not blocking:
- Secondary features
- UI polish
- Performance optimizations

**P3 (Low)** - Nice to have:
- Advanced features
- Edge case handling
- Extra documentation

**Prioritization strategy:**

1. **Foundation First**: Infrastructure, database, auth
2. **Happy Path**: Core user flows working end-to-end
3. **Breadth Before Depth**: All features at basic level before polishing
4. **Risk Reduction**: Tackle unknowns and technical risks early
5. **Value Delivery**: High-impact features first

### Step 6: Create Execution Phases

```
Prioritized Work Orders → Phase Planning → Sprint Plan
```

**Phase structure:**

**Phase 1: Foundation** (Week 1)
- WO-000: Project setup
- WO-001: Database setup
- WO-002: Authentication system
- WO-003: Basic API structure

**Phase 2: Core Features** (Week 2-3)
- WO-004: User management
- WO-005: Task CRUD operations
- WO-006: Team functionality
- WO-007: Basic UI components

**Phase 3: Integration** (Week 4)
- WO-008: Connect frontend to backend
- WO-009: Real-time updates
- WO-010: Notifications
- WO-011: Testing and bug fixes

**Phase 4: Polish** (Week 5)
- WO-012: UI/UX improvements
- WO-013: Performance optimization
- WO-014: Documentation
- WO-015: Deployment preparation

## Output Format

### Work Orders Document Structure

```markdown
# Work Orders: [Project Name]

## Overview
- **Blueprint Reference**: [Link or ID]
- **Total Work Orders**: [Count]
- **Estimated Duration**: [Weeks]
- **Phases**: [Number of phases]

## Dependency Graph
[Visual representation of task dependencies]

## Phase 1: Foundation

### WO-000: Project Setup and Configuration
**Priority**: P0
**Complexity**: Low
**Estimated Hours**: 2
**Dependencies**: None

**Description**:
Set up the development environment, initialize the project structure, and configure essential tools.

**Acceptance Criteria**:
- [ ] Git repository initialized
- [ ] Project structure created (frontend + backend)
- [ ] Package.json with core dependencies
- [ ] TypeScript and ESLint configured
- [ ] Docker setup for development
- [ ] README with setup instructions

**Technical Details**:
- **Files to Create**:
  - `package.json`
  - `tsconfig.json`
  - `.eslintrc.js`
  - `docker-compose.yml`
  - `README.md`
- **Technologies**: Node.js, TypeScript, Docker
- **Commands**:
  ```bash
  npm init -y
  npm install typescript @types/node --save-dev
  npx tsc --init
  ```

**Testing Requirements**:
- [ ] Project builds successfully
- [ ] Docker containers start without errors

**Documentation**:
- [ ] README with setup instructions
- [ ] Development guide

---

### WO-001: Database Setup and Migrations
**Priority**: P0
**Complexity**: Medium
**Estimated Hours**: 4
**Dependencies**: WO-000

**Description**:
Set up PostgreSQL database, configure connection, and set up migration system.

**Acceptance Criteria**:
- [ ] PostgreSQL running in Docker
- [ ] Database connection configured
- [ ] Migration system set up (e.g., Knex, TypeORM)
- [ ] Initial migration creates database schema
- [ ] Seed data script for development

**Technical Details**:
- **Files to Create**:
  - `src/db/connection.ts`
  - `src/db/migrations/001_initial_schema.ts`
  - `src/db/seeds/dev_data.ts`
- **Technologies**: PostgreSQL, TypeORM
- **External Dependencies**: `pg`, `typeorm`

**Testing Requirements**:
- [ ] Database connection test
- [ ] Migration up/down test
- [ ] Seed data loads successfully

---

[Continue for all work orders...]

## Phase 2: Core Features
[Work orders for Phase 2]

## Phase 3: Integration
[Work orders for Phase 3]

## Phase 4: Polish
[Work orders for Phase 4]

## Execution Timeline

| Week | Phase | Work Orders | Focus |
|------|-------|-------------|-------|
| 1 | Foundation | WO-000 to WO-003 | Infrastructure setup |
| 2 | Core | WO-004 to WO-007 | Backend APIs |
| 3 | Core | WO-008 to WO-011 | Frontend UI |
| 4 | Integration | WO-012 to WO-015 | Connect systems |
| 5 | Polish | WO-016 to WO-019 | Refinement |

## Parallel Work Streams

**Stream 1: Backend** (Developer A)
- WO-001, WO-002, WO-004, WO-005

**Stream 2: Frontend** (Developer B)
- WO-007, WO-008, WO-009, WO-011

**Stream 3: Infrastructure** (Developer C)
- WO-000, WO-003, WO-015, WO-019

## Risk Assessment

| Work Order | Risk Level | Risk Description | Mitigation |
|------------|------------|------------------|------------|
| WO-009 | High | WebSocket implementation complexity | Proof-of-concept first, fallback to polling |
| WO-013 | Medium | Performance optimization unknowns | Profile early, set measurable targets |

## Definition of Done

A work order is considered complete when:
- [ ] All acceptance criteria are met
- [ ] Code is reviewed and approved
- [ ] Tests are written and passing
- [ ] Documentation is updated
- [ ] No critical bugs remain
- [ ] Deployed to staging environment
```

### JSON Format for Programmatic Use

```json
{
  "project": "Collaborative Task Manager",
  "blueprint_id": "bp-12345",
  "created_at": "2025-12-17T09:00:00Z",
  "total_work_orders": 20,
  "phases": [
    {
      "phase": 1,
      "name": "Foundation",
      "duration_weeks": 1,
      "work_orders": ["WO-000", "WO-001", "WO-002", "WO-003"]
    }
  ],
  "work_orders": [
    {
      "id": "WO-000",
      "title": "Project Setup and Configuration",
      "description": "...",
      "priority": "P0",
      "complexity": "low",
      "estimated_hours": 2,
      "dependencies": [],
      "phase": 1,
      "acceptance_criteria": [...],
      "technical_details": {...},
      "testing_requirements": [...],
      "tags": ["setup", "infrastructure"]
    }
  ],
  "dependency_graph": {
    "WO-000": [],
    "WO-001": ["WO-000"],
    "WO-002": ["WO-001"]
  }
}
```

## Best Practices

### DO:
- **Make work orders atomic**: Each should be completable independently
- **Write clear acceptance criteria**: Testable, unambiguous conditions
- **Estimate conservatively**: Pad estimates for unknowns
- **Plan for testing**: Every work order includes testing requirements
- **Consider parallelization**: Identify independent work streams
- **Include file paths**: Be specific about where code goes

### DON'T:
- **Create massive work orders**: Nothing > 8 hours of work
- **Create tiny work orders**: Avoid micro-management (< 1 hour tasks should be subtasks)
- **Ignore dependencies**: Missing dependencies causes blocking
- **Skip technical details**: Vague work orders lead to confusion
- **Forget documentation**: Every work order should update docs

## Integration with Other Agents

### Input ← Foundry Agent
Receives the technical blueprint containing:
- System architecture
- Technology stack
- Data models
- API specifications
- Component structure

### Output → Assembler Agent
Provides work orders for execution:
- Detailed task descriptions
- Technical specifications
- File structure
- Acceptance criteria
- Testing requirements

### Feedback Loop ← Validator Agent
May receive feedback on:
- Tasks that were under-specified
- Missing dependencies discovered during implementation
- Estimation accuracy (to improve future planning)

## Example Usage

### Input Blueprint (Summary)
```
Architecture: Monolithic web app
Frontend: React + TypeScript
Backend: Node.js + Express
Database: PostgreSQL
Features: Auth, Tasks, Teams, Notifications
```

### Planner Analysis
1. **Identify components**: Database, Auth, API, Frontend, Real-time
2. **Map dependencies**: Database → Models → API → Frontend
3. **Break into work orders**: 20 work orders across 4 phases
4. **Assign priorities**: P0 for foundation, P1 for core features
5. **Create execution plan**: 5-week timeline

### Output Work Orders
```
Phase 1 (Foundation):
- WO-000: Project setup (2h)
- WO-001: Database setup (4h)
- WO-002: Auth system (6h)

Phase 2 (Core Features):
- WO-003: User API (4h)
- WO-004: Task API (6h)
- WO-005: Team API (4h)

[20 work orders total]
```

## Tips for Effective Planning

1. **Start with the critical path**: Identify and plan blocking tasks first
2. **Validate with the team**: Check if estimates and scope are realistic
3. **Build buffer time**: Things take longer than expected
4. **Plan for integration time**: Connecting pieces takes time
5. **Keep work orders fresh**: Update as implementation reveals new info

## Common Pitfalls

- **Over-planning**: Creating 100 micro-tasks is overwhelming
- **Under-planning**: "Build the frontend" is too vague
- **Ignoring risk**: Not identifying technically risky tasks
- **Forgetting infrastructure**: Auth, logging, monitoring need work orders too
- **Sequential thinking**: Missing opportunities for parallel work
- **Estimation optimism**: Always pad estimates for unknowns

## Advanced Techniques

### Agile Integration
Convert work orders to user stories:
```
Work Order: Implement task creation API
→ User Story: As a team member, I want to create tasks via API
```

### Iterative Planning
- **Sprint 0**: Foundation + first vertical slice
- **Sprint 1+**: Iterate based on learnings, reprioritize remaining work

### Risk-Driven Planning
Tackle high-risk items early:
- Novel technology integration
- Performance-critical components
- Complex business logic

## Summary

The Planner Agent transforms architecture into action. It creates a roadmap that guides development from empty repository to working software, ensuring nothing is forgotten and everything is built in the right order.

**Remember**: A good work order is:
- **Actionable**: Clear what needs to be done
- **Testable**: Acceptance criteria can be verified
- **Sized right**: 2-6 hours of focused work
- **Well-specified**: Includes technical details and file paths
- **Properly sequenced**: Dependencies are clear
