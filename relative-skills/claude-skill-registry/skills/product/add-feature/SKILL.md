---
name: Add Feature
description: Add a new feature to the Next.js app following best practices
---

# Add Feature Skill

You are helping add a new feature to a Next.js 15 application with TypeScript, Tailwind CSS, BetterAuth, and Drizzle ORM.

## Context

This is a Next.js 15 App Router project with:
- Server Components by default
- Drizzle ORM for database (PostgreSQL)
- BetterAuth for authentication
- TypeScript strict mode
- Tailwind CSS v4 + shadcn/ui

## Your Task

When the user asks to add a feature, follow this workflow:

### 1. Understand Requirements

Ask clarifying questions:
- What routes are needed?
- Is authentication required?
- Does it need database tables?
- What data needs to be displayed?
- What user interactions are needed?

### 2. Plan Architecture

Before coding, outline:
```
Route Structure:
- app/[feature-name]/page.tsx (main page)
- app/[feature-name]/layout.tsx (if needed)
- app/[feature-name]/loading.tsx (loading state)
- app/[feature-name]/error.tsx (error boundary)

Database Schema:
- lib/server/db/schema/[feature].ts (if new tables needed)

Server Actions:
- lib/actions/[feature].ts (for mutations)

Components:
- components/[feature]/ (feature-specific components)
```

### 3. Implementation Order

Always implement in this order:

#### Step 1: Database Schema (if needed)

Create schema file:
```typescript
// lib/server/db/schema/[feature].ts
import { pgTable, text, timestamp, uuid, boolean } from "drizzle-orm/pg-core"
import { createInsertSchema, createSelectSchema } from "drizzle-zod"

export const [tableName] = pgTable("[table_name]", {
  id: uuid("id").primaryKey().defaultRandom(),
  // Add fields here
  createdAt: timestamp("createdAt").notNull().defaultNow(),
  updatedAt: timestamp("updatedAt").notNull().defaultNow(),
})

export const insert[TableName]Schema = createInsertSchema([tableName])
export const select[TableName]Schema = createSelectSchema([tableName])

export type [TableName] = typeof [tableName].$inferSelect
export type New[TableName] = typeof [tableName].$inferInsert
```

Export from schema/index.ts:
```typescript
export * from "./[feature]"
```

Run migration:
```bash
npm run db:push
```

#### Step 2: Server Actions (if mutations needed)

Create server actions:
```typescript
// lib/actions/[feature].ts
"use server"

import { db } from "@/lib/server/db"
import { [tableName], insert[TableName]Schema } from "@/lib/server/db/schema"
import { revalidatePath } from "next/cache"
import { z } from "zod"

export async function create[Resource](data: z.infer<typeof insert[TableName]Schema>) {
  try {
    const validated = insert[TableName]Schema.parse(data)
    const [created] = await db.insert([tableName]).values(validated).returning()
    revalidatePath("/[feature-path]")
    return { success: true, data: created }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error"
    }
  }
}
```

#### Step 3: Page Components

Create the main page (Server Component):
```typescript
// app/[feature]/page.tsx
import { db } from "@/lib/server/db"
import { [tableName] } from "@/lib/server/db/schema"

export const metadata = {
  title: "[Feature Title]",
  description: "[Feature description]",
}

export default async function [Feature]Page() {
  // Fetch data in Server Component
  const data = await db.query.[tableName].findMany()

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold">[Feature Title]</h1>
      {/* Render data */}
    </div>
  )
}
```

#### Step 4: Interactive Components (Client Components)

Only create Client Components when needed:
```typescript
// components/[feature]/[component-name].tsx
"use client"

import { useState } from "react"
import { create[Resource] } from "@/lib/actions/[feature]"
import { Button } from "@/components/ui/button"

export function [ComponentName]() {
  const [isLoading, setIsLoading] = useState(false)

  async function handleAction() {
    setIsLoading(true)
    const result = await create[Resource](data)
    setIsLoading(false)
  }

  return (
    <div>
      <Button onClick={handleAction} disabled={isLoading}>
        {isLoading ? "Loading..." : "Action"}
      </Button>
    </div>
  )
}
```

#### Step 5: Loading & Error States

Create loading.tsx:
```typescript
// app/[feature]/loading.tsx
export default function Loading() {
  return (
    <div className="container mx-auto p-8">
      <div className="h-8 w-64 animate-pulse rounded bg-muted" />
    </div>
  )
}
```

Create error.tsx:
```typescript
// app/[feature]/error.tsx
"use client"

export default function Error({ error, reset }: {
  error: Error
  reset: () => void
}) {
  return (
    <div className="container mx-auto p-8">
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

#### Step 6: Authentication (if needed)

**⚠️ Always use server layouts for auth, NOT middleware.**

Add auth layout with forced dynamic rendering:
```typescript
// app/[feature]/layout.tsx
import { redirect } from "next/navigation"
import { auth } from "@/lib/server/auth"
import { headers } from "next/headers"

// ⚠️ CRITICAL: Force dynamic rendering for fresh auth checks
export const dynamic = "force-dynamic"

export default async function [Feature]Layout({
  children,
}: {
  children: React.ReactNode
}) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    redirect("/auth/signin")
  }

  return <>{children}</>
}
```

**Why server layouts for auth:**
- ✅ Execute on the same request (no extra hops)
- ✅ Full TypeScript support and type inference
- ✅ Can render UI and compose with data fetching
- ✅ Co-located with protected routes

**Do NOT use middleware for auth gates** - middleware should only be used for session refresh and cross-cutting concerns like i18n.

### 4. Best Practices Checklist

Before completing, verify:

- [ ] Server Components by default
- [ ] Client Components only when needed
- [ ] Type safety (TypeScript + Zod validation)
- [ ] Error handling in server actions
- [ ] Loading states (loading.tsx)
- [ ] Error boundaries (error.tsx)
- [ ] Metadata for SEO
- [ ] Revalidation after mutations
- [ ] Mobile-responsive design
- [ ] Accessibility (ARIA attributes, semantic HTML)

### 5. Testing

After implementation:

1. Test the feature manually
2. Verify TypeScript compilation: `npm run type-check`
3. Check for lint errors: `npm run lint`
4. Test all user flows
5. Verify error states
6. Test loading states

## Key Principles

1. **Server-First**: Always start with Server Components
2. **Type Safety**: Use TypeScript and Zod everywhere
3. **Co-location**: Keep related code together
4. **Performance**: Minimize client-side JavaScript
5. **User Experience**: Always show loading and error states
6. **Security**: Validate all inputs, check permissions

## Common Patterns

### Data Fetching Pattern
```typescript
// In Server Component
const data = await db.query.table.findMany()
```

### Mutation Pattern
```typescript
// In Server Action
"use server"
const validated = schema.parse(data)
await db.insert(table).values(validated)
revalidatePath("/path")
```

### Form Pattern
```typescript
// Client Component
const result = await serverAction(formData)
if (result.success) {
  router.push("/success")
}
```

---

Now, help the user implement their feature following these guidelines!
