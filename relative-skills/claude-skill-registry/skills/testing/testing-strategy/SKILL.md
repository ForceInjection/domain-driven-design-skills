---
name: testing-strategy
description: Comprehensive testing strategy covering test pyramids, framework selection, coverage standards, test organization, mocking patterns, and CI/CD integration. Activate when planning testing approaches, setting quality gates, or establishing test standards.
triggers:
  - "testing strategy"
  - "test coverage"
  - "quality gates"
  - "test patterns"
  - "testing standards"
  - "test pyramid"
  - "testing best practices"
  - "test organization"
---

# Testing Strategy & Standards

Master comprehensive testing strategies that ensure code quality, catch bugs early, and enable confident deployments. This skill covers test pyramids, framework selection, coverage standards, and continuous testing practices.

## Testing Philosophy

### Why We Test

**Primary Goals**:
1. **Prevent Regressions** - New changes don't break existing features
2. **Enable Refactoring** - Change implementation with confidence
3. **Document Behavior** - Tests serve as executable documentation
4. **Catch Bugs Early** - Cheaper to fix in development than production
5. **Enable CI/CD** - Automated testing enables automated deployment

**Not Goals**:
- 100% coverage for the sake of it
- Testing implementation details
- Slowing down development
- Replacing manual QA entirely

### Testing Mindset

**Test Behavior, Not Implementation**:
```javascript
// ❌ Bad: Testing implementation
test('calls useState with initial value', () => {
  const spy = jest.spyOn(React, 'useState');
  render(<Counter />);
  expect(spy).toHaveBeenCalledWith(0);
});

// ✅ Good: Testing behavior
test('displays initial count of 0', () => {
  render(<Counter />);
  expect(screen.getByText('Count: 0')).toBeInTheDocument();
});
```

**Write Tests Users Would Write**:
```javascript
// ✅ Test from user perspective
test('user can add item to cart', () => {
  render(<ProductPage />);

  // Find product
  const addButton = screen.getByRole('button', { name: /add to cart/i });

  // Click button
  userEvent.click(addButton);

  // Verify result
  expect(screen.getByText('1 item in cart')).toBeInTheDocument();
});
```

## Test Pyramid

### The Classic Pyramid

```
        /\
       /  \
      / E2E \         10% - Slow, expensive, brittle
     /------\
    /  Integ. \       20% - Medium speed, medium cost
   /----------\
  /   Unit     \      70% - Fast, cheap, stable
 /--------------\
```

**Distribution Guidelines**:
- **70% Unit Tests** - Individual functions/components
- **20% Integration Tests** - Multiple units working together
- **10% E2E Tests** - Full user flows

### Unit Tests

**What to Test**:
- Pure functions
- Component rendering
- Event handlers
- State management
- Utility functions

**Characteristics**:
- Fast (< 10ms each)
- Isolated (no external dependencies)
- Deterministic (same input → same output)
- Independent (can run in any order)

**Example**:
```javascript
// ✅ Good unit test
describe('formatCurrency', () => {
  it('should format USD correctly', () => {
    expect(formatCurrency(1234.56, 'USD')).toBe('$1,234.56');
  });

  it('should handle zero', () => {
    expect(formatCurrency(0, 'USD')).toBe('$0.00');
  });

  it('should handle negative amounts', () => {
    expect(formatCurrency(-100, 'USD')).toBe('-$100.00');
  });
});
```

### Integration Tests

**What to Test**:
- API endpoints
- Database interactions
- Multiple components together
- Service layer interactions
- External API integrations

**Characteristics**:
- Medium speed (< 1s each)
- Some external dependencies (test database)
- Test realistic scenarios
- More setup/teardown needed

**Example**:
```javascript
// ✅ Integration test
describe('POST /api/users', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  it('should create user and send welcome email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test User' });

    expect(response.status).toBe(201);
    expect(response.body.user.email).toBe('test@example.com');

    // Verify database
    const user = await db.users.findByEmail('test@example.com');
    expect(user).toBeDefined();

    // Verify email sent
    expect(emailService.send).toHaveBeenCalledWith({
      to: 'test@example.com',
      template: 'welcome'
    });
  });
});
```

### End-to-End Tests

**What to Test**:
- Critical user journeys
- Multi-page flows
- Payment processes
- Registration/login flows
- Key business workflows

**Characteristics**:
- Slow (seconds to minutes)
- Full stack (browser + backend + database)
- Fragile (many points of failure)
- High maintenance

