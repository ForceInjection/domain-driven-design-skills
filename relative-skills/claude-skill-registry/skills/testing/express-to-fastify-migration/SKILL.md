---
name: express-to-fastify-migration
description: Migrate Express.js REST APIs to Fastify with automated testing, performance benchmarking, and schema generation. Use when migrating Express applications to Fastify, modernizing Node.js APIs, improving API performance, or when users mention Express to Fastify migration, Fastify conversion, API modernization, or performance optimization of Express apps.
---

# Express to Fastify Migration

## MANDATORY WORKFLOW

You MUST complete each phase IN ORDER. Do NOT proceed to the next phase until the current phase is complete. Report your progress after each phase.

---

## Phase 1: Assessment & Baseline Capture (REQUIRED before any code changes)

Before writing ANY code, you MUST:

### 1.1 Document the existing codebase:
1. **Routes**: List ALL Express routes in the codebase (method, path, handler)
2. **Middleware**: List ALL middleware (global and route-specific)
3. **Dependencies**: List ALL Express-related dependencies from package.json
4. **Custom patterns**: Note any authentication, error handling, or custom middleware

### 1.2 Capture Express API responses (CRITICAL):

**You MUST save the actual API responses BEFORE making any code changes.** These are required to verify output compatibility in Phase 6.

For EACH endpoint identified in 1.1, capture the response:

```bash
# Example: save responses to files for later comparison
curl -s "http://localhost:PORT/endpoint" | jq . > /tmp/express_endpoint.json
curl -s "http://localhost:PORT/endpoint?query=test" | jq . > /tmp/express_endpoint_query.json
```

Save responses for:
- Success cases (200 responses)
- Error cases (400/404 responses) 
- Response headers (especially Cache-Control, Content-Type)

### 1.3 Capture Express baseline performance (CRITICAL):

**You MUST benchmark the Express server BEFORE making any code changes.** This baseline is required for performance comparison in Phase 6.

1. Install autocannon: `npm install autocannon --save-dev`
2. Start the Express server
3. Run benchmarks on key endpoints and record the results:

```bash
npx autocannon -c 10 -d 10 http://localhost:PORT/endpoint
```

4. **Save these metrics** - you will compare against them in Phase 6:
   - Requests/second
   - Average latency
   - Throughput (bytes/sec)

**STOP**: You MUST report your assessment findings, saved API responses, AND Express baseline metrics before proceeding to Phase 2.

---

## Phase 2: Dependencies

Install Fastify and equivalents for EACH Express plugin identified in Phase 1.

### REQUIRED plugins (ALWAYS install these):
- `fastify` - Core framework
- `@fastify/helmet` - Security headers (REQUIRED)
- `@fastify/rate-limit` - Rate limiting (REQUIRED)

### Conditional plugins (install if Express equivalent was used):
- `compression` → `@fastify/compress`
- `cors` → `@fastify/cors`
- `cookie-parser` → `@fastify/cookie`
- `express-session` → `@fastify/session`
- `body-parser` → Built-in (no plugin needed)

### IMPORTANT: Do NOT uninstall Express yet!
Keep Express installed until Phase 6 (Performance Verification) is complete. This allows you to run both servers simultaneously for benchmarking comparison.

**STOP**: Confirm all Fastify dependencies installed before Phase 3. Express stays installed for now.

---

## Phase 3: Route Migration

For EACH route identified in Phase 1, you MUST:

1. Convert syntax using these patterns:
   - `app.get()` → `fastify.get()`
   - `req/res` → `request/reply`
   - `res.json(data)` → `return data`
   - `res.status(code).json(data)` → `reply.code(code); return data`
   - `res.header()` → `reply.header()`

2. Add JSON schema for validation (REQUIRED for every route):
```typescript
fastify.get('/example', {
  schema: {
    querystring: {
      type: 'object',
      properties: {
        query: { type: 'string' }
      }
    },
    response: {
      200: {
        type: 'object',
        properties: {
          data: { type: 'array' }
        }
      }
    }
  }
}, async (request, reply) => {
  // handler
});
```

3. Convert middleware to hooks:
   - Global middleware → `fastify.addHook('onRequest', ...)`
   - Route middleware → `preHandler` option
   - Error middleware → `fastify.setErrorHandler(...)`

Consult `references/migration_patterns.md` for detailed examples.

**STOP**: Confirm all routes migrated with schemas before Phase 4.

---

## Phase 4: Server Setup

Update the server entry point:

1. Configure Fastify with logging:
```typescript
const app = Fastify({ logger: true });
```

2. Register REQUIRED security plugins:
```typescript
app.register(helmet);
app.register(rateLimit, { max: 100, timeWindow: '1 minute' });
```

