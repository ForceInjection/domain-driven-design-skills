---
name: architecture-review
description: Use after implementing features to verify architecture compliance. Checks for layer violations, missing interfaces, and tight coupling.
---

# Architecture Review

## Overview

Verify that implemented code follows the three-layer architecture with proper dependency injection. This skill catches violations before they become entrenched.

**Run this after every feature implementation.** Catching violations early prevents technical debt accumulation.

## When to Use

Use this skill when:
- Finished implementing a new feature
- Before creating a pull request
- After refactoring code
- Periodically to audit existing code
- When reviewing someone else's code

## Architecture Rules

### The Three Laws

1. **Domain layer (`lib/domain/`) MUST NOT import from `lib/infra/` or `lib/db/`**
2. **Services MUST receive dependencies via constructor injection**
3. **UI layer MUST only import from `lib/container.ts`, never directly from infra**

### Layer Structure

```
app/                    → Can import: lib/container.ts, lib/domain/**/types
lib/domain/            → Can import: lib/infra/interfaces/* (types only)
lib/infra/interfaces/  → Can import: lib/domain/**/entity types
lib/infra/db/          → Can import: lib/infra/interfaces/*, lib/domain/**/types
lib/infra/storage/     → Can import: lib/infra/interfaces/*
lib/container.ts       → Can import: Everything (wires it all together)
```

## Review Checklist

### 1. Layer Violation Check

Run these commands to detect violations:

```bash
# Domain importing from infra (VIOLATION)
grep -r "from.*infra" lib/domain/ 2>/dev/null

# Domain importing db directly (VIOLATION)
grep -r "from.*lib/db" lib/domain/ 2>/dev/null
grep -r "from.*\/db" lib/domain/ 2>/dev/null

# Domain importing drizzle (VIOLATION)
grep -r "drizzle-orm" lib/domain/ 2>/dev/null

# Domain importing external storage (VIOLATION)
grep -r "@vercel/blob" lib/domain/ 2>/dev/null

# UI importing infra directly (VIOLATION)
grep -r "from.*lib/infra" app/ 2>/dev/null
grep -r "from.*infra/db" app/ 2>/dev/null

# UI importing db directly (VIOLATION)
grep -r "from.*lib/db" app/ 2>/dev/null
```

**Expected result:** No matches. Any match is a violation that must be fixed.

### 2. Dependency Injection Check

Verify services use constructor injection:

```bash
# Find all service files
find lib/domain -name "*.service.ts" -type f

# For each service, verify:
# - Has constructor with interface parameters
# - Does NOT instantiate dependencies with 'new'
# - Does NOT import concrete implementations
```

**Check each service for:**
```typescript
// ✅ GOOD: Constructor injection
export class SiteService {
  constructor(
    private repo: ISiteRepository,      // Interface type
    private storage: IStorageAdapter,   // Interface type
  ) {}
}

// ❌ BAD: Direct instantiation
export class SiteService {
  private repo = new DrizzleSiteRepository();  // VIOLATION
}

// ❌ BAD: Importing concrete class
import { DrizzleSiteRepository } from '../infra/db/site.repository';  // VIOLATION
```

### 3. Entity Purity Check

Verify entity files have no side effects:

```bash
# Find all entity files
find lib/domain -name "*.entity.ts" -type f

# Check for violations in entity files:
grep -l "async" lib/domain/**/*.entity.ts 2>/dev/null      # Should be empty
grep -l "await" lib/domain/**/*.entity.ts 2>/dev/null      # Should be empty
grep -l "fetch" lib/domain/**/*.entity.ts 2>/dev/null      # Should be empty
grep -l "import.*db" lib/domain/**/*.entity.ts 2>/dev/null # Should be empty
```

**Entity files should contain ONLY:**
- Type/interface definitions
- Pure validation functions (no async, no I/O)
- Constants
- Type guards

### 4. Interface Completeness Check

Verify interfaces exist for all external dependencies:

```bash
# List interface files
ls lib/infra/interfaces/

# Expected: One interface per external dependency type
# - site.repository.ts (or combined {entity}.repository.ts)
# - storage.adapter.ts
# - email.adapter.ts
# - etc.
```

**For each repository/adapter:**
- [ ] Interface defined in `lib/infra/interfaces/`
- [ ] Implementation in `lib/infra/{type}/`
- [ ] Service depends on interface, not implementation

### 5. Container Wiring Check

Verify container properly wires dependencies:

```bash
# Check container file
cat lib/container.ts
```

**Verify:**
- [ ] All services have factory functions (`getSiteService()`, etc.)
- [ ] Factory functions instantiate concrete implementations
- [ ] No services are instantiated outside container
- [ ] Test helper exists for injecting mocks (`createSiteService(mockRepo, mockStorage)`)

### 6. Import Path Check

Verify UI layer imports correctly:

```bash
# Find all imports from lib/ in app/
grep -rh "from.*@/lib" app/ | sort | uniq

# Should see:
# - from '@/lib/container'     ✅ OK
# - from '@/lib/domain/.../types'  ✅ OK (if just types)
# - from '@/lib/infra/...'     ❌ VIOLATION
# - from '@/lib/db/...'        ❌ VIOLATION
```

## Common Violations

### Violation 1: Direct Database Import

```typescript
// ❌ In lib/domain/site/site.service.ts
import { db } from '../../db';
import { sites } from '../../db/schema';

// ✅ Fixed
import type { ISiteRepository } from '../../infra/interfaces/site.repository';
constructor(private repo: ISiteRepository) {}
```

