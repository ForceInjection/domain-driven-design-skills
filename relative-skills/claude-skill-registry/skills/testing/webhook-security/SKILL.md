---
name: webhook-security
description: Webhook validation patterns with signature verification, event logging, and testing tools. Use when implementing webhooks, validating webhook signatures, securing payment webhooks, testing webhook endpoints, preventing replay attacks, or when user mentions webhook security, Stripe webhooks, signature verification, webhook testing, or event validation.
allowed-tools: Bash, Read, Write, Edit, WebFetch
---

# webhook-security

## Instructions

This skill provides comprehensive webhook security patterns for payment integrations (Stripe, PayPal, and other providers). It covers signature verification, replay attack prevention, event logging, idempotency, and local testing workflows.

### 1. Webhook Signature Verification

Implement cryptographic signature verification to authenticate webhook requests:

**Why Signature Verification Matters:**
- Prevents attackers from forging webhook events
- Ensures events actually come from the payment provider
- Required for PCI compliance in production
- Protects against man-in-the-middle attacks

**Setup Process:**
```bash
# Generate and configure webhook endpoint with signature verification
bash /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/scripts/setup-webhook-endpoint.sh stripe
```

**Verification Algorithm (Stripe):**
1. Extract timestamp and signature from webhook headers
2. Construct signed payload: `timestamp.raw_body`
3. Compute HMAC-SHA256 hash using webhook secret
4. Compare computed signature with received signature
5. Verify timestamp is within tolerance (5 minutes default)

### 2. Replay Attack Prevention

Protect against replay attacks where attackers resend captured webhook events:

**Defense Mechanisms:**
- **Timestamp Validation:** Reject events older than 5 minutes
- **Event ID Tracking:** Store processed event IDs to prevent duplicates
- **Signature Verification:** Ensures event hasn't been tampered with
- **Idempotency Keys:** Safe to process same event multiple times

**Implementation:**
```python
# Use the signature verification script
python /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/scripts/verify-signature.py
```

### 3. Event Logging and Auditing

Log all webhook events for debugging, compliance, and dispute resolution:

**What to Log:**
- Raw webhook payload (for signature re-verification)
- Event type and ID
- Timestamp received
- Processing status (success, failure, retry)
- Error messages if processing failed
- User/account associated with event

**Template Usage:**
```python
# Use event logger template for database storage
cat /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/templates/event_logger.py
```

### 4. Local Webhook Testing

Test webhooks locally before deploying to production:

**Using Stripe CLI:**
```bash
# Forward webhooks to local development server
bash /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/scripts/test-webhook-locally.sh
```

**Testing Workflow:**
1. Install Stripe CLI (`stripe` command)
2. Login to your Stripe account
3. Forward webhooks to localhost
4. Trigger test events from Stripe Dashboard or CLI
5. Verify signature verification works
6. Check event logging and processing

### 5. Webhook Secret Management

Securely manage webhook signing secrets:

**CRITICAL SECURITY RULE:**
```bash
# ✅ CORRECT - Never hardcode secrets
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# ❌ WRONG - Never commit real secrets
STRIPE_WEBHOOK_SECRET=whsec_1234567890abcdef...  # DON'T DO THIS
```

**Generate Webhook Secret:**
```bash
# Get webhook secret for your endpoint
bash /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/scripts/generate-webhook-secret.sh
```

**Secret Rotation:**
- Rotate webhook secrets quarterly
- Update all endpoints when rotating
- Test new secret before deactivating old one
- Store in environment variables, never in code

### 6. Error Handling and Retries

Handle webhook processing failures gracefully:

**Retry Logic:**
- Payment providers retry failed webhooks automatically
- Return 200 OK only after successful processing
- Return 500/503 for temporary failures (triggers retry)
- Return 400 for permanent failures (stops retries)

**Template Usage:**
```python
# Use retry handler template
cat /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/templates/retry_handler.py
```

