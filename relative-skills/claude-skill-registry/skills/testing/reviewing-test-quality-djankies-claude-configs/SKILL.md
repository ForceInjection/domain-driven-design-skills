---
name: reviewing-test-quality
description: Review React 19 test quality including coverage, patterns, and React 19 API testing. Use when reviewing tests or test coverage.
review: true
allowed-tools: Read, Grep
version: 1.0.0
---

# Review: Test Quality

For Vitest configuration validation (pool options, coverage setup, deprecated patterns), see `vitest-4/skills/reviewing-vitest-config/SKILL.md`.

## Checklist

### Test Coverage
- [ ] Components have tests for user interactions
- [ ] Forms test both success and error paths
- [ ] Server Actions tested in isolation
- [ ] Custom hooks tested with `renderHook`
- [ ] Edge cases covered (empty states, errors, loading)

### React 19 APIs
- [ ] Forms using `useActionState` have tests
- [ ] `useOptimistic` updates tested for immediate feedback
- [ ] `useFormStatus` tested within form component context
- [ ] Server Actions tested with mocked auth/database
- [ ] `use()` hook tested with Promises and Context

### Testing Patterns
- [ ] Using `@testing-library/react` and `@testing-library/user-event`
- [ ] Queries prefer accessibility (`getByRole`, `getByLabelText`)
- [ ] `waitFor` used for async assertions
- [ ] Mocking external dependencies (API, database)
- [ ] Tests are isolated and don't depend on each other

### Anti-Patterns
- [ ] ❌ Testing implementation details (internal state, methods)
- [ ] ❌ Querying by class names or data-testid when role available
- [ ] ❌ Not waiting for async updates (`waitFor`)
- [ ] ❌ Testing components without user interactions
- [ ] ❌ Missing error case tests

### Server Action Testing
- [ ] Server Actions tested as functions (not through UI)
- [ ] Input validation tested
- [ ] Authentication/authorization tested
- [ ] Database operations mocked
- [ ] Error handling tested

For typed test fixtures and mocks, use the TYPES-generics skill from the typescript plugin.

For comprehensive testing patterns, see: `research/react-19-comprehensive.md`.
