---
name: debugging-and-diagnosis
version: 2.0.0
description: Systematic debugging methodology using evidence-based investigation to identify root causes. Use when encountering bugs, errors, unexpected behavior, failing tests, or intermittent issues. Enforces four-phase framework (root cause investigation, pattern analysis, hypothesis testing, implementation) with the iron law NO FIXES WITHOUT ROOT CAUSE FIRST. Covers runtime errors, logic bugs, integration failures, and performance issues. Useful when debugging, troubleshooting, investigating failures, or when --debug flag is mentioned.
---

# Systematic Debugging

Evidence-based investigation → root cause → verified fix.

<when_to_use>

- Bugs, errors, exceptions, crashes
- Unexpected behavior or wrong results
- Failing tests (unit, integration, e2e)
- Intermittent or timing-dependent failures
- Performance issues (slow, memory leaks, high CPU)
- Integration failures (API, database, external services)

NOT for: well-understood issues with obvious fixes, feature requests, architecture planning

</when_to_use>

<iron_law>

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST**

Never propose solutions, "quick fixes", or "try this" without first understanding root cause through systematic investigation.

</iron_law>

<phases>

Track with TodoWrite. Phases advance forward only.

| Phase | Trigger | activeForm |
|-------|---------|------------|
| Collect Evidence | Session start, bug encountered | "Collecting evidence" |
| Isolate Variables | Evidence gathered, reproduction confirmed | "Isolating variables" |
| Formulate Hypotheses | Problem isolated, patterns identified | "Formulating hypotheses" |
| Test Hypothesis | Hypothesis formed | "Testing hypothesis" |
| Verify Fix | Fix identified and implemented | "Verifying fix" |

Situational (insert when triggered):
- Iterate → Hypothesis disproven, need new approach
  - Trigger: Test Hypothesis fails to confirm hypothesis
  - activeForm: "Iterating on findings"
  - Loops back to Test Hypothesis with new hypothesis

