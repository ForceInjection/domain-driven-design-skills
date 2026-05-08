---
name: error-tracking
description: Provide analysis and recommendations for error handling patterns, Sentry integration, and error monitoring strategies - ANALYSIS-ONLY skill that provides guidance without modifying code
schema_version: 1.0
---

# error-tracking

**Type:** ANALYSIS-ONLY
**DAIC Modes:** DISCUSS, ALIGN, IMPLEMENT, CHECK (all modes)
**Priority:** Medium

## Trigger Reference

This skill activates on:
- Keywords: "error handling", "sentry", "error tracking", "captureException", "captureMessage"
- Intent patterns: "(add|implement|configure).*?sentry", "error.*?(tracking|monitoring|handling)"
- File patterns: `**/instrument.ts`, `**/sentry*.ts`

From: `skill-rules.json` - error-tracking configuration

## Purpose

Provide analysis and recommendations for error handling patterns, Sentry integration, and error monitoring strategies. This is an ANALYSIS-ONLY skill that never modifies code directly but provides guidance and suggestions.

## Core Behavior

In any DAIC mode (DISCUSS, ALIGN, IMPLEMENT, CHECK):

1. **Error Handling Analysis**
   - Review try-catch patterns for completeness
   - Identify missing error boundaries
   - Suggest error recovery strategies
   - Recommend logging best practices
   - Analyze error propagation flow

2. **Sentry Integration Guidance**
   - Recommend Sentry SDK setup for platform (Node.js, Browser, etc.)
   - Suggest appropriate Sentry.captureException() placements
   - Guide context enrichment (tags, breadcrumbs, user info)
   - Recommend error filtering and sampling strategies
   - Help configure source maps for stack traces

3. **Error Monitoring Strategy**
   - Suggest what errors to track vs. ignore
   - Recommend alert thresholds and grouping
   - Guide error categorization (severity levels)
   - Help design error dashboards
   - Suggest performance vs. error correlation

4. **Best Practices Enforcement**
   - Ensure errors include actionable context
   - Recommend structured error messages
   - Suggest error types/classes for different scenarios
   - Guide async error handling (promises, async/await)
   - Recommend graceful degradation patterns

## Safety Guardrails

**ANALYSIS-ONLY RULES:**
- ✓ NEVER call write tools (Edit, Write, MultiEdit)
- ✓ NEVER modify code directly
- ✓ Only provide analysis, recommendations, and code examples
- ✓ Safe to run in any DAIC mode

**Recommendation Quality:**
- Provide specific, actionable suggestions
- Include code examples in recommendations
- Explain trade-offs of different approaches
- Consider project context (Node.js vs. Browser, framework used)
- Link to relevant documentation where helpful

## Examples

### When to Activate

✓ "How should I handle errors in this Express route?"
✓ "Add Sentry to this project"
✓ "Review error handling in auth.js"
✓ "What errors should I track with Sentry?"
✓ "How do I capture user context with errors?"

### Typical Output

**Analysis:**
```markdown
### Error Handling Analysis: auth.js

**Issues Found:**
1. Line 45: Uncaught promise rejection in loginUser()
2. Line 67: Generic catch block without context
3. Missing error boundary for async middleware

**Recommendations:**

1. **Add Promise Rejection Handling (Line 45)**
   ```javascript
   // Before
   const user = await User.findOne({ email });

   // After
   try {
     const user = await User.findOne({ email });
   } catch (error) {
     Sentry.captureException(error, {
       tags: { operation: 'user_lookup' },
       extra: { email }
     });
     throw new AuthenticationError('User lookup failed');
   }
   ```

2. **Enrich Error Context (Line 67)**
   ```javascript
   // Before
   catch (error) {
     console.error(error);
   }

   // After
   catch (error) {
     Sentry.captureException(error, {
       tags: {
         auth_stage: 'token_verification',
         user_id: userId
       },
       level: 'error'
     });
     res.status(401).json({ error: 'Authentication failed' });
   }
   ```

3. **Add Error Boundary Middleware**
   ```javascript
   app.use((error, req, res, next) => {
     Sentry.captureException(error, {
       tags: {
         path: req.path,
         method: req.method
       },
       user: { id: req.user?.id }
     });

     res.status(error.status || 500).json({
       error: process.env.NODE_ENV === 'production'
         ? 'Internal server error'
         : error.message
     });
   });
   ```
```

### When NOT to Activate

✗ User is asking about general debugging (not error tracking)
✗ Question is about testing, not error handling
✗ Focus is on performance, not errors
✗ User wants to implement errors (recommend activating a WRITE-CAPABLE skill)

## Sentry Setup Recommendations

### Basic Node.js/Express Setup

```javascript
// instrument.js (must be first import)
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1, // Adjust based on traffic

  beforeSend(event, hint) {
    // Filter sensitive data
    if (event.request?.data) {
      delete event.request.data.password;
      delete event.request.data.token;
    }
    return event;
  }
});

module.exports = Sentry;
```

### Error Categorization

Recommend error severity levels:

**Critical** - System failures, database connectivity
```javascript
Sentry.captureException(error, { level: 'fatal' });
```

**Error** - Request failures, auth failures
```javascript
Sentry.captureException(error, { level: 'error' });
```

**Warning** - Deprecations, rate limits
```javascript
Sentry.captureMessage('Rate limit approaching', { level: 'warning' });
```

**Info** - Notable events
```javascript
Sentry.captureMessage('Large file uploaded', { level: 'info' });
```

## Common Error Patterns

### 1. Async Route Handler
```javascript
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next))
    .catch((error) => {
      Sentry.captureException(error, {
        tags: { route: req.route.path },
        user: { id: req.user?.id }
      });
      next(error);
    });
};

// Usage
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
}));
```

### 2. Error with Context
```javascript
try {
  await processPayment(order);
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      payment_provider: order.paymentProvider,
      order_id: order.id
    },
    extra: {
      amount: order.total,
      currency: order.currency
    },
    level: 'error'
  });
  throw new PaymentError('Payment processing failed', { cause: error });
}
```

### 3. Error Filtering
```javascript
Sentry.init({
  dsn: process.env.SENTRY_DSN,

  beforeSend(event) {
    // Don't send validation errors to Sentry
    if (event.exception?.values?.[0]?.type === 'ValidationError') {
      return null;
    }

    // Don't send 404s
    if (event.request?.url && event.exception?.values?.[0]?.value?.includes('404')) {
      return null;
    }

    return event;
  }
});
```

## Integration with Framework

When user is in IMPLEMENT mode and ready to add Sentry:
1. Analyze current error handling
2. Provide specific integration recommendations
3. Suggest they activate a WRITE-CAPABLE skill for implementation
4. Offer to review after implementation (in CHECK mode)

## Decision Logging

When providing significant error handling recommendations:

```markdown
### Error Tracking Recommendation: [Date]
- **File:** src/api/auth.js
- **Issue:** Missing error boundaries for async operations
- **Recommendation:** Add asyncHandler wrapper + Sentry integration
- **Rationale:** Current implementation silently fails on promise rejections
- **Next Steps:** Implement in IMPLEMENT mode, review in CHECK mode
```

## Related Skills

- **cc-sessions-core** - If implementing error tracking in cc-sessions itself
- **framework_health_check** - To validate error handling is working
- **daic_mode_guidance** - If user needs to transition to IMPLEMENT mode

---

**Last Updated:** 2025-11-15
**Framework Version:** 2.0