**Example**:
```javascript
// ✅ E2E test
test('user can complete checkout process', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[name="email"]', 'user@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  // Add to cart
  await page.goto('/products/123');
  await page.click('button:has-text("Add to Cart")');

  // Checkout
  await page.goto('/cart');
  await page.click('button:has-text("Checkout")');
  await page.fill('[name="cardNumber"]', '4242424242424242');
  await page.fill('[name="expiry"]', '12/25');
  await page.fill('[name="cvc"]', '123');
  await page.click('button:has-text("Complete Purchase")');

  // Verify success
  await expect(page.locator('text=Order Confirmed')).toBeVisible();
});
```

See [Test Pyramid Details](references/test-pyramid.md) for comprehensive guidelines.

## Framework Selection

### Unit Testing Frameworks

**Jest** (Most Popular):
```javascript
// Pros: All-in-one, great React support, snapshot testing
// Cons: Can be slow for large codebases
// Best for: React apps, Node.js backends

describe('UserService', () => {
  it('should fetch user by id', async () => {
    const user = await UserService.getById('123');
    expect(user).toMatchObject({
      id: '123',
      name: expect.any(String)
    });
  });
});
```

**Vitest** (Modern Alternative):
```javascript
// Pros: Very fast, Vite integration, Jest-compatible API
// Cons: Newer, smaller ecosystem
// Best for: Vite projects, new projects wanting speed

import { describe, it, expect } from 'vitest';

describe('UserService', () => {
  it('should fetch user by id', async () => {
    const user = await UserService.getById('123');
    expect(user).toMatchObject({
      id: '123',
      name: expect.any(String)
    });
  });
});
```

### Integration Testing

**Supertest** (API Testing):
```javascript
// Best for: Testing REST APIs
import request from 'supertest';
import app from './app';

describe('API Integration', () => {
  it('GET /api/users should return users', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200)
      .expect('Content-Type', /json/);

    expect(response.body).toHaveLength(10);
  });
});
```

### E2E Testing Frameworks

**Playwright** (Recommended):
```javascript
// Pros: Fast, reliable, multi-browser, great dev tools
// Cons: Newer
// Best for: Modern web apps, cross-browser testing

import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'user@example.com');
  await page.fill('[name="password"]', 'password');
  await page.click('button[type="submit"]');
  await expect(page.locator('text=Dashboard')).toBeVisible();
});
```

**Cypress** (Popular Alternative):
```javascript
// Pros: Great DX, time-travel debugging, easy to learn
// Cons: Runs in browser (limitations), slower than Playwright
// Best for: Developers new to E2E testing

describe('Login', () => {
  it('should allow user to login', () => {
    cy.visit('/login');
    cy.get('[name="email"]').type('user@example.com');
    cy.get('[name="password"]').type('password');
    cy.get('button[type="submit"]').click();
    cy.contains('Dashboard').should('be.visible');
  });
});
```

## Coverage Standards

### Coverage Thresholds

**Minimum Targets**:
```json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      },
      "critical": {
        "branches": 100,
        "functions": 100,
        "lines": 100,
        "statements": 100
      }
    }
  }
}
```

**By Code Type**:
- **Critical Paths** (auth, payments): 100%
- **Business Logic**: 90-100%
- **Utilities**: 90%+
- **Components**: 70-80%
- **Config/Boilerplate**: 50%+

### Coverage Quality

**Good Coverage** ≠ **Good Tests**:

```javascript
// ❌ 100% coverage but useless test
test('user service exists', () => {
  const service = new UserService();
  expect(service).toBeDefined();
  service.getUser('123'); // Called but not verified!
  service.createUser({}); // Called but not verified!
});

// ✅ Lower coverage but meaningful tests
test('getUser returns user when found', async () => {
  const user = await UserService.getUser('123');
  expect(user).toMatchObject({
    id: '123',
    email: 'test@example.com'
  });
});

test('getUser throws when user not found', async () => {
  await expect(UserService.getUser('999'))
    .rejects.toThrow(NotFoundError);
});
```

**What Good Coverage Includes**:
- Happy paths tested
- Edge cases tested
- Error scenarios tested
- Boundary conditions tested
- Integration points tested

See [Coverage Standards](references/coverage-standards.md) for detailed requirements.

## Test Organization

### File Structure

**Co-located Tests** (Recommended):
```
src/
  components/
    Button/
      Button.tsx
      Button.test.tsx
      Button.stories.tsx
  services/
    UserService.ts
    UserService.test.ts
  utils/
    formatters.ts
    formatters.test.ts
```

**Separate Test Directory**:
```
src/
  components/
    Button.tsx
  services/
    UserService.ts
__tests__/
  components/
    Button.test.tsx
  services/
    UserService.test.ts
```

### Naming Conventions

