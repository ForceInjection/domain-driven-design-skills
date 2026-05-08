---
name: gapless-crypto-clickhouse-onboarding
description: Onboard company employees (Claude Code CLI users) to use gapless-crypto-clickhouse package with ClickHouse Cloud credentials. Use when company employee needs to set up ClickHouse Cloud access, mentions first-time setup, credential configuration, connection testing, or troubleshooting ClickHouse Cloud connections.
---

# Company Employee Onboarding: gapless-crypto-clickhouse + ClickHouse Cloud

## Overview

This skill provides step-by-step workflow for onboarding 3-10 company employees (Claude Code CLI users) to use `gapless-crypto-clickhouse` package with ClickHouse Cloud credentials.

**Target**: <15 minute onboarding from zero to first successful query

**Access Model**: Binary access (admins have full ClickHouse Cloud access, non-admins use file-based API only)

**Credential Methods**: Doppler (recommended) OR local `.env` file (fallback)

## When to Use This Skill

Trigger this skill when:
- Company employee needs first-time ClickHouse Cloud setup
- User mentions "onboarding", "company credentials", "ClickHouse Cloud access"
- User asks "how do I connect to ClickHouse Cloud?"
- User encounters ClickHouse connection errors (guide through troubleshooting)

## Onboarding Workflow

### Step 1: Verify Prerequisites (2 minutes)

**Check installed**:
- Python 3.12+ (`python --version`)
- `gapless-crypto-clickhouse` package (`pip show gapless-crypto-clickhouse`)

**Install if missing**:
```bash
pip install gapless-crypto-clickhouse
```

**Verify installation**:
```python
python -c "import gapless_crypto_clickhouse; print(gapless_crypto_clickhouse.__version__)"
# Expected: 6.0.0 or higher
```

### Step 2: Choose Credential Access Method (1 minute)

**Option A: Doppler (Recommended)**
- Centralized credential management
- No local credential storage
- Requires Doppler CLI access to `aws-credentials/prd` project

**Option B: Local .env File (Fallback)**
- Local credential file
- Simpler for one-off scripts
- Requires manual credential entry

**Guide user to choose**:
- If user has Doppler access → Use Option A
- If user prefers local development OR doesn't have Doppler → Use Option B

### Step 3A: Configure Doppler Access (If Option A)

**Verify Doppler access**:
```bash
doppler secrets --project aws-credentials --config prd --only-names | grep CLICKHOUSE
```

**Expected output** (8 secrets):
```
CLICKHOUSE_CLOUD_KEY_ID
CLICKHOUSE_CLOUD_KEY_SECRET
CLICKHOUSE_CLOUD_ORG_ID
CLICKHOUSE_CLOUD_SERVICE_ID
CLICKHOUSE_HOST
CLICKHOUSE_PORT
CLICKHOUSE_USER
CLICKHOUSE_PASSWORD
```

**If missing** → User needs Doppler access from DevOps team

**Reference**: [`references/doppler-setup.md`](./references/doppler-setup.md)

### Step 3B: Configure Local .env File (If Option B)

**Copy Cloud template**:
```bash
cp .env.cloud .env
```

**Edit .env with credentials**:
- Open `.env` in editor
- Fill in `CLICKHOUSE_PASSWORD` (from Doppler or ClickHouse Cloud console)
- Ensure `CLICKHOUSE_SECURE=true`
- Verify `CLICKHOUSE_HOST` ends with `.aws.clickhouse.cloud`

**Security check**:
```bash
grep "^\.env$" .gitignore
```
Expected: `.env` is in `.gitignore` (NEVER commit credentials)

**Reference**: [`references/env-setup.md`](./references/env-setup.md)

### Step 4: Test Connection (2 minutes)

**Option A (Doppler)**:
```bash
doppler run --project aws-credentials --config prd -- python skills/gapless-crypto-clickhouse-onboarding/scripts/test_connection_cloud.py
```

**Option B (.env file)**:
```bash
python skills/gapless-crypto-clickhouse-onboarding/scripts/test_connection_cloud.py
```

**Expected output**:
```
✅ Connection successful!
   ClickHouse version: 25.8.1.8702
   User: default
   Tables visible: 150+
✅ All connection tests passed!
```

**If errors** → Guide user through troubleshooting (see Step 6)

