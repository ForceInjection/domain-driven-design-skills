---
name: "code-reviewer"
description: "Use this when user requests code review, pull request analysis, or quality assessment. Provides systematic 6-category checklist: functionality, security (OWASP), code quality (SOLID), performance, testing, and maintainability. Apply for PR reviews, security audits, or teaching code quality principles"
categories: ["role", "perspective", "quality"]
tags: ["code-review", "security", "quality", "best-practices", "testing"]
version: "1.0.0"
---

# Code Reviewer Role

## Purpose

Provides systematic code review perspective focusing on quality, security, maintainability, performance, and adherence to best practices.

## When to Use

- ✅ User requests code review
- ✅ Analyzing pull requests or diffs
- ✅ Evaluating code quality of modules
- ✅ Security audit requirements
- ✅ Pre-merge quality checks
- ✅ Teaching code quality principles

## Code Review Checklist

### Category 1: Functionality

**Questions**:
- Does the code do what it's supposed to do?
- Are edge cases handled correctly?
- Are error conditions handled gracefully?
- Is the happy path clear and correct?
- Are there any logical errors?

**Check For**:
```typescript
// ❌ Off-by-one errors
for (let i = 0; i <= array.length; i++) // Should be i < array.length

// ❌ Incorrect null checks
if (user.email) // Should check: if (user && user.email)

// ❌ Async/await misuse
async function process() {
  doAsync(); // Missing await!
}

// ✅ Correct error handling
try {
  const result = await operation();
  return result;
} catch (error) {
  logger.error('Operation failed', { error, context });
  throw new BusinessException('User-friendly message');
}
```

**Search Examples**:
```bash
codecompass search:semantic "error handling and exception management"
codecompass search:semantic "null safety and defensive programming"
codecompass search:semantic "async operations and promise handling"
```

### Category 2: Security

**OWASP Security Checks**:

**1. Injection Vulnerabilities**
```typescript
// ❌ SQL Injection
const query = `SELECT * FROM users WHERE email = '${userInput}'`;

// ✅ Parameterized queries
const query = 'SELECT * FROM users WHERE email = ?';
const result = await db.execute(query, [userInput]);

// ❌ Command Injection
exec(`ls ${userInput}`);

// ✅ Sanitized input
const allowedCommands = ['list', 'show', 'get'];
if (!allowedCommands.includes(userInput)) {
  throw new Error('Invalid command');
}
```

**2. Authentication & Authorization**
```typescript
// ❌ Missing authentication check
@Get('/admin/users')
async getUsers() {
  return this.userService.findAll();
}

// ✅ Protected endpoint
@UseGuards(AuthGuard, RolesGuard)
@Roles('admin')
@Get('/admin/users')
async getUsers() {
  return this.userService.findAll();
}

// ❌ Weak password requirements
if (password.length >= 6) // Too short!

// ✅ Strong password policy
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$/;
if (!passwordRegex.test(password)) {
  throw new Error('Password does not meet security requirements');
}
```

**3. Sensitive Data Exposure**
```typescript
// ❌ Logging sensitive data
logger.info('User login', { email, password }); // Never log passwords!

// ✅ Safe logging
logger.info('User login', { email, userId });

// ❌ Exposing internal errors
catch (error) {
  return { error: error.message, stack: error.stack }; // Leaks internals!
}

// ✅ Generic error messages
catch (error) {
  logger.error('Operation failed', { error, userId });
  return { error: 'An unexpected error occurred' };
}
```

**4. Access Control**
```typescript
// ❌ Insecure direct object reference (IDOR)
@Get('/orders/:id')
async getOrder(@Param('id') id: string) {
  return this.orderService.findById(id); // No ownership check!
}

// ✅ Authorization check
@Get('/orders/:id')
async getOrder(@Param('id') id: string, @CurrentUser() user: User) {
  const order = await this.orderService.findById(id);
  if (order.userId !== user.id && !user.isAdmin) {
    throw new ForbiddenException('Access denied');
  }
  return order;
}
```

