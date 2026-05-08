---
name: spec-kit-workflow
description: Guides specification-driven development workflow. Automatically invoked when discussing new features, specifications, technical planning, or implementation tasks. Ensures proper workflow phases (specify → clarify → plan → checklist → tasks → analyze → implement).
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - SlashCommand
---

# Spec Kit Workflow Skill

You are assisting with a project that uses **Spec Kit** - a specification-driven development framework. This skill ensures proper workflow adherence.

## Workflow Phases

The Spec Kit workflow follows this progression:

```
constitution → specify → clarify → plan → checklist → tasks → analyze → implement
```

### Phase Descriptions

1. **Constitution** (`/speckit.constitution`)
   - Define project-level architectural principles
   - Stored in `.specify/memory/constitution.md`
   - One-time setup per project

2. **Specify** (`/speckit.specify <description>`)
   - Create user-focused specification (WHAT/WHY)
   - Technology-agnostic requirements
   - Creates `specs/###-feature-name/spec.md`

3. **Clarify** (`/speckit.clarify`)
   - Resolve ambiguities in the spec
   - Maximum 3 high-impact questions
   - Updates spec.md with answers

4. **Plan** (`/speckit.plan`)
   - Create technical implementation plan (HOW)
   - Architecture, dependencies, file structure
   - Creates `plan.md` in feature directory

5. **Checklist** (`/speckit.checklist`)
   - Generate domain-specific quality checklists
   - Security, accessibility, performance
   - Creates `checklists/` in feature directory

6. **Tasks** (`/speckit.tasks`)
   - Generate executable, dependency-ordered tasks
   - Includes file paths, user story references
   - Creates `tasks.md` in feature directory

7. **Analyze** (`/speckit.analyze`)
   - Cross-artifact consistency validation
   - Ensures spec → plan → tasks alignment
   - CRITICAL: Run before implementation

8. **Implement** (`/speckit.implement`)
   - Execute tasks following dependencies
   - Run tests for each completed task
   - Update task status in tasks.md

## When to Invoke This Skill

Claude should use this skill when the user:
- Mentions adding a new feature
- Discusses specifications or requirements
- Asks about planning implementation
- Wants to understand the development workflow
- References spec.md, plan.md, or tasks.md files

## Key Principles

### Separation of Concerns
- **Spec**: WHAT/WHY (user-focused, technology-agnostic)
- **Plan**: HOW (technical, includes frameworks/architecture)
- **Tasks**: WHEN/ORDER (executable, with dependencies)

### Quality Gates
Always run `/speckit.analyze` before `/speckit.implement` to catch:
- Missing requirements
- Scope creep
- Inconsistent artifacts

### Task Organization
Tasks use priority levels:
- **P1**: MVP - Must have
- **P2**: Important - Should have
- **P3**: Nice to have - Could have

Task markers:
- `[T###]` - Task ID
- `[P]` - Parallelizable
- `[US#]` - User story reference

## Examples

### Starting a New Feature
```
User: I want to add user authentication
Claude: Let's use the Spec Kit workflow. Run /speckit.specify Add user authentication with email/password login
```

### Checking Current Phase
```
User: What should I do next?
Claude: [Checks for existing artifacts in specs/]
- If no spec.md: Start with /speckit.specify
- If spec.md but no plan.md: Run /speckit.plan
- If plan.md but no tasks.md: Run /speckit.tasks
- If tasks.md exists: Run /speckit.analyze then /speckit.implement
```

### Before Implementation
```
User: Let's start coding
Claude: Before implementing, let's validate consistency with /speckit.analyze to ensure spec, plan, and tasks are aligned.
```
