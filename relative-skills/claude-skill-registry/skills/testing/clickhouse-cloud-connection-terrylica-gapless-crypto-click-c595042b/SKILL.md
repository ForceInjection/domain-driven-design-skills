---
name: clickhouse-cloud-connection
description: Test and validate ClickHouse Cloud connection using clickhouse-connect for gapless-crypto-clickhouse. Use when validating connectivity, troubleshooting connection issues, or verifying environment configuration. Includes version check and query validation.
---

# ClickHouse Cloud Connection

Validate ClickHouse Cloud connectivity and troubleshoot connection issues for gapless-crypto-clickhouse service.

## Purpose

Test connection to ClickHouse Cloud service using clickhouse-connect library with credentials from Doppler. This skill guides the workflow of:
1. Loading credentials from Doppler environment
2. Configuring clickhouse-connect client (`secure=True` for Cloud)
3. Testing connection with diagnostic queries
4. Validating service accessibility and performance

## When to Use

Use this skill when:
- **Connection validation**: Verifying ClickHouse Cloud service is accessible
- **Troubleshooting**: Diagnosing connection errors or authentication failures
- **Environment verification**: Confirming Doppler credentials are correctly configured
- **Post-deployment testing**: Validating service after setup or credential rotation

Triggers: User mentions "test connection", "connection failed", "ClickHouse unreachable", "validate credentials"

## Prerequisites

**Required Environment Variables** (loaded from Doppler `aws-credentials/prd`):
- `CLICKHOUSE_HOST`: Service hostname (e.g., `ebmf8f35lu.us-west-2.aws.clickhouse.cloud`)
- `CLICKHOUSE_PORT`: HTTPS port (`8443`)
- `CLICKHOUSE_USER`: Database user (`default`)
- `CLICKHOUSE_PASSWORD`: Database password

**Required Library**:
```bash
# Install clickhouse-connect (if not already installed)
uv pip install clickhouse-connect
```

## Workflow

### Step 1: Load Credentials from Doppler

```bash
# Run Python with Doppler environment
doppler run --project aws-credentials --config prd -- python test_connection.py
```

**Environment Loading**: Doppler injects all `CLICKHOUSE_*` secrets as environment variables

### Step 2: Configure clickhouse-connect Client

```python
import os
import clickhouse_connect

# Load from environment (set by Doppler)
client = clickhouse_connect.get_client(
    host=os.getenv("CLICKHOUSE_HOST"),
    port=int(os.getenv("CLICKHOUSE_PORT", "8443")),
    username=os.getenv("CLICKHOUSE_USER", "default"),
    password=os.getenv("CLICKHOUSE_PASSWORD"),
    secure=True  # CRITICAL: Required for ClickHouse Cloud
)
```

**Key Configuration**:
- `secure=True`: Enforces TLS/SSL for ClickHouse Cloud (HTTPS endpoint)
- Port `8443`: HTTPS protocol (not 8123 for HTTP)
- Environment fallbacks: Defaults for port and user

### Step 3: Test Connection with Version Query

```python
# Query ClickHouse version and current user
result = client.query("SELECT version() as version, currentUser() as user")
version = result.result_rows[0][0]
current_user = result.result_rows[0][1]

print(f"✅ Connection successful!")
print(f"   ClickHouse version: {version}")
print(f"   User: {current_user}")
```

**Expected Output**:
```
✅ Connection successful!
   ClickHouse version: 25.8.1.8702
   User: default
```

### Step 4: Validate Service Accessibility

```python
# Test query: Count tables in system database
result = client.query("SELECT count() FROM system.tables")
table_count = result.result_rows[0][0]
print(f"   Tables visible: {table_count}")
```

**Success Criteria**: Query executes without errors, returns numeric count

### Step 5: Test Data Query Performance (Optional)

```python
# Test query: Fetch first row from gapless_crypto.klines (if exists)
try:
    result = client.query("SELECT * FROM gapless_crypto.klines LIMIT 1")
    print(f"   Data accessible: ✅ (gapless_crypto.klines)")
except Exception as e:
    print(f"   Data accessible: ⚠️ (table not yet created)")
```

