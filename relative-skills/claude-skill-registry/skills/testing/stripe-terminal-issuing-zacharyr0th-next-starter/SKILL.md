---
name: stripe-terminal-issuing
description: Use when implementing in-person payments with Terminal or issuing cards with Stripe Issuing. Invoke for POS terminal setup, card reader integration, in-person payment processing, card issuance, authorization controls, or physical/virtual card management.
allowed-tools: Read, Grep, Glob
---

# Stripe Terminal & Issuing Expert

## Purpose

Expert knowledge of Stripe Terminal for in-person payments and Stripe Issuing for card programs. Covers POS reader setup, Terminal SDK integration, card issuance, authorization controls, and card lifecycle management.

## When to Use

Invoke this skill when:
- Implementing in-person payments
- Setting up card readers (Terminal)
- Processing payments at physical locations
- Creating card programs (Issuing)
- Issuing physical or virtual cards
- Setting up spending controls
- Managing card authorizations
- Handling card disputes
- Debugging Terminal or Issuing issues

## Documentation Available

**Location**: `/Users/zach/Documents/cc-skills/docs/stripe/`

**Coverage** (~149 files in terminal/ + issuing/):
- **Terminal** (~75 files):
  - Reader management (Stripe Reader M2, BBPOS, Verifone)
  - Connection tokens
  - Payment collection
  - Refunds and cancellations
  - Terminal SDK (JS, iOS, Android)
  - Reader locations

- **Issuing** (~74 files):
  - Card creation (physical, virtual)
  - Cardholder management
  - Authorization controls
  - Spending limits
  - Authorization holds
  - Card disputes
  - Transaction management

## Related Skills

- **stripe-payments**: For online payment flows
- **stripe-api-integration**: For webhooks and API patterns

## Best Practices

### Terminal
- **Test with simulated readers** - Use test mode readers
- **Handle connection states** - Manage reader connections properly
- **Implement offline mode** - Store payments when offline
- **Update reader software** - Keep firmware updated
- **Handle timeouts** - Set appropriate payment timeouts

### Issuing
- **Set authorization controls** - Prevent fraud
- **Monitor spending** - Track card usage
- **Handle real-time authorizations** - Approve/decline instantly
- **Implement 3DS** - For online card use
- **Manage card lifecycle** - Issue, activate, cancel properly

## Examples

### Example 1: Terminal Reader Setup

**Question**: "How do I set up Stripe Terminal?"

**Response**:
```typescript
import { loadStripeTerminal } from '@stripe/terminal-js';

// Backend: Create connection token
export async function createConnectionToken(req, res) {
  try {
    const terminal = require('stripe')(process.env.STRIPE_SECRET_KEY!).terminal;

    const connectionToken = await terminal.connectionTokens.create();

    res.json({ secret: connectionToken.secret });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Frontend: Initialize Terminal SDK
async function initializeTerminal() {
  const StripeTerminal = await loadStripeTerminal();

  const terminal = StripeTerminal.create({
    onFetchConnectionToken: async () => {
      const response = await fetch('/api/connection-token', {
        method: 'POST',
      }).then(r => r.json());

      return response.secret;
    },
    onUnexpectedReaderDisconnect: () => {
      console.log('Reader disconnected unexpectedly');
    },
  });

  return terminal;
}

// Discover readers
async function discoverReaders(terminal) {
  const discoverResult = await terminal.discoverReaders({
    simulated: false, // Set to true for testing
    location: 'tml_xxxxx', // Optional: filter by location
  });

  if (discoverResult.error) {
    console.error('Discovery failed:', discoverResult.error);
  } else {
    console.log('Discovered readers:', discoverResult.discoveredReaders);
    return discoverResult.discoveredReaders;
  }
}

// Connect to reader
async function connectToReader(terminal, reader) {
  const connectResult = await terminal.connectReader(reader);

  if (connectResult.error) {
    console.error('Connect failed:', connectResult.error);
  } else {
    console.log('Connected to reader:', connectResult.reader);
    return connectResult.reader;
  }
}

// Complete Terminal setup
async function setupTerminal() {
  const terminal = await initializeTerminal();
  const readers = await discoverReaders(terminal);

  if (readers && readers.length > 0) {
    await connectToReader(terminal, readers[0]);
  }

  return terminal;
}
```

