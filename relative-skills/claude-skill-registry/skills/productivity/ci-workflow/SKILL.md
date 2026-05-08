---
name: ci-workflow
description: Run comprehensive CI checks before committing changes. Use when the user asks to run CI, run quality checks, validate code quality, or before finishing any task that involves code changes.
---

# CI Workflow Skill

This skill guides you through running comprehensive CI quality checks before committing code changes.

## When to Use This Skill

Activate this skill when:

- User explicitly asks to "run CI" or "run quality checks"
- Before finishing any task that involves code changes
- After making significant code modifications
- Before creating a pull request
- When validating code quality

## Workflow Steps

### 1. Run Comprehensive CI Command

Execute the primary CI command that runs all quality checks:

```bash
make ci
```

**Expected Outcome**: The command MUST output "✅ CI checks successfully passed!" at the end.

### 2. Monitor CI Execution

The `make ci` command runs these checks in sequence:

1. Composer validation
2. Security vulnerability analysis
3. Code style fixes (PHP CS Fixer)
4. Static analysis (Psalm)
5. Security taint analysis (Psalm)
6. Code quality analysis (PHPInsights)
7. Architecture validation (Deptrac)
8. Unit tests
9. Integration tests
10. End-to-end tests (Behat)
11. Mutation testing (Infection)

### 3. Handle Failures

**If CI fails** (output shows "❌ CI checks failed:"):

1. **Identify the failing check** from the error output
2. **Fix the specific issue**:

   - Code style: Review PHP CS Fixer suggestions
   - Static analysis: Fix Psalm type errors
   - Quality issues: Address PHPInsights warnings (reduce complexity, fix architecture)
   - Test failures: Debug and fix failing tests
   - Mutation testing: Add missing test cases or refactor for testability

3. **Run individual check** to verify fix:

   ```bash
   make phpcsfixer    # For code style issues
   make psalm         # For static analysis errors
   make phpinsights   # For quality issues
   make unit-tests    # For unit test failures
   make infection     # For mutation testing issues
   ```

4. **Re-run full CI** after fixes:
   ```bash
   make ci
   ```

### 4. Iterate Until Success

**CRITICAL**: Keep fixing issues and re-running `make ci` until you see:

```text
✅ CI checks successfully passed!
```

**DO NOT finish the task** until this success message appears.

### 5. Quality Standards Protection

**NEVER decrease these quality thresholds**:

- PHPInsights min-quality: 100% (src/), 95% (tests/)
- PHPInsights min-complexity: 93% (src/), 95% (tests/)
- PHPInsights min-architecture: 100% (src/), 90% (tests/)
- PHPInsights min-style: 100% (src/), 95% (tests/)
- Mutation testing MSI: 100%
- Test coverage: 100%

If quality checks fail, **fix the code**, don't lower the standards.

## Common Issues and Solutions

### High Cyclomatic Complexity

**Problem**: PHPInsights reports complexity score too low
**Solution**:

1. Run `make phpmd` to identify complex methods
2. Refactor by extracting methods or using strategy pattern
3. Keep methods under 5 complexity score

### Escaped Mutants

**Problem**: Infection finds untested code mutations
**Solution**:

1. Review the mutation diff in infection output
2. Add specific test cases for edge cases
3. Consider refactoring for better testability (injectable time, extracted methods)

### Architecture Violations

**Problem**: Deptrac reports layer violations
**Solution**:

1. Review the dependency rule violation
2. Move code to appropriate layer
3. Follow hexagonal architecture principles

## Success Criteria

- Command outputs "✅ CI checks successfully passed!"
- All quality metrics meet or exceed thresholds
- Zero test failures
- Zero escaped mutants
- Zero architecture violations
