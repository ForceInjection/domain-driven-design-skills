---
name: stripe-payments
description: Use when processing payments, handling payment methods, implementing PaymentIntents, or integrating Payment Element. Invoke for payment flow setup, 3D Secure authentication, refund processing, payment method management, or checkout implementation.
allowed-tools: Read, Grep, Glob
---

# Stripe Payments Expert

## Purpose

Expert knowledge of Stripe payments infrastructure. Covers PaymentIntents, payment methods, 3D Secure authentication, refunds, Payment Element, and complete payment flow implementation.

## When to Use

Invoke this skill when:
- Implementing payment acceptance
- Setting up PaymentIntents flow
- Handling payment methods (cards, wallets, bank accounts)
- Implementing 3D Secure authentication
- Processing refunds and disputes
- Integrating Payment Element
- Building checkout flows
- Handling payment webhooks
- Implementing payment confirmations
- Debugging payment issues

## Documentation Available

**Location**: `/Users/zach/Documents/cc-skills/docs/stripe/`

**Coverage** (~436 files in payments/):
- **PaymentIntents**:
  - Creating and confirming payments
  - Payment flow lifecycle
  - Automatic payment methods
  - Manual confirmation

- **Payment Methods**:
  - Cards (Visa, Mastercard, Amex, etc.)
  - Digital wallets (Apple Pay, Google Pay)
  - Bank transfers (ACH, SEPA)
  - Buy now pay later (Klarna, Afterpay)
  - Local payment methods

- **Authentication**:
  - 3D Secure (SCA compliance)
  - Strong Customer Authentication
  - Authentication challenges

- **Payment Element**:
  - Pre-built UI components
  - Customization options
  - Integration patterns

- **Refunds & Disputes**:
  - Full and partial refunds
  - Refund reasons
  - Dispute handling

## Related Skills

- **stripe-billing-subscriptions**: For recurring payments
- **stripe-connect**: For marketplace payments
- **stripe-api-integration**: For webhooks and API patterns
- **stripe-terminal-issuing**: For in-person payments

## Best Practices

- **Use PaymentIntents** - Not deprecated Charges API
- **Handle webhooks properly** - Verify signatures
- **Implement idempotency** - Use idempotency keys
- **Test with test cards** - Use official test card numbers
- **Handle errors gracefully** - Show user-friendly messages
- **Store customer IDs** - Enable saved payment methods
- **Use Payment Element** - Pre-built, optimized UI
- **Implement SCA** - Required in Europe
- **Log payment attempts** - For debugging and reconciliation

## Examples

### Example 1: Basic Payment Flow with PaymentIntents

**Question**: "How do I implement a basic payment flow?"

**Response**:
```typescript
// Backend: Create PaymentIntent
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

// POST /api/create-payment-intent
export async function createPaymentIntent(req, res) {
  try {
    const { amount, currency = 'usd' } = req.body;

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Convert to cents
      currency,
      automatic_payment_methods: {
        enabled: true, // Enable all available payment methods
      },
      metadata: {
        orderId: '12345',
        customerId: req.user.id,
      },
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Frontend: Confirm payment with Stripe.js
import { loadStripe } from '@stripe/stripe-js';
import {
  Elements,
  PaymentElement,
  useStripe,
  useElements,
} from '@stripe/react-stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);

function CheckoutForm({ clientSecret }: { clientSecret: string }) {
  const stripe = useStripe();
  const elements = useElements();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!stripe || !elements) return;

    setLoading(true);
    setError(null);

    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/payment/success`,
      },
    });

    if (error) {
      setError(error.message || 'Payment failed');
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button type="submit" disabled={!stripe || loading}>
        {loading ? 'Processing...' : 'Pay now'}
      </button>
      {error && <div className="error">{error}</div>}
    </form>
  );
}

