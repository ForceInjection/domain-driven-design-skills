---
name: mz-configure-loki-logging
description: Configure Grafana Loki logging using mazza-base library for Python/Flask applications with CA certificate (Mazza-specific). Use when setting up Loki logging for Mazza projects or configuring centralized logging.
---

# Loki Logging with mazza-base

This skill helps you integrate Grafana Loki logging using the mazza-base utility library, which handles structured JSON logging and Loki shipping.

## When to Use This Skill

Use this skill when:
- Starting a new Python/Flask application
- You want centralized logging with Loki
- You need structured logs for production
- You want easy local development with console logs

## What This Skill Creates

1. **requirements.txt entry** - Adds mazza-base dependency
2. **CA certificate file** - Places mazza.vc_CA.pem in project root
3. **Dockerfile updates** - Copies CA certificate to container
4. **Logging initialization** - Adds configure_logging() call to main application file
5. **Environment variable documentation** - All required Loki configuration

## Step 1: Gather Project Information

**IMPORTANT**: Before making changes, ask the user these questions:

1. **"What is your application tag/name?"** (e.g., "materia-server", "trading-api")
   - This identifies your service in Loki logs

2. **"What is your main application file?"** (e.g., "app.py", "server.py", "materia_server.py")
   - Where to add the logging configuration

3. **"Do you have the mazza.vc_CA.pem certificate file?"**
   - Required for secure Loki connection
   - If no, user needs to obtain it from Mazza infrastructure team

4. **"Do you have a CR_PAT environment variable set?"** (GitHub Personal Access Token)
   - Required to install mazza-base from private GitHub repo

## Step 2: Add mazza-base to requirements.txt

Add this line to `requirements.txt`:

```txt
# Logging configuration with Loki support
mazza-base @ git+https://${CR_PAT}@github.com/mazza-vc/python-mazza-base.git@main
```

**NOTE**: The `CR_PAT` environment variable must be set when running `pip install`:
```bash
export CR_PAT="your_github_personal_access_token"
pip install -r requirements.txt
```

## Step 3: Add CA Certificate File

Ensure `mazza.vc_CA.pem` file is in your project root:

```
{project_root}/
├── mazza.vc_CA.pem    # CA certificate for secure Loki connection
├── requirements.txt
├── Dockerfile
└── {app_file}.py
```

If you don't have this file, contact the Mazza infrastructure team.

## Step 4: Update Dockerfile

Add the CA certificate to your Dockerfile. Place this **before** installing requirements:

```dockerfile
FROM python:3.11-alpine

ARG CR_PAT
ENV CR_PAT=${CR_PAT}

WORKDIR /app

# Copy CA certificate
COPY mazza.vc_CA.pem .

# Copy requirements and install
COPY requirements.txt .
RUN pip install -r requirements.txt

# ... rest of Dockerfile
```

**CRITICAL**: The COPY line must appear before `pip install -r requirements.txt`

The certificate will be available at `/app/mazza.vc_CA.pem` in the container.

## Step 5: Configure Logging in Application

Add to the **top** of your main application file (e.g., `{app_file}.py`):

```python
import os
from mazza_base import configure_logging

# Configure logging with mazza_base
# Use debug_local=True for local development, False for production with Loki
debug_mode = os.environ.get('DEBUG_LOCAL', 'true').lower() == 'true'
log_level = os.environ.get('LOG_LEVEL', 'INFO')
configure_logging(
    application_tag='{application_tag}',
    debug_local=debug_mode,
    local_level=log_level
)
```

**CRITICAL**: Replace:
- `{app_file}` → Your main application filename (e.g., "materia_server")
- `{application_tag}` → Your service name (e.g., "materia-server")

Place this **before** creating your Flask app or any other initialization.

## Step 6: Document Environment Variables

Add to README.md or .env.example:

### Environment Variables

**Logging Configuration (Local Development):**
- `DEBUG_LOCAL` - Set to 'true' for local development (console logs), 'false' for production (Loki)
  - Default: 'true'
  - Production: 'false'
- `LOG_LEVEL` - Logging level: DEBUG, INFO, WARNING, ERROR, CRITICAL
  - Default: 'INFO'

