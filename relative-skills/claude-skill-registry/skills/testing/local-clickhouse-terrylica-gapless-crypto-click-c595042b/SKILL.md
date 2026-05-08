---
name: local-clickhouse
description: Install, configure, and validate local ClickHouse for gapless-crypto-clickhouse development and backtesting. Use when setting up local development environment, enabling offline mode, improving query performance for backtesting, or running E2E validation. Includes mise/Homebrew/apt installation, mode detection, connection validation, and E2E workflow scripts.
---

# Local ClickHouse

Install, configure, and validate local ClickHouse as an alternative to ClickHouse Cloud for development and backtesting (ADR-0044, ADR-0045).

## Purpose

Enable local ClickHouse deployment for:

1. **Backtesting**: 50-100x faster queries (no network round-trip)
2. **Development**: Offline work without Cloud credentials
3. **Evaluation**: Try package before Cloud commitment
4. **Cost savings**: Avoid Cloud costs during experimentation

## When to Use

Use this skill when:

- **Local development**: Setting up development environment without Cloud
- **Backtesting optimization**: Need faster query performance
- **Offline mode**: Working without network access
- **Package evaluation**: Trying gapless-crypto-clickhouse before Cloud setup

Triggers: User mentions "local ClickHouse", "install clickhouse", "backtesting setup", "offline mode", "GCCH_MODE=local"

## Prerequisites

**System Requirements**:

- macOS (Homebrew) or Linux (apt/installer)
- 2-4GB RAM minimum
- 10GB+ disk space for data

**Network**: Internet required for installation only (offline after setup)

## Workflow

### Step 1: Install ClickHouse

**macOS (Homebrew)**:

```bash
# Install ClickHouse
brew install clickhouse

# Verify installation
clickhouse --version
```

**Linux (Ubuntu/Debian)**:

```bash
# Quick installer (recommended)
curl https://clickhouse.com/ | sh
./clickhouse --version

# Or via apt
sudo apt-get install -y apt-transport-https ca-certificates
curl -fsSL https://packages.clickhouse.com/deb/lts/clickhouse.gpg | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo apt-get install -y clickhouse-server clickhouse-client
```

### Step 2: Start ClickHouse Server

**macOS (Homebrew)**:

```bash
# Start server in background
clickhouse server --daemon

# Verify server is running
clickhouse client --query "SELECT 1"
```

**Linux (systemd)**:

```bash
# Start and enable service
sudo service clickhouse-server start
sudo systemctl enable clickhouse-server

# Verify server is running
clickhouse-client --query "SELECT 1"
```

### Step 3: Configure Environment

**Set Local Mode**:

```bash
# Explicit local mode (recommended)
export GCCH_MODE=local

# Or rely on auto-detection (localhost triggers local mode)
export CLICKHOUSE_HOST=localhost
```

**Environment Variables**:

```bash
# Full local configuration
export GCCH_MODE=local
export CLICKHOUSE_HOST=localhost
export CLICKHOUSE_HTTP_PORT=8123
export CLICKHOUSE_DATABASE=default
export CLICKHOUSE_USER=default
export CLICKHOUSE_PASSWORD=
```

### Step 4: Verify Connection

**Using Python**:

```python
from gapless_crypto_clickhouse import probe

# Check local ClickHouse status
status = probe.check_local_clickhouse()
print(f"Installed: {status['installed']}")
print(f"Running: {status['running']}")
print(f"Version: {status['version']}")

# Get current mode
mode = probe.get_current_mode()
print(f"Mode: {mode}")  # Should be "local"
```

**Using CLI**:

```bash
# Quick connection test
GCCH_MODE=local python -c "
from gapless_crypto_clickhouse.clickhouse.config import ClickHouseConfig
config = ClickHouseConfig.from_env()
print(f'Host: {config.host}')
print(f'Port: {config.http_port}')
print(f'Secure: {config.secure}')
"
```

### Step 5: Test with Real Data

**Query with Auto-Ingestion**:

```python
import os
os.environ["GCCH_MODE"] = "local"

from gapless_crypto_clickhouse import query_ohlcv

# First query downloads and ingests data automatically
df = query_ohlcv(
    "BTCUSDT",
    "1h",
    "2024-01-01",
    "2024-01-07"
)
print(f"Rows: {len(df)}")
print(df.head())
```

## Mode Detection Logic

The package auto-detects deployment mode based on environment:

```
GCCH_MODE=local       → Local mode (explicit)
GCCH_MODE=cloud       → Cloud mode (requires CLICKHOUSE_HOST)
GCCH_MODE=auto        → Auto-detect:
  CLICKHOUSE_HOST=""           → Local mode
  CLICKHOUSE_HOST="localhost"  → Local mode
  CLICKHOUSE_HOST="127.0.0.1"  → Local mode
  CLICKHOUSE_HOST="*.cloud"    → Cloud mode
```

**Introspection**:

```python
from gapless_crypto_clickhouse import probe

# Get available modes
modes = probe.get_deployment_modes()
print(modes["available_modes"])  # ["local", "cloud"]

# Get current mode
current = probe.get_current_mode()  # "local" or "cloud"

# Get installation guide
guide = probe.get_local_installation_guide()
print(guide["macos"]["commands"])
```

