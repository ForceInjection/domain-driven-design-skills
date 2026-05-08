---
name: Scenario Testing
version: 1.0.0
description: End-to-end scenario testing without mocks, using real dependencies. Test scripts go in .scratch/ (gitignored), patterns documented in scenarios.jsonl (committed). Truth hierarchy - scenarios > unit tests > mocks. Use when validating features end-to-end, testing integrations, writing proof programs, or when scenario-test, e2e-test, integration-test, no-mocks, or --scenario are mentioned.
---

# Scenario Testing

End-to-end validation using real dependencies, no mocks ever.

<when_to_use>

- End-to-end feature validation
- Integration testing across services
- Proof programs demonstrating behavior
- Real-world workflow testing
- API contract verification
- Authentication flow validation

NOT for: unit testing, mock testing, performance benchmarking, load testing

</when_to_use>

<iron_law>

NO MOCKS EVER.

Truth hierarchy:
1. **Scenarios** — real dependencies, actual behavior
2. **Unit tests** — isolated logic, synthetic inputs
3. **Mocks** — assumptions about how things work

Mocks test your assumptions, not reality. When mocks pass but production fails, the mock lied. When scenarios fail, reality spoke.

Test against real databases, real APIs, real services. Use test credentials, staging environments, local instances — but always real implementations.

</iron_law>

<directory_structure>

## .scratch/ (gitignored)

Throwaway test scripts for quick validation. Self-contained, runnable, disposable.

CRITICAL: Verify .scratch/ in .gitignore before first use.

## scenarios.jsonl (committed)

Successful scenario patterns documented as JSONL. One scenario per line, each a complete JSON object.

Purpose: capture proven patterns, regression indicators, reusable test cases.

Structure:

```jsonl
{"name":"auth-login-success","description":"User logs in with valid credentials","setup":"Create test user with known password","steps":["POST /auth/login with credentials","Receive JWT token","GET /auth/me with token"],"expected":"User profile returned with correct data","tags":["auth","jwt","happy-path"]}
{"name":"auth-login-invalid","description":"Login fails with wrong password","setup":"Test user exists","steps":["POST /auth/login with wrong password"],"expected":"401 Unauthorized, no token issued","tags":["auth","error-handling"]}
```

</directory_structure>

<scratch_directory>

## Purpose

Quick validation without ceremony. Write script, run against real deps, verify behavior, delete or document.

## Characteristics

- **Gitignored** — never committed, purely local
- **Disposable** — delete after validation or promote to permanent tests
- **Self-contained** — runnable with single command
- **Real dependencies** — actual DB, real APIs, live services

## Naming Conventions

- `test-{feature}.ts` — feature validation (test-auth-flow.ts)
- `debug-{issue}.ts` — investigate specific bug (debug-token-expiry.ts)
- `prove-{behavior}.ts` — demonstrate expected behavior (prove-rate-limiting.ts)
- `explore-{api}.ts` — learn external API behavior (explore-stripe-webhooks.ts)

## Example Structure

```typescript
// .scratch/test-auth-flow.ts
import { db } from '../src/db'
import { api } from '../src/api'

async function testAuthFlow() {
  // Setup: real test user in real database
  const user = await db.users.create({
    email: 'test@example.com',
    password: 'hashed-test-password'
  })

  // Execute: real HTTP requests
  const loginRes = await api.post('/auth/login', {
    email: user.email,
    password: 'test-password'
  })

  // Verify: actual response
  console.assert(loginRes.status === 200, 'Login should succeed')
  console.assert(loginRes.body.token, 'Should receive JWT token')

  const meRes = await api.get('/auth/me', {
    headers: { Authorization: `Bearer ${loginRes.body.token}` }
  })

  console.assert(meRes.status === 200, 'Auth should work')
  console.assert(meRes.body.email === user.email, 'Should return correct user')

  // Cleanup
  await db.users.delete({ id: user.id })

  console.log('✓ Auth flow validated')
}

testAuthFlow().catch(console.error)
```

</scratch_directory>

<scenarios_jsonl>

## Format

Each line is complete JSON object with fields:

