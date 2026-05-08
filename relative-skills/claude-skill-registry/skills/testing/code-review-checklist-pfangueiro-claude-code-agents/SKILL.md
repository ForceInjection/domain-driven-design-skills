---
name: code-review-checklist
description: Systematic code review guidelines and checklist. Use this skill when reviewing code, conducting pull request reviews, or establishing code quality standards. Provides comprehensive review criteria covering functionality, design, testing, security, and documentation. Complements the code-quality agent.
---

# Code Review Checklist

## Overview

This skill provides a systematic approach to code reviews, ensuring consistent quality standards across your codebase. Use it to conduct thorough, constructive code reviews that improve code quality and team knowledge sharing.

## When to Use This Skill

- Reviewing pull requests
- Conducting pair programming sessions
- Establishing code review standards for your team
- Self-reviewing code before submitting
- Mentoring junior developers on code quality
- Complementing the **code-quality agent** for comprehensive reviews

## Core Review Categories

### 1. Functionality & Correctness

**Does the code work as intended?**

- [ ] Code accomplishes the intended purpose
- [ ] Edge cases are handled appropriately
- [ ] Error handling is comprehensive
- [ ] Input validation is present and correct
- [ ] Boundary conditions are tested
- [ ] No obvious bugs or logic errors
- [ ] Code handles null/undefined/empty values safely

**Questions to Ask:**
- What happens if this API call fails?
- Are all user inputs validated?
- What if the array is empty?
- Are there any race conditions?

### 2. Design & Architecture

**Is the code well-designed?**

- [ ] Code follows SOLID principles
- [ ] Appropriate design patterns used
- [ ] Separation of concerns is clear
- [ ] No tight coupling between components
- [ ] Abstractions are at the right level
- [ ] Code is modular and reusable
- [ ] No circular dependencies

**Red Flags:**
- God classes (doing too much)
- Excessive method parameters (>3-4)
- Deep nesting (>3 levels)
- Duplicate code (DRY violation)
- Overly clever code (premature optimization)

### 3. Readability & Maintainability

**Can others understand and maintain this code?**

- [ ] Code is self-documenting
- [ ] Variable/function names are descriptive
- [ ] Functions are single-purpose and focused
- [ ] Code follows project style guide
- [ ] Complex logic has explanatory comments
- [ ] Magic numbers are named constants
- [ ] Code structure is logical and intuitive

**Naming Conventions:**
```javascript
// BAD
function d(a, b) { return a + b; }
const x = 42;

// GOOD
function calculateTotalPrice(basePrice, taxRate) {
  return basePrice * (1 + taxRate);
}
const MAX_RETRY_ATTEMPTS = 3;
```

### 4. Testing

**Is the code adequately tested?**

- [ ] Unit tests cover new functionality
- [ ] Edge cases are tested
- [ ] Negative test cases included
- [ ] Tests are readable and maintainable
- [ ] Test names describe what they test
- [ ] No flaky tests
- [ ] Integration tests for complex interactions
- [ ] Test coverage meets standards (typically >80%)

**Test Quality Checks:**
- Tests follow AAA pattern (Arrange, Act, Assert)
- Mocks/stubs are used appropriately
- Tests are independent (no shared state)
- Test data is meaningful, not random

### 5. Security

**Is the code secure?**

- [ ] No sensitive data in code or logs
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS vulnerabilities addressed
- [ ] CSRF protection implemented
- [ ] Authentication/authorization checks present
- [ ] Secrets stored securely (environment variables, vaults)
- [ ] Input sanitization in place
- [ ] Rate limiting for APIs

**OWASP Top 10 Considerations:**
1. Injection flaws
2. Broken authentication
3. Sensitive data exposure
4. XML external entities (XXE)
5. Broken access control
6. Security misconfiguration
7. Cross-site scripting (XSS)
8. Insecure deserialization
9. Using components with known vulnerabilities
10. Insufficient logging & monitoring

### 6. Performance

**Will this code perform well at scale?**

- [ ] No obvious performance bottlenecks
- [ ] Database queries are optimized
- [ ] Indexes are used appropriately
- [ ] No N+1 query problems
- [ ] Appropriate data structures chosen
- [ ] Caching used where beneficial
- [ ] Large datasets handled efficiently
- [ ] Async operations used where appropriate

**Performance Anti-Patterns:**
- Synchronous I/O in loops
- Missing database indexes
- Loading entire datasets into memory
- Unnecessary object creation
- Inefficient algorithms (O(n²) where O(n) possible)

### 7. Documentation

**Is the code adequately documented?**

- [ ] Complex algorithms explained
- [ ] Public APIs documented
- [ ] README updated if needed
- [ ] CHANGELOG updated
- [ ] Migration guide provided (if breaking changes)
- [ ] Code comments explain "why", not "what"
- [ ] Docstrings/JSDoc for functions
- [ ] Architecture decisions recorded (ADRs)

