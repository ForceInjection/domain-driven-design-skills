---
name: contract-test-design
description: Design consumer-driven contract testing strategies using Pact, verify provider contracts, and manage API evolution with contract-first approaches.
allowed-tools: Read, Write, Glob, Grep, Task, WebSearch, WebFetch
---

# Contract Test Design

## When to Use This Skill

Use this skill when:

- **Contract Test Design tasks** - Working on consumer-driven contract testing strategies using Pact
- **Planning or design** - Need guidance on contract testing approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Contract testing verifies that services communicate correctly by testing the contract (API agreement) between a consumer and provider. Consumer-driven contracts (CDC) ensure providers don't break their consumers.

---

## Contract Testing vs Other Test Types

| Aspect | E2E Tests | Integration Tests | Contract Tests |
|--------|-----------|-------------------|----------------|
| Scope | Full system | Component + deps | Consumer-provider |
| Speed | Slow (minutes) | Medium (seconds) | Fast (ms) |
| Reliability | Often flaky | Moderate | Very stable |
| Deployment coupling | High | Medium | Low (async) |
| Failure localization | Poor | Moderate | Excellent |
| Maintenance | High | Medium | Low |

---

## Consumer-Driven Contract Flow

```text
┌─────────────────────────────────────────────────────────────┐
│                    CONSUMER SIDE                            │
│                                                             │
│  1. Consumer writes test   2. Test generates contract       │
│     ┌──────────────┐          ┌──────────────┐              │
│     │ Consumer     │          │   Contract   │              │
│     │ Test         │  ─────►  │   (JSON)     │              │
│     └──────────────┘          └──────────────┘              │
│                                      │                      │
└──────────────────────────────────────┼──────────────────────┘
                                       │
                                       ▼ Publish to Broker
                              ┌──────────────────┐
                              │  Contract Broker │
                              │  (Pact Broker)   │
                              └────────┬─────────┘
                                       │
┌──────────────────────────────────────┼──────────────────────┐
│                    PROVIDER SIDE     │                      │
│                                      ▼                      │
│  3. Provider verifies contract                              │
│     ┌──────────────┐          ┌──────────────┐              │
│     │  Provider    │  ◄─────  │   Contract   │              │
│     │  Verification│          │   (JSON)     │              │
│     └──────────────┘          └──────────────┘              │
│            │                                                │
│            ▼                                                │
│  4. Provider tests pass = Contract honored                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Reference: Breaking Changes

| Change Type | Breaking? | Action |
|-------------|-----------|--------|
| Remove field | Yes | Block deployment |
| Change field type | Yes | Block deployment |
| Add required field | Yes | Block deployment |
| Add optional field | No | Allow |
| Add new endpoint | No | Allow |

---

## Tooling Selection

| Purpose | Tool | Rationale |
|---------|------|-----------|
| Contract Framework | PactNet | .NET native, mature |
| Broker | Pact Broker | Standard, free tier |
| Async Contracts | Pact Message | Same ecosystem |
| Schema Validation | OpenAPI | Industry standard |

---

## References

| Reference | Content | When to Load |
| --- | --- | --- |
| [strategy-template.md](references/strategy-template.md) | Contract testing strategy template, service maps, workflows | Planning contract testing strategy |
| [pact-dotnet-implementation.md](references/pact-dotnet-implementation.md) | Consumer tests, provider verification, provider states | Implementing Pact in .NET |
| [message-contracts.md](references/message-contracts.md) | Async message/event contract testing | Testing event-driven architectures |
| [matchers-cicd.md](references/matchers-cicd.md) | Pact matchers, breaking change detection, CI/CD pipelines | Matcher syntax, CI/CD integration |

---

## Integration Points

**Inputs from**:

- API specifications → Contract definitions
- Service architecture → Consumer-provider map
- `test-strategy-planning` skill → Contract test scope

**Outputs to**:

- CI/CD pipeline → Contract verification gates
- API governance → Breaking change detection
- `api-design-fundamentals` skill → Contract-first design

---

## Test Scenarios

### Scenario 1: Planning contract testing strategy

**Query:** "Help me design a contract testing strategy for our microservices"

**Expected:** Skill activates, provides strategy template, guides through service mapping

### Scenario 2: Implementing Pact tests

**Query:** "Show me how to write Pact consumer tests in .NET"

**Expected:** Skill activates, loads pact-dotnet-implementation.md reference, provides code examples

### Scenario 3: CI/CD integration

**Query:** "How do I integrate contract testing into our GitHub Actions pipeline?"

**Expected:** Skill activates, loads matchers-cicd.md reference, provides pipeline examples

---

**Last Updated:** 2025-12-28

## Version History

- **v1.1.0** (2025-12-28): Refactored to progressive disclosure - extracted implementation to references/
- **v1.0.0** (2025-12-26): Initial release
