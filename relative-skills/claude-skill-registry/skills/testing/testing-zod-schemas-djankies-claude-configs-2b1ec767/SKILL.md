---
name: testing-zod-schemas
description: Test Zod schemas comprehensively with unit tests, integration tests, and type tests for validation logic
---

# Testing Zod Schemas

## Purpose

Comprehensive guide to testing Zod v4 schemas, including validation logic, error messages, transformations, and type inference.

**For Vitest test structure, mocking, and async patterns, use `vitest-4/skills/writing-vitest-tests`**

## Unit Testing Schemas

### Basic Validation Tests

```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.email().trim().toLowerCase(),
  age: z.number().min(18),
  username: z.string().trim().min(3)
});

const result = userSchema.safeParse({
  email: 'user@example.com',
  age: 25,
  username: 'john'
});

expect(result.success).toBe(true);
if (result.success) {
  expect(result.data.email).toBe('user@example.com');
}

const invalidResult = userSchema.safeParse({
  email: 'not-an-email',
  age: 25,
  username: 'john'
});

expect(invalidResult.success).toBe(false);
if (!invalidResult.success) {
  expect(invalidResult.error.issues[0].path).toEqual(['email']);
}
```

### Testing Transformations

```typescript
const emailSchema = z.email().trim().toLowerCase();

const result = emailSchema.safeParse('  USER@EXAMPLE.COM  ');

expect(result.success).toBe(true);
if (result.success) {
  expect(result.data).toBe('user@example.com');
}
```

### Testing Error Messages

```typescript
const schema = z.object({
  email: z.email({ error: "Please enter a valid email address" }),
  password: z.string().min(8, {
    error: "Password must be at least 8 characters"
  })
});

const result = schema.safeParse({
  email: 'invalid',
  password: 'password123'
});

expect(result.success).toBe(false);
if (!result.success) {
  expect(result.error.issues[0].message).toBe(
    "Please enter a valid email address"
  );
}
```

### Testing Refinements

```typescript
const passwordSchema = z.string()
  .min(8)
  .refine(
    (password) => /[A-Z]/.test(password),
    { error: "Must contain uppercase letter" }
  )
  .refine(
    (password) => /[0-9]/.test(password),
    { error: "Must contain number" }
  );

const validResult = passwordSchema.safeParse('Password123');
expect(validResult.success).toBe(true);

const invalidResult = passwordSchema.safeParse('password123');
expect(invalidResult.success).toBe(false);
if (!invalidResult.success) {
  expect(invalidResult.error.issues[0].message).toBe(
    "Must contain uppercase letter"
  );
}
```

### Testing Async Refinements

```typescript
const emailSchema = z.email().refine(
  async (email) => {
    const exists = await checkEmailExists(email);
    return !exists;
  },
  { error: "Email already exists" }
);

const validResult = await emailSchema.safeParseAsync('new@example.com');
expect(validResult.success).toBe(true);

const invalidResult = await emailSchema.safeParseAsync('existing@example.com');
expect(invalidResult.success).toBe(false);
if (!invalidResult.success) {
  expect(invalidResult.error.issues[0].message).toBe("Email already exists");
}
```

## Testing Complex Schemas

### Nested Objects

```typescript
const addressSchema = z.object({
  street: z.string().trim().min(1),
  city: z.string().trim().min(1),
  zip: z.string().trim().regex(/^\d{5}$/)
});

const userSchema = z.object({
  name: z.string().trim().min(1),
  address: addressSchema
});

const result = userSchema.safeParse({
  name: 'John',
  address: { street: '123 Main St', city: 'Boston', zip: 'invalid' }
});

expect(result.success).toBe(false);
if (!result.success) {
  expect(result.error.issues[0].path).toEqual(['address', 'zip']);
}
```

### Arrays

```typescript
const tagsSchema = z.array(
  z.string().trim().min(1)
).min(1, { error: "At least one tag required" });

const result = tagsSchema.safeParse(['valid', '']);

expect(result.success).toBe(false);
if (!result.success) {
  expect(result.error.issues[0].path).toEqual([1]);
}
```

### Discriminated Unions

```typescript
const eventSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('click'),
    x: z.number(),
    y: z.number()
  }),
  z.object({
    type: z.literal('keypress'),
    key: z.string()
  })
]);

const result = eventSchema.safeParse({
  type: 'click',
  x: 100,
  y: 200
});

expect(result.success).toBe(true);
```

## Type Testing

### Type Inference

```typescript
const userSchema = z.object({
  email: z.email(),
  age: z.number(),
  name: z.string()
});

type User = z.infer<typeof userSchema>;

expectTypeOf<User>().toEqualTypeOf<{
  email: string;
  age: number;
  name: string;
}>();
```

### Transform Types

```typescript
const schema = z.string().transform(s => parseInt(s));

type Input = z.input<typeof schema>;
type Output = z.output<typeof schema>;

expectTypeOf<Input>().toEqualTypeOf<string>();
expectTypeOf<Output>().toEqualTypeOf<number>();
```

## Best Practices

### 1. Test Both Success and Failure

Always test valid data passes and invalid data fails

### 2. Test Transformations

Verify trim, lowercase, and other transforms produce expected output

### 3. Verify Error Messages

Check custom error messages appear correctly

### 4. Test Edge Cases

Handle empty strings, very long strings, special characters

### 5. Use SafeParse in Tests

```typescript
const result = schema.safeParse(data);  // ✅
try { schema.parse(data) }              // ❌
```

### 6. Test Type Inference

Verify `z.infer`, `z.input`, and `z.output` produce correct types

## Test Coverage

Aim for:
- **100% branch coverage** for validation logic
- **100% path coverage** for refinements
- **Edge cases** tested thoroughly
- **Error messages** verified
- **Transformations** validated

For coverage configuration in Vitest 4.x when testing schemas, use vitest-4/skills/configuring-vitest-4 for coverage include patterns and thresholds setup.

## References

- v4 Features: Use the validating-string-formats skill from the zod-4 plugin
- Error handling: Use the customizing-errors skill from the zod-4 plugin
- Transformations: Use the transforming-string-methods skill from the zod-4 plugin
- Performance: Use the optimizing-performance skill from the zod-4 plugin

**Cross-Plugin References:**

- If testing Zod validation with React components, use the testing-components skill for component integration testing patterns
- [@vitest-4/skills/configuring-vitest-4](/vitest-4/skills/configuring-vitest-4/SKILL.md) - Coverage configuration for schema testing

## Success Criteria

- ✅ 100% branch coverage for validation logic
- ✅ Success and failure paths tested
- ✅ Transformations verified
- ✅ Error messages validated
- ✅ Edge cases covered
- ✅ Type inference tested
- ✅ Integration tests pass
- ✅ Performance benchmarks meet targets
