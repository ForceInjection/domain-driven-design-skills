---
name: stripe-api-integration
description: Use when working with Stripe API fundamentals, webhooks, authentication, error handling, CLI, or testing. Invoke for webhook implementation, signature verification, API error patterns, idempotency, rate limiting, Stripe CLI usage, or test mode setup.
allowed-tools: Read, Grep, Glob
---

# Stripe API Integration Expert

## Purpose

Expert knowledge of Stripe API fundamentals and integration patterns. Covers webhooks, authentication, error handling, API best practices, Stripe CLI, testing strategies, and common integration patterns.

## When to Use

Invoke this skill when:
- Setting up webhook endpoints
- Verifying webhook signatures
- Handling API errors
- Implementing idempotency
- Using the Stripe CLI
- Testing Stripe integrations
- Managing API keys
- Handling rate limits
- Debugging API calls
- Understanding API versioning

## Documentation Available

**Location**: `/Users/zach/Documents/cc-skills/docs/stripe/`

**Coverage** (~920 files in api/ + webhooks/ + cli/):
- **API Reference** (~800 files):
  - All Stripe objects and methods
  - Request parameters
  - Response formats
  - Error codes

- **Webhooks** (~60 files):
  - Event types
  - Signature verification
  - Event handling patterns
  - Webhook endpoints

- **CLI** (~40 files):
  - Local webhook testing
  - Event triggering
  - API testing
  - Log streaming

- **Testing** (~20 files):
  - Test mode
  - Test cards and data
  - Test clocks
  - Mock requests

## Related Skills

- **stripe-payments**: For payment processing
- **stripe-billing-subscriptions**: For subscription events
- **stripe-connect**: For Connect webhooks

## Best Practices

- **Verify webhook signatures** - Always verify to prevent tampering
- **Handle webhooks idempotently** - Events may be delivered multiple times
- **Use API versioning** - Pin to specific version for stability
- **Implement proper error handling** - Handle all error types
- **Use idempotency keys** - Prevent duplicate operations
- **Monitor webhook endpoints** - Ensure they're responding quickly (<5s)
- **Test with Stripe CLI** - Local webhook testing
- **Use test mode extensively** - Before going live
- **Log API requests** - For debugging and auditing
- **Handle rate limits** - Implement backoff strategies

## Examples

### Example 1: Webhook Implementation & Signature Verification

**Question**: "How do I properly implement webhooks?"

**Response**:
```typescript
import { buffer } from 'micro';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

// Disable body parsing (Next.js)
export const config = {
  api: {
    bodyParser: false,
  },
};

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Get raw body
  const buf = await buffer(req);
  const sig = req.headers['stripe-signature'];

  let event: Stripe.Event;

  try {
    // Verify webhook signature
    event = stripe.webhooks.constructEvent(buf, sig!, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle event idempotently
  const eventId = event.id;
  const existingEvent = await db.webhookEvents.findUnique({
    where: { id: eventId },
  });

  if (existingEvent) {
    console.log('Event already processed:', eventId);
    return res.json({ received: true });
  }

  try {
    // Process event
    await handleEvent(event);

    // Store event to prevent reprocessing
    await db.webhookEvents.create({
      data: {
        id: eventId,
        type: event.type,
        processedAt: new Date(),
      },
    });

    res.json({ received: true });
  } catch (err) {
    console.error('Error handling webhook:', err);
    res.status(500).json({ error: 'Webhook handler failed' });
  }
}

async function handleEvent(event: Stripe.Event) {
  console.log('Processing event:', event.type);

  switch (event.type) {
    // Payment events
    case 'payment_intent.succeeded':
      await handlePaymentSuccess(event.data.object as Stripe.PaymentIntent);
      break;

    case 'payment_intent.payment_failed':
      await handlePaymentFailure(event.data.object as Stripe.PaymentIntent);
      break;

    // Subscription events
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object as Stripe.Subscription);
      break;

    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
      break;

    case 'customer.subscription.deleted':
      await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
      break;

    // Invoice events
    case 'invoice.paid':
      await handleInvoicePaid(event.data.object as Stripe.Invoice);
      break;

    case 'invoice.payment_failed':
      await handleInvoicePaymentFailed(event.data.object as Stripe.Invoice);
      break;

    // Dispute events
    case 'charge.dispute.created':
      await handleDisputeCreated(event.data.object as Stripe.Dispute);
      break;

    // Customer events
    case 'customer.created':
      await handleCustomerCreated(event.data.object as Stripe.Customer);
      break;

    case 'customer.deleted':
      await handleCustomerDeleted(event.data.object as Stripe.Customer);
      break;

    default:
      console.log(`Unhandled event type: ${event.type}`);
  }
}

async function handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
  console.log('Payment succeeded:', paymentIntent.id);

  // Update order
  await db.orders.update({
    where: { paymentIntentId: paymentIntent.id },
    data: {
      status: 'paid',
      paidAt: new Date(),
    },
  });

  // Send confirmation email
  await sendEmail({
    to: paymentIntent.receipt_email!,
    subject: 'Payment Confirmed',
    template: 'payment-success',
    data: { paymentIntent },
  });
}
```

