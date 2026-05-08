---
name: code-review-standards
description: Comprehensive code review standards covering security, quality, performance, testing, and documentation. Includes checklists, common issues, and best practices for thorough code reviews.
triggers:
  - "code review standards"
  - "review checklist"
  - "security review"
  - "code quality review"
  - "performance review"
  - "what to look for in code review"
  - "code review best practices"
  - "review criteria"
  - "quality gates"
---

# Code Review Standards

Master comprehensive code review practices that catch critical issues before they reach production. This skill covers security vulnerabilities, code quality metrics, performance optimization, testing requirements, and documentation standards to ensure every pull request meets professional engineering standards.

## Introduction

Code review is your last line of defense against bugs, security vulnerabilities, and technical debt. A thorough review process prevents production incidents, maintains code quality, and transfers knowledge across the team.

**Review Philosophy**:
- **Behavior over implementation** - Focus on what the code does, not just how it's written
- **Security-first mindset** - Always check for vulnerabilities before code quality
- **Constructive feedback** - Explain the "why" behind every comment
- **Question assumptions** - If something isn't clear, ask before approving

**When to Review vs. Auto-Approve**:
- ✅ **Always review**: Security changes, authentication, data handling, database migrations, API changes
- ✅ **Always review**: Complex business logic, performance-critical code, public APIs
- ⚠️ **Light review**: Documentation updates, simple typo fixes, dependency updates (check changelogs)
- ❌ **Never auto-approve**: Anything you don't understand - ask questions instead

---

## Security Review Checklist

Security vulnerabilities are the highest priority in code review. Check these categories systematically.

**For comprehensive security review guidance with examples, see**:
- [references/security-review.md](references/security-review.md) - OWASP Top 10 deep dive with vulnerability examples
- [examples/security-issues.md](examples/security-issues.md) - Real-world security vulnerabilities with fixes

### Authentication & Authorization Quick Check

**What to Check**:
- JWT validation and token expiry handling
- Session management and secure cookie configuration
- RBAC (Role-Based Access Control) enforcement
- Password hashing and credential storage (bcrypt, argon2)
- OAuth/SSO implementation correctness

**Review Questions**:
- Are all protected routes behind authentication middleware?
- Does the code check user permissions before sensitive operations?
- Are tokens validated on every request (not just cached)?
- Is password reset flow secure (tokens, expiry, rate limiting)?
- Are credentials never hardcoded in code?

### Input Validation & Sanitization Quick Check

**What to Check**:
- SQL injection prevention (parameterized queries only)
- XSS prevention (proper output encoding)
- Command injection prevention (use execFile, not shell commands)
- Path traversal prevention
- File upload validation (type, size, content scanning)

**Review Questions**:
- Are all database queries parameterized (no string concatenation)?
- Is user input validated against a whitelist (not just blacklist)?
- Are file uploads restricted by type, size, and scanned for malware?
- Is output properly escaped for the context (HTML, URL, JS)?
- Are shell commands avoided or properly sanitized?

### Data Protection Quick Check

**What to Check**:
- Encryption at rest (sensitive data in database)
- Encryption in transit (HTTPS, TLS)
- PII (Personally Identifiable Information) handling
- Secrets management (environment variables, never hardcoded)
- Data retention and deletion policies

**Review Questions**:
- Is sensitive data encrypted both at rest and in transit?
- Are PII fields properly identified and protected (GDPR compliance)?
- Are secrets loaded from environment variables (never committed to git)?
- Does the code comply with data retention policies?
- Is sensitive data never logged?

### OWASP Top 10 Quick Reference

For comprehensive security review, verify the code doesn't have these OWASP vulnerabilities:

