---
name: writing-unit-tests
description: Defines unit testing standards for the Sigil project. Applies when writing tests, reviewing test code, creating fixtures or mocks, or answering questions about testing conventions. Covers test structure, fixtures, mocks, assertions, table tests, and type safety in tests.
---

# Writing Unit Tests

Standards for unit testing in Sigil. Test behaviour, not implementation. Comprehensive coverage of edge cases. No vague assertions.

## When to Use

Apply these standards when writing new tests, reviewing test code, or refactoring existing tests. This skill covers unit tests only—integration tests and E2E tests (Cypress) are separate concerns.

## Test Execution

Always use `npm run test` to run tests. This runs `spec:all` (bundling, validation, type generation, codegen for the IR) then `vitest --run`. Never use `npx vitest` directly—the npm script includes required build steps and preferred flags.

## File Structure

Tests are co-located with implementation by default:

```
moduleName/
├── moduleName.ts
├── moduleName.spec.ts
├── moduleName.fixtures.ts    # Static test data and factory functions
└── moduleName.mock.ts        # Mocks for dependency injection (if needed)
```

**Exception—`__tests__/` folder**: When a test file exceeds ~1000-1500 lines, split into multiple files in a `__tests__/` directory:

```
executeAgent/
├── executeAgent.ts
├── executeAgent.mock.ts
├── executeAgent.fixtures.ts
└── __tests__/
    ├── basic.spec.ts
    ├── callbacks.spec.ts
    ├── reducer.spec.ts
    └── reducer.fixtures.ts
```

When splitting, the top-level `describe` follows the pattern `functionName - Concern`:

```typescript
describe('executeAgent - Callbacks', () => { ... });
describe('executeAgent - Retries', () => { ... });
```

## Test Order Within File

Organise tests in this order:
1. Happy path / successful cases
2. Specific feature tests
3. Edge cases (empty, null, boundaries)
4. Error scenarios

## Core Philosophy

### Test Behaviour, Not Implementation

Tests should survive complete implementation rewrites. Test the contract and surface, not internal details.

```typescript
// Correct: Tests behaviour
it('should return parsed fields from CSV', () => {
  const result = parseCSV(FIXTURES.CSV_INPUT);
  expect(isOk(result)).toBe(true);
  if (!isOk(result)) return;
  expect(result.data.fields).toEqual(['name', 'email', 'age']);
});

// Wrong: Tests implementation detail
it('should call splitLines then parseHeader', () => {
  const splitSpy = vi.spyOn(internals, 'splitLines');
  const parseSpy = vi.spyOn(internals, 'parseHeader');
  parseCSV(input);
  expect(splitSpy).toHaveBeenCalledBefore(parseSpy);
});
```

**Exception**: Testing that something throws is valid when throwing is the defined behaviour.

### Systematic Test Derivation

Think in systems. When a source of truth exists (mapping object, enum, schema, configuration), derive tests from it systematically. This keeps implementation and test coverage in sync—when the source changes, test coverage automatically adjusts.

```typescript
import {objectToEntries} from '@sigil/renderer/react/common';
import {ALIGNMENT_CLASS_MAP} from './alignment';

it.each(objectToEntries(ALIGNMENT_CLASS_MAP))('returns %s for %s', (alignment, expected) => {
  expect(getAlignmentClass(alignment)).toBe(expected);
});
```

This principle applies broadly:
- **Mapping objects** → Use `objectToEntries()` to generate test cases
- **Enums/unions** → Derive test cases from enum values
- **Zod schemas** → Use schema to validate outputs
- **Configuration objects** → Test all configured options

The goal: if someone adds a new entry to `ALIGNMENT_CLASS_MAP`, the test automatically covers it. No manual test updates required. No coverage gaps.

### Edge Cases and Hostile Input

Given the project's nature (arbitrary user data → generated UI), tests must cover edge cases thoroughly. Treat all inputs as potentially hostile or malformed.

