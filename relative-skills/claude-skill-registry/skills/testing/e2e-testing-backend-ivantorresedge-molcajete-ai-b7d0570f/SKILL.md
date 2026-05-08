---
name: e2e-testing-backend
description: End-to-end testing patterns for backend services. Use when testing complete application flows.
---

# E2E Testing Backend Skill

This skill covers end-to-end testing patterns for Node.js backend services.

## When to Use

Use this skill when:
- Testing complete user flows
- Verifying multi-service integration
- Testing deployment readiness
- Validating production-like scenarios

## Core Principle

**TEST LIKE A USER** - E2E tests verify the system works as users expect. Test complete flows, not individual parts.

## Setup

```typescript
// tests/e2e/setup.ts
import { execSync, spawn, ChildProcess } from 'child_process';

let serverProcess: ChildProcess | null = null;

export async function startServer(): Promise<void> {
  // Build the application
  execSync('npm run build', { stdio: 'inherit' });

  // Start the server
  serverProcess = spawn('node', ['dist/index.js'], {
    env: {
      ...process.env,
      NODE_ENV: 'test',
      PORT: '3001',
    },
    stdio: 'pipe',
  });

  // Wait for server to be ready
  await waitForServer('http://localhost:3001/health', 30000);
}

export async function stopServer(): Promise<void> {
  if (serverProcess) {
    serverProcess.kill();
    serverProcess = null;
  }
}

async function waitForServer(url: string, timeout: number): Promise<void> {
  const startTime = Date.now();

  while (Date.now() - startTime < timeout) {
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch {
      // Server not ready yet
    }
    await new Promise((resolve) => setTimeout(resolve, 500));
  }

  throw new Error(`Server did not start within ${timeout}ms`);
}
```

## Vitest Configuration

```typescript
// vitest.e2e.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['tests/e2e/**/*.e2e.test.ts'],
    testTimeout: 60000,
    hookTimeout: 30000,
    globalSetup: './tests/e2e/global-setup.ts',
    setupFiles: ['./tests/e2e/setup-file.ts'],
    pool: 'forks',
    poolOptions: {
      forks: {
        singleFork: true,
      },
    },
  },
});
```

## Global Setup

```typescript
// tests/e2e/global-setup.ts
import { execSync } from 'child_process';

export async function setup(): Promise<void> {
  console.log('Setting up E2E environment...');

  // Start required services
  execSync('docker-compose -f docker-compose.test.yml up -d', {
    stdio: 'inherit',
  });

  // Wait for services to be ready
  await waitForPostgres();
  await waitForRedis();

  // Run migrations
  execSync('npx prisma migrate deploy', { stdio: 'inherit' });

  // Seed test data
  execSync('npx prisma db seed', { stdio: 'inherit' });

  console.log('E2E environment ready');
}

export async function teardown(): Promise<void> {
  console.log('Tearing down E2E environment...');
  execSync('docker-compose -f docker-compose.test.yml down', {
    stdio: 'inherit',
  });
}

async function waitForPostgres(): Promise<void> {
  const maxAttempts = 30;
  for (let i = 0; i < maxAttempts; i++) {
    try {
      execSync('docker-compose -f docker-compose.test.yml exec -T db pg_isready', {
        stdio: 'pipe',
      });
      return;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
  throw new Error('PostgreSQL did not start');
}

async function waitForRedis(): Promise<void> {
  const maxAttempts = 30;
  for (let i = 0; i < maxAttempts; i++) {
    try {
      execSync('docker-compose -f docker-compose.test.yml exec -T redis redis-cli ping', {
        stdio: 'pipe',
      });
      return;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
  throw new Error('Redis did not start');
}
```

## Docker Compose for Tests

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
      POSTGRES_DB: testdb
    ports:
      - "5433:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U test"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6380:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  api:
    build: .
    environment:
      NODE_ENV: test
      DATABASE_URL: postgresql://test:test@db:5432/testdb
      REDIS_URL: redis://redis:6379
      PORT: 3000
    ports:
      - "3001:3000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
```

## Complete Flow Test

```typescript
// tests/e2e/auth-flow.e2e.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';

const API_URL = process.env.API_URL ?? 'http://localhost:3001';

describe('Authentication Flow E2E', () => {
  const testUser = {
    email: `e2e-${Date.now()}@example.com`,
    password: 'Password123!',
    name: 'E2E Test User',
  };

  let accessToken: string;
  let refreshToken: string;
  let userId: string;

  it('registers a new user', async () => {
    const response = await fetch(`${API_URL}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(testUser),
    });

    expect(response.status).toBe(201);

    const data = await response.json();
    expect(data.user.email).toBe(testUser.email);
    expect(data.accessToken).toBeDefined();
    expect(data.refreshToken).toBeDefined();

    accessToken = data.accessToken;
    refreshToken = data.refreshToken;
    userId = data.user.id;
  });

  it('logs in with registered credentials', async () => {
    const response = await fetch(`${API_URL}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testUser.email,
        password: testUser.password,
      }),
    });

    expect(response.status).toBe(200);

    const data = await response.json();
    expect(data.accessToken).toBeDefined();
    accessToken = data.accessToken;
  });

  it('accesses protected resource with token', async () => {
    const response = await fetch(`${API_URL}/api/users/me`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    expect(response.status).toBe(200);

    const data = await response.json();
    expect(data.email).toBe(testUser.email);
    expect(data.name).toBe(testUser.name);
  });

  it('refreshes access token', async () => {
    const response = await fetch(`${API_URL}/api/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });

    expect(response.status).toBe(200);

    const data = await response.json();
    expect(data.accessToken).toBeDefined();
    expect(data.accessToken).not.toBe(accessToken);
  });

  it('logs out successfully', async () => {
    const response = await fetch(`${API_URL}/api/auth/logout`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    expect(response.status).toBe(200);
  });

  it('rejects requests after logout', async () => {
    const response = await fetch(`${API_URL}/api/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });

    expect(response.status).toBe(401);
  });
});
```

## CRUD Flow Test

```typescript
// tests/e2e/posts-crud.e2e.test.ts
import { describe, it, expect, beforeAll } from 'vitest';

