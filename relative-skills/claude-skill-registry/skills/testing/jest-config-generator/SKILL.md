---
name: jest-config-generator
description: Generate Jest configuration files for JavaScript/TypeScript testing with coverage, mocking, and environment-specific settings. Triggers on "create jest config", "generate jest.config", "jest configuration for", "testing config".
---

# Jest Config Generator

Generate optimized Jest configuration files for JavaScript and TypeScript testing projects.

## Output Requirements

**File Output:** `jest.config.js`, `jest.config.ts`, or `jest.config.json`
**Format:** JavaScript module (ESM or CJS) or JSON
**Compatibility:** Jest 29.x

## When Invoked

Immediately generate a complete Jest configuration appropriate for the project type. Include sensible defaults for coverage, transforms, and module resolution.

## Configuration Templates

### TypeScript Project (Node.js)
```javascript
// jest.config.js
/** @type {import('jest').Config} */
const config = {
  // Test environment
  testEnvironment: 'node',

  // File extensions
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],

  // Transform TypeScript files
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      {
        tsconfig: 'tsconfig.json',
        isolatedModules: true,
      },
    ],
  },

  // Test file patterns
  testMatch: [
    '**/__tests__/**/*.+(ts|tsx|js)',
    '**/?(*.)+(spec|test).+(ts|tsx|js)',
  ],

  // Ignore patterns
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/build/',
  ],

  // Module path aliases (match tsconfig paths)
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
    '^@models/(.*)$': '<rootDir>/src/models/$1',
  },

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],

  // Coverage configuration
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
    '!src/**/*.stories.{ts,tsx}',
    '!src/types/**/*',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },

  // Performance
  maxWorkers: '50%',
  cache: true,
  cacheDirectory: '<rootDir>/.jest-cache',

  // Timeouts
  testTimeout: 10000,

  // Clear mocks between tests
  clearMocks: true,
  restoreMocks: true,

  // Verbose output
  verbose: true,
};

module.exports = config;
```

### React Application (Vite/CRA)
```javascript
// jest.config.js
/** @type {import('jest').Config} */
const config = {
  // Use jsdom for DOM testing
  testEnvironment: 'jsdom',

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.ts'],

  // Transform
  transform: {
    '^.+\\.(ts|tsx)$': [
      'ts-jest',
      {
        tsconfig: 'tsconfig.json',
        isolatedModules: true,
      },
    ],
    '^.+\\.(js|jsx)$': 'babel-jest',
  },

  // Module resolution
  moduleNameMapper: {
    // Handle CSS imports
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',

    // Handle image imports
    '\\.(jpg|jpeg|png|gif|svg|webp)$': '<rootDir>/__mocks__/fileMock.js',

    // Path aliases
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    '^@hooks/(.*)$': '<rootDir>/src/hooks/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
  },

  // Test patterns
  testMatch: [
    '<rootDir>/src/**/__tests__/**/*.{ts,tsx}',
    '<rootDir>/src/**/*.{spec,test}.{ts,tsx}',
  ],

  // Ignore
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/.next/',
  ],

  // Transform ignore
  transformIgnorePatterns: [
    '/node_modules/(?!(uuid|other-esm-package)/)',
  ],

  // Coverage
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{ts,tsx}',
    '!src/main.tsx',
    '!src/vite-env.d.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],

  // Mock behavior
  clearMocks: true,
  restoreMocks: true,

  // Globals
  globals: {
    'ts-jest': {
      isolatedModules: true,
    },
  },
};

module.exports = config;
```

### Next.js Application
```javascript
// jest.config.js
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  // Path to Next.js app
  dir: './',
});

/** @type {import('jest').Config} */
const customConfig = {
  // Test environment
  testEnvironment: 'jest-environment-jsdom',

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],

  // Module aliases (synced with tsconfig.json)
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    '^@lib/(.*)$': '<rootDir>/src/lib/$1',
    '^@hooks/(.*)$': '<rootDir>/src/hooks/$1',
  },

  // Test patterns
  testMatch: [
    '**/__tests__/**/*.[jt]s?(x)',
    '**/?(*.)+(spec|test).[jt]s?(x)',
  ],

  // Ignore
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/.next/',
    '<rootDir>/e2e/',
  ],

  // Coverage
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/app/layout.tsx',
    '!src/app/providers.tsx',
  ],

  // Module directories
  moduleDirectories: ['node_modules', '<rootDir>/'],
};

module.exports = createJestConfig(customConfig);
```

