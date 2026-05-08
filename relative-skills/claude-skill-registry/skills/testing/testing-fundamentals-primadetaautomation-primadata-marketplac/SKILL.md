---
name: testing-fundamentals
description: TDD workflow, comprehensive test strategies, test coverage, and quality assurance patterns
triggers: [test, testing, TDD, coverage, unit test, integration test, e2e, quality assurance, QA]
version: 1.0.0
agents: [qa-testing-engineer, senior-fullstack-developer, playwright-test-agent]
context_levels:
  minimal: TDD workflow and quick test patterns
  detailed: Comprehensive testing strategies and patterns
  full: Test templates and data generation utilities
---

# Testing Fundamentals Skill

## Overview
This skill provides comprehensive testing strategies following TDD principles with 80%+ coverage requirements. It ensures quality assurance through systematic testing approaches.

## When to Use This Skill
- Implementing new features (TDD approach)
- Creating comprehensive test suites
- Analyzing test coverage gaps
- Pre-production quality validation
- Refactoring with safety net

## TDD Workflow (Level 1 - Always Loaded)

### 🔴 Red → 🟢 Green → 🔵 Refactor

**Step 1: Red - Write Failing Test First**
```typescript
// Write the test BEFORE implementation
describe('UserService', () => {
  it('should create a new user with valid data', async () => {
    // Arrange
    const userData = {
      email: 'test@example.com',
      password: 'SecurePass123!',
      name: 'Test User'
    };

    // Act
    const result = await userService.createUser(userData);

    // Assert
    expect(result).toHaveProperty('id');
    expect(result.email).toBe(userData.email);
    expect(result.name).toBe(userData.name);
    expect(result).not.toHaveProperty('password'); // Password should not be returned
  });
});

// Test should FAIL initially (Red)
```

**Step 2: Green - Write Minimal Code to Pass**
```typescript
class UserService {
  async createUser(data: CreateUserDto): Promise<User> {
    // Minimal implementation to make test pass
    const user = {
      id: generateId(),
      email: data.email,
      name: data.name,
      // password is hashed and not returned
    };

    await this.userRepository.save(user);
    return user;
  }
}

// Test should PASS now (Green)
```

**Step 3: Refactor - Improve Code Quality**
```typescript
class UserService {
  async createUser(data: CreateUserDto): Promise<User> {
    // Refactor with better structure
    this.validateUserData(data);

    const hashedPassword = await this.hashPassword(data.password);

    const user = User.create({
      email: data.email,
      name: data.name,
      passwordHash: hashedPassword,
    });

    return this.userRepository.save(user);
  }

  private validateUserData(data: CreateUserDto): void {
    if (!validator.isEmail(data.email)) {
      throw new ValidationError('Invalid email');
    }
    if (data.password.length < 8) {
      throw new ValidationError('Password too short');
    }
  }

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
  }
}

// Tests still PASS after refactoring
```

## Test Coverage Requirements

**Minimum Standards:**
- **80%+ overall coverage** (lines, branches, functions)
- **100% coverage** for critical business logic
- **All error paths** tested
- **Edge cases** covered

**What to Test:**
1. ✅ Happy path (normal flow)
2. ✅ Error scenarios (validation failures, exceptions)
3. ✅ Edge cases (empty arrays, null values, boundary conditions)
4. ✅ Integration points (API calls, database operations)
5. ✅ Security (unauthorized access, input validation)

## Arrange-Act-Assert (AAA) Pattern

```typescript
describe('OrderService', () => {
  it('should calculate total with tax correctly', () => {
    // ===== ARRANGE =====
    // Set up test data and dependencies
    const mockTaxService = {
      getTaxRate: jest.fn().mockResolvedValue(0.21)
    };
    const orderService = new OrderService(mockTaxService);
    const items = [
      { price: 100, quantity: 2 },
      { price: 50, quantity: 1 }
    ];

    // ===== ACT =====
    // Execute the function being tested
    const result = await orderService.calculateTotal(items);

    // ===== ASSERT =====
    // Verify the results
    expect(result.subtotal).toBe(250);
    expect(result.tax).toBe(52.5);
    expect(result.total).toBe(302.5);
    expect(mockTaxService.getTaxRate).toHaveBeenCalledTimes(1);
  });
});
```

## Test Types & When to Use

### 1. Unit Tests (Fast, Isolated)
```typescript
// Test single function/method in isolation
describe('calculateDiscount', () => {
  it('should apply 10% discount for orders over $100', () => {
    expect(calculateDiscount(150)).toBe(15);
  });

  it('should return 0 for orders under $100', () => {
    expect(calculateDiscount(50)).toBe(0);
  });
});
```

**When to use:**
- Testing pure functions
- Business logic validation
- Utility functions
- Unit-level validation

### 2. Integration Tests (Realistic)
```typescript
// Test multiple components together
describe('User Registration Integration', () => {
  it('should register user and send welcome email', async () => {
    // Uses real UserService, UserRepository, and EmailService
    const result = await userService.register({
      email: 'test@example.com',
      password: 'Test123!'
    });

    expect(result.user).toBeDefined();

    // Verify email was sent
    const emails = await testEmailService.getSentEmails();
    expect(emails).toHaveLength(1);
    expect(emails[0].to).toBe('test@example.com');
  });
});
```

**When to use:**
- API endpoint testing
- Database operations
- Service layer integration
- External service integration

