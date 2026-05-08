---
name: task
description: Create well-defined task specifications from plans or user prompts. Use when user wants to define a task, create a work item, break down a plan into actionable work, or write a spec for implementation. Triggers on "create task", "define task", "write spec", "break this down", "make this actionable", or when moving from planning to execution.
---

# Task Creation

Create well-defined task specifications that provide clear goals while leaving implementation open to interpretation. Output to `.work/tasks/backlog/<name>.md`.

## Task Creation Workflow

### 1. Understand the Scope

Determine task type and relevant sections:
- **Full-stack feature**: All sections applicable
- **Backend only**: Skip UX Guidelines, focus on System Behaviors and Data
- **Frontend only**: Skip Data & Contracts internals, focus on UX
- **Documentation**: Summary, Acceptance Criteria only
- **Bug fix**: Summary, Edge Cases, Acceptance Criteria
- **Refactor**: Summary, System Behaviors, Acceptance Criteria

### 2. Gather Context

If working from a plan:
- Read the plan from `.work/plans/`
- Extract relevant decisions and constraints
- Link back to the plan

If working from user prompt:
- Ask clarifying questions about scope
- Identify affected files and systems
- Understand success criteria

### 3. Write the Task Spec

Create `.work/tasks/backlog/<descriptive-name>.md` using the template below.

**Omit sections not relevant to the task type.** A backend API task doesn't need UX Guidelines. A docs update doesn't need System Behaviors.

## Task Template

See [references/spec-template.md](references/spec-template.md) for the full template.

Core sections:
- **Summary**: One paragraph describing the task and why it exists
- **User Journey**: Entry point, happy path, exit criteria
- **UX Guidelines**: What user sees, copy tone, accessibility
- **System Behaviors**: Invariants, state transitions, policies
- **Data & Contracts**: Storage needs, API/events (high-level)
- **Usage/Cost Accounting**: What usage to track and how
- **Edge Cases**: Failure modes and user-visible outcomes
- **Acceptance Criteria**: Testable outcomes as bullet list

## Writing Guidelines

### Be Specific About What, Open About How

**Good**: "User can filter todos by status (all, active, completed)"
**Bad**: "Implement filtering using React state with useMemo optimization"

Define the outcome, not the implementation.

### Reference Concrete Touchpoints

Include:
- Files that will likely need changes
- API routes or contracts involved
- Database tables affected
- UI components to modify

### Keep It Scannable

- Use bullet points over paragraphs
- Bold key terms
- Keep acceptance criteria atomic and testable

## Task Lifecycle

After creating the task:
1. Task starts in `.work/tasks/backlog/`
2. When work begins, move to `.work/tasks/in-progress/`
3. When complete, move to `.work/tasks/completed/`

Update task status in the file header as work progresses.