**Search Examples**:
```bash
codecompass search:semantic "SQL query construction with user input"
codecompass search:semantic "authentication guards and authorization"
codecompass search:semantic "password hashing and storage"
codecompass search:semantic "logging sensitive information"
```

### Category 3: Code Quality

**1. Readability**

**Naming Conventions**:
```typescript
// ❌ Poor naming
function f(x) {
  const y = x * 2;
  return y;
}

// ✅ Clear naming
function calculateDoublePrice(basePrice: number): number {
  const doublePrice = basePrice * 2;
  return doublePrice;
}

// ❌ Ambiguous boolean
let flag = false;

// ✅ Descriptive boolean
let isEmailVerified = false;
let hasActiveSubscription = true;
let canEditOrder = user.isAdmin || order.status === 'draft';
```

**Function Length**:
```typescript
// ❌ Too long (>50 lines)
function processOrder() {
  // 100 lines of code...
}

// ✅ Extracted and focused
function processOrder() {
  validateOrder();
  calculateTotal();
  applyDiscounts();
  processPayment();
  sendConfirmation();
}
```

**Complexity**:
```typescript
// ❌ High cyclomatic complexity (>10)
function calculateDiscount(user, order, date) {
  if (user.vip) {
    if (order.total > 1000) {
      if (date.isWeekend()) {
        if (order.items.length > 5) {
          // ... more nested conditions
        }
      }
    }
  }
}

// ✅ Extracted rules
function calculateDiscount(user: User, order: Order, date: Date): number {
  const rules = [
    new VipDiscountRule(),
    new BulkOrderDiscountRule(),
    new WeekendDiscountRule(),
    new LargeCartDiscountRule(),
  ];

  return rules.reduce((total, rule) => total + rule.calculate(user, order, date), 0);
}
```

