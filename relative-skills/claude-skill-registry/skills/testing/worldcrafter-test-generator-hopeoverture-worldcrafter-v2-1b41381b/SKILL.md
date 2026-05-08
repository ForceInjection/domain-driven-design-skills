---
name: worldcrafter-test-generator
description: Generate comprehensive tests following three-layer pyramid - unit (Vitest), integration (real database), E2E (Playwright). Use when user needs "add tests", "improve coverage", "test [feature]", "write E2E tests", "generate test factory", or mentions testing auth, forms, database, AI features, visualizations, real-time collaboration, performance, accessibility, or import/export. Provides templates and patterns for 80%+ coverage including AI mocking, chart testing, WebSocket testing, and Page Object Models. Do NOT use when building new features (use worldcrafter-feature-builder which includes tests), database-only changes (use worldcrafter-database-setup), or simple routes (use worldcrafter-route-creator).
---

# WorldCrafter Test Generator

**Version:** 2.0.0
**Last Updated:** 2025-01-09

This skill provides tools and templates for generating comprehensive tests following WorldCrafter's three-layer testing pyramid: unit tests (Vitest), integration tests (real database), and E2E tests (Playwright).

## Skill Metadata

**Related Skills:**
- `worldcrafter-feature-builder` - Feature-builder already includes basic tests, use test-generator for additional coverage
- `worldcrafter-database-setup` - Use to create test database schema before integration tests
- `worldcrafter-auth-guard` - Test auth flows and protected routes

**Example Use Cases:**
- "Add tests for the user profile component" → Generates component test with rendering, interaction, and validation tests
- "Write integration tests for blog post Server Actions" → Creates integration test file with database operations, RLS policy tests, and cleanup
- "Create E2E tests for checkout flow" → Generates Playwright test with Page Object Model for multi-step checkout
- "Generate test factory for BlogPost model" → Creates factory function using faker.js for test data generation

## When to Use This Skill

Use this skill when:
- Writing tests for new components or features
- Adding integration tests for Server Actions
- Creating E2E tests for user flows
- Generating test data factories
- Achieving coverage goals (80%+)
- Setting up Page Object Models for E2E tests
- Mocking Supabase or Prisma in tests
- Writing tests for authentication flows

## WorldCrafter Testing Strategy

### Three-Layer Testing Pyramid

**1. Unit Tests (60-70% of tests)** - Vitest + React Testing Library
- Test components in isolation
- Test utility functions and pure logic
- Fast execution (<100ms per test)
- Mocked dependencies

**2. Integration Tests (20-30% of tests)** - Vitest + Real Test Database
- Test Server Actions with actual database
- Test database operations and RLS policies
- Verify data flows
- Use separate test database

**3. E2E Tests (10-20% of tests)** - Playwright
- Test complete user workflows
- Test across browsers (Chromium, Firefox, Mobile)
- Critical paths only
- Use Page Object Model pattern

**Coverage Goal**: 80%+ overall (enforced by Vitest)

## Test Generation Process

### Phase 1: Identify What to Test

**For Components:**
- Rendering behavior
- User interactions
- Form validation
- State changes
- Error handling

**For Server Actions:**
- Input validation
- Authentication checks
- Database operations
- Error handling
- RLS policy enforcement

**For User Flows:**
- Login/signup
- Form submissions
- CRUD operations
- Navigation
- Error scenarios

### Phase 2: Generate Test Files

**Automated Generation:**

For component tests:
```bash
python .claude/skills/worldcrafter-test-generator/scripts/generate_tests.py component <ComponentName>
```

For integration tests:
```bash
python .claude/skills/worldcrafter-test-generator/scripts/generate_tests.py integration <feature-name>
```

For E2E tests:
```bash
python .claude/skills/worldcrafter-test-generator/scripts/generate_e2e.py <feature-name>
```

For test factories:
```bash
python .claude/skills/worldcrafter-test-generator/scripts/generate_factory.py <ModelName>
```

**Manual Approach:**
Copy templates from `assets/templates/` and customize.

### Phase 3: Write Unit Tests

**Component Testing Pattern:**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { renderWithProviders, screen, userEvent } from '@/test/utils/render'
import YourComponent from '../YourComponent'

describe('YourComponent', () => {
  it('renders correctly', () => {
    renderWithProviders(<YourComponent />)
    expect(screen.getByRole('heading')).toBeInTheDocument()
  })

  it('handles user interaction', async () => {
    const user = userEvent.setup()
    renderWithProviders(<YourComponent />)

    await user.click(screen.getByRole('button'))
    expect(screen.getByText(/success/i)).toBeInTheDocument()
  })
})
```

**Utility Testing Pattern:**

```typescript
import { describe, it, expect } from 'vitest'
import { yourUtility } from '../utils'

