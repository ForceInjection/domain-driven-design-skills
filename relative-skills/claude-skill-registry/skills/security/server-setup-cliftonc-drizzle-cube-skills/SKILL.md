---
name: server-setup
description: Set up drizzle-cube API server with Express, Fastify, Hono, or Next.js framework adapters. Use when configuring the semantic layer server, setting up API endpoints, extracting security context, or initializing drizzle-cube with different web frameworks.
---

# Drizzle Cube Server Setup

This skill helps you set up a Drizzle Cube API server using framework adapters for Express, Fastify, Hono, or Next.js. These adapters provide Cube.js-compatible API endpoints for your semantic layer.

## Core Concept

Drizzle Cube provides framework adapters that:
- Expose Cube.js-compatible REST API endpoints
- Handle security context extraction from requests
- Integrate with your existing web framework
- Support `/load`, `/sql`, and `/meta` endpoints
- **Create the semantic layer compiler internally** from cubes array

## Express Adapter

### Installation

```bash
npm install express drizzle-cube
```

### Basic Setup

```typescript
import express from 'express'
import { createCubeRouter } from 'drizzle-cube/adapters/express'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'

// Initialize database connection
const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const app = express()
app.use(express.json())

// Create Cube API router with cubes array
const cubeRouter = createCubeRouter({
  cubes: [employeesCube, departmentsCube], // Array of cube definitions
  drizzle: db,
  schema: schema,
  // Extract security context from request
  extractSecurityContext: async (req, res) => {
    // Example: Extract from authenticated user
    return {
      organisationId: req.user?.organisationId || 'default-org',
      userId: req.user?.id
    }
  }
})

// Mount the router
app.use('/cubejs-api/v1', cubeRouter)

// Start server
app.listen(3000, () => {
  console.log('Drizzle Cube API listening on port 3000')
})
```

### With Authentication Middleware

```typescript
import express from 'express'
import { createCubeRouter } from 'drizzle-cube/adapters/express'
import { authenticateJWT } from './auth'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const app = express()
app.use(express.json())

// Authentication middleware
app.use('/cubejs-api', authenticateJWT)

const cubeRouter = createCubeRouter({
  cubes: [employeesCube, departmentsCube],
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (req, res) => {
    // req.user is populated by authenticateJWT middleware
    if (!req.user) {
      throw new Error('Unauthorized: No user found')
    }

    return {
      organisationId: req.user.organisationId,
      userId: req.user.id,
      role: req.user.role
    }
  },
  engineType: 'postgres', // Optional: specify database type
  cors: { origin: 'https://yourdomain.com' } // Optional: CORS configuration
})

app.use('/cubejs-api/v1', cubeRouter)

app.listen(3000)
```

### Express Adapter Options

```typescript
interface ExpressAdapterOptions {
  cubes: Cube[]                                // REQUIRED: Array of cube definitions
  drizzle: DrizzleDatabase                     // REQUIRED: Drizzle database instance
  schema?: any                                 // RECOMMENDED: Database schema
  extractSecurityContext: (req, res) => SecurityContext | Promise<SecurityContext>  // REQUIRED
  engineType?: 'postgres' | 'mysql' | 'sqlite' // Optional: auto-detected if not provided
  cors?: CorsOptions                           // Optional: CORS configuration
  basePath?: string                            // Optional: API base path
  jsonLimit?: string                           // Optional: JSON body parser limit (default: '10mb')
}
```

## Fastify Adapter

### Installation

```bash
npm install fastify drizzle-cube
```

### Basic Setup

```typescript
import Fastify from 'fastify'
import { registerCubeRoutes } from 'drizzle-cube/adapters/fastify'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const fastify = Fastify({
  logger: true
})

// Register Cube API plugin
await registerCubeRoutes(fastify, {
  cubes: [employeesCube, departmentsCube], // Array of cube definitions
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (request) => {
    // Extract from Fastify request
    return {
      organisationId: request.user?.organisationId || 'default-org',
      userId: request.user?.id
    }
  }
})

// Start server
await fastify.listen({ port: 3000 })
```

### With JWT Authentication