1. **Broken Access Control** - Check authorization on every protected resource
2. **Cryptographic Failures** - Verify strong encryption, no weak algorithms
3. **Injection** - SQL, NoSQL, command, LDAP injection prevention
4. **Insecure Design** - Threat modeling, secure architecture
5. **Security Misconfiguration** - Check default configs, error messages don't leak info
6. **Vulnerable Components** - Check dependency versions, known CVEs
7. **Authentication Failures** - MFA, credential stuffing prevention, weak password policies
8. **Software/Data Integrity** - CI/CD security, unsigned packages
9. **Logging/Monitoring Failures** - Security events logged, alerting configured
10. **SSRF** - Server-Side Request Forgery prevention

**See [references/security-review.md](references/security-review.md) for detailed examples and remediation patterns.**

---

## Code Quality Standards

Beyond security, code must be maintainable, readable, and follow best practices.

### Complexity Metrics

**Cyclomatic Complexity**: Aim for functions with complexity < 10. High complexity (>15) is a code smell.

❌ **Bad**: High complexity (15+ branches)
```typescript
function processOrder(order, user, inventory) {
  if (order.type === 'standard') {
    if (user.isPremium) {
      if (inventory.stock > 0) {
        if (order.quantity < inventory.stock) {
          if (user.paymentMethod === 'card') {
            // ... 10 more nested conditions
          }
        }
      }
    }
  }
  // Complexity: 20+, impossible to test
}
```

✅ **Good**: Extracted functions (complexity < 10 each)
```typescript
function processOrder(order, user, inventory) {
  validateOrder(order);
  checkInventory(order, inventory);
  processPayment(order, user);
  updateStock(order, inventory);
}

function validateOrder(order) {
  if (!order.type || !order.quantity) {
    throw new ValidationError("Invalid order");
  }
}
// Each function: complexity 3-5, easily testable
```

**Review Questions**:
- Are functions short and focused (< 50 lines ideal)?
- Is nesting depth reasonable (< 4 levels)?
- Can complex functions be broken into smaller ones?
- Are early returns used to reduce nesting?

### Code Smells

**Common Smells to Flag**:

❌ **Duplicate Code**: Same logic repeated in multiple places
```typescript
// In component A
const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

// In component B
const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
```

✅ **Good**: Extracted to shared utility
```typescript
// utils/cart.ts
export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
```

❌ **Magic Numbers**: Unexplained constants
```typescript
if (user.age > 65) { ... } // Why 65?
setTimeout(pollAPI, 5000); // Why 5 seconds?
```

✅ **Good**: Named constants
```typescript
const RETIREMENT_AGE = 65;
const API_POLL_INTERVAL_MS = 5000;

if (user.age > RETIREMENT_AGE) { ... }
setTimeout(pollAPI, API_POLL_INTERVAL_MS);
```

❌ **Long Parameter Lists**: > 4 parameters is a smell
```typescript
function createUser(name, email, password, age, country, city, zipCode) { ... }
```

✅ **Good**: Object parameter
```typescript
function createUser({ name, email, password, profile }: CreateUserParams) { ... }
```

❌ **God Objects/Functions**: Classes/functions doing too much
```typescript
class UserService {
  authenticate() { ... }
  sendEmail() { ... }
  processPayment() { ... }
  generateReport() { ... } // Too many responsibilities
}
```

✅ **Good**: Single Responsibility Principle
```typescript
class AuthService { authenticate() { ... } }
class EmailService { send() { ... } }
class PaymentService { process() { ... } }
class ReportService { generate() { ... } }
```

### Naming Conventions

**Variables and Functions**:
- Use descriptive names (avoid abbreviations unless universally known)
- Boolean variables should be questions: `isValid`, `hasPermission`, `canEdit`
- Functions should be verbs: `getUserById`, `calculateTotal`, `validateEmail`

❌ **Bad**: Vague names
```typescript
const d = new Date(); // What does 'd' mean?
function proc(x) { ... } // What is proc? What is x?
const temp = fetchData(); // Temporary for what?
```

✅ **Good**: Descriptive names
```typescript
const currentDate = new Date();
function processPayment(order) { ... }
const userData = await fetchUserProfile();
```

### Code Organization (SOLID Principles)

**Single Responsibility**: Each class/function should have one reason to change