describe('yourUtility', () => {
  it('handles valid input', () => {
    expect(yourUtility('input')).toBe('expected')
  })

  it('handles edge cases', () => {
    expect(yourUtility('')).toBe('default')
  })
})
```

**Reference**: `references/testing-patterns.md` for more examples

### Phase 4: Write Integration Tests

**Server Action Testing Pattern:**

```typescript
import { describe, it, expect, afterAll } from 'vitest'
import { prisma } from '@/lib/prisma'
import { submitFeature } from '../actions'

describe('Feature Integration Tests', () => {
  const createdIds: string[] = []

  afterAll(async () => {
    // Clean up test data
    await prisma.feature.deleteMany({
      where: { id: { in: createdIds } }
    })
  })

  it('creates record in database', async () => {
    const result = await submitFeature({
      title: 'Test Feature'
    })

    expect(result.success).toBe(true)
    createdIds.push(result.data!.id)

    // Verify in database
    const dbRecord = await prisma.feature.findUnique({
      where: { id: result.data!.id }
    })
    expect(dbRecord).toBeTruthy()
  })
})
```

**Key Points:**
- Use real test database (`.env.test`)
- Clean up data in `afterAll`
- Test actual database operations
- Verify RLS policies work

**Reference**: `references/testing-patterns.md` for integration test patterns

### Phase 5: Write E2E Tests

**E2E Testing Pattern (with Page Object Model):**

Create Page Object:
```typescript
// e2e/pages/feature.page.ts
import { Page, Locator } from '@playwright/test'

export class FeaturePage {
  readonly page: Page
  readonly titleInput: Locator
  readonly submitButton: Locator

  constructor(page: Page) {
    this.page = page
    this.titleInput = page.locator('input[name="title"]')
    this.submitButton = page.locator('button[type="submit"]')
  }

  async goto() {
    await this.page.goto('/feature')
  }

  async submitForm(title: string) {
    await this.titleInput.fill(title)
    await this.submitButton.click()
  }
}
```

Write E2E test:
```typescript
// e2e/feature.spec.ts
import { test, expect } from '@playwright/test'
import { FeaturePage } from './pages/feature.page'

test('user can submit feature', async ({ page }) => {
  const featurePage = new FeaturePage(page)

  await featurePage.goto()
  await featurePage.submitForm('Test Feature')

  await expect(page.locator('text=Success')).toBeVisible()
})
```

**Reference**: `references/testing-patterns.md` for E2E patterns

### Phase 6: Create Test Data Factories

**Factory Pattern:**

```typescript
// src/test/factories/user.ts
import { faker } from '@faker-js/faker'

export function createMockUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides
  }
}
```

**Usage:**
```typescript
const user = createMockUser({ email: 'test@example.com' })
```

**Generate factory:**
```bash
python .claude/skills/worldcrafter-test-generator/scripts/generate_factory.py User
```

### Phase 7: Mock Dependencies

**Mocking Patterns:**

Reference `references/mocking-guide.md` for:
- Mocking Supabase client
- Mocking Prisma client
- Mocking Next.js router
- Mocking Server Actions
- Mocking fetch/API calls

**Example: Mock Server Action**
```typescript
import { vi } from 'vitest'

vi.mock('../actions', () => ({
  submitFeature: vi.fn().mockResolvedValue({
    success: true,
    data: { id: '1', title: 'Test' }
  })
}))
```

### Phase 8: Run Tests and Check Coverage

```bash
# Run unit tests (watch mode)
npm test

# Run with coverage
npm run test:coverage

# Run E2E tests
npm run test:e2e

# Run all tests
npm run test:all
```

**Coverage Report:**
- View HTML report: `coverage/index.html`
- Check coverage thresholds (80% required)
- Identify untested code

## Testing Best Practices

### Query Priority (React Testing Library)

1. **getByRole** - Preferred (accessibility)
   ```typescript
   screen.getByRole('button', { name: /submit/i })
   ```

2. **getByLabelText** - Forms
   ```typescript
   screen.getByLabelText(/email/i)
   ```

3. **getByText** - Static content
   ```typescript
   screen.getByText(/welcome/i)
   ```

4. **getByTestId** - Last resort
   ```typescript
   screen.getByTestId('custom-element')
   ```

### Async Testing

```typescript
import { waitFor } from '@testing-library/react'

// Wait for element
await waitFor(() => {
  expect(screen.getByText(/loaded/i)).toBeInTheDocument()
})

