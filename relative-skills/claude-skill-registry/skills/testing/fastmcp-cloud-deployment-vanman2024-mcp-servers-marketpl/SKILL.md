---
name: fastmcp-cloud-deployment
description: FastMCP Cloud deployment validation, testing, and verification patterns. Use when deploying MCP servers, validating deployments, testing server configurations, checking environment variables, verifying deployment health, tracking deployments, or when user mentions FastMCP Cloud, deployment validation, pre-deployment checks, post-deployment verification, deployment troubleshooting, or deployment lifecycle management.
allowed-tools: Bash, Read, Write, Edit
---

# FastMCP Cloud Deployment Skill

This skill provides comprehensive deployment lifecycle management for FastMCP servers, including pre-deployment validation, local testing, post-deployment verification, environment variable checking, and deployment tracking.

## Overview

The deployment lifecycle consists of five phases:
1. **Pre-Deployment Validation** - Syntax, dependencies, configuration
2. **Local Testing** - STDIO and HTTP transport testing
3. **Environment Verification** - Environment variable validation
4. **Deployment** - To FastMCP Cloud, HTTP, or STDIO
5. **Post-Deployment Verification** - Health checks, endpoint testing

## Available Scripts

### 1. Pre-Deployment Validation

**Script**: `scripts/validate-server.sh <server-path>`

**Purpose**: Validates server is ready for deployment

**Checks**:
- Server file exists (server.py, server.ts, index.ts)
- Syntax validation (Python/TypeScript)
- Dependencies declared (requirements.txt or package.json)
- FastMCP dependency included
- fastmcp.json configuration valid
- No hardcoded secrets
- Environment configuration present
- .gitignore properly configured

**Usage**:
```bash
# Validate current directory
./scripts/validate-server.sh .

# Validate specific server
./scripts/validate-server.sh /path/to/server

# Verbose mode
VERBOSE=1 ./scripts/validate-server.sh .
```

**Exit Codes**:
- `0`: Validation passed (may have warnings)
- `1`: Validation failed (must fix before deployment)

**Example Output**:
```
=== FastMCP Server Pre-Deployment Validation ===
✓ Found Python server file: server.py
✓ Python syntax is valid
✓ FastMCP dependency declared in requirements.txt
✓ fastmcp.json has valid JSON syntax
✓ Server name: my-server
⚠ Found 2 unpinned dependencies
✓ No obvious hardcoded secrets detected

Results: 12 passed, 0 failed, 1 warnings
✓ Server passed validation - ready for deployment
```

### 2. Local Testing

**Script**: `scripts/test-local.sh <server-path>`

**Purpose**: Tests server locally before deployment

**Tests**:
- Module imports successful
- STDIO transport working
- HTTP transport responding
- Environment variables configured
- Health endpoints (if configured)
- Server stability (runs for 5+ seconds)

**Usage**:
```bash
# Test with default transport (STDIO)
./scripts/test-local.sh .

# Test both STDIO and HTTP
TRANSPORT=both ./scripts/test-local.sh .

# Test HTTP only on custom port
TRANSPORT=http PORT=3000 ./scripts/test-local.sh .

# Longer test duration
TEST_DURATION=30 ./scripts/test-local.sh .
```

**Environment Variables**:
- `TRANSPORT`: `stdio`, `http`, or `both` (default: `stdio`)
- `PORT`: Port for HTTP testing (default: `8000`)
- `TEST_DURATION`: Test duration in seconds (default: `10`)

**Example Output**:
```
=== FastMCP Server Local Testing ===
✓ Python imports successful
✓ Server started successfully (PID: 12345)
✓ Server is producing MCP protocol messages
✓ HTTP server started (PID: 12346)
✓ Health endpoint responding

Results: 12 passed, 0 failed, 0 warnings
✓ Server tests passed - ready for deployment testing
```

### 3. Environment Variable Check

**Script**: `scripts/check-env-vars.sh <server-path>`

**Purpose**: Validates environment variables are properly configured

**Checks**:
- .env.example exists and documents variables
- Required vs optional variables identified
- Local .env file has all required variables
- fastmcp.json env declarations match .env.example
- .env in .gitignore (security)
- No placeholder values in production

**Usage**:
```bash
# Check default .env file
./scripts/check-env-vars.sh .

# Check specific env file
ENV_FILE=.env.production ./scripts/check-env-vars.sh .

# Check only required variables
CHECK_MODE=required ./scripts/check-env-vars.sh .
```

**Environment Variables**:
- `ENV_FILE`: Environment file to check (default: `.env`)
- `CHECK_MODE`: `all`, `required`, or `optional` (default: `all`)

**Example Output**:
```
=== FastMCP Server Environment Variable Check ===
✓ Found .env.example template
ℹ Required: API_KEY
ℹ Optional: LOG_LEVEL (default: INFO)
✓ All required variables are set
✓ All fastmcp.json variables documented in .env.example
✓ .env files properly excluded from git

Results: 6 passed, 0 failed, 0 warnings
✓ Environment configuration validated
```

### 4. Post-Deployment Verification