**Best Practices:**
- Make webhook handlers idempotent (safe to retry)
- Process events asynchronously (queue for background jobs)
- Respond quickly (< 5 seconds) to avoid timeouts
- Store events before processing (persist first, process later)

## Examples

### Example 1: Stripe Subscription Webhook with Full Security

Complete implementation with signature verification, logging, and idempotency:

```bash
# 1. Set up webhook endpoint with security
bash /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/scripts/setup-webhook-endpoint.sh stripe

# 2. View the complete implementation
cat /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/examples/complete-webhook-handler.py

# 3. Test locally before deploying
bash /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/scripts/test-webhook-locally.sh

# 4. Deploy to production
# Ensure STRIPE_WEBHOOK_SECRET environment variable is set
# Configure webhook endpoint URL in Stripe Dashboard
```

**Result:** Production-ready webhook handler that:
- Verifies Stripe signatures cryptographically
- Prevents replay attacks via timestamp validation
- Logs all events to database with full audit trail
- Handles retries idempotently (safe to process twice)
- Returns appropriate HTTP status codes

### Example 2: Event Processing with Idempotency

Process payment events safely with duplicate protection:

```python
# Use the event processing example
cat /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/examples/event-processing-example.py
```

**Implementation:**
1. Check if event ID already processed (database lookup)
2. If processed, return 200 OK immediately (idempotent)
3. If new, store event to database with "pending" status
4. Process the event (update subscription, send email, etc.)
5. Update event status to "processed"
6. Return 200 OK

**Result:** Safe to receive duplicate events without side effects

### Example 3: Multi-Provider Webhook Handler

Support multiple payment providers with unified security:

```bash
# Set up webhooks for Stripe, PayPal, and Square
for provider in stripe paypal square; do
  bash /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/scripts/setup-webhook-endpoint.sh $provider
done
```

**Features:**
- Provider-specific signature verification (different algorithms)
- Unified event logging across providers
- Consistent retry handling
- Single testing workflow for all providers

### Example 4: Complete Testing Workflow

End-to-end webhook testing before production deployment:

```bash
# Use the complete testing example
bash /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/payments/skills/webhook-security/examples/webhook-testing-example.sh
```

**Test Scenarios:**
1. Valid signature - Should process successfully
2. Invalid signature - Should reject with 401
3. Expired timestamp - Should reject (replay protection)
4. Duplicate event ID - Should return 200 (idempotent)
5. Malformed payload - Should return 400
6. Processing failure - Should return 500 (triggers retry)

**Result:** High confidence before production deployment

## Requirements

**Environment Variables:**
```bash
# Stripe Configuration
STRIPE_API_KEY=sk_test_your_stripe_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# PayPal Configuration (if using PayPal)
PAYPAL_CLIENT_ID=your_paypal_client_id_here
PAYPAL_CLIENT_SECRET=your_paypal_client_secret_here
PAYPAL_WEBHOOK_ID=your_webhook_id_here

# Database Configuration
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
```

**Dependencies:**

Python (FastAPI):
- `fastapi` - Web framework for webhook endpoints
- `stripe` - Stripe Python SDK
- `sqlalchemy` - Database ORM for event logging
- `pydantic` - Data validation
- `python-dotenv` - Environment variable management
- `httpx` - HTTP client for webhook testing

Development Tools:
- `stripe-cli` - Local webhook testing (download from Stripe)
- `ngrok` or `localtunnel` - Expose localhost for testing
- `pytest` - Testing framework
- `requests` - HTTP client for manual testing

**Database Setup:**

Required table for event logging:
```sql
CREATE TABLE webhook_events (
    id SERIAL PRIMARY KEY,
    event_id VARCHAR(255) UNIQUE NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    signature VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    processed_at TIMESTAMP
);

CREATE INDEX idx_event_id ON webhook_events(event_id);
CREATE INDEX idx_status ON webhook_events(status);
```

**Payment Provider Setup:**

