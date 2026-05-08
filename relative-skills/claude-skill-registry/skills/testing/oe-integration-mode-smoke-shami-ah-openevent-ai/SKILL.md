---
name: oe-integration-mode-smoke
description: Smoke-test “integration mode” safely (Supabase + optional live OpenAI integration tests). Use when debugging prod-only differences, validating Supabase connectivity, or running backend/tests_integration without turning every local run into a deployment.
---

# oe-integration-mode-smoke

## Supabase connectivity (fastest signal)

1. Export required env vars:
   - `export OE_INTEGRATION_MODE=supabase`
   - `export OE_SUPABASE_URL=...`
   - `export OE_SUPABASE_KEY=...`
   - `export OE_TEAM_ID=...`
   - `export OE_SYSTEM_USER_ID=...`
   - (optional) `export OE_EMAIL_ACCOUNT_ID=...`

2. Run the built-in connection validator:
   - `python -m backend.workflows.io.integration.test_connection`

## Live OpenAI integration lane (only when explicitly needed)

1. Export integration test env vars:
   - `export AGENT_MODE=openai`
   - `export OPENAI_TEST_MODE=1`
   - `export OPENAI_API_KEY=...`

2. Run the integration tests:
   - `pytest backend/tests_integration/ -v`

## If a test fails

- Prefer fixing the contract in the integration adapter layer first:
  - `backend/workflows/io/integration/adapter.py`
  - `backend/workflows/io/integration/field_mapping.py`
  - `backend/workflows/io/integration/status_utils.py`
