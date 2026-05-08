---
name: superthink
description: Deep reasoning framework for complex tasks with confidence validation, context gathering, and systematic planning
version: 1.0.0
---

# SuperThink

Confidence-driven workflow preventing misaligned execution: invest 100-200 tokens upfront to save 5,000-50,000 tokens.

## When to Use

**USE for:**
- Complex features requiring changes across multiple files/systems
- Architectural decisions with long-term implications
- Unclear requirements needing exploration
- Multi-system integration
- Breaking changes
- Security-sensitive implementations

**SKIP for:**
- Simple, well-defined single-file changes
- Obvious bug fixes with clear solutions
- Routine tasks (formatting, linting, etc.)

## Core Philosophy

**Confidence-driven workflow:** Requires **≥90% confidence score** before proceeding to implementation.

1. **Context Gathering** (30% effort) - Understand what exists
2. **Confidence Assessment** (20% effort) - Validate readiness
3. **Structured Planning** (30% effort) - Break down approach
4. **Implementation** (20% effort) - Execute with tracking

## Five-Phase Workflow

### Phase 1: Initial Context (30 tokens)
Parse requirements | Identify systems | Create TodoWrite tasks

### Phase 2: Deep Context Gathering (60 tokens)
Search codebase (Grep/Glob) | Read existing code | Check docs | Analyze dependencies

### Phase 3: Confidence Assessment (40 tokens)

| Component                    | Weight | Validates                    |
| ---------------------------- | ------ | ---------------------------- |
| No Duplicate Implementations | 25%    | Existing functionality check |
| Architecture Compliance      | 25%    | Pattern alignment            |
| Documentation Verified       | 20%    | API/library validation       |
| Data Model Understood        | 20%    | Schema/type confirmation     |
| Dependencies Mapped          | 10%    | Side effects understood      |

**Requires ≥90% score to proceed.**

### Phase 4: Structured Planning (50 tokens)
Order by dependency | Follow existing patterns | Include validation | Expand TodoWrite

### Phase 5: Execution with Validation (Variable tokens)
Mark in_progress (ONE at a time) | Execute | Validate immediately | Mark completed immediately | Handle errors at root cause

## TodoWrite Hygiene

- Create tasks at Phase 1
- Expand at Phase 4
- Mark completed after each step
- ONE in_progress at a time

## Success Metrics

60-70% fewer tokens | Zero failures | First-try success
