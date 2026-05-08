---
name: testing-standards
description: Testing conventions, test runner configurations, coverage requirements, and failure interpretation for the Klassenzeit monorepo.
---

# Testing Standards

## Test Runner Commands

### Backend (Spring Boot / JUnit)
```bash
make test-backend           # Run all backend tests
./gradlew test              # Direct Gradle command
./gradlew test --tests "ClassName"  # Run specific test class
```

### Frontend (Vitest / React Testing Library)
```bash
make test-frontend          # Run all frontend tests
npm run test                # Run tests once
npm run test:watch          # Watch mode
npm run test:coverage       # With coverage report
npm run test:ui             # Vitest UI
```

### E2E (Playwright)
```bash
make test-e2e               # Run all E2E tests
npm run test:e2e            # Direct Playwright run
npm run test:e2e:ui         # Playwright UI mode
npm run test:api            # API integration tests only
```

## Coverage Reports

| Type | Location | Minimum Threshold |
|------|----------|-------------------|
| Backend | `backend/build/reports/jacoco/test/html/index.html` | 80% line coverage |
| Frontend | `frontend/coverage/index.html` | 80% line coverage |
| E2E | `e2e/playwright-report/index.html` | Critical paths covered |

## Coverage Requirements

- **New code**: Minimum 80% line coverage
- **Public API functions**: Must have unit tests
- **Critical user flows**: Must have E2E tests
- **Edge cases**: Error scenarios must be tested

## Interpreting Failures

### Priority Order
1. Check if failure is flaky (re-run once with same seed)
2. Look for recent changes to test file or tested module
3. Check for environment issues (missing fixtures, DB state, port conflicts)
4. Inspect assertion messages carefully for root cause

### Common Failure Patterns

**Backend**
- `NullPointerException`: Missing mock setup or fixture data
- `ConstraintViolationException`: Invalid test data for entity constraints
- `LazyInitializationException`: Missing `@Transactional` or eager fetch

**Frontend**
- `Unable to find element`: Component not rendered, wrong query, async timing
- `act() warning`: State update outside test act boundary
- `Mock not called`: Wrong mock path or missing mock setup

**E2E**
- `Timeout`: Slow page load, element not visible, wrong selector
- `Element not attached`: DOM changed between find and action
- `Navigation error`: Auth redirect, missing route, CORS issue

## Test File Conventions

- Backend: `src/test/java/**/*Test.java`
- Frontend: `src/**/*.test.tsx` (co-located with source)
- E2E: `e2e/tests/**/*.spec.ts`

## Pre-Test Checklist

1. Services running (`make services-up`)
2. Database migrated (Flyway runs on backend startup)
3. Environment variables set (`.env` files in place)
4. Dependencies installed (`npm install` in frontend/e2e)