**References**:
- See: `docs/stripe/terminal/`

### Example 2: Collect Payment with Terminal

**Question**: "How do I collect an in-person payment?"

**Response**:
```typescript
// Backend: Create PaymentIntent for Terminal
export async function createTerminalPaymentIntent(req, res) {
  try {
    const { amount } = req.body;

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100,
      currency: 'usd',
      payment_method_types: ['card_present'],
      capture_method: 'automatic', // or 'manual' for auth only
      metadata: {
        orderId: 'order_123',
      },
    });

    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Frontend: Collect payment
async function collectPayment(terminal: any, amount: number) {
  try {
    // Create PaymentIntent
    const response = await fetch('/api/create-terminal-payment-intent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amount }),
    }).then(r => r.json());

    // Collect payment method
    const collectResult = await terminal.collectPaymentMethod(
      response.clientSecret
    );

    if (collectResult.error) {
      throw new Error(collectResult.error.message);
    }

    console.log('Payment method collected:', collectResult.paymentIntent);

    // Process payment
    const processResult = await terminal.processPayment(
      collectResult.paymentIntent
    );

    if (processResult.error) {
      throw new Error(processResult.error.message);
    }

    console.log('Payment successful:', processResult.paymentIntent);

    // Optionally confirm on backend
    await fetch('/api/capture-payment-intent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        paymentIntentId: processResult.paymentIntent.id,
      }),
    });

    return processResult.paymentIntent;
  } catch (error) {
    console.error('Payment failed:', error);
    throw error;
  }
}

// Cancel payment collection
async function cancelPayment(terminal: any) {
  const cancelResult = await terminal.cancelCollectPaymentMethod();

  if (cancelResult.error) {
    console.error('Cancel failed:', cancelResult.error);
  } else {
    console.log('Payment collection canceled');
  }
}

// Handle reader events
terminal.on('connection_status', (status) => {
  console.log('Connection status:', status);
});

terminal.on('payment_status', (status) => {
  console.log('Payment status:', status);
});
```

**References**:
- See: `docs/stripe/terminal/payments/`

### Example 3: Create Location and Register Reader

**Question**: "How do I register a physical reader?"

**Response**:
```typescript
// Create location
export async function createLocation(req, res) {
  try {
    const { displayName, address } = req.body;

    const location = await stripe.terminal.locations.create({
      display_name: displayName,
      address: {
        line1: address.line1,
        city: address.city,
        state: address.state,
        postal_code: address.postalCode,
        country: address.country,
      },
    });

    res.json({ location });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// List locations
export async function listLocations(req, res) {
  try {
    const locations = await stripe.terminal.locations.list({
      limit: 10,
    });

    res.json({ locations: locations.data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Register reader (done via Stripe Dashboard or mobile app)
// Readers are automatically registered when first connected

// List readers
export async function listReaders(req, res) {
  try {
    const { locationId } = req.query;

    const readers = await stripe.terminal.readers.list({
      location: locationId as string,
      limit: 10,
    });

    res.json({ readers: readers.data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Update reader
export async function updateReader(req, res) {
  try {
    const { readerId, label, metadata } = req.body;

    const reader = await stripe.terminal.readers.update(readerId, {
      label,
      metadata,
    });

    res.json({ reader });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Delete reader
export async function deleteReader(req, res) {
  try {
    const { readerId } = req.body;

    const deleted = await stripe.terminal.readers.del(readerId);

    res.json({ deleted });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
```

**References**:
- See: `docs/stripe/terminal/locations/`
- See: `docs/stripe/terminal/readers/`

