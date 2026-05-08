---
name: pinpoint-patterns
description: Project-specific code patterns for Server Actions, data fetching, error handling, file organization. Use when implementing features to follow established patterns, or when user asks about project conventions/patterns/architecture.
---

# PinPoint Patterns Guide

## When to Use This Skill

Use this skill when:
- Implementing new features
- Wondering "how should I structure this?"
- Looking for established patterns to follow
- Contributing new patterns after implementing same approach 2+ times
- User mentions: "pattern", "convention", "architecture", "how to", "best practice"

## Quick Reference

### Pattern Discovery Process
1. Check `docs/PATTERNS.md` (index of all patterns)
2. Look in `docs/patterns/` for specific pattern files
3. If implementing same approach 2+ times, add new pattern
4. Focus on PinPoint-specific patterns (not general Next.js knowledge)

### Core Patterns
- **Server Actions**: File organization, auth, validation, revalidation
- **Data Fetching**: Drizzle queries, caching, error handling
- **Error Handling**: Validation errors, auth errors, DB errors
- **File Organization**: Where to put files, naming conventions

## Detailed Documentation

Read these files for all established patterns:

```bash
# Index of all patterns
cat docs/PATTERNS.md

# Specific pattern files
ls docs/patterns/
cat docs/patterns/*.md

# Example: Data fetching patterns
cat docs/patterns/data-fetching.md
```

## Server Action Patterns

### File Organization

```
src/server/actions/
├── issues.ts       # Issue-related actions
├── machines.ts     # Machine-related actions
├── users.ts        # User-related actions
└── comments.ts     # Comment-related actions
```

### Server Action Template

```typescript
"use server";

import { createClient } from "~/lib/supabase/server";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { z } from "zod";
import { db } from "~/server/db";
import { issues } from "~/server/db/schema";

// 1. Define validation schema
const createIssueSchema = z.object({
  title: z.string().min(1, "Title required"),
  description: z.string().optional(),
  machineId: z.string().uuid(),
  severity: z.enum(["minor", "playable", "unplayable"]),
});

// 2. Define return type
export type CreateIssueResult =
  | { success: true; issueId: string }
  | { success: false; error: string };

// 3. Implement action
export async function createIssue(
  formData: FormData
): Promise<CreateIssueResult> {
  // 3a. Auth check (ALWAYS first)
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  // 3b. Validate input
  const rawData = {
    title: formData.get("title"),
    description: formData.get("description"),
    machineId: formData.get("machineId"),
    severity: formData.get("severity"),
  };

  let validData;
  try {
    validData = createIssueSchema.parse(rawData);
  } catch (error) {
    return { success: false, error: "Invalid input" };
  }

  // 3c. Perform action
  try {
    const [issue] = await db
      .insert(issues)
      .values({
        ...validData,
        reportedBy: user.id,
      })
      .returning();

    // 3d. Revalidate affected paths
    revalidatePath("/issues");
    revalidatePath(`/machines/${validData.machineId}`);

    return { success: true, issueId: issue.id };
  } catch (error) {
    return { success: false, error: "Failed to create issue" };
  }
}
```

## Data Fetching Patterns

### Direct Drizzle Queries

```typescript
// src/server/data-access/issues.ts

import { db } from "~/server/db";
import { issues, machines } from "~/server/db/schema";
import { eq, desc } from "drizzle-orm";
import { cache } from "react";

// ✅ Good: Cached data access function
export const getIssuesForMachine = cache(async (machineId: string) => {
  if (!machineId) {
    throw new Error("Machine ID required");
  }

  return await db.query.issues.findMany({
    where: eq(issues.machineId, machineId),
    orderBy: desc(issues.createdAt),
    with: {
      machine: true,
      reportedByUser: {
        columns: {
          id: true,
          email: true,
          fullName: true,
        },
      },
    },
  });
});

// Usage in Server Component
export default async function MachineIssuesPage({
  params,
}: {
  params: { machineId: string };
}) {
  const issues = await getIssuesForMachine(params.machineId);

  return (
    <div>
      {issues.map((issue) => (
        <IssueCard key={issue.id} issue={issue} />
      ))}
    </div>
  );
}
```

### Caching Pattern

```typescript
import { cache } from "react";

// ✅ Good: Wrap data access in cache()
export const getMachines = cache(async () => {
  return await db.query.machines.findMany({
    orderBy: (machines, { asc }) => [asc(machines.name)],
  });
});

// React 19 cache() deduplicates calls within same request
// Multiple components can call getMachines() without extra DB queries
```

## Error Handling Patterns

### Validation Errors

```typescript
// ✅ Good: Return structured errors
export type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string };

export async function createMachine(
  formData: FormData
): Promise<ActionResult<Machine>> {
  const schema = z.object({
    name: z.string().min(1),
    manufacturer: z.string().min(1),
  });

  const result = schema.safeParse({
    name: formData.get("name"),
    manufacturer: formData.get("manufacturer"),
  });

  if (!result.success) {
    return {
      success: false,
      error: result.error.issues[0]?.message ?? "Validation failed",
    };
  }

  // Proceed with valid data
  const [machine] = await db.insert(machines).values(result.data).returning();
  return { success: true, data: machine };
}
```

### Database Errors

```typescript
export async function deleteIssue(
  issueId: string
): Promise<ActionResult<void>> {
  try {
    await db.delete(issues).where(eq(issues.id, issueId));
    revalidatePath("/issues");
    return { success: true, data: undefined };
  } catch (error) {
    console.error("Failed to delete issue:", error);
    return { success: false, error: "Failed to delete issue" };
  }
}
```

