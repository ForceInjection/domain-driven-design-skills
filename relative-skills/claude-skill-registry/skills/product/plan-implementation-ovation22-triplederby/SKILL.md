---
name: plan-implementation
description: Break down feature specifications into manageable implementation phases with TDD vertical slices. Creates actionable task lists for immediate development. Use when you have a feature spec and need a concrete implementation roadmap.
---

# Implementation Planning

## Overview
This skill takes a feature specification document and breaks it down into concrete, manageable implementation phases. Each phase is sized appropriately for implementation (typically completable in a focused work session) and follows a Test-Driven Development approach with vertical slices.

## When to Use
- After completing feature discovery (feature spec exists in `/docs/features/`)
- Before starting implementation of a complex feature
- When a feature needs to be broken into phases for incremental delivery
- When you want to create an actionable task list from a specification
- When planning sprints or work iterations

## Core Principles

### 1. TDD Vertical Slices
Each phase should:
- **Start with tests** (Red-Green-Refactor)
- **Deliver end-to-end functionality** (data → logic → UI)
- **Be independently testable** (can validate it works)
- **Build incrementally** (each phase adds value to previous)

### 2. Appropriate Sizing
Tasks should be:
- **Small enough**: Completable in 30-90 minutes of focused work
- **Large enough**: Deliver meaningful, testable functionality
- **Concrete**: Clear acceptance criteria and deliverables
- **Independent**: Minimal dependencies on other in-progress work

### 3. Risk-Aware Sequencing
Phases should be ordered to:
- **Validate assumptions early**: High-risk items in early phases
- **Build foundation first**: Core domain models before complex logic
- **Enable testing**: Test infrastructure before feature code
- **Deliver value incrementally**: Each phase produces working software

## Instructions

### Phase 1: Analyze Feature Specification
1. **Read the feature spec** from `/docs/features/[feature-name].md`
2. **Extract requirements**: Identify all functional requirements and acceptance criteria
3. **Identify complexity areas**: Note which parts are complex, risky, or have unknowns
4. **Map dependencies**: Understand what exists, what's new, what needs changing
5. **Review codebase**: Read relevant existing code to understand integration points

### Phase 2: Design Phase Breakdown
1. **Identify vertical slices**: What end-to-end capabilities can be delivered incrementally?
2. **Sequence for value**: What order delivers testable functionality earliest?
3. **Group related work**: Cluster tasks that naturally belong together
4. **Size appropriately**: Break large slices into multiple phases if needed
5. **Define deliverables**: What does "done" look like for each phase?

### Phase 3: Create Implementation Tasks
For each phase, define:
1. **Phase Goal**: One sentence describing what this phase accomplishes
2. **Test-First Tasks**: What tests to write first (RED phase)
3. **Implementation Tasks**: What code to write to make tests pass (GREEN phase)
4. **Refactoring Tasks**: What cleanup/improvements to make (REFACTOR phase)
5. **Acceptance Criteria**: How to verify this phase is complete

### Phase 4: Generate Task List
1. **Create TodoWrite list**: Populate with first phase tasks
2. **Document remaining phases**: Write markdown doc with all phases
3. **Add phase markers**: Clear separators between phases
4. **Include estimates**: Flag complex/risky tasks
5. **Link to spec**: Reference feature spec for context

## Phase Template

Each phase should follow this structure:

```markdown
### Phase N: [Descriptive Name]
**Goal**: [One sentence describing what this phase delivers]

**Vertical Slice**: [What end-to-end capability does this deliver?]

**TDD Cycle**:

#### RED - Write Failing Tests
- [ ] Test: [Specific test case 1]
- [ ] Test: [Specific test case 2]
- [ ] Test: [Specific test case 3]

**Why these tests**: [Brief explanation of what behavior we're defining]

#### GREEN - Make Tests Pass
- [ ] Create/modify: [File or class name]
- [ ] Implement: [Specific method or functionality]
- [ ] Wire up: [Integration points]

**Implementation notes**: [Key decisions, patterns to follow, gotchas]

#### REFACTOR - Clean Up
- [ ] Extract: [What to pull out into separate methods/classes]
- [ ] Rename: [What to make clearer]
- [ ] Remove: [What duplication to eliminate]

**Acceptance Criteria**:
- [ ] All tests in this phase pass
- [ ] Code coverage for new code > 80%
- [ ] [Specific observable behavior works]
- [ ] No regressions in existing tests

**Deliverable**: [What working functionality can be demonstrated]

**Estimated Complexity**: [Simple / Medium / Complex]
**Risks**: [Any concerns or unknowns]
```

## Task Sizing Guidelines

### Too Small (Avoid)
- Single line changes
- Trivial refactorings
- Adding one test case
❌ **Why**: Overhead of tracking exceeds value

### Just Right (Target)
- Implement one domain concept with tests
- Add one feature capability end-to-end
- Refactor one subsystem with test coverage
✅ **Why**: Meaningful progress, clear validation, manageable scope

### Too Large (Break Down)
- "Implement entire feature"
- "Refactor whole service layer"
- "Add all API endpoints"
❌ **Why**: Too vague, hard to test, risky, unclear when done

## Vertical Slice Examples

### Good Vertical Slice
**Phase**: Add horse training for Speed stat
- **Tests**: Training increases Speed, respects caps, validates input
- **Implementation**: Training entity, TrainingService.AddTraining(), Horse.CalculateEffectiveStats()
- **Refactor**: Extract validation, use value objects
- **Demo**: Can train a horse's Speed and see it improve in the database

