---
name: implementation-verifier
description: Verify implementation completeness against spec and tasks. Use after implementation to ensure all tasks are complete, tests pass, and code meets quality standards before marking feature done.
---

# Implementation Verifier

Validate that implementation matches specification and all tasks are complete.

## When to Use
- After completing all tasks in tasks.md
- Before marking a feature as done
- When reviewing implementation quality

## Verification Process

1. **Load Checklist**
   - Review [implementation-verification-checklist.md](resources/implementation-verification-checklist.md)

2. **Gather Artifacts**
   - Read `amp-os/specs/[feature]/spec.md`
   - Read `amp-os/specs/[feature]/tasks.md`
   - Use `todo_read` to check task completion status

3. **Verify Each Category**
   - Task Completion
   - Test Coverage
   - Code Quality
   - Spec Alignment
   - Documentation

4. **Run Verification Commands**
   - Execute test suite
   - Run linter/type checker
   - Verify build succeeds

5. **Generate Report**
   - Save to `amp-os/specs/[feature]/verifications/final-verification.md`

## Output Format
```
## Implementation Verification: [Feature Name]

### Task Completion: X/Y tasks complete

### Test Results
- Tests: X passed, Y failed
- Coverage: X%

### Code Quality
- Linting: ✅/❌
- Type Check: ✅/❌
- Build: ✅/❌

### Verdict: COMPLETE / INCOMPLETE
```

## Amp Tools to Use
- `todo_read` - Check task status
- `Bash` - Run tests, lint, build
- `finder` - Locate implementation files