## Example Connection Test Script

**See**: [`references/connection-test.py`](./references/connection-test.py) for complete executable example

**Quick Test** (one-liner):
```bash
doppler run --project aws-credentials --config prd -- python -c "
import os, clickhouse_connect
client = clickhouse_connect.get_client(
    host=os.getenv('CLICKHOUSE_HOST'),
    port=int(os.getenv('CLICKHOUSE_PORT')),
    username=os.getenv('CLICKHOUSE_USER'),
    password=os.getenv('CLICKHOUSE_PASSWORD'),
    secure=True
)
print('✅ Connected:', client.query('SELECT version()').result_rows[0][0])
"
```

## Success Criteria

- ✅ Connection established without authentication errors
- ✅ Version query returns ClickHouse version 25.8+
- ✅ User query confirms `default` user
- ✅ Table count query executes successfully
- ✅ Service response time <1 second (idle service may take 5-10s to resume)

## Troubleshooting

**Issue**: "Connection refused" or "Timeout"
- **Check**: Verify `CLICKHOUSE_HOST` is correct (should be `*.aws.clickhouse.cloud`)
- **Check**: Port is `8443` (HTTPS), not `8123` (HTTP)
- **Check**: Service state is `running` (may be paused due to idle scaling)
- **Action**: Check ClickHouse Cloud console for service status

**Issue**: "Authentication failed"
- **Check**: Verify `CLICKHOUSE_PASSWORD` in Doppler matches console password
- **Action**: Reset password in ClickHouse Cloud console → Settings → Reset Password
- **Verify**: Store new password in Doppler and 1Password

**Issue**: "SSL/TLS error"
- **Check**: `secure=True` parameter is set in `get_client()`
- **Verify**: ClickHouse Cloud requires TLS, cannot connect without `secure=True`

**Issue**: "Query slow (>10 seconds)"
- **Check**: Service may be resuming from idle state (first query after 15min idle)
- **Expected**: Subsequent queries should be fast (<1s)
- **Action**: Wait for service to fully resume, retry query

**Issue**: "Table not found (gapless_crypto.klines)"
- **Status**: Table not yet created (expected for new service)
- **Action**: Run schema migration from local Docker to ClickHouse Cloud

## Connection Parameters Reference

| Parameter | Value | Description |
|-----------|-------|-------------|
| `host` | `ebmf8f35lu.us-west-2.aws.clickhouse.cloud` | Service hostname (us-west-2) |
| `port` | `8443` | HTTPS port (not 8123) |
| `username` | `default` | Default database user |
| `password` | (from Doppler) | Database password |
| `secure` | `True` | **Required** for ClickHouse Cloud (TLS/SSL) |

## Service Details

- **Service ID**: `a3163f31-21f4-4e22-844e-ef3fbc26ace2`
- **Organization**: "TE's Organization" (`2404d339-6921-4f1c-bf80-b07d5e23b91a`)
- **Region**: us-west-2 (AWS)
- **Idle Scaling**: Enabled (15 minutes)
- **Expected latency**: <100ms (active), 5-10s (resuming from idle)

## References

- **Connection Test Script**: [`references/connection-test.py`](./references/connection-test.py)
- **clickhouse-connect Documentation**: https://clickhouse.com/docs/en/integrations/python
- **ClickHouse Cloud Console**: https://clickhouse.cloud/services/a3163f31-21f4-4e22-844e-ef3fbc26ace2
- **Doppler Dashboard**: https://dashboard.doppler.com/workplace/13e9e4203ede563b1d37/projects/aws-credentials

## Next Steps

After successful connection validation:
1. **Schema Migration**: Import schema from local Docker to ClickHouse Cloud
2. **Data Ingestion**: Configure gapless-crypto-clickhouse package to use Cloud endpoints
3. **Production Testing**: Validate data collection and query performance
