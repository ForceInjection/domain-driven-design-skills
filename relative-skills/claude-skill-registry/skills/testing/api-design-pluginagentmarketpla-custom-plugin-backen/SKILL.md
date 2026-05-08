---
name: api-design
description: Design and build professional APIs with REST, GraphQL, and gRPC. Master authentication, documentation, testing, and operational concerns.
sasmp_version: "2.0.0"
bonded_agent: 03-api-development
bond_type: PRIMARY_BOND

# === PRODUCTION-GRADE SKILL CONFIG (SASMP v2.0.0) ===

atomic_operations:
  - ENDPOINT_DESIGN
  - AUTHENTICATION_SETUP
  - DOCUMENTATION_GENERATION
  - RATE_LIMITING_CONFIG

parameter_validation:
  query:
    type: string
    required: true
    minLength: 5
    maxLength: 2000
  api_type:
    type: string
    enum: [rest, graphql, grpc, websocket]
    required: false
  auth_method:
    type: string
    enum: [jwt, oauth2, api_key, session]
    required: false

retry_logic:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging_hooks:
  on_invoke: "skill.api-design.invoked"
  on_success: "skill.api-design.completed"
  on_error: "skill.api-design.failed"

exit_codes:
  SUCCESS: 0
  INVALID_INPUT: 1
  SECURITY_ISSUE: 2
  SCHEMA_ERROR: 3
---

# API Design Skill

**Bonded to:** `api-development-agent`

---

## Quick Start

```bash
# Invoke api-design skill
"Design a REST API for user management with authentication"
"Implement JWT authentication for my FastAPI app"
"Generate OpenAPI documentation for my endpoints"
```

---

## Instructions

1. **Analyze Requirements**: Understand client needs and data flow
2. **Choose Paradigm**: Select REST, GraphQL, or gRPC
3. **Design Endpoints**: Create resource-oriented API structure
4. **Implement Security**: Add authentication and authorization
5. **Document API**: Generate OpenAPI specification

---

## API Paradigm Selection

| Paradigm | Best For | Performance | Complexity |
|----------|----------|-------------|------------|
| REST | Public APIs, CRUD, simple | Good | Low |
| GraphQL | Complex data, mobile clients | Good | Medium |
| gRPC | Internal services, real-time | Excellent | Medium |
| WebSocket | Bi-directional real-time | Excellent | Medium |

---

## Decision Tree

```
Client type?
    │
    ├─→ Public/Third-party → REST
    │
    ├─→ Mobile with complex data → GraphQL
    │
    ├─→ Internal microservices
    │     ├─→ High performance needed → gRPC
    │     └─→ Standard HTTP preferred → REST
    │
    └─→ Real-time bi-directional → WebSocket
```

---

## Examples

### Example 1: REST API Design
```yaml
# OpenAPI 3.1 Specification
openapi: 3.1.0
info:
  title: User Management API
  version: 1.0.0

paths:
  /api/v1/users:
    post:
      summary: Create user
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUser'
      responses:
        '201':
          description: User created
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: User list

  /api/v1/users/{id}:
    get:
      summary: Get user by ID
    put:
      summary: Update user
    delete:
      summary: Delete user
```

### Example 2: JWT Authentication
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from datetime import datetime, timedelta

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        return user_id
    except JWTError:
        raise credentials_exception
```

### Example 3: Rate Limiting
```python
from fastapi import FastAPI, Request
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app = FastAPI()
app.state.limiter = limiter

@app.get("/api/v1/resource")
@limiter.limit("100/minute")
async def get_resource(request: Request):
    return {"data": "rate limited endpoint"}
```

---

## HTTP Status Codes

```
2xx Success
├── 200 OK              → Standard success
├── 201 Created         → Resource created
├── 204 No Content      → Success, no body

4xx Client Error
├── 400 Bad Request     → Invalid input
├── 401 Unauthorized    → Auth required
├── 403 Forbidden       → Permission denied
├── 404 Not Found       → Resource not found
├── 422 Unprocessable   → Validation error
├── 429 Too Many Reqs   → Rate limited

5xx Server Error
├── 500 Internal Error  → Server error
├── 502 Bad Gateway     → Upstream error
├── 503 Unavailable     → Service down
```

---

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Invalid/expired token | Check token, refresh if needed |
| CORS errors | Missing headers | Configure CORS middleware |
| 429 Rate Limited | Too many requests | Implement backoff, cache |
| Slow endpoints | N+1 queries, no caching | Optimize queries, add cache |

### Debug Checklist

1. Verify request format (headers, body)
2. Check authentication: `curl -H "Authorization: Bearer <token>"`
3. Review API logs for errors
4. Test with minimal example
5. Validate against OpenAPI spec

---

## Test Template

```python
# tests/test_api.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestUserAPI:
    def test_create_user_returns_201(self):
        response = client.post(
            "/api/v1/users",
            json={"email": "test@example.com", "password": "secure123"}
        )
        assert response.status_code == 201
        assert "id" in response.json()

    def test_get_user_requires_auth(self):
        response = client.get("/api/v1/users/123")
        assert response.status_code == 401

    def test_get_user_with_valid_token(self, auth_headers):
        response = client.get("/api/v1/users/123", headers=auth_headers)
        assert response.status_code == 200
```

---

## References

See `references/` directory for:
- `API_GUIDE.md` - Detailed API patterns
- `openapi-template.yaml` - OpenAPI starter template

---

## Resources

- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
- [REST API Best Practices](https://restfulapi.net/)
- [OWASP API Security](https://owasp.org/www-project-api-security/)
