---
name: bun-dev
version: 1.0.0
description: Bun runtime patterns including native APIs, SQLite, testing, HTTP server, WebSocket, file handling, and shell operations. Use when working with Bun runtime, bun:sqlite, Bun.serve, bun:test, or when Bun, --bun flag, SQLite, or Bun-specific patterns mentioned.
---

# Bun Development

Bun runtime → native APIs → zero-dependency patterns.

<when_to_use>

- Bun runtime development
- SQLite database with bun:sqlite
- HTTP server with Bun.serve
- Testing with bun:test
- File operations with Bun.file/Bun.write
- Shell operations with $ template
- Password hashing with Bun.password
- Environment variable handling
- Building and bundling

NOT for: Node.js-only patterns, cross-runtime libraries, non-Bun projects

</when_to_use>

<runtime_basics>

**Package management**:

```bash
bun install          # Install dependencies (faster than npm/yarn)
bun add zod          # Add package
bun remove zod       # Remove package
bun update           # Update all dependencies
```

**Script execution**:

```bash
bun run dev          # Run script from package.json
bun run src/index.ts # Execute TypeScript directly
bun --watch index.ts # Watch mode with auto-reload
```

**Testing**:

```bash
bun test             # Run all tests
bun test src/        # Run tests in directory
bun test --watch     # Watch mode
bun test --coverage  # With coverage
```

**Building**:

```bash
bun build ./index.ts --outfile dist/bundle.js
bun build ./index.ts --compile --outfile myapp  # Standalone executable
```

</runtime_basics>

## File Operations

<file_operations>

```typescript
// Read file (lazy, efficient)
const file = Bun.file('./data.json');

// Check existence
if (!(await file.exists())) {
  throw new Error('File not found');
}

// Read as different formats
const text = await file.text();
const json = await file.json();
const buffer = await file.arrayBuffer();
const stream = file.stream(); // For large files

// File metadata
console.log(file.size);  // bytes
console.log(file.type);  // MIME type

// Write file
await Bun.write('./output.txt', 'content');
await Bun.write('./data.json', JSON.stringify(data));

// Write blob
const blob = new Blob(['data'], { type: 'text/plain' });
await Bun.write('./blob.txt', blob);

// Write stream (for large data)
const readable = new ReadableStream({ ... });
await Bun.write('./stream.txt', readable);
```

</file_operations>

## SQLite (bun:sqlite)

<sqlite>

```typescript
import { Database } from 'bun:sqlite';

const db = new Database('app.db', {
  create: true,
  readwrite: true,
  strict: true
});

// Create tables
db.run(`
  CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  )
`);

// Prepared statements (recommended)
const getUser = db.prepare('SELECT * FROM users WHERE id = ?');
const createUser = db.prepare('INSERT INTO users (id, email, name) VALUES (?, ?, ?) RETURNING *');
const updateUser = db.prepare('UPDATE users SET email = ?, name = ? WHERE id = ? RETURNING *');
const deleteUser = db.prepare('DELETE FROM users WHERE id = ? RETURNING *');

// Query execution
const user = getUser.get('user-123');        // Single row
const allUsers = db.prepare('SELECT * FROM users').all();  // All rows
db.prepare('DELETE FROM users WHERE id = ?').run('user-123');  // No return

// Parameter binding
const stmt = db.prepare('SELECT * FROM users WHERE email = ? AND role = ?');
const user = stmt.get('alice@example.com', 'admin');

// Named parameters
const stmt2 = db.prepare('SELECT * FROM users WHERE email = $email');
const user2 = stmt2.get({ $email: 'alice@example.com' });

// Transactions
const transfer = db.transaction((fromId: string, toId: string, amount: number) => {
  db.run('UPDATE accounts SET balance = balance - ? WHERE id = ?', [amount, fromId]);
  db.run('UPDATE accounts SET balance = balance + ? WHERE id = ?', [amount, toId]);
});

transfer('alice', 'bob', 100);  // Atomic
// Automatically rolled back on error

// Close when done
db.close();
```

See [sqlite-patterns.md](references/sqlite-patterns.md) for migrations and advanced patterns.

</sqlite>

## Password Hashing

<password>

