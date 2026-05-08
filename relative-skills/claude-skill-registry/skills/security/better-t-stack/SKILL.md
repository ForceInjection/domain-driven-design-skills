---
name: better-t-stack
description: Patterns and best practices for Better-T-Stack projects (TanStack Router, Hono, Drizzle, tRPC, Better Auth)
---

# Better-T-Stack Development

Guidance for building with the Better-T-Stack: TanStack Router + Hono + Drizzle + tRPC + Better Auth.

## Stack Overview

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | TanStack Router | Type-safe routing with loaders |
| Backend | Hono | Fast, edge-ready HTTP server |
| Database | SQLite/PostgreSQL + Drizzle | Type-safe ORM |
| API | tRPC | End-to-end type safety |
| Auth | Better Auth | Self-hosted authentication |
| Build | Turborepo | Monorepo with caching |
| Lint | Biome | Fast Rust-based tooling |

---

## Project Structure

```
my-app/
├── apps/
│   ├── web/                 # TanStack Router frontend
│   │   ├── src/
│   │   │   ├── routes/      # File-based routing
│   │   │   ├── components/  # React components
│   │   │   ├── lib/         # Utilities, tRPC client
│   │   │   └── main.tsx
│   │   └── package.json
│   └── server/              # Hono backend
│       ├── src/
│       │   ├── routes/      # API routes
│       │   ├── db/          # Drizzle schema & migrations
│       │   ├── trpc/        # tRPC routers
│       │   └── index.ts
│       └── package.json
├── packages/
│   ├── shared/              # Shared types, utils
│   └── ui/                  # Shared UI components
├── turbo.json
└── package.json
```

---

## TanStack Router Patterns

### File-Based Routing

```
routes/
├── __root.tsx          # Root layout
├── index.tsx           # / (home)
├── about.tsx           # /about
├── dashboard/
│   ├── index.tsx       # /dashboard
│   ├── settings.tsx    # /dashboard/settings
│   └── $projectId.tsx  # /dashboard/:projectId
└── _auth/              # Layout route group
    ├── login.tsx       # /login
    └── register.tsx    # /register
```

### Route with Loader

```typescript
// routes/dashboard/$projectId.tsx
import { createFileRoute } from '@tanstack/react-router'
import { trpc } from '@/lib/trpc'

export const Route = createFileRoute('/dashboard/$projectId')({
  loader: async ({ params }) => {
    return trpc.projects.getById.query({ id: params.projectId })
  },
  component: ProjectPage,
})

function ProjectPage() {
  const project = Route.useLoaderData()
  return <div>{project.name}</div>
}
```

### Protected Routes

```typescript
// routes/_auth.tsx (layout)
import { createFileRoute, redirect } from '@tanstack/react-router'
import { getSession } from '@/lib/auth'

export const Route = createFileRoute('/_auth')({
  beforeLoad: async () => {
    const session = await getSession()
    if (!session) {
      throw redirect({ to: '/login' })
    }
  },
})
```

---

## Hono Backend Patterns

### Route Organization

```typescript
// src/routes/index.ts
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { trpcServer } from '@hono/trpc-server'
import { appRouter } from './trpc'
import { authRouter } from './auth'

const app = new Hono()

// Middleware
app.use('*', logger())
app.use('*', cors())

// Routes
app.route('/auth', authRouter)
app.use('/trpc/*', trpcServer({ router: appRouter }))

// Health check
app.get('/health', (c) => c.json({ status: 'ok' }))

export default app
```

### Environment Variables

```typescript
// src/env.ts
import { z } from 'zod'

const envSchema = z.object({
  DATABASE_URL: z.string(),
  BETTER_AUTH_SECRET: z.string(),
  BETTER_AUTH_URL: z.string().url(),
})

export const env = envSchema.parse(process.env)
```

---

## Drizzle ORM Patterns

### Schema Definition

```typescript
// src/db/schema.ts
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'
import { createId } from '@paralleldrive/cuid2'

export const users = sqliteTable('users', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  email: text('email').unique().notNull(),
  name: text('name'),
  createdAt: integer('created_at', { mode: 'timestamp' })
    .$defaultFn(() => new Date()),
})

export const projects = sqliteTable('projects', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  name: text('name').notNull(),
  userId: text('user_id').references(() => users.id).notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' })
    .$defaultFn(() => new Date()),
})
```

### Queries