### Example 4: Issue Cards

**Question**: "How do I issue cards with Stripe Issuing?"

**Response**:
```typescript
// Create cardholder
export async function createCardholder(req, res) {
  try {
    const { name, email, phone, address } = req.body;

    const cardholder = await stripe.issuing.cardholders.create({
      name,
      email,
      phone_number: phone,
      billing: {
        address: {
          line1: address.line1,
          city: address.city,
          state: address.state,
          postal_code: address.postalCode,
          country: address.country,
        },
      },
      type: 'individual', // or 'company'
      metadata: {
        userId: req.user.id,
      },
    });

    res.json({ cardholder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Issue virtual card
export async function issueVirtualCard(req, res) {
  try {
    const { cardholderId } = req.body;

    const card = await stripe.issuing.cards.create({
      cardholder: cardholderId,
      currency: 'usd',
      type: 'virtual',
      status: 'active',
      spending_controls: {
        spending_limits: [
          {
            amount: 50000, // $500 per month
            interval: 'per_month',
          },
        ],
        allowed_categories: ['restaurants', 'gas_stations'],
      },
      metadata: {
        purpose: 'Employee expenses',
      },
    });

    res.json({ card });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Issue physical card
export async function issuePhysicalCard(req, res) {
  try {
    const { cardholderId, shippingAddress } = req.body;

    const card = await stripe.issuing.cards.create({
      cardholder: cardholderId,
      currency: 'usd',
      type: 'physical',
      status: 'inactive', // Activate after cardholder receives it
      shipping: {
        name: 'John Doe',
        address: {
          line1: shippingAddress.line1,
          city: shippingAddress.city,
          state: shippingAddress.state,
          postal_code: shippingAddress.postalCode,
          country: shippingAddress.country,
        },
        service: 'standard', // or 'express', 'priority'
      },
    });

    res.json({ card });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Get card details (including sensitive data)
export async function getCardDetails(req, res) {
  try {
    const { cardId } = req.query;

    const card = await stripe.issuing.cards.retrieve(cardId as string, {
      expand: ['number', 'cvc'], // Get full card number and CVC
    });

    res.json({
      number: card.number,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      cvc: card.cvc,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Update card status
export async function updateCardStatus(req, res) {
  try {
    const { cardId, status } = req.body;
    // status: 'active', 'inactive', 'canceled'

    const card = await stripe.issuing.cards.update(cardId, {
      status,
    });

    res.json({ card });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
```

**Card Types**:
- **Virtual**: Instant issuance, online use
- **Physical**: 3-7 day delivery, in-person use

**References**:
- See: `docs/stripe/issuing/cards/`

### Example 5: Authorization Controls

**Question**: "How do I control card authorizations?"

**Response**:
```typescript
// Set spending controls on card
export async function setSpendingControls(req, res) {
  try {
    const { cardId, limits } = req.body;

    const card = await stripe.issuing.cards.update(cardId, {
      spending_controls: {
        spending_limits: [
          {
            amount: 100000, // $1000
            interval: 'per_month',
            categories: ['restaurants'],
          },
          {
            amount: 5000, // $50
            interval: 'per_transaction',
          },
        ],
        allowed_categories: [
          'restaurants',
          'gas_stations',
          'grocery_stores',
        ],
        blocked_categories: [
          'gambling',
          'adult_digital_content',
        ],
      },
    });

    res.json({ card });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Real-time authorization webhook
export async function handleAuthorizationWebhook(req, res) {
  const event = req.body;

  if (event.type === 'issuing_authorization.request') {
    const authorization = event.data.object;

    // Custom authorization logic
    const shouldApprove = await checkAuthorizationRules(authorization);

    if (shouldApprove) {
      // Approve authorization
      await stripe.issuing.authorizations.approve(authorization.id);
    } else {
      // Decline authorization
      await stripe.issuing.authorizations.decline(authorization.id, {
        reason: 'insufficient_funds', // or 'spending_controls'
      });
    }
  }

  res.json({ received: true });
}

async function checkAuthorizationRules(authorization: any): Promise<boolean> {
  // Custom business logic
  const cardholder = await db.cardholders.findUnique({
    where: { stripeId: authorization.cardholder },
  });

  // Check balance
  if (cardholder.balance < authorization.amount) {
    return false;
  }

  // Check merchant category
  if (BLOCKED_MCCS.includes(authorization.merchant_data.category)) {
    return false;
  }

  // Check time of day
  const hour = new Date().getHours();
  if (hour < 6 || hour > 22) {
    return false; // Block late-night transactions
  }

  return true;
}

// List authorizations
export async function listAuthorizations(req, res) {
  try {
    const { cardId } = req.query;

    const authorizations = await stripe.issuing.authorizations.list({
      card: cardId as string,
      limit: 10,
    });

    res.json({ authorizations: authorizations.data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Capture authorization
export async function captureAuthorization(req, res) {
  try {
    const { authorizationId, captureAmount } = req.body;

    const authorization = await stripe.issuing.authorizations.update(
      authorizationId,
      {
        metadata: { capture_amount: captureAmount },
      }
    );

    res.json({ authorization });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
```

