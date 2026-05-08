---
name: amplitude-user-lookup
description: Amplitude user behavior queries
---

# Amplitude User Lookup

Query Amplitude user data via REST API using Device ID or User ID.

## Prerequisites

Set environment variables:
```bash
export AMPLITUDE_API_KEY="your-api-key"
export AMPLITUDE_SECRET_KEY="your-secret-key"
export AMPLITUDE_REGION="us"  # or "eu" for EU data residency
```

Get keys from: Amplitude Dashboard > Settings > Projects > General

## Quick Start

### 1. Search User (Device ID -> Amplitude ID)

```bash
python scripts/user_search.py "DEVICE-ID-HERE"
```

### 2. Get User Activity

```bash
python scripts/user_activity.py AMPLITUDE_ID --limit 50
```

### Combined Workflow

```bash
# Get Amplitude ID first
AMP_ID=$(python scripts/user_search.py "DEVICE-ID" --json | jq -r '.matches[0].amplitude_id')

# Then get activity
python scripts/user_activity.py $AMP_ID --limit 100
```

## Script Options

| Script | Options |
|--------|---------|
| `user_search.py` | `--json` for raw JSON output |
| `user_activity.py` | `--limit N`, `--offset N`, `--direction [latest\|earliest]`, `--json` |

## Rate Limits

- User Search/Activity: **360 requests/hour**
- Concurrent requests: **5 max**

## References

- **[API Reference](references/api-reference.md)**: curl examples, response schemas, error codes
- **[Scripts Guide](references/scripts-guide.md)**: detailed script usage and examples
