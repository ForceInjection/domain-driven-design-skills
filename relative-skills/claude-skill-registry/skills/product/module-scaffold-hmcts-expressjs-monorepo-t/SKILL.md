---
name: module-scaffold
description: Use when creating a new feature module in libs/. Triggers on "create a module", "add a feature module", "scaffold module for X", or "new library for Y"
---

# Module Scaffolding Skill

This skill automates creation of new feature modules in the `libs/` directory, following the project's conventions and patterns.

## When to Use

- User asks to create a new feature/module
- User wants to add a new library to the monorepo
- User needs a new domain area (e.g., "authentication", "payments", "notifications")

## Module Types

| Type | Description | Includes |
|------|-------------|----------|
| **Full** | Complete feature module | pages + routes + database + assets |
| **Pages only** | Web frontend only | pages + assets |
| **API only** | Backend API only | routes |
| **Shared** | Reusable code | business logic, no routes |

## Step-by-Step Instructions

### Step 1: Gather Requirements

Ask the user for:
1. **Module name** (kebab-case, e.g., `user-management`)
2. **Module type** (full/pages/api/shared)
3. **Whether it needs database models** (yes/no)

### Step 2: Create Directory Structure

```bash
# For full module:
mkdir -p libs/{name}/src/pages
mkdir -p libs/{name}/src/routes
mkdir -p libs/{name}/src/locales
mkdir -p libs/{name}/src/assets/css
mkdir -p libs/{name}/src/assets/js
mkdir -p libs/{name}/prisma

# For pages-only:
mkdir -p libs/{name}/src/pages
mkdir -p libs/{name}/src/locales
mkdir -p libs/{name}/src/assets/css

# For API-only:
mkdir -p libs/{name}/src/routes

# For shared library:
mkdir -p libs/{name}/src
```

### Step 3: Generate Files

Use the templates in `assets/` to create:

1. **libs/{name}/package.json** - from `package.json.template`
   - Replace `{{MODULE_NAME}}` with the kebab-case module name
   - Remove `build:nunjucks` script if no pages directory

2. **libs/{name}/tsconfig.json** - from `tsconfig.json.template`
   - No modifications needed

3. **libs/{name}/src/config.ts** - from `config.ts.template`
   - Remove unused exports based on module type:
     - No pages? Remove `pageRoutes`
     - No routes? Remove `apiRoutes`
     - No database? Remove `prismaSchemas`
     - No assets? Remove `assets`

4. **libs/{name}/src/index.ts** - from `index.ts.template`
   - Add business logic exports as they're created

### Step 4: Register Module

#### 4a. Root tsconfig.json

Add to `compilerOptions.paths`:

```json
"@hmcts/{name}": ["libs/{name}/src"]
```

#### 4b. Web App (if module has pages)

In `apps/web/src/app.ts`, add import:

```typescript
import { pageRoutes as {camelName}Pages } from "@hmcts/{name}/config";
```

Add to `createSimpleRouter` call or router setup.

#### 4c. API App (if module has routes)

In `apps/api/src/app.ts`, add import:

```typescript
import { apiRoutes as {camelName}Routes } from "@hmcts/{name}/config";
```

Add to `createSimpleRouter` call.

#### 4d. Vite Config (if module has assets)

In `apps/web/vite.config.ts`, add import:

```typescript
import { assets as {camelName}Assets } from "@hmcts/{name}/config";
```

Add to `createBaseViteConfig` array.

#### 4e. Prisma Schema Discovery (if module has database)

In `libs/postgres-prisma/src/schema-discovery.ts`, add import:

```typescript
import { prismaSchemas as {camelName}Schemas } from "@hmcts/{name}/config";
```

Add to `schemaPaths` array.

### Step 5: Verify Setup

Run these commands to verify the module is set up correctly:

```bash
yarn                    # Install dependencies
yarn build              # Verify TypeScript compiles
yarn lint               # Check for lint errors
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Module directory | kebab-case | `libs/user-management/` |
| Package name | @hmcts/{kebab} | `@hmcts/user-management` |
| Import alias | @hmcts/{kebab} | `@hmcts/user-management` |
| Config variable | camelCase + type | `userManagementPages` |
| File names | kebab-case | `user-service.ts` |

## Conversion Helper

kebab-case to camelCase for imports:
- `user-management` → `userManagement`
- `council-tax` → `councilTax`
- `footer-pages` → `footerPages`

## Template Files

Templates are located in `.claude/skills/module-scaffold/assets/`:

- `package.json.template` - Package configuration
- `tsconfig.json.template` - TypeScript configuration
- `config.ts.template` - Module config exports
- `index.ts.template` - Business logic exports

## Example: Full Module Creation

Creating a `payment-gateway` module:

1. **Create directories:**
   ```bash
   mkdir -p libs/payment-gateway/src/{pages,routes,locales,assets/css}
   mkdir -p libs/payment-gateway/prisma
   ```

2. **Create package.json** with name `@hmcts/payment-gateway`

3. **Create tsconfig.json** extending root

4. **Create src/config.ts** with all exports

5. **Create src/index.ts** placeholder

6. **Register in tsconfig.json:**
   ```json
   "@hmcts/payment-gateway": ["libs/payment-gateway/src"]
   ```

7. **Register in apps/web/src/app.ts:**
   ```typescript
   import { pageRoutes as paymentGatewayPages } from "@hmcts/payment-gateway/config";
   ```

8. **Run verification:**
   ```bash
   yarn && yarn build && yarn lint
   ```
