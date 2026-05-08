---
name: authentication-strategies
description: Authentication patterns including JWT, sessions, and OAuth. Use when implementing user authentication.
---

# Authentication Strategies Skill

This skill covers authentication patterns for Node.js APIs.

## When to Use

Use this skill when:
- Implementing user authentication
- Setting up JWT token handling
- Integrating OAuth providers
- Managing user sessions

## Core Principle

**DEFENSE IN DEPTH** - Multiple layers of security. Never trust client input. Always validate tokens server-side.

## JWT Authentication

### Setup

```bash
npm install @fastify/jwt bcrypt
npm install -D @types/bcrypt
```

### JWT Plugin

```typescript
// src/plugins/auth.ts
import { FastifyPluginAsync, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import jwt from '@fastify/jwt';

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: {
      userId: string;
      role: 'USER' | 'ADMIN';
      iat: number;
      exp: number;
    };
    user: {
      userId: string;
      role: 'USER' | 'ADMIN';
    };
  }
}

declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (request: FastifyRequest) => Promise<void>;
    authenticateOptional: (request: FastifyRequest) => Promise<void>;
  }
}

const authPlugin: FastifyPluginAsync = async (fastify) => {
  await fastify.register(jwt, {
    secret: process.env.JWT_SECRET!,
    sign: {
      expiresIn: '15m', // Short-lived access tokens
    },
  });

  // Required authentication
  fastify.decorate('authenticate', async (request: FastifyRequest) => {
    await request.jwtVerify();
  });

  // Optional authentication
  fastify.decorate('authenticateOptional', async (request: FastifyRequest) => {
    try {
      await request.jwtVerify();
    } catch {
      // Continue without user
    }
  });
};

export default fp(authPlugin, { name: 'auth' });
```

### Auth Routes

```typescript
// src/routes/auth.ts
import { FastifyPluginAsync } from 'fastify';
import { z } from 'zod';
import bcrypt from 'bcrypt';

const RegisterSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(1),
});

const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

const authRoutes: FastifyPluginAsync = async (fastify) => {
  // Register
  fastify.post<{ Body: z.infer<typeof RegisterSchema> }>('/register', async (request, reply) => {
    const { email, password, name } = request.body;

    // Check if user exists
    const existing = await fastify.db.user.findUnique({ where: { email } });
    if (existing) {
      return reply.status(400).send({ error: 'Email already registered' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const user = await fastify.db.user.create({
      data: { email, password: hashedPassword, name },
    });

    // Generate tokens
    const accessToken = fastify.jwt.sign({
      userId: user.id,
      role: user.role,
    });

    const refreshToken = await createRefreshToken(fastify, user.id);

    return reply.status(201).send({
      user: { id: user.id, email: user.email, name: user.name },
      accessToken,
      refreshToken,
    });
  });

  // Login
  fastify.post<{ Body: z.infer<typeof LoginSchema> }>('/login', async (request, reply) => {
    const { email, password } = request.body;

    const user = await fastify.db.user.findUnique({ where: { email } });
    if (!user) {
      return reply.status(401).send({ error: 'Invalid credentials' });
    }

    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return reply.status(401).send({ error: 'Invalid credentials' });
    }

    const accessToken = fastify.jwt.sign({
      userId: user.id,
      role: user.role,
    });

    const refreshToken = await createRefreshToken(fastify, user.id);

    return {
      user: { id: user.id, email: user.email, name: user.name },
      accessToken,
      refreshToken,
    };
  });

  // Refresh token
  fastify.post<{ Body: { refreshToken: string } }>('/refresh', async (request, reply) => {
    const { refreshToken } = request.body;

    const token = await fastify.db.refreshToken.findUnique({
      where: { token: refreshToken },
      include: { user: true },
    });

    if (!token || token.expiresAt < new Date()) {
      return reply.status(401).send({ error: 'Invalid refresh token' });
    }

    // Rotate refresh token
    await fastify.db.refreshToken.delete({ where: { id: token.id } });
    const newRefreshToken = await createRefreshToken(fastify, token.userId);

    const accessToken = fastify.jwt.sign({
      userId: token.user.id,
      role: token.user.role,
    });

    return { accessToken, refreshToken: newRefreshToken };
  });

  // Logout
  fastify.post('/logout', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    // Delete all refresh tokens for user
    await fastify.db.refreshToken.deleteMany({
      where: { userId: request.user.userId },
    });

    return { success: true };
  });
};

async function createRefreshToken(fastify: FastifyInstance, userId: string): Promise<string> {
  const token = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

  await fastify.db.refreshToken.create({
    data: { token, userId, expiresAt },
  });

  return token;
}

export default authRoutes;
```

### Protected Routes

