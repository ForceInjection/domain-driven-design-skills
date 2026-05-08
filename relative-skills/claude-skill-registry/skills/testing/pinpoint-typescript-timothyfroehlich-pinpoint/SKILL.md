---
name: pinpoint-typescript
description: TypeScript strictest patterns, type guards, optional properties (exactOptionalPropertyTypes), Drizzle query safety, null checks. Use when fixing type errors, implementing complex types, or when user mentions TypeScript/types/generics.
---

# PinPoint TypeScript Guide

## When to Use This Skill

Use this skill when:
- Fixing TypeScript compilation errors
- Implementing complex types or generics
- Dealing with optional properties and `exactOptionalPropertyTypes`
- Working with Drizzle ORM types
- Handling null/undefined safety
- User mentions: "TypeScript", "type error", "type guard", "optional", "nullable"

## Quick Reference

### Critical TypeScript Rules
1. **Strictest config**: No `any`, no `!`, no unsafe `as`
2. **Explicit return types**: Required for public functions
3. **Path aliases**: Use `~/` instead of relative imports
4. **Optional property assignment**: Use conditional spread, not direct assignment with undefined
5. **Type guards**: Write proper predicates for narrowing

### Common Fixes

**Optional Properties (exactOptionalPropertyTypes)**:
```typescript
// ✅ Correct: Conditional spread
const data = {
  id: uuid(),
  ...(name && { name }),
  ...(description && { description }),
};

// ❌ Wrong: Direct assignment
const data = { name: value }; // Error if value is undefined
```

## Detailed Documentation

Read this file for comprehensive TypeScript patterns:

```bash
# All TypeScript strictest patterns
cat docs/TYPESCRIPT_STRICTEST_PATTERNS.md
```

## Core Safety Patterns

### Null Safety & Optional Chaining

```typescript
// ✅ Safe authentication check
const supabase = await createClient();
const { data: { user } } = await supabase.auth.getUser();

if (!user?.id) {
  throw new Error("Unauthorized");
}
const userId = user.id; // Now safe - TypeScript knows user is not null

// ✅ Safe array access
const firstItem = items[0]?.name ?? "No items";
const lastItem = items.at(-1)?.name ?? "No items";

// ✅ Safe object property access
const machineName = issue.machine?.name ?? "Unknown";
```

### Optional Property Assignment (exactOptionalPropertyTypes)

```typescript
// ✅ Correct: Conditional assignment
const data: { name?: string } = {};
if (value) data.name = value;

// ✅ Correct: Object spread with conditional
const data = {
  id: uuid(),
  ...(name && { name }),
  ...(description && { description }),
};

// ❌ Wrong: Direct assignment of potentially undefined
const data: { name?: string } = { name: value }; // Error if value is undefined
```

### Type Guards

```typescript
// ✅ Type guard for arrays
function hasItems<T>(arr: T[] | undefined): arr is T[] {
  return arr !== undefined && arr.length > 0;
}

// Usage
if (hasItems(issues)) {
  issues.forEach(issue => console.log(issue.title)); // Safe
}

// ✅ Type guard for Supabase user
function isValidUser(user: unknown): user is { id: string; email: string } {
  return (
    typeof user === "object" &&
    user !== null &&
    "id" in user &&
    "email" in user &&
    typeof (user as any).id === "string" &&
    typeof (user as any).email === "string"
  );
}

// ✅ Type guard for discriminated unions
type Result =
  | { type: "success"; data: string }
  | { type: "error"; message: string };

function processResult(result: Result) {
  if (result.type === "success") {
    console.log(result.data); // Safe - TypeScript knows it's success
  } else {
    console.log(result.message); // Safe - TypeScript knows it's error
  }
}
```

## Common Error Fixes

### "Object is possibly null" Errors

```typescript
// ❌ Problem
const user = await getUserById(id);
console.log(user.email); // Error: Object is possibly null

// ✅ Solution 1: Null check
const user = await getUserById(id);
if (!user) throw new Error("User not found");
console.log(user.email); // Safe

// ✅ Solution 2: Optional chaining with fallback
const user = await getUserById(id);
console.log(user?.email ?? "No email"); // Safe with fallback
```

### "Argument of type X is not assignable to parameter" Errors

```typescript
// ❌ Problem: Mixing string and number
const id: string | number = getId();
const result = await fetchUser(id); // Error: expects string

// ✅ Solution: Type narrowing
const id: string | number = getId();
const userId = typeof id === "string" ? id : String(id);
const result = await fetchUser(userId);
```

### Union Type Errors

```typescript
// ✅ Discriminated unions
type Result =
  | { type: "success"; data: string }
  | { type: "error"; message: string };

function processResult(result: Result) {
  if (result.type === "success") {
    console.log(result.data); // Safe
  } else {
    console.log(result.message); // Safe
  }
}
```

## Drizzle Query Safety

### Safe Query Patterns