Test: empty inputs, malformed inputs, null/undefined where not expected, boundary conditions, invalid types, oversized inputs.

## Fixtures

**Fixtures** (`.fixtures.ts` or `.fixtures.tsx`): Static objects representing inputs or expected values. Can include factory functions for reusable structures with variable parts.

**Mocks** (`.mock.ts`): For dependency injection and API mocking. Used when you need to control function return values without calling real implementations. Can track calls and stub return values to elicit specific behaviour.

**Key distinction**: Fixtures are data. Mocks are behaviour substitutes.

For detailed mock patterns, see [API_MOCKS.md](./API_MOCKS.md).

### Fixture Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Static constants | `SCREAMING_SNAKE_CASE` | `BASIC_TABLE`, `EMPTY_DATA_ARRAY` |
| Factory functions | `camelCase` | `createPassingValidator()`, `agentBuilder()` |
| Base templates | `BASE_*` prefix | `BASE_MINIMAL_AGENT` |
| Invalid fixtures | `INVALID_*` prefix | `INVALID_EMPTY_NAME` |

### Fixtures Philosophy

Think in systems. Before creating a new fixture, check existing fixtures for redundancy. Make fixtures composable and modular.

Rules:
- Only export what tests actually use
- No magic values in tests—constants come from fixtures
- If existing fixture doesn't suit, create a new one (don't inline magic values)
- Expected values reference fixtures via dot notation (`fixture.user.name` not `'Alice'`)
- Fixtures not shared across concerns—parent module gets its own fixtures representing inputs at parent's scope
- Type fixtures wherever possible—avoid `as` and `as const`

When fixtures would bloat a spec file, extract to `.fixtures.ts`. A few test-specific constants can stay in the spec file at module level (screaming snake case).

### Fixture Reference Rule

When to reference fixtures vs inline values:

- **Unmapped/unprocessed value**: Reference fixture directly (`fixture.user.name`)—keeps input and expected output in sync
- **Transformed/processed value**: Inline the expected value—that's the behaviour being tested

Never call the transformation function in the test to derive expected values—that tests implementation, not behaviour.

## Type Safety in Tests

Use type guards with assertions to narrow types. Never use `as` casting except for deliberately hostile/malformed test data.

**Important**: Asserting on a type guard alone doesn't narrow the type—you also need the guard in a conditional for TypeScript to narrow:

```typescript
// Correct: Assert then guard to narrow
const result = await processData(input);
expect(isOk(result)).toBe(true);
if (!isOk(result)) {
  return; // Early return - TypeScript now knows result is Ok below
}
// Type is now narrowed - safe to access result.data
expect(result.data.items).toHaveLength(3);

// Wrong: as casting to force access
const result = await processData(input) as Ok<ProcessedData>;
expect(result.data.items).toHaveLength(3);
```

The assertion verifies correctness; the guard enables type narrowing. Both are required.

**Conditions require prior assertions**: If test code has any conditional (`if`, ternary), the condition's value must already be asserted. No unknown values in branch logic.

```typescript
// Correct: Assertion guarantees the condition
expect(result.items.length).toBeGreaterThan(0);
if (result.items.length > 0) {
  expect(result.items.at(0)?.type).toBe('text');
}

// Wrong: Condition on unasserted value
if (result.items.length > 0) {  // What if it's 0?
  expect(result.items.at(0)?.type).toBe('text');
}
```

**Discriminated unions**: Assert on the discriminator before accessing variant-specific fields:

```typescript
expect(error.code).toBe('VALIDATION_ERROR');
// Now type-narrowed to ValidationError variant
expect(error.fields).toContain('email');
```

**Error context narrowing:**

```typescript
if (isErr(result)) {
  const error = result.error.at(0);
  expect(error?.code).toBe(ERROR_CODES.NOT_ARRAY);
  if (error?.code === ERROR_CODES.NOT_ARRAY) {
    expect(error.context.actualType).toBe('string');
  }
}
```

