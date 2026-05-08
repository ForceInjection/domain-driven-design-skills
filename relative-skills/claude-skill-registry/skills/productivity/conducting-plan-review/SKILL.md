---
name: Conducting Plan Review
description: Complete workflow for evaluating implementation plans before execution with quality checklist and structured feedback
when_to_use: when evaluating implementation plans, before executing plans, when another agent asks you to review a plan
version: 1.0.0
---

# Conducting Plan Review

## Overview

Systematic plan evaluation process ensuring plans are comprehensive, executable, and account for all quality criteria (security, testing, architecture, error handling, code quality, process) before implementation begins.

## When to Use

Use verifying-plans when:

- **Before executing implementation plan:** Validate quality and completeness before agents start work
- **After writing a plan:** Quality-check the plan you just created
- **Before high-stakes work:** Ensure plan meets standards before committing resources
- **When plan scope is uncertain:** Verify all requirements are covered
- **Default before /execute:** Standard quality gate before plan execution

**Don't use when:**
- Plan is simple checklist (1-3 trivial steps)
- Doing research/exploration (not implementation plan)
- Plan already executed and complete


## Quick Reference

**Before starting:**
1. Read plan to understand scope and approach
2. Evaluate against plan quality standards
3. Check plan structure (task granularity, completeness, TDD approach)
4. Save structured feedback to work directory

**Core workflow:**
1. Identify plan to review
2. Review against quality checklist (all categories)
3. Evaluate plan structure and completeness
4. Save structured feedback to work directory

## Implementation

### Prerequisites

Read these to understand quality standards:
- `${CLAUDE_PLUGIN_ROOT}standards/code-review.md` - Quality standards apply to plans too
- `${CLAUDE_PLUGIN_ROOT}standards/development.md` - Simplicity, consistency, documentation
- `${CLAUDE_PLUGIN_ROOT}principles/testing.md` - TDD and testing principles

### Step-by-Step Workflow

#### 1. Identify plan to review

**Locate the plan:**
- Plan files are typically in `.work/<feature-name>` directory
- Naming pattern: `YYYY-MM-DD-<feature-name>.md`
- Check current directory or ask user for plan location

**Read the plan completely:**
- Understand the goal and architecture
- Review all tasks and steps
- Note any immediate concerns

#### 2. Review against quality checklist

**Review ALL categories from verify-plan-template.md:**

1. **Security & Correctness** (6 items)
   - Does plan address security vulnerabilities in design?
   - Does plan consider dependency security?
   - Does plan include acceptance criteria?
   - Does plan handle concurrency if applicable?
   - Does plan specify error handling strategy?
   - Does plan address API/schema compatibility?

2. **Testing** (6 items)
   - Does plan include test strategy?
   - Does plan specify TDD approach?
   - Does plan identify edge cases?
   - Does plan emphasize behavior testing?
   - Does plan require test isolation?
   - Does plan specify test structure?

3. **Architecture** (7 items)
   - Does plan maintain SRP?
   - Does plan avoid duplication?
   - Does plan separate concerns?
   - Does plan avoid over-engineering (YAGNI)?
   - Does plan minimize coupling?
   - Does plan maintain encapsulation?
   - Does plan keep modules testable?

4. **Error Handling** (3 items)
   - Does plan specify error handling approach?
   - Does plan include error message requirements?
   - Does plan identify invariants?

5. **Code Quality** (7 items)
   - Does plan emphasize simplicity?
   - Does plan include naming conventions?
   - Does plan maintain type safety?
   - Does plan follow project patterns?
   - Does plan avoid magic numbers?
   - Does plan specify where rationale is needed?
   - Does plan include documentation requirements?

6. **Process** (6 items)
   - Does plan include verification steps?
   - Does plan identify performance considerations?
   - Does plan include linting/formatting verification?
   - Does plan scope match requirements?
   - Does plan leverage existing libraries/patterns?
   - Does plan include commit strategy?