```typescript
import { eq, and, desc } from "drizzle-orm";
import { issues, machines } from "~/server/db/schema";

// ✅ Safe Drizzle queries with proper typing
export async function getIssuesForMachine(machineId: string): Promise<Issue[]> {
  if (!machineId) {
    throw new Error("Machine ID required");
  }

  return await db.query.issues.findMany({
    where: eq(issues.machineId, machineId),
    orderBy: desc(issues.createdAt),
  });
}

// ✅ Explicit column selection
const users = await db.query.users.findMany({
  columns: {
    id: true,
    email: true,
    name: true,
    // Explicitly exclude sensitive fields
  },
});

// ✅ Type-safe joins
const issuesWithMachines = await db.query.issues.findMany({
  with: {
    machine: true, // Drizzle infers correct types
  },
});
```

### Database Type Conversion

```typescript
// Database types (snake_case)
import { users } from "~/server/db/schema";
type DbUser = typeof users.$inferSelect;

// Application types (camelCase)
export type User = {
  id: string;
  email: string;
  fullName: string | null;
  createdAt: Date;
};

// Converter at boundary
export function dbUserToUser(dbUser: DbUser): User {
  return {
    id: dbUser.id,
    email: dbUser.email,
    fullName: dbUser.full_name,
    createdAt: new Date(dbUser.created_at),
  };
}
```

## Supabase SSR Safety

### Safe Auth Context

```typescript
// ✅ Safe auth context in Server Component
export default async function ProtectedPage() {
  const supabase = await createClient();
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  // Handle both success and error cases
  if (error || !user) {
    redirect("/login");
  }

  // user is guaranteed to be non-null here
  return <DashboardContent user={user} />;
}
```

### Server Action Safety

```typescript
// ✅ Safe Server Action with auth
"use server";
export async function updateProfile(formData: FormData): Promise<void> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  const name = formData.get("name");
  if (typeof name !== "string") {
    throw new Error("Name must be a string");
  }

  await db.update(users).set({ name }).where(eq(users.id, user.id));
  revalidatePath("/profile");
}
```

## Strict Function Signatures

```typescript
// ✅ Explicit return types prevent inference errors
export async function getIssuesForMachine(machineId: string): Promise<Issue[]> {
  if (!machineId) {
    throw new Error("Machine ID required");
  }

  return await db.query.issues.findMany({
    where: eq(issues.machineId, machineId),
  });
}

// ✅ Strict parameter validation
export function createIssue(data: {
  title: string;
  description?: string;
  machineId: string;
  severity: "minor" | "playable" | "unplayable";
}): Promise<Issue> {
  return db.insert(issues).values(data).returning();
}
```

## Import Path Consistency

```typescript
// ✅ Always use TypeScript alias
import { validateUser } from "~/lib/validation/user";
import { createClient } from "~/lib/supabase/server";

// ❌ Never use relative paths for deep imports
import { validateUser } from "../../../lib/validation/user";
```

## Anti-Patterns to Avoid

```typescript
// ❌ Never: any types
const data: any = await fetchData();

// ❌ Never: Non-null assertion without justification
const user = getUser()!.email; // Dangerous

// ❌ Never: Ignoring TypeScript errors
// @ts-ignore
const result = dangerousOperation();

// ❌ Never: Unsafe type assertions
const user = data as User; // Without validation

// ✅ Instead: Proper validation
function isUser(data: unknown): data is User {
  return typeof data === "object" && data !== null && "id" in data;
}
if (isUser(data)) {
  const user = data; // Safe
}
```

## Server Components Safety

### Async Component Patterns

```typescript
// ✅ Safe async Server Component
export default async function MachineIssuesPage({
  params
}: {
  params: { machineId: string }
}): Promise<JSX.Element> {
  if (!params.machineId) {
    throw new Error("Machine ID required");
  }

  const issues = await db.query.issues.findMany({
    where: eq(issues.machineId, params.machineId),
    orderBy: desc(issues.createdAt),
  });

  return (
    <div>
      {issues.map((issue) => (
        <IssueCard key={issue.id} issue={issue} />
      ))}
    </div>
  );
}
```

### Form Data Validation

```typescript
// ✅ Safe FormData handling with Zod
"use server";
import { z } from "zod";

const createIssueSchema = z.object({
  title: z.string().min(1, "Title required"),
  description: z.string().optional(),
  machineId: z.string().uuid("Invalid machine ID"),
  severity: z.enum(["minor", "playable", "unplayable"]),
});

export async function createIssueAction(formData: FormData) {
  const rawData = {
    title: formData.get("title"),
    description: formData.get("description"),
    machineId: formData.get("machineId"),
    severity: formData.get("severity"),
  };

  // Type-safe validation
  const validData = createIssueSchema.parse(rawData);

  const [issue] = await db.insert(issues).values(validData).returning();
  revalidatePath("/issues");
  return issue;
}
```

## TypeScript Checklist

Before committing TypeScript code:

- [ ] No `any` types
- [ ] No non-null assertions (`!`)
- [ ] No unsafe type assertions (`as`)
- [ ] Explicit return types on public functions
- [ ] Optional properties use conditional spread
- [ ] Type guards for complex narrowing
- [ ] Path aliases (`~/`) instead of relative imports
- [ ] `npm run typecheck` passes

## Additional Resources

- TypeScript patterns: `docs/TYPESCRIPT_STRICTEST_PATTERNS.md`
- Non-negotiables: `docs/NON_NEGOTIABLES.md` (CORE-TS-* rules)
- Drizzle types: Use Context7 MCP for latest patterns