**Exception testing:**

```typescript
expect(() => {
  render(INVALID_SPEC, []);
}).toThrow(SpecProcessingError);

// For detailed error inspection:
try {
  render(INVALID_SPEC, []);
} catch (error) {
  expect(error).toBeInstanceOf(SpecProcessingError);
  if (error instanceof SpecProcessingError) {
    expect(error.errors).toHaveLength(1);
  }
}
```

## Leveraging Existing Validators

If the function under test has a Zod schema for input/output validation, import and use it in tests rather than reinventing validation logic:

```typescript
// Correct: Use existing schema
import {OutputSchema} from './schemas';
const parsed = OutputSchema.safeParse(result);
expect(parsed.success).toBe(true);

// Wrong: Inline validation that duplicates schema logic
expect(typeof result).toBe('object');
expect(result).not.toBeNull();
expect(result).toHaveProperty('field1');
expect(result).toHaveProperty('field2');
```

**Anti-pattern—inline type predicates in tests:**

```typescript
// Wrong: Inline predicate that should be a Zod schema
describe('Mutation Detection', () => {
  const isValidationFailedContext = (
    value: unknown
  ): value is ValidationFailedContext => (
    typeof value === 'object' &&
    value !== null &&
    'layer' in value &&
    'reason' in value
  );
  // ...
});
```

This predicate should not exist in test code. A Zod schema should exist in the implementation for `ValidationFailedContext`, and tests should use that schema for validation and type narrowing. If no schema exists, create one in the implementation first.

## Table Tests with `it.each`

Prefer `it.each` over multiple trivial `it` blocks when testing input/output variations. Makes tests more concise and easier to maintain/extend. Use array of objects, not 2D arrays.

Define a `TestData` interface in the same file:

```typescript
interface TestData {
  description: string;
  input: InputType;
  expected: ExpectedType;
}

const testCases: TestData[] = [
  {
    description: 'handles empty input',
    input: FIXTURES.EMPTY_INPUT,
    expected: FIXTURES.EMPTY_OUTPUT,
  },
  {
    description: 'processes valid data',
    input: FIXTURES.VALID_INPUT,
    expected: FIXTURES.VALID_OUTPUT,
  },
];

it.each(testCases)('should $description', ({input, expected}) => {
  const result = processData(input);
  expect(result).toEqual(expected);
});
```

Standard keys:
- `description: string`—for legible test output
- `input`—or something semantic if appropriate
- `expected`—the expected output

## Assertion Precision

Assert on complete values wherever reasonably possible. No vague assertions.

```typescript
// Wrong: Partial match hides other issues
expect(error.message).toContain('validation');

// Correct: Complete assertion
expect(error.message).toBe('Validation failed: email field is required');

// Wrong: Loose regex
expect(output).toMatch(/success/i);

// Correct: Exact match
expect(output).toBe('Operation completed successfully');
```

Rationale: Partial matches hide typos and unintended changes elsewhere in output. The exact output *is* the behaviour being tested.

**Exception**: When asserting object structure, both inline property assertions and full object assertions are acceptable:

```typescript
// Both acceptable—choose based on clarity
expect(result.data).toHaveLength(1);
expect(result.data.at(0)?.type).toBe('text');

// Or
expect(result.data).toEqual([{type: 'text', content: 'hello'}]);
```

Use full object assertion when concise. Use property assertions when objects have getters, functions, or deep equality isn't possible.

**Avoid unnecessary variable extraction:**

```typescript
// Avoid: Extracting to variables unnecessarily
const value1 = result.data.children.at(0);
const value2 = result.data.children.at(1);
expect(value1?.type).toBe('text');
expect(value2?.type).toBe('image');

// Preferred: Assert on structure directly
expect(result.data.children).toHaveLength(2);
expect(result.data.children).toEqual([
  expect.objectContaining({type: 'text'}),
  expect.objectContaining({type: 'image'}),
]);
```