**Empty BLOCKING section is GOOD if you actually checked.** Missing sections mean you didn't check.

**BLOCKING vs SUGGESTIONS decision:**

Use BLOCKING when:
- Security vulnerability in design
- Missing error handling strategy
- No test strategy or TDD approach
- Tasks too large (>5 minutes)
- Missing exact file paths or commands
- Scope doesn't match requirements

Use SUGGESTIONS when:
- Could add logging for debugging
- Could improve variable naming
- Could add documentation
- Could consider performance optimization
- Could leverage existing pattern

**Rule of thumb:**
- BLOCKING = Plan will fail during execution or produce insecure/incorrect code
- SUGGESTIONS = Plan would succeed but quality could be higher

#### 3. Evaluate plan structure

**Task Granularity:**
- Are tasks bite-sized (2-5 minutes each)?
- Are tasks independent where possible?
- Does each task have clear success criteria?

**Completeness:**
- Are exact file paths specified?
- Are complete code examples provided (not "add validation")?
- Are exact commands with expected output included?
- Are relevant skills/practices referenced?

**TDD Approach:**
- Does each task follow RED-GREEN-REFACTOR?
- Write test → Run test (fail) → Implement → Run test (pass) → Commit?

#### 4. Save structured evaluation

**Template location:**
`${CLAUDE_PLUGIN_ROOT}templates/verify-plan-template.md`

**YOU MUST use this exact structure:**

```markdown
# Plan Evaluation - {Date}

## Status: [BLOCKED | APPROVED WITH SUGGESTIONS | APPROVED]

## Plan Summary
- **Feature:** [Feature name]
- **Location:** [Path to plan file]
- **Scope:** [Brief description]

## BLOCKING (Must Address Before Execution)
[Issues or "None"]

**[Issue title]:**
- Description: [what's missing or problematic]
- Impact: [why this blocks execution]
- Action: [what needs to be added/changed]

## SUGGESTIONS (Would Improve Plan Quality)
[Suggestions or "None"]

**[Suggestion title]:**
- Description: [what could be improved]
- Benefit: [how this would help]
- Action: [optional improvement]

## Plan Quality Checklist
[Check all 35 items across 6 categories]

## Plan Structure Quality
[Evaluate task granularity, completeness, TDD approach]

## Assessment
**Ready for execution?** [YES / NO / WITH CHANGES]

**Reasoning:** [Brief explanation]
```

**File naming:**

Save to `.work/{YYYY-MM-DD}-verify-plan-{HHmmss}.md`

Example: `.work/2025-11-22-verify-plan-143052.md`

**Time-based naming ensures:**
- No conflicts when multiple agents run in parallel (dual verification)
- Each evaluation gets unique filename automatically
- Collation agents can find all reviews with glob pattern
- No coordination needed between agents

**Do NOT create custom section structures.** Use template exactly. Additional context (plan excerpts, specific examples) may be added at the end, but core template sections are mandatory.

## What NOT to Skip

**NEVER skip:**
- Reading the entire plan (not just summary)
- Reviewing ALL quality categories (not just critical)
- Checking plan structure (granularity, completeness, TDD)
- Saving evaluation file to work directory
- Including specific examples of issues found

**Common rationalizations that violate workflow:**
- "Plan looks comprehensive" → Check all categories anyway
- "Author is experienced" → Evaluate objectively regardless of author
- "Just a small feature" → Small features need complete plans
- "Only flagging blockers" → Document suggestions too
- "Template is too detailed" → Template structure is mandatory

## Related Skills

**Writing plans:**
- Writing Plans: `${CLAUDE_PLUGIN_ROOT}skills/writing-plans/SKILL.md`

**Executing plans:**
- Executing Plans: `${CLAUDE_PLUGIN_ROOT}skills/executing-plans/SKILL.md`

## Testing This Skill

See `test-scenarios.md` for pressure tests validating this workflow resists rationalization.