## Success Criteria

- ClickHouse server running on localhost:8123
- `probe.check_local_clickhouse()` returns `{"installed": True, "running": True}`
- `probe.get_current_mode()` returns `"local"`
- `query_ohlcv()` executes without Cloud credentials

## Troubleshooting

**Issue**: "Connection refused" on port 8123

- **Check**: Is ClickHouse server running?

  ```bash
  # macOS
  ps aux | grep clickhouse

  # Linux
  sudo service clickhouse-server status
  ```

- **Action**: Start server with `clickhouse server --daemon`

**Issue**: "Command not found: clickhouse"

- **Check**: Was ClickHouse installed correctly?
- **macOS**: Run `brew install clickhouse`
- **Linux**: Run `curl https://clickhouse.com/ | sh`

**Issue**: Mode detected as "cloud" instead of "local"

- **Check**: Is `CLICKHOUSE_HOST` set to a remote hostname?
- **Action**: Set `export GCCH_MODE=local` explicitly

**Issue**: Server crashes with memory error

- **Check**: System has 2-4GB RAM available
- **Action**: Increase available memory or reduce concurrent queries

**Issue**: Permission denied errors

- **Check**: ClickHouse data directory permissions
- **Action**: Ensure user has write access to `/var/lib/clickhouse` (Linux)

## Port Reference

| Mode  | HTTP Port | Native Port | Secure |
| ----- | --------- | ----------- | ------ |
| Local | 8123      | 9000        | False  |
| Cloud | 8443      | 9440        | True   |

## Performance Comparison

| Metric             | Local       | Cloud               |
| ------------------ | ----------- | ------------------- |
| Query latency      | 50ms        | 100-500ms           |
| First query (cold) | 50ms        | 5-10s (idle resume) |
| Network dependency | None        | Required            |
| Credentials        | None        | Required            |
| Best for           | Backtesting | Production          |

## Server Management

**Start Server**:

```bash
# macOS
clickhouse server --daemon

# Linux
sudo service clickhouse-server start
```

**Stop Server**:

```bash
# macOS
pkill -f clickhouse-server

# Linux
sudo service clickhouse-server stop
```

**Check Logs**:

```bash
# macOS (Homebrew)
tail -f /opt/homebrew/var/log/clickhouse-server/clickhouse-server.log

# Linux
sudo tail -f /var/log/clickhouse-server/clickhouse-server.log
```

## E2E Validation Workflow (ADR-0045)

This skill includes executable scripts for end-to-end validation of local ClickHouse.

### Scripts Directory

| Script                          | Purpose                                          |
| ------------------------------- | ------------------------------------------------ |
| `scripts/start-clickhouse.sh`   | Start mise-installed ClickHouse server           |
| `scripts/deploy-schema.sh`      | Deploy production schema (calls existing script) |
| `scripts/ingest-sample-data.py` | Ingest real Binance data via `query_ohlcv()`     |
| `scripts/take-screenshot.py`    | Capture Play UI screenshot via Playwright        |
| `scripts/validate-data.py`      | Validate data integrity, output JSON evidence    |

### Running E2E Validation

**Full workflow (manual)**:

```bash
# 1. Start ClickHouse
./skills/local-clickhouse/scripts/start-clickhouse.sh

# 2. Deploy schema
./skills/local-clickhouse/scripts/deploy-schema.sh

# 3. Ingest sample data
uv run python skills/local-clickhouse/scripts/ingest-sample-data.py

# 4. Capture screenshot
uv run python skills/local-clickhouse/scripts/take-screenshot.py

# 5. Validate data
uv run python skills/local-clickhouse/scripts/validate-data.py
```

**Via pytest (automated)**:

```bash
# Run E2E tests (requires mise ClickHouse installed)
uv run pytest tests/test_local_clickhouse_e2e.py -v

# Tests will FAIL (not skip) if ClickHouse not available
```

### Evidence Output

Scripts output evidence to `tests/screenshots/` (gitignored):

- `play-ui-{timestamp}.png` - Playwright screenshots
- `validation-{timestamp}.json` - Structured validation results

## References

- **ADR-0044**: [Local ClickHouse Option](/docs/architecture/decisions/0044-local-clickhouse-option.md)
- **ADR-0045**: [Local ClickHouse E2E Validation](/docs/architecture/decisions/0045-local-clickhouse-e2e-validation.md)
- **Plan 0044**: [Implementation Plan](/docs/development/plan/0044-local-clickhouse-option/plan.md)
- **Plan 0045**: [E2E Validation Plan](/docs/development/plan/0045-local-clickhouse-e2e/plan.md)
- **llms.txt**: AI agent documentation with deployment modes
- **probe.py**: `get_deployment_modes()`, `check_local_clickhouse()`

## Next Steps

After successful local setup:

1. **Schema Creation**: Tables created automatically on first query
2. **Data Ingestion**: Use `query_ohlcv()` with `auto_ingest=True`
3. **E2E Validation**: Run `uv run pytest tests/test_local_clickhouse_e2e.py -v`
4. **Backtesting**: Run analysis with 50-100x faster queries
5. **Production Migration**: Switch to Cloud mode with `export GCCH_MODE=cloud`