```typescript
{
  name: string        // unique identifier (kebab-case)
  description: string // human-readable summary
  setup: string       // prerequisites and state preparation
  steps: string[]     // ordered actions to execute
  expected: string    // success criteria
  tags: string[]      // categorization (auth, api, error, etc)
  env?: string        // required environment (staging, local, prod-readonly)
  duration_ms?: number // typical execution time
}
```

## Purpose

- **Pattern library** — proven scenarios for regression testing
- **Documentation** — executable specification of system behavior
- **Regression detection** — compare new behavior against known-good patterns
- **Test generation** — source material for permanent test suites

## When to Document

Document in scenarios.jsonl when:
- Scenario validates critical user path
- Bug was caught by this scenario (regression prevention)
- Behavior is non-obvious or frequently questioned
- Integration pattern is reusable across features

Delete from .scratch/ when:
- One-time debugging script
- Exploratory testing that didn't find issues
- Temporary verification during development

</scenarios_jsonl>

<workflow>

Loop: Write → Execute → Document → Cleanup

1. **Write proof program** — self-contained script in .scratch/
2. **Run against real dependencies** — actual DB, live APIs, real services
3. **Verify behavior** — assertions on actual responses
4. **Document if successful** — add pattern to scenarios.jsonl
5. **Cleanup** — delete script or promote to permanent tests

Each iteration:
- Script is throwaway (lives in .scratch/)
- Dependencies are real (no mocks, no stubs)
- Validation is concrete (actual behavior observed)
- Pattern captured if valuable (scenarios.jsonl)

</workflow>

<gitignore_check>

MANDATORY before first .scratch/ use:

```bash
grep -q '.scratch/' .gitignore || echo '.scratch/' >> .gitignore
```

Verify .scratch/ directory will not be committed. All test scripts are local-only.

If .gitignore doesn't exist, create it:

```bash
[ -f .gitignore ] || touch .gitignore
grep -q '.scratch/' .gitignore || echo '.scratch/' >> .gitignore
```

</gitignore_check>

<phases>

## 1. Setup → Setting up scenario environment

Prepare real dependencies:
- Spin up local database (Docker, embedded)
- Configure test API keys (staging credentials)
- Initialize test data (real records, not fixtures)
- Verify service connectivity

## 2. Script → Writing proof program

Create .scratch/ test script:
- Import real dependencies (no mocks)
- Setup phase: prepare state
- Execute phase: perform actions
- Verify phase: assert on results
- Cleanup phase: restore state

## 3. Execute → Running against real dependencies

Run proof program:
- Execute with real database connection
- Call actual API endpoints
- Use live service instances
- Observe actual behavior (no simulation)

## 4. Document → Capturing successful patterns

If scenario validates behavior:
- Extract pattern to scenarios.jsonl
- Document setup requirements
- Record expected outcomes
- Tag for categorization

Delete .scratch/ script or promote to permanent test suite.

</phases>

<rules>

ALWAYS:
- Verify .scratch/ in .gitignore before first use
- Test against real dependencies (actual DB, live APIs)
- Use self-contained scripts (runnable with single command)
- Document successful scenarios in scenarios.jsonl
- Cleanup test data after execution
- Tag scenarios for easy filtering
- Include cleanup phase in all scripts
- Use test credentials (never production)

NEVER:
- Use mocks, stubs, or test doubles
- Commit .scratch/ directory contents
- Test against production data
- Skip cleanup phase
- Assume behavior without verification
- Promote assumptions to truth
- Test mocked behavior instead of reality
- Leave test data in shared environments

ESCALATE when:
- No staging environment available
- Real dependencies too expensive to test
- Test requires destructive production operations
- Cannot obtain test credentials

</rules>

<references>

Patterns and examples:
- [patterns.md](references/patterns.md) — common scenario patterns and templates

Related skills:
- debugging-and-diagnosis — investigation methodology (scenarios help reproduce bugs)
- test-driven-development — TDD workflow (scenarios validate features)
- codebase-analysis — evidence gathering (scenarios provide empirical data)

External resources:
- [Growing Object-Oriented Software, Guided by Tests](http://www.growing-object-oriented-software.com/) — end-to-end testing philosophy
- [Testing Without Mocks](https://www.jamesshore.com/v2/blog/2018/testing-without-mocks) — James Shore's pattern library

</references>
