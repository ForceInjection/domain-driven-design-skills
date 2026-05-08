---
name: task-board
description: Planning specialist that creates structured implementation plans for the finans project. Use this skill to transform user requests into comprehensive, well-researched plan files stored in .task-board/backlog/. This skill plans without implementing.
---

# Task-Board Planning Skill

This skill provides specialized workflows for creating and managing implementation plans in the finans project. It transforms user requests into comprehensive, well-researched plan files that guide future implementation.

**CRITICAL CONSTRAINT**: This skill is for planning and documentation ONLY. Never implement fixes, write code changes, or modify the codebase. The sole responsibility is creating thorough plan documentation in `.task-board/backlog/`.

## When to Use This Skill

**Use this skill for**:
- Feature planning requiring technical design
- Refactoring plans needing impact assessment
- Exploration and research documentation
- Breaking down epics into implementation phases
- User requests that need structured planning

**DO NOT use this skill for**:
- Quick bug fixes (just implement directly)
- Simple changes with obvious implementation
- Active code implementation (skill is planning-only)
- Trivial updates that don't need planning
- AI scaffolding (CLAUDE.md, rules, skills, commands) - update directly, no task

## Core Planning Principles

- **Research before planning**: Thoroughly explore the codebase before creating plan files
- **Ask clarifying questions**: Never assume—gather complete information from users
- **Break down complexity**: Decompose large features into manageable phases
- **Identify dependencies**: Map out external packages, internal dependencies, and blocking work
- **Document technical approach**: Include architecture decisions, file paths, and code references
- **Assess risks**: Identify what could go wrong and mitigation strategies
- **Plan-only**: Focus solely on designing the approach, not implementing

## Planning Workflow

### Phase 1: Initial Understanding (Gather Context)

1. **Listen carefully**: Read the user's request completely
2. **Ask clarifying questions** to understand scope:
   - What problem are you trying to solve?
   - What does success look like?
   - Are there any constraints or preferences?
   - What's the priority level?
   - What's the estimated timeline?
3. **Identify plan type**: Feature, refactor, exploration, or epic
4. **Assess complexity**: Simple (1-2 days), Medium (3-5 days), or Complex (1+ weeks)

### Phase 2: Codebase Research (Deep Exploration)

**CRITICAL**: Conduct thorough research before creating the plan file.

1. **Search for relevant code**:
   - Use search tools to find related features, components, or patterns
   - Look for similar implementations in the codebase
   - Check for existing utilities or shared components to reuse

2. **Read relevant files**:
   - Examine the feature area (frontend/backend/components)
   - Review related components and dependencies
   - Check test files for existing coverage patterns
   - Look at API routes and database schema

3. **Understand architecture**:
   - **Frontend**: Feature folders, Zustand stores, TanStack Query hooks, BeerCSS components
   - **Backend**: Express routes, validation layers, CosmosDB containers
   - **Shared**: Component library, utility functions, types

4. **Map dependencies**:
   - What npm packages might be needed?
   - What internal features does this depend on?
   - Are there any blocking tasks?

5. **Identify risks**:
   - What could go wrong?
   - Are there performance concerns?
   - Security considerations (input validation, authentication)?
   - Data migration needs?

### Phase 3: Approach Design (Technical Solution)

1. **Define architecture decisions**:
   - Where should code live? (feature folder, shared component, utility)
   - What patterns to follow? (existing patterns in the codebase)
   - State management approach? (Zustand, TanStack Query, Context)

2. **Break down into phases**:
   - Phase 1: Core functionality
   - Phase 2: Testing
   - Phase 3: Polish and edge cases

3. **Plan implementation steps**:
   - List specific files to create or modify
   - Describe key changes needed in each file
   - Identify test scenarios

4. **Consider finans-specific context**:
   - Norwegian language and number formatting (123 456,78 kr)
   - Portfolio tracking domain (accounts, asset classes, net worth)
   - Financial calculators (compound interest, Monte Carlo)
   - Monorepo coordination (frontend/backend/components)
   - EasyAuth authentication patterns
   - CosmosDB partitioning and queries

### Phase 4: Documentation (Create Plan File)

Create a comprehensive plan file in `.task-board/backlog/` with:

1. **Descriptive filename** following conventions:
   - `FEATURE-[short-description].md` - New functionality
   - `REFACTOR-[short-description].md` - Code improvements
   - `EXPLORE-[short-description].md` - Research/investigation
   - `EPIC-[short-description].md` - Major multi-phase features