**Open/Closed**: Open for extension, closed for modification (use composition/inheritance)

**Liskov Substitution**: Subtypes should be substitutable for base types

**Interface Segregation**: Many specific interfaces > one general interface

**Dependency Inversion**: Depend on abstractions, not concretions

**Review Questions**:
- Does each function/class have a single, clear purpose?
- Can the design be extended without modifying existing code?
- Are dependencies injected (not hardcoded)?

See [examples/code-quality-examples.md](examples/code-quality-examples.md) for 15-20 refactoring examples.

---

## Performance Considerations

Look for performance issues that could cause production problems under load.

### Database Optimization

**N+1 Query Problem**: Most common performance issue

❌ **Bad**: N+1 queries (1 for posts + N for authors)
```typescript
const posts = await db.query('SELECT * FROM posts');
for (const post of posts) {
  post.author = await db.query('SELECT * FROM users WHERE id = ?', [post.authorId]);
  // This executes N additional queries!
}
```

✅ **Good**: Single query with JOIN
```typescript
const posts = await db.query(`
  SELECT p.*, u.name as authorName, u.email as authorEmail
  FROM posts p
  JOIN users u ON p.authorId = u.id
`);
```

**Missing Indexes**: Check for queries on unindexed columns

❌ **Bad**: Full table scan
```sql
SELECT * FROM orders WHERE customer_email = 'user@example.com';
-- If email isn't indexed, this scans all rows
```

✅ **Good**: Indexed column
```sql
CREATE INDEX idx_orders_email ON orders(customer_email);
SELECT * FROM orders WHERE customer_email = 'user@example.com';
```

**Large Result Sets**: Always paginate

❌ **Bad**: Returning all results
```typescript
const allUsers = await db.query('SELECT * FROM users'); // Could be millions!
```

✅ **Good**: Pagination
```typescript
const users = await db.query(
  'SELECT * FROM users LIMIT ? OFFSET ?',
  [pageSize, page * pageSize]
);
```

See [references/performance-review.md](references/performance-review.md) for comprehensive database optimization patterns.

### Frontend Performance

**Unnecessary Re-renders**:

❌ **Bad**: Creating new objects in render
```typescript
function Component() {
  const options = { key: 'value' }; // New object every render!
  return <Child options={options} />; // Causes Child to re-render
}
```

✅ **Good**: Memoization
```typescript
function Component() {
  const options = useMemo(() => ({ key: 'value' }), []);
  return <Child options={options} />;
}
```

**Bundle Size**: Check for large dependencies

❌ **Bad**: Importing entire libraries
```typescript
import _ from 'lodash'; // 70KB+ for one function
import moment from 'moment'; // 68KB for date formatting
```

✅ **Good**: Tree-shakeable imports
```typescript
import debounce from 'lodash/debounce'; // 2KB
import { formatDistance } from 'date-fns'; // 2-10KB
```

### API Design

**Efficient Data Transfer**:

❌ **Bad**: No pagination, overfetching
```typescript
app.get('/api/products', async (req, res) => {
  const products = await db.getAllProducts(); // All 10,000 products!
  res.json(products);
});
```

✅ **Good**: Pagination + selective fields
```typescript
app.get('/api/products', async (req, res) => {
  const { page = 1, limit = 20, fields = 'id,name,price' } = req.query;
  const products = await db.getProducts({ page, limit, fields });
  res.json(products);
});
```

**Review Questions**:
- Are database queries optimized (indexes, JOINs instead of loops)?
- Is pagination implemented for list endpoints?
- Are large computations cached or memoized?
- Is lazy loading used for images and code?

---

## Testing Requirements

Code review should verify comprehensive test coverage.

### Coverage Thresholds

**Minimum Coverage Targets**:
- **Critical paths** (auth, payments, data integrity): 100%
- **Business logic**: 90%+
- **UI components**: 70-80%
- **Utilities/helpers**: 85%+