```typescript
import Fastify from 'fastify'
import fastifyJWT from '@fastify/jwt'
import { registerCubeRoutes } from 'drizzle-cube/adapters/fastify'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const fastify = Fastify({ logger: true })

// Register JWT plugin
await fastify.register(fastifyJWT, {
  secret: process.env.JWT_SECRET!
})

// Authentication decorator
fastify.decorate('authenticate', async (request, reply) => {
  try {
    await request.jwtVerify()
  } catch (err) {
    reply.send(err)
  }
})

// Register Cube API with authentication
await registerCubeRoutes(fastify, {
  cubes: [employeesCube, departmentsCube],
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (request) => {
    // request.user is populated by JWT verification
    if (!request.user) {
      throw new Error('Unauthorized')
    }

    return {
      organisationId: request.user.organisationId,
      userId: request.user.sub,
      tenantId: request.user.tenantId
    }
  },
  basePath: '/cubejs-api/v1' // Optional: custom prefix
})

// Protect routes
fastify.addHook('onRequest', fastify.authenticate)

await fastify.listen({ port: 3000 })
```

## Hono Adapter

### Installation

```bash
npm install hono drizzle-cube
```

### Basic Setup

```typescript
import { Hono } from 'hono'
import { createCubeApp } from 'drizzle-cube/adapters/hono'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const app = new Hono()

// Create Cube API
const cubeApp = createCubeApp({
  cubes: [employeesCube, departmentsCube], // Array of cube definitions
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (c) => {
    // Extract from Hono context
    const authHeader = c.req.header('Authorization')
    const token = authHeader?.replace('Bearer ', '')

    // Decode token and extract context
    const user = await verifyToken(token)

    return {
      organisationId: user.organisationId,
      userId: user.id
    }
  }
})

// Mount the API
app.route('/cubejs-api/v1', cubeApp)

// Start server (for Node.js)
export default app
```

### With JWT Middleware

```typescript
import { Hono } from 'hono'
import { jwt } from 'hono/jwt'
import { createCubeApp } from 'drizzle-cube/adapters/hono'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const app = new Hono()

// JWT middleware
app.use('/cubejs-api/*', jwt({
  secret: process.env.JWT_SECRET!
}))

const cubeApp = createCubeApp({
  cubes: [employeesCube, departmentsCube],
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (c) => {
    // Get JWT payload from context
    const payload = c.get('jwtPayload')

    return {
      organisationId: payload.organisationId,
      userId: payload.sub,
      permissions: payload.permissions
    }
  }
})

app.route('/cubejs-api/v1', cubeApp)

export default app
```

### Edge Runtime (Cloudflare Workers)

```typescript
import { Hono } from 'hono'
import { createCubeApp } from 'drizzle-cube/adapters/hono'
import { drizzle } from 'drizzle-orm/d1'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'

const app = new Hono<{ Bindings: { DB: D1Database } }>()

const cubeApp = createCubeApp({
  cubes: [employeesCube, departmentsCube],
  drizzle: drizzle(c.env.DB), // D1 database binding
  schema: schema,
  extractSecurityContext: async (c) => {
    const authHeader = c.req.header('Authorization')
    // Extract and verify token
    const user = await verifyEdgeToken(authHeader)

    return {
      organisationId: user.orgId,
      userId: user.sub
    }
  }
})

app.route('/cubejs-api/v1', cubeApp)

export default app
```

## Next.js Adapter

### Installation

```bash
npm install next drizzle-cube
```

### API Route Setup (App Router)

```typescript
// app/api/cubejs/[...cube]/route.ts
import { NextRequest } from 'next/server'
import { createCubeHandlers } from 'drizzle-cube/adapters/nextjs'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from '@/lib/schema'
import { employeesCube, departmentsCube } from '@/lib/cubes'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

// Create all cube handlers
const handlers = createCubeHandlers({
  cubes: [employeesCube, departmentsCube], // Array of cube definitions
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (request) => {
    // Get session from Next Auth
    const session = await getServerSession(authOptions)

    if (!session?.user) {
      throw new Error('Unauthorized')
    }

    return {
      organisationId: session.user.organisationId,
      userId: session.user.id
    }
  }
})

// POST handler for /load and /sql
export async function POST(
  request: NextRequest,
  context: { params: Promise<{ cube: string[] }> }
) {
  const params = await context.params
  const endpoint = params.cube[0]

  // Route to appropriate handler
  if (endpoint === 'load') {
    return handlers.load(request, context)
  } else if (endpoint === 'sql') {
    return handlers.sql(request, context)
  }

  return new Response('Not Found', { status: 404 })
}

// GET handler for /meta
export async function GET(
  request: NextRequest,
  context: { params: Promise<{ cube: string[] }> }
) {
  const params = await context.params
  const endpoint = params.cube[0]

  if (endpoint === 'meta') {
    return handlers.meta(request, context)
  }

  return new Response('Not Found', { status: 404 })
}
```

