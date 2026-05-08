---
name: security-fastapi
description: |-
  Review FastAPI security audit patterns for dependencies and middleware. Use for auditing auth dependencies, CORS configuration, and TrustedHost middleware. Use proactively when reviewing FastAPI apps.
  Examples:
  - user: "Audit FastAPI route security" → check for Depends() and Security() usage
  - user: "Check FastAPI CORS setup" → verify origins when allow_credentials=True
  - user: "Review FastAPI middleware" → check TrustedHost and HTTPSRedirect config
  - user: "Secure FastAPI API keys" → move from query params to header schemes
  - user: "Scan for FastAPI footguns" → check starlette integration and dependency order
---

<overview>

Security audit patterns for FastAPI applications covering authentication dependencies, CORS configuration, and middleware security.

</overview>

<vulnerabilities>

## Core Risks to Check

### Missing Auth on Routes

FastAPI expects authentication/authorization via dependencies on routes or routers. If no `Depends()`/`Security()` usage exists, review every route for unintended public access.

```python
from fastapi import Depends, Security

@app.get("/private")
async def private_route(user=Depends(get_current_user)):
    return {"ok": True}

@app.get("/scoped")
async def scoped_route(user=Security(get_current_user, scopes=["items"])):
    return {"ok": True}
```

### API Key Schemes

If using API keys, SHOULD prefer header-based schemes (`APIKeyHeader`) and validate the key server-side.

```python
from fastapi import Depends, FastAPI
from fastapi.security import APIKeyHeader

api_key = APIKeyHeader(name="x-api-key")

@app.get("/items")
async def read_items(key: str = Depends(api_key)):
    return {"key": key}
```

### CORS: Avoid Wildcards with Credentials

Using `allow_origins=["*"]` excludes credentialed requests (cookies/Authorization). For authenticated browser clients, MUST explicitly list allowed origins.

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://app.example.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Host Header and HTTPS Enforcement

SHOULD use Starlette middleware to prevent host-header attacks and enforce HTTPS in production.

```python
from starlette.middleware.trustedhost import TrustedHostMiddleware
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware

app.add_middleware(TrustedHostMiddleware, allowed_hosts=["example.com", "*.example.com"])
app.add_middleware(HTTPSRedirectMiddleware)
```

</vulnerabilities>

<commands>

## Quick Audit Commands

```bash
# Detect FastAPI usage
rg -n "fastapi" pyproject.toml requirements*.txt

# Find routes
rg -n "@app\.(get|post|put|patch|delete)" . -g "*.py"

# Check for auth dependencies
rg -n "Depends\(|Security\(" . -g "*.py"

# CORS config and wildcards
rg -n "CORSMiddleware|allow_origins|allow_credentials" . -g "*.py"

# TrustedHost/HTTPS middleware
rg -n "TrustedHostMiddleware|HTTPSRedirectMiddleware" . -g "*.py"
```

</commands>

<checklist>

## Hardening Checklist

- [ ] All sensitive routes require `Depends()` or `Security()` auth dependencies
- [ ] API key schemes use headers (`APIKeyHeader`), not query params
- [ ] `allow_origins` is explicit when `allow_credentials=True`
- [ ] `TrustedHostMiddleware` configured for production domains
- [ ] `HTTPSRedirectMiddleware` enabled in production (or enforced by proxy)

</checklist>

<scripts>

## Scripts

- `scripts/scan.sh` - First-pass FastAPI security scan

</scripts>
