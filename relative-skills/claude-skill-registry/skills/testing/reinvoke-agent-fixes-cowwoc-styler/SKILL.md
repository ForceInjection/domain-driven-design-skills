---
name: reinvoke-agent-fixes
description: Re-invoke agents to fix issues found during validation (style, tests, logic)
allowed-tools: Task, Bash, Read, Write
---

# Re-invoke Agent Fixes Skill

**Purpose**: Analyze validation failures and re-invoke appropriate stakeholder agents with scoped fix requirements.

**Performance**: Proper delegation of fixes, avoids main agent protocol violations

## When to Use This Skill

### ✅ Use reinvoke-agent-fixes When:

- Validation found issues (Checkstyle, PMD, test failures, logic errors)
- Need to determine which agent should fix
- Want to re-invoke agent with scoped fix requirements
- Iterating in VALIDATION state

### ❌ Do NOT Use When:

- Trivial compilation errors (main agent can fix)
- Infrastructure issues (module-info.java, pom.xml)
- Simple typos or imports
- No validation failures

## What This Skill Does

### 1. Analyzes Validation Failure

```bash
# Categorizes failure type:
- Style violations (Checkstyle, PMD) → formatter agent
- Test failures → tester agent (or engineer if quality issue)
- Logic errors → architect agent
- Compilation errors → main agent (if trivial)
```

### 2. Determines Responsible Agent

```bash
# Decision tree from CLAUDE.md:
- Style violations → Re-invoke formatter
- Test failures → Re-invoke tester (or engineer)
- Logic errors → Re-invoke architect
- Complex refactoring → Re-invoke appropriate agent
```

### 3. Creates Fix Requirements

```bash
# Scoped requirements document:
- Specific failures to fix
- Context from original implementation
- Constraints (don't break existing functionality)
- Validation criteria
```

### 4. Re-invokes Agent

```bash
# Uses Task tool with:
- Agent type (architect/tester/formatter/engineer)
- Scoped fix requirements
- Same worktree as original implementation
- IMPLEMENTATION mode (fixes are implementation)
```

### 5. Merges Fixes

```bash
# After agent completes:
- Merge agent branch to task branch
- Re-run validation
- Repeat if new issues found
```

## Usage

### Basic Fix Invocation

```bash
# After validation finds style violations
TASK_NAME="implement-formatter-api"
FAILURE_TYPE="style"
VIOLATIONS="$(cat checkstyle-violations.txt)"

/workspace/main/.claude/scripts/reinvoke-agent-fixes.sh \
  --task "$TASK_NAME" \
  --failure-type "$FAILURE_TYPE" \
  --violations "$VIOLATIONS"
```

### With Multiple Failure Types

```bash
# Multiple issues found
TASK_NAME="implement-formatter-api"

/workspace/main/.claude/scripts/reinvoke-agent-fixes.sh \
  --task "$TASK_NAME" \
  --style-violations "checkstyle.txt" \
  --test-failures "test-failures.txt" \
  --logic-errors "logic-issues.txt"
```

## Failure Type Mapping

### Style Violations → Formatter Agent

**Triggers**:
- Checkstyle violations
- PMD violations
- Missing JavaDoc
- Incorrect formatting
- Naming convention violations

**Fix Scope**:
```markdown
Fix the following style violations:

1. Missing JavaDoc on public method Foo.bar()
   File: src/main/java/Foo.java:15

2. Line too long (>120 chars)
   File: src/main/java/Bar.java:42

DO NOT change logic or tests. ONLY fix style/documentation issues.
```

### Test Failures → Tester Agent

**Triggers**:
- Unit test failures
- Integration test failures
- Test compilation errors
- Assertion failures
- Test coverage gaps

**Fix Scope**:
```markdown
Fix the following test failures:

1. TestFoo.testBar() - AssertionError
   Expected: 5, Actual: 3
   File: src/test/java/TestFoo.java:25

2. TestBaz.testEdgeCase() - NullPointerException
   File: src/test/java/TestBaz.java:40

DO NOT change production code unless fixing a logic bug.
Focus on making tests pass correctly.
```

### Test Failures → Engineer Agent

**Triggers** (quality issues):
- Code quality issues found via tests
- Refactoring needed for testability
- Duplication identified
- Complexity issues

**Fix Scope**:
```markdown
Improve code quality to fix test issues:

1. Foo.bar() has cyclomatic complexity of 15
   Refactor to reduce complexity

2. Duplicated code in Foo and Bar
   Extract common logic

Ensure tests pass after refactoring.
```

### Logic Errors → Architect Agent

**Triggers**:
- Incorrect behavior
- Design flaws
- Algorithm issues
- Performance problems
- Integration failures

**Fix Scope**:
```markdown
Fix the following logic errors:

1. ValidationEngine.validate() incorrectly handles null input
   Current: Throws NPE
   Expected: Returns validation error

2. RuleEngine.apply() performance O(n²) instead of O(n)
   Optimize algorithm

Ensure all tests still pass after fixes.
```

## Fix Requirements Document Format

### Standard Format

```markdown
# Fix Requirements: {task-name}

## Failure Summary
{Brief description of what failed}

## Specific Issues
1. {Issue 1 description}
   - Location: {file:line}
   - Current behavior: {what happens}
   - Expected behavior: {what should happen}

2. {Issue 2 description}
   - Location: {file:line}
   - Error: {error message}
   - Fix needed: {specific change}

## Constraints
- DO NOT modify files: {list files to preserve}
- DO NOT break existing tests
- Maintain API compatibility
- Follow existing patterns

## Validation Criteria
- All tests pass
- No Checkstyle violations
- No PMD violations
- Build succeeds
```

## Workflow Integration