export function CheckoutPage({ amount }: { amount: number }) {
  const [clientSecret, setClientSecret] = useState('');

  useEffect(() => {
    // Create PaymentIntent on mount
    fetch('/api/create-payment-intent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amount }),
    })
      .then((r) => r.json())
      .then((data) => setClientSecret(data.clientSecret));
  }, [amount]);

  if (!clientSecret) return <div>Loading...</div>;

  return (
    <Elements stripe={stripePromise} options={{ clientSecret }}>
      <CheckoutForm clientSecret={clientSecret} />
    </Elements>
  );
}
```

**Payment Flow**:
1. Create PaymentIntent on backend
2. Return client_secret to frontend
3. Collect payment details with Payment Element
4. Confirm payment with Stripe.js
5. Handle redirect for authentication (3DS)
6. Webhook confirms successful payment

**References**:
- See: `docs/stripe/payments/payment-intents/`
- See: `docs/stripe/payments/accept-a-payment/`

### Example 2: Payment Methods & Saved Cards

**Question**: "How do I save payment methods for future use?"

**Response**:
```typescript
// Backend: Create customer and attach payment method
export async function savePaymentMethod(req, res) {
  try {
    const { paymentMethodId, email } = req.body;

    // Create or retrieve customer
    let customer;
    const existingCustomer = await stripe.customers.list({
      email,
      limit: 1,
    });

    if (existingCustomer.data.length > 0) {
      customer = existingCustomer.data[0];
    } else {
      customer = await stripe.customers.create({
        email,
        payment_method: paymentMethodId,
        invoice_settings: {
          default_payment_method: paymentMethodId,
        },
      });
    }

    // Attach payment method to customer
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customer.id,
    });

    res.json({ customerId: customer.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Create PaymentIntent with saved payment method
export async function chargeCustomer(req, res) {
  try {
    const { customerId, amount } = req.body;

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100,
      currency: 'usd',
      customer: customerId,
      payment_method_types: ['card'],
      setup_future_usage: 'off_session', // Save for future use
      metadata: {
        orderId: '12345',
      },
    });

    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// List customer payment methods
export async function listPaymentMethods(req, res) {
  try {
    const { customerId } = req.query;

    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId as string,
      type: 'card',
    });

    res.json({ paymentMethods: paymentMethods.data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Delete payment method
export async function deletePaymentMethod(req, res) {
  try {
    const { paymentMethodId } = req.body;

    await stripe.paymentMethods.detach(paymentMethodId);

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Frontend: Show saved payment methods
function SavedPaymentMethods({ customerId }: { customerId: string }) {
  const [methods, setMethods] = useState([]);

  useEffect(() => {
    fetch(`/api/payment-methods?customerId=${customerId}`)
      .then(r => r.json())
      .then(data => setMethods(data.paymentMethods));
  }, [customerId]);

  const handleDelete = async (id: string) => {
    await fetch('/api/payment-methods', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ paymentMethodId: id }),
    });

    setMethods(methods.filter(m => m.id !== id));
  };

  return (
    <div>
      {methods.map(method => (
        <div key={method.id}>
          {method.card.brand} •••• {method.card.last4}
          <button onClick={() => handleDelete(method.id)}>Remove</button>
        </div>
      ))}
    </div>
  );
}
```

**References**:
- See: `docs/stripe/payments/payment-methods/`
- See: `docs/stripe/payments/save-and-reuse/`

### Example 3: Refunds and Cancellations

**Question**: "How do I process refunds?"

**Response**:
```typescript
// Full refund
export async function fullRefund(req, res) {
  try {
    const { paymentIntentId } = req.body;

    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      reason: 'requested_by_customer', // or 'duplicate', 'fraudulent'
    });

    res.json({ refund });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Partial refund
export async function partialRefund(req, res) {
  try {
    const { paymentIntentId, amount } = req.body;

    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      amount: amount * 100, // Refund specific amount
      reason: 'requested_by_customer',
      metadata: {
        reason: 'Partial order cancellation',
      },
    });

    res.json({ refund });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Cancel PaymentIntent (before capture)
export async function cancelPayment(req, res) {
  try {
    const { paymentIntentId } = req.body;

    const paymentIntent = await stripe.paymentIntents.cancel(paymentIntentId);

    res.json({ paymentIntent });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// List refunds
export async function listRefunds(req, res) {
  try {
    const { paymentIntentId } = req.query;

    const refunds = await stripe.refunds.list({
      payment_intent: paymentIntentId as string,
      limit: 10,
    });

    res.json({ refunds: refunds.data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Check refund status
export async function getRefund(req, res) {
  try {
    const { refundId } = req.query;

    const refund = await stripe.refunds.retrieve(refundId as string);

    res.json({ refund });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
```

**Refund Reasons**:
- `requested_by_customer` - Customer requested
- `duplicate` - Duplicate payment
- `fraudulent` - Fraudulent transaction

**Refund Timing**:
- Cards: 5-10 business days
- ACH: 5-10 business days
- Instant for some payment methods

**References**:
- See: `docs/stripe/payments/refunds/`

### Example 4: Webhooks for Payment Events

**Question**: "How do I handle payment webhooks?"

**Response**:
```typescript
import { buffer } from 'micro';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

// Disable body parser (Next.js API route)
export const config = {
  api: {
    bodyParser: false,
  },
};

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

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

  // Handle event
  try {
    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await handlePaymentSuccess(paymentIntent);
        break;

      case 'payment_intent.payment_failed':
        const failedPayment = event.data.object as Stripe.PaymentIntent;
        await handlePaymentFailure(failedPayment);
        break;

      case 'payment_intent.canceled':
        const canceledPayment = event.data.object as Stripe.PaymentIntent;
        await handlePaymentCanceled(canceledPayment);
        break;

      case 'charge.refunded':
        const refund = event.data.object as Stripe.Charge;
        await handleRefund(refund);
        break;

      case 'payment_method.attached':
        const paymentMethod = event.data.object as Stripe.PaymentMethod;
        await handlePaymentMethodAttached(paymentMethod);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (err) {
    console.error('Error handling webhook:', err);
    res.status(500).json({ error: 'Webhook handler failed' });
  }
}

async function handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
  console.log('Payment succeeded:', paymentIntent.id);

  // Update order status
  await db.orders.update({
    where: { id: paymentIntent.metadata.orderId },
    data: {
      status: 'paid',
      paymentIntentId: paymentIntent.id,
    },
  });

  // Send confirmation email
  await sendEmail({
    to: paymentIntent.receipt_email!,
    subject: 'Payment Confirmed',
    body: 'Your payment was successful!',
  });
}

async function handlePaymentFailure(paymentIntent: Stripe.PaymentIntent) {
  console.log('Payment failed:', paymentIntent.id);

  const lastError = paymentIntent.last_payment_error;
  console.log('Error:', lastError?.message);

  // Update order status
  await db.orders.update({
    where: { id: paymentIntent.metadata.orderId },
    data: {
      status: 'payment_failed',
      errorMessage: lastError?.message,
    },
  });

  // Send failure email
  await sendEmail({
    to: paymentIntent.receipt_email!,
    subject: 'Payment Failed',
    body: 'Your payment could not be processed. Please try again.',
  });
}

async function handlePaymentCanceled(paymentIntent: Stripe.PaymentIntent) {
  console.log('Payment canceled:', paymentIntent.id);

  await db.orders.update({
    where: { id: paymentIntent.metadata.orderId },
    data: { status: 'canceled' },
  });
}

async function handleRefund(charge: Stripe.Charge) {
  console.log('Refund processed:', charge.id);

  await db.orders.update({
    where: { paymentIntentId: charge.payment_intent as string },
    data: { status: 'refunded' },
  });
}

async function handlePaymentMethodAttached(paymentMethod: Stripe.PaymentMethod) {
  console.log('Payment method attached:', paymentMethod.id);

  // Store payment method details
  await db.paymentMethods.create({
    data: {
      id: paymentMethod.id,
      customerId: paymentMethod.customer as string,
      type: paymentMethod.type,
      last4: paymentMethod.card?.last4,
      brand: paymentMethod.card?.brand,
    },
  });
}
```

**Important Webhook Events**:
- `payment_intent.succeeded` - Payment successful
- `payment_intent.payment_failed` - Payment failed
- `payment_intent.canceled` - Payment canceled
- `charge.refunded` - Refund processed
- `payment_method.attached` - Payment method saved

**References**:
- See: `docs/stripe/webhooks/`
- See: `docs/stripe/payments/handling-payment-events/`

### Example 5: 3D Secure Authentication

**Question**: "How do I handle 3D Secure authentication?"

**Response**:
```typescript
// Backend: PaymentIntent with SCA
export async function createPaymentWithSCA(req, res) {
  try {
    const { amount, currency, customerId } = req.body;

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100,
      currency,
      customer: customerId,
      payment_method_types: ['card'],
      // Explicitly request authentication
      confirmation_method: 'manual',
      confirm: false,
    });

    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Frontend: Handle authentication
function CheckoutWithSCA({ clientSecret }: { clientSecret: string }) {
  const stripe = useStripe();
  const elements = useElements();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!stripe || !elements) return;

    // Confirm payment (may trigger 3DS)
    const { error, paymentIntent } = await stripe.confirmCardPayment(
      clientSecret,
      {
        payment_method: {
          card: elements.getElement('card')!,
          billing_details: {
            name: 'Customer Name',
            email: 'customer@example.com',
          },
        },
      }
    );

    if (error) {
      // Show error (authentication failed)
      console.error(error.message);
    } else if (paymentIntent.status === 'requires_action') {
      // Handle additional authentication
      const { error: authError } = await stripe.handleCardAction(clientSecret);

      if (authError) {
        console.error('Authentication failed:', authError.message);
      } else {
        // Payment authenticated, confirm again
        const { error: confirmError } = await stripe.confirmCardPayment(
          clientSecret
        );

        if (confirmError) {
          console.error(confirmError.message);
        } else {
          // Payment successful
          console.log('Payment succeeded!');
        }
      }
    } else if (paymentIntent.status === 'succeeded') {
      // Payment successful without additional auth
      console.log('Payment succeeded!');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <CardElement />
      <button type="submit">Pay</button>
    </form>
  );
}

// Automatic handling with Payment Element (recommended)
function CheckoutAutoSCA({ clientSecret }: { clientSecret: string }) {
  const stripe = useStripe();
  const elements = useElements();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!stripe || !elements) return;

    // Payment Element handles 3DS automatically
    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/payment/success`,
      },
    });

    if (error) {
      console.error(error.message);
    }
    // Success handled by return_url
  };

  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button type="submit">Pay</button>
    </form>
  );
}
```

**3DS States**:
- `requires_payment_method` - Needs payment method
- `requires_confirmation` - Ready to confirm
- `requires_action` - Needs authentication (3DS)
- `processing` - Being processed
- `succeeded` - Payment successful

**References**:
- See: `docs/stripe/payments/3d-secure/`
- See: `docs/stripe/payments/strong-customer-authentication/`

## Common Patterns

### Idempotency for Retries
```typescript
const paymentIntent = await stripe.paymentIntents.create(
  {
    amount: 1000,
    currency: 'usd',
  },
  {
    idempotencyKey: 'order_12345', // Prevents duplicate charges
  }
);
```

### Test Card Numbers
```typescript
// Success
4242 4242 4242 4242

// Requires authentication (3DS)
4000 0027 6000 3184

// Declined
4000 0000 0000 0002

// Insufficient funds
4000 0000 0000 9995
```

### Payment Status Check
```typescript
const paymentIntent = await stripe.paymentIntents.retrieve('pi_xxx');

if (paymentIntent.status === 'succeeded') {
  // Payment complete
}
```

## Search Helpers

```bash
# Find payment docs
grep -r "PaymentIntent\|payment\|charge" /Users/zach/Documents/cc-skills/docs/stripe/payments/

# Find authentication docs
grep -r "3D Secure\|SCA\|authentication" /Users/zach/Documents/cc-skills/docs/stripe/payments/

# Find refund docs
grep -r "refund\|cancel" /Users/zach/Documents/cc-skills/docs/stripe/payments/

# List payment files
ls /Users/zach/Documents/cc-skills/docs/stripe/payments/
```

## Common Errors

- **PaymentIntent already succeeded**: Trying to confirm twice
  - Solution: Check status before confirming

- **Invalid API key**: Wrong or missing key
  - Solution: Verify STRIPE_SECRET_KEY is set

- **Customer not found**: Using invalid customer ID
  - Solution: Create customer first or verify ID

- **Webhook signature mismatch**: Wrong secret or modified payload
  - Solution: Use correct STRIPE_WEBHOOK_SECRET and raw body

## Security Tips

1. **Never expose secret key** - Use only on backend
2. **Verify webhook signatures** - Prevent tampering
3. **Use HTTPS** - Required for production
4. **Implement idempotency** - Prevent duplicate charges
5. **Validate amounts** - Server-side validation
6. **Log payment attempts** - Audit trail
7. **Handle PCI compliance** - Use Stripe.js/Elements

## Notes

- Documentation covers latest Stripe API (2023+)
- PaymentIntents is the recommended API (not Charges)
- Payment Element handles most payment methods automatically
- Webhooks are essential for reliable payment confirmation
- Test mode uses test API keys and test card numbers
- File paths reference local documentation cache
- For latest updates, check https://stripe.com/docs/payments
