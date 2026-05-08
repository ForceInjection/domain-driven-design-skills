---
name: billing-integration
description: Payment processing and subscription management integration patterns. Covers Stripe, payment lifecycle, webhooks, dunning, and billing system architecture.
allowed-tools: Read, Glob, Grep, Task, mcp__perplexity__search, mcp__perplexity__reason, mcp__context7__resolve-library-id, mcp__context7__query-docs, mcp__microsoft-learn__microsoft_docs_search, mcp__microsoft-learn__microsoft_docs_fetch
---

# Billing Integration Skill

Patterns for integrating payment processing and subscription management into SaaS applications.

## When to Use This Skill

Use this skill when:

- **Billing Integration tasks** - Working on payment processing and subscription management integration patterns. covers stripe, payment lifecycle, webhooks, dunning, and billing system architecture
- **Planning or design** - Need guidance on Billing Integration approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Billing integration connects your application to payment processors (Stripe, etc.) for subscription management, payment collection, and revenue operations.

## Billing Architecture

```text
+------------------------------------------------------------------+
|                    SaaS Billing Architecture                      |
+------------------------------------------------------------------+
|                                                                   |
|  +----------------+    +-----------------+    +----------------+  |
|  | Your App       |--->| Billing Service |--->| Stripe/Payment |  |
|  | (Subscriptions)|    | (Orchestration) |    | Provider       |  |
|  +----------------+    +-----------------+    +----------------+  |
|         |                      |                      |           |
|         v                      v                      v           |
|  +----------------+    +-----------------+    +----------------+  |
|  | Entitlements   |    | Usage Metering  |    | Webhooks       |  |
|  | (Feature Flags)|    | (Consumption)   |    | (Events)       |  |
|  +----------------+    +-----------------+    +----------------+  |
|                                                                   |
+------------------------------------------------------------------+
```

## Integration Patterns

### Stripe as Source of Truth

```text
Pattern: Stripe owns subscription state
Your App: Syncs state via webhooks
Benefit: Stripe handles complexity (proration, dunning, taxes)
Caveat: Need reliable webhook processing
```

### Hybrid Approach

```text
Pattern: Your DB + Stripe in sync
Your App: Owns business logic, uses Stripe for payments
Benefit: More control, faster reads
Caveat: Must keep in sync (eventual consistency)
```

## Core Entities

### Billing Domain Model

```csharp
// Your internal representation (synced from Stripe)
public sealed record Subscription
{
    public required Guid TenantId { get; init; }
    public required string StripeSubscriptionId { get; init; }
    public required string StripePriceId { get; init; }
    public required SubscriptionStatus Status { get; init; }
    public required DateTimeOffset CurrentPeriodStart { get; init; }
    public required DateTimeOffset CurrentPeriodEnd { get; init; }
    public DateTimeOffset? CancelAt { get; init; }
    public DateTimeOffset? TrialEnd { get; init; }
    public required int Quantity { get; init; }  // Seats
}

public enum SubscriptionStatus
{
    Trialing,
    Active,
    PastDue,
    Canceled,
    Unpaid,
    Incomplete,
    IncompleteExpired,
    Paused
}

public sealed record BillingCustomer
{
    public required Guid TenantId { get; init; }
    public required string StripeCustomerId { get; init; }
    public required string Email { get; init; }
    public string? DefaultPaymentMethodId { get; init; }
    public required string Currency { get; init; }
    public TaxInfo? TaxInfo { get; init; }
}
```

## Stripe Integration

### Client Setup (.NET)

```csharp
// Program.cs - Register Stripe client
builder.Services.AddSingleton<IStripeClient>(sp =>
{
    var apiKey = builder.Configuration["Stripe:SecretKey"];
    return new StripeClient(apiKey);
});

// Register services
builder.Services.AddScoped<CustomerService>();
builder.Services.AddScoped<SubscriptionService>();
builder.Services.AddScoped<InvoiceService>();
builder.Services.AddScoped<PaymentMethodService>();
builder.Services.AddScoped<UsageRecordService>();
```

### Creating Customers

