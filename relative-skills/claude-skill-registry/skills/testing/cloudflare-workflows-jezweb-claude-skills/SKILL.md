---
name: cloudflare-workflows
description: |
  Build durable workflows with Cloudflare Workflows (GA April 2025). Features step.do, step.sleep, waitForEvent,
  Vitest testing, and runs for hours to days with automatic retries and state persistence.

  Use when: creating long-running workflows, implementing retry logic, building event-driven processes,
  testing workflows with cloudflare:test, coordinating API calls, or troubleshooting NonRetryableError,
  I/O context errors, serialization failures.

  Keywords: cloudflare workflows, workflows workers, durable execution, workflow step,
  WorkflowEntrypoint, step.do, step.sleep, workflow retries, NonRetryableError,
  workflow state, wrangler workflows, workflow events, long-running tasks, step.sleepUntil,
  step.waitForEvent, workflow bindings, vitest testing, cloudflare:test, introspectWorkflowInstance
---

# Cloudflare Workflows

**Status**: Production Ready ✅ (GA since April 2025)
**Last Updated**: 2025-11-25
**Dependencies**: cloudflare-worker-base (for Worker setup)
**Latest Versions**: wrangler@4.50.0, @cloudflare/workers-types@4.20251121.0

**Recent Updates (2025)**:
- **April 2025**: Workflows GA release - waitForEvent API, Vitest testing, CPU time metrics, 4,500 concurrent instances
- **October 2025**: Instance creation rate 10x faster (100/sec), concurrency increased to 10,000
- **2025 Limits**: Max steps 1,024, state persistence 1MB/step (100MB-1GB per instance), event payloads 1MB, CPU time 5 min max
- **Testing**: cloudflare:test module with introspectWorkflowInstance, disableSleeps, mockStepResult, mockEvent modifiers
- **Platform**: Waiting instances don't count toward concurrency, retention 3-30 days, subrequests 50-1,000

---

## Quick Start (5 Minutes)

```bash
# 1. Scaffold project
npm create cloudflare@latest my-workflow -- --template cloudflare/workflows-starter --git --deploy false
cd my-workflow

# 2. Configure wrangler.jsonc
{
  "name": "my-workflow",
  "main": "src/index.ts",
  "compatibility_date": "2025-11-25",
  "workflows": [{
    "name": "my-workflow",
    "binding": "MY_WORKFLOW",
    "class_name": "MyWorkflow"
  }]
}

# 3. Create workflow (src/index.ts)
import { WorkflowEntrypoint, WorkflowStep, WorkflowEvent } from 'cloudflare:workers';

export class MyWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    const result = await step.do('process', async () => { /* work */ });
    await step.sleep('wait', '1 hour');
    await step.do('continue', async () => { /* more work */ });
  }
}

# 4. Deploy and test
npm run deploy
npx wrangler workflows instances list my-workflow
```

**CRITICAL**: Extends `WorkflowEntrypoint`, implements `run()` with `step` methods, bindings in wrangler.jsonc

---


## Step Methods

### step.do() - Execute Work

```typescript
step.do<T>(name: string, config?: WorkflowStepConfig, callback: () => Promise<T>): Promise<T>
```

**Parameters:**
- `name` - Step name (for observability)
- `config` (optional) - Retry configuration (retries, timeout, backoff)
- `callback` - Async function that does the work

**Returns:** Value from callback (must be serializable)

**Example:**
```typescript
const result = await step.do('call API', { retries: { limit: 10, delay: '10s', backoff: 'exponential' }, timeout: '5 min' }, async () => {
  return await fetch('https://api.example.com/data').then(r => r.json());
});
```

**CRITICAL - Serialization:**
- ✅ Allowed: string, number, boolean, Array, Object, null
- ❌ Forbidden: Function, Symbol, circular references, undefined
- Throws error if return value isn't JSON serializable

---

### step.sleep() - Relative Sleep

```typescript
step.sleep(name: string, duration: WorkflowDuration): Promise<void>
```

**Parameters:**
- `name` - Step name
- `duration` - Number (ms) or string: `"second"`, `"minute"`, `"hour"`, `"day"`, `"week"`, `"month"`, `"year"` (plural forms accepted)

**Examples:**
```typescript
await step.sleep('wait 5 minutes', '5 minutes');
await step.sleep('wait 1 hour', '1 hour');
await step.sleep('wait 2 days', '2 days');
await step.sleep('wait 30 seconds', 30000);  // milliseconds
```

**Note:** Resuming workflows take priority over new instances. Sleeps don't count toward step limits.

---

### step.sleepUntil() - Sleep to Specific Date

```typescript
step.sleepUntil(name: string, timestamp: Date | number): Promise<void>
```

**Parameters:**
- `name` - Step name
- `timestamp` - Date object or UNIX timestamp (milliseconds)

