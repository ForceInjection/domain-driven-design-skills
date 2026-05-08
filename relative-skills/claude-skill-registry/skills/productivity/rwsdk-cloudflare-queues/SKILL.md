---
name: rwsdk-cloudflare-queues
description: Use when implementing background tasks, async processing, or offloading slow operations in rwsdk/Cloudflare Workers - covers queue setup, sending messages (direct/R2/KV patterns), consuming message batches, handling multiple queues, and message type routing
---

# rwsdk Cloudflare Queues

## Overview

Cloudflare Queues enable background task processing in rwsdk without blocking user requests. Send messages to a queue from your main worker, and a consumer worker processes them asynchronously. Perfect for emails, payments, AI processing, or any slow operation that shouldn't delay user responses.

## When to Use

Use when:

- Operations take too long to block HTTP responses (>1-2 seconds)
- Sending emails, processing payments, generating reports
- AI/ML inference, image processing, video encoding
- Batch operations that can be deferred
- Need reliable async task execution with retries

Don't use when:

- Immediate results required for user experience
- Simple operations (<100ms) that can run inline
- Real-time bidirectional communication needed (use WebSockets/Durable Objects)

## Quick Setup (3 Steps)

### 1. Create Queue

```bash
npx wrangler queues create my-queue-name
```

**Naming rules**: Lowercase letters, numbers, hyphens only. Max 63 chars. Cannot start/end with hyphen.

Valid: `my-queue`, `email-queue-v2`, `payment-processor`
Invalid: `My_Queue`, `queue_name`, `-my-queue`, `PAYMENTS`

### 2. Configure wrangler.jsonc

```json
{
  "queues": {
    "producers": [
      {
        "binding": "QUEUE",
        "queue": "my-queue-name"
      }
    ],
    "consumers": [
      {
        "queue": "my-queue-name",
        "max_batch_size": 10,
        "max_batch_timeout": 5
      }
    ]
  }
}
```

**After updating**: Run `pnpm generate` to update type definitions.

**Consumer settings**:

- `max_batch_size`: Max messages per batch (1-100)
- `max_batch_timeout`: Max seconds to wait before processing partial batch

### 3. Update Worker Export

Change from single `defineApp` export to object with `fetch` and `queue`:

```typescript
const app = defineApp([
  /* routes */
]);

export default {
  fetch: app.fetch,
  async queue(batch) {
    for (const message of batch.messages) {
      console.log('Processing:', message.body);
      // Handle message
    }
  },
} satisfies ExportedHandler<Env>;
```

## Sending Messages

### Basic Pattern

```typescript
import { env } from 'cloudflare:workers';

export default defineApp([
  route('/checkout', async ({ request }) => {
    const order = await request.json();

    // Send to queue (non-blocking)
    await env.QUEUE.send({
      orderId: order.id,
      userId: order.userId,
      amount: order.total,
    });

    return new Response('Order placed!');
  }),
]);
```

**Message is queued immediately**, user gets fast response.

### Batch Sending

```typescript
// Send multiple messages at once
await env.QUEUE.sendBatch([
  { body: { userId: 1, action: 'email' } },
  { body: { userId: 2, action: 'email' } },
  { body: { userId: 3, action: 'email' } },
]);
```

## Message Payload Strategies

| Strategy         | Size Limit | Best For            | Pros/Cons                                               |
| ---------------- | ---------- | ------------------- | ------------------------------------------------------- |
| **Direct body**  | 128KB      | Small payloads      | ✅ Simple, fast<br>❌ 128KB hard limit                  |
| **R2 reference** | Unlimited  | Large files, videos | ✅ Large data, persistent<br>❌ Requires R2 integration |
| **KV reference** | ~25MB      | Medium payloads     | ✅ Fast access, TTL support<br>❌ Eventual consistency  |

### Direct Body (Default)

```typescript
await env.QUEUE.send({
  email: '[email protected]',
  subject: 'Welcome!',
  body: 'Thanks for signing up',
});
```

**When to use**: Payload < 128KB, simple structured data

### R2 Reference (Large Data)

```typescript
// Producer: Upload to R2 first
const key = `messages/${crypto.randomUUID()}.json`;
await env.R2_BUCKET.put(key, JSON.stringify(largeData));

await env.QUEUE.send({
  type: 'R2_REFERENCE',
  r2Key: key,
});

// Consumer: Fetch from R2
async queue(batch) {
  for (const message of batch.messages) {
    if (message.body.type === 'R2_REFERENCE') {
      const data = await env.R2_BUCKET.get(message.body.r2Key);
      const payload = await data.json();
      // Process large payload
    }
  }
}
```

