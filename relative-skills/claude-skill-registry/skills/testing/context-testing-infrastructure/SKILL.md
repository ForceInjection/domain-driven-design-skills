---
name: context-testing-infrastructure
description: |
  Tiered testing strategy (UI mock, auth stub, full-stack), fixtures, mocks, and test configuration.
  Handles test setup, Playwright E2E tests, pytest backend tests, mocking strategies, and CI test configuration.
  Use when working with tests, test setup, mocking strategies, or CI test configuration,
  or when user mentions test patterns, auth stub, fixture loaders, Playwright tests, test failures,
  tiered testing, UI mock, E2E tests, pytest, vitest, or debugging test issues.
tags: [testing, qa, infrastructure]
---

# Testing Infrastructure

Navigate tiered testing strategy (ui-mock, auth-stub, full-stack), fixtures, and configs.

## Overview

Three-tier testing strategy for speed/isolation balance. See `docs/testing/STRATEGY.md`.

## E2E Test Tiers

### Tier 1: UI Mock
- **Location**: `frontend/e2e-tiers/tier-ui-mock/`
- **Speed**: <5s
- **Purpose**: UI-only, no backend

### Tier 2: Auth Stub
- **Location**: `frontend/e2e-tiers/tier-auth-stub/`
- **Speed**: <30s
- **Purpose**: Real frontend + stubbed auth

### Tier 3: Full Stack
- **Location**: `frontend/e2e-tiers/tier-full-stack/`
- **Speed**: ~60s+
- **Purpose**: Complete integration

## E2E Tests

- `frontend/e2e/*.spec.ts` - Main E2E tests
- `frontend/e2e-smoke/*.spec.ts` - Smoke tests

## Backend Tests

- `backend/tests/unit/` - Unit tests
- `backend/tests/integration/` - Integration tests
- `backend/tests/manual/` - Manual tests
- `backend/tests/conftest.py` - Pytest fixtures
- `backend/tests/fixtures/` - Mock fixtures

## Test Utilities

- `scripts/lib/db_test_utils.py` - Database utilities
- `scripts/test_*.py` - Test helpers
- `scripts/quick_fix_test_data.py` - Quick data generation
- `scripts/generate-dev-data.ts` - Dev data seeding
- `frontend/src/test-utils/` - Frontend test utilities

## Smoke Tests

- `backend/smoke_endpoints.py` - Backend health checks
- `frontend/e2e-smoke/` - Frontend smoke tests

## Configuration

- `frontend/playwright*.config.ts` - Playwright configs
- `pytest.ini` - Pytest configuration
- `frontend/vitest.config.ts` - Vitest config (if used)

## Documentation

- **Internal**: `docs/testing/STRATEGY.md`

## Related Areas

- See `context-plaid-integration` for Plaid test patterns
- See `context-clerk-integration` for auth stub patterns
- See `context-infrastructure` for CI integration