**Good Comment Example:**
```python
# GOOD: Explains WHY
# Use exponential backoff to avoid overwhelming the API
# after transient failures (recommended by vendor)
retry_delay = base_delay * (2 ** attempt)

# BAD: Explains WHAT (obvious from code)
# Set retry_delay to base_delay times 2 to the power of attempt
retry_delay = base_delay * (2 ** attempt)
```

### 8. Dependencies & Libraries

**Are dependencies managed properly?**

- [ ] Dependencies are up-to-date
- [ ] No known security vulnerabilities
- [ ] Dependency versions are pinned
- [ ] License compatibility checked
- [ ] Dependencies are actually needed
- [ ] Bundle size impact considered
- [ ] Dependency documentation reviewed

### 9. Error Handling & Logging

**Are errors handled gracefully?**

- [ ] Errors are caught and handled appropriately
- [ ] Error messages are user-friendly
- [ ] Errors are logged with context
- [ ] No swallowed exceptions
- [ ] Proper logging levels used (DEBUG/INFO/WARN/ERROR)
- [ ] PII not logged
- [ ] Stack traces available for debugging

**Logging Best Practices:**
```javascript
// GOOD: Structured logging with context
logger.error('Payment processing failed', {
  orderId: order.id,
  userId: user.id,
  amount: payment.amount,
  errorCode: error.code
});

// BAD: Generic error logging
console.log('Error');
```

### 10. Code Style & Consistency

**Does the code follow team standards?**

- [ ] Linter passes
- [ ] Formatter applied
- [ ] Naming conventions followed
- [ ] File organization consistent
- [ ] Import statements organized
- [ ] No commented-out code
- [ ] No debug statements (console.log, etc.)

## Review Process Guidelines

### Before You Review

1. **Understand the context**
   - Read the PR description
   - Review linked issues/tickets
   - Understand the "why" behind the change

2. **Set aside time**
   - Don't rush reviews
   - Block dedicated time for thorough analysis
   - Review in multiple sessions if large PR

3. **Check CI/CD**
   - Ensure tests pass
   - Check build succeeds
   - Review test coverage reports

### During Review

1. **Be constructive**
   - Praise good code
   - Suggest, don't demand
   - Explain your reasoning
   - Offer alternatives

2. **Use review labels**
   - **Nitpick**: Minor suggestion, not blocking
   - **Question**: Seeking clarification
   - **Suggestion**: Proposed improvement
   - **Issue**: Needs to be addressed before merge

3. **Focus on what matters**
   - Prioritize functionality and security
   - Don't bike-shed over style (use linters)
   - Consider technical debt trade-offs

### Giving Feedback

**Good Feedback Examples:**

```
✅ "Great use of the factory pattern here! This makes the code much
more testable. Consider extracting the validation logic into a
separate validator class for even better separation of concerns."

✅ "Question: What happens if the API returns a 429 (rate limit)?
Should we implement exponential backoff here?"

✅ "Suggestion: Instead of nested if statements, consider using
early returns to reduce complexity:
[code example]"
```

**Avoid:**

```
❌ "This is wrong."
❌ "Why didn't you use X pattern?"
❌ "This code is terrible."
❌ Rewriting entire sections without explanation
```

### Review Size Guidelines

**Small PR (< 200 lines):**
- Ideal size
- 15-30 minutes to review
- Easy to understand and test

**Medium PR (200-500 lines):**
- Acceptable
- 30-60 minutes to review
- May need to be split across sessions

**Large PR (> 500 lines):**
- Request split into smaller PRs
- Difficult to review thoroughly
- Higher chance of bugs slipping through

## Self-Review Checklist

Before submitting your PR, review your own code:

- [ ] Re-read your changes with fresh eyes
- [ ] Run tests locally
- [ ] Check test coverage
- [ ] Remove debug statements
- [ ] Update documentation
- [ ] Add descriptive commit messages
- [ ] Ensure PR description is clear
- [ ] Consider reviewer's perspective

## Team-Specific Considerations

Customize this checklist for your team:

- **Technology-specific checks** (React hooks rules, async/await patterns)
- **Business logic validation** (pricing calculations, data transformations)
- **Compliance requirements** (GDPR, HIPAA, SOX)
- **Company coding standards** (internal style guides)
- **Performance benchmarks** (API response time < 200ms)

## Quick Reference: Review Commands

**Inline Comments:**
- Be specific: Reference line numbers
- Provide examples: Show better alternatives
- Link to docs: Reference style guides

**Approval Criteria:**
- All tests pass
- No security vulnerabilities
- Meets acceptance criteria
- Documentation updated
- Code quality standards met

**Request Changes When:**
- Bugs or logic errors present
- Security issues found
- Tests are missing or inadequate
- Breaks existing functionality
- Violates architectural principles

## Resources

For deeper dives, see:
- `.claude/skills/README.md` - Skills system overview
- OWASP guidelines for security reviews
- Google's Code Review Developer Guide
- Team-specific style guides
