---
name: component-testing
description: Write comprehensive unit tests for Visual Layout Builder using Vitest. Use when creating tests for lib/ functions, schema validation, canvas utilities, or any business logic. Follows AAA pattern and project testing conventions.
allowed-tools: Read, Glob, Grep
---

# Component Testing Skill

Visual Layout Builder 프로젝트의 Vitest 기반 유닛 테스트 작성을 위한 전문 스킬입니다. 579+ 테스트, ~14,000 라인의 테스트 코드 패턴을 따릅니다.

## When to Use

- `lib/` 디렉토리의 새로운 함수 테스트 작성
- 기존 테스트 파일 수정 또는 확장
- 버그 수정 후 회귀 테스트 추가
- 스키마 검증 로직 테스트
- Canvas 유틸리티 테스트
- 성능 테스트 작성

## Test File Structure

```
lib/__tests__/
├── [module-name].test.ts       # Main test file
├── fixtures/                   # Shared test data
│   ├── component-fixtures.ts
│   └── test-schemas.ts
└── README.md                   # Test documentation
```

## Test File Naming Convention

```typescript
// Pattern: [module-name].test.ts
schema-validation.test.ts
canvas-utils.test.ts
prompt-generator.test.ts

// For specific features:
schema-utils-dynamic-breakpoints.test.ts
component-linking-concurrent.test.ts
```

## Basic Test Template

```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { functionToTest } from '../module-name'

describe('ModuleName', () => {
  describe('functionToTest', () => {
    it('should perform expected behavior when given valid input', () => {
      // Arrange: 테스트 데이터 준비
      const input = { /* test data */ }

      // Act: 동작 수행
      const result = functionToTest(input)

      // Assert: 결과 검증
      expect(result).toBe(expectedValue)
    })

    it('should handle edge case appropriately', () => {
      // Arrange
      const edgeCaseInput = { /* edge case */ }

      // Act
      const result = functionToTest(edgeCaseInput)

      // Assert
      expect(result).toMatchObject({ /* expected shape */ })
    })

    it('should throw error for invalid input', () => {
      // Arrange
      const invalidInput = null

      // Act & Assert
      expect(() => functionToTest(invalidInput)).toThrow('Expected error message')
    })
  })
})
```

## AAA Pattern (Arrange-Act-Assert)

항상 AAA 패턴을 따르세요:

```typescript
describe('Schema Validation', () => {
  it('should validate component name is PascalCase', () => {
    // Arrange: 초기 데이터 준비
    const schema: LaydlerSchema = {
      schemaVersion: '2.0',
      components: [{
        id: 'c1',
        name: 'invalidName',  // lowercase - should fail
        semanticTag: 'header',
        positioning: { type: 'sticky' },
        layout: { type: 'flex' }
      }],
      breakpoints: [{ name: 'mobile', minWidth: 0, gridCols: 4, gridRows: 8 }],
      layouts: { mobile: { structure: 'vertical', components: ['c1'] } }
    }

    // Act: 동작 수행
    const result = validateSchema(schema)

    // Assert: 결과 검증
    expect(result.valid).toBe(false)
    expect(result.errors).toContainEqual(
      expect.objectContaining({
        code: 'INVALID_COMPONENT_NAME',
        componentId: 'c1'
      })
    )
  })
})
```

## Schema Testing Patterns

### Valid Schema Fixture

```typescript
// fixtures/test-schemas.ts
export const createValidSchema = (overrides = {}): LaydlerSchema => ({
  schemaVersion: '2.0',
  components: [{
    id: 'c1',
    name: 'Header',
    semanticTag: 'header',
    positioning: { type: 'sticky', position: { top: 0 } },
    layout: { type: 'flex', flex: { direction: 'row', justify: 'between' } },
    responsiveCanvasLayout: {
      mobile: { x: 0, y: 0, width: 4, height: 1 }
    }
  }],
  breakpoints: [
    { name: 'mobile', minWidth: 0, gridCols: 4, gridRows: 8 }
  ],
  layouts: {
    mobile: { structure: 'vertical', components: ['c1'] }
  },
  ...overrides
})
```

### Testing Validation Errors

```typescript
describe('Schema Validation - Error Cases', () => {
  it('should detect invalid breakpoint name', () => {
    const schema = createValidSchema({
      breakpoints: [
        { name: 'mobile@tablet', minWidth: 0, gridCols: 4, gridRows: 8 }
      ]
    })

    const result = validateSchema(schema)

    expect(result.valid).toBe(false)
    expect(result.errors[0].code).toBe('INVALID_BREAKPOINT_NAME')
  })

  it('should detect too many breakpoints', () => {
    const schema = createValidSchema({
      breakpoints: Array.from({ length: 11 }, (_, i) => ({
        name: `bp${i}`,
        minWidth: i * 100,
        gridCols: 4,
        gridRows: 8
      }))
    })

    const result = validateSchema(schema)

    expect(result.errors).toContainEqual(
      expect.objectContaining({ code: 'TOO_MANY_BREAKPOINTS' })
    )
  })
})
```