**Get Webhook Secret**:
```bash
# From Stripe Dashboard → Developers → Webhooks
# Or using Stripe CLI:
stripe listen --print-secret
```

**References**:
- See: `docs/stripe/webhooks/`

### Example 2: Error Handling

**Question**: "How do I handle Stripe API errors?"

**Response**:
```typescript
import Stripe from 'stripe';

async function handleStripeOperation() {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 1000,
      currency: 'usd',
    });

    return { success: true, paymentIntent };
  } catch (error) {
    if (error instanceof Stripe.errors.StripeError) {
      // Handle specific Stripe errors
      switch (error.type) {
        case 'StripeCardError':
          // Card was declined
          console.error('Card error:', error.message);
          return {
            success: false,
            error: 'Your card was declined',
            code: error.code,
          };

        case 'StripeRateLimitError':
          // Too many requests
          console.error('Rate limit exceeded');
          return {
            success: false,
            error: 'Too many requests, please try again later',
          };

        case 'StripeInvalidRequestError':
          // Invalid parameters
          console.error('Invalid request:', error.message);
          return {
            success: false,
            error: 'Invalid request',
            param: error.param,
          };

        case 'StripeAPIError':
          // Stripe API error
          console.error('Stripe API error:', error.message);
          return {
            success: false,
            error: 'Payment processing error, please try again',
          };

        case 'StripeConnectionError':
          // Network error
          console.error('Network error:', error.message);
          return {
            success: false,
            error: 'Connection error, please try again',
          };

        case 'StripeAuthenticationError':
          // Authentication error (invalid API key)
          console.error('Authentication error:', error.message);
          return {
            success: false,
            error: 'Payment system error',
          };

        default:
          console.error('Unknown Stripe error:', error);
          return {
            success: false,
            error: 'An unexpected error occurred',
          };
      }
    }

    // Non-Stripe error
    console.error('Unknown error:', error);
    return {
      success: false,
      error: 'An unexpected error occurred',
    };
  }
}

// Retry logic with exponential backoff
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  let lastError: Error;

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;

      if (error instanceof Stripe.errors.StripeError) {
        // Don't retry client errors
        if (
          error.type === 'StripeCardError' ||
          error.type === 'StripeInvalidRequestError'
        ) {
          throw error;
        }
      }

      // Exponential backoff
      const delay = Math.pow(2, i) * 1000;
      console.log(`Retry ${i + 1}/${maxRetries} after ${delay}ms`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  throw lastError!;
}

// Usage
const result = await retryWithBackoff(() =>
  stripe.paymentIntents.create({
    amount: 1000,
    currency: 'usd',
  })
);
```

**Common Error Codes**:
- `card_declined` - Card was declined
- `insufficient_funds` - Not enough funds
- `expired_card` - Card expired
- `incorrect_cvc` - Wrong CVC
- `processing_error` - Processing error
- `rate_limit` - Too many requests

**References**:
- See: `docs/stripe/api/errors/`

### Example 3: Idempotency

**Question**: "How do I prevent duplicate charges?"

**Response**:
```typescript
// Use idempotency keys for POST requests
async function createPaymentWithIdempotency(orderId: string, amount: number) {
  const idempotencyKey = `order_${orderId}`; // Unique per order

  try {
    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount: amount * 100,
        currency: 'usd',
        metadata: { orderId },
      },
      {
        idempotencyKey, // Prevents duplicate charges
      }
    );

    return paymentIntent;
  } catch (error) {
    if (
      error instanceof Stripe.errors.StripeError &&
      error.type === 'StripeIdempotencyError'
    ) {
      console.error('Idempotency key already used with different parameters');
      // Use new key or retrieve original request
    }

    throw error;
  }
}

// Generate unique idempotency key
function generateIdempotencyKey(
  operation: string,
  resourceId: string,
  timestamp?: number
): string {
  const ts = timestamp || Date.now();
  return `${operation}_${resourceId}_${ts}`;
}

// Example: Idempotent subscription creation
async function createSubscriptionIdempotent(
  customerId: string,
  priceId: string
) {
  const idempotencyKey = generateIdempotencyKey(
    'create_subscription',
    customerId
  );

  const subscription = await stripe.subscriptions.create(
    {
      customer: customerId,
      items: [{ price: priceId }],
    },
    { idempotencyKey }
  );

  return subscription;
}

// Store idempotency keys for tracking
async function createPaymentWithTracking(orderId: string, amount: number) {
  const idempotencyKey = `order_${orderId}`;

  // Check if already processed
  const existingPayment = await db.payments.findUnique({
    where: { idempotencyKey },
  });

  if (existingPayment) {
    console.log('Payment already processed');
    return existingPayment;
  }

  const paymentIntent = await stripe.paymentIntents.create(
    {
      amount: amount * 100,
      currency: 'usd',
      metadata: { orderId },
    },
    { idempotencyKey }
  );

  // Store payment with idempotency key
  await db.payments.create({
    data: {
      id: paymentIntent.id,
      orderId,
      amount,
      idempotencyKey,
      createdAt: new Date(),
    },
  });

  return paymentIntent;
}
```