// Wait for element to disappear
await waitForElementToBeRemoved(() => screen.queryByText(/loading/i))
```

### User Events

```typescript
import { userEvent } from '@testing-library/user-event'

const user = userEvent.setup()

await user.type(input, 'Hello')
await user.click(button)
await user.selectOptions(select, 'option1')
```

### Test Organization

**Describe blocks:**
```typescript
describe('FeatureComponent', () => {
  describe('rendering', () => {
    it('renders heading', () => { /* ... */ })
  })

  describe('user interactions', () => {
    it('handles click', () => { /* ... */ })
  })
})
```

### Setup and Teardown

```typescript
beforeEach(() => {
  // Run before each test
})

afterEach(() => {
  // Run after each test
})

beforeAll(() => {
  // Run once before all tests
})

afterAll(() => {
  // Run once after all tests
})
```

## Common Testing Patterns

### Testing Forms

```typescript
test('validates required fields', async () => {
  const user = userEvent.setup()
  renderWithProviders(<Form />)

  await user.click(screen.getByRole('button', { name: /submit/i }))

  expect(screen.getByText(/required/i)).toBeInTheDocument()
})

test('submits valid data', async () => {
  const user = userEvent.setup()
  const onSubmit = vi.fn()
  renderWithProviders(<Form onSubmit={onSubmit} />)

  await user.type(screen.getByLabelText(/name/i), 'John')
  await user.click(screen.getByRole('button', { name: /submit/i }))

  await waitFor(() => {
    expect(onSubmit).toHaveBeenCalledWith({ name: 'John' })
  })
})
```

### Testing Authentication

```typescript
test('redirects when not authenticated', async ({ page }) => {
  await page.goto('/protected')
  await expect(page).toHaveURL('/login')
})

test('shows protected content when authenticated', async ({ page }) => {
  // Login first
  await loginAs('user@example.com', 'password')

  await page.goto('/protected')
  await expect(page.locator('h1')).toContainText('Protected')
})
```

### Testing Database Operations

```typescript
test('enforces RLS policies', async () => {
  // Create user's record
  const userRecord = await prisma.post.create({
    data: { authorId: 'user1', title: 'User 1 Post' }
  })

  // Try to access as different user (should fail)
  // This requires mocking auth context
  const result = await getPost(userRecord.id, 'user2')

  expect(result).toBeNull() // RLS blocked access
})
```

## Advanced Testing Patterns (v2.0)

### Testing AI Features

WorldCrafter integrates AI for story generation, character creation, and world-building. See `references/testing-patterns.md` for comprehensive patterns:

- **Mocking AI APIs**: Mock OpenAI/Anthropic SDK calls with `vi.mock('ai')`
- **Response Validation**: Test JSON parsing and Zod schema validation
- **Rate Limiting**: Test request throttling with fake timers
- **Cost Tracking**: Test token usage and budget enforcement
- **Streaming**: Test SSE/streaming responses with async generators
- **Error Handling**: Test retries, timeouts, and API failures

**Example:**
```typescript
vi.mock('ai', () => ({
  generateText: vi.fn()
}))

it('generates character from AI', async () => {
  const { generateText } = await import('ai')
  vi.mocked(generateText).mockResolvedValue({
    text: JSON.stringify({ name: 'Aria', class: 'Mage' }),
    usage: { totalTokens: 100 }
  })

  const character = await generateCharacter({ archetype: 'mage' })
  expect(character.name).toBe('Aria')
})
```

See `references/testing-patterns.md` → "AI Feature Testing Patterns" for full examples.

### Testing Visualizations

WorldCrafter uses canvas/SVG for timelines, relationship graphs, and world maps. See comprehensive patterns for:

- **Canvas Rendering**: Verify canvas elements with Playwright
- **Interactive Charts**: Test pan, zoom, drag with mouse events
- **Graph Layouts**: Unit test force-directed algorithms
- **Timeline Filtering**: Test date range and category filters
- **Map Markers**: Test marker placement and interactions
- **Visual Regression**: Screenshot comparison with baseline

**Example:**
```typescript
test('timeline renders events', async ({ page }) => {
  await page.goto('/world/timeline')

  const canvas = page.locator('canvas[data-timeline]')
  await expect(canvas).toBeVisible()

  const events = page.locator('svg circle.event-marker')
  await expect(events).toHaveCount(5)
})
```

See `references/testing-patterns.md` → "Visualization Testing Patterns" for full examples.

### Testing Real-time Collaboration

WorldCrafter supports multi-user editing with WebSockets. See patterns for:

- **WebSocket Mocking**: Mock connection with `vi.fn(() => mockWs)`
- **Presence Indicators**: Test user avatars and cursors
- **Optimistic Updates**: Test immediate UI updates with eventual consistency
- **Conflict Resolution**: Test last-write-wins and merge strategies
- **Concurrent Edits**: Multi-page tests with Playwright context

**Example:**
```typescript
let mockWs: any
beforeEach(() => {
  mockWs = {
    send: vi.fn(),
    addEventListener: vi.fn()
  }
  global.WebSocket = vi.fn(() => mockWs) as any
})

