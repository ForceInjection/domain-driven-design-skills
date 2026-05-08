---
name: nimble-user-stories
description: Comprehensive guidance for writing user stories following Nimble's product development standards. Use when creating product requirements, organizing backlogs, writing user stories, documenting bugs, or creating chores for digital product development at Nimble. Covers backlog organization (modules, features, labels), user story types (features, bugs, chores), story templates, naming conventions, and estimation guidelines.
---

# Nimble User Stories

Comprehensive guidance for writing user stories following Nimble's standardized backlog management process.

## Overview

This skill provides the complete Nimble methodology for:
- **Backlog organization**: Modules, features, versioning, and labels
- **Feature stories**: User-focused stories that deliver business value
- **Bug reports**: Structured bug documentation with clear reproduction steps
- **Chores**: Non-feature work like refactoring, setup, and research

All documentation is fetched from live sources to ensure accuracy.

## Process Workflow

When writing user stories, follow this sequence:

1. **Fetch latest documentation** - Always start by fetching the relevant documentation URL(s) to get current standards
2. **Identify story type** - Determine if this is a feature, bug, or chore
3. **Apply appropriate template** - Use the correct format for the story type
4. **Validate completeness** - Ensure all required sections are present
5. **Check naming conventions** - Verify labels, titles, and formatting match standards

## Documentation Sources

Before writing any user story, fetch the relevant live documentation:

- **Backlog Organization**: https://nimblehq.co/compass/product/backlog-management/organization/
- **Writing Stories**: https://nimblehq.co/compass/product/backlog-management/user-stories/
- **Feature Stories**: https://nimblehq.co/compass/product/backlog-management/user-stories/features/
- **Bug Stories**: https://nimblehq.co/compass/product/backlog-management/user-stories/bugs/
- **Chore Stories**: https://nimblehq.co/compass/product/backlog-management/user-stories/chores/

**Important**: Always fetch the documentation before writing stories. The live docs contain the most current standards, templates, examples, and best practices.

## Writing Feature Stories

**Always fetch latest documentation first:**
https://nimblehq.co/compass/product/backlog-management/user-stories/features/

### Quick Reference Template (verify with live docs)

```
As a [Who], [When], I [can/must] [action verb] [What]

## Why
What user problem this solves and what business value it creates.

## Acceptance Criteria
- Specific, observable behavior
- Clear success conditions
- No room for interpretation

## Technical Considerations
(Optional) Implementation guidance or constraints

## Design
(Optional) Figma links or design screenshots

## Resources
(Optional) API docs, references, implementation examples
```

### Naming Conventions (verify with live docs)

**Features**: Pattern `<user> <requirement> <action> <item>`
- Examples: "User can view past orders", "Admin can delete ticket"
- Label: `$<user>-<action>-<item>`

**Modules**: Short, descriptive names
- Examples: "Order Management", "Authentication"
- Label: `#<module-name>`

Fetch the documentation for complete details on user value validation, Definition of Done, core components, and feature breakdown best practices.

## Writing Bug Reports

**Always fetch latest documentation first:**
https://nimblehq.co/compass/product/backlog-management/user-stories/bugs/

### Quick Reference Template (verify with live docs)

```
[Clear title stating the issue - NOT user story format]

## Environment
- Platform: Web/Android/iOS
- Device: e.g., iPhone 10
- OS: e.g., iOS 13
- Version: e.g., 0.12.0 (519)
- Environment: staging/production

## Prerequisites
Specific conditions needed to recreate the issue.

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen (with screenshots if possible)

## Actual Behavior
What actually happens (with screenshots/videos)
```

Example title: "On the Homepage, the heading is the wrong font"

Fetch the documentation for complete guidance on environment details, prerequisites, reproduction steps, and attachment requirements.

## Writing Chores

**Always fetch latest documentation first:**
https://nimblehq.co/compass/product/backlog-management/user-stories/chores/

### Quick Reference Template (verify with live docs)

```
[Clear title stating the task]

## Why
Purpose and benefit of this chore

## Acceptance Criteria
- Task 1
- Task 2
- Behaviors to verify in QA

## Resources
Links, documentation, or materials needed
```

### Key Guidelines (verify with live docs)

- Product Manager adds chores to sprint
- Should be completable within one day
- Do not require estimation
- Common types: refactoring, POC, research, dependencies, test coverage, setup tasks

Fetch the documentation for complete details on chore types, handling, and acceptance criteria.

## Backlog Organization

**Always fetch latest documentation first:**
https://nimblehq.co/compass/product/backlog-management/organization/

### Standard Labels (verify with live docs)

- **Module**: `#<module-name>` (e.g., `#authentication`)
- **Feature**: `$<feature-name>` (e.g., `$user-list-tickets`)
- **Chore**: `!<chore-name>` (e.g., `!setup-ci-cd`)
- **Version**: `@<semver>` (e.g., `@1.2.2`)
- **Initial scope**: `initial-scope` (for all initial project stories)

### Priority Levels (verify with live docs)

- **High**: Time-sensitive, blocks work (e.g., users can't login, API down)
- **Medium**: Default priority
- **Low**: No urgency (e.g., minor UI changes, documentation)

### Workflow States (verify with live docs)

Backlog → Ready for Development → In Development → In Code Review → Ready for QA → Completed

### Versioning (verify with live docs)

Semantic Versioning: `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

Fetch the documentation for complete details on modules, features, workflow states, and label usage.

## Best Practices

**Fetch documentation for complete best practices guidance.**

### Core Principles

**DO:**
- Use specific user roles (not "system" or "developer")
- Validate meaningful user value
- Keep stories small and focused
- Write clear, testable acceptance criteria
- Use standardized labels consistently
- Write "Why" at feature level

**DON'T:**
- Split stories by technical layers
- Use generic/vague feature names
- Let technical complexity dictate boundaries
- Forget version labels

## Example Workflow

**User request**: "Create user stories for an order history feature"

**Response process**:
1. Fetch https://nimblehq.co/compass/product/backlog-management/user-stories/features/
2. Fetch https://nimblehq.co/compass/product/backlog-management/organization/
3. Review the fetched documentation for current templates and examples
4. Identify the module (e.g., "Order Management", `#order-management`)
5. Define the feature with Why, labels, and documentation
6. Break down into user stories following the template
7. Apply appropriate labels (`$feature-name`, `@version`, etc.)
8. Validate against best practices

## Resources

This skill maintains minimal bundled resources since all documentation is fetched live from Nimble's compass:

- **Scripts** (`scripts/`): Not currently used - all templates are in live docs
- **References** (`references/`): Not currently used - fetch live documentation
- **Assets** (`assets/`): Not currently used - templates in live docs

**Note**: The decision to fetch live documentation rather than bundle it ensures this skill always reflects Nimble's current standards without requiring skill updates.