**Authorization States**:
- `pending`: Awaiting approval
- `approved`: Approved
- `declined`: Declined

**References**:
- See: `docs/stripe/issuing/controls/`

## Common Patterns

### Terminal Payment Flow
```typescript
// 1. Create PaymentIntent (backend)
// 2. Collect payment method (Terminal SDK)
// 3. Process payment (Terminal SDK)
// 4. Confirm payment (webhook)
```

### Card Lifecycle
```typescript
// 1. Create cardholder
// 2. Issue card (virtual or physical)
// 3. Activate card (physical only)
// 4. Monitor transactions
// 5. Update/cancel card as needed
```

### Real-time Authorization
```typescript
// Webhook: issuing_authorization.request
// → Check rules
// → Approve or decline within 5 seconds
```

## Search Helpers

```bash
# Find Terminal docs
grep -r "Terminal\|reader\|in-person" /Users/zach/Documents/cc-skills/docs/stripe/terminal/

# Find Issuing docs
grep -r "Issuing\|card\|authorization" /Users/zach/Documents/cc-skills/docs/stripe/issuing/

# List Terminal files
ls /Users/zach/Documents/cc-skills/docs/stripe/terminal/

# List Issuing files
ls /Users/zach/Documents/cc-skills/docs/stripe/issuing/
```

## Common Errors

### Terminal
- **Reader not found**: Reader not registered or offline
  - Solution: Check reader power and connection

- **Connection token expired**: Token older than 60 seconds
  - Solution: Fetch new connection token

- **Payment timeout**: Reader timeout waiting for card
  - Solution: Set appropriate timeout or cancel

### Issuing
- **Cardholder required**: Missing cardholder
  - Solution: Create cardholder first

- **Spending limit exceeded**: Transaction over limit
  - Solution: Adjust spending controls

- **Authorization declined**: Custom logic declined
  - Solution: Check authorization rules

## Security Notes

### Terminal
- **Secure connection tokens** - Use HTTPS
- **Validate reader ID** - Ensure reader belongs to your account
- **Monitor offline mode** - Reconcile offline payments

### Issuing
- **Protect card details** - Never log full card numbers
- **Implement fraud detection** - Monitor unusual patterns
- **Use real-time authorizations** - Control spending instantly
- **Secure cardholder data** - Follow PCI compliance

## Notes

- Documentation covers latest Stripe API (2023+)
- Terminal requires physical hardware (readers)
- Issuing requires approval from Stripe
- Real-time authorization webhook must respond within 5 seconds
- Virtual cards are instant, physical cards take 3-7 days
- File paths reference local documentation cache
- For latest updates, check:
  - https://stripe.com/docs/terminal
  - https://stripe.com/docs/issuing