```typescript
// src/routes/users.ts
import { FastifyPluginAsync } from 'fastify';

const usersRoutes: FastifyPluginAsync = async (fastify) => {
  // Protected route
  fastify.get('/me', {
    preHandler: [fastify.authenticate],
  }, async (request) => {
    const user = await fastify.db.user.findUnique({
      where: { id: request.user.userId },
      select: { id: true, email: true, name: true, role: true },
    });

    return user;
  });

  // Admin only route
  fastify.get('/admin/users', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    if (request.user.role !== 'ADMIN') {
      return reply.status(403).send({ error: 'Forbidden' });
    }

    return fastify.db.user.findMany();
  });
};

export default usersRoutes;
```

## OAuth 2.0 Integration

### Google OAuth

```typescript
// src/routes/oauth.ts
import { FastifyPluginAsync } from 'fastify';

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID!;
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET!;
const GOOGLE_REDIRECT_URI = process.env.GOOGLE_REDIRECT_URI!;

const oauthRoutes: FastifyPluginAsync = async (fastify) => {
  // Initiate Google OAuth
  fastify.get('/google', async (request, reply) => {
    const params = new URLSearchParams({
      client_id: GOOGLE_CLIENT_ID,
      redirect_uri: GOOGLE_REDIRECT_URI,
      response_type: 'code',
      scope: 'email profile',
      access_type: 'offline',
    });

    return reply.redirect(
      `https://accounts.google.com/o/oauth2/v2/auth?${params}`
    );
  });

  // Google OAuth callback
  fastify.get<{ Querystring: { code: string } }>('/google/callback', async (request, reply) => {
    const { code } = request.query;

    // Exchange code for tokens
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        code,
        client_id: GOOGLE_CLIENT_ID,
        client_secret: GOOGLE_CLIENT_SECRET,
        redirect_uri: GOOGLE_REDIRECT_URI,
        grant_type: 'authorization_code',
      }),
    });

    const tokens = await tokenResponse.json();

    // Get user info
    const userResponse = await fetch('https://www.googleapis.com/oauth2/v2/userinfo', {
      headers: { Authorization: `Bearer ${tokens.access_token}` },
    });

    const googleUser = await userResponse.json();

    // Find or create user
    let user = await fastify.db.user.findUnique({
      where: { email: googleUser.email },
    });

    if (!user) {
      user = await fastify.db.user.create({
        data: {
          email: googleUser.email,
          name: googleUser.name,
          googleId: googleUser.id,
          password: '', // No password for OAuth users
        },
      });
    }

    // Generate JWT
    const accessToken = fastify.jwt.sign({
      userId: user.id,
      role: user.role,
    });

    // Redirect to frontend with token
    return reply.redirect(`${process.env.FRONTEND_URL}/auth/callback?token=${accessToken}`);
  });
};

export default oauthRoutes;
```

## API Key Authentication

```typescript
// src/plugins/api-key.ts
import { FastifyPluginAsync, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';

declare module 'fastify' {
  interface FastifyRequest {
    apiKey?: { id: string; name: string; permissions: string[] };
  }
  interface FastifyInstance {
    authenticateApiKey: (request: FastifyRequest) => Promise<void>;
  }
}

const apiKeyPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.decorate('authenticateApiKey', async (request: FastifyRequest) => {
    const key = request.headers['x-api-key'] as string | undefined;

    if (!key) {
      throw fastify.httpErrors.unauthorized('API key required');
    }

    const apiKey = await fastify.db.apiKey.findUnique({
      where: { key },
    });

    if (!apiKey || !apiKey.active) {
      throw fastify.httpErrors.unauthorized('Invalid API key');
    }

    // Update last used
    await fastify.db.apiKey.update({
      where: { id: apiKey.id },
      data: { lastUsedAt: new Date() },
    });

    request.apiKey = {
      id: apiKey.id,
      name: apiKey.name,
      permissions: apiKey.permissions,
    };
  });
};

export default fp(apiKeyPlugin);
```

## Password Security

```typescript
// src/lib/password.ts
import bcrypt from 'bcrypt';
import { z } from 'zod';

const SALT_ROUNDS = 12;

// Password requirements
export const PasswordSchema = z.string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain uppercase letter')
  .regex(/[a-z]/, 'Password must contain lowercase letter')
  .regex(/[0-9]/, 'Password must contain number')
  .regex(/[^A-Za-z0-9]/, 'Password must contain special character');

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

export function isPasswordCompromised(password: string): boolean {
  // Check against common passwords list
  const commonPasswords = ['password', '123456', 'qwerty'];
  return commonPasswords.includes(password.toLowerCase());
}
```

## Best Practices

1. **Short-lived access tokens** - 15 minutes maximum
2. **Rotate refresh tokens** - On each use
3. **Hash passwords** - bcrypt with high cost factor
4. **Rate limit auth endpoints** - Prevent brute force
5. **Secure cookies** - HttpOnly, Secure, SameSite
6. **Validate all tokens** - Server-side verification

## Notes

- Never store plain-text passwords
- Use HTTPS in production
- Implement account lockout
- Log authentication events
- Support MFA for sensitive operations