```csharp
public sealed class BillingService(
    CustomerService customerService,
    SubscriptionService subscriptionService,
    IBillingRepository repository)
{
    public async Task<BillingCustomer> CreateCustomerAsync(
        Guid tenantId,
        string email,
        string? name = null,
        CancellationToken ct = default)
    {
        var options = new CustomerCreateOptions
        {
            Email = email,
            Name = name,
            Metadata = new Dictionary<string, string>
            {
                ["tenant_id"] = tenantId.ToString()
            }
        };

        var stripeCustomer = await customerService.CreateAsync(options, cancellationToken: ct);

        var customer = new BillingCustomer
        {
            TenantId = tenantId,
            StripeCustomerId = stripeCustomer.Id,
            Email = email,
            Currency = "usd"
        };

        await repository.SaveCustomerAsync(customer, ct);
        return customer;
    }
}
```

### Creating Subscriptions

```csharp
public async Task<Subscription> CreateSubscriptionAsync(
    Guid tenantId,
    string priceId,
    int quantity = 1,
    bool startTrial = false,
    CancellationToken ct = default)
{
    var customer = await repository.GetCustomerAsync(tenantId, ct)
        ?? throw new InvalidOperationException("Customer not found");

    var options = new SubscriptionCreateOptions
    {
        Customer = customer.StripeCustomerId,
        Items =
        [
            new SubscriptionItemOptions
            {
                Price = priceId,
                Quantity = quantity
            }
        ],
        PaymentBehavior = "default_incomplete",
        PaymentSettings = new SubscriptionPaymentSettingsOptions
        {
            SaveDefaultPaymentMethod = "on_subscription"
        },
        Metadata = new Dictionary<string, string>
        {
            ["tenant_id"] = tenantId.ToString()
        }
    };

    if (startTrial)
    {
        options.TrialPeriodDays = 14;
    }

    var stripeSub = await subscriptionService.CreateAsync(options, cancellationToken: ct);

    return MapToSubscription(tenantId, stripeSub);
}
```

## Webhook Processing

### Webhook Handler

```csharp
[ApiController]
[Route("webhooks/stripe")]
public class StripeWebhookController(
    IBillingWebhookHandler handler,
    IConfiguration config,
    ILogger<StripeWebhookController> logger) : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> HandleWebhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var signature = Request.Headers["Stripe-Signature"].ToString();
        var webhookSecret = config["Stripe:WebhookSecret"];

        try
        {
            var stripeEvent = EventUtility.ConstructEvent(
                json,
                signature,
                webhookSecret);

            logger.LogInformation(
                "Processing Stripe webhook: {EventType} {EventId}",
                stripeEvent.Type,
                stripeEvent.Id);

            await handler.HandleEventAsync(stripeEvent);

            return Ok();
        }
        catch (StripeException ex)
        {
            logger.LogError(ex, "Stripe webhook signature verification failed");
            return BadRequest();
        }
    }
}
```

### Event Handler

```csharp
public sealed class BillingWebhookHandler(
    IBillingRepository repository,
    IEntitlementService entitlements,
    ILogger<BillingWebhookHandler> logger) : IBillingWebhookHandler
{
    public async Task HandleEventAsync(Event stripeEvent)
    {
        switch (stripeEvent.Type)
        {
            case Events.CustomerSubscriptionCreated:
            case Events.CustomerSubscriptionUpdated:
                await HandleSubscriptionChangeAsync(
                    (Stripe.Subscription)stripeEvent.Data.Object);
                break;

            case Events.CustomerSubscriptionDeleted:
                await HandleSubscriptionDeletedAsync(
                    (Stripe.Subscription)stripeEvent.Data.Object);
                break;

            case Events.InvoicePaid:
                await HandleInvoicePaidAsync(
                    (Invoice)stripeEvent.Data.Object);
                break;

            case Events.InvoicePaymentFailed:
                await HandlePaymentFailedAsync(
                    (Invoice)stripeEvent.Data.Object);
                break;

            case Events.CustomerSubscriptionTrialWillEnd:
                await HandleTrialEndingAsync(
                    (Stripe.Subscription)stripeEvent.Data.Object);
                break;

            default:
                logger.LogDebug("Unhandled event type: {Type}", stripeEvent.Type);
                break;
        }
    }

    private async Task HandleSubscriptionChangeAsync(Stripe.Subscription stripeSub)
    {
        var tenantId = Guid.Parse(stripeSub.Metadata["tenant_id"]);

        var subscription = new Subscription
        {
            TenantId = tenantId,
            StripeSubscriptionId = stripeSub.Id,
            StripePriceId = stripeSub.Items.Data[0].Price.Id,
            Status = ParseStatus(stripeSub.Status),
            CurrentPeriodStart = stripeSub.CurrentPeriodStart,
            CurrentPeriodEnd = stripeSub.CurrentPeriodEnd,
            CancelAt = stripeSub.CancelAt,
            TrialEnd = stripeSub.TrialEnd,
            Quantity = (int)stripeSub.Items.Data[0].Quantity
        };

        await repository.SaveSubscriptionAsync(subscription);

        // Update entitlements based on new subscription state
        await entitlements.SyncEntitlementsAsync(tenantId);
    }
}
```