**Idempotency Key Rules**:
- Must be unique per operation
- Valid for 24 hours
- Only for POST requests
- Returns same result for duplicate requests

**References**:
- See: `docs/stripe/api/idempotent_requests/`

### Example 4: Stripe CLI Usage

**Question**: "How do I use the Stripe CLI?"

**Response**:
```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe
# Or download from https://stripe.com/docs/stripe-cli

# Login to Stripe
stripe login

# Listen to webhooks (local testing)
stripe listen --forward-to localhost:3000/api/webhooks

# Get webhook signing secret
stripe listen --print-secret

# Trigger test events
stripe trigger payment_intent.succeeded
stripe trigger customer.subscription.created
stripe trigger invoice.payment_failed

# Test specific webhook endpoint
stripe listen --forward-to localhost:3000/api/webhooks \
  --events payment_intent.succeeded,customer.subscription.updated

# View logs
stripe logs tail

# Filter logs
stripe logs tail --filter-type=payment_intent

# Make API requests
stripe payment_intents create \
  --amount=1000 \
  --currency=usd

stripe customers list --limit=10

stripe subscriptions retrieve sub_xxxxx

# Test webhooks with specific event
stripe trigger payment_intent.succeeded \
  --add payment_intent:amount=5000

# Forward webhooks to different endpoints by event type
stripe listen \
  --forward-to localhost:3000/api/webhooks/payments \
  --events payment_intent.succeeded,charge.succeeded \
  --forward-to localhost:3000/api/webhooks/subscriptions \
  --events customer.subscription.created,customer.subscription.updated

# Use with Docker
docker run --rm -it stripe/stripe-cli:latest \
  listen --api-key sk_test_xxx \
  --forward-to host.docker.internal:3000/api/webhooks
```

**References**:
- See: `docs/stripe/cli/`

### Example 5: Testing Strategies

**Question**: "How do I test my Stripe integration?"

**Response**:
```typescript
// Test mode configuration
const stripe = new Stripe(
  process.env.NODE_ENV === 'production'
    ? process.env.STRIPE_SECRET_KEY!
    : process.env.STRIPE_TEST_SECRET_KEY!
);

// Test card numbers
const TEST_CARDS = {
  success: '4242424242424242',
  decline: '4000000000000002',
  insufficientFunds: '4000000000009995',
  requires3DS: '4000002500003155',
  requiresAuth: '4000002760003184',
};

// Test with specific scenarios
async function testPaymentScenarios() {
  // Successful payment
  const successPayment = await stripe.paymentIntents.create({
    amount: 1000,
    currency: 'usd',
    payment_method_data: {
      type: 'card',
      card: { token: 'tok_visa' }, // Test token
    },
    confirm: true,
  });

  console.log('Success:', successPayment.status);

  // Test declined card
  try {
    await stripe.paymentIntents.create({
      amount: 1000,
      currency: 'usd',
      payment_method_data: {
        type: 'card',
        card: { token: 'tok_chargeDeclined' },
      },
      confirm: true,
    });
  } catch (error) {
    console.log('Declined:', error.code);
  }
}

// Test with Test Clocks (for time-dependent features)
async function testWithTestClock() {
  // Create test clock
  const testClock = await stripe.testHelpers.testClocks.create({
    frozen_time: Math.floor(Date.now() / 1000), // Current time
    name: 'Trial expiration test',
  });

  // Create customer with test clock
  const customer = await stripe.customers.create({
    email: 'test@example.com',
    test_clock: testClock.id,
  });

  // Create subscription with trial
  const subscription = await stripe.subscriptions.create({
    customer: customer.id,
    items: [{ price: 'price_xxx' }],
    trial_period_days: 14,
  });

  // Advance time to end of trial
  await stripe.testHelpers.testClocks.advance(testClock.id, {
    frozen_time: Math.floor(Date.now() / 1000) + 14 * 24 * 60 * 60,
  });

  // Check subscription status
  const updatedSubscription = await stripe.subscriptions.retrieve(
    subscription.id
  );
  console.log('Status after trial:', updatedSubscription.status);

  // Clean up
  await stripe.testHelpers.testClocks.del(testClock.id);
}

// Mock Stripe for unit tests
import { jest } from '@jest/globals';

jest.mock('stripe', () => {
  return jest.fn().mockImplementation(() => ({
    paymentIntents: {
      create: jest.fn().mockResolvedValue({
        id: 'pi_test_123',
        status: 'succeeded',
        amount: 1000,
        currency: 'usd',
      }),
      retrieve: jest.fn().mockResolvedValue({
        id: 'pi_test_123',
        status: 'succeeded',
      }),
    },
    customers: {
      create: jest.fn().mockResolvedValue({
        id: 'cus_test_123',
        email: 'test@example.com',
      }),
    },
  }));
});

// Integration test with real API (test mode)
describe('Stripe Integration', () => {
  it('should create a payment intent', async () => {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 1000,
      currency: 'usd',
    });

    expect(paymentIntent.id).toMatch(/^pi_/);
    expect(paymentIntent.amount).toBe(1000);
  });

  it('should handle declined card', async () => {
    await expect(
      stripe.paymentIntents.create({
        amount: 1000,
        currency: 'usd',
        payment_method_data: {
          type: 'card',
          card: { token: 'tok_chargeDeclined' },
        },
        confirm: true,
      })
    ).rejects.toThrow('Your card was declined');
  });
});
```

