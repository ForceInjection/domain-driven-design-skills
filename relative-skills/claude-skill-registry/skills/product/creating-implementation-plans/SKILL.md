---
name: creating-implementation-plans
description: Creates structured implementation plans from feature requirements. Use when planning new features, multi-phase projects, or when the user asks for an implementation plan, build plan, or development roadmap.
---

# Creating Implementation Plans

Transform feature requirements into actionable implementation plans with clear phases, deliverables, and success criteria.

## When to Use This Skill

- User requests an implementation plan, build plan, or roadmap
- Planning a new feature with multiple components
- Organizing work into logical phases
- Need to identify dependencies between features

## Flexibility

Adapt based on project type:

- **Single feature**: Simplified structure, may skip phases
- **Multi-feature project**: Full phase breakdown with dependencies
- **Refactoring**: Focus on risk assessment and rollback strategy
- **Prototypes**: Lighter on testing, heavier on deliverables

## Quick Start

1. **Locate feature requirements documents** - check `requirements/features/` or ask user for paths
2. **Ask for GitHub issue URL(s)** if not provided in context
3. Identify dependencies between features
4. Determine optimal build sequence
5. Create the implementation plan using the template

## File Locations

- `requirements/implementation/` - Implementation plan documents

## Template

See [templates/implementation-plan.md](templates/implementation-plan.md) for the full template.

### Structure Overview

```
# Implementation Plan: [Project Name]
- Overview
- Features Summary (table: ID, Name, Priority, Complexity, Status)
- Recommended Build Sequence
  - Phase N: Rationale, Implementation Steps, Deliverables
- Shared Infrastructure
- Testing Strategy
- Dependencies and Prerequisites
- Risk Assessment (table: Risk, Impact, Probability, Mitigation)
- Success Criteria
- Code Organization
```

### Sequencing Principles

Order features by: **foundation patterns** → **dependencies** → **complexity progression** → **value delivery**

Each phase needs a rationale explaining why it comes at this point and what patterns it introduces.

### Implementation Steps

- Start with CLI/API/interface additions
- Include validation and error handling
- End with tests and documentation
- Be specific enough to execute without ambiguity

## Verification Checklist

Before finalizing:

- [ ] All features from requirements included
- [ ] Build sequence accounts for dependencies
- [ ] Each phase has clear rationale and deliverables
- [ ] Risks identified with mitigations
- [ ] Success criteria are measurable

## Reference

See [implementation-plan-example.md](reference/implementation-plan-example.md) for a complete example covering 5 CLI features with full phase breakdowns.