### Critical Webhooks

| Event | Action Required |
| ----- | --------------- |
| `customer.subscription.created` | Provision tenant, set entitlements |
| `customer.subscription.updated` | Update entitlements (plan change) |
| `customer.subscription.deleted` | Revoke access, cleanup |
| `invoice.paid` | Confirm payment, extend access |
| `invoice.payment_failed` | Notify, start dunning |
| `customer.subscription.trial_will_end` | Notify user (3 days before) |

## Payment Lifecycle

### Subscription States

```text
Lifecycle Flow:
                                   +-------------------+
                                   |                   |
                                   v                   |
+----------+    +----------+    +--------+    +-------------+
| Trialing |--->| Active   |--->| PastDue|--->| Canceled    |
+----------+    +----------+    +--------+    +-------------+
     |              |               |               ^
     |              v               v               |
     |         +---------+    +---------+           |
     +-------->| Canceled|    | Unpaid  |-----------+
               +---------+    +---------+

Key Transitions:
- Trialing -> Active: First successful payment
- Active -> PastDue: Payment failed (retry in progress)
- PastDue -> Active: Payment succeeded on retry
- PastDue -> Canceled: All retries exhausted
- Any -> Canceled: User or admin cancellation
```

### Dunning (Failed Payment Recovery)

```csharp
public sealed class DunningService(
    IEmailService email,
    IBillingRepository repository)
{
    public async Task HandlePaymentFailedAsync(
        Guid tenantId,
        string invoiceId,
        int attemptCount,
        DateTimeOffset nextRetry)
    {
        var customer = await repository.GetCustomerAsync(tenantId);

        // Progressive messaging based on attempt
        var message = attemptCount switch
        {
            1 => "We couldn't process your payment. We'll retry automatically.",
            2 => "Second payment attempt failed. Please update your payment method.",
            3 => "Final payment attempt upcoming. Update your payment to avoid service interruption.",
            _ => "Your subscription is at risk. Immediate action required."
        };

        await email.SendAsync(new PaymentFailedEmail
        {
            To = customer.Email,
            Subject = $"Payment Issue - Attempt {attemptCount}",
            Message = message,
            UpdatePaymentUrl = GenerateUpdatePaymentUrl(tenantId),
            NextRetryDate = nextRetry
        });

        // Log for support visibility
        await repository.LogDunningEventAsync(tenantId, invoiceId, attemptCount);
    }
}
```

## Usage-Based Billing

### Reporting Usage to Stripe

```csharp
public sealed class UsageReporter(
    UsageRecordService usageRecordService,
    IUsageMeteringService metering,
    IBillingRepository repository)
{
    public async Task ReportDailyUsageAsync(DateOnly date, CancellationToken ct)
    {
        var subscriptions = await repository.GetMeteredSubscriptionsAsync(ct);

        foreach (var sub in subscriptions)
        {
            var usage = await metering.GetDailyUsageAsync(
                sub.TenantId,
                date,
                ct);

            foreach (var metric in usage)
            {
                var subscriptionItemId = sub.GetSubscriptionItemId(metric.MetricName);

                await usageRecordService.CreateAsync(new UsageRecordCreateOptions
                {
                    SubscriptionItem = subscriptionItemId,
                    Quantity = (long)metric.TotalQuantity,
                    Timestamp = date.ToDateTime(TimeOnly.MinValue),
                    Action = "set"  // "set" replaces, "increment" adds
                }, cancellationToken: ct);
            }
        }
    }
}
```