**Examples:**
```typescript
await step.sleepUntil('wait for launch', new Date('2025-12-25T00:00:00Z'));
await step.sleepUntil('wait until time', Date.parse('24 Oct 2024 13:00:00 UTC'));
```

---

### step.waitForEvent() - Wait for External Event (GA April 2025)

```typescript
step.waitForEvent<T>(name: string, options: { type: string; timeout?: string | number }): Promise<T>
```

**Parameters:**
- `name` - Step name
- `options.type` - Event type to match
- `options.timeout` (optional) - Max wait time (default: 24 hours, max: 30 days)

**Returns:** Event payload sent via `instance.sendEvent()`

**Example:**
```typescript
export class PaymentWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    await step.do('create payment', async () => { /* Stripe API */ });

    const webhookData = await step.waitForEvent<StripeWebhook>(
      'wait for payment confirmation',
      { type: 'stripe-webhook', timeout: '1 hour' }
    );

    if (webhookData.status === 'succeeded') {
      await step.do('fulfill order', async () => { /* fulfill */ });
    }
  }
}

// Worker sends event to workflow
export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.url.includes('/webhook/stripe')) {
      const instance = await env.PAYMENT_WORKFLOW.get(instanceId);
      await instance.sendEvent({ type: 'stripe-webhook', payload: await req.json() });
      return new Response('OK');
    }
  }
};
```

**Timeout handling:**
```typescript
try {
  const event = await step.waitForEvent('wait for user', { type: 'user-submitted', timeout: '10 minutes' });
} catch (error) {
  await step.do('send reminder', async () => { /* reminder */ });
}
```

---

## WorkflowStepConfig

```typescript
interface WorkflowStepConfig {
  retries?: {
    limit: number;          // Max attempts (Infinity allowed)
    delay: string | number; // Delay between retries
    backoff?: 'constant' | 'linear' | 'exponential';
  };
  timeout?: string | number; // Max time per attempt
}
```

**Default:** `{ retries: { limit: 5, delay: 10000, backoff: 'exponential' }, timeout: '10 minutes' }`

**Backoff Examples:**
```typescript
// Constant: 30s, 30s, 30s
{ retries: { limit: 3, delay: '30 seconds', backoff: 'constant' } }

// Linear: 1m, 2m, 3m, 4m, 5m
{ retries: { limit: 5, delay: '1 minute', backoff: 'linear' } }

// Exponential (recommended): 10s, 20s, 40s, 80s, 160s
{ retries: { limit: 10, delay: '10 seconds', backoff: 'exponential' }, timeout: '5 minutes' }

// Unlimited retries
{ retries: { limit: Infinity, delay: '1 minute', backoff: 'exponential' } }

// No retries
{ retries: { limit: 0 } }
```

---

## Error Handling

### NonRetryableError

Force workflow to fail immediately without retrying:

```typescript
import { WorkflowEntrypoint, WorkflowStep, WorkflowEvent } from 'cloudflare:workers';
import { NonRetryableError } from 'cloudflare:workflows';

export class MyWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    await step.do('validate input', async () => {
      if (!event.payload.userId) {
        throw new NonRetryableError('userId is required');
      }

      // Validate user exists
      const user = await this.env.DB.prepare(
        'SELECT * FROM users WHERE id = ?'
      ).bind(event.payload.userId).first();

      if (!user) {
        // Terminal error - retrying won't help
        throw new NonRetryableError('User not found');
      }

      return user;
    });
  }
}
```

**When to use NonRetryableError:**
- ✅ Authentication/authorization failures
- ✅ Invalid input that won't change
- ✅ Resource doesn't exist (404)
- ✅ Validation errors
- ❌ Network failures (should retry)
- ❌ Rate limits (should retry with backoff)
- ❌ Temporary service outages (should retry)

---

### Catch Errors to Continue Workflow

Prevent workflow failure by catching optional step errors:

```typescript
export class MyWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    await step.do('process payment', async () => { /* critical */ });

    try {
      await step.do('send email', async () => { /* optional */ });
    } catch (error) {
      await step.do('log failure', async () => {
        await this.env.DB.prepare('INSERT INTO failed_emails VALUES (?, ?)').bind(event.payload.userId, error.message).run();
      });
    }

    await step.do('update status', async () => { /* continues */ });
  }
}
```

**Graceful Degradation:**
```typescript
let result;
try {
  result = await step.do('call primary API', async () => await callPrimaryAPI());
} catch {
  result = await step.do('call backup API', async () => await callBackupAPI());
}
```

---

## Triggering Workflows

**Configure binding (wrangler.jsonc):**
```jsonc
{
  "workflows": [{
    "name": "my-workflow",
    "binding": "MY_WORKFLOW",
    "class_name": "MyWorkflow",
    "script_name": "workflow-worker"  // If workflow in different Worker
  }]
}
```

