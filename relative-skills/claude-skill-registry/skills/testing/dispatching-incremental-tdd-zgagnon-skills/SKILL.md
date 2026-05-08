---
name: dispatching-incremental-tdd
description: Use when implementing features or adding functionality - dispatches incremental-tdd-agent that enforces ONE test at a time, preventing batch test writing that defeats incremental design discovery. Maintains discipline through entire feature implementation (10+ test cycles)
---

# Dispatching Incremental TDD

**Core principle:** Write ONE test at a time. Dispatch the agent instead of writing multiple tests or full implementation upfront.

## When to Dispatch

**Always dispatch incremental-tdd-agent when:**
- Implementing new features
- Adding functionality to existing code
- Building new components or modules
- Creating APIs or interfaces
- Extending classes or services

**Especially when:**
- Feature seems "simple" or "obvious"
- You can "see the pattern" already
- Writing similar or related tests
- Implementing integration tests
- Under time pressure

## How to Dispatch

Use Task tool with `subagent_type='incremental-tdd-agent'`:

```typescript
Task(
  subagent_type='incremental-tdd-agent',
  prompt=`
    Feature: [What to implement]
    Context: [Existing code, patterns to follow]
    Goal: [Expected behavior when complete]
  `
)
```

## What the Agent Does

The incremental-tdd-agent maintains ONE TEST AT A TIME discipline throughout feature implementation:

**For each test:**
1. **RED Phase (Two-Stage)**
   - Stage 1: Make it compile (write stub)
   - Stage 2: Make it fail correctly (verify test works)
2. **GREEN Phase**
   - Write minimal code to pass THIS test only
3. **REFACTOR Phase**
   - Evaluate design after each test
   - Make improvements before next test

**Agent enforces:**
- NO writing multiple tests at once (even if similar)
- NO skipping to implementation without failing test
- NO batching implementation for multiple tests
- NO skipping REFACTOR phase
- ONE test → GREEN → REFACTOR → repeat

## Red Flags - Dispatch Agent Instead

If you catch yourself thinking:
- "Let me write tests for all scenarios first"
- "I can see the pattern, let me implement it"
- "These tests are similar, I'll batch them"
- "The feature is simple, I'll just write it"
- "Let me write the implementation first, then tests"
- "I'll test the full integration flow at once"
- "Refactoring can wait until feature is complete"
- "Making it compile is obvious, skip to implementation"

**ALL of these mean: STOP. Dispatch incremental-tdd-agent.**

## Why Agent Pattern

**Problem:** ONE TEST discipline fades from context after 3-4 test cycles. By test 5-6, agents batch remaining tests and implementation.

**Solution:** Agent identity IS incremental TDD. Process maintained through 10+ test cycles.

**Benefits:**
- No context dilution during multi-test features
- Automatic discipline enforcement per test
- Design insights emerge test by test
- Process maintained through entire feature
- Clear boundaries (dispatch → feature complete)

## After Agent Returns

Agent returns when:
- ✅ Feature fully implemented
- ✅ All tests passing
- ✅ Design evaluated through multiple REFACTOR cycles
- ✅ Incremental approach maintained throughout

You can continue with completed feature.

## Common Mistakes

**DON'T:**
- Write multiple tests before dispatching
- Skip agent for "simple" features
- Batch similar tests "to save time"
- Skip REFACTOR after early tests
- Ignore agent's ONE TEST discipline

**DO:**
- Dispatch before writing first test
- Trust agent's incremental process
- Let agent complete full RED-GREEN-REFACTOR per test
- Learn design insights from each test cycle
- Maintain discipline through entire feature