```typescript
// src/db/queries.ts
import { db } from './client'
import { projects, users } from './schema'
import { eq } from 'drizzle-orm'

export async function getUserProjects(userId: string) {
  return db.query.projects.findMany({
    where: eq(projects.userId, userId),
    with: {
      user: true,
    },
  })
}
```

### Migrations

```bash
# Generate migration
npx drizzle-kit generate

# Apply migration
npx drizzle-kit migrate

# Open Drizzle Studio
npx drizzle-kit studio
```

---

## tRPC Patterns

### Router Definition

```typescript
// src/trpc/routers/projects.ts
import { z } from 'zod'
import { router, protectedProcedure } from '../trpc'
import { db } from '@/db/client'
import { projects } from '@/db/schema'
import { eq } from 'drizzle-orm'

export const projectsRouter = router({
  list: protectedProcedure.query(async ({ ctx }) => {
    return db.query.projects.findMany({
      where: eq(projects.userId, ctx.user.id),
    })
  }),

  create: protectedProcedure
    .input(z.object({ name: z.string().min(1) }))
    .mutation(async ({ ctx, input }) => {
      const [project] = await db.insert(projects).values({
        name: input.name,
        userId: ctx.user.id,
      }).returning()
      return project
    }),

  getById: protectedProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      return db.query.projects.findFirst({
        where: eq(projects.id, input.id),
      })
    }),
})
```

### App Router

```typescript
// src/trpc/index.ts
import { router } from './trpc'
import { projectsRouter } from './routers/projects'
import { usersRouter } from './routers/users'

export const appRouter = router({
  projects: projectsRouter,
  users: usersRouter,
})

export type AppRouter = typeof appRouter
```

### Frontend Client

```typescript
// apps/web/src/lib/trpc.ts
import { createTRPCReact } from '@trpc/react-query'
import type { AppRouter } from '@server/trpc'

export const trpc = createTRPCReact<AppRouter>()
```

---

## Better Auth Patterns

### Server Setup

```typescript
// src/auth.ts
import { betterAuth } from 'better-auth'
import { drizzleAdapter } from 'better-auth/adapters/drizzle'
import { db } from './db/client'

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: 'sqlite',
  }),
  emailAndPassword: {
    enabled: true,
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
  },
})
```

### Auth Routes

```typescript
// src/routes/auth.ts
import { Hono } from 'hono'
import { auth } from '../auth'

export const authRouter = new Hono()

authRouter.on(['POST', 'GET'], '/*', (c) => auth.handler(c.req.raw))
```

### Protected Procedures (tRPC)

```typescript
// src/trpc/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server'
import { auth } from '../auth'

const t = initTRPC.context<{ req: Request }>().create()

export const protectedProcedure = t.procedure.use(async ({ ctx, next }) => {
  const session = await auth.api.getSession({ headers: ctx.req.headers })

  if (!session) {
    throw new TRPCError({ code: 'UNAUTHORIZED' })
  }

  return next({
    ctx: {
      ...ctx,
      user: session.user,
      session: session.session,
    },
  })
})
```

---

## Turborepo Commands

```bash
# Run all dev servers
turbo dev

# Build all packages
turbo build

# Run tests
turbo test

# Lint all packages
turbo lint

# Run specific app
turbo dev --filter=web
turbo dev --filter=server
```

---

## Common Gotchas

### 1. Type Inference Issues

Ensure `@server/trpc` path alias is configured in `tsconfig.json`:
```json
{
  "compilerOptions": {
    "paths": {
      "@server/*": ["../server/src/*"]
    }
  }
}
```

### 2. CORS in Development

Configure CORS for frontend port:
```typescript
app.use('*', cors({
  origin: ['http://localhost:5173'],
  credentials: true,
}))
```

### 3. Session Cookies

Ensure cookies work cross-origin:
```typescript
session: {
  cookieCache: {
    enabled: true,
    maxAge: 60 * 5, // 5 minutes
  },
}
```

### 4. Drizzle Relations

Define relations for `with` queries:
```typescript
export const projectsRelations = relations(projects, ({ one }) => ({
  user: one(users, {
    fields: [projects.userId],
    references: [users.id],
  }),
}))
```

---

## Best Practices

1. **Type Everything** - Let TypeScript flow from database to UI
2. **Collocate** - Keep related code together (route + loader + component)
3. **Server First** - Prefer server-side data fetching with loaders
4. **Validate Inputs** - Use Zod schemas for all tRPC inputs
5. **Handle Errors** - Use tRPC error codes consistently
6. **Cache Wisely** - Leverage Turborepo and TanStack Query caching