## Checkout Flow

### Stripe Checkout Session

```csharp
public async Task<string> CreateCheckoutSessionAsync(
    Guid tenantId,
    string priceId,
    string successUrl,
    string cancelUrl,
    CancellationToken ct = default)
{
    var customer = await repository.GetCustomerAsync(tenantId, ct);

    var sessionService = new SessionService();
    var session = await sessionService.CreateAsync(new SessionCreateOptions
    {
        Customer = customer?.StripeCustomerId,
        CustomerEmail = customer?.Email,
        Mode = "subscription",
        LineItems =
        [
            new SessionLineItemOptions
            {
                Price = priceId,
                Quantity = 1
            }
        ],
        SuccessUrl = successUrl + "?session_id={CHECKOUT_SESSION_ID}",
        CancelUrl = cancelUrl,
        SubscriptionData = new SessionSubscriptionDataOptions
        {
            Metadata = new Dictionary<string, string>
            {
                ["tenant_id"] = tenantId.ToString()
            }
        },
        AllowPromotionCodes = true
    }, cancellationToken: ct);

    return session.Url;
}
```

### Customer Portal

```csharp
public async Task<string> CreatePortalSessionAsync(
    Guid tenantId,
    string returnUrl,
    CancellationToken ct = default)
{
    var customer = await repository.GetCustomerAsync(tenantId, ct)
        ?? throw new InvalidOperationException("Customer not found");

    var portalService = new Stripe.BillingPortal.SessionService();
    var session = await portalService.CreateAsync(new SessionCreateOptions
    {
        Customer = customer.StripeCustomerId,
        ReturnUrl = returnUrl
    }, cancellationToken: ct);

    return session.Url;
}
```

## Best Practices

### Idempotency

```csharp
// Store processed webhook event IDs
public async Task<bool> TryProcessWebhookAsync(string eventId)
{
    // Check if already processed (idempotency)
    if (await repository.WebhookAlreadyProcessedAsync(eventId))
    {
        logger.LogInformation("Webhook {EventId} already processed", eventId);
        return false;
    }

    // Mark as processing (with TTL for cleanup)
    await repository.MarkWebhookProcessingAsync(eventId);
    return true;
}
```

### Webhook Reliability

```text
Recommendations:
1. Return 200 quickly (process async if needed)
2. Store raw event for replay/debugging
3. Implement idempotency (track event IDs)
4. Handle out-of-order events gracefully
5. Set up webhook endpoint monitoring
6. Use Stripe CLI for local development
```

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
| ------------ | ------- | -------- |
| Sync API calls only | Miss events, state drift | Use webhooks as source of truth |
| No idempotency | Duplicate processing | Track event IDs |
| Blocking webhook handlers | Timeouts, retries | Process async, return 200 fast |
| Hardcoded prices | Painful to change | Use Stripe price IDs, sync from Stripe |
| No retry handling | Lost events | Implement retry with backoff |

## References

Reference documentation for detailed implementation patterns (load on demand):

- `usage-metering` skill - Consumption tracking for usage-based billing
- `subscription-models` skill - Pricing tier design and feature bundling
- `entitlements-management` skill - Feature gating based on subscription

For Stripe-specific patterns, use MCP research:

```text
perplexity: "Stripe .NET SDK billing integration patterns"
context7: "Stripe.net" (for SDK documentation)
```

## Related Skills

- `subscription-models` - Pricing tier design
- `usage-metering` - Consumption tracking for usage-based billing
- `entitlements-management` - Feature gating based on subscription

## MCP Research

For current billing integration patterns:

```text
perplexity: "Stripe .NET SDK 2024" "SaaS billing integration patterns"
context7: "Stripe.net" (for SDK documentation)
microsoft-learn: "Azure SaaS billing" "subscription management patterns"
```

---

**Last Updated:** 2025-12-29