### Violation 2: Async Validation

```typescript
// ❌ In lib/domain/site/site.entity.ts
export async function isSubdomainAvailable(subdomain: string): Promise<boolean> {
  const existing = await db.select()...  // VIOLATION: I/O in entity
}

// ✅ Fixed: Move to service
// In site.entity.ts - pure validation only
export function validateSubdomainFormat(subdomain: string): ValidationResult { }

// In site.service.ts - async checks
async createSite(input: CreateSiteInput) {
  const formatResult = validateSubdomainFormat(input.subdomain);
  if (!formatResult.valid) throw new SiteError(...);

  const existing = await this.repo.findBySubdomain(input.subdomain);
  if (existing) throw new SiteError('SUBDOMAIN_TAKEN', ...);
}
```

### Violation 3: Service Instantiating Dependencies

```typescript
// ❌ In lib/domain/site/site.service.ts
export class SiteService {
  private repo = new DrizzleSiteRepository();  // VIOLATION
  private storage = new VercelBlobAdapter();   // VIOLATION
}

// ✅ Fixed: Constructor injection
export class SiteService {
  constructor(
    private repo: ISiteRepository,
    private storage: IStorageAdapter,
  ) {}
}
```

### Violation 4: UI Importing Infra

```typescript
// ❌ In app/(dashboard)/sites/new/actions.ts
import { createSite } from '@/lib/infra/db/site.repository';

// ✅ Fixed: Import from container
import { getSiteService } from '@/lib/container';

const service = getSiteService();
await service.createSite(...);
```

### Violation 5: Missing Interface

```typescript
// ❌ Service depends on concrete class
import { DrizzleSiteRepository } from '../../infra/db/site.repository';

export class SiteService {
  constructor(private repo: DrizzleSiteRepository) {}  // Concrete type!
}

// ✅ Fixed: Depend on interface
import type { ISiteRepository } from '../../infra/interfaces/site.repository';

export class SiteService {
  constructor(private repo: ISiteRepository) {}  // Interface type
}
```

## Review Output Template

After running the review, document findings:

```markdown
## Architecture Review - [Feature/Date]

### Layer Violations
- [ ] Domain → Infra imports: None / [List violations]
- [ ] Domain → DB imports: None / [List violations]
- [ ] UI → Infra imports: None / [List violations]

### Dependency Injection
- [ ] All services use constructor injection: Yes / [List violations]
- [ ] No direct instantiation in services: Yes / [List violations]

### Entity Purity
- [ ] No async in entity files: Yes / [List violations]
- [ ] No I/O in entity files: Yes / [List violations]

### Interface Coverage
- [ ] All repositories have interfaces: Yes / [List missing]
- [ ] All adapters have interfaces: Yes / [List missing]

### Container
- [ ] All services wired in container: Yes / [List missing]
- [ ] Test factories available: Yes / No

### Actions Required
1. [Action item 1]
2. [Action item 2]
```

## Automated Review Script

Create this script for quick reviews:

```bash
#!/bin/bash
# save as: scripts/architecture-review.sh

echo "=== Architecture Review ==="
echo ""

echo "1. Checking domain → infra imports..."
DOMAIN_INFRA=$(grep -r "from.*infra" lib/domain/ 2>/dev/null | grep -v ".test.ts")
if [ -n "$DOMAIN_INFRA" ]; then
  echo "❌ VIOLATION: Domain imports from infra"
  echo "$DOMAIN_INFRA"
else
  echo "✅ No domain → infra imports"
fi
echo ""

echo "2. Checking domain → db imports..."
DOMAIN_DB=$(grep -r "from.*\/db" lib/domain/ 2>/dev/null | grep -v ".test.ts")
if [ -n "$DOMAIN_DB" ]; then
  echo "❌ VIOLATION: Domain imports from db"
  echo "$DOMAIN_DB"
else
  echo "✅ No domain → db imports"
fi
echo ""

echo "3. Checking UI → infra imports..."
UI_INFRA=$(grep -r "from.*lib/infra" app/ 2>/dev/null)
if [ -n "$UI_INFRA" ]; then
  echo "❌ VIOLATION: UI imports from infra"
  echo "$UI_INFRA"
else
  echo "✅ No UI → infra imports"
fi
echo ""

echo "4. Checking for async in entity files..."
ASYNC_ENTITY=$(grep -l "async\|await" lib/domain/**/*.entity.ts 2>/dev/null)
if [ -n "$ASYNC_ENTITY" ]; then
  echo "❌ VIOLATION: Async found in entity files"
  echo "$ASYNC_ENTITY"
else
  echo "✅ No async in entity files"
fi
echo ""

echo "5. Checking for direct instantiation in services..."
DIRECT_NEW=$(grep -r "new.*Repository\|new.*Adapter" lib/domain/ 2>/dev/null | grep -v ".test.ts")
if [ -n "$DIRECT_NEW" ]; then
  echo "❌ VIOLATION: Direct instantiation in services"
  echo "$DIRECT_NEW"
else
  echo "✅ No direct instantiation in services"
fi
echo ""

echo "=== Review Complete ==="
```

## Why This Matters

**Without architecture reviews:**
- Violations accumulate over time
- "Just this once" becomes permanent
- Testing becomes increasingly difficult
- Refactoring becomes risky

**With regular reviews:**
- Catch violations early when easy to fix
- Maintain clean architecture over time
- Keep codebase testable
- Enable safe refactoring