## Assertion Helpers

When repetitive assertion patterns emerge within a `describe` block, extract small helper functions scoped to that block:

```typescript
describe('parseDocument', () => {
  const expectValidDocument = (result: Result<Document, Error>) => {
    expect(isOk(result)).toBe(true);
    if (!isOk(result)) return;
    expect(result.data.version).toBe(FIXTURES.EXPECTED_VERSION);
    expect(result.data.sections.length).toBeGreaterThan(0);
  };

  it('should parse minimal document', () => {
    const result = parseDocument(FIXTURES.MINIMAL_DOC);
    expectValidDocument(result);
  });

  // ... more tests using expectValidDocument
});
```

Not exported—scoped to the describe block. Consolidate if patterns emerge across the file.

## Setup and Teardown

**Use `beforeEach`:**
- Mock reset: `vi.clearAllMocks()`
- Filesystem setup with TempFSBuilder
- Environment variable setup
- Shared fixture setup via helper: `setupExecuteAgentMocks(mockMessagesCreate)`

**Use `afterEach`:**
- Filesystem cleanup: `tempFS.cleanup()`
- Environment restoration: `process.env = originalEnv`
- Unstub environment: `vi.unstubAllEnvs()`

**Avoid `beforeEach`/`afterEach` for pure functions**—tests of pure functions don't need setup:

```typescript
describe('ok', () => {
  it('should create a successful Result', () => {
    const result = ok(42);
    expect(result.success).toBe(true);
  });
});
```

For detailed filesystem patterns, see [TEMP_FS.md](./TEMP_FS.md).

## Timeouts

Acceptable for genuinely heavy operations (transformers.js, embedding models). Not a crutch for inefficient tests.

```typescript
it('should generate embeddings for large dataset', {timeout: 30000}, async () => {
  const result = await generateEmbeddings(LARGE_DATASET);
  expect(result.vectors).toHaveLength(LARGE_DATASET.length);
});
```

Use the options object syntax `{timeout: X}` as the second argument. If a test needs a timeout, question whether it can be written more efficiently first.

## Description Style

Use imperative phrasing in test descriptions:

```typescript
// Correct
it('should parse valid JSON input', ...);
it('should throw when input is malformed', ...);
it('should return empty array for missing data', ...);

// Avoid
it('parses valid JSON input', ...);
it('valid JSON input is parsed', ...);
```

## Test Hygiene

After finishing a test file, review the entire file (including untouched existing code) for:
- Consolidation opportunities
- Redundant fixtures
- Repeated assertion patterns that could be helpers
- Opportunities to convert repetitive `it` blocks to `it.each`

Tests are documentation. Someone new to the project should understand behaviour from reading tests. Assertions should be meaningful and informative about the unit under test.

## Reference Files

**Filesystem testing**: See [TEMP_FS.md](./TEMP_FS.md) for TempFSBuilder API, cleanup patterns, and test data generators.

**API mocking**: See [API_MOCKS.md](./API_MOCKS.md) for AnthropicApiMock, CallbackTracker, content block helpers, and module mocking patterns.

**React components**: See [REACT_TESTING.md](./REACT_TESTING.md) for Testing Library patterns, selector priority, and CSS assertions.

## Anti-Patterns to Avoid

- `as` casting (except for deliberately hostile test data)
- Inline fixtures that encourage duplication
- Inline predicates that duplicate implementation validators
- Magic values not from fixtures
- `expect(x).toContain(substring)` for error messages
- Loose regex assertions
- Conditions on unasserted values
- `npx vitest` instead of `npm run test`
- Shared fixtures across unrelated concerns
- Common fixtures files (prefer per-module fixtures)
- Extracting array elements to variables unnecessarily (assert on structure directly)
- Snapshot testing
- `getByTestId` when semantic selectors would work
- Low-level selectors (`getElementById`, `querySelector`)
- Imports after `vi.mock()` that should be before