Workflow:
- Start: Create "Collect Evidence" as `in_progress`
- Transition: Mark current `completed`, add next `in_progress`
- Failed hypothesis: Mark "Test Hypothesis" complete, add "Iterate" `in_progress`
- Quick fixes: If root cause obvious from error, skip directly to "Verify Fix" (still create failing test)
- Need more evidence: Add new "Collect Evidence" task (don't regress phases)
- Circuit breaker: After 3 failed hypotheses → escalate (see `<escalation>`)

</phases>

<quick_start>

When encountering a bug:

1. Create "Collect Evidence" todo as `in_progress` via TodoWrite
2. Reproduce — exact steps to trigger consistently
3. Investigate — gather evidence about what's actually happening
4. Analyze — compare working vs broken, find all differences
5. Test hypothesis — form single specific hypothesis, test minimally
6. Implement — write failing test, then fix
7. On phase transitions, update todos (mark complete, add next)

</quick_start>

<phase_1_root_cause>

Goal: Understand what's actually happening, not what you think is happening.

Transition: Mark "Collect Evidence" complete and add "Isolate Variables" as `in_progress` when you have reproduction steps and initial evidence.

Steps:

**Read error messages completely**
- Error messages often contain solution
- Read stack traces top to bottom
- Note file paths, line numbers, variable names
- Look for "caused by" chains

**Reproduce consistently**
- Document exact steps to trigger bug
- Note what inputs cause it vs don't cause it
- Check if intermittent (timing, race conditions)
- Verify in clean environment

**Check recent changes**
- `git diff` — what changed since it last worked?
- `git log --since="yesterday"` — recent commits
- Dependency updates — package.json/Cargo.toml changes
- Config changes — environment variables, settings files
- External factors — API changes, database schema

**Gather evidence systematically**
- Add logging at key points in data flow
- Print variable values at each transformation
- Log function entry/exit with parameters
- Capture timestamps for timing issues
- Save intermediate state for inspection

**Trace data flow backward**
- Where does bad value come from?
- Track backward through transformations
- Find first place it becomes wrong
- Identify transformation that broke it

Red flags indicating need more investigation:
- "I think maybe X is the problem"
- "Let's try changing Y"
- "It might be related to Z"
- Starting to write code

</phase_1_root_cause>

<phase_2_pattern_analysis>

Goal: Learn from what works to understand what's broken.

Transition: Mark "Isolate Variables" complete and add "Formulate Hypotheses" as `in_progress` when you've identified key differences between working and broken cases.

Steps:

**Find working examples in same codebase**
- Search for similar functionality that works
- Grep for similar patterns: `rg "pattern"`
- Look for tests that pass vs fail
- Check git history for when it last worked

**Read reference implementations completely**
- Don't skim — read every line
- Understand full context
- Note all dependencies and imports
- Check configuration and setup

**Identify every difference**
- Line by line comparison working vs broken
- Different imports or dependencies?
- Different function signatures?
- Different error handling?
- Different data flow or transformations?
- Different configuration or environment?

**Understand dependencies**
- What libraries/packages involved?
- What versions in use?
- What external services called?
- What shared state exists?
- What assumptions made?

Questions to answer:
- Why does working version work?
- What's fundamentally different in broken version?
- Are there edge cases working version handles?
- What invariants does working version maintain?

</phase_2_pattern_analysis>

<phase_3_hypothesis_testing>

Goal: Test one specific idea with minimal changes.

Transition: Mark "Formulate Hypotheses" complete and add "Test Hypothesis" as `in_progress` when you have specific, evidence-based hypothesis.

Steps:

**Form single, specific hypothesis**
- Template: "I think X is root cause because Y"
- Must explain all observed symptoms
- Must be testable with small change
- Must be based on evidence from phases 1-2

**Design minimal test**
- Smallest possible change to test hypothesis
- Change exactly ONE variable
- Preserve everything else
- Make it reversible

**Execute test**
- Apply the change
- Run reproduction steps
- Observe results carefully
- Document what happened

**Verify or pivot**
- If fixed: Confirm works across all cases, proceed to "Verify Fix"
- If not fixed: Mark "Test Hypothesis" complete, add "Iterate" as `in_progress`, form NEW hypothesis
- If partially fixed: Add "Iterate" to investigate what remains
- Never: Try random variations hoping one works

Bad hypothesis examples:
- "Maybe it's a race condition" (too vague)
- "Could be caching or permissions" (multiple causes)
- "Probably something with the database" (no evidence)

Good hypothesis examples:
- "Function fails because it expects number but receives string when API returns empty results"
- "Race condition occurs because fetchData() called before initializeClient() completes, causing uninitialized error"
- "Memory leak happens because event listeners added in useEffect but never removed in cleanup"

</phase_3_hypothesis_testing>

<phase_4_implementation>

Goal: Fix root cause permanently with verification.

Transition: Mark "Test Hypothesis" complete and add "Verify Fix" as `in_progress` when you've confirmed hypothesis and ready to implement permanent fix.

Steps:

**Create failing test case**
- Write test that reproduces bug
- Verify it fails before fix
- Should pass after fix
- Captures exact scenario that was broken

**Implement single fix**
- Address identified root cause
- No additional "improvements"
- No refactoring "while you're there"
- Just fix specific problem

**Verify fix works**
- Failing test now passes
- All existing tests still pass
- Manual reproduction steps no longer trigger bug
- No new errors or warnings introduced

**Circuit breaker: 3 failed fixes**
- If 3+ fixes tried and none worked: STOP
- Problem isn't hypothesis — problem is architecture
- Code may be using wrong pattern entirely
- Escalate or redesign instead of more fixes

After fixing:
- Mark "Verify Fix" as `completed`
- Add defensive validation at multiple layers
- Document why bug occurred
- Consider if similar bugs exist elsewhere
- Update documentation if behavior was misunderstood

</phase_4_implementation>

<playbooks>

Bug type specific investigation focus and techniques.

**Runtime Errors** (crashes, exceptions)

Investigation focus:
- Stack trace analysis (which line, which function)
- Variable state at crash point
- Input values that trigger crash
- Environment differences (dev vs prod)

Common causes:
- Null/undefined access
- Type mismatches
- Array out of bounds
- Missing error handling
- Resource exhaustion

Key techniques:
- Add try-catch with detailed logging
- Validate assumptions with assertions
- Check for null/undefined before access
- Log input values before processing

**Logic Bugs** (wrong result, unexpected behavior)

Investigation focus:
- Expected vs actual output comparison
- Data transformations step by step
- Conditional logic evaluation
- State changes over time

Common causes:
- Off-by-one errors
- Incorrect comparison operators
- Wrong order of operations
- Missing edge case handling
- State not reset between operations

Key techniques:
- Print intermediate values
- Step through with debugger
- Write test cases for edge cases
- Check loop boundaries carefully

**Integration Failures** (API, database, external service)

Investigation focus:
- Request/response logging
- Network traffic inspection
- Authentication/authorization
- Data format mismatches
- Timing and timeouts

Common causes:
- API version mismatch
- Authentication token expired
- Wrong content-type headers
- Data serialization differences
- Network timeout too short
- Rate limiting

Key techniques:
- Log full request/response
- Test with curl/httpie directly
- Check API documentation version
- Verify credentials and permissions
- Monitor network timing

**Intermittent Issues** (works sometimes, fails others)

Investigation focus:
- What's different when it fails?
- Timing dependencies
- Shared state/resources
- External conditions
- Concurrency issues

Common causes:
- Race conditions
- Cache inconsistency
- Clock/timezone issues
- Resource contention
- External service flakiness

Key techniques:
- Add timestamps to all logs
- Run many times to find pattern
- Check for async operations
- Look for shared mutable state
- Test under different loads

**Performance Issues** (slow, memory leaks, high CPU)

Investigation focus:
- Profiling and metrics
- Resource usage over time
- Algorithm complexity
- Data volume scaling
- Memory allocation patterns

Common causes:
- N+1 queries
- Inefficient algorithms
- Memory leaks (unreleased resources)
- Excessive allocations
- Missing indexes
- Unbounded caching

Key techniques:
- Profile with appropriate tools
- Measure time/memory at checkpoints
- Test with various data sizes
- Check for cleanup in destructors
- Monitor resource usage trends

</playbooks>

<evidence>

Patterns for gathering diagnostic information.

**Instrumentation** — add diagnostic logging without changing behavior:

```typescript
function processData(data: Data): Result {
  console.log('[DEBUG] processData input:', JSON.stringify(data));

  const transformed = transform(data);
  console.log('[DEBUG] after transform:', JSON.stringify(transformed));

  const validated = validate(transformed);
  console.log('[DEBUG] after validate:', JSON.stringify(validated));

  const result = finalize(validated);
  console.log('[DEBUG] processData result:', JSON.stringify(result));

  return result;
}
```

**Binary Search Debugging** — find commit that introduced bug:

```bash
git bisect start
git bisect bad                    # Current commit is bad
git bisect good <last-good-commit> # Known good commit

# Git will check out middle commit
# Test if bug exists, then:
git bisect bad   # if bug exists
git bisect good  # if bug doesn't exist

# Repeat until git identifies exact commit
```

**Differential Analysis** — compare versions side by side:

```bash
# Working version
git show <good-commit>:path/to/file.ts > file-working.ts

# Broken version
git show <bad-commit>:path/to/file.ts > file-broken.ts

# Detailed diff
diff -u file-working.ts file-broken.ts
```

**Timeline Analysis** — correlate events for intermittent issues:

```
12:00:01.123 - Request received
12:00:01.145 - Database query started
12:00:01.167 - Cache check started
12:00:01.169 - Cache hit returned  <-- Returned before DB!
12:00:01.234 - Database query completed
12:00:01.235 - Error: stale data   <-- Bug symptom
```

</evidence>

<red_flags>

If you catch yourself thinking or saying these — STOP, return to Phase 1:

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "I don't fully understand but this might work"
- "One more fix attempt" (when already tried 2+)
- "Let me try a few different things"
- Proposing solutions before gathering evidence
- Skipping failing test case
- Fixing symptoms instead of root cause

ALL of these mean: STOP. Return to Phase 1.

Add new "Collect Evidence" task and mark current task complete.

</red_flags>

<anti_patterns>

Common debugging mistakes to avoid.

**Random Walk** — trying different things hoping one works without systematic investigation

Why it fails: Wastes time, may mask real issue, doesn't build understanding

Instead: Follow phases 1-2 to understand system

**Quick Fix** — implementing solution that stops symptom without finding root cause

Why it fails: Bug will resurface or manifest differently

Instead: Use phase 1 to find root cause before fixing

**Cargo Cult** — copying code from Stack Overflow without understanding why it works

Why it fails: May not apply to your context, introduces new issues

Instead: Use phase 2 to understand working examples thoroughly

**Shotgun Approach** — changing multiple things simultaneously "to be sure"

Why it fails: Can't tell which change fixed it or if you introduced new bugs

Instead: Use phase 3 to test one hypothesis at a time

</anti_patterns>

<integration>

Connect debugging to broader development workflow.

**Test-Driven Debugging**:
1. Write test that reproduces bug (fails)
2. Fix the bug
3. Test passes
4. Confirms fix works and prevents regression

**Defensive Programming After Fix** — add validation at multiple layers:

```typescript
function processUser(userId: string): User {
  // Input validation
  if (!userId || typeof userId !== 'string') {
    throw new Error('Invalid userId: must be non-empty string');
  }

  // Fetch with error handling
  const user = await fetchUser(userId);
  if (!user) {
    throw new Error(`User not found: ${userId}`);
  }

  // Output validation
  if (!user.email || !user.name) {
    throw new Error('Invalid user data: missing required fields');
  }

  return user;
}
```

**Documentation** — after fixing, document:

1. What broke: Symptom description
2. Root cause: Why it happened
3. The fix: What changed
4. Prevention: How to avoid in future

Example:

```typescript
/**
 * Processes user data from API.
 *
 * Bug fix (2024-01-15): Added validation for missing email field.
 * Root cause: API sometimes returns partial user objects when
 * user hasn't completed onboarding.
 * Prevention: Always validate required fields before processing.
 */
```

</integration>

<escalation>

When to ask for help or escalate:

1. After 3 failed fix attempts — architecture may be wrong
2. No clear reproduction — need more context/access
3. External system issues — need vendor/team involvement
4. Security implications — need security expertise
5. Data corruption risks — need backup/recovery planning

</escalation>

<completion>

Before claiming "fixed", verify checklist:

- [ ] Root cause identified with evidence
- [ ] Failing test case created
- [ ] Fix implemented addressing root cause only
- [ ] Test now passes
- [ ] All existing tests still pass
- [ ] Manual reproduction steps no longer trigger bug
- [ ] No new warnings or errors introduced
- [ ] Root cause documented
- [ ] Prevention measures considered
- [ ] "Verify Fix" marked as completed

Remember: **Understanding the bug is more valuable than fixing it quickly.**

</completion>

<rules>

ALWAYS:
- Create "Collect Evidence" todo at session start
- Follow four-phase framework systematically
- Update todos when transitioning between phases
- Create failing test before implementing fix
- Test single hypothesis at a time
- Document root cause after fixing
- Mark "Verify Fix" complete only after all tests pass

NEVER:
- Propose fixes without understanding root cause
- Skip evidence gathering phase
- Test multiple hypotheses simultaneously
- Skip failing test case
- Fix symptoms instead of root cause
- Continue after 3 failed fixes without escalation
- Regress phases — add new tasks if more investigation needed

</rules>

<references>

- [reproduction.md](references/reproduction.md) — reproduction techniques
- [examples/](examples/) — debugging session examples
- [FORMATTING.md](../../shared/rules/FORMATTING.md) — formatting conventions

</references>