**Script**: `scripts/verify-deployment.sh <deployment-url>`

**Purpose**: Verifies deployed server is accessible and functioning

**Checks**:
- DNS resolution working
- Server is reachable
- Health endpoint responding
- MCP endpoint accepting requests
- Valid JSON-RPC responses
- Tools are available
- SSL/TLS certificate valid (HTTPS)
- Response time acceptable

**Usage**:
```bash
# Verify FastMCP Cloud deployment
./scripts/verify-deployment.sh https://my-server.fastmcp.app/mcp

# Verify HTTP deployment
./scripts/verify-deployment.sh https://my-server.example.com/mcp

# Custom timeout and retries
MAX_RETRIES=10 TIMEOUT=60 ./scripts/verify-deployment.sh https://my-server.com/mcp

# Verbose output
VERBOSE=1 ./scripts/verify-deployment.sh https://my-server.com/mcp
```

**Environment Variables**:
- `MAX_RETRIES`: Maximum retry attempts (default: `5`)
- `RETRY_DELAY`: Seconds between retries (default: `10`)
- `TIMEOUT`: Request timeout in seconds (default: `30`)
- `VERBOSE`: Show detailed output (default: `0`)

**Example Output**:
```
=== FastMCP Server Deployment Verification ===
✓ DNS resolved: my-server.fastmcp.app -> 104.21.45.123
✓ Server is reachable
✓ Health endpoint available at /health (HTTP 200)
✓ MCP endpoint responding (HTTP 200)
✓ Valid JSON-RPC response received
✓ Server provides 3 tool(s)
✓ Valid SSL/TLS certificate
✓ Response time excellent (<1s)

Results: 11 passed, 0 failed, 0 warnings
✓ Deployment verified successfully
```

## Templates

### Deployment Tracking Template

**File**: `templates/.fastmcp-deployments.json`

**Purpose**: Track all server deployments with metadata

**Structure**:
```json
{
  "version": "1.0.0",
  "deployments": [
    {
      "id": "deployment-uuid",
      "serverName": "my-server",
      "environment": "production",
      "target": "fastmcp-cloud",
      "url": "https://my-server.fastmcp.app/mcp",
      "status": "active",
      "deployedAt": "2025-01-15T10:30:00Z",
      "version": "1.0.0",
      "validationResults": {
        "preDeployment": {...},
        "postDeployment": {...}
      }
    }
  ]
}
```

**Usage**: Copy template and update with actual deployment details

### Deployment Checklist

**File**: `templates/deployment-checklist.md`

**Purpose**: Step-by-step checklist for successful deployments

**Sections**:
- Pre-Deployment Checklist (code quality, dependencies, config)
- Deployment Checklist (by target: FastMCP Cloud, HTTP, STDIO)
- Post-Deployment Verification (accessibility, functionality, performance)
- Deployment Tracking (record keeping)
- Rollback Plan (if issues occur)

**Usage**: Copy checklist for each deployment, check off items as completed

### Environment Variables Documentation

**File**: `templates/env-var-template.md`

**Purpose**: Template for documenting all environment variables

**Sections**:
- Required Variables (must be set)
- Optional Variables (have defaults)
- Development-Only Variables
- Environment-Specific Configurations
- Security Best Practices
- Troubleshooting

**Usage**: Copy template to server repo as `ENV_VARS.md`, customize with actual variables

## Examples

### Successful Deployment Workflow

**File**: `examples/successful-deployment.md`

**Contents**: Complete end-to-end deployment example including:
- Pre-deployment validation output
- Environment variable checking
- Local testing results
- Deployment process
- Post-deployment verification
- Deployment tracking record
- Post-deployment monitoring
- Lessons learned

**Use Case**: Reference for first-time deployments or training

### Troubleshooting Guide

**File**: `examples/troubleshooting.md`

**Contents**: Common issues and solutions including:
- Pre-deployment validation failures
- Environment variable issues
- Local testing problems
- FastMCP Cloud deployment errors
- HTTP deployment issues
- SSL/TLS certificate problems
- Post-deployment verification failures
- Performance issues
- Runtime crashes
- Debugging tools and techniques

**Use Case**: Reference when deployments fail or issues occur

## Deployment Workflow

### Standard Deployment Process

**Step 1: Pre-Deployment Validation**
```bash
cd /path/to/server
./scripts/validate-server.sh .
```

**Expected**: All checks pass, address any warnings

**Step 2: Environment Variable Check**
```bash
./scripts/check-env-vars.sh .
```

**Expected**: All required variables set, no security issues

**Step 3: Local Testing**
```bash
TRANSPORT=both ./scripts/test-local.sh .
```

**Expected**: Server runs successfully in both STDIO and HTTP modes

**Step 4: Deploy**

For **FastMCP Cloud**:
1. Create separate GitHub repository
2. Push code
3. Connect to FastMCP Cloud
4. Set environment variables in dashboard
5. Trigger deployment

For **HTTP** (your infrastructure):
1. Deploy to server (VPS, container, etc.)
2. Configure environment variables
3. Set up reverse proxy (nginx/caddy)
4. Configure SSL/TLS
5. Start server

