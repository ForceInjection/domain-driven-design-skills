---
name: testing-best-practices
description: Testing methodologies, patterns, and best practices for unit, integration, and E2E tests. (project)
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# Testing Best Practices

## Testing Pyramid
```
        /\
       /E2E\        <- Few, slow, expensive
      /------\
     /Integration\  <- Some, moderate speed
    /--------------\
   /   Unit Tests   \ <- Many, fast, cheap
  /------------------\
```

## Unit Testing

### AAA Pattern
```typescript
describe('Calculator', () => {
  it('should add two numbers correctly', () => {
    // Arrange
    const calculator = new Calculator();

    // Act
    const result = calculator.add(2, 3);

    // Assert
    expect(result).toBe(5);
  });
});
```

### Naming Convention
```typescript
// Pattern: should [expected behavior] when [condition]
it('should throw error when dividing by zero')
it('should return empty array when no items match')
it('should update user when valid data provided')
```

### Test Organization
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data')
    it('should throw error when email exists')
    it('should hash password before saving')
  });

  describe('deleteUser', () => {
    it('should remove user from database')
    it('should throw error when user not found')
  });
});
```

## Mocking

### Function Mocks
```typescript
const mockFn = jest.fn();
mockFn.mockReturnValue('value');
mockFn.mockResolvedValue('async value');
mockFn.mockRejectedValue(new Error('fail'));
```

### Module Mocks
```typescript
jest.mock('./database', () => ({
  query: jest.fn().mockResolvedValue([]),
}));
```

### Spy on Methods
```typescript
const spy = jest.spyOn(service, 'method');
expect(spy).toHaveBeenCalledWith(arg1, arg2);
```

## Integration Testing

### API Testing
```typescript
describe('POST /api/users', () => {
  it('should create a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'john@example.com' })
      .expect(201);

    expect(response.body.data.name).toBe('John');
  });
});
```

### Database Testing
```typescript
beforeEach(async () => {
  await db.migrate.latest();
  await db.seed.run();
});

afterEach(async () => {
  await db.migrate.rollback();
});
```

## E2E Testing

### Playwright Example
```typescript
test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'user@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
```

## Code Coverage

### Coverage Targets
- Statements: 80%+
- Branches: 75%+
- Functions: 80%+
- Lines: 80%+

### Focus Areas
- Critical business logic
- Edge cases and error handling
- Security-sensitive code

### Don't Over-Test
- Getters/setters
- Framework code
- Third-party libraries
- Simple transformations

## Test Data

### Factories
```typescript
const createUser = (overrides = {}) => ({
  id: faker.string.uuid(),
  name: faker.person.fullName(),
  email: faker.internet.email(),
  ...overrides,
});
```

### Fixtures
```typescript
// fixtures/users.json
{
  "admin": { "id": "1", "role": "admin" },
  "user": { "id": "2", "role": "user" }
}
```
