---
name: vue-testing
description: Master Vue Testing - Vitest, Vue Test Utils, Component Testing, E2E with Playwright
sasmp_version: "1.3.0"
bonded_agent: 06-vue-testing
bond_type: PRIMARY_BOND
version: "2.0.0"
last_updated: "2025-01"
---

# Vue Testing Skill

Production-grade skill for mastering Vue application testing with Vitest, Vue Test Utils, and Playwright.

## Purpose

**Single Responsibility:** Teach comprehensive testing strategies for Vue applications including unit, component, integration, and E2E testing.

## Parameter Schema

```typescript
interface VueTestingParams {
  topic: 'unit' | 'component' | 'integration' | 'e2e' | 'mocking' | 'all';
  level: 'beginner' | 'intermediate' | 'advanced';
  context?: {
    test_runner?: 'vitest' | 'jest';
    e2e_tool?: 'playwright' | 'cypress';
    coverage_target?: number;
  };
}
```

## Learning Modules

### Module 1: Testing Fundamentals
```
Prerequisites: vue-fundamentals
Duration: 2 hours
Outcome: Set up testing environment
```

| Topic | Tool | Exercise |
|-------|------|----------|
| Setup | Vitest + VTU | Configure project |
| Test structure | describe/it/expect | First test |
| Assertions | expect matchers | Various assertions |
| Test naming | Descriptive names | Convention practice |

**Vitest Configuration:**
```typescript
// vitest.config.ts
export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    coverage: {
      provider: 'v8',
      thresholds: { lines: 80 }
    }
  }
})
```

### Module 2: Component Testing
```
Prerequisites: Module 1
Duration: 4-5 hours
Outcome: Test Vue components thoroughly
```

| Test Type | What to Test | Example |
|-----------|--------------|---------|
| Rendering | DOM output | Text content |
| Props | Input handling | Prop values |
| Events | Emitted events | Button clicks |
| Slots | Slot content | Custom content |
| Async | Loading states | API responses |

**Component Test Template:**
```typescript
import { mount } from '@vue/test-utils'
import MyComponent from './MyComponent.vue'

describe('MyComponent', () => {
  it('renders correctly', () => {
    const wrapper = mount(MyComponent, {
      props: { title: 'Test' }
    })
    expect(wrapper.text()).toContain('Test')
  })

  it('emits event on click', async () => {
    const wrapper = mount(MyComponent)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('action')).toHaveLength(1)
  })
})
```

### Module 3: Mocking Strategies
```
Prerequisites: Module 2
Duration: 3 hours
Outcome: Mock dependencies effectively
```

| Mock Type | Use Case | Example |
|-----------|----------|---------|
| Modules | API services | vi.mock() |
| Composables | Custom hooks | Return mocks |
| Timers | Debounce/setTimeout | vi.useFakeTimers() |
| HTTP | API calls | MSW or vi.mock |
| Router | Navigation | Mock router |
| Store | Pinia stores | createTestingPinia |

### Module 4: Testing Composables & Stores
```
Prerequisites: Module 3
Duration: 3 hours
Outcome: Test reusable logic
```

**Composable Testing:**
```typescript
import { useCounter } from './useCounter'

it('increments count', () => {
  const { count, increment } = useCounter()
  increment()
  expect(count.value).toBe(1)
})
```

**Store Testing:**
```typescript
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from './useUserStore'

beforeEach(() => setActivePinia(createPinia()))

it('logs in user', async () => {
  const store = useUserStore()
  await store.login(credentials)
  expect(store.isLoggedIn).toBe(true)
})
```

### Module 5: E2E Testing with Playwright
```
Prerequisites: Modules 1-4
Duration: 4 hours
Outcome: Write reliable E2E tests
```

| Concept | Playwright API | Exercise |
|---------|----------------|----------|
| Navigation | page.goto() | Page visits |
| Selectors | getByRole() | Element selection |
| Actions | click(), fill() | User interactions |
| Assertions | expect().toBeVisible() | Verify state |
| Fixtures | test.use() | Reusable setup |

**Playwright Test:**
```typescript
import { test, expect } from '@playwright/test'

test.describe('Login', () => {
  test('logs in successfully', async ({ page }) => {
    await page.goto('/login')
    await page.getByLabel('Email').fill('user@example.com')
    await page.getByLabel('Password').fill('password')
    await page.getByRole('button', { name: 'Submit' }).click()

    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Welcome')).toBeVisible()
  })
})
```

## Validation Checkpoints

### Beginner Checkpoint
- [ ] Set up Vitest with Vue
- [ ] Write basic component test
- [ ] Test props and events
- [ ] Run tests with coverage

### Intermediate Checkpoint
- [ ] Mock API calls
- [ ] Test async components
- [ ] Test composables
- [ ] Test Pinia stores

### Advanced Checkpoint
- [ ] Write E2E tests with Playwright
- [ ] Achieve 80%+ coverage
- [ ] Test edge cases
- [ ] Set up CI testing

## Retry Logic

```typescript
const skillConfig = {
  maxAttempts: 3,
  backoffMs: [1000, 2000, 4000],
  onFailure: 'provide_test_hint'
}
```

## Observability

```yaml
tracking:
  - event: test_written
    data: [test_type, component_name]
  - event: coverage_achieved
    data: [percentage, file_count]
  - event: skill_completed
    data: [tests_written, coverage]
```

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| wrapper.vm undefined | shallowMount used | Use mount() |
| Mock not working | Wrong vi.mock path | Match import path |
| Async not resolved | Missing await | Await async ops |
| Flaky E2E | Race conditions | Add proper waits |

### Debug Steps

1. Check test isolation (beforeEach cleanup)
2. Verify mock is at file top
3. Console.log wrapper.html()
4. Use Playwright trace viewer

## Unit Test Template

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import Component from './Component.vue'

describe('Component', () => {
  let wrapper: VueWrapper

  beforeEach(() => {
    wrapper = mount(Component, {
      props: {},
      global: {
        stubs: {},
        mocks: {},
        plugins: []
      }
    })
  })

  it('renders correctly', () => {
    expect(wrapper.exists()).toBe(true)
  })

  it('handles user interaction', async () => {
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('action')).toBeTruthy()
  })
})
```

## Usage

```
Skill("vue-testing")
```

## Related Skills

- `vue-fundamentals` - Prerequisite
- `vue-composition-api` - For composable testing
- `vue-pinia` - For store testing

## Resources

- [Vitest Documentation](https://vitest.dev/)
- [Vue Test Utils](https://test-utils.vuejs.org/)
- [Playwright](https://playwright.dev/)
- [Testing Library](https://testing-library.com/docs/vue-testing-library/intro/)