it('sends presence updates', () => {
  const collab = createCollaborationClient({ worldId: '123' })
  collab.updatePresence({ viewing: 'char-456' })

  expect(mockWs.send).toHaveBeenCalledWith(
    expect.stringContaining('"type":"presence"')
  )
})
```

See `references/testing-patterns.md` → "Real-time Collaboration Testing Patterns" for full examples.

### Testing Performance

Ensure WorldCrafter meets performance targets:

- **Page Load**: Test initial load < 200ms with Playwright
- **API Response**: Test endpoints < 100ms with `performance.now()`
- **Database Queries**: Profile queries < 50ms with Prisma event logging
- **Bundle Size**: Test gzipped bundles < 200KB
- **Lighthouse CI**: Automated performance audits

**Example:**
```typescript
test('world list loads fast', async ({ page }) => {
  const start = Date.now()
  await page.goto('/worlds')
  await page.waitForSelector('[data-testid="world-list"]')

  expect(Date.now() - start).toBeLessThan(200)
})
```

See `references/testing-patterns.md` → "Performance Testing Patterns" for full examples.

### Testing Accessibility

Ensure WCAG 2.1 AA compliance:

- **axe-core**: Automated a11y scanning with `@axe-core/playwright`
- **Color Contrast**: Test sufficient contrast ratios
- **Keyboard Navigation**: Test Tab, Enter, Escape, Arrow keys
- **Screen Readers**: Test ARIA labels, live regions, roles
- **Form Labels**: Ensure all inputs have proper labels

**Example:**
```typescript
import AxeBuilder from '@axe-core/playwright'

test('page is accessible', async ({ page }) => {
  await page.goto('/worlds')

  const results = await new AxeBuilder({ page }).analyze()
  expect(results.violations).toEqual([])
})
```

See `references/testing-patterns.md` → "Accessibility Testing Patterns" for full examples.

### Testing Import/Export

WorldCrafter supports CSV, Markdown, and JSON import/export:

- **CSV Parsing**: Test quoted fields, validation, field mapping
- **Markdown Export**: Test formatting, escaping special chars
- **JSON Import/Export**: Test schema validation, data integrity
- **Field Mapping**: Test auto-detection and manual mapping UI
- **File Download**: Test Playwright download events

**Example:**
```typescript
test('downloads CSV', async ({ page }) => {
  await page.goto('/characters')

  const [download] = await Promise.all([
    page.waitForEvent('download'),
    page.click('button:has-text("Export CSV")')
  ])

  expect(download.suggestedFilename()).toMatch(/\.csv$/)
})
```

See `references/testing-patterns.md` → "Import/Export Testing Patterns" for full examples.

## Test Generation Scripts Reference

```bash
# Generate component test
python .claude/skills/worldcrafter-test-generator/scripts/generate_tests.py component Button

# Generate integration test
python .claude/skills/worldcrafter-test-generator/scripts/generate_tests.py integration user-profile

# Generate E2E test
python .claude/skills/worldcrafter-test-generator/scripts/generate_e2e.py checkout-flow