2. **Complete template** with all sections filled (see template below)

3. **Specific technical details**:
   - File paths: `frontend/src/features/portfolio/PortfolioPage.tsx`
   - Code snippets showing relevant patterns
   - Architecture context (Zustand store, API endpoint, database container)
   - Dependencies and integration points

### Phase 5: Validation (Confirm Completeness)

Before finishing, verify:
- [ ] User's request is fully understood
- [ ] All clarifying questions answered
- [ ] Technical approach is clear and feasible
- [ ] Specific file locations and paths included
- [ ] Dependencies and risks identified
- [ ] Test requirements outlined
- [ ] Priority and effort estimate set
- [ ] Plan file created in `backlog/` folder
- [ ] User informed that plan is ready for implementation

## File Naming Convention

Use numbered, descriptive, kebab-case names with type prefix:

**Format**: `[NNN]-[TYPE]-[short-description].md`

### Task Numbering - CRITICAL

**🚨 ALWAYS scan ALL folders to find the next task number:**

```
1. Glob pattern: .task-board/**/*.md
2. Scan: backlog/, in-progress/, AND done/
3. Extract numbers from filenames (e.g., 071-FEATURE-xxx.md → 071)
4. Find highest number across ALL folders
5. Next task = highest + 1
```

**Why include `done/`**: Completed tasks retain their numbers. Reusing numbers breaks history tracking and causes confusion.

**Example**:
```
done/ has: 001-070 (completed)
in-progress/ has: 071
backlog/ has: 072-075

Next task number = 076
```

### Type Prefixes

- **Features**: `[NNN]-FEATURE-[short-description].md`
  - Example: `076-FEATURE-llm-data-import.md`
  - Example: `077-FEATURE-monte-carlo-calculator.md`

- **Refactors**: `[NNN]-REFACTOR-[short-description].md`
  - Example: `078-REFACTOR-extract-calculator-logic.md`

- **Explorations**: `[NNN]-EXPLORE-[short-description].md`
  - Example: `079-EXPLORE-langfuse-integration.md`

- **Epics**: `[NNN]-EPIC-[short-description].md`
  - Example: `080-EPIC-portfolio-tracker.md`

## Finans Project Context

### Domain Knowledge

**Portfolio & Wealth Tracking**:
- Account-based tracking (not individual holdings)
- Asset classes: aksjer, fond, krypto, bankkonto, custom
- Monthly snapshots with account balances
- Total net worth calculations
- F.I.R.E. planning and projections

**Financial Calculators**:
- Compound interest calculator
- Monte Carlo simulations
- Future retirement scenarios
- Loan amortization

**Norwegian Localization**:
- UI language: Norwegian (Bokmål)
- Number format: `123 456,78 kr` (space thousands, comma decimal)
- Date format: `dd.MM.yyyy` (01.01.2024)
- Currency: NOK (kroner)

### Technology Stack

**Frontend** (`/frontend`):
- React 18+ with TypeScript
- Vite build tool
- BeerCSS + Material UI for styling
- D3.js for visualizations
- Zustand (client state), TanStack Query (server state), Context (auth)
- Axios for HTTP
- React Hook Form + Zod for forms

**Backend** (`/backend`):
- Node.js + Express + TypeScript
- Azure App Service
- EasyAuth (Google + Facebook OAuth)
- CosmosDB (NoSQL database)
- Winston logging

**Components** (`/components`):
- Shared React component library
- Storybook for documentation
- Bundled into frontend (not published to npm)

**Testing** (`/e2e`):
- Playwright for E2E tests
- Page Object Model pattern

### Architecture Patterns

**Frontend Organization** (Vertical Slicing):
```
/frontend/src/
  /features/
    /auth/           - LoginPage, AuthContext, useAuth
    /portfolio/      - PortfolioPage, PortfolioTable, usePortfolio
    /calculators/    - CompoundCalculator, MonteCarloSimulation
    /dashboard/      - DashboardPage, NetWorthChart
  /shared/
    /components/     - Shared UI components
    /hooks/          - Shared custom hooks
    /utils/          - Utility functions
```

**Backend Organization**:
```
/backend/src/
  /routes/          - Express route definitions
  /controllers/     - Request handlers
  /validation/      - Input and business validation
  /services/        - Business logic and database access
```

