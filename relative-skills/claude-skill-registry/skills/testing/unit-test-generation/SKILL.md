---
name: unit-test-generation
description: Generate comprehensive unit tests for source files with 100% coverage target. Use when writing tests for React components, utility functions, hooks, or API routes. Supports Jest and Vitest frameworks following Pandora coding standards.
allowed-tools: Read, Grep, Glob, Bash
---

# Unit Test Generation Skill

Generate comprehensive unit tests for any source code with a target of 100% coverage.

## When to Use

This skill activates when:
- User asks for unit tests for a file or component
- Code needs test coverage
- User mentions "test", "coverage", "jest", "vitest"
- After writing new code that needs testing

## Supported File Types

- React components (`.tsx`, `.jsx`)
- Utility functions (`.ts`, `.js`)
- Custom hooks (`use*.ts`, `use*.tsx`)
- API routes (`route.ts`, `api/*.ts`)
- Classes and modules

## Test Generation Process

1. **Analyze the source file**:
   - Identify exported functions, components, hooks
   - Map conditional branches and logic paths
   - Note dependencies and imports

2. **Generate test cases for**:
   - Happy path scenarios
   - Edge cases (empty, null, boundary)
   - Error handling paths
   - All branches and conditions

3. **Write test code following patterns**:
   - Use React Testing Library for components
   - Mock external dependencies
   - Use descriptive test names
   - Group with describe blocks

## Test File Template

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { ComponentName } from './ComponentName';

describe('ComponentName', () => {
  describe('rendering', () => {
    it('should render correctly with default props', () => {
      render(<ComponentName />);
      expect(screen.getByRole('...')).toBeInTheDocument();
    });
  });

  describe('interactions', () => {
    it('should handle click events', () => {
      const onClick = jest.fn();
      render(<ComponentName onClick={onClick} />);
      fireEvent.click(screen.getByRole('button'));
      expect(onClick).toHaveBeenCalled();
    });
  });

  describe('edge cases', () => {
    it('should handle empty props gracefully', () => {
      render(<ComponentName items={[]} />);
      expect(screen.getByText('No items')).toBeInTheDocument();
    });
  });
});
```

## Best Practices

- Test behavior, not implementation
- Use meaningful test descriptions
- Keep tests independent and isolated
- Mock external services and APIs
- Test accessibility where applicable
- Aim for 100% branch coverage
- Follow AAA pattern (Arrange, Act, Assert)