# Generate test factory
python .claude/skills/worldcrafter-test-generator/scripts/generate_factory.py User
```

## Troubleshooting

### Tests Failing Due to Mocks

- Check mock implementation matches actual API
- Verify mock is properly scoped
- Clear mocks between tests: `vi.clearAllMocks()`

### E2E Tests Timing Out

- Increase timeout: `test.setTimeout(60000)`
- Use proper wait conditions
- Check network requests in browser devtools

### Coverage Not Meeting Threshold

- Identify untested files: `npm run test:coverage`
- Focus on critical paths first
- Add tests for edge cases

### Test Database Issues

- Ensure `.env.test` is configured
- Verify test database is separate from dev
- Clean up data in `afterAll` hooks

## Reference Files

- `references/testing-patterns.md` - Comprehensive testing patterns
- `references/mocking-guide.md` - How to mock dependencies
- `references/assertion-guide.md` - Common assertions and utilities
- `references/related-skills.md` - How this skill works with other WorldCrafter skills
- `assets/templates/` - Complete test templates

## Skill Orchestration

This skill is typically used to ADD test coverage to existing code or to supplement tests generated by other skills.

### Common Workflows

**Adding Tests to Existing Features:**
1. **worldcrafter-test-generator** (this skill) - Add unit, integration, or E2E tests
2. Run tests to verify coverage meets goals

**Complete Feature Development (Database-First):**
1. **worldcrafter-database-setup** - Create database schema
2. **worldcrafter-feature-builder** - Build UI and Server Actions (includes basic tests)
3. **worldcrafter-test-generator** (this skill) - Add additional test coverage if needed
4. **worldcrafter-auth-guard** - Add authentication (test auth flows)

**Testing Authentication Features:**
1. **worldcrafter-auth-guard** - Implement auth logic
2. **worldcrafter-test-generator** (this skill) - Create auth-specific tests (login, protected routes, etc.)

**Improving Coverage:**
1. Run `npm run test:coverage` to identify gaps
2. **worldcrafter-test-generator** (this skill) - Generate tests for untested code
3. Verify coverage meets 80% threshold

### When Claude Should Use Multiple Skills

Claude will orchestrate test-generator with other skills when:
- Feature-builder creates a feature AND user explicitly requests additional tests
- User wants to test existing code that wasn't generated by skills
- User requests specific test types (integration, E2E, factories) not covered by feature-builder

**Example orchestration:**
```
User: "Add a comments feature and make sure it has comprehensive test coverage"

Claude's workflow:
1. worldcrafter-database-setup: Create Comment model
2. worldcrafter-feature-builder: Create comment form and Server Actions (includes basic tests)
3. worldcrafter-test-generator (this skill): Add edge case tests, RLS policy tests, E2E tests for comment threading
```

### Skill Selection Guidance

**Choose this skill when:**
- User explicitly mentions "tests", "testing", "coverage", "E2E", "integration tests"
- User wants to test existing code
- Feature-builder was used but additional test coverage is needed
- User wants specific test scenarios (auth, RLS, edge cases)

**Choose worldcrafter-feature-builder instead when:**
- User wants a complete feature from scratch
- Feature-builder includes basic tests automatically
- No need for additional test coverage beyond feature-builder's output

**Use this skill AFTER feature-builder when:**
- User requests "comprehensive" or "thorough" testing
- User wants to test edge cases or specific scenarios
- Coverage reports show gaps

## Testing Checklist

For each feature:

**Core Testing:**
- [ ] Unit tests for components (rendering, interactions)
- [ ] Unit tests for utilities and pure functions
- [ ] Integration tests for Server Actions
- [ ] Integration tests for database operations
- [ ] E2E tests for critical user flows
- [ ] Test data factories created
- [ ] Mocks properly configured
- [ ] Authentication tests (if applicable)
- [ ] Error handling tested
- [ ] Loading states tested

**AI Features (if applicable):**
- [ ] AI API mocking configured
- [ ] Response parsing/validation tested
- [ ] Rate limiting tested
- [ ] Cost tracking tested
- [ ] Streaming responses tested
- [ ] Error handling for AI failures

**Visualizations (if applicable):**
- [ ] Canvas/SVG rendering tested
- [ ] Interactive features tested (pan, zoom, drag)
- [ ] Layout algorithms tested
- [ ] Visual regression tests
- [ ] Responsive viewport tests

**Real-time Collaboration (if applicable):**
- [ ] WebSocket/SSE mocking configured
- [ ] Presence indicators tested
- [ ] Optimistic updates tested
- [ ] Conflict resolution tested
- [ ] Concurrent edits tested

**Performance:**
- [ ] Page load times < target (200-300ms)
- [ ] API response times measured
- [ ] Database queries profiled
- [ ] Bundle size monitored

**Accessibility:**
- [ ] axe-core scans passing
- [ ] WCAG 2.1 AA compliance
- [ ] Keyboard navigation tested
- [ ] Screen reader compatibility tested

**Import/Export (if applicable):**
- [ ] CSV parsing tested
- [ ] Markdown export tested
- [ ] JSON import/export tested
- [ ] Field mapping tested
- [ ] File download tested

**Final Verification:**
- [ ] Coverage meets 80% threshold
- [ ] All tests pass: `npm run test:all`

## Success Criteria

Complete test coverage includes:
- ✅ Unit tests with >80% coverage
- ✅ Integration tests for all Server Actions
- ✅ E2E tests for critical paths
- ✅ Test data factories for models
- ✅ Proper mocking of dependencies
- ✅ Clean test data management
- ✅ Fast unit tests (<100ms)
- ✅ All tests pass in CI/CD
- ✅ Page Object Models for E2E tests