### Alternative: Individual Handler Creation

You can also create individual handlers:

```typescript
// app/api/cubejs/load/route.ts
import { createLoadHandler } from 'drizzle-cube/adapters/nextjs'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from '@/lib/schema'
import { employeesCube, departmentsCube } from '@/lib/cubes'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const loadHandler = createLoadHandler({
  cubes: [employeesCube, departmentsCube],
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (request) => {
    // Your security context extraction logic
    return {
      organisationId: 'org-1',
      userId: 'user-1'
    }
  }
})

export const POST = loadHandler

// app/api/cubejs/meta/route.ts
import { createMetaHandler } from 'drizzle-cube/adapters/nextjs'
// ... same imports and setup ...

const metaHandler = createMetaHandler({
  cubes: [employeesCube, departmentsCube],
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (request) => {
    return { organisationId: 'org-1', userId: 'user-1' }
  }
})

export const GET = metaHandler
```

### Next.js Adapter Options

```typescript
interface NextAdapterOptions {
  cubes: Cube[]                              // REQUIRED: Array of cube definitions
  drizzle: DrizzleDatabase                   // REQUIRED: Drizzle database instance
  schema?: any                               // RECOMMENDED: Database schema
  extractSecurityContext: (request, context?) => SecurityContext | Promise<SecurityContext>  // REQUIRED
  engineType?: 'postgres' | 'mysql' | 'sqlite'  // Optional: auto-detected
  cors?: NextCorsOptions                     // Optional: CORS configuration
  runtime?: 'edge' | 'nodejs'                // Optional: Runtime environment
}
```

## Security Context Patterns

### Session-Based Authentication

```typescript
extractSecurityContext: async (req) => {
  const session = await getSession(req)

  if (!session) {
    throw new Error('Unauthorized: No session')
  }

  return {
    organisationId: session.organisationId,
    userId: session.userId,
    role: session.role
  }
}
```

### JWT Token Authentication

```typescript
import jwt from 'jsonwebtoken'

extractSecurityContext: async (req) => {
  const authHeader = req.headers.authorization
  const token = authHeader?.replace('Bearer ', '')

  if (!token) {
    throw new Error('Unauthorized: No token provided')
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as any

    return {
      organisationId: payload.orgId,
      userId: payload.sub,
      tenantId: payload.tenantId
    }
  } catch (error) {
    throw new Error('Unauthorized: Invalid token')
  }
}
```

### API Key Authentication

```typescript
extractSecurityContext: async (req) => {
  const apiKey = req.headers['x-api-key']

  if (!apiKey) {
    throw new Error('Unauthorized: No API key')
  }

  // Lookup API key in database
  const keyInfo = await db
    .select()
    .from(apiKeys)
    .where(eq(apiKeys.key, apiKey))
    .limit(1)

  if (!keyInfo[0]) {
    throw new Error('Unauthorized: Invalid API key')
  }

  return {
    organisationId: keyInfo[0].organisationId,
    userId: keyInfo[0].userId,
    scope: keyInfo[0].scope
  }
}
```

### Multi-Tenant with Sub-domains

```typescript
extractSecurityContext: async (req) => {
  const host = req.headers.host
  const subdomain = host?.split('.')[0]

  // Lookup organization by subdomain
  const org = await db
    .select()
    .from(organisations)
    .where(eq(organisations.subdomain, subdomain))
    .limit(1)

  if (!org[0]) {
    throw new Error('Invalid subdomain')
  }

  // Also validate user session
  const session = await getSession(req)

  return {
    organisationId: org[0].id,
    userId: session?.userId,
    tenantId: org[0].tenantId
  }
}
```

## Available Endpoints

All adapters expose these Cube.js-compatible endpoints:

### POST /cubejs-api/v1/load

Execute semantic queries and return results.

```typescript
// Request
POST /cubejs-api/v1/load
Content-Type: application/json
Authorization: Bearer <token>

{
  "measures": ["Employees.count"],
  "dimensions": ["Departments.name"]
}

// Response
{
  "data": [
    {
      "Departments.name": "Engineering",
      "Employees.count": 50
    }
  ],
  "annotation": { ... },
  "requestId": "req-123",
  "slowQuery": false
}
```

### POST /cubejs-api/v1/sql

Generate SQL without executing (dry-run).

