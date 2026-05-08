---
name: vibeflow-issue-template
description: Create or refine VibeFlow issue files under issues/. Use when turning plan items into implementable tasks with clear acceptance criteria.
---

# VibeFlow Issue Template

## When to Use
- When creating new issue files from plan items
- When refining existing issues with clearer acceptance criteria
- When converting user requests into implementable tasks

## Output Format (Required)

Every issue file MUST include these sections:

### Overview
Brief description of the task (1-2 sentences).

### Requirements
- Bullet list of functional requirements
- What the implementation must achieve

### Acceptance Criteria
- [ ] Testable, unambiguous criteria
- [ ] Each item should be verifiable
- [ ] Include edge cases where relevant

### Technical Details
- Implementation approach
- Architecture decisions
- API contracts (if applicable)

### File Locations
- List of files to be created/modified
- Include paths relative to project root

### Testing Requirements
- Unit test requirements
- Integration test requirements (if applicable)
- E2E test requirements (if applicable)

### Dependencies
- Other issues this depends on
- External dependencies (packages, APIs)

### Non-goals (optional)
- What is explicitly out of scope

## Instructions

1. **Read context first**: Always read `spec.md` and `plan.md` before creating issues.
2. **Check state**: Read `.vibe/state.yaml` to understand current phase.
3. **Create file**: Write to `issues/<issue-name>.md`.
4. **Verify completeness**: Ensure all required sections are present.
5. **Cross-reference**: Link to related issues if applicable.

## Examples

- "Create an issue for user authentication"
- "Turn plan item 2.1 into an implementable issue"
- "Refine issue-001 with clearer acceptance criteria"