**Test script**: [`scripts/test_connection_cloud.py`](./scripts/test_connection_cloud.py)

### Step 5: Run First Query (5 minutes)

**Simple query example** (Option A - Doppler):
```bash
doppler run --project aws-credentials --config prd -- python -c "
import gapless_crypto_clickhouse as gcch

# Query OHLCV data (auto-ingests if not present)
df = gcch.query_ohlcv('BTCUSDT', '1h', '2024-01-01', '2024-01-31')

print(f'✅ Query successful: {len(df)} rows')
print(df.head())
"
```

**Simple query example** (Option B - .env):
```bash
python -c "
from dotenv import load_dotenv
load_dotenv('.env')  # Load credentials from .env

import gapless_crypto_clickhouse as gcch

# Query OHLCV data
df = gcch.query_ohlcv('BTCUSDT', '1h', '2024-01-01', '2024-01-31')

print(f'✅ Query successful: {len(df)} rows')
print(df.head())
"
```

**Expected**: DataFrame with OHLCV data (11 columns: open_time, open, high, low, close, volume, etc.)

### Step 6: Troubleshooting Common Errors

**Error: "Connection refused"**
- **Cause**: Wrong hostname or port
- **Fix**: Verify `CLICKHOUSE_HOST` ends with `.aws.clickhouse.cloud` and `CLICKHOUSE_HTTP_PORT=8443`

**Error: "SSL/TLS error" or "certificate verify failed"**
- **Cause**: Missing `secure=True` parameter
- **Fix**: Ensure `CLICKHOUSE_SECURE=true` in environment variables
- **Note**: Package v6.0.0+ includes `secure` parameter support (ADR-0026)

**Error: "Authentication failed" or "Invalid password"**
- **Cause**: Wrong password or expired credentials
- **Fix**: Reset password in ClickHouse Cloud console → Update Doppler/`.env`

**Error: "Timeout" (>10 seconds)**
- **Cause**: Service resuming from idle state (15-minute idle scaling)
- **Fix**: Retry in 30 seconds (service should be awake)

**Error: "Table 'gapless_crypto.klines' doesn't exist"**
- **Cause**: Database schema not yet created on Cloud service
- **Fix**: Expected for new service, `query_ohlcv()` will auto-create schema

**Complete troubleshooting guide**: [`references/troubleshooting.md`](./references/troubleshooting.md)

## Binary Access Model

**Admins** (3-10 users with ClickHouse Cloud credentials):
- Full access to `query_ohlcv()` and database features
- Use this onboarding skill for setup

**Non-admins** (no ClickHouse Cloud credentials):
- Use file-based API only (`fetch_data()`, `download()`)
- No ClickHouse connection needed
- Package still useful for Binance data collection

## Resources

### scripts/
- **test_connection_cloud.py**: Connection validator with diagnostics (Doppler + .env support)

### references/
- **troubleshooting.md**: Common errors + actionable fixes
- **doppler-setup.md**: Doppler CLI configuration workflow
- **env-setup.md**: Local `.env` file setup (fallback method)

## Next Steps After Onboarding

1. **Explore examples**: Review `/examples/`
2. **Read API docs**: `/docs/guides/python-api.md`
3. **Review architecture**: `/docs/architecture/OVERVIEW.md`
4. **Join support channel**: #data-engineering Slack

## Service Details

**ClickHouse Cloud Service**:
- **Service ID**: `a3163f31-21f4-4e22-844e-ef3fbc26ace2`
- **Region**: us-west-2 (AWS)
- **Console**: https://clickhouse.cloud/services/a3163f31-21f4-4e22-844e-ef3fbc26ace2
- **Idle scaling**: 15 minutes (first query may take 10s to resume)
- **Credentials**: Stored in Doppler (`aws-credentials/prd`) + 1Password (Engineering vault)

## Related Skills

- [`clickhouse-cloud-service-setup`](../clickhouse-cloud-service-setup/SKILL.md): Infrastructure-focused (API-driven service discovery)
- [`clickhouse-cloud-credentials`](../clickhouse-cloud-credentials/SKILL.md): Credential storage (Doppler + 1Password)
- [`clickhouse-cloud-connection`](../clickhouse-cloud-connection/SKILL.md): Connection validation + troubleshooting