**When to use**: Files, videos, large JSON blobs, need persistence

### KV Reference (Medium Data)

```typescript
// Producer: Store in KV
const key = `queue:msg:${crypto.randomUUID()}`;
await env.KV.put(key, JSON.stringify(data), {
  expirationTtl: 600 // Auto-cleanup after 10 minutes
});

await env.QUEUE.send({
  type: 'KV_REFERENCE',
  kvKey: key,
});

// Consumer: Fetch from KV
async queue(batch) {
  for (const message of batch.messages) {
    if (message.body.type === 'KV_REFERENCE') {
      const dataStr = await env.KV.get(message.body.kvKey);
      const payload = JSON.parse(dataStr);
      // Process payload
    }
  }
}
```

**When to use**: Short-lived data, automatic expiration desired
**Warning**: KV has eventual consistency - small delay before reads reflect writes

## Consuming Messages

### Basic Consumer

```typescript
export default {
  fetch: app.fetch,
  async queue(batch) {
    for (const message of batch.messages) {
      const { userId, action } = message.body;

      // Process message
      await processTask(userId, action);

      // Message automatically ACKed if no error thrown
    }
  },
} satisfies ExportedHandler<Env>;
```

**Automatic behavior**:

- Messages ACKed (deleted) if function completes without error
- Messages retried if function throws error
- Batch processed as a unit

### Error Handling

```typescript
async queue(batch) {
  for (const message of batch.messages) {
    try {
      await processMessage(message.body);
    } catch (error) {
      console.error('Failed to process:', message.id, error);
      // Message will be retried automatically
      // Consider moving to DLQ after N retries
    }
  }
}
```

**Retry behavior**: Cloudflare automatically retries failed messages with exponential backoff.

## Multiple Queues Pattern

**Best practice**: One queue per message type for clear separation.

### Setup Multiple Queues

```json
{
  "queues": {
    "producers": [
      { "binding": "EMAIL_QUEUE", "queue": "email-queue" },
      { "binding": "PAYMENT_QUEUE", "queue": "payment-queue" }
    ],
    "consumers": [
      { "queue": "email-queue", "max_batch_size": 10 },
      { "queue": "payment-queue", "max_batch_size": 5 }
    ]
  }
}
```

### Sending to Different Queues

```typescript
route('/register', async () => {
  await env.EMAIL_QUEUE.send({ type: 'welcome', email: '...' });
  return new Response('Registered!');
});

route('/checkout', async () => {
  await env.PAYMENT_QUEUE.send({ orderId: '...', amount: 100 });
  return new Response('Processing payment...');
});
```

### Consuming Different Queues

```typescript
async queue(batch) {
  if (batch.queue === 'email-queue') {
    await handleEmailBatch(batch.messages);
  } else if (batch.queue === 'payment-queue') {
    await handlePaymentBatch(batch.messages);
  }
}
```

## Message Type Routing (Same Queue)

If using single queue for multiple message types (not recommended, but possible):

```typescript
// Sending with type field
await env.QUEUE.send({
  type: 'PAYMENT',
  userId: 123,
  amount: 100,
});

await env.QUEUE.send({
  type: 'EMAIL',
  to: '[email protected]',
  subject: 'Hello',
});

// Consuming with type routing
async queue(batch) {
  for (const message of batch.messages) {
    const { type, ...data } = message.body;

    switch (type) {
      case 'PAYMENT':
        await processPayment(data);
        break;
      case 'EMAIL':
        await sendEmail(data);
        break;
      default:
        console.warn('Unknown message type:', type);
    }
  }
}
```

## Common Mistakes

| Mistake                                     | Fix                                              |
| ------------------------------------------- | ------------------------------------------------ |
| **Queue name with uppercase/underscores**   | Use lowercase letters, numbers, hyphens only     |
| **Forgetting `pnpm generate` after config** | Always run after updating wrangler.jsonc         |
| **Blocking operations in producer**         | Send message immediately, don't await processing |
| **Large payload directly in message**       | Use R2/KV reference pattern for >128KB           |
| **Not handling errors in consumer**         | Wrap message processing in try-catch             |
| **Returning response from queue handler**   | Queue handlers don't return responses            |
| **Missing ExportedHandler type**            | Use `satisfies ExportedHandler<Env>`             |
| **Mixing message types without routing**    | Use type field or separate queues                |
| **KV without expiration for queue data**    | Set expirationTtl to prevent unbounded growth    |

