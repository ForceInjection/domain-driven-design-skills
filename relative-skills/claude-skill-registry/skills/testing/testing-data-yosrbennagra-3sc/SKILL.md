---
name: testing-data
description: Build integration tests for data access in the widget host app. Use when setting up test databases, running EF Core migrations for tests, or validating repository behavior end-to-end.
---

# Testing Data

## Overview

Validate data access behavior with integration tests against a real or ephemeral database.

## Core areas

- Test database orchestration
- Migrations and schema setup
- Repository integration tests

## Definition of done (DoD)

- Each test gets isolated DB instance (in-memory or temp file)
- Migrations applied automatically before tests run
- Test data seeded via explicit setup, not global fixtures
- No test depends on another test's data
- Tests clean up connections/resources in Dispose
- Repository tests cover CRUD + edge cases (not found, duplicates)

## Workflow

1. Provision a test database per test run.
2. Apply migrations before tests.
3. Seed minimal data for each scenario.
4. Tear down and clean after tests.

## Guidance

- Prefer isolated databases per test suite.
- Avoid shared mutable state across tests.
- Keep tests slower but reliable.

## References

- `references/test-db.md` for DB setup options.
- `references/migrations.md` for test migration usage.
