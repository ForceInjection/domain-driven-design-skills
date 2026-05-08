---
name: dispatching-systematic-debugging
description: Use when encountering bugs, test failures, unexpected behavior, errors, or performance problems - dispatches systematic-debugging-agent that enforces 4-phase process (root cause investigation, pattern analysis, hypothesis testing, implementation) to prevent quick-fix attempts and ensure proper debugging
---

# Dispatching Systematic Debugging

**Core principle:** Debug systematically, not randomly. Dispatch the debugging agent instead of proposing quick fixes.

## When to Dispatch

**Always dispatch systematic-debugging-agent when:**
- Test failures
- Bugs or errors
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Especially when:**
- Fix seems "obvious"
- Under time pressure
- Already tried multiple fixes
- Don't fully understand the issue

## How to Dispatch

Use Task tool with `subagent_type='systematic-debugging-agent'`:

```typescript
Task(
  subagent_type='systematic-debugging-agent',
  prompt=`
    Bug: [What's broken]
    Error: [Error messages, stack traces]
    Context: [Recent changes, environment, what you've tried]
    Goal: [What should happen instead]
  `
)
```

## What the Agent Does

The systematic-debugging-agent maintains full 4-phase process throughout debugging:

1. **Phase 1: Root Cause Investigation** - Gathers evidence before proposing fixes
2. **Phase 2: Pattern Analysis** - Compares against working examples
3. **Phase 3: Hypothesis Testing** - Tests one hypothesis at a time
4. **Phase 4: Implementation** - Creates failing test, then implements fix

**Agent enforces:**
- NO fixes without root cause investigation first
- NO skipping phases (even for "simple" bugs)
- Failing test required before implementation
- Return to Phase 1 after 3 failed fixes

## Red Flags - Dispatch Agent Instead

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "I can see the problem, let me fix it"
- "Skip the process, this is simple"
- "One more fix attempt without investigation"

**ALL of these mean: STOP. Dispatch systematic-debugging-agent.**

## Why Agent Pattern

**Problem:** Skill instructions fade from context after 20+ tool calls, agents forget process and revert to quick-fix mode.

**Solution:** Agent maintains full debugging process in context throughout entire session. Agent identity IS systematic debugging.

**Benefits:**
- No context dilution (agent "born" with full process)
- Automatic discipline enforcement
- Clear start (dispatch) and end (fixed + verified) boundaries
- Process maintained through 50+ tool calls

## After Agent Returns

Agent returns when:
- ✅ Bug fixed and verified
- ✅ All tests passing
- ✅ Root cause documented

You can continue with fixed code.

## Common Mistakes

**DON'T:**
- Propose fixes before dispatching agent
- Skip agent for "simple" bugs
- Ignore agent's investigation process
- Manually skip phases "to save time"

**DO:**
- Dispatch immediately when bug encountered
- Trust agent's systematic process
- Let agent complete all 4 phases
- Learn from agent's investigation approach
