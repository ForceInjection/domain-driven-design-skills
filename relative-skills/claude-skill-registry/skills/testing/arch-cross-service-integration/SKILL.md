---
name: cross-service-integration
description: Quick decision guide for cross-service communication patterns. For implementation details, use the backend-message-bus skill.
allowed-tools: Read, Grep, Glob
---

# Cross-Service Integration Decision Guide

> **For implementation details, activate the `backend-message-bus` skill.**

## Quick Decision Matrix

| Scenario | Pattern | Skill to Use |
|----------|---------|--------------|
| Sync entity data to other services | Entity Event Bus | `backend-message-bus` |
| Need real-time data, no local copy | Direct API Call | N/A (simple HttpClient) |
| Initial data population | Full Sync Job | `backend-background-job` |
| Cross-service database access | :x: NEVER DO THIS | - |

## When to Use Message Bus

✅ **Use Entity Event Bus when:**
- Source service owns the data
- Target services need local copies
- Eventual consistency is acceptable
- Decoupling is important

❌ **Don't use when:**
- You need real-time, up-to-the-second data
- Data is only needed occasionally (use API call)
- You're accessing data within the same service

## Key Principles

1. **Data Ownership**: Each entity has ONE owner service
2. **No Shared DB**: Never access another service's database directly
3. **Event-Driven**: Use message bus for cross-service sync
4. **Idempotency**: Consumers must handle duplicate messages

## Implementation Steps

1. Define data ownership
2. Create message in `YourApp.Shared/CrossServiceMessages/`
3. Implement producer in source service
4. Implement consumer in target service
5. Handle dependencies and race conditions

→ **See `backend-message-bus` skill for detailed patterns and code examples.**
