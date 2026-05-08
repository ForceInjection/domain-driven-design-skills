---
name: grey-haven-security-practices
description: Grey Haven's security best practices - input validation, output sanitization, multi-tenant RLS, secret management with Doppler, rate limiting, OWASP Top 10 for TanStack/FastAPI stack. Use when implementing security-critical features.
# v2.0.43: Skills to auto-load for security work
skills:
  - grey-haven-code-style
  - grey-haven-authentication-patterns
  - grey-haven-api-design-standards
# v2.0.74: Tools for security implementation
allowed-tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
  - TodoWrite
---

# Grey Haven Security Practices

Follow Grey Haven Studio's security best practices for TanStack Start and FastAPI applications.

## Secret Management with Doppler

**CRITICAL**: NEVER commit secrets to git. Always use Doppler.

### Doppler Setup

```bash
# Install Doppler CLI
brew install dopplerhq/cli/doppler

# Authenticate
doppler login

# Setup project
cd /path/to/project
doppler setup

# Access secrets
doppler run -- npm run dev          # TypeScript
doppler run -- python app/main.py   # Python
```

### Required Secrets (Doppler)

```bash
# Auth
BETTER_AUTH_SECRET=<random-32-bytes>
JWT_SECRET_KEY=<random-32-bytes>

# Database
DATABASE_URL_ADMIN=postgresql://...
DATABASE_URL_AUTHENTICATED=postgresql://...

# APIs
RESEND_API_KEY=re_...
STRIPE_SECRET_KEY=sk_...
OPENAI_API_KEY=sk-...

# OAuth
GOOGLE_CLIENT_SECRET=GOCSPX-...
GITHUB_CLIENT_SECRET=...
```

### Accessing Secrets in Code

```typescript
// [OK] Correct - Use process.env (Doppler provides at runtime)
const apiKey = process.env.OPENAI_API_KEY!;

// [X] Wrong - Hardcoded secrets
const apiKey = "sk-...";  // NEVER DO THIS!
```

```python
# [OK] Correct - Use os.getenv (Doppler provides at runtime)
import os
api_key = os.getenv("OPENAI_API_KEY")

# [X] Wrong - Hardcoded secrets
api_key = "sk-..."  # NEVER DO THIS!
```

## Input Validation

### TypeScript (Zod Validation)

```typescript
import { z } from "zod";

// [OK] Validate all user input
const UserCreateSchema = z.object({
  email_address: z.string().email().max(255),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150),
});

export const createUser = createServerFn("POST", async (data: unknown) => {
  // Validate input
  const validated = UserCreateSchema.parse(data);

  // Now safe to use
  await db.insert(users).values(validated);
});
```

### Python (Pydantic Validation)

```python
from pydantic import BaseModel, EmailStr, Field, validator

class UserCreate(BaseModel):
    """User creation schema with validation."""
    email_address: EmailStr
    name: str = Field(min_length=1, max_length=100)
    age: int = Field(ge=0, le=150)

    @validator("name")
    def name_must_not_contain_special_chars(cls, v):
        if not v.replace(" ", "").isalnum():
            raise ValueError("Name must be alphanumeric")
        return v

@router.post("/users", response_model=UserResponse)
async def create_user(data: UserCreate):
    # Pydantic validates automatically
    # data is now safe to use
    pass
```

## Output Sanitization

### HTML Escaping (XSS Prevention)

```typescript
// [OK] React automatically escapes in JSX
function UserProfile({ user }: { user: User }) {
  return <div>{user.name}</div>;  // Safe, auto-escaped
}

// [X] Dangerous - Raw HTML
function UserProfile({ user }: { user: User }) {
  return <div dangerouslySetInnerHTML={{ __html: user.bio }} />;  // UNSAFE!
}

// [OK] If HTML needed, sanitize first
import DOMPurify from "isomorphic-dompurify";

function UserProfile({ user }: { user: User }) {
  const sanitized = DOMPurify.sanitize(user.bio);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}
```

### SQL Injection Prevention

```typescript
// [OK] Use parameterized queries (Drizzle)
const user = await db.query.users.findFirst({
  where: eq(users.email_address, email),  // Safe, parameterized
});

// [X] Never concatenate SQL
const user = await db.execute(
  `SELECT * FROM users WHERE email = '${email}'`  // SQL INJECTION!
);
```

```python
# [OK] Use ORM (SQLModel/SQLAlchemy)
user = await session.execute(
    select(User).where(User.email_address == email)  # Safe, parameterized
)

# [X] Never concatenate SQL
user = await session.execute(
    f"SELECT * FROM users WHERE email = '{email}'"  # SQL INJECTION!
)
```

## Multi-Tenant Security (RLS)

### Enable RLS on All Tables

```sql
-- ALWAYS enable RLS for multi-tenant tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
```

### Tenant Isolation Policies

```sql
-- Authenticated users see only their tenant's data
CREATE POLICY "Tenant isolation for users"
  ON users FOR ALL TO authenticated
  USING (tenant_id = (current_setting('request.jwt.claims')::json->>'tenant_id')::uuid);
```

### Always Include tenant_id in Queries

```typescript
// [OK] Correct - Tenant isolation enforced
export const getUser = createServerFn("GET", async (userId: string) => {
  const session = await getSession();
  const tenantId = session.user.tenant_id;

  return await db.query.users.findFirst({
    where: and(
      eq(users.id, userId),
      eq(users.tenant_id, tenantId)  // REQUIRED!
    ),
  });
});

// [X] Wrong - Missing tenant check (security vulnerability!)
export const getUser = createServerFn("GET", async (userId: string) => {
  return await db.query.users.findFirst({
    where: eq(users.id, userId),  // Can access ANY tenant's users!
  });
});
```