**Test Card Numbers**:
- `4242424242424242` - Success
- `4000000000000002` - Declined
- `4000000000009995` - Insufficient funds
- `4000002500003155` - Requires 3D Secure
- `4000000000000341` - Attaches and charges

**References**:
- See: `docs/stripe/testing/`

## Common Patterns

### Pagination
```typescript
async function listAllCustomers() {
  let customers: Stripe.Customer[] = [];
  let hasMore = true;
  let startingAfter: string | undefined;

  while (hasMore) {
    const page = await stripe.customers.list({
      limit: 100,
      starting_after: startingAfter,
    });

    customers = customers.concat(page.data);
    hasMore = page.has_more;
    startingAfter = page.data[page.data.length - 1]?.id;
  }

  return customers;
}
```

### Expand Related Objects
```typescript
const invoice = await stripe.invoices.retrieve('in_xxx', {
  expand: ['customer', 'subscription', 'payment_intent'],
});

// Access expanded data
console.log(invoice.customer.email);
console.log(invoice.subscription.items);
```

### Rate Limit Handling
```typescript
async function handleRateLimit<T>(fn: () => Promise<T>): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    if (
      error instanceof Stripe.errors.StripeError &&
      error.type === 'StripeRateLimitError'
    ) {
      // Wait and retry
      await new Promise(resolve => setTimeout(resolve, 1000));
      return handleRateLimit(fn);
    }
    throw error;
  }
}
```

## Search Helpers

```bash
# Find API docs
grep -r "API\|endpoint\|request" /Users/zach/Documents/cc-skills/docs/stripe/api/

# Find webhook docs
grep -r "webhook\|event\|signature" /Users/zach/Documents/cc-skills/docs/stripe/webhooks/

# Find CLI docs
grep -r "CLI\|stripe listen\|trigger" /Users/zach/Documents/cc-skills/docs/stripe/cli/

# List API reference files
ls /Users/zach/Documents/cc-skills/docs/stripe/api/
```

## Common Errors

- **Webhook signature verification failed**: Wrong secret or body modified
  - Solution: Use raw body and correct webhook secret

- **Idempotency key mismatch**: Same key with different parameters
  - Solution: Use unique key per operation or retrieve original

- **Rate limit exceeded**: Too many requests
  - Solution: Implement exponential backoff

- **API version mismatch**: Using features from newer version
  - Solution: Pin API version or upgrade

## API Best Practices

1. **Always verify webhooks** - Security critical
2. **Handle idempotency** - Prevent duplicates
3. **Use expand sparingly** - Only when needed
4. **Implement retry logic** - For transient errors
5. **Log API calls** - For debugging
6. **Use test mode** - Extensively before production
7. **Pin API version** - Avoid breaking changes
8. **Monitor webhook health** - Response time and success rate
9. **Handle all error types** - Graceful degradation
10. **Use metadata** - Track custom data

## Notes

- Documentation covers latest Stripe API (2023+)
- Webhooks are the reliable way to track events
- Always verify webhook signatures
- Idempotency keys prevent duplicate operations
- Test mode has same features as live mode
- Stripe CLI essential for local development
- File paths reference local documentation cache
- For latest updates, check https://stripe.com/docs/api