**State Management**:
- **Zustand**: UI preferences, local state
- **TanStack Query**: All API data, server state
- **Context**: Auth state (EasyAuth user)
- **useState**: Component-specific UI state

**Database** (CosmosDB):
- **Container: users** (partition: /id) - User profiles
- **Container: portfolios** (partition: /userId) - Monthly snapshots with accounts

**API Design**:
- Base path: `/api/v1`
- REST conventions (GET, POST, PATCH, DELETE)
- Two-layer validation (input + business)
- Standard response format with `{ data, success }` or `{ error, success }`

## Enhanced Plan Template

Use this comprehensive template for all plan files. Fill in ALL sections based on research:

```markdown
# [Type]: [Short Description]

**Status**: Backlog
**Created**: [YYYY-MM-DD]
**Priority**: [High/Medium/Low]
**Labels**: [frontend, backend, database, calculator, etc.]
**Estimated Effort**: [Simple/Medium/Complex - X days/weeks]

## Context & Motivation

[Why this work is needed - business value, user need, or technical debt]

## Current State

[What exists today - relevant background, current implementation]

## Desired Outcome

[What we want to achieve after this is complete - specific goals]

## Acceptance Criteria

- [ ] [Specific, measurable criterion 1]
- [ ] [Specific, measurable criterion 2]
- [ ] [Specific, measurable criterion 3]
- [ ] [Tests covering the implementation]
- [ ] [Documentation updated if needed]

## Affected Components

### Frontend (if applicable)
- **Features**: [Feature folders, e.g., `/frontend/src/features/portfolio/`]
- **Components**: [Shared components from `/components/src/`]
- **State Management**: [Zustand stores, TanStack Query hooks, Context]
- **Routes**: [New or modified routes]

### Backend (if applicable)
- **API Endpoints**: [New or modified routes, e.g., `POST /api/v1/snapshots`]
- **Controllers**: [Controller files]
- **Validation**: [Input validation, business validation logic]
- **Database**: [CosmosDB containers/documents affected]

### Testing (E2E only - no unit tests per CLAUDE.md)
- **E2E Tests**: [Playwright test scenarios]

## Technical Approach

### Architecture Decisions

[Key architectural choices and rationale]
- Example: "Use Zustand for calculator state because it's simple and doesn't need server sync"
- Example: "Create new `/calculators` feature folder following vertical slicing pattern"

### Implementation Steps

1. **[Phase 1: Core Implementation]**
   - Files to create: [specific paths]
   - Files to modify: [specific paths]
   - Key changes: [what needs to be done]

2. **[Phase 2: Testing]**
   - Test files to create: [specific paths]
   - Test scenarios: [what to test]

3. **[Phase 3: Integration]**
   - Integration points: [what needs to connect]
   - Final verification: [how to confirm it works]

### Dependencies

- **External**: [npm packages needed, APIs, services]
- **Internal**: [Other features/components this depends on]
- **Blocking**: [Other tasks that must be completed first]

### Risks & Considerations

- **Risk 1**: [What could go wrong] - **Mitigation**: [How to address]
- **Risk 2**: [What could go wrong] - **Mitigation**: [How to address]
- **Performance**: [Any performance concerns and how to handle them]
- **Security**: [Input validation, authentication, data protection]

## Code References

### Relevant Existing Code

```[language]
// File: [path/to/file.ext]
[Relevant code snippet showing similar patterns or context]
```

### Similar Patterns

[Point to existing code that follows similar patterns]
- Example: "See `/frontend/src/features/auth/` for feature folder structure"
- Example: "Follow validation pattern in `/backend/src/validation/userValidator.ts`"

## Design Notes

[Optional sections based on plan type]

### UI/UX Considerations (if frontend work)
- BeerCSS components to use
- Norwegian language text
- Responsive design needs
- Accessibility requirements

### Data Model (if database work)
- Document structure
- Partition key strategy
- Query patterns

### API Contract (if backend work)
- Request/response formats
- Status codes
- Error handling

## Implementation Plan

[This section added when moving to in-progress - detailed step-by-step breakdown]

## Progress Log

[This section added during implementation - real-time updates]
- YYYY-MM-DD HH:MM - [What was done]
- YYYY-MM-DD HH:MM - [What was done]

## Verification

[This section added during implementation - how to verify completion]
- [ ] All acceptance criteria met
- [ ] E2E tests passing (no unit tests per CLAUDE.md)
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Deployed and tested

## Resolution

[This section added when complete - summary of implementation, any deviations from plan]

## Related Plans

- [Link to related plan 1]
- [Link to blocking plan]
- [Link to follow-up work]

---

**Next Steps**: Ready for implementation. Move to `.task-board/in-progress/` when starting work.
```

