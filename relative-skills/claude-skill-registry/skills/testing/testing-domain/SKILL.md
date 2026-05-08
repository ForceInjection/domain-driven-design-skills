---
name: testing-domain
description: Write domain and unit tests for the widget host app. Use when testing entities, value objects, invariants, domain services, and application logic with deterministic fixtures.
---

# Testing Domain

## Overview

Validate domain rules and invariants without UI or infrastructure dependencies.

## Focus areas

- Entity and value object behavior
- Aggregate invariants
- Domain services
- Application use cases (when pure)

## Definition of done (DoD)

- New domain logic has corresponding unit tests
- Tests cover happy path + at least one edge/error case
- Tests are deterministic (no random, no DateTime.Now)
- Tests run in under 1 second each
- No infrastructure/UI dependencies in domain tests

## Workflow

1. Build fixtures for domain objects.
2. Test invariants and edge cases.
3. Keep tests fast and deterministic.
4. Avoid infrastructure dependencies.

## Guidance

- Use builders/factories to reduce test setup noise.
- Prefer explicit assertions over snapshots.
- Name tests after the rule being validated.

## References

- `references/fixtures.md` for fixture patterns.
- `references/invariant-tests.md` for invariant coverage.