## Rate Limiting

### Redis-Based Rate Limiting

```typescript
import { Redis } from "@upstash/redis";

// Doppler provides REDIS_URL
const redis = new Redis({ url: process.env.REDIS_URL! });

async function rateLimit(identifier: string, limit: number, window: number) {
  const key = `rate-limit:${identifier}`;
  const count = await redis.incr(key);

  if (count === 1) {
    await redis.expire(key, window);
  }

  if (count > limit) {
    throw new Error("Rate limit exceeded");
  }

  return { success: true, remaining: limit - count };
}

export const sendEmail = createServerFn("POST", async (data) => {
  const session = await getSession();

  // Rate limit: 10 emails per hour per user
  await rateLimit(`email:${session.user.id}`, 10, 3600);

  // Send email...
});
```

## Authentication Security

### Password Requirements

```typescript
const PasswordSchema = z.string()
  .min(12, "Password must be at least 12 characters")
  .regex(/[A-Z]/, "Must contain uppercase letter")
  .regex(/[a-z]/, "Must contain lowercase letter")
  .regex(/[0-9]/, "Must contain number")
  .regex(/[^A-Za-z0-9]/, "Must contain special character");
```

### Session Security

```typescript
// lib/server/auth.ts
export const auth = betterAuth({
  session: {
    expiresIn: 7 * 24 * 60 * 60,  // 7 days
    updateAge: 24 * 60 * 60,      // Refresh daily
    cookieOptions: {
      httpOnly: true,               // Prevent XSS
      secure: true,                 // HTTPS only
      sameSite: "lax",             // CSRF protection
    },
  },
});
```

## CORS Configuration

```typescript
// TanStack Start
import { cors } from "@elysiajs/cors";

app.use(cors({
  origin: [
    "https://app.greyhaven.studio",
    "https://admin.greyhaven.studio",
  ],
  credentials: true,
  maxAge: 86400,
}));
```

```python
# FastAPI
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://app.greyhaven.studio",
        "https://admin.greyhaven.studio",
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
    max_age=86400,
)
```

## File Upload Security

```typescript
// Validate file type and size
const MAX_FILE_SIZE = 5 * 1024 * 1024;  // 5MB
const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp"];

export const uploadFile = createServerFn("POST", async (file: File) => {
  // Validate size
  if (file.size > MAX_FILE_SIZE) {
    throw new Error("File too large");
  }

  // Validate type
  if (!ALLOWED_TYPES.includes(file.type)) {
    throw new Error("Invalid file type");
  }

  // Validate content (check file header, not just extension)
  const buffer = await file.arrayBuffer();
  const header = new Uint8Array(buffer.slice(0, 4));

  // Check for valid image headers
  // JPEG: FF D8 FF
  // PNG: 89 50 4E 47
  // etc.

  // Generate safe filename (prevent path traversal)
  const ext = file.name.split(".").pop();
  const filename = `${crypto.randomUUID()}.${ext}`;

  // Upload to secure storage...
});
```

## Environment-Specific Security

### Development

```bash
# Doppler: dev config
BETTER_AUTH_URL=http://localhost:3000
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
DEBUG=true
```

### Production

```bash
# Doppler: production config
BETTER_AUTH_URL=https://app.greyhaven.studio
CORS_ORIGINS=https://app.greyhaven.studio
DEBUG=false
FORCE_HTTPS=true
```

## Testing Security

```typescript
// tests/integration/security.test.ts
import { describe, it, expect } from "vitest";

describe("Security", () => {
  it("prevents tenant data leakage", async () => {
    // Create user in tenant A
    const userA = await createUser({ email: "a@example.com", tenantId: "A" });

    // Try to access as tenant B user
    const sessionB = await loginAs({ tenantId: "B" });
    const result = await getUserById(userA.id, sessionB);

    // Should return null or 404, not tenant A's user
    expect(result).toBeNull();
  });

  it("enforces rate limiting", async () => {
    // Make 11 requests (limit is 10)
    for (let i = 0; i < 11; i++) {
      if (i < 10) {
        await sendEmail({ to: "test@example.com" });
      } else {
        await expect(
          sendEmail({ to: "test@example.com" })
        ).rejects.toThrow("Rate limit exceeded");
      }
    }
  });
});
```

## When to Apply This Skill

Use this skill when:
- Handling user input
- Implementing authentication
- Working with sensitive data
- Configuring API endpoints
- Writing database queries
- Implementing file uploads
- Setting up CORS
- Managing secrets with Doppler

## Critical Reminders

1. **Doppler**: ALWAYS use for secrets (never commit to git)
2. **Input validation**: Validate ALL user input (Zod/Pydantic)
3. **RLS**: Enable on all multi-tenant tables
4. **tenant_id**: ALWAYS filter by tenant_id
5. **Rate limiting**: Implement on expensive operations
6. **HTTPS only**: Force HTTPS in production
7. **SQL injection**: Use ORM, never concatenate SQL
8. **XSS**: React auto-escapes, sanitize dangerouslySetInnerHTML
9. **CORS**: Whitelist specific origins
10. **Sessions**: httpOnly, secure, sameSite cookies