Stripe:
1. Create Stripe account (test mode for development)
2. Configure webhook endpoint in Stripe Dashboard
3. Select events to listen to (e.g., `customer.subscription.updated`)
4. Copy webhook signing secret
5. Set `STRIPE_WEBHOOK_SECRET` environment variable

PayPal:
1. Create PayPal Developer account
2. Create REST API app
3. Configure webhook endpoint in PayPal Developer Dashboard
4. Copy webhook ID
5. Set `PAYPAL_WEBHOOK_ID` environment variable

## Security Best Practices

**CRITICAL: Never Hardcode Webhook Secrets**

```bash
# ✅ CORRECT - Use environment variables
export STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# ✅ CORRECT - Read from environment in code
import os
webhook_secret = os.getenv("STRIPE_WEBHOOK_SECRET")
if not webhook_secret:
    raise ValueError("STRIPE_WEBHOOK_SECRET not set")

# ❌ WRONG - Never hardcode secrets
webhook_secret = "whsec_1234567890abcdef..."  # DON'T DO THIS
```

**Always Verify Signatures:**
- Never trust webhook data without verification
- Verify before any database operations
- Reject requests with invalid signatures immediately
- Log signature verification failures

**Prevent Replay Attacks:**
- Check timestamp is within 5-minute window
- Store processed event IDs to detect duplicates
- Use database constraints (UNIQUE on event_id)
- Never process events older than tolerance window

**Protect Webhook Endpoints:**
- Use HTTPS in production (required by most providers)
- Don't expose endpoint URL publicly
- Rate limit webhook endpoints
- Monitor for suspicious activity

**Event Logging:**
- Log raw payloads for audit trail
- Store signature for re-verification
- Record processing status and errors
- Retain logs for dispute resolution (90+ days)

**Idempotency:**
- Check event_id before processing
- Make handlers safe to retry
- Use database transactions
- Return 200 OK for duplicate events

**Error Handling:**
- Return appropriate HTTP status codes
- 200 - Successfully processed
- 400 - Invalid payload (don't retry)
- 401 - Invalid signature (don't retry)
- 500 - Processing error (will retry)
- Respond within 5 seconds to avoid timeout

## Common Webhook Events

**Stripe Subscription Events:**
- `customer.subscription.created` - New subscription
- `customer.subscription.updated` - Plan change, renewal
- `customer.subscription.deleted` - Cancellation
- `invoice.payment_succeeded` - Successful payment
- `invoice.payment_failed` - Failed payment

**Stripe Payment Events:**
- `payment_intent.succeeded` - One-time payment success
- `payment_intent.payment_failed` - Payment failure
- `charge.refunded` - Refund processed
- `charge.dispute.created` - Chargeback dispute

**PayPal Events:**
- `PAYMENT.SALE.COMPLETED` - Payment completed
- `BILLING.SUBSCRIPTION.CREATED` - New subscription
- `BILLING.SUBSCRIPTION.CANCELLED` - Subscription cancelled
- `CUSTOMER.DISPUTE.CREATED` - Dispute opened

## Troubleshooting

**Signature Verification Failing:**
1. Check webhook secret is correct
2. Verify using raw request body (not parsed JSON)
3. Check timestamp tolerance (default 5 minutes)
4. Ensure secret matches the endpoint in provider dashboard
5. Test with Stripe CLI to rule out code issues

**Events Not Reaching Endpoint:**
1. Check endpoint URL is publicly accessible
2. Verify HTTPS is configured (required in production)
3. Check firewall/security group rules
4. Review webhook logs in provider dashboard
5. Test with ngrok/localtunnel for local development

**Duplicate Events Being Processed:**
1. Ensure event_id is stored before processing
2. Check database has UNIQUE constraint on event_id
3. Verify idempotency logic is implemented
4. Review transaction handling in event processing

---

**Plugin:** payments
**Version:** 1.0.0
**Category:** Security
**Skill Type:** Webhook Security