**Trigger from Worker:**
```typescript
const instance = await env.MY_WORKFLOW.create({ params: { userId: '123' } });
return Response.json({ id: instance.id, status: await instance.status() });
```

**Instance Management:**
```typescript
const instance = await env.MY_WORKFLOW.get(instanceId);
const status = await instance.status();  // { status: 'running'|'complete'|'errored'|'queued', error, output }
await instance.sendEvent({ type: 'user-action', payload: { action: 'approved' } });
await instance.pause();
await instance.resume();
await instance.terminate();
```

---


## State Persistence

Workflows automatically persist state returned from `step.do()`:

**✅ Serializable:**
- Primitives: `string`, `number`, `boolean`, `null`
- Arrays, Objects, Nested structures

**❌ Non-Serializable:**
- Functions, Symbols, circular references, undefined, class instances

**Example:**
```typescript
// ✅ Good
const result = await step.do('fetch data', async () => ({
  users: [{ id: 1, name: 'Alice' }],
  timestamp: Date.now(),
  metadata: null
}));

// ❌ Bad - function not serializable
const bad = await step.do('bad', async () => ({ data: [1, 2, 3], transform: (x) => x * 2 }));  // Throws error!
```

**Access State Across Steps:**
```typescript
const userData = await step.do('fetch user', async () => ({ id: 123, email: 'user@example.com' }));
const orderData = await step.do('create order', async () => ({ userId: userData.id, orderId: 'ORD-456' }));
await step.do('send email', async () => sendEmail({ to: userData.email, subject: `Order ${orderData.orderId}` }));
```

---

## Observability

### Built-in Metrics (Enhanced in 2025)

Workflows automatically track:
- **Instance status**: queued, running, complete, errored, paused, waiting
- **Step execution**: start/end times, duration, success/failure
- **Retry history**: attempts, errors, delays
- **Sleep state**: when workflow will wake up
- **Output**: return values from steps and run()
- **CPU time** (GA April 2025): Active processing time per instance for billing insights

### View Metrics in Dashboard

Access via Cloudflare dashboard:
1. Workers & Pages
2. Select your workflow
3. View instances and metrics

**Metrics include:**
- Total instances created
- Success/error rates
- Average execution time
- Step-level performance
- **CPU time consumption** (2025 feature)

### Programmatic Access

```typescript
const instance = await env.MY_WORKFLOW.get(instanceId);
const status = await instance.status();

console.log(status);
// {
//   status: 'complete' | 'running' | 'errored' | 'queued' | 'waiting' | 'unknown',
//   error: string | null,
//   output: { userId: '123', status: 'processed' }
// }
```

**CPU Time Configuration (2025):**
```jsonc
// wrangler.jsonc
{ "limits": { "cpu_ms": 300000 } }  // 5 minutes max (default: 30 seconds)
```

---

## Limits (Updated 2025)

| Feature | Workers Free | Workers Paid |
|---------|--------------|--------------|
| **Max steps per workflow** | 1,024 | 1,024 |
| **Max state per step** | 1 MiB | 1 MiB |
| **Max state per instance** | 100 MB | 1 GB |
| **Max event payload size** | 1 MiB | 1 MiB |
| **Max sleep/sleepUntil duration** | 365 days | 365 days |
| **Max waitForEvent timeout** | 365 days | 365 days |
| **CPU time per step** | 10 ms | 30 sec (default), 5 min (max) |
| **Duration (wall clock) per step** | Unlimited | Unlimited |
| **Max workflow executions** | 100,000/day | Unlimited |
| **Concurrent instances** | 25 | 10,000 (Oct 2025, up from 4,500) |
| **Instance creation rate** | 100/second | 100/second (Oct 2025, 10x faster) |
| **Max queued instances** | 100,000 | 1,000,000 |
| **Max subrequests per instance** | 50/request | 1,000/request |
| **Retention (completed state)** | 3 days | 30 days |
| **Max Workflow name length** | 64 chars | 64 chars |
| **Max instance ID length** | 100 chars | 100 chars |

**CRITICAL Notes:**
- `step.sleep()` and `step.sleepUntil()` do NOT count toward 1,024 step limit
- **Waiting instances** (sleeping, retrying, or waiting for events) do NOT count toward concurrency limits
- Instance creation rate increased 10x (October 2025): 100 per 10 seconds → 100 per second
- Max concurrency increased (October 2025): 4,500 → 10,000 concurrent instances
- State persistence limits increased (2025): 128 KB → 1 MiB per step, 100 MB - 1 GB per instance
- Event payload size increased (2025): 128 KB → 1 MiB
- CPU time configurable via `wrangler.jsonc`: `{ "limits": { "cpu_ms": 300000 } }` (5 min max)