3. Register error handler:
```typescript
app.setErrorHandler((error, request, reply) => {
  request.log.error(error);
  reply.status(error.statusCode || 500).send({ error: error.message });
});
```

4. Update server startup to use Fastify's listen():
```typescript
await app.listen({ port: PORT, host: '0.0.0.0' });
```

**STOP**: Confirm server setup complete before Phase 5.

---

## Phase 5: Validation (REQUIRED before completion)

You MUST complete ALL of these checks:

### Build & Test
- [ ] Run `npm run build` - MUST succeed with no errors
- [ ] Run `npm test` - ALL tests MUST pass
- [ ] Run linting - MUST pass or only have unrelated warnings

### Code Quality Verification
- [ ] ALL routes have JSON schemas
- [ ] Security plugins registered (`@fastify/helmet`, `@fastify/rate-limit`)
- [ ] Error handler configured
- [ ] Logging enabled

### Documentation
- [ ] Update package.json description (Express → Fastify)
- [ ] Update README.md to reference Fastify
- [ ] Update any API documentation

**Do NOT report completion until ALL boxes are checked.**

---

## Phase 6: Output & Performance Comparison (REQUIRED)

### 6.1 Verify API output compatibility (CRITICAL):

Compare Fastify responses against the Express responses saved in Phase 1.

For EACH endpoint, verify the output matches:

```bash
# Capture Fastify response
curl -s "http://localhost:PORT/endpoint" | jq . > /tmp/fastify_endpoint.json

# Compare against Express baseline from Phase 1
diff /tmp/express_endpoint.json /tmp/fastify_endpoint.json
```

You MUST verify:
- [ ] Response body structure is identical
- [ ] Status codes match for success and error cases
- [ ] Response headers match (Content-Type, Cache-Control, etc.)

**If outputs differ, fix the Fastify implementation before proceeding.**

### 6.2 Compare performance against baseline:

1. **Start the Fastify server** on the same port used for baseline
2. **Run the same benchmarks** used in Phase 1:

```bash
npx autocannon -c 10 -d 10 http://localhost:PORT/endpoint
```

3. **Compare results** against the Express baseline from Phase 1:

| Metric | Express (Phase 1) | Fastify (Phase 6) | Improvement |
|--------|------------------|-------------------|-------------|
| Req/sec | _baseline_ | _new_ | _X%_ |
| Latency | _baseline_ | _new_ | _X%_ |
| Throughput | _baseline_ | _new_ | _X%_ |

Expected improvements:
- 2-3x more requests/second
- 30-40% lower latency

**STOP**: You MUST report BOTH the output compatibility verification AND the performance comparison table before Phase 7.

---

## Phase 7: Cleanup (REQUIRED - Final Step)

After performance verification is complete:

1. **Uninstall Express dependencies**:
```bash
npm uninstall express morgan compression cors cookie-parser express-session
npm uninstall @types/express @types/morgan @types/compression @types/cors
```

2. **Remove any Express-specific code** that was kept for benchmarking

3. **Final verification**:
- [ ] Run `npm run build` - MUST succeed
- [ ] Run `npm test` - ALL tests MUST pass
- [ ] Confirm no Express imports remain in production code

**Do NOT report migration complete until Express is fully removed.**

---

## Reference Documentation

Consult these files for detailed patterns:

- `references/migration_patterns.md` - Route and middleware conversion examples
- `references/plugin_ecosystem.md` - Complete Express → Fastify plugin mapping
- `scripts/benchmark.js` - Performance benchmarking
- `scripts/schema_generator.js` - Generate JSON schemas from examples
- `assets/server_template.js` - Production-ready Fastify boilerplate

---

## Common Pitfalls to AVOID

1. **Skipping Phase 1 baselines**: You MUST capture Express API responses AND performance metrics BEFORE any code changes - you cannot verify compatibility or compare performance without baselines
2. **Forgetting schemas**: EVERY route MUST have a JSON schema
3. **Skipping security plugins**: helmet and rate-limit are REQUIRED
4. **Using callbacks**: Fastify expects async/await, not callbacks
5. **Manual JSON serialization**: Use `return`, not `reply.send(JSON.stringify())`
6. **Forgetting to close app in tests**: Add `afterAll(() => app.close())`
7. **Not verifying output compatibility**: API responses must be identical after migration - always diff the before/after outputs

---

## TypeScript Patterns

For typed routes:

```typescript
interface QueryParams {
  query?: string;
}

fastify.get<{ Querystring: QueryParams }>(
  '/search',
  { schema: { querystring: { type: 'object', properties: { query: { type: 'string' } } } } },
  async (request, reply) => {
    const { query } = request.query; // Typed!
    return { results: [] };
  }
);
```
