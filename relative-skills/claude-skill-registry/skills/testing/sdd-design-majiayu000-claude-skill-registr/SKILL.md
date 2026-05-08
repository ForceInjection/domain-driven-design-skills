---
name: sdd-design
description: |
  Orchestrate design document creation using specialist skills.
  Use when: starting design phase, merging specialist outputs, resolving design conflicts.
  Triggers: "create design", "design phase", "merge design", "design skeleton"
---

# SDD Design Orchestrator

Coordinate specialist skills to produce a complete design document.

## Role

| Do | Don't |
|----|-------|
| Create skeleton structure | Write implementation details |
| Assign sections to specialists | Make design decisions |
| Map REQs to sections | Choose libraries or patterns |
| Merge specialist outputs | Override specialist decisions |
| Resolve conflicts between specialists | Skip specialist review |

## Specialists

| Skill | Domain | Invocation |
|-------|--------|------------|
| sdd-design-frontend | Component architecture, state, patterns | After skeleton |
| sdd-design-uiux | Layout, responsive, accessibility | After skeleton |
| sdd-design-security | Threats, sandboxing, validation | After skeleton |
| sdd-design-perf | Bundle size, lazy loading, caching | After skeleton |

## Workflow

```
Phase 1: Skeleton
    │
    ├─→ Phase 2: Specialists (parallel)
    │       ├── frontend
    │       ├── uiux  
    │       ├── security
    │       └── perf
    │
    └─→ Phase 3: Merge
```

## Instructions

### Phase 1: Create Skeleton

1. **Read requirements document**
   ```
   packages/{package}/spec/{package}.requirements.md
   ```

2. **Create design file**
   ```
   packages/{package}/spec/{package}.design.md
   ```

3. **Write skeleton** using template:

```markdown
---
title: "{Package} Design"
author: Claude
date: {YYYY-MM-DD}
version: 1.0.0
status: draft
depends_on:
  - packages/{package}/spec/{package}.requirements.md@{version}
---

# {Package} Design

## Overview

Brief description of the design approach.

@derives: (list all REQ IDs)

**Status:** draft

## Component Architecture

@derives: {REQ-IDs}

<!-- sdd-design-frontend writes this section -->

**Status:** pending

## UI/UX Design

@derives: {REQ-IDs}

<!-- sdd-design-uiux writes this section -->

**Status:** pending

## Security Considerations

@derives: {REQ-IDs}

<!-- sdd-design-security writes this section -->

**Status:** pending

## Performance Strategy

@derives: {REQ-IDs}

<!-- sdd-design-perf writes this section -->

**Status:** pending

## Decisions Log

| ID | Decision | Rationale | Owner |
|----|----------|-----------|-------|
| | | | |

## Cross-Cutting Concerns

> **Note:** Extension to sdd-guidelines for specialist coordination.

| Concern | Primary | Reviewer | Status |
|---------|---------|----------|--------|
| Accessibility | uiux | frontend | pending |
| Error handling | frontend | security | pending |
| Loading states | uiux | perf | pending |
```

4. **Initialize state file**

```yaml
# .sdd/state.yaml (add to existing)
documents:
  design:
    status: draft
    sections:
      component-architecture:
        status: pending
        owner: sdd-design-frontend
      uiux:
        status: pending
        owner: sdd-design-uiux
      security:
        status: pending
        owner: sdd-design-security
      perf:
        status: pending
        owner: sdd-design-perf
```

5. **Map REQs to sections**

   Read each requirement and determine which section(s) address it:

   | Section | Typical REQs |
   |---------|--------------|
   | Component Architecture | Structure, data flow, patterns |
   | UI/UX Design | Layout, interaction, responsive |
   | Security | User input, code execution, XSS |
   | Performance | Loading, bundle size, caching |

6. **Fill @derives for each section**

### Phase 2: Invoke Specialists

Invoke all specialists **in parallel**. Each specialist:
- Reads the skeleton
- Reads assigned REQs
- Writes their section
- Adds decisions to Decisions Log

**Invocation format:**
```
Use sdd-design-{specialist} to write the {Section Name} section 
for packages/{package}/spec/{package}.design.md
```

### Phase 3: Merge

After all specialists complete:

1. **Collect outputs**
   - Each specialist's section content
   - Decisions added to log

2. **Check conflicts**

   | Conflict Type | Detection | Resolution |
   |---------------|-----------|------------|
   | Library choice | Same need, different lib | Perf wins unless security concern |
   | Pattern choice | Same problem, different pattern | Frontend decides |
   | Layout vs Perf | UX wants X, Perf says too heavy | UX for primary flow, Perf for edge |
   | Any vs Security | Security flags risk | Security wins, find alternative |

3. **Review cross-cutting concerns**

   For each concern:
   - Primary owner wrote the approach
   - Reviewer validates from their perspective
   - Mark status: `approved` or `needs-revision`

4. **Ensure consistency**
   - Terminology matches across sections
   - No contradicting decisions
   - All REQs have @derives coverage

5. **Update status**
   - If no conflicts: `status: verified`
   - If unresolved: `status: blocked` + note

## Example: react-sample

### Skeleton REQ Mapping

| Section | REQs |
|---------|------|
| Component Architecture | REQ-REACT-001, 002, 003, 004 |
| UI/UX Design | REQ-REACT-002, 003, 005 |
| Security Considerations | REQ-REACT-004 |
| Performance Strategy | REQ-REACT-003, 004 |

### Cross-Cutting for react-sample

| Concern | Primary | Reviewer | Notes |
|---------|---------|----------|-------|
| Accessibility | uiux | frontend | Keyboard nav for playground |
| Error handling | frontend | security | Editable code errors |
| Loading states | uiux | perf | Code viewer lazy load |
| Code display | frontend | perf | Syntax highlighter choice |
| User input | frontend | security | Props playground inputs |

## Verification

After merge:

- [ ] All REQs appear in at least one @derives
- [ ] No section has placeholder comments
- [ ] Decisions Log has entries from each specialist
- [ ] Cross-cutting concerns all `approved`
- [ ] No contradicting decisions
- [ ] Frontmatter complete (title, version, depends_on)

## Conflict Escalation

If specialists can't resolve:

1. Document both options in Decisions Log
2. Set decision status to `escalated`
3. Flag for human review:
   ```markdown
   > ⚠️ **Escalated:** {description}
   > Options: A) {option1} B) {option2}
   > Blocked until human decision.
   ```

## References

- [reference/section-templates.md](reference/section-templates.md) — Detailed section structures