**2. DRY Principle (Don't Repeat Yourself)**

```typescript
// ❌ Duplication
function processUserPayment(user: User, amount: number) {
  const fee = amount * 0.03;
  const total = amount + fee;
  return stripe.charge(user.paymentMethod, total);
}

function processOrderPayment(order: Order) {
  const fee = order.total * 0.03;
  const total = order.total + fee;
  return stripe.charge(order.user.paymentMethod, total);
}

// ✅ Extracted common logic
function calculateFee(amount: number): number {
  return amount * 0.03;
}

function processPayment(paymentMethod: PaymentMethod, amount: number): Promise<PaymentResult> {
  const fee = calculateFee(amount);
  const total = amount + fee;
  return stripe.charge(paymentMethod, total);
}
```

**3. SOLID Principles**

**Single Responsibility**:
```typescript
// ❌ Multiple responsibilities
class UserService {
  async createUser(data: CreateUserDto) {
    // Validate input
    // Hash password
    // Save to database
    // Send welcome email
    // Log analytics event
    // Update cache
  }
}

// ✅ Separated concerns
class UserService {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordService: PasswordService,
    private readonly emailService: EmailService,
    private readonly analyticsService: AnalyticsService,
  ) {}

  async createUser(data: CreateUserDto): Promise<User> {
    const hashedPassword = await this.passwordService.hash(data.password);
    const user = await this.userRepository.create({ ...data, password: hashedPassword });

    // Delegate to other services
    await this.emailService.sendWelcome(user);
    await this.analyticsService.trackUserCreated(user);

    return user;
  }
}
```

**Open/Closed Principle**:
```typescript
// ❌ Modifying existing code for new features
function calculateShipping(type: string, distance: number) {
  if (type === 'standard') {
    return distance * 0.5;
  } else if (type === 'express') {
    return distance * 1.5;
  } else if (type === 'overnight') { // New feature requires modification
    return distance * 3.0;
  }
}

// ✅ Open for extension, closed for modification
interface ShippingStrategy {
  calculate(distance: number): number;
}

class StandardShipping implements ShippingStrategy {
  calculate(distance: number): number {
    return distance * 0.5;
  }
}

class ExpressShipping implements ShippingStrategy {
  calculate(distance: number): number {
    return distance * 1.5;
  }
}

// Add new shipping types without modifying existing code
class OvernightShipping implements ShippingStrategy {
  calculate(distance: number): number {
    return distance * 3.0;
  }
}
```

**Dependency Inversion**:
```typescript
// ❌ High-level module depends on low-level module
class OrderService {
  private stripeClient = new StripeClient(); // Direct dependency!

  async processPayment(order: Order) {
    return this.stripeClient.charge(order.total);
  }
}

// ✅ Both depend on abstraction
interface PaymentGateway {
  charge(amount: number): Promise<PaymentResult>;
}

class StripeGateway implements PaymentGateway {
  charge(amount: number): Promise<PaymentResult> {
    // Stripe implementation
  }
}

class OrderService {
  constructor(private readonly paymentGateway: PaymentGateway) {} // Injected abstraction

  async processPayment(order: Order) {
    return this.paymentGateway.charge(order.total);
  }
}
```

### Category 4: Performance

**1. Database Performance**

```typescript
// ❌ N+1 Query Problem
async function getUserOrders(userId: string) {
  const user = await userRepo.findById(userId);
  const orders = await orderRepo.findByUserId(userId);

  for (const order of orders) {
    order.items = await orderItemRepo.findByOrderId(order.id); // N queries!
  }

  return orders;
}

// ✅ Eager loading
async function getUserOrders(userId: string) {
  return orderRepo.find({
    where: { userId },
    relations: ['items'], // Single query with join
  });
}

// ❌ Missing index
// Query: SELECT * FROM orders WHERE status = 'pending' AND created_at < NOW() - INTERVAL 1 HOUR
// Table has no index on (status, created_at)

// ✅ Add index
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
```

**2. Algorithm Efficiency**

```typescript
// ❌ O(n²) complexity
function findDuplicates(array: number[]): number[] {
  const duplicates = [];
  for (let i = 0; i < array.length; i++) {
    for (let j = i + 1; j < array.length; j++) {
      if (array[i] === array[j]) {
        duplicates.push(array[i]);
      }
    }
  }
  return duplicates;
}

// ✅ O(n) complexity
function findDuplicates(array: number[]): number[] {
  const seen = new Set<number>();
  const duplicates = new Set<number>();

  for (const num of array) {
    if (seen.has(num)) {
      duplicates.add(num);
    } else {
      seen.add(num);
    }
  }

  return Array.from(duplicates);
}
```

**3. Memory Management**

```typescript
// ❌ Memory leak (event listeners)
class DataService {
  constructor(private eventEmitter: EventEmitter) {
    this.eventEmitter.on('data', this.handleData.bind(this));
  }

  // No cleanup! Listener persists after service destroyed
}

// ✅ Proper cleanup
class DataService implements OnDestroy {
  private subscription: Subscription;

  constructor(private eventEmitter: EventEmitter) {
    this.subscription = this.eventEmitter.on('data', this.handleData.bind(this));
  }

  onDestroy() {
    this.subscription.unsubscribe();
  }
}

// ❌ Loading entire dataset into memory
async function processAllUsers() {
  const users = await userRepo.find(); // Could be millions!
  return users.map(processUser);
}

// ✅ Stream processing
async function processAllUsers() {
  const stream = await userRepo.createQueryBuilder('user').stream();

  for await (const user of stream) {
    await processUser(user);
  }
}
```

**Search Examples**:
```bash
codecompass search:semantic "database queries in loops"
codecompass search:semantic "algorithm complexity and performance"
codecompass search:semantic "memory leaks and resource cleanup"
```

### Category 5: Testing

**1. Test Coverage**

```typescript
// ❌ Insufficient tests
describe('UserService', () => {
  it('should create user', async () => {
    const user = await service.createUser(mockData);
    expect(user).toBeDefined();
  });
});

// ✅ Comprehensive tests
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      const user = await service.createUser(validData);
      expect(user.email).toBe(validData.email);
      expect(user.password).not.toBe(validData.password); // Should be hashed
    });

    it('should throw error for duplicate email', async () => {
      await service.createUser(validData);
      await expect(service.createUser(validData)).rejects.toThrow('Email already exists');
    });

    it('should send welcome email after creation', async () => {
      await service.createUser(validData);
      expect(emailService.sendWelcome).toHaveBeenCalledWith(expect.objectContaining({
        email: validData.email,
      }));
    });

    it('should reject invalid email format', async () => {
      const invalidData = { ...validData, email: 'invalid-email' };
      await expect(service.createUser(invalidData)).rejects.toThrow('Invalid email');
    });
  });
});
```

**2. Test Quality**

```typescript
// ❌ Brittle test (implementation details)
it('should process order', async () => {
  const spy = jest.spyOn(service as any, 'calculateTotal'); // Testing private method!
  await service.processOrder(order);
  expect(spy).toHaveBeenCalled();
});

// ✅ Behavior-focused test
it('should include shipping fee in total', async () => {
  const result = await service.processOrder(order);
  const expectedTotal = order.subtotal + order.shippingFee;
  expect(result.total).toBe(expectedTotal);
});

// ❌ Test with side effects
it('should save user', async () => {
  await service.createUser(data); // Actually hits database!
  const users = await userRepo.find();
  expect(users).toHaveLength(1);
});

// ✅ Isolated test with mocks
it('should save user', async () => {
  const mockRepo = { save: jest.fn().mockResolvedValue(mockUser) };
  const service = new UserService(mockRepo as any);

  await service.createUser(data);

  expect(mockRepo.save).toHaveBeenCalledWith(expect.objectContaining({
    email: data.email,
  }));
});
```

**3. Test Organization**

```typescript
// ❌ Unclear test structure
describe('OrderService', () => {
  it('test1', () => {});
  it('test2', () => {});
  it('test3', () => {});
});

// ✅ Clear test organization (AAA pattern: Arrange, Act, Assert)
describe('OrderService', () => {
  describe('processOrder', () => {
    describe('when order is valid', () => {
      it('should calculate total correctly', () => {
        // Arrange
        const order = createMockOrder({ subtotal: 100, tax: 10 });

        // Act
        const result = service.processOrder(order);

        // Assert
        expect(result.total).toBe(110);
      });
    });

    describe('when order is invalid', () => {
      it('should throw validation error', () => {
        // Arrange
        const invalidOrder = createMockOrder({ subtotal: -100 });

        // Act & Assert
        expect(() => service.processOrder(invalidOrder)).toThrow('Invalid subtotal');
      });
    });
  });
});
```

**Search Examples**:
```bash
codecompass search:semantic "test coverage and unit tests"
codecompass search:semantic "mock objects and test doubles"
codecompass search:semantic "integration tests and e2e tests"
```

### Category 6: Maintainability

**1. Documentation**

```typescript
// ❌ No documentation
function calculate(a, b, c) {
  return (a + b) * c - (a * 0.1);
}

// ✅ Clear documentation
/**
 * Calculates the total order price with discount applied.
 *
 * Formula: (basePrice + shipping) * quantity - (basePrice * discountRate)
 *
 * @param basePrice - The base price of the item in cents
 * @param shipping - The shipping cost in cents
 * @param quantity - Number of items ordered
 * @returns The final price in cents after discount
 *
 * @example
 * calculateOrderTotal(1000, 500, 2) // Returns 2900 (2 items @ $10 + $5 shipping - 10% discount)
 */
function calculateOrderTotal(
  basePrice: number,
  shipping: number,
  quantity: number,
): number {
  const discountRate = 0.1;
  return (basePrice + shipping) * quantity - (basePrice * discountRate);
}
```

**2. Error Messages**

```typescript
// ❌ Unclear error messages
throw new Error('Invalid');
throw new Error('Error 42');
throw new Error(e.toString());

// ✅ Descriptive error messages
throw new ValidationError('Email format is invalid', {
  field: 'email',
  value: userInput.email
});

throw new BusinessError('Order cannot be cancelled after shipment', {
  orderId: order.id,
  currentStatus: order.status,
  allowedStatuses: ['pending', 'processing'],
});

throw new Error(
  `Failed to process payment: ${e.message}. ` +
  `Order ID: ${order.id}, User ID: ${user.id}`,
);
```

**3. Code Comments**

```typescript
// ❌ Obvious comments
// Increment counter
counter++;

// Loop through users
for (const user of users) {

// ❌ Commented-out code
// const oldImplementation = () => {
//   return someOldLogic();
// };

// ✅ Explain WHY, not WHAT
// Use exponential backoff to avoid overwhelming the payment gateway
// after temporary failures (their rate limit is 10 req/sec)
await retryWithBackoff(processPayment, { maxRetries: 3 });

// HACK: Workaround for third-party API bug (ticket #1234)
// Remove this after they deploy fix (ETA: 2025-12-01)
if (response.status === 200 && !response.data) {
  response.data = await fetchDataManually();
}
```

**Search Examples**:
```bash
codecompass search:semantic "missing documentation and comments"
codecompass search:semantic "error handling and error messages"
codecompass search:semantic "commented out code blocks"
```

## Review Process

### Step 1: High-Level Pass
1. Read the purpose (PR description, commit message)
2. Understand the change scope
3. Identify affected modules
4. Check test coverage

### Step 2: Deep Dive
1. Review each file methodically
2. Apply checklist categories
3. Note issues (critical, major, minor)
4. Suggest improvements

### Step 3: Feedback Generation
1. Start with positives
2. Group related issues
3. Provide examples for fixes
4. Prioritize critical issues

## Review Output Format

```markdown
## Summary
**Overall**: Approve with minor changes requested
**Complexity**: Medium
**Risk Level**: Low

## Strengths
✅ Comprehensive test coverage (95%)
✅ Clear naming and documentation
✅ Good error handling

## Critical Issues (Must Fix)
🔴 **Security**: SQL injection vulnerability in UserController:45
   - Current: `query = "SELECT * FROM users WHERE id = " + userId`
   - Fix: Use parameterized query or ORM

## Major Issues (Should Fix)
🟡 **Performance**: N+1 query in OrderService:78
   - Add eager loading for order items relation

🟡 **Code Quality**: Duplicated validation logic in 3 files
   - Extract to shared ValidationService

## Minor Issues (Consider)
🟢 **Naming**: Variable `tmp` in DiscountCalculator:12
   - Suggest: `discountedPrice` or `priceAfterDiscount`

🟢 **Documentation**: Missing JSDoc for public method `processRefund`
   - Add description, parameters, return type, example

## Suggestions
💡 Consider using Strategy pattern for payment methods instead of switch statement
💡 Could extract magic numbers to named constants (e.g., `MAX_RETRY_ATTEMPTS = 3`)

## Questions
❓ Why is the timeout set to 30 seconds instead of the standard 10?
❓ Should we add rate limiting to this endpoint?
```

## Best Practices

### ✅ Do
- Review with empathy and respect
- Explain WHY, not just WHAT is wrong
- Provide specific examples for fixes
- Balance perfectionism with pragmatism
- Recognize good code and improvements
- Ask questions when unclear
- Focus on behavior over implementation details

### ❌ Don't
- Be overly critical or pedantic
- Nitpick formatting (use linter instead)
- Review your own code (get peer review)
- Approve without actually reading
- Focus only on negatives
- Demand your personal preferences
- Review when tired or rushed

## Related Skills

- `software-architect.md` - Architectural perspective
- `semantic-search.md` - Finding code patterns
- `0-discover-capabilities.md` - Understanding codebase

## Related Modules

From `.ai/capabilities.json`:
- `ast-analyzer` - Code structure analysis
- `static-analyzer` - Code quality metrics
- `security-analyzer` - Vulnerability detection
- `test-analyzer` - Test coverage analysis

---

**Remember**: Code review is about improving code AND helping developers grow. Be kind, be thorough, be constructive.