---

## Pricing

**Requires Workers Paid plan** ($5/month)

**Workflow Executions:**
- First 10,000,000 step executions/month: **FREE**
- After that: **$0.30 per million step executions**

**What counts as a step execution:**
- Each `step.do()` call
- Each retry of a step
- `step.sleep()`, `step.sleepUntil()`, `step.waitForEvent()` do NOT count

**Cost examples:**
- Workflow with 5 steps, no retries: **5 step executions**
- Workflow with 3 steps, 1 step retries 2 times: **5 step executions** (3 + 2)
- 10M simple workflows/month (5 steps each): ((50M - 10M) / 1M) × $0.30 = **$12/month**


## Troubleshooting

### Issue: "Cannot perform I/O on behalf of a different request"

**Cause:** Trying to use I/O objects created in one request context from another request handler

**Solution:** Always perform I/O within `step.do()` callbacks

```typescript
// ❌ Bad - I/O outside step
const response = await fetch('https://api.example.com/data');
const data = await response.json();

await step.do('use data', async () => {
  // Using data from outside step's I/O context
  return data;  // This will fail!
});

// ✅ Good - I/O inside step
const data = await step.do('fetch data', async () => {
  const response = await fetch('https://api.example.com/data');
  return await response.json();  // ✅ Correct
});
```

---

### Issue: NonRetryableError behaves differently in dev vs production

**Known Issue:** Throwing NonRetryableError with empty message in dev mode causes retries, but works correctly in production

**Workaround:** Always provide a message to NonRetryableError

```typescript
// ❌ May retry in dev
throw new NonRetryableError();

// ✅ Works consistently
throw new NonRetryableError('User not found');
```

**Source:** [workers-sdk#10113](https://github.com/cloudflare/workers-sdk/issues/10113)

---

## Vitest Testing (GA April 2025)

Workflows support full testing integration via `cloudflare:test` module.

### Setup

```bash
npm install -D vitest@latest @cloudflare/vitest-pool-workers@latest
```

**vitest.config.ts:**
```typescript
import { defineWorkersConfig } from '@cloudflare/vitest-pool-workers/config';
export default defineWorkersConfig({ test: { poolOptions: { workers: { miniflare: { bindings: { MY_WORKFLOW: { scriptName: 'workflow' } } } } } } });
```

### Introspection API

```typescript
import { env, introspectWorkflowInstance } from 'cloudflare:test';

it('should complete workflow', async () => {
  const instance = await introspectWorkflowInstance(env.MY_WORKFLOW, 'test-123');

  try {
    await instance.modify(async (m) => {
      await m.disableSleeps();  // Skip all sleeps
      await m.mockStepResult({ name: 'fetch data' }, { users: [{ id: 1 }] });  // Mock step result
      await m.mockEvent({ type: 'approval', payload: { approved: true } });  // Send mock event
      await m.mockStepError({ name: 'call API' }, new Error('Network timeout'), 1);  // Force error once
    });

    await env.MY_WORKFLOW.create({ id: 'test-123' });
    await expect(instance.waitForStatus('complete')).resolves.not.toThrow();
  } finally {
    await instance.dispose();  // Cleanup
  }
});
```

### Test Modifiers

- `disableSleeps(steps?)` - Skip sleeps instantly
- `mockStepResult(step, result)` - Mock step.do() result
- `mockStepError(step, error, times?)` - Force step.do() to throw
- `mockEvent(event)` - Send mock event to step.waitForEvent()
- `forceStepTimeout(step, times?)` - Force step.do() timeout
- `forceEventTimeout(step)` - Force step.waitForEvent() timeout

**Official Docs**: https://developers.cloudflare.com/workers/testing/vitest-integration/

---

## Related Documentation

- **Cloudflare Workflows Docs**: https://developers.cloudflare.com/workflows/
- **Get Started Guide**: https://developers.cloudflare.com/workflows/get-started/guide/
- **Workers API**: https://developers.cloudflare.com/workflows/build/workers-api/
- **Vitest Testing**: https://developers.cloudflare.com/workers/testing/vitest-integration/
- **Sleeping and Retrying**: https://developers.cloudflare.com/workflows/build/sleeping-and-retrying/
- **Events and Parameters**: https://developers.cloudflare.com/workflows/build/events-and-parameters/
- **Limits**: https://developers.cloudflare.com/workflows/reference/limits/
- **Pricing**: https://developers.cloudflare.com/workflows/platform/pricing/
- **Changelog**: https://developers.cloudflare.com/workflows/reference/changelog/
- **MCP Tool**: Use `mcp__cloudflare-docs__search_cloudflare_documentation` for latest docs

---

**Last Updated**: 2025-11-25
**Version**: 1.0.0
**Maintainer**: Jeremy Dawes | jeremy@jezweb.net