## Real-World Patterns

### Email Processing

```typescript
// Producer
route('/register', async ({ request }) => {
  const user = await request.json();
  await db.insertInto('users').values(user).execute();

  await env.EMAIL_QUEUE.send({
    to: user.email,
    template: 'welcome',
    data: { name: user.name },
  });

  return new Response('Success!');
});

// Consumer
async queue(batch) {
  for (const message of batch.messages) {
    const { to, template, data } = message.body;
    await sendEmail(to, renderTemplate(template, data));
  }
}
```

### Image Processing

```typescript
// Producer: Upload to R2, queue processing
route('/upload', async ({ request }) => {
  const formData = await request.formData();
  const image = formData.get('image');

  const key = `images/${crypto.randomUUID()}.jpg`;
  await env.R2_BUCKET.put(key, image);

  await env.IMAGE_QUEUE.send({
    r2Key: key,
    operations: ['resize', 'thumbnail', 'watermark'],
  });

  return new Response('Uploaded!');
});

// Consumer: Process images
async queue(batch) {
  for (const message of batch.messages) {
    const { r2Key, operations } = message.body;
    const image = await env.R2_BUCKET.get(r2Key);

    for (const op of operations) {
      await processImage(image, op);
    }
  }
}
```

### AI Processing

```typescript
// Producer
route('/analyze', async ({ request }) => {
  const { text } = await request.json();

  const jobId = crypto.randomUUID();
  await env.KV.put(`job:${jobId}`, JSON.stringify({ status: 'queued' }));

  await env.AI_QUEUE.send({
    jobId,
    text,
    model: 'gpt-4',
  });

  return new Response(JSON.stringify({ jobId }));
});

// Consumer
async queue(batch) {
  for (const message of batch.messages) {
    const { jobId, text, model } = message.body;

    const result = await runAIModel(model, text);

    await env.KV.put(`job:${jobId}`, JSON.stringify({
      status: 'complete',
      result,
    }));
  }
}
```

## Batch Processing Tips

- **max_batch_size**: Higher = more efficient, but longer processing time
- **max_batch_timeout**: Lower = faster response, but smaller batches
- **Trade-off**: Latency vs. throughput

**Recommended settings**:

- High volume, latency-tolerant: `max_batch_size: 100, max_batch_timeout: 30`
- Low volume, quick processing: `max_batch_size: 10, max_batch_timeout: 5`
- Critical tasks: `max_batch_size: 1, max_batch_timeout: 1`

## Queue Limits

- **Message size**: 128KB per message body
- **Batch size**: 1-100 messages
- **Batch timeout**: 0-60 seconds
- **Queue throughput**: Depends on plan (check Cloudflare docs)

## Quick Reference

| Task                 | Code                                                             |
| -------------------- | ---------------------------------------------------------------- |
| **Send message**     | `await env.QUEUE.send({ data })`                                 |
| **Send batch**       | `await env.QUEUE.sendBatch([{ body: data1 }, { body: data2 }])`  |
| **Consume messages** | `async queue(batch) { for (const msg of batch.messages) {...} }` |
| **Check queue name** | `if (batch.queue === 'my-queue')`                                |
| **Route by type**    | `switch (message.body.type) { case 'PAYMENT': ... }`             |
| **R2 reference**     | `await env.R2.put(key, data); await queue.send({ r2Key: key })`  |
| **KV reference**     | `await env.KV.put(key, data, { expirationTtl: 600 })`            |
| **Error handling**   | `try { await process() } catch (e) { /* auto-retry */ }`         |

## Performance Considerations

- **Queue latency**: Messages processed within seconds, not instant
- **Cold starts**: Consumer workers may have cold start delay
- **Retries**: Failed messages automatically retried with backoff
- **Ordering**: Messages processed in approximate order, not guaranteed
- **At-least-once delivery**: Messages may be delivered multiple times (handle idempotently)

## Best Practices

1. **One queue per message type** for clarity and independent scaling
2. **Add type field** if sharing queues to enable routing
3. **Use R2 for large data** (>128KB) with key references
4. **Set KV expiration** for temporary queue data
5. **Handle errors gracefully** - log and let Cloudflare retry
6. **Make consumers idempotent** - same message may arrive twice
7. **Monitor queue depth** to catch processing issues early
8. **Test locally** with `wrangler dev` and manual queue sends