### Validation-Fix Iteration Loop

```markdown
VALIDATION state: Run build/tests/checks
  ↓
Issues found
  ↓
[reinvoke-agent-fixes skill] ← THIS SKILL
  ↓
Analyze failure type
  ↓
Determine responsible agent
  ↓
Create fix requirements
  ↓
Re-invoke agent with fixes
  ↓
Agent fixes issues
  ↓
Merge fixes to task branch
  ↓
Re-run validation
  ↓
If issues remain: Repeat loop
If all pass: Continue to AWAITING_USER_APPROVAL
```

## Output Format

Script returns JSON:

```json
{
  "status": "success",
  "message": "Agent re-invoked for fixes",
  "task_name": "implement-formatter-api",
  "failure_type": "style",
  "agent_invoked": "formatter",
  "fix_requirements_file": "/workspace/tasks/implement-formatter-api/fix-requirements-formatter.md",
  "agent_branch": "implement-formatter-api-formatter",
  "issues_count": 5,
  "timestamp": "2025-11-11T12:34:56-05:00"
}
```

## Main Agent Fix Boundaries

### Main Agent MAY Fix (No Agent Needed)

**Compilation Errors**:
- Missing imports
- Incorrect package paths
- Type resolution failures
- Simple syntax errors

**Infrastructure**:
- module-info.java updates
- pom.xml dependency fixes
- build.gradle configuration

**Trivial Fixes**:
- Missing semicolons
- Typos in identifiers
- Whitespace issues

### Main Agent MUST Re-invoke Agent

**Style Violations**:
- ❌ Main agent fix
- ✅ Re-invoke formatter

**Test Failures**:
- ❌ Main agent fix
- ✅ Re-invoke tester/engineer

**Logic Errors**:
- ❌ Main agent fix
- ✅ Re-invoke architect

**Complex Refactoring**:
- ❌ Main agent implement
- ✅ Re-invoke appropriate agent

## Decision Criterion

**Question**: "Can this fix be applied mechanically without changing logic?"

- **YES** → Main agent may fix directly
- **NO** → Re-invoke agent

## Safety Features

### Precondition Validation

- ✅ Verifies task exists
- ✅ Checks task in VALIDATION state
- ✅ Confirms validation failures present
- ✅ Validates agent worktree exists

### Fix Scoping

- ✅ Creates focused fix requirements
- ✅ Constrains scope (don't break existing)
- ✅ Specifies validation criteria
- ✅ Preserves context from original work

### Error Handling

On any error:
- Reports which validation check failed
- Lists specific failures by type
- Does not invoke wrong agent
- Returns JSON with error details

## Related Skills

- **merge-agent-work**: Merges agent fixes after completion
- **checkpoint-approval**: Not needed for fixes (iterative work)
- **synthesize-plan**: Initial planning (this is iteration)

## Troubleshooting

### Error: "Cannot determine responsible agent"

```bash
# Ambiguous failure type
# Options:
1. Categorize manually based on nature
2. Start with most likely agent (usually formatter for style)
3. Invoke multiple agents if needed
4. Ask user which agent should fix
```

### Error: "Agent worktree not found"

```bash
# Agent worktree removed prematurely
# Re-create:
git worktree add /workspace/tasks/{task}/agents/{agent}/code \
  -b {task}-{agent}

# Then retry fix invocation
```

### Agent Fixes Break Other Things

```bash
# Fix introduced new failures
# Options:
1. Re-invoke same agent with additional constraints
2. Invoke different agent to fix new issues
3. Rollback agent fix and try different approach
```

### Infinite Loop (Fixes Keep Failing)

```bash
# Never converges to passing validation
# Possible causes:
1. Contradictory requirements (impossible to satisfy both)
2. Agent misunderstanding requirements
3. Tests themselves incorrect

# Solutions:
1. Manual investigation of root cause
2. Simplify requirements
3. Fix tests if they're wrong
4. Escalate to user for guidance
```

## Common Fix Patterns

### Pattern 1: Style-Only Fixes

```markdown
Validation: Checkstyle failures
Agent: formatter
Scope: Add missing JavaDoc, fix line lengths
Result: Tests still pass, style clean
```

### Pattern 2: Test Fixes

```markdown
Validation: 3 test failures
Agent: tester
Scope: Fix assertions, handle edge cases
Result: All tests pass, no logic changes
```

### Pattern 3: Logic + Tests

```markdown
Validation: Logic error found by tests
Agent 1: architect (fix logic)
Agent 2: tester (update tests for new logic)
Result: Correct behavior, tests updated
```

### Pattern 4: Refactoring for Quality

```markdown
Validation: Complexity too high
Agent: engineer
Scope: Refactor to reduce complexity
Result: Same behavior, better quality
```

## Implementation Notes

The reinvoke-agent-fixes script performs:

1. **Analysis Phase**
   - Parse validation output
   - Categorize failures by type
   - Count issues per category
   - Determine severity

2. **Agent Selection Phase**
   - Apply decision tree logic
   - Select responsible agent(s)
   - Validate agent worktree exists
   - Check agent availability

3. **Requirements Creation Phase**
   - Extract specific failures
   - Format fix requirements
   - Add context from original work
   - Specify constraints
   - Define validation criteria

4. **Invocation Phase**
   - Prepare Task tool parameters
   - Set IMPLEMENTATION mode
   - Specify agent worktree
   - Include fix requirements
   - Invoke agent

5. **Monitoring Phase**
   - Wait for agent completion
   - Check agent status
   - Verify fixes applied
   - Report to main agent

6. **Integration Phase**
   - Merge agent fixes to task branch
   - Re-run validation
   - Report results
   - Determine if iteration needed
