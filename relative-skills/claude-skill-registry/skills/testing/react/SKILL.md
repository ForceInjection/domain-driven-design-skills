---
name: react
description: Comprehensive React best practices for building scalable web applications with feature-based architecture, TypeScript, state management patterns, performance optimization, and testing guidelines. Use when creating React/Next.js UIs, components, features, or applications. This skill provides official React documentation guidance, 2025 community best practices, folder structure recommendations, and component patterns.
---

# React Best Practices Skill

## Overview

This skill provides React best practices for building modern web applications using React and Next.js. It follows official React documentation and 2025 community standards, emphasizing feature-based architecture, TypeScript integration, state management patterns, performance optimization, and testing guidelines.

## Quick Start: Creating Components

When creating React components, follow these core principles from [Official React Rules](https://react.dev/reference/rules):

### 1. Component Structure

```tsx
// ✅ Good: Functional component with TypeScript
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick}>
      {label}
    </button>
  );
}
```

**Key Rules:**
- Components must be **pure** - same inputs = same output
- Never call components directly (`<MyComponent />` not `MyComponent()`)
- Always call Hooks at the **top level** of the component
- Only call Hooks from React functions (not regular JavaScript functions)

### 2. Component Organization

```tsx
// ✅ Good: Co-locate related code
// src/features/auth/components/LoginForm.tsx

import { useState } from 'react';
import type { LoginCredentials } from '../types';

export function LoginForm() {
  const [credentials, setCredentials] = useState<LoginCredentials>({
    username: '',
    password: '',
  });

  // Component logic here
}
```

## Project Structure

Use **feature-based architecture** for scalable React applications:

```
src/
├── app/                    # Next.js app router (if using Next.js)
├── features/               # Feature modules
│   ├── auth/              # Authentication feature
│   │   ├── components/    # Feature-specific components
│   │   │   ├── LoginForm.tsx
│   │   │   └── RegisterForm.tsx
│   │   ├── hooks/         # Feature-specific hooks
│   │   │   └── useAuth.ts
│   │   ├── api/           # API calls
│   │   │   └── authApi.ts
│   │   ├── types/         # TypeScript types
│   │   │   └── auth.types.ts
│   │   └── index.ts       # Public exports
│   └── dashboard/         # Dashboard feature
├── shared/                # Shared utilities
│   ├── components/        # Common UI components
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   └── Input/
│   ├── hooks/             # Shared custom hooks
│   │   └── useLocalStorage.ts
│   ├── utils/             # Helper functions
│   │   └── format.ts
│   └── types/             # Shared types
│       └── api.types.ts
└── lib/                   # External library configs
    ├── react-query/
    └── tests/
```

**Principles:**
- Group by **feature**, not by file type
- Co-locate related code (component, hooks, types, tests)
- Keep shared utilities separate
- Use `index.ts` for clean imports

For detailed structure guidance, see [references/project-structure.md](references/project-structure.md)

## Core React Best Practices

### 1. State Management

Choose the right state management approach based on your needs:

**useState** - Simple, independent state
```tsx
const [count, setCount] = useState(0);
```

**useReducer** - Complex state logic with multiple sub-values
```tsx
const [state, dispatch] = useReducer(formReducer, initialState);
```

**Context API** - Shared global state (theme, auth, language)
```tsx
const AuthContext = createContext<AuthContextValue | null>(null);
```

**Server State** - Server data with React Query or SWR
```tsx
const { data, isLoading } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
```

For detailed state management patterns, see [references/state-management.md](references/state-management.md)

### 2. Component Patterns

**Composition over Inheritance**
```tsx
// ✅ Good: Composition
<Card>
  <CardHeader title="Welcome" />
  <CardBody>Content here</CardBody>
  <CardFooter>Actions</CardFooter>
</Card>
```

**Custom Hooks for Reusable Logic**
```tsx
// ✅ Good: Extract logic into custom hook
function useForm<T>(initialValues: T) {
  const [values, setValues] = useState(initialValues);
  // ... hook logic
  return { values, handleChange, reset };
}
```

**Props vs State**
- Props: Immutable data passed from parent
- State: Mutable data managed within component

### 3. TypeScript Integration

**Component Props**
```tsx
interface UserCardProps {
  user: User;
  onEdit?: (user: User) => void;
  variant?: 'default' | 'compact';
}

export function UserCard({ user, onEdit, variant = 'default' }: UserCardProps) {
  // ...
}
```

**Type Exports**
```tsx
export type { UserCardProps }; // Export alongside component
```

For comprehensive TypeScript patterns, see [references/typescript.md](references/typescript.md)

## Performance Optimization

**Memoization**
```tsx
// Use useMemo for expensive calculations
const filteredItems = useMemo(
  () => items.filter(item => item.active),
  [items]
);

// Use useCallback for functions passed to children
const handleClick = useCallback((id: string) => {
  // handler logic
}, [dependency]);
```

**Code Splitting**
```tsx
import lazy from 'react';
const HeavyComponent = lazy(() => import('./HeavyComponent'));
```

For detailed optimization techniques, see [references/performance.md](references/performance.md)

## Testing Patterns

**Component Testing with React Testing Library**
```tsx
import { render, screen } from '@testing-library/react';
import { Button } from './Button';

test('renders button with label', () => {
  render(<Button label="Click me" onClick={vi.fn()} />);
  expect(screen.getByText('Click me')).toBeInTheDocument();
});
```

For comprehensive testing guidelines, see [references/testing.md](references/testing.md)

## When to Use Reference Materials

### references/project-structure.md
Read when:
- Setting up a new React project
- Restructuring an existing codebase
- Deciding where to place new features
- Organizing large-scale applications

### references/state-management.md
Read when:
- Designing state architecture
- Choosing between useState, useReducer, or Context
- Implementing form state
- Managing server state with React Query/SWR

### references/performance.md
Read when:
- Optimizing render performance
- Implementing code splitting
- Reducing bundle size
- Working with large lists or data

### references/testing.md
Read when:
- Writing component tests
- Testing custom hooks
- Setting up test infrastructure
- Testing async operations

### references/typescript.md
Read when:
- Typing component props
- Creating generic components
- Organizing type definitions
- Ensuring type safety throughout the app

## Resources

### references/
Detailed documentation on specific aspects of React development:
- **project-structure.md** - Feature-based folder organization and scaling
- **state-management.md** - State patterns and when to use each approach
- **performance.md** - Optimization techniques and best practices
- **testing.md** - Testing patterns with React Testing Library
- **typescript.md** - TypeScript integration and type organization

### assets/
Template files and boilerplate:
- **FunctionalComponent.template.tsx** - Starting template for components
- **FeatureModule.template** - Feature module structure template

## Common Anti-Patterns to Avoid

❌ **Don't:**
```tsx
// Calling components directly
const element = MyComponent();

// Mutating props or state directly
props.user.name = 'John';
state.items.push(newItem);

// Using hooks in conditions or loops
if (condition) {
  useEffect(() => {}, []); // ❌ Wrong
}

// Not providing dependency arrays
useEffect(() => {
  // Missing dependencies
}, []); // ❌ Wrong if dependencies exist
```

✅ **Do:**
```tsx
// Using JSX
const element = <MyComponent />;

// Creating new copies
setUser({ ...user, name: 'John' });
setItems([...items, newItem]);

// Hooks at top level
useEffect(() => {}, []); // ✅ Correct

// Complete dependency arrays
useEffect(() => {
  // All dependencies included
}, [dep1, dep2]); // ✅ Correct
```

## Key Takeaways

1. **Follow the Rules of React** - Keep components pure, call Hooks correctly
2. **Use feature-based architecture** - Group code by feature, not type
3. **TypeScript is essential** - Use proper types for all components and props
4. **Optimize intentionally** - Measure first, then optimize with memoization
5. **Test user behavior** - Test what users see and interact with
6. **Co-locate related code** - Keep components with their hooks, types, and tests