```typescript
// Hash password (argon2id recommended)
const hashedPassword = await Bun.password.hash('password123', {
  algorithm: 'argon2id',
  memoryCost: 65536,  // 64 MB
  timeCost: 3         // Iterations
});

// Or bcrypt
const bcryptHash = await Bun.password.hash('password123', {
  algorithm: 'bcrypt',
  cost: 12  // Work factor
});

// Verify password
const isValid = await Bun.password.verify('password123', hashedPassword);

if (!isValid) {
  throw new Error('Invalid password');
}
```

**In auth flow**:

```typescript
app.post('/auth/register', zValidator('json', RegisterSchema), async (c) => {
  const { email, password } = c.req.valid('json');
  const db = c.get('db');

  const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
  if (existing) {
    throw new HTTPException(409, { message: 'Email already registered' });
  }

  const hashedPassword = await Bun.password.hash(password, { algorithm: 'argon2id' });
  const user = db.prepare(`
    INSERT INTO users (id, email, password)
    VALUES (?, ?, ?)
    RETURNING id, email
  `).get(crypto.randomUUID(), email, hashedPassword);

  return c.json({ user }, 201);
});
```

</password>

## HTTP Server

<http_server>

```typescript
Bun.serve({
  port: 3000,
  fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === '/') {
      return new Response('Hello, world!');
    }

    if (url.pathname === '/json') {
      return Response.json({ message: 'Hello' });
    }

    return new Response('Not found', { status: 404 });
  },
  error(err) {
    return new Response(`Error: ${err.message}`, { status: 500 });
  }
});

console.log('Server running on http://localhost:3000');
```

**With Hono** (recommended for complex APIs):

```typescript
import { Hono } from 'hono';

const app = new Hono()
  .get('/', (c) => c.text('Hello'))
  .get('/json', (c) => c.json({ ok: true }));

Bun.serve({
  port: 3000,
  fetch: app.fetch
});
```

</http_server>

## WebSocket

<websocket>

```typescript
import type { ServerWebSocket } from 'bun';

type WebSocketData = { userId: string };

Bun.serve<WebSocketData>({
  port: 3000,
  fetch(req, server) {
    const url = new URL(req.url);

    if (url.pathname === '/ws') {
      const userId = url.searchParams.get('userId') || 'anonymous';
      const success = server.upgrade(req, { data: { userId } });

      if (!success) {
        return new Response('WebSocket upgrade failed', { status: 400 });
      }
      return undefined;
    }

    return new Response('Hello');
  },
  websocket: {
    open(ws: ServerWebSocket<WebSocketData>) {
      console.log(`Client connected: ${ws.data.userId}`);
      ws.subscribe('chat');
      ws.send(JSON.stringify({ type: 'connected' }));
    },
    message(ws: ServerWebSocket<WebSocketData>, message: string | Buffer) {
      console.log(`Received from ${ws.data.userId}:`, message);
      ws.publish('chat', message);
    },
    close(ws: ServerWebSocket<WebSocketData>) {
      console.log(`Client disconnected: ${ws.data.userId}`);
      ws.unsubscribe('chat');
    }
  }
});
```

</websocket>

## Shell Operations

<shell>

```typescript
import { $ } from 'bun';

// Run commands
const result = await $`ls -la`;
console.log(result.text());

// With variables (auto-escaped)
const dir = './src';
await $`find ${dir} -name "*.ts"`;

// Check exit code
const { exitCode } = await $`npm test`.nothrow();
if (exitCode !== 0) {
  console.error('Tests failed');
}

// Spawn process
const proc = Bun.spawn(['ls', '-la']);
await proc.exited;
console.log('Exit code:', proc.exitCode);

// Capture output
const proc2 = Bun.spawn(['echo', 'Hello'], { stdout: 'pipe' });
const output = await new Response(proc2.stdout).text();
```

</shell>

## Testing (bun:test)

<testing>

```typescript
import { describe, test, expect, beforeAll, afterAll, beforeEach, afterEach } from 'bun:test';

describe('feature', () => {
  let db: Database;

  beforeAll(() => {
    console.log('Setup test suite');
  });

  afterAll(() => {
    console.log('Cleanup test suite');
  });

  beforeEach(() => {
    db = new Database(':memory:');
  });

  afterEach(() => {
    db.close();
  });

  test('behavior', () => {
    expect(result).toBe(expected);
    expect(arr).toContain(item);
    expect(fn).toThrow();
    expect(obj).toEqual({ foo: 'bar' });
    expect(value).toBeDefined();
    expect(value).toBeTruthy();
  });

  test('async behavior', async () => {
    const result = await asyncFn();
    expect(result).toBeDefined();
  });

  test.todo('pending feature');
  test.skip('temporarily disabled');
});
```