**Test Files**:
- `Component.test.tsx` (Jest/Vitest)
- `Component.spec.tsx` (Angular convention)
- `Component.integration.test.ts` (Integration tests)
- `Component.e2e.test.ts` (E2E tests)

**Test Names**:
```javascript
// ✅ Good: Descriptive, readable
describe('UserAuthentication', () => {
  describe('login', () => {
    it('should return user when credentials are valid', () => {});
    it('should throw error when password is incorrect', () => {});
    it('should lock account after 5 failed attempts', () => {});
  });

  describe('logout', () => {
    it('should clear session token', () => {});
    it('should redirect to login page', () => {});
  });
});

// ❌ Bad: Vague, unclear
describe('Auth', () => {
  it('works', () => {});
  it('fails sometimes', () => {});
});
```

### Test Grouping

**By Feature**:
```javascript
describe('Shopping Cart', () => {
  describe('adding items', () => {
    it('should add item to empty cart', () => {});
    it('should increase quantity if item exists', () => {});
    it('should enforce maximum quantity', () => {});
  });

  describe('removing items', () => {
    it('should remove item from cart', () => {});
    it('should handle removing non-existent item', () => {});
  });

  describe('calculating total', () => {
    it('should sum all item prices', () => {});
    it('should apply discounts', () => {});
    it('should include tax', () => {});
  });
});
```

## Mocking Strategies

### When to Mock

**Mock External Dependencies**:
- API calls
- Database queries
- File system operations
- Third-party services
- Date/time
- Random number generation

**Don't Mock Internal Logic**:
- Business logic
- Pure functions
- Internal utilities

### Mock Patterns

**API Mocking**:
```javascript
// ✅ Mock fetch with jest
global.fetch = jest.fn(() =>
  Promise.resolve({
    json: () => Promise.resolve({ id: '123', name: 'Test User' })
  })
);

test('fetches user data', async () => {
  const user = await fetchUser('123');
  expect(user.name).toBe('Test User');
  expect(fetch).toHaveBeenCalledWith('/api/users/123');
});
```

**Database Mocking**:
```javascript
// ✅ Use test database
import { setupTestDB, cleanupTestDB } from './test-helpers';

beforeAll(async () => {
  await setupTestDB();
});

afterAll(async () => {
  await cleanupTestDB();
});

test('creates user in database', async () => {
  const user = await UserService.create({
    email: 'test@example.com',
    name: 'Test'
  });

  const found = await UserService.findById(user.id);
  expect(found.email).toBe('test@example.com');
});
```

**Service Mocking**:
```javascript
// ✅ Mock service dependencies
jest.mock('./EmailService');
import EmailService from './EmailService';

test('sends welcome email when user registers', async () => {
  await UserService.register({ email: 'test@example.com' });

  expect(EmailService.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    template: 'welcome'
  });
});
```

**Time Mocking**:
```javascript
// ✅ Mock dates for consistent tests
beforeAll(() => {
  jest.useFakeTimers();
  jest.setSystemTime(new Date('2024-01-01'));
});

afterAll(() => {
  jest.useRealTimers();
});

test('calculates days until expiry', () => {
  const expiry = new Date('2024-01-10');
  const days = calculateDaysUntil(expiry);
  expect(days).toBe(9);
});
```

See [Test Patterns](examples/test-patterns.md) for common mocking patterns.

## Testing Async Code

### Promises

```javascript
// ✅ Return promise
test('fetches user', () => {
  return fetchUser('123').then(user => {
    expect(user.id).toBe('123');
  });
});

// ✅ Use async/await (preferred)
test('fetches user', async () => {
  const user = await fetchUser('123');
  expect(user.id).toBe('123');
});

// ✅ Test rejections
test('throws when user not found', async () => {
  await expect(fetchUser('999')).rejects.toThrow(NotFoundError);
});
```

### Callbacks

```javascript
// ✅ Use done callback
test('calls callback with result', (done) => {
  fetchUser('123', (error, user) => {
    expect(error).toBeNull();
    expect(user.id).toBe('123');
    done();
  });
});
```

### Timers

```javascript
// ✅ Fast-forward time
jest.useFakeTimers();

test('debounces input', () => {
  const callback = jest.fn();
  const debounced = debounce(callback, 1000);

  debounced('a');
  debounced('b');
  debounced('c');

  expect(callback).not.toHaveBeenCalled();

  jest.runAllTimers();

  expect(callback).toHaveBeenCalledTimes(1);
  expect(callback).toHaveBeenCalledWith('c');
});
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json

      - name: Check coverage threshold
        run: npm run test:coverage-check
```

### Quality Gates