**Coverage is Necessary but Not Sufficient**: 100% coverage doesn't guarantee bug-free code. Test quality matters more than quantity.

### Test Quality (AAA Pattern)

Good tests follow **Arrange, Act, Assert**:

❌ **Bad**: Testing implementation details
```typescript
test('counter increments', () => {
  const counter = new Counter();
  counter.value = 5; // Directly setting internal state
  expect(counter.value).toBe(5); // Testing implementation, not behavior
});
```

✅ **Good**: Testing behavior
```typescript
test('counter increments when button clicked', () => {
  // Arrange
  const counter = new Counter();

  // Act
  counter.increment();
  counter.increment();

  // Assert
  expect(counter.getValue()).toBe(2);
});
```

❌ **Bad**: Multiple assertions without clear meaning
```typescript
test('user creation', async () => {
  const user = await createUser({ name: 'John' });
  expect(user).toBeDefined();
  expect(user.id).toBeTruthy();
  expect(user.name).toBe('John');
  expect(user.createdAt).toBeTruthy();
  // What is actually being tested?
});
```

✅ **Good**: Focused tests with clear intent
```typescript
test('createUser assigns unique ID to new user', async () => {
  const user = await createUser({ name: 'John' });
  expect(user.id).toMatch(/^[a-f0-9-]{36}$/); // UUID format
});

test('createUser sets createdAt timestamp', async () => {
  const before = Date.now();
  const user = await createUser({ name: 'John' });
  const after = Date.now();
  expect(user.createdAt).toBeGreaterThanOrEqual(before);
  expect(user.createdAt).toBeLessThanOrEqual(after);
});
```

### Test Types Required

**When to Require Each Type**:

**Unit Tests** (always required):
- All business logic functions
- Utilities and helpers
- Data validation
- Calculations and transformations

**Integration Tests** (required for):
- API endpoints
- Database operations
- External service integrations
- Multi-component workflows

**E2E Tests** (required for):
- Critical user flows (signup, checkout, payments)
- Complex multi-page workflows
- Features involving multiple services

**Review Questions**:
- Are all new functions covered by tests?
- Do tests cover edge cases and error conditions?
- Are tests focused on behavior, not implementation?
- Do integration tests verify API contracts?

See [references/test-review.md](references/test-review.md) for comprehensive testing guidance.

---

## Documentation Expectations

Documentation should explain *why*, not just *what*.

### When Documentation is Required

**Always Document**:
- Public APIs (exported functions, classes, endpoints)
- Complex algorithms or business logic
- Non-obvious design decisions
- Security considerations
- Performance optimizations

**Optional Documentation**:
- Self-explanatory code (good naming makes comments redundant)
- Obvious implementations (standard CRUD operations)

### What to Document

**Function/Method Documentation**:

❌ **Bad**: Redundant comments
```typescript
// Gets the user by ID
function getUserById(id) { ... }
```

✅ **Good**: Meaningful documentation
```typescript
/**
 * Fetches user profile with eager-loaded preferences.
 *
 * @param id - User UUID
 * @returns User with preferences, or null if not found
 * @throws DatabaseError if connection fails
 *
 * Note: This function caches results for 5 minutes to reduce DB load.
 * Use getUserByIdFresh() if you need latest data.
 */
async function getUserById(id: string): Promise<User | null> { ... }
```

**Complex Logic Documentation**:

❌ **Bad**: No explanation
```typescript
const price = base * (1 + tax) * (1 - discount) + shipping;
```

✅ **Good**: Explained calculation
```typescript
// Calculate final price including tax (additive), discount (multiplicative), and shipping
// Formula: (base × (1 + tax%) × (1 - discount%)) + shipping
// Example: $100 × 1.08 × 0.90 + $5 = $102.20
const price = base * (1 + tax) * (1 - discount) + shipping;
```

### Documentation Formats

**Use appropriate format for context**:
- **JSDoc/TSDoc**: For TypeScript/JavaScript functions and classes
- **Inline comments**: For complex logic within functions
- **README/docs**: For architecture, setup, API guides

