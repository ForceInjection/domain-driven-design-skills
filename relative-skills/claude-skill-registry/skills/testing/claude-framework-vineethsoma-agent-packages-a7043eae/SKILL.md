---
name: claude-framework
description: CLAUDE Framework coding standards for code quality, naming conventions, error handling, security, testing, database, and logging
---

# CLAUDE Framework

Production-ready coding standards for building maintainable, secure, and well-tested software.

---

## Code Quality (C-1 to C-5)

- **C-1**: Single Responsibility Principle - each function/class does ONE thing
- **C-2**: DRY (Don't Repeat Yourself) - no code duplication
- **C-3**: KISS (Keep It Simple) - simplicity over complexity
- **C-4**: Functions maximum 20 lines (split if longer)
- **C-5**: Prefer composition over inheritance

---

## Naming Conventions (N-1 to N-6)

- **N-1**: Use descriptive names that explain intent
- **N-2**: Functions = verbs: `calculateTotal()`, `validateUserInput()`
- **N-3**: Variables = nouns: `userAccount`, `totalPrice`
- **N-4**: Booleans start with is/has/can/should: `isValid`, `hasPermission`
- **N-5**: Constants in UPPER_SNAKE_CASE: `MAX_RETRY_ATTEMPTS`
- **N-6**: Avoid abbreviations: use `user` not `usr`

---

## Error Handling (E-1 to E-5)

- **E-1**: Handle ALL possible error scenarios
- **E-2**: Use specific error types/messages
- **E-3**: Log errors with context information
- **E-4**: NEVER allow silent failures
- **E-5**: Fail fast - validate inputs early

---

## Security (SEC-1 to SEC-5)

- **SEC-1**: Validate ALL inputs at system boundaries
- **SEC-2**: Sanitize output data
- **SEC-3**: Use environment variables for secrets
- **SEC-4**: Never hardcode sensitive information
- **SEC-5**: Implement proper authentication and authorization

---

## Testing Standards (T-1 to T-5)

- **T-1**: Write failing test first, then implement (TDD)
- **T-2**: Minimum 80% code coverage for new code
- **T-3**: Test happy path, error scenarios, and edge cases
- **T-4**: Descriptive test names explaining what is tested
- **T-5**: Arrange-Act-Assert pattern clearly separated

---

## Test Quality (TQ-1 to TQ-5)

- **TQ-1**: Use realistic test data, no magic numbers
- **TQ-2**: One assertion per test where possible
- **TQ-3**: Ensure test isolation
- **TQ-4**: Tests must be deterministic (no flaky tests)
- **TQ-5**: Tests should run fast (mock external dependencies)

---

## Database (DB-1 to DB-4)

- **DB-1**: Use transactions for multi-step operations
- **DB-2**: Optimize queries (avoid N+1 problems)
- **DB-3**: Document indexing strategy
- **DB-4**: Create migration and rollback scripts

---

## Logging (L-1 to L-4)

- **L-1**: Structured logging (JSON format)
- **L-2**: NEVER log sensitive data
- **L-3**: Include correlation IDs for tracing
- **L-4**: Use appropriate log levels: DEBUG, INFO, WARN, ERROR

---

## Code Structure Requirements

- Organize imports clearly (stdlib, third-party, local)
- Define constants at module level
- Use pure functions where possible
- Implement proper error boundaries
- Include comprehensive JSDoc/comments for complex logic
- Follow consistent indentation (2 or 4 spaces)
- Maximum 120 characters per line

---

## Quality Assurance Checklist

Before delivering code, verify:

- ✅ Functions under 20 lines
- ✅ Single responsibility maintained
- ✅ No code duplication
- ✅ Clear naming conventions followed
- ✅ All errors handled with specific types
- ✅ Input validation implemented
- ✅ Output sanitization applied
- ✅ Tests written and passing (80%+ coverage)
- ✅ Security considerations addressed
- ✅ Performance implications considered
- ✅ Documentation updated
