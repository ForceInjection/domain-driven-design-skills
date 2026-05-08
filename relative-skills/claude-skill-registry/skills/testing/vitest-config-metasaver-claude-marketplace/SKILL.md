---
name: vitest-config
description: Vitest configuration template and validation logic for test configuration. Standards differ by package type - use package-type specific configs (react-app, react-library, node-library, node-service, contracts, database). Use factory pattern for React packages that need vite.config.ts merging.
---

# Vitest Configuration Skill

This skill provides vitest.config.ts templates and validation logic for Vitest test configuration.

## Purpose

Manage vitest.config.ts configuration to:

- Configure test environment based on package type
- Set up test setup files (frontend only)
- Configure coverage reporting
- Add required dependencies and scripts

## Usage

This skill is invoked by the `vitest-agent` when:

- Creating new vitest.config.ts files
- Auditing existing Vitest configurations
- Validating Vitest configs against standards

## Templates

Templates are located at:

```
templates/vitest.config.ts.template         # Frontend (React apps, components) - factory pattern
templates/vitest-backend.config.ts.template # Backend (libraries, APIs, contracts, database)
templates/vitest.setup.ts.template          # Setup file (frontend only) - DEPRECATED, use shared setup
```

## Package-Type Specific Configs

The `@metasaver/core-vitest-config` package exports package-type specific configurations:

| Export Path       | Package Type                    | Environment | Factory |
| ----------------- | ------------------------------- | ----------- | ------- |
| `./react-app`     | React applications (portals)    | jsdom       | Yes     |
| `./react-library` | React component libraries       | jsdom       | Yes     |
| `./node-library`  | Node.js utility packages        | node        | No      |
| `./node-service`  | Express/Hono backend services   | node        | No      |
| `./contracts`     | Zod schema packages             | node        | No      |
| `./database`      | Prisma database packages        | node        | No      |
| `./base`          | Base config (internal use only) | none        | No      |

## The 5 Vitest Standards

### Standard 1: Use Package-Type Specific Config

**React apps (portals):** Use factory pattern with vite.config.ts merging

```typescript
import { createReactAppConfig } from "@metasaver/core-vitest-config/react-app";
import viteConfig from "./vite.config";

export default createReactAppConfig(viteConfig, {
  // Optional overrides
  setupFiles: ["./vitest.setup.ts"],
});
```

**React libraries (component packages):**

```typescript
import { createReactLibraryConfig } from "@metasaver/core-vitest-config/react-library";
import viteConfig from "./vite.config";

export default createReactLibraryConfig(viteConfig);
```

**Node libraries (utility packages):**

```typescript
import nodeLibraryConfig from "@metasaver/core-vitest-config/node-library";

export default nodeLibraryConfig;
```

**Node services (REST APIs):**

```typescript
import nodeServiceConfig from "@metasaver/core-vitest-config/node-service";

export default nodeServiceConfig;
```

**Contracts (Zod schemas):**

```typescript
import contractsConfig from "@metasaver/core-vitest-config/contracts";

export default contractsConfig;
```

**Database (Prisma):**

```typescript
import databaseConfig from "@metasaver/core-vitest-config/database";

export default databaseConfig;
```

### Standard 2: Test Configuration (by package type)

| Package Type        | Environment | setupFiles                                         |
| ------------------- | ----------- | -------------------------------------------------- |
| React apps          | jsdom       | `["@metasaver/core-vitest-config/setup/jest-dom"]` |
| Frontend components | jsdom       | `["@metasaver/core-vitest-config/setup/jest-dom"]` |
| Backend libraries   | node        | None                                               |
| API services        | node        | Optional: `./tests/setup.ts`                       |
| Contracts packages  | node        | None                                               |
| Database packages   | node        | None                                               |

### Standard 3: Setup File (frontend only)

**Use shared setup from vitest-config package:**

```typescript
// Configured automatically by factory pattern
setupFiles: ["@metasaver/core-vitest-config/setup/jest-dom"];
```

The shared setup imports `@testing-library/jest-dom` for DOM assertions.

**DEPRECATED:** Creating local `./vitest.setup.ts` files. Use the shared setup instead.

Backend packages do NOT need a setup file.

### Standard 4: Required Dependencies (by package type)

**Frontend packages:**

```json
{
  "devDependencies": {
    "vitest": "^3.2.4",
    "@vitest/coverage-v8": "^3.2.4",
    "@vitest/ui": "^3.2.4",
    "@testing-library/react": "^16.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "@metasaver/core-vitest-config": "workspace:*",
    "jsdom": "^26.0.0"
  }
}
```

**Backend packages:**

```json
{
  "devDependencies": {
    "vitest": "^3.2.4",
    "@vitest/coverage-v8": "^3.2.4",
    "@metasaver/core-vitest-config": "workspace:*"
  }
}
```

**Service packages (additional):**

```json
{
  "devDependencies": {
    "supertest": "^7.0.0",
    "@types/supertest": "^6.0.3"
  }
}
```

### Standard 5: Required npm Scripts (by package type)

**All packages:**

```json
{
  "scripts": {
    "test:unit": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

**Frontend packages (additional):**

```json
{
  "scripts": {
    "test:ui": "vitest --ui"
  }
}
```

## Package Type Rules Summary

| Package Type        | Config Export     | Environment | Setup File | test:ui |
| ------------------- | ----------------- | ----------- | ---------- | ------- |
| React apps          | `./react-app`     | jsdom       | Shared     | Yes     |
| Frontend components | `./react-library` | jsdom       | Shared     | Yes     |
| Backend libraries   | `./node-library`  | node        | No         | No      |
| API services        | `./node-service`  | node        | Optional   | No      |
| Contracts packages  | `./contracts`     | node        | No         | No      |
| Database packages   | `./database`      | node        | No         | No      |

## Validation

To validate a vitest.config.ts file:

1. Determine package type (frontend vs backend)
2. Check vitest.config.ts exists
3. For frontend: verify factory pattern usage with vite.config.ts
4. For backend: verify package-type specific config usage
5. Check environment matches package type
6. For frontend: verify shared setup file reference
7. Check required dependencies for package type
8. Verify npm scripts (test:unit, test:watch, test:coverage, + test:ui for frontend)
9. Report violations

## Repository Type Considerations

- **Consumer Repos**: Must strictly follow all 5 standards unless exception declared
- **Library Repos**: May have custom test configuration for component library testing

### Exception Declaration

Consumer repos may declare exceptions in package.json:

```json
{
  "metasaver": {
    "exceptions": {
      "vitest-config": {
        "type": "custom-test-setup",
        "reason": "Requires custom test environment setup for specialized testing"
      }
    }
  }
}
```

## Best Practices

1. Place vitest.config.ts at workspace root
2. Frontend: use factory pattern (createReactAppConfig/createReactLibraryConfig)
3. Backend: use package-type specific config (node-library, node-service, contracts, etc.)
4. Frontend: use shared setup file from vitest-config package
5. Use correct config for package type
6. Re-audit after making changes

## Integration

This skill integrates with:

- Repository type provided via `scope` parameter. If not provided, use `/skill scope-check`
- `/skill audit-workflow` - Bi-directional comparison workflow
- `/skill remediation-options` - Conform/Update/Ignore choices
- `vite-agent` - Ensure vite.config.ts exists for frontend packages
- `package-scripts-agent` - Ensure test scripts exist