**Review Questions**:
- Are public APIs documented with parameters, returns, and examples?
- Are complex algorithms explained (the "why", not just "what")?
- Do comments add value (not just restate the code)?

---

## Review Process Best Practices

### Review Etiquette

**Be Constructive**:
- ✅ "Consider extracting this to a helper function for reusability"
- ❌ "This code is terrible"

**Ask Questions**:
- ✅ "Why did you choose approach X over Y?"
- ❌ "This is wrong" (without explanation)

**Explain Reasoning**:
- ✅ "Parameterized queries prevent SQL injection (OWASP #3)"
- ❌ "Use parameterized queries" (without context)

**Acknowledge Good Work**:
- ✅ "Great test coverage on this edge case!"
- ✅ "Nice refactoring, much clearer now"

See [examples/review-comments.md](examples/review-comments.md) for template review comments.

### Common Review Comments

**Security**:
- "🔒 This endpoint needs authentication middleware"
- "🔒 User input should be validated before database query"
- "🔒 Sensitive data should not be logged"

**Code Quality**:
- "♻️ Consider extracting this logic to a reusable function"
- "♻️ Magic number - define as named constant"
- "♻️ Could simplify with early return"

**Performance**:
- "⚡ N+1 query detected - use JOIN or eager loading"
- "⚡ This could be memoized to avoid recalculation"
- "⚡ Consider pagination for large result sets"

**Testing**:
- "🧪 Missing test case for error condition"
- "🧪 This test is brittle - testing implementation, not behavior"
- "🧪 Integration test needed for this API endpoint"

### When to Approve vs. Request Changes

**✅ Approve**:
- All critical issues resolved (security, correctness)
- Minor nitpicks noted but don't block (style preferences)
- Tests pass and coverage is adequate
- Documentation is sufficient

**🔄 Request Changes**:
- Security vulnerabilities present
- Tests missing or failing
- Critical bugs or logic errors
- Performance issues that could cause production problems

**💬 Comment Only** (no approval/rejection):
- Suggesting improvements but not blocking
- Asking questions for clarification
- Sharing knowledge or context

---

## Quick Reference

### Security Checklist
- [ ] Authentication & authorization enforced
- [ ] All user input validated and sanitized
- [ ] SQL queries parameterized (no string concatenation)
- [ ] Sensitive data encrypted at rest and in transit
- [ ] Secrets in environment variables (not hardcoded)
- [ ] OWASP Top 10 vulnerabilities checked
- [ ] No sensitive data in logs

### Code Quality Checklist
- [ ] Functions < 50 lines, complexity < 10
- [ ] No duplicate code (DRY principle)
- [ ] Meaningful variable/function names
- [ ] Magic numbers replaced with named constants
- [ ] SOLID principles followed
- [ ] Code is readable without excessive comments

### Performance Checklist
- [ ] No N+1 queries (use JOINs or eager loading)
- [ ] Database indexes present for queried columns
- [ ] Large result sets paginated
- [ ] Expensive computations memoized
- [ ] Large dependencies tree-shaken
- [ ] Images and code lazy-loaded

### Testing Checklist
- [ ] Coverage meets thresholds (90%+ business logic)
- [ ] Tests follow AAA pattern (Arrange, Act, Assert)
- [ ] Tests verify behavior, not implementation
- [ ] Edge cases and error conditions covered
- [ ] Integration tests for APIs
- [ ] E2E tests for critical flows

### Documentation Checklist
- [ ] Public APIs documented (JSDoc/TSDoc)
- [ ] Complex algorithms explained
- [ ] Non-obvious decisions justified
- [ ] README updated if needed
- [ ] Comments add value (not redundant)

---

## Related Skills

- `testing-strategy` - Test pyramid and comprehensive testing patterns
- `github-workflow-best-practices` - PR workflow and review process
- `agency-workflow-patterns` - Multi-agent code review coordination (Reality Checker agent)