### API/Backend (Express/Fastify)
```javascript
// jest.config.js
/** @type {import('jest').Config} */
const config = {
  preset: 'ts-jest',
  testEnvironment: 'node',

  // Root directory
  roots: ['<rootDir>/src', '<rootDir>/tests'],

  // Transform
  transform: {
    '^.+\\.ts$': ['ts-jest', { tsconfig: 'tsconfig.json' }],
  },

  // Test patterns
  testMatch: [
    '**/tests/**/*.test.ts',
    '**/tests/**/*.spec.ts',
    '**/__tests__/**/*.ts',
  ],

  // Path mapping
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@controllers/(.*)$': '<rootDir>/src/controllers/$1',
    '^@models/(.*)$': '<rootDir>/src/models/$1',
    '^@services/(.*)$': '<rootDir>/src/services/$1',
    '^@middleware/(.*)$': '<rootDir>/src/middleware/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
  },

  // Setup
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  globalSetup: '<rootDir>/tests/globalSetup.ts',
  globalTeardown: '<rootDir>/tests/globalTeardown.ts',

  // Coverage
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/index.ts',
    '!src/types/**/*',
    '!src/migrations/**/*',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },

  // Test isolation
  clearMocks: true,
  restoreMocks: true,
  resetModules: true,

  // Timeouts (longer for integration tests)
  testTimeout: 30000,

  // Force exit after tests complete
  forceExit: true,
  detectOpenHandles: true,

  // Verbose
  verbose: true,
};

module.exports = config;
```

### Monorepo (with projects)
```javascript
// jest.config.js (root)
/** @type {import('jest').Config} */
const config = {
  // Use projects for monorepo
  projects: [
    '<rootDir>/packages/*/jest.config.js',
    '<rootDir>/apps/*/jest.config.js',
  ],

  // Root coverage
  collectCoverage: true,
  coverageDirectory: '<rootDir>/coverage',
  coverageReporters: ['text', 'lcov', 'json-summary'],

  // Merge coverage from all projects
  collectCoverageFrom: [
    'packages/*/src/**/*.{ts,tsx}',
    'apps/*/src/**/*.{ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
  ],
};

module.exports = config;
```

### Package Project Example
```javascript
// packages/shared/jest.config.js
/** @type {import('jest').Config} */
const config = {
  displayName: 'shared',
  preset: 'ts-jest',
  testEnvironment: 'node',

  rootDir: '.',

  testMatch: ['<rootDir>/src/**/*.test.ts'],

  moduleNameMapper: {
    '^@shared/(.*)$': '<rootDir>/src/$1',
  },

  // Use root tsconfig
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      { tsconfig: '<rootDir>/tsconfig.json' },
    ],
  },
};

module.exports = config;
```

## Setup Files

### jest.setup.ts (React)
```typescript
// jest.setup.ts
import '@testing-library/jest-dom';

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  observe() { return null; }
  unobserve() { return null; }
  disconnect() { return null; }
} as any;

// Mock ResizeObserver
global.ResizeObserver = class ResizeObserver {
  constructor() {}
  observe() { return null; }
  unobserve() { return null; }
  disconnect() { return null; }
} as any;

// Mock matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});
```

### jest.setup.ts (API)
```typescript
// tests/setup.ts
import { prisma } from '@/lib/prisma';

// Clean up after each test
afterEach(async () => {
  jest.clearAllMocks();
});

// Close database connection after all tests
afterAll(async () => {
  await prisma.$disconnect();
});
```

## Mock Files

### fileMock.js
```javascript
// __mocks__/fileMock.js
module.exports = 'test-file-stub';
```

### styleMock.js
```javascript
// __mocks__/styleMock.js
module.exports = {};
```

## Validation Checklist

Before outputting, verify:
- [ ] Correct `testEnvironment` (node vs jsdom)
- [ ] Transform matches file types used
- [ ] Path aliases match tsconfig
- [ ] Coverage excludes appropriate files
- [ ] Setup files exist or noted as needed
- [ ] ESM packages in transformIgnorePatterns
- [ ] Appropriate timeouts set

## Example Invocations

**Prompt:** "Create Jest config for a TypeScript Node.js API"
**Output:** Complete `jest.config.js` with ts-jest, coverage, path aliases.

**Prompt:** "Generate Jest configuration for React Testing Library"
**Output:** Complete `jest.config.js` with jsdom, RTL setup, CSS mocks.

**Prompt:** "Jest config for Next.js 14 with App Router"
**Output:** Complete `jest.config.js` using next/jest with proper setup.