**Run tests**:

```bash
bun test                    # All tests
bun test src/api.test.ts    # Specific file
bun test --watch            # Watch mode
bun test --coverage         # With coverage
```

</testing>

## Environment Variables

<environment>

```typescript
// Access (same as process.env)
console.log(Bun.env.NODE_ENV);
console.log(Bun.env.DATABASE_URL);

// With Zod validation
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string(),
  PORT: z.coerce.number().int().positive().default(3000),
  API_KEY: z.string().min(32)
});

const env = EnvSchema.parse(Bun.env);
export default env;
```

Bun automatically loads `.env` files:

```bash
# .env
DATABASE_URL=sqlite://app.db
PORT=3000

# .env.local (gitignored overrides)
# .env.production (production values)
```

</environment>

## Compression

<compression>

```typescript
import { gzipSync, gunzipSync, deflateSync, inflateSync } from 'bun';

// Gzip
const data = 'Large data string...'.repeat(1000);
const compressed = gzipSync(data);
const decompressed = gunzipSync(compressed);

// Deflate
const deflated = deflateSync('data');
const inflated = inflateSync(deflated);

// In HTTP response
app.get('/large-data', (c) => {
  const data = generateLargeDataset();
  const json = JSON.stringify(data);

  const acceptEncoding = c.req.header('accept-encoding') || '';

  if (acceptEncoding.includes('gzip')) {
    const compressed = gzipSync(json);
    return c.body(compressed, {
      headers: {
        'Content-Type': 'application/json',
        'Content-Encoding': 'gzip'
      }
    });
  }

  return c.json(data);
});
```

</compression>

## Performance Utilities

<performance>

```typescript
// High-resolution timing
const start = Bun.nanoseconds();
await doWork();
const elapsed = Bun.nanoseconds() - start;
console.log(`Took ${elapsed / 1_000_000}ms`);

// Hashing
const hash = Bun.hash(data);
const crc32 = Bun.hash.crc32(data);
const sha256 = Bun.CryptoHasher.hash('sha256', data);

// Sleep
await Bun.sleep(1000); // ms

// Memory usage
const usage = process.memoryUsage();
console.log('RSS:', usage.rss / 1024 / 1024, 'MB');
console.log('Heap Used:', usage.heapUsed / 1024 / 1024, 'MB');
```

</performance>

## Building & Bundling

<building>

```bash
# Bundle for production
bun build ./index.ts --outfile dist/bundle.js --minify --sourcemap

# Bundle with external dependencies
bun build ./index.ts --outfile dist/bundle.js --external hono --external zod

# Compile to standalone executable
bun build ./index.ts --compile --outfile myapp

# Cross-compile
bun build ./index.ts --compile --target=bun-linux-x64 --outfile myapp-linux
bun build ./index.ts --compile --target=bun-darwin-arm64 --outfile myapp-macos
bun build ./index.ts --compile --target=bun-windows-x64 --outfile myapp.exe
```

</building>

<rules>

ALWAYS:
- Use Bun APIs when available (faster, native)
- Prepared statements for database queries
- Transactions for multi-statement operations
- argon2id for password hashing
- Validate environment variables at startup
- Close database connections when done

NEVER:
- String interpolation in SQL queries (use parameters)
- Store plaintext passwords
- Ignore async disposal cleanup
- Use deprecated Node.js APIs when Bun native exists

PREFER:
- Bun.file over fs.readFile
- Bun.write over fs.writeFile
- bun:sqlite over external SQLite libraries
- Bun.password over bcrypt/argon2 packages
- $ shell template over child_process

</rules>

<references>

- [sqlite-patterns.md](references/sqlite-patterns.md) — migrations, connection pooling
- [server-patterns.md](references/server-patterns.md) — HTTP, WebSocket, streaming
- [testing.md](references/testing.md) — bun:test patterns, lifecycle hooks

**Examples:**
- [database-crud.md](examples/database-crud.md) — SQLite CRUD patterns
- [file-uploads.md](examples/file-uploads.md) — streaming file handling

</references>
