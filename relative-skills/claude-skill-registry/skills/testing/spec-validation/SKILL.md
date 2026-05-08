---
name: spec-validation
description: Validates specification quality for technology-agnosticism, testability, and completeness. Automatically invoked when reviewing specs, checking requirements, or before transitioning from specify to plan phase.
allowed-tools:
  - Read
  - Grep
  - Glob
---

# Spec Validation Skill

You are validating specifications in a **Spec Kit** workflow. This skill ensures specifications meet quality standards before proceeding to technical planning.

## Validation Criteria

### 1. Technology Agnosticism

Specifications must describe WHAT and WHY, not HOW. Flag any references to:

**Frameworks & Libraries**
- ❌ React, Vue, Angular, Django, FastAPI, Express
- ❌ Redux, MobX, Zustand (state management)
- ❌ Tailwind, Bootstrap, Material UI (styling)

**Languages & Syntax**
- ❌ async/await, promises, callbacks
- ❌ decorators, hooks, mixins
- ❌ specific type systems

**Databases & Storage**
- ❌ PostgreSQL, MongoDB, Redis, S3
- ❌ SQL queries, NoSQL patterns
- ❌ Specific ORM syntax

**Infrastructure**
- ❌ Docker, Kubernetes, AWS, GCP
- ❌ Specific API protocols (REST, GraphQL, gRPC)
- ❌ Deployment patterns

**Good Example:**
```markdown
Users can view their order history sorted by date.
```

**Bad Example:**
```markdown
Use React Query to fetch orders from the REST API and display in a Tailwind-styled table.
```

### 2. Testability

Every requirement must be verifiable. Flag:

**Vague Requirements**
- ❌ "System should be fast"
- ❌ "Good user experience"
- ❌ "Intuitive interface"
- ❌ "Improve performance"

**Subjective Criteria**
- ❌ "Easy to use"
- ❌ "Modern design"
- ❌ "Scalable architecture"

**Good Examples:**
```markdown
- Page loads in under 2 seconds on 3G connection
- Form validates email format before submission
- Users receive confirmation within 24 hours
- System handles 1000 concurrent users
```

### 3. Completeness

Check for:

**Missing Scenarios**
- Happy path (main flow)
- Error cases (what can go wrong)
- Edge cases (boundary conditions)
- Empty/null states

**Undefined Terms**
- Acronyms without definitions
- Domain-specific terms
- Ambiguous references ("the system", "it")

**Missing Acceptance Criteria**
- Success conditions
- Error conditions
- Performance requirements
- Security requirements

### 4. Consistency

Verify:
- No contradicting requirements
- Consistent terminology
- Aligned with constitution (if exists)
- No duplicate requirements

## Output Format

When validating, produce:

```markdown
## Spec Validation Report

### Summary
| Criterion | Status |
|-----------|--------|
| Technology Agnosticism | ✅ PASS / ⚠️ ISSUES |
| Testability | ✅ PASS / ⚠️ ISSUES |
| Completeness | ✅ PASS / ⚠️ ISSUES |
| Consistency | ✅ PASS / ⚠️ ISSUES |

### Issues Found

#### Technology Leaks
- Line 42: "Use PostgreSQL for storage" → Rephrase as "Data persists across sessions"

#### Testability Issues
- Line 15: "System should be intuitive" → Add measurable criteria

#### Missing Scenarios
- No error handling for invalid input
- No empty state defined

### Recommendations
1. [Priority 1] Remove database reference on line 42
2. [Priority 2] Add success criteria for requirement 3
3. [Priority 3] Define acronym "SSO" on first use
```

## When to Invoke This Skill

Claude should use this skill when:
- User creates or edits a spec.md file
- Before running `/speckit.plan`
- User asks to review a specification
- Discussing requirement quality
- Transitioning from specify to plan phase

## Validation Process

1. **Read the spec.md file**
2. **Check each section** against criteria
3. **Note specific line numbers** for issues
4. **Prioritize findings** by impact
5. **Suggest concrete improvements**

## Integration with Workflow

```
specify → [VALIDATION] → clarify → plan
             ↑
        This skill
```

After validation:
- If PASS: Proceed to `/speckit.plan`
- If ISSUES: Run `/speckit.clarify` to resolve
- If MAJOR ISSUES: Revise spec before proceeding