For **STDIO** (local/IDE):
1. Update `.mcp.json` or IDE config
2. Ensure `.env` file has required variables
3. Restart IDE

**Step 5: Post-Deployment Verification**
```bash
./scripts/verify-deployment.sh https://your-deployment-url/mcp
```

**Expected**: All checks pass, server responding correctly

**Step 6: Track Deployment**

Update `.fastmcp-deployments.json` with:
- Deployment timestamp
- Git commit hash
- Version number
- Validation results
- Environment variables used

### Emergency Rollback

If deployment fails:

1. Check deployment logs for errors
2. Run verification script to identify issues
3. Review troubleshooting guide for solutions
4. If critical: Rollback to previous version
5. Fix issues locally
6. Re-run validation scripts
7. Redeploy

## Integration with Other Skills

This skill complements:

- **mcp-server-config**: Uses config templates for deployment setup
- **newman-runner**: Can integrate API testing before deployment
- **api-schema-analyzer**: Validates API schemas match deployment

## Best Practices

### Before Every Deployment

1. Run all validation scripts in order
2. Test locally in target transport mode
3. Verify all environment variables
4. Review deployment checklist
5. Have rollback plan ready

### Security

1. Never commit `.env` files
2. Use `.env.example` for documentation only
3. Rotate secrets regularly
4. Use different values per environment
5. Store production secrets in secrets manager

### Monitoring

1. Check health endpoint immediately after deployment
2. Monitor logs for first 24 hours
3. Set up alerts for failures
4. Track performance metrics
5. Document any issues encountered

### Documentation

1. Keep `.env.example` up to date
2. Document all environment variables
3. Track deployments in `.fastmcp-deployments.json`
4. Update troubleshooting guide with new issues
5. Maintain deployment checklist

## Common Use Cases

### Use Case 1: First Production Deployment

```bash
# Validate server is ready
./scripts/validate-server.sh .

# Check environment variables
./scripts/check-env-vars.sh .

# Test locally
TRANSPORT=both ./scripts/test-local.sh .

# Deploy to FastMCP Cloud
# (via dashboard or CLI)

# Verify deployment
./scripts/verify-deployment.sh https://my-server.fastmcp.app/mcp
```

### Use Case 2: Staging Environment Testing

```bash
# Use staging environment file
ENV_FILE=.env.staging ./scripts/check-env-vars.sh .

# Test with staging config
cp .env.staging .env
TRANSPORT=http ./scripts/test-local.sh .

# Deploy to staging
# ...

# Verify staging deployment
./scripts/verify-deployment.sh https://staging.example.com/mcp
```

### Use Case 3: Multi-Environment Deployment

```bash
# Validate once
./scripts/validate-server.sh .

# Check each environment's variables
for env in development staging production; do
    echo "Checking $env..."
    ENV_FILE=.env.$env ./scripts/check-env-vars.sh .
done

# Deploy to each environment
# ...

# Verify each deployment
./scripts/verify-deployment.sh https://dev.example.com/mcp
./scripts/verify-deployment.sh https://staging.example.com/mcp
./scripts/verify-deployment.sh https://my-server.fastmcp.app/mcp
```

### Use Case 4: Continuous Deployment Pipeline

```bash
#!/bin/bash
# .github/workflows/deploy.sh

set -e

# Validation
./scripts/validate-server.sh . || exit 1

# Environment check
ENV_FILE=.env.production ./scripts/check-env-vars.sh . || exit 1

# Local testing
TRANSPORT=both ./scripts/test-local.sh . || exit 1

# Deploy (example using FastMCP Cloud CLI)
fastmcp deploy --env production

# Wait for deployment
sleep 30

# Verify
./scripts/verify-deployment.sh https://my-server.fastmcp.app/mcp || exit 1

echo "Deployment successful!"
```

## Troubleshooting Quick Reference

**Script fails with permission denied**:
```bash
chmod +x scripts/*.sh
```

**Python not found**:
```bash
# Install Python 3
sudo apt install python3 python3-pip
```

**jq not found**:
```bash
# Install jq for JSON parsing
sudo apt install jq
```

**curl not found**:
```bash
# Install curl
sudo apt install curl
```

**Script hangs during testing**:
```bash
# Reduce test duration
TEST_DURATION=5 ./scripts/test-local.sh .
```

**Verification fails immediately**:
```bash
# Increase timeout
TIMEOUT=60 ./scripts/verify-deployment.sh <url>
```

## Success Criteria

A deployment is successful when:

- ✅ All validation scripts pass
- ✅ Local tests complete successfully
- ✅ Environment variables properly configured
- ✅ Deployment completes without errors
- ✅ Post-deployment verification passes
- ✅ Health endpoint returns 200 OK
- ✅ MCP endpoint responds to JSON-RPC
- ✅ All tools are available
- ✅ Response time is acceptable
- ✅ No errors in first 24 hours of logs
- ✅ Deployment tracked in `.fastmcp-deployments.json`

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-01-15
**Maintained By**: FastMCP Plugin Team