```typescript
// Request
POST /cubejs-api/v1/sql
Content-Type: application/json
Authorization: Bearer <token>

{
  "measures": ["Employees.count"],
  "dimensions": ["Departments.name"]
}

// Response
{
  "sql": {
    "sql": ["SELECT departments.name, COUNT(employees.id) FROM ..."],
    "params": ["org-123"]
  }
}
```

### GET /cubejs-api/v1/meta

Get cube metadata (dimensions, measures, types).

```typescript
// Request
GET /cubejs-api/v1/meta
Authorization: Bearer <token>

// Response
{
  "cubes": [
    {
      "name": "Employees",
      "title": "Employees",
      "measures": [...],
      "dimensions": [...]
    }
  ]
}
```

## Environment Configuration

```bash
# .env file

# Database connection
DATABASE_URL=postgresql://user:password@localhost:5432/mydb

# JWT authentication
JWT_SECRET=your-secret-key

# API configuration
PORT=3000

# Multi-database support (optional - auto-detected)
DB_TYPE=postgres  # or mysql, sqlite
```

## Complete Example: Express with TypeScript

```typescript
// src/server.ts
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import { createCubeRouter } from 'drizzle-cube/adapters/express'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'
import { employeesCube, departmentsCube } from './cubes'
import { authenticateJWT } from './middleware/auth'

const queryClient = postgres(process.env.DATABASE_URL!)
const db = drizzle(queryClient, { schema })

const app = express()

// Middleware
app.use(helmet())
app.use(cors())
app.use(express.json())

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})

// Cube API (protected)
const cubeRouter = createCubeRouter({
  cubes: [employeesCube, departmentsCube],
  drizzle: db,
  schema: schema,
  extractSecurityContext: async (req, res) => {
    if (!req.user) {
      throw new Error('Unauthorized')
    }

    return {
      organisationId: req.user.organisationId,
      userId: req.user.id,
      role: req.user.role,
      permissions: req.user.permissions
    }
  },
  cors: {
    origin: process.env.ALLOWED_ORIGINS?.split(',')
  }
})

app.use('/cubejs-api/v1', authenticateJWT, cubeRouter)

// Error handling
app.use((err: any, req: any, res: any, next: any) => {
  console.error(err.stack)
  res.status(500).json({
    error: err.message,
    requestId: req.id
  })
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`🚀 Drizzle Cube API running on port ${PORT}`)
})
```

## Defining Cubes

Cubes are defined separately and imported into the adapter:

```typescript
// lib/cubes/employees.ts
import { defineCube } from 'drizzle-cube'
import { eq } from 'drizzle-orm'
import { employees } from '../schema'

export const employeesCube = defineCube('Employees', {
  // Security context filtering (MANDATORY)
  sql: (ctx) => ({
    from: employees,
    where: eq(employees.organisationId, ctx.securityContext.organisationId)
  }),

  dimensions: {
    id: {
      type: 'number',
      sql: () => employees.id,
      primaryKey: true
    },
    name: {
      type: 'string',
      sql: () => employees.name
    }
  },

  measures: {
    count: {
      type: 'count',
      sql: () => employees.id
    }
  }
})

// lib/cubes/index.ts
export { employeesCube } from './employees'
export { departmentsCube } from './departments'
// ... export other cubes
```

## Best Practices

1. **Always validate security context** - Never trust client input
2. **Use HTTPS in production** - Protect API traffic
3. **Implement rate limiting** - Prevent abuse
4. **Log queries** - Monitor performance and usage
5. **Handle errors gracefully** - Return meaningful error messages
6. **Validate environment variables** - Check configuration on startup
7. **Pass cubes as array** - Let adapters create the semantic layer internally
8. **Provide schema for type safety** - Enables better TypeScript inference

## Common Pitfalls

- **Missing authentication** - Always protect Cube API endpoints
- **Wrong function names** - Use `createCubeRouter` for Express, not `createCubeApi`
- **Passing compiler instead of cubes** - Adapters expect `cubes` array, NOT a `semanticLayer` parameter
- **Exposing internal errors** - Sanitize error messages in production
- **No security context validation** - Verify context contains required fields
- **Incorrect CORS configuration** - Configure CORS for your client domains
- **Missing database connection pooling** - Use connection pools for production

## Next Steps

- Define **cubes** with the `cube-definition` skill
- Build **queries** with the `queries` skill
- Create **dashboards** with the `dashboard` skill
- Configure **charts** with the chart-specific skills
