---
name: task-planning
description: Orchestrates the complete task planning workflow including codebase exploration, requirements gathering, and technical plan creation. Use when the user provides a new feature request, bug fix, or refactoring task that needs planning before implementation.
---

# Task Planning Workflow - AIGP Django Backend

You are orchestrating a multi-phase planning workflow for **AIGP Django backends**.

**IMPORTANT:** Always reference `references/coding-standards.md` for coding conventions. All plans must follow AIGP coding standards.

This skill automatically activates when users describe tasks that need planning, such as:
- "I need to add..." / "We should implement..."
- "Plan out..." / "Design..."
- "How should we implement..."
- New feature requests
- Bug fixes that require investigation
- Refactoring tasks

## Workflow Phases

### Phase 1: Initial Understanding

**Goal:** Understand the codebase context relevant to the task.

1. Launch the `explore-codebase` agent to investigate:
   - Existing implementations related to the task
   - Coding patterns and conventions
   - Dependencies and related components
   - Potential impact areas

2. Summarize findings for the user:
   - Key files discovered
   - Architecture overview
   - Patterns to follow
   - Areas of concern

### Phase 2: Requirements Clarification

**Goal:** Ensure requirements are clear before planning.

1. Use the `requirements-analyst` agent to:
   - Analyze the user's request
   - Identify ambiguities
   - Generate clarifying questions

2. Present questions to the user:
   - Prioritize by importance
   - Provide options where possible
   - Explain why each question matters

3. **Wait for user responses before proceeding**
   - Do not make assumptions
   - Record answers for planning phase

### Phase 3: Technical Planning

**Goal:** Create a detailed, actionable implementation plan.

1. Launch the `plan-architect` agent with:
   - Codebase exploration results
   - Clarified requirements
   - User preferences

2. Review the generated plan for:
   - Completeness
   - Correctness
   - Alignment with requirements

3. Present the plan to the user:
   - Summary of approach
   - Step-by-step implementation guide
   - Files to modify
   - Risks and mitigations

### Phase 4: Finalization

**Goal:** Get user approval and prepare for implementation.

1. Incorporate user feedback:
   - Address concerns
   - Adjust approach if needed
   - Add missing details

2. Write final plan to `.claude/plans/` directory:
   - Use descriptive filename
   - Include all context needed
   - Make it standalone readable

3. Confirm readiness:
   - Ask for explicit approval
   - Clarify next steps
   - Offer to begin implementation

## Important Guidelines

### AIGP Coding Standards (MANDATORY)
Reference: `references/coding-standards.md`

All plans must ensure:
- Models inherit from `BaseModel` (audit fields)
- Serializers inherit from `CustomBaseSerializer`
- Views use `APIView` with permission classes
- Write operations use `@transaction.atomic`
- Success responses use `create_success_response()`
- Errors use `LogicError()` with domain error codes
- OpenAPI documentation via `@extend_schema`
- URLs follow `/api/v1/` prefix and kebab-case
- Queries filter `is_delete=False` (soft deletes)

### Never Skip Phases
- Always explore the codebase before planning
- Always clarify requirements before architecting
- Always get approval before implementing

### Communication Style
- Be concise but thorough
- Use bullet points for clarity
- Highlight critical decisions
- Explain trade-offs

### Plan Output Location
Save all plans to: `.claude/plans/[task-name].md`

### Quality Standards
- Plans must be actionable (no vague steps)
- Files must have full paths
- Testing must be addressed
- Risks must be documented

## Trigger Phrases

This skill activates automatically for:
- Feature requests: "add", "implement", "create", "build"
- Planning requests: "plan", "design", "architect", "how should we"
- Investigation: "investigate", "analyze", "understand"
- Refactoring: "refactor", "improve", "optimize", "restructure"

## Example Workflow

**User:** "I need to add email notifications when orders are placed"

**Phase 1:** Explore codebase for:
- Order processing code
- Existing notification systems
- Email configuration
- Event handling patterns

**Phase 2:** Ask clarifying questions:
- What email provider should we use?
- Should notifications be async?
- What information should the email contain?

**Phase 3:** Create plan:
- Add email service integration
- Create notification template
- Hook into order completion event
- Add configuration options

**Phase 4:** Present plan and get approval
