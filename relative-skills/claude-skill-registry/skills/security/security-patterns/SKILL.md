---
name: security-patterns
description: Security patterns for input validation, PII protection, and cryptographic operations
---

# Security Patterns

**Purpose**: Security best practices (validation, PII protection, crypto, defense against vulnerabilities)

- Keywords: security, validation, auth, password, token, sanitize, xss, sql injection, zod, pii, webhook, signature, verify, encrypt, decrypt, hash, jwt, oauth, csrf, authentication, authorization, stripe

## Quick Reference

| Category | ✅ DO | ❌ AVOID |
|----------|-------|----------|
| Validation | Zod schemas with constraints | Trust client input |
| PII | `sanitizeForLogging()` | Log emails, names, tokens |
| Crypto | `crypto.randomInt()` | `Math.random()` |
| Storage | Encrypt localStorage | Store keys/passwords |
| Errors | Generic to client | Stack traces to client |

## Input Validation (Zod)

```ts
import { z } from "zod"

const orderSchema = z.object({
  name: z.string().min(1).max(100).trim(),
  email: z.string().email().max(255).toLowerCase(),
  amount: z.number().positive().max(1000000),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/).optional()
})

type Result<T, E> = { ok: true; value: T } | { ok: false; error: E }

const validate = (input: unknown): Result<Order, z.ZodError> => {
  const result = orderSchema.safeParse(input)
  return result.success
    ? { ok: true, value: result.data }
    : { ok: false, error: result.error }
}
```

**Key**: Use `.safeParse()`, add constraints (`.min()`, `.max()`, `.trim()`), return Result

## PII Protection

```ts
import { sanitizeForLogging } from "./utils/sanitize"

// ✅ Auto-removes PII
logger.audit('order_created', sanitizeForLogging({
  user_id: "123",
  full_name: "John", // Removed
  email: "john@example.com", // Removed
  amount: 100
}))
// Logged: { user_id: "123", amount: 100 }
```

**Auto-removed**: Passwords, tokens, API keys, emails, names, SSN, cards, Bitcoin keys/addresses, phones

See `resources/pii-protection.md` for implementation.

## Secure Random

```ts
import { randomInt } from "crypto"

// ✅ Cryptographically secure
const sessionId = randomInt(0, Number.MAX_SAFE_INTEGER).toString(36)
const code = randomInt(100000, 999999).toString()

// ✅ Browser
const array = new Uint32Array(1)
crypto.getRandomValues(array)

// ❌ NEVER for security
const code = Math.random() * 1000000
```

## Secure Client Storage

```ts
import { encrypt, decrypt } from "./crypto"

const saveSession = (data: SessionData) => {
  const encrypted = encrypt(JSON.stringify(data))
  localStorage.setItem("session", encrypted)
}

// ❌ NEVER store Bitcoin keys/passwords (even encrypted)
```

## Error Handling

```ts
export const createOrder = async (input: unknown) => {
  try {
    const order = await processOrder(input)
    return { ok: true, value: order }
  } catch (error) {
    // ✅ Log full details server-side
    logger.error('Order failed', {
      error,
      stack: error.stack,
      input: sanitizeForLogging(input)
    })

    // ✅ Generic to client
    return {
      ok: false,
      error: new Error("Failed to create order")
    }
  }
}
```

## Webhook Verification

```ts
export const handleStripeWebhook = async (req: Request) => {
  const signature = req.headers.get("stripe-signature")
  const body = await req.text()

  // ✅ Verify signature BEFORE processing
  if (!verifySignature(body, signature, WEBHOOK_SECRET)) {
    logger.warn('Invalid signature', { ip: req.headers.get("x-forwarded-for") })
    return new Response("Invalid signature", { status: 401 })
  }

  // ✅ Check timestamp (replay attack)
  const event = JSON.parse(body)
  const eventTime = event.created * 1000
  if (Date.now() - eventTime > 5 * 60 * 1000) {
    return new Response("Timestamp too old", { status: 400 })
  }

  await processWebhookEvent(event)
  return new Response("OK", { status: 200 })
}
```

## Pre-Implementation Checklist

Before implementing, ask:

1. ✅ Can users access data they shouldn't? (Authorization)
2. ✅ Can this be automated/abused? (Rate limiting)
3. ✅ Am I trusting client data? (Validation)
4. ✅ Could this leak PII? (Sanitization)
5. ✅ Can concurrent requests cause issues? (Race conditions)
6. ✅ Can this be spammed? (Rate limiting, CAPTCHA)

**If ANY "yes" → redesign before implementing**

## Rate Limits

| Action | Limit |
|--------|-------|
| Registration | 3/IP/24h |
| Login | 10/email/5min |
| Password reset | 3/email/hour |
| API calls | 100/user/hour |

See `resources/rate-limiting.md`

## Incident Response

| Severity | Response | Examples |
|----------|----------|----------|
| Critical | 4 hours | Breach, auth bypass |
| High | 24 hours | PII leak, privilege escalation |
| Medium | 3 days | XSS, CSRF |

**Steps**: Assess → Contain → Investigate → Patch → Notify (<72h if PII)

## Resources

- `resources/input-validation.md` - Zod patterns
- `resources/pii-protection.md` - Sanitization
- `resources/crypto-operations.md` - Secure random, encryption
- `resources/rate-limiting.md` - Rate limit implementation
