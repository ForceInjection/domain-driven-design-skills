---
name: create-unit-test
description: Create Vitest unit tests following project patterns. Use when writing tests for functions, components, models, or route loaders/actions.
---

# Create Unit Test

Creates Vitest unit tests following Iridium testing patterns with proper mocking.

## When to Use

- Writing tests for any code
- User asks to "add tests", "write unit tests", or "test this function"
- After implementing new features that need test coverage

## Test File Location & Naming

Tests are **co-located** with source files:

```
app/
├── components/
│   ├── Button.tsx
│   └── Button.test.tsx          # Component test
├── lib/
│   ├── form-validation.server.ts
│   └── form-validation.server.test.ts  # Utility test
└── models/
    ├── user.server.ts
    └── user.server.test.ts      # Model test
```

**Naming:**
- `*.test.ts` - TypeScript utility/library tests
- `*.test.tsx` - React component tests

## Test Template

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('Feature Name', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('does something specific', () => {
        // Arrange
        const input = 'test';

        // Act
        const result = functionUnderTest(input);

        // Assert
        expect(result).toBe('expected');
    });
});
```

## Pattern 1: Component Testing

Use React Testing Library. Focus on **user behavior**, not implementation.

```tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '~/test/utils';
import { Button } from './Button';

describe('Button Component', () => {
    it('renders with default props', () => {
        render(<Button>Click me</Button>);

        const button = screen.getByRole('button', { name: /click me/i });
        expect(button).toBeInTheDocument();
        expect(button).toHaveClass('btn');
    });

    it('handles click events', () => {
        const handleClick = vi.fn();
        render(<Button onClick={handleClick}>Click me</Button>);

        screen.getByRole('button').click();

        expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('shows loading state', () => {
        render(<Button loading>Submit</Button>);

        expect(screen.getByRole('button')).toBeDisabled();
    });
});
```

**Key principles:**
- Query by role, label, or text (NOT class or test IDs)
- Use semantic queries: `getByRole`, `getByLabelText`, `getByText`
- Test user interactions (clicks, typing)

## Pattern 2: Utility/Library Testing

Test pure functions with input/output assertions.

```typescript
import { describe, it, expect } from 'vitest';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { validateFormData } from './form-validation.server';

const testSchema = z.object({
    name: z.string().min(1, 'Name is required'),
    email: z.string().email('Invalid email'),
});

describe('validateFormData', () => {
    it('validates correct form data', async () => {
        const formData = new FormData();
        formData.append('name', 'John Doe');
        formData.append('email', 'john@example.com');

        const result = await validateFormData(
            formData,
            zodResolver(testSchema),
        );

        expect(result.data).toEqual({
            name: 'John Doe',
            email: 'john@example.com',
        });
        expect(result.errors).toBeUndefined();
    });

    it('returns errors for invalid data', async () => {
        const formData = new FormData();
        formData.append('name', '');
        formData.append('email', 'invalid');

        const result = await validateFormData(
            formData,
            zodResolver(testSchema),
        );

        expect(result.errors?.name).toBeDefined();
        expect(result.errors?.email).toBeDefined();
    });
});
```

## Pattern 3: Model Layer Testing

Mock Prisma client. Verify correct queries and data transformations.

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Role } from '~/generated/prisma/client';
import { getUserProfile, updateUser } from './user.server';

// Mock BEFORE importing prisma
vi.mock('~/db.server', () => ({
    prisma: {
        user: {
            findUnique: vi.fn(),
            update: vi.fn(),
        },
    },
}));

import { prisma } from '~/db.server';

describe('User Model', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('fetches user profile by ID', async () => {
        const mockProfile = {
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
            role: Role.USER,
        };

        vi.mocked(prisma.user.findUnique).mockResolvedValue(mockProfile as any);

        const result = await getUserProfile('user-123');

        expect(prisma.user.findUnique).toHaveBeenCalledWith({
            where: { id: 'user-123' },
            select: expect.objectContaining({
                id: true,
                email: true,
                name: true,
            }),
        });
        expect(result).toEqual(mockProfile);
    });
});
```

**Critical:** Mock `~/db.server` BEFORE importing it.

## Pattern 4: Route Loader/Action Testing

Mock dependencies and verify responses.

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { loader, action } from './profile';
import { createMockRequest } from '~/test/utils';

// Mock dependencies
vi.mock('~/lib/session.server');
vi.mock('~/models/user.server');

import { requireUser } from '~/lib/session.server';
import { getUserProfile, updateUser } from '~/models/user.server';

describe('Profile Route', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('loader', () => {
        it('returns user profile', async () => {
            const mockUser = { id: 'user-123' };
            const mockProfile = { id: 'user-123', name: 'Test' };

            vi.mocked(requireUser).mockResolvedValue(mockUser as any);
            vi.mocked(getUserProfile).mockResolvedValue(mockProfile as any);

            const request = createMockRequest({
                url: 'http://localhost:5173/profile',
            });

            const response = await loader({
                request,
                params: {},
                context: {},
            });

            const data = await response.json();
            expect(data.profile).toEqual(mockProfile);
        });
    });

    describe('action', () => {
        it('updates profile on PUT', async () => {
            const mockUser = { id: 'user-123' };
            vi.mocked(requireUser).mockResolvedValue(mockUser as any);
            vi.mocked(updateUser).mockResolvedValue({ id: 'user-123' } as any);

            const request = createMockRequest({
                method: 'PUT',
                url: 'http://localhost:5173/profile',
                body: { name: 'New Name' },
            });

            const response = await action({
                request,
                params: {},
                context: {},
            });

            const data = await response.json();
            expect(data.success).toBe(true);
        });
    });
});
```

## Test Utilities

Located in `app/test/utils.tsx`:

| Utility | Purpose |
|---------|---------|
| `renderWithProviders(ui)` | Render with React Router context |
| `createMockUser(overrides?)` | Create mock user object |
| `createMockRequest(options)` | Create mock Request for loaders/actions |
| `createMockFormData(data)` | Create FormData from object |

## Mocking Patterns

### Module Mocking

```typescript
// Mock BEFORE importing
vi.mock('~/db.server', () => ({
    prisma: {
        user: { findUnique: vi.fn(), update: vi.fn() },
    },
}));

import { prisma } from '~/db.server';
```

### Async Module Mocking (with type safety)

```typescript
// Type the importOriginal result
vi.mock('@react-email/components', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@react-email/components')>();
    return {
        ...actual,
        render: vi.fn().mockResolvedValue('<html>Mocked</html>'),
    };
});
```

### Function Mocking

```typescript
const mockFn = vi.fn();
mockFn.mockReturnValue('value');
mockFn.mockResolvedValue({ data: 'async' });
mockFn.mockImplementation((arg) => `custom: ${arg}`);
```

### Suppressing Console Output

```typescript
beforeEach(() => {
    vi.clearAllMocks();
    vi.spyOn(console, 'error').mockImplementation(() => {});
});
```

## What to Test

- Business rules, validation, permissions
- Data transformations, API call payloads
- User interactions (clicks, form submissions)
- Side effects (via mocks/spies)
- Error handling paths
- Loading, empty, success, error states

## What NOT to Test

- Third-party libraries (React Router, DaisyUI)
- Pure styling/CSS classes
- Implementation details (private functions)
- Multiple variations of identical behavior

## Running Tests

```bash
npm test              # Watch mode
npm run test:run      # Single run (CI)
npm run test:ui       # Visual UI
npm run test:coverage # Coverage report
```

## Anti-Patterns

- Importing from `@prisma/client` (use `~/generated/prisma/client`)
- Testing implementation details instead of behavior
- Querying by CSS class or test IDs
- Not clearing mocks between tests
- Missing mock declarations before imports

## Full Reference

See `.github/instructions/unit-testing.instructions.md` for comprehensive documentation.