### Poor Vertical Slice (Too Horizontal)
**Phase**: Create all training entities
- **Tests**: Training entity exists, Stamina entity exists, Agility entity exists
- **Implementation**: Training class, Stamina class, Agility class
- **Refactor**: Share base class
- ❌ **Problem**: Doesn't deliver working feature, can't validate in real scenario

## Output Format

This skill produces two outputs:

### 1. Implementation Plan Document
Create `/docs/implementation/[feature-name]-implementation-plan.md` with:
- Overview of approach
- All phases with tasks
- Testing strategy
- Risk mitigation notes
- Dependencies and prerequisites

### 2. TodoWrite Task List
Populate TodoWrite with tasks from **Phase 1 only**:
- Keeps immediate focus clear
- Avoids overwhelming task list
- Each phase gets added as it becomes active

## Integration with Feature Discovery

This skill works hand-in-hand with `feature-discovery`:

1. **feature-discovery**: Understand requirements → Create feature spec
2. **plan-implementation**: Analyze spec → Create implementation plan → Populate tasks
3. **Implementation**: Execute tasks → Mark todos complete → Move to next phase

## Best Practices

### Before Planning
- [ ] Feature spec exists and is approved
- [ ] Open questions are resolved
- [ ] Technical approach is validated
- [ ] Codebase has been explored

### During Planning
- [ ] Each phase delivers testable value
- [ ] Tests are written before implementation
- [ ] Phases build on each other logically
- [ ] Risks are identified and sequenced appropriately
- [ ] Task list is concrete and actionable

### After Planning
- [ ] First phase tasks are in TodoWrite
- [ ] Implementation plan is documented
- [ ] Team/stakeholders agree on approach
- [ ] Ready to start implementing immediately

## Example Usage

### User Workflow
```
User: "I'm ready to implement the race modifiers refactor"

Claude (using plan-implementation skill):
1. Reads docs/features/race-modifiers-refactor.md
2. Analyzes requirements and existing code
3. Designs 7 phases with vertical slices
4. Creates detailed task breakdown for each phase
5. Writes docs/implementation/race-modifiers-refactor-implementation-plan.md
6. Populates TodoWrite with Phase 1 tasks
7. Reports: "Ready to implement! Phase 1 tasks added to your todo list."
```

### Phase Progression
```
Phase 1 Complete → Mark todos done → Add Phase 2 todos
Phase 2 Complete → Mark todos done → Add Phase 3 todos
...
All Phases Complete → Feature implemented with full test coverage
```

## Common Phase Patterns

### Pattern 1: Foundation Phase
**Goal**: Set up infrastructure and test harness
- Create test project structure
- Add domain entities/value objects
- Write characterization tests for existing behavior
- Deliverable: Tests run, infrastructure ready

### Pattern 2: Core Logic Phase
**Goal**: Implement main business logic
- Write tests for core calculations/rules
- Implement service methods
- Validate edge cases
- Deliverable: Core feature works in unit tests

### Pattern 3: Integration Phase
**Goal**: Connect to existing systems
- Write integration tests
- Wire up to database/repositories
- Connect to existing services
- Deliverable: Feature works end-to-end

### Pattern 4: UI Phase (if applicable)
**Goal**: Add user-facing interface
- Write UI tests (if framework supports)
- Create controllers/view models
- Wire up to backend services
- Deliverable: Feature accessible to users

### Pattern 5: Cleanup Phase
**Goal**: Remove old code and polish
- Delete deprecated methods
- Consolidate duplicated logic
- Add documentation
- Deliverable: Clean, maintainable codebase

## Notes

- This skill uses Read, Grep, Glob to analyze feature specs and codebase
- Uses TodoWrite to create initial task list
- May use AskUserQuestion to clarify ambiguous implementation choices
- Focuses on actionable, concrete tasks rather than abstract planning
- Emphasizes tests-first approach for confidence and correctness
- Delivers working software incrementally rather than big-bang integration

## CRITICAL GIT WORKFLOW RULES

**NEVER commit or push code without EXPLICIT user approval.**

When implementing planned features:
1. **Plan Phase**: Create implementation plan - NO git commands
2. **Implementation**: Write code, run tests - NO git commits
3. **WAIT for user approval**: User must explicitly say "commit this" or "push this"
4. **ONLY THEN**: Create commits and push to remote

**Examples of what NOT to do:**
- ❌ "Let me commit Phase 1" (without asking first)
- ❌ Automatically committing after completing a phase
- ❌ Assuming user wants code committed

**Correct workflow:**
- ✅ Complete phase implementation
- ✅ Run tests to verify
- ✅ Report results to user: "Phase 1 is complete. All tests passing."
- ✅ ASK: "Would you like me to commit these changes?"
- ✅ WAIT for explicit approval
- ✅ ONLY THEN run git commands

## COMMIT AND PR MESSAGE RULES

**NEVER include Claude Code attribution or self-reference in commits or PRs.**

When creating commits or pull requests:
- ❌ NEVER add "🤖 Generated with [Claude Code]" footer
- ❌ NEVER add "Co-Authored-By: Claude Sonnet" tag
- ❌ NEVER mention Claude, AI, or automated generation
- ✅ Write commit messages as if written by the developer
- ✅ Focus on what changed and why
- ✅ Use professional, technical language only

**Examples:**

**BAD - DO NOT DO THIS:**
```
Feature implementation complete

This adds the new commentary system.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**GOOD - DO THIS:**
```
Feature implementation complete

This adds the new commentary system with event detection
and natural language variation.
```