const API_URL = process.env.API_URL ?? 'http://localhost:3001';

describe('Posts CRUD Flow E2E', () => {
  let authToken: string;
  let postId: string;

  beforeAll(async () => {
    // Login to get auth token
    const response = await fetch(`${API_URL}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'e2e-user@example.com',
        password: 'Password123!',
      }),
    });
    const data = await response.json();
    authToken = data.accessToken;
  });

  it('creates a post', async () => {
    const response = await fetch(`${API_URL}/api/posts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authToken}`,
      },
      body: JSON.stringify({
        title: 'E2E Test Post',
        content: 'This is an E2E test post',
        published: false,
      }),
    });

    expect(response.status).toBe(201);

    const data = await response.json();
    expect(data.title).toBe('E2E Test Post');
    postId = data.id;
  });

  it('retrieves the created post', async () => {
    const response = await fetch(`${API_URL}/api/posts/${postId}`, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    expect(response.status).toBe(200);

    const data = await response.json();
    expect(data.title).toBe('E2E Test Post');
    expect(data.published).toBe(false);
  });

  it('updates the post', async () => {
    const response = await fetch(`${API_URL}/api/posts/${postId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authToken}`,
      },
      body: JSON.stringify({
        title: 'Updated E2E Test Post',
        published: true,
      }),
    });

    expect(response.status).toBe(200);

    const data = await response.json();
    expect(data.title).toBe('Updated E2E Test Post');
    expect(data.published).toBe(true);
  });

  it('lists posts including the new one', async () => {
    const response = await fetch(`${API_URL}/api/posts?published=true`, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    expect(response.status).toBe(200);

    const data = await response.json();
    const post = data.data.find((p: { id: string }) => p.id === postId);
    expect(post).toBeDefined();
    expect(post.title).toBe('Updated E2E Test Post');
  });

  it('deletes the post', async () => {
    const response = await fetch(`${API_URL}/api/posts/${postId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${authToken}` },
    });

    expect(response.status).toBe(204);
  });

  it('returns 404 for deleted post', async () => {
    const response = await fetch(`${API_URL}/api/posts/${postId}`, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    expect(response.status).toBe(404);
  });
});
```

## API Client Helper

```typescript
// tests/e2e/helpers/api-client.ts
const API_URL = process.env.API_URL ?? 'http://localhost:3001';

interface RequestOptions {
  method?: string;
  body?: unknown;
  headers?: Record<string, string>;
  token?: string;
}

export async function apiRequest(
  path: string,
  options: RequestOptions = {}
): Promise<Response> {
  const { method = 'GET', body, headers = {}, token } = options;

  const requestHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
    ...headers,
  };

  if (token) {
    requestHeaders['Authorization'] = `Bearer ${token}`;
  }

  return fetch(`${API_URL}${path}`, {
    method,
    headers: requestHeaders,
    body: body ? JSON.stringify(body) : undefined,
  });
}

export async function login(
  email: string,
  password: string
): Promise<{ accessToken: string; refreshToken: string }> {
  const response = await apiRequest('/api/auth/login', {
    method: 'POST',
    body: { email, password },
  });

  if (!response.ok) {
    throw new Error(`Login failed: ${response.status}`);
  }

  return response.json();
}
```

## Running E2E Tests

```bash
# Start services and run tests
npm run test:e2e

# Run against existing services
API_URL=http://localhost:3000 npm run test:e2e

# Run specific test file
npm run test:e2e -- auth-flow.e2e.test.ts
```

## Package.json Scripts

```json
{
  "scripts": {
    "test:e2e": "docker-compose -f docker-compose.test.yml up -d && vitest run --config vitest.e2e.config.ts; docker-compose -f docker-compose.test.yml down",
    "test:e2e:watch": "docker-compose -f docker-compose.test.yml up -d && vitest --config vitest.e2e.config.ts"
  }
}
```

## Best Practices

1. **Test complete flows** - Registration to logout
2. **Isolate test data** - Use unique identifiers
3. **Clean up after tests** - Delete created resources
4. **Use real services** - No mocking in E2E
5. **Test error scenarios** - Invalid data, auth failures
6. **Parallel-safe** - Tests should not interfere

## Notes

- E2E tests are slowest - run sparingly
- Use in CI/CD before deployment
- Test against staging environment
- Monitor test flakiness