**Loki Configuration (Production Only - required when DEBUG_LOCAL=false):**
- `MZ_LOKI_ENDPOINT` - Loki server URL (e.g., https://loki.mazza.vc:8443/loki/api/v1/push)
- `MZ_LOKI_USER` - Loki username for authentication
- `MZ_LOKI_PASSWORD` - Loki password for authentication
- `MZ_LOKI_CA_BUNDLE_PATH` - Path to CA certificate (e.g., /app/mazza.vc_CA.pem)

**GitHub Access (for pip install):**
- `CR_PAT` - GitHub Personal Access Token with repo access
  - Required to install mazza-base from private repository

### Logging Behavior

**Local Development** (`DEBUG_LOCAL=true`):
- Logs output to console with pretty formatting
- Easy to read during development
- No Loki connection required
- No need to set MZ_LOKI_* variables

**Production** (`DEBUG_LOCAL=false`):
- Logs output as structured JSON to Loki
- All MZ_LOKI_* variables must be set
- Queryable in Grafana
- Secure connection via mazza.vc_CA.pem

## Step 7: Usage Examples

### Local Development

```bash
# In .env or shell
export DEBUG_LOCAL=true
export LOG_LEVEL=DEBUG
export CR_PAT=your_github_token

pip install -r requirements.txt
python {app_file}.py
```

### Production Deployment

Docker Compose example:

```yaml
services:
  {app_name}:
    build:
      context: .
      args:
        - CR_PAT=${CR_PAT}
    environment:
      - DEBUG_LOCAL=false
      - LOG_LEVEL=INFO
      - MZ_LOKI_ENDPOINT=${MZ_LOKI_ENDPOINT}
      - MZ_LOKI_USER=${MZ_LOKI_USER}
      - MZ_LOKI_PASSWORD=${MZ_LOKI_PASSWORD}
      - MZ_LOKI_CA_BUNDLE_PATH=/app/mazza.vc_CA.pem
```

**NOTE**: Set these in your .env file:
```
MZ_LOKI_ENDPOINT=https://loki.mazza.vc:8443/loki/api/v1/push
MZ_LOKI_USER=your_loki_user
MZ_LOKI_PASSWORD=your_loki_password
```

## How It Works

The `mazza-base` library provides:

1. **Automatic mode detection** - Console logs for local dev, Loki for production
2. **Structured logging** - Consistent JSON format for Loki
3. **Secure connection** - Uses CA certificate for encrypted Loki communication
4. **Easy integration** - One function call to configure everything
5. **Application tagging** - Identifies your service in centralized logs

**You don't need to:**
- Write JSON formatters
- Configure logging handlers
- Manage Loki client setup
- Handle certificate validation

**Just call `configure_logging()` and you're done!**

## Integration with Other Skills

### Flask API Server
If using **flask-smorest-api** skill, add logging **before** creating Flask app:

```python
import os
from flask import Flask
from mazza_base import configure_logging

# Configure logging FIRST
debug_mode = os.environ.get('DEBUG_LOCAL', 'true').lower() == 'true'
configure_logging(application_tag='my-api', debug_local=debug_mode)

# Then create Flask app
app = Flask(__name__)
# ... rest of setup
```

### Docker Deployment
In your Dockerfile:

```dockerfile
ARG CR_PAT
ENV CR_PAT=${CR_PAT}
COPY mazza.vc_CA.pem .
COPY requirements.txt .
RUN pip install -r requirements.txt
```

## Troubleshooting

**Cannot install mazza-base:**
- Ensure `CR_PAT` environment variable is set
- Verify token has repo access to `mazza-vc/python-mazza-base`
- Check token is not expired

**Missing CA certificate error:**
- Ensure `mazza.vc_CA.pem` is in project root
- Verify file is copied in Dockerfile: `COPY mazza.vc_CA.pem .`
- Check MZ_LOKI_CA_BUNDLE_PATH points to correct location

**Runtime error: Missing required environment variables:**
- Only occurs when `DEBUG_LOCAL=false`
- Ensure all MZ_LOKI_* variables are set
- Check spelling (MZ_LOKI_, not LOKI_ or MATERIA_LOKI_)

**Logs not appearing in Loki (production):**
- Verify `DEBUG_LOCAL=false` is set
- Check all MZ_LOKI_* variables are correct
- Test CA certificate path is accessible in container
- Verify Loki endpoint is reachable from container

**Import error for mazza_base:**
- Run `pip install -r requirements.txt` with CR_PAT set
- Verify mazza-base installed: `pip list | grep mazza-base`

## Example Implementation

See the materia-server project for a reference implementation:

```python
# materia_server.py
import os
from mazza_base import configure_logging

debug_mode = os.environ.get('DEBUG_LOCAL', 'true').lower() == 'true'
log_level = os.environ.get('LOG_LEVEL', 'INFO')
configure_logging(
    application_tag='materia-server',
    debug_local=debug_mode,
    local_level=log_level
)

# ... rest of Flask app setup
```

```dockerfile
# Dockerfile
FROM python:3.11-alpine
ARG CR_PAT
ENV CR_PAT=${CR_PAT}
WORKDIR /app
COPY mazza.vc_CA.pem .
COPY requirements.txt .
RUN pip install -r requirements.txt
# ... rest of Dockerfile
```

```yaml
# docker-compose.yaml
services:
  materia-server:
    environment:
      - MZ_LOKI_USER=${MZ_LOKI_USER}
      - MZ_LOKI_ENDPOINT=${MZ_LOKI_ENDPOINT}
      - MZ_LOKI_PASSWORD=${MZ_LOKI_PASSWORD}
      - MZ_LOKI_CA_BUNDLE_PATH=/app/mazza.vc_CA.pem
```

This provides structured logging locally during development and automatic Loki shipping in production with secure encrypted connections.