### 3. E2E Tests (Full User Journey)
```typescript
// Test complete user flows (Playwright/Cypress)
test('user can complete checkout process', async ({ page }) => {
  // Navigate to site
  await page.goto('https://example.com');

  // Add items to cart
  await page.click('[data-testid="add-to-cart"]');

  // Go to checkout
  await page.click('[data-testid="checkout-button"]');

  // Fill shipping info
  await page.fill('[name="address"]', '123 Test St');
  await page.fill('[name="city"]', 'Amsterdam');

  // Complete payment
  await page.click('[data-testid="pay-now"]');

  // Verify success
  await expect(page.locator('.success-message')).toBeVisible();
});
```

**When to use:**
- Critical user journeys
- Cross-browser testing
- Visual regression
- Accessibility validation

## Test Data Management

### Factory Pattern
```typescript
// Test data factory for consistent test data
class UserFactory {
  static create(overrides: Partial<User> = {}): User {
    return {
      id: faker.string.uuid(),
      email: faker.internet.email(),
      name: faker.person.fullName(),
      createdAt: new Date(),
      ...overrides
    };
  }

  static createMany(count: number): User[] {
    return Array.from({ length: count }, () => this.create());
  }

  static createAdmin(): User {
    return this.create({
      role: 'admin',
      permissions: ['read', 'write', 'delete']
    });
  }
}

// Usage in tests
describe('UserService', () => {
  it('should handle multiple users', () => {
    const users = UserFactory.createMany(5);
    expect(users).toHaveLength(5);
  });

  it('should allow admin to delete users', () => {
    const admin = UserFactory.createAdmin();
    expect(admin.permissions).toContain('delete');
  });
});
```

## Mocking Best Practices

### Mock External Dependencies
```typescript
describe('PaymentService', () => {
  let paymentService: PaymentService;
  let mockStripeClient: jest.Mocked<StripeClient>;
  let mockDatabase: jest.Mocked<Database>;

  beforeEach(() => {
    // Create mocks
    mockStripeClient = {
      createCharge: jest.fn(),
      refund: jest.fn(),
    } as any;

    mockDatabase = {
      saveTransaction: jest.fn(),
    } as any;

    // Inject mocks
    paymentService = new PaymentService(mockStripeClient, mockDatabase);
  });

  it('should process payment and save transaction', async () => {
    // Arrange
    mockStripeClient.createCharge.mockResolvedValue({ id: 'ch_123', status: 'succeeded' });
    mockDatabase.saveTransaction.mockResolvedValue(true);

    // Act
    await paymentService.processPayment(100, 'usd');

    // Assert
    expect(mockStripeClient.createCharge).toHaveBeenCalledWith({
      amount: 100,
      currency: 'usd'
    });
    expect(mockDatabase.saveTransaction).toHaveBeenCalled();
  });
});
```

## Test Organization

### Describe Blocks for Structure
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', () => { /* ... */ });
    it('should throw error with invalid email', () => { /* ... */ });
    it('should throw error with weak password', () => { /* ... */ });
  });

  describe('updateUser', () => {
    it('should update user fields', () => { /* ... */ });
    it('should not update immutable fields', () => { /* ... */ });
  });

  describe('deleteUser', () => {
    it('should soft delete user', () => { /* ... */ });
    it('should throw error if user not found', () => { /* ... */ });
  });
});
```

## Testing Checklist

Before marking feature complete:
- [ ] Tests written BEFORE implementation (TDD)
- [ ] Happy path tested
- [ ] Error scenarios tested
- [ ] Edge cases covered
- [ ] 80%+ coverage achieved
- [ ] No flaky tests
- [ ] Tests run fast (< 5s for unit tests)
- [ ] Descriptive test names
- [ ] AAA pattern used
- [ ] Mocks properly isolated
- [ ] Integration tests for critical paths
- [ ] E2E tests for user journeys

## Common Testing Mistakes

### ❌ BAD: Testing Implementation Details
```typescript
it('should call getUserById method', () => {
  const spy = jest.spyOn(userService, 'getUserById');
  userService.getUser('123');
  expect(spy).toHaveBeenCalled(); // Testing HOW, not WHAT
});
```

### ✅ GOOD: Testing Behavior
```typescript
it('should return user data when valid ID provided', () => {
  const user = userService.getUser('123');
  expect(user).toBeDefined();
  expect(user.id).toBe('123'); // Testing WHAT happens
});
```

### ❌ BAD: Multiple Assertions Testing Different Things
```typescript
it('should work correctly', () => {
  expect(userService.create(data)).toBeDefined();
  expect(userService.delete('123')).toBe(true);
  expect(userService.list()).toHaveLength(5);
  // Too many unrelated assertions
});
```

### ✅ GOOD: One Behavior Per Test
```typescript
it('should create user successfully', () => {
  expect(userService.create(data)).toBeDefined();
});

it('should delete user when valid ID provided', () => {
  expect(userService.delete('123')).toBe(true);
});

it('should list all users', () => {
  expect(userService.list()).toHaveLength(5);
});
```

## Detailed Testing Strategies (Level 2 - Load on Request)

See companion files:
- `advanced-mocking.md` - Complex mocking scenarios
- `performance-testing.md` - Load and stress testing
- `snapshot-testing.md` - Visual and data snapshot strategies

## Test Templates (Level 3 - Load When Needed)

See templates directory:
- `templates/unit-test.template.ts`
- `templates/integration-test.template.ts`
- `templates/e2e-test.template.ts`

## Integration with Agents

**qa-testing-engineer:**
- Primary agent for test strategy and implementation
- Uses this skill for all testing tasks
- Ensures coverage requirements met

**senior-fullstack-developer:**
- Uses this skill for TDD workflow
- References patterns during feature development

**playwright-test-agent:**
- Uses E2E testing sections
- Focuses on browser automation patterns

---

*Version 1.0.0 | TDD Compliant | 80%+ Coverage Required*