## File Organization Patterns

### Directory Structure

```
src/
├── app/                        # Next.js App Router
│   ├── (app)/                  # Authenticated app routes
│   │   ├── machines/
│   │   ├── issues/
│   │   └── layout.tsx
│   ├── (auth)/                 # Authentication routes
│   │   ├── login/
│   │   └── signup/
│   └── api/                    # API routes (minimal, prefer Server Actions)
├── components/
│   ├── ui/                     # shadcn/ui components
│   ├── issues/                 # Issue-specific components
│   ├── machines/               # Machine-specific components
│   └── layout/                 # Layout components (nav, header, etc.)
├── lib/
│   ├── utils.ts                # Utility functions
│   ├── types.ts                # Shared types
│   ├── validation/             # Zod schemas
│   └── supabase/
│       ├── client.ts           # Client-side Supabase
│       └── server.ts           # Server-side Supabase
├── server/
│   ├── actions/                # Server Actions
│   ├── data-access/            # Data fetching functions
│   └── db/
│       ├── index.ts            # Drizzle client
│       └── schema.ts           # Drizzle schema
└── test/
    ├── unit/                   # Unit tests
    └── integration/
        └── supabase/           # Integration tests
```

### Naming Conventions

- **Server Actions**: `createIssue`, `updateMachine`, `deleteComment` (verb + noun)
- **Data Access**: `getIssuesForMachine`, `getMachineById` (get + descriptive)
- **Components**: `IssueCard`, `MachineList`, `CreateIssueDialog` (PascalCase)
- **Utilities**: `formatDate`, `calculateSeverity` (camelCase)
- **Types**: `Issue`, `Machine`, `User` (PascalCase, singular)

## Type Patterns

### Database vs Application Types

```typescript
// Database types (snake_case) - from schema
import { issues } from "~/server/db/schema";
type DbIssue = typeof issues.$inferSelect;

// Application types (camelCase) - in ~/lib/types
export type Issue = {
  id: string;
  title: string;
  description: string | null;
  machineId: string;
  severity: "minor" | "playable" | "unplayable";
  createdAt: Date;
};

// Converter at boundary
export function dbIssueToIssue(dbIssue: DbIssue): Issue {
  return {
    id: dbIssue.id,
    title: dbIssue.title,
    description: dbIssue.description,
    machineId: dbIssue.machine_id,
    severity: dbIssue.severity,
    createdAt: new Date(dbIssue.created_at),
  };
}
```

## Revalidation Patterns

```typescript
import { revalidatePath, revalidateTag } from "next/cache";

// ✅ Good: Revalidate specific paths
export async function createIssue(formData: FormData) {
  // ... create issue ...

  revalidatePath("/issues"); // List page
  revalidatePath(`/machines/${machineId}`); // Machine detail page
  revalidatePath(`/issues/${issueId}`); // Issue detail page
}

// ✅ Good: Revalidate by tag (for complex dependencies)
export async function updateMachine(machineId: string, data: MachineData) {
  // ... update machine ...

  revalidateTag(`machine-${machineId}`); // All queries tagged with this
}
```

## Testing Patterns

### Unit Test Pattern

```typescript
// src/test/unit/lib/utils.test.ts

import { describe, it, expect } from "vitest";
import { calculateSeverityScore } from "~/lib/utils";

describe("calculateSeverityScore", () => {
  it("returns 10 for unplayable", () => {
    expect(calculateSeverityScore("unplayable")).toBe(10);
  });

  it("returns 5 for playable", () => {
    expect(calculateSeverityScore("playable")).toBe(5);
  });
});
```

### Integration Test Pattern

```typescript
// src/test/integration/supabase/issues.test.ts

import { describe, it, expect, beforeAll } from "vitest";
import { getPGlite } from "~/test/setup/pglite";
import { getIssuesForMachine } from "~/server/data-access/issues";

describe("getIssuesForMachine", () => {
  beforeAll(async () => {
    const db = getPGlite();
    // Seed test data
    await db.exec("INSERT INTO machines ...");
    await db.exec("INSERT INTO issues ...");
  });

  it("returns issues for machine", async () => {
    const issues = await getIssuesForMachine("machine-id");
    expect(issues).toHaveLength(2);
  });
});
```

## Contributing New Patterns

When you implement the same approach 2+ times:

1. **Identify the pattern**: What problem does it solve?
2. **Document it**: Add to `docs/patterns/` or update `docs/PATTERNS.md`
3. **Include example**: Show concrete code, not just description
4. **Keep it concise**: Focus on PinPoint-specific patterns

Example contribution:

```markdown
## New Pattern: Multi-Step Forms

**When to use**: Forms with multiple steps (e.g., machine setup wizard)

**Pattern**:
1. Use React 19 `useActionState` for state management
2. Store step number in state
3. Conditionally render step components
4. Final step calls Server Action

**Example**: See `src/components/machines/CreateMachineWizard.tsx`
```

## Pattern Checklist

Before implementing a feature:

- [ ] Checked `docs/PATTERNS.md` for existing patterns
- [ ] Reviewed similar features in codebase
- [ ] Following Server Action template (auth → validate → action → revalidate)
- [ ] Using React 19 `cache()` for data fetching
- [ ] Returning structured results from Server Actions
- [ ] Adding new pattern if implementing 2+ times

## Additional Resources

- Pattern index: `docs/PATTERNS.md`
- Specific patterns: `docs/patterns/*.md`
- Non-negotiables: `docs/NON_NEGOTIABLES.md`
- Architecture: `docs/TECH_SPEC.md`
