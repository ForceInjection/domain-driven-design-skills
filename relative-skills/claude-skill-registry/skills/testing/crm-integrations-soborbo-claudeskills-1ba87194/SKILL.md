---
name: crm-integrations
description: CRM and automation integration patterns for lead gen sites. Webhooks, Zapier, Make, HubSpot, Pipedrive. Use for connecting forms to business systems.
---

# CRM Integrations Skill

## Purpose

Connects lead generation forms to CRM systems and automation tools. Ensures no leads are lost through robust backup strategies and async processing.

## Core Rules

1. **Always have backup** — If CRM fails, data must be saved elsewhere (Google Sheets)
2. **Async processing** — Don't block form submission on CRM integration
3. **Retry failed sends** — Queue and retry integration failures with exponential backoff
4. **Log everything** — Track all integration attempts for debugging and compliance
5. **Validate before send** — Ensure data format matches CRM requirements using Zod
6. **GDPR compliance** — Check consent before sending PII to third parties
7. **4xx = don't retry** — Client errors are not retryable, 5xx errors are
8. **Hash sensitive data** — IP addresses should be hashed for privacy
9. **Track source** — Always include UTM parameters and referrer for attribution
10. **Timeout protection** — Set reasonable timeouts (10s) to prevent hanging requests

## Integration Flow

```
Form → Validate → Save to Sheets → Queue CRM (async) → Thank You → [Background] CRM with retry
```

## Key Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `HUBSPOT_ACCESS_TOKEN` | HubSpot API auth | `pat-xxx` |
| `PIPEDRIVE_API_TOKEN` | Pipedrive API auth | `xxx` |
| `ZAPIER_WEBHOOK_URL` | Zapier webhook | `https://hooks.zapier.com/...` |
| `CRM_WEBHOOK_URL` | Generic CRM endpoint | `https://your-crm.com/webhook` |

## Error Handling Strategy

| Status Code | Action | Retryable |
|-------------|--------|-----------|
| 2xx | Success | No |
| 4xx | Client error, log and skip | No |
| 5xx | Server error, retry with backoff | Yes |
| Timeout | Network issue, retry | Yes |

## References

Detailed implementation code and examples:

- **[Webhook Implementation](references/webhooks.md)** — Generic webhook function, payload standard, architecture
- **[HubSpot Integration](references/hubspot.md)** — HubSpot contact creation code
- **[Pipedrive Integration](references/pipedrive.md)** — Pipedrive person and deal creation
- **[Automation & Forms](references/automation.md)** — Zapier/Make, form handlers, failure queues

## Forbidden

- ❌ Blocking form response on CRM integration
- ❌ No backup storage for leads
- ❌ Exposing API tokens to client-side code
- ❌ Sending PII without user consent
- ❌ No retry logic for transient failures
- ❌ Ignoring failed integrations without logging
- ❌ Using GET requests for webhooks (always POST)
- ❌ Storing API tokens in version control

## Definition of Done

- [ ] Generic webhook function implemented with retry logic
- [ ] Google Sheets configured as primary backup storage
- [ ] CRM integration runs asynchronously (doesn't block form)
- [ ] Failed integrations logged to separate sheet/queue
- [ ] All environment variables properly set and documented
- [ ] GDPR consent checked before sending data to CRM
- [ ] Email notifications working (customer + internal)
- [ ] UTM parameters captured and stored with each lead
- [ ] Error handling tested for 4xx, 5xx, and timeout scenarios
- [ ] Exponential backoff implemented for retries
