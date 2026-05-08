---
name: rwsdk-cron-triggers
description: Schedule recurring background tasks in rwsdk/Cloudflare Workers - cron syntax, setup, local testing, and patterns for cleanup, metrics, billing, and maintenance
---

# rwsdk Cron Triggers

Schedule recurring background tasks using standard cron syntax. Tasks run automatically in production. Use for cleanup, metrics, billing, backups, and maintenance.

## Quick Setup

### 1. Configure wrangler.jsonc

```json
{
  "triggers": {
    "crons": [
      "0 * * * *", // Every hour
      "0 21 * * *" // Daily at 9 PM UTC
    ]
  }
}
```

Run `pnpm generate` after changes.

### 2. Add Scheduled Handler

```typescript
export default {
  fetch: app.fetch,
  async scheduled(controller: ScheduledController) {
    try {
      switch (controller.cron) {
        case '0 * * * *': {
          await cleanupExpiredSessions();
          console.log('✅ Hourly cleanup complete');
          break;
        }
        case '0 21 * * *': {
          await processBilling();
          console.log('✅ Daily billing complete');
          break;
        }
        default: {
          console.warn(`Unhandled cron: ${controller.cron}`);
        }
      }
    } catch (error) {
      console.error('Cron error:', error);
    }
  },
} satisfies ExportedHandler<Env>;
```

**Each case must match a cron in wrangler.jsonc.**

## Cron Syntax

```
┌─ minute (0-59)
│ ┌─ hour (0-23)
│ │ ┌─ day (1-31)
│ │ │ ┌─ month (1-12)
│ │ │ │ ┌─ weekday (0-6, Sun-Sat)
* * * * *
```

**Common patterns:**

- `* * * * *` - Every minute (testing only)
- `*/5 * * * *` - Every 5 minutes
- `0 * * * *` - Every hour
- `0 0 * * *` - Daily at midnight UTC
- `0 9 * * 1-5` - Weekdays at 9 AM UTC
- `0 0 * * 0` - Weekly (Sundays)
- `0 0 1 * *` - Monthly (1st day)

**Operators:**

- `*` - Every value
- `*/n` - Every n units
- `,` - Multiple values: `0 9,17 * * *` (9 AM and 5 PM)
- `-` - Range: `0 9-17 * * *` (9 AM through 5 PM)

## Testing Locally

Crons only fire automatically in production. Test locally with curl.

**Basic test** (find PORT from `pnpm dev` output):

```bash
curl "http://localhost:PORT/cdn-cgi/handler/scheduled?cron=0+*+*+*+*"
```

**With custom timestamp** (for time-dependent logic):

```bash
# Test as if running Jan 1, 2025 midnight UTC
curl "http://localhost:PORT/cdn-cgi/handler/scheduled?cron=0+0+1+*+*&time=1735689600"
```

**Generate timestamps:**

```bash
date +%s  # Current time
date -d "2025-01-15 12:00:00 UTC" +%s  # Specific date
```

**Test script:**

```bash
#!/bin/bash
PORT=5173  # Your dev server port

curl "http://localhost:$PORT/cdn-cgi/handler/scheduled?cron=0+*+*+*+*"
curl "http://localhost:$PORT/cdn-cgi/handler/scheduled?cron=0+21+*+*+*"
```

## Example Patterns

**Session cleanup (hourly):**

```typescript
"crons": ["0 * * * *"]

case "0 * * * *": {
  const result = await db
    .deleteFrom("sessions")
    .where("expiresAt", "<", new Date().toISOString())
    .executeTakeFirst();
  console.log(`🧹 Cleaned ${result.numDeletedRows} sessions`);
  break;
}
```

**Billing (daily at 2 AM):**

```typescript
"crons": ["0 2 * * *"]

case "0 2 * * *": {
  const subs = await db
    .selectFrom("subscriptions")
    .where("nextBillingDate", "<=", today())
    .selectAll()
    .execute();

  // Queue work instead of processing inline
  await env.BILLING_QUEUE.sendBatch(
    subs.map(s => ({ body: { subscriptionId: s.id } }))
  );
  console.log(`💰 Queued ${subs.length} billing tasks`);
  break;
}
```

**Cleanup old files (monthly):**

```typescript
"crons": ["0 3 1 * *"]  // 1st of month, 3 AM UTC

case "0 3 1 * *": {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - 30);

  const { objects } = await env.R2_BUCKET.list({ prefix: "temp/" });

  for (const obj of objects) {
    if (obj.uploaded < cutoff) {
      await env.R2_BUCKET.delete(obj.key);
    }
  }
  console.log(`🗑️ Cleaned up old files`);
  break;
}
```

## Best Practices

**1. Queue heavy work**

```typescript
// ❌ BAD - might timeout
for (const user of await getAllUsers()) {
  await sendEmail(user);
}

// ✅ GOOD - queue work
const users = await getAllUsers();
await env.EMAIL_QUEUE.sendBatch(users.map((u) => ({ body: { userId: u.id } })));
```

**2. Add error handling**

```typescript
try {
  await task();
} catch (error) {
  console.error('Cron failed:', error);
}
```

**3. Document schedules**

```typescript
"crons": [
  "*/5 * * * *",  // Health checks
  "0 * * * *",    // Session cleanup
  "0 2 * * *"     // Billing
]
```

**4. All times are UTC**

```typescript
'0 17 * * *'; // 5 PM UTC = 12 PM EST = 9 AM PST
```

## Common Mistakes

- ❌ Cron not in wrangler.jsonc
- ❌ Forgetting `pnpm generate`
- ❌ Long-running work in handler (use queues)
- ❌ Assuming non-UTC timezone
- ❌ No error handling or logging
- ❌ Missing default case in switch

## Key Limits

- Minimum interval: 1 minute
- Maximum schedules: 3 (free tier)
- Timezone: UTC only
- Execution: At-least-once (make idempotent)
- Timeout: Same as Worker CPU limits

## Workflow

1. Add cron to `wrangler.jsonc`
2. Run `pnpm generate`
3. Add case to `scheduled` handler
4. Test with curl: `curl "http://localhost:PORT/cdn-cgi/handler/scheduled?cron=0+*+*+*+*"`
5. Deploy and monitor in Cloudflare Dashboard

## Architecture

```
Cron Trigger → Check what needs doing → Queue work → Process in queue consumer
```

Keep cron handlers lightweight. Use them to schedule work, not process it.