**Pre-merge Requirements**:
- [ ] All tests pass
- [ ] Coverage meets threshold
- [ ] No new linting errors
- [ ] Type checking passes
- [ ] E2E tests pass (for main branch)

**Configuration**:
```json
{
  "scripts": {
    "test": "jest",
    "test:coverage": "jest --coverage",
    "test:coverage-check": "jest --coverage --coverageReporters=text-summary --passWithNoTests",
    "test:ci": "jest --ci --coverage --maxWorkers=2"
  }
}
```

## Testing Best Practices

### AAA Pattern

**Arrange, Act, Assert**:
```javascript
test('adds item to cart', () => {
  // Arrange - Set up test data
  const cart = new ShoppingCart();
  const item = { id: '123', name: 'Product', price: 29.99 };

  // Act - Perform the action
  cart.addItem(item);

  // Assert - Verify the result
  expect(cart.items).toHaveLength(1);
  expect(cart.total).toBe(29.99);
});
```

### Test Isolation

```javascript
// ✅ Clean state between tests
describe('ShoppingCart', () => {
  let cart;

  beforeEach(() => {
    cart = new ShoppingCart(); // Fresh instance
  });

  test('adds item', () => {
    cart.addItem(item1);
    expect(cart.items).toHaveLength(1);
  });

  test('removes item', () => {
    cart.addItem(item1);
    cart.removeItem(item1.id);
    expect(cart.items).toHaveLength(0);
  });
});
```

### One Assertion Per Test

```javascript
// ❌ Bad: Multiple unrelated assertions
test('user service', async () => {
  const user = await UserService.create(data);
  expect(user.id).toBeDefined();
  const found = await UserService.findById(user.id);
  expect(found).toBeDefined();
  await UserService.delete(user.id);
  const deleted = await UserService.findById(user.id);
  expect(deleted).toBeNull();
});

// ✅ Good: Focused tests
test('creates user with generated id', async () => {
  const user = await UserService.create(data);
  expect(user.id).toBeDefined();
});

test('finds created user by id', async () => {
  const user = await UserService.create(data);
  const found = await UserService.findById(user.id);
  expect(found).toMatchObject(data);
});

test('deletes user', async () => {
  const user = await UserService.create(data);
  await UserService.delete(user.id);
  const deleted = await UserService.findById(user.id);
  expect(deleted).toBeNull();
});
```

### Meaningful Test Data

```javascript
// ❌ Bad: Magic values
test('validates email', () => {
  expect(validateEmail('a@b.c')).toBe(true);
});

// ✅ Good: Clear intent
test('validates email', () => {
  const validEmail = 'user@example.com';
  expect(validateEmail(validEmail)).toBe(true);
});

test('rejects invalid email format', () => {
  const invalidEmail = 'not-an-email';
  expect(validateEmail(invalidEmail)).toBe(false);
});
```

## Common Testing Pitfalls

### Testing Implementation Details

```javascript
// ❌ Bad: Tests internal state
test('counter increments state', () => {
  const { result } = renderHook(() => useCounter());
  expect(result.current.count).toBe(0); // Implementation detail
  act(() => result.current.increment());
  expect(result.current.count).toBe(1);
});

// ✅ Good: Tests behavior
test('displays incremented count', () => {
  render(<Counter />);
  expect(screen.getByText('Count: 0')).toBeInTheDocument();
  fireEvent.click(screen.getByText('Increment'));
  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```

### Flaky Tests

**Causes & Solutions**:
- **Race conditions**: Use proper async handling
- **Random data**: Use deterministic data or seeds
- **Shared state**: Isolate tests properly
- **Time-dependent**: Mock dates/timers
- **Network dependent**: Mock API calls

### Slow Tests

**Optimization**:
- Run tests in parallel
- Mock expensive operations
- Use smaller test datasets
- Skip unnecessary setup
- Use test database instead of production

## Quick Reference

**Test Types**:
- Unit: 70% - Fast, isolated, pure functions
- Integration: 20% - Medium, realistic scenarios
- E2E: 10% - Slow, critical paths

**Coverage Targets**:
- Critical: 100%
- Business Logic: 90%+
- Components: 70-80%
- Overall: 80%+

**Frameworks**:
- Unit: Jest or Vitest
- E2E: Playwright or Cypress
- API: Supertest

**CI/CD**:
- All tests pass before merge
- Coverage threshold enforced
- E2E on main branch

## Related Skills

- `code-review-standards` - What to look for in test reviews
- `github-workflow-best-practices` - CI/CD integration
- `agency-workflow-patterns` - Using test automation agents

---

**Remember**: Tests are documentation and safety nets. Write tests that give confidence and catch real bugs, not tests for coverage numbers.