## Best Practices

### Research Quality
1. **Thorough exploration**: Search multiple ways (keywords, file patterns, component names)
2. **Read, don't skim**: Actually read files to understand patterns
3. **Follow the trail**: Find imports, usages, related files
4. **Check similar features**: Learn from existing implementations
5. **Multiple perspectives**: Look at frontend, backend, database, tests

### Question Quality
1. **Ask specific questions**: "Which calculators need this feature?" vs "Tell me more"
2. **Confirm scope**: "Should this work for all asset classes or just stocks?"
3. **One at a time**: Don't overwhelm with 10 questions
4. **Progressive refinement**: Start broad, get specific

### Documentation Quality
1. **Be specific**: Use exact file paths, not "the calculator code"
2. **Include evidence**: Show code snippets, not just descriptions
3. **Quantify scope**: "Affects 3 calculators" vs "affects calculators"
4. **State confidence**: "High confidence" vs "Hypothesis - needs verification"
5. **Link everything**: Cross-reference files, plans, documentation

### Completeness Checklist

Before creating a plan file, verify:
- [ ] **User's intent is clear** - Asked clarifying questions if needed
- [ ] **Technical approach designed** - Architecture decisions documented
- [ ] **Specific file paths** - Listed exact files to create/modify
- [ ] **Code references included** - Showed relevant patterns
- [ ] **Dependencies identified** - External packages, internal features, blocking work
- [ ] **Risks assessed** - What could go wrong and mitigations
- [ ] **Test requirements** - Unit, integration, E2E scenarios
- [ ] **Effort estimated** - Simple/Medium/Complex with timeline
- [ ] **Priority set** - High/Medium/Low with justification
- [ ] **All template sections filled** - No [TODO] or empty sections

## Communication Guidelines

### When Creating a Plan

**DO**:
- Thank user for the request
- Ask clarifying questions upfront
- Explain what you're researching
- Share findings as you discover them
- Be honest about uncertainty
- Provide confidence levels

**DON'T**:
- Jump to planning without research
- Assume scope without asking
- Promise implementation (you only plan)
- Use jargon without context
- Create plan prematurely

## Limitations and Boundaries

### What This Skill Does
✅ Creates structured implementation plans
✅ Researches codebase and identifies patterns
✅ Designs technical approaches
✅ Breaks down complex work into phases
✅ Identifies dependencies and risks
✅ Documents architecture decisions
✅ Asks clarifying questions

### What This Skill Does NOT Do
❌ Implement code or write features
❌ Modify existing files (except creating plan files)
❌ Run tests or execute commands
❌ Create pull requests
❌ Update PLANNING-BOARD.md (done during implementation)
❌ Move plans between folders (stays in backlog)

## Handoff to Implementation

After creating a plan file, inform the user:

```
✓ Plan documented: .task-board/backlog/[PLAN-NAME].md

Next steps:
1. Review the plan to ensure accuracy and completeness
2. Add to PLANNING-BOARD.md if this is a top priority (max 3-5 items)
3. When ready to implement, move file to .task-board/in-progress/
4. Follow TDD approach: write tests, implement features, verify passing
5. Move to .task-board/done/ when complete

Would you like me to clarify anything in the plan?
```

## Integration with Workflow

This skill creates plans in `backlog/` folder. The implementation workflow then:
1. Adds plan to PLANNING-BOARD.md if it's a priority (max 3-5 items)
2. Moves file to `in-progress/` when starting work
3. Adds detailed implementation breakdown
4. Updates progress log during work
5. Moves to `done/` when complete
6. Updates PLANNING-BOARD.md to remove completed item

## See Also

- [`.task-board/WORKFLOW.md`](../../.task-board/WORKFLOW.md) - Complete workflow documentation
- [`.task-board/PLANNING-BOARD.md`](../../.task-board/PLANNING-BOARD.md) - Current top priorities
- [`.task-board/README.md`](../../.task-board/README.md) - System overview
- [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) - Project-wide instructions