## Canvas Testing Patterns

### Canvas Layout Testing

```typescript
describe('Canvas Utils', () => {
  describe('getCanvasLayoutForBreakpoint', () => {
    it('should return layout for existing breakpoint', () => {
      const component: Component = {
        id: 'c1',
        name: 'Header',
        semanticTag: 'header',
        positioning: { type: 'sticky' },
        layout: { type: 'flex' },
        responsiveCanvasLayout: {
          mobile: { x: 0, y: 0, width: 4, height: 1 },
          desktop: { x: 0, y: 0, width: 12, height: 1 }
        }
      }

      const result = getCanvasLayoutForBreakpoint(component, 'desktop')

      expect(result).toEqual({ x: 0, y: 0, width: 12, height: 1 })
    })

    it('should return undefined for missing breakpoint', () => {
      const component: Component = {
        id: 'c1',
        name: 'Header',
        semanticTag: 'header',
        positioning: { type: 'sticky' },
        layout: { type: 'flex' }
      }

      const result = getCanvasLayoutForBreakpoint(component, 'tablet')

      expect(result).toBeUndefined()
    })
  })
})
```

### Grid Constraint Testing

```typescript
describe('Grid Constraints', () => {
  it('should calculate minimum grid size based on components', () => {
    const components: Component[] = [
      createComponent({
        responsiveCanvasLayout: {
          mobile: { x: 0, y: 0, width: 4, height: 2 }
        }
      }),
      createComponent({
        responsiveCanvasLayout: {
          mobile: { x: 0, y: 2, width: 3, height: 3 }
        }
      })
    ]

    const { minCols, minRows } = calculateMinimumGridSize(components, 'mobile')

    expect(minCols).toBe(4)  // Max x + width
    expect(minRows).toBe(5)  // Max y + height
  })
})
```

## Performance Testing

```typescript
describe('Performance', () => {
  it('should calculate link groups in under 50ms for 100 components', () => {
    // Arrange
    const componentIds = Array.from({ length: 100 }, (_, i) => `c${i}`)
    const links = Array.from({ length: 50 }, (_, i) => ({
      source: `c${i * 2}`,
      target: `c${i * 2 + 1}`
    }))

    // Act
    const startTime = performance.now()
    const result = calculateLinkGroups(componentIds, links)
    const endTime = performance.now()

    // Assert
    expect(endTime - startTime).toBeLessThan(50)
    expect(result.size).toBeGreaterThan(0)
  })
})
```

## Mocking Patterns

### Mocking Store

```typescript
import { vi } from 'vitest'

vi.mock('@/store/layout-store', () => ({
  useLayoutStore: vi.fn(() => ({
    schema: mockSchema,
    addComponent: vi.fn(),
    updateComponent: vi.fn()
  }))
}))
```

### Mocking External Modules

```typescript
vi.mock('konva', () => ({
  Stage: vi.fn(),
  Layer: vi.fn(),
  Rect: vi.fn()
}))
```

## Test Organization Best Practices

### Group Related Tests

```typescript
describe('Prompt Generator', () => {
  describe('generatePrompt', () => {
    describe('with valid schema', () => {
      it('should generate prompt successfully', () => { /* ... */ })
      it('should include all components', () => { /* ... */ })
      it('should include canvas layout info', () => { /* ... */ })
    })

    describe('with invalid schema', () => {
      it('should return errors for invalid components', () => { /* ... */ })
      it('should return warnings for suboptimal positioning', () => { /* ... */ })
    })

    describe('with component links', () => {
      it('should include link section in prompt', () => { /* ... */ })
      it('should validate links before including', () => { /* ... */ })
    })
  })
})
```

### Use Test Fixtures

```typescript
// At top of test file
import {
  createValidSchema,
  createValidComponent,
  createComponentWithCanvas
} from './fixtures/test-schemas'

describe('Schema Utils', () => {
  it('should normalize schema with inheritance', () => {
    const schema = createValidSchema({
      breakpoints: [
        { name: 'mobile', minWidth: 0, gridCols: 4, gridRows: 8 },
        { name: 'tablet', minWidth: 768, gridCols: 8, gridRows: 8 },
        { name: 'desktop', minWidth: 1024, gridCols: 12, gridRows: 8 }
      ]
    })

    const result = normalizeSchema(schema)

    // Assertions...
  })
})
```

## Running Tests

```bash
# Watch mode (development)
pnpm test

# Run once (CI)
pnpm test:run

# With UI
pnpm test:ui

# With coverage
pnpm test:coverage
```

## Test Coverage Targets

- **핵심 비즈니스 로직**: 80%+ 커버리지
- **새로운 기능**: 반드시 테스트 포함
- **버그 수정**: 회귀 테스트 추가 필수

## Reference Files

- `lib/__tests__/fixtures/test-schemas.ts` - 공통 테스트 픽스처
- `lib/__tests__/fixtures/component-fixtures.ts` - 컴포넌트 픽스처
- `vitest.config.ts` - Vitest 설정
- `lib/__tests__/README.md` - 테스트 문서
