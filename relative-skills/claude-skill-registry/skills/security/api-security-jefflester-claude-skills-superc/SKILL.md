---
name: api-security
description: API security best practices and common vulnerability prevention. Enforces security checks for authentication, input validation, SQL injection, XSS, and OWASP Top 10 vulnerabilities. Use when building or modifying APIs.
---

# API Security Best Practices

## Purpose

This guardrail skill enforces critical security practices when building APIs. It helps prevent common vulnerabilities including OWASP Top 10 threats, ensuring your API is secure by design.

## When to Use This Skill

Auto-activates when:

- Working with API endpoints or routes
- Mentions of "api", "endpoint", "authentication", "authorization"
- Adding request handlers or middleware
- Working with user input or database queries

## Authentication & Authorization

### Always Require Authentication

Every API endpoint must have explicit authentication:

```python
# Good - Authentication required
@app.post("/api/users")
@require_auth  # Explicit authentication decorator
async def create_user(request: Request):
    user = get_current_user(request)
    # Implementation
```

```javascript
// Good - Authentication middleware
router.post('/api/users', authenticate, async (req, res) => {
  const user = req.user; // Set by authenticate middleware
  // Implementation
});
```

**Never skip authentication:**
```python
# BAD - No authentication!
@app.post("/api/users")
async def create_user(request: Request):
    # Anyone can call this!
    pass
```

### Implement Proper Authorization

Authentication (who you are) is not enough - check authorization (what you can do):

```python
@app.delete("/api/users/{user_id}")
@require_auth
async def delete_user(user_id: str, request: Request):
    current_user = get_current_user(request)

    # Authorization check
    if not current_user.is_admin and current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Proceed with deletion
    await delete_user_by_id(user_id)
```

### Use Strong Token Standards

Use industry-standard tokens:

```python
# Good - JWT with expiration
import jwt
from datetime import datetime, timedelta

def create_access_token(user_id: str) -> str:
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + timedelta(hours=1),
        "iat": datetime.utcnow(),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")

# Validate tokens properly
def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## Input Validation

### Validate All User Input

Never trust user input - always validate:

```python
from pydantic import BaseModel, Field, validator

class CreateUserRequest(BaseModel):
    """Validated user creation request."""

    username: str = Field(..., min_length=3, max_length=50, regex="^[a-zA-Z0-9_]+$")
    email: str = Field(..., regex=r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
    age: int = Field(..., ge=0, le=150)

    @validator("username")
    def username_no_admin(cls, v):
        if "admin" in v.lower():
            raise ValueError("Username cannot contain 'admin'")
        return v

@app.post("/api/users")
async def create_user(data: CreateUserRequest):  # Automatic validation
    # data is guaranteed valid here
    pass
```

### Sanitize Output

Prevent XSS by escaping output:

```python
import html

@app.get("/api/users/{user_id}")
async def get_user(user_id: str):
    user = await get_user_by_id(user_id)

    # Sanitize output for web display
    return {
        "username": html.escape(user.username),
        "bio": html.escape(user.bio),
    }
```

### Rate Limiting

Prevent abuse with rate limiting:

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/api/login")
@limiter.limit("5/minute")  # Max 5 attempts per minute
async def login(request: Request, credentials: LoginRequest):
    # Implementation
    pass
```

## SQL Injection Prevention

### Always Use Parameterized Queries

**NEVER concatenate user input into SQL:**

```python
# CRITICAL VULNERABILITY - SQL Injection!
user_id = request.query_params.get("id")
query = f"SELECT * FROM users WHERE id = {user_id}"  # NEVER DO THIS!
result = db.execute(query)

# Good - Parameterized query
user_id = request.query_params.get("id")
query = "SELECT * FROM users WHERE id = ?"
result = db.execute(query, (user_id,))

# Better - Use ORM
user = await User.filter(id=user_id).first()
```

### ORM Best Practices

Use ORMs correctly to prevent injection:

```python
from sqlalchemy import select

# Good - ORM with parameters
async def get_users_by_role(role: str):
    query = select(User).where(User.role == role)  # Parameterized
    result = await session.execute(query)
    return result.scalars().all()

# BAD - Raw SQL with concatenation
async def get_users_by_role_bad(role: str):
    query = f"SELECT * FROM users WHERE role = '{role}'"  # Vulnerable!
    result = await session.execute(query)
    return result.all()
```

## Cross-Site Scripting (XSS) Prevention

### Content Security Policy

Set CSP headers to prevent XSS:

```python
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)

    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self' 'unsafe-inline'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data: https:;"
    )
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"

    return response
```

### Escape User Content

Always escape user-generated content:

```python
import html
import json

# Escape for HTML
safe_html = html.escape(user_input)

# Escape for JavaScript
safe_js = json.dumps(user_input)

# Use templating engines with auto-escaping
# Jinja2 auto-escapes by default
return templates.TemplateResponse("page.html", {"content": user_input})
```

## HTTPS & Transport Security

### Enforce HTTPS

Redirect HTTP to HTTPS:

```python
@app.middleware("http")
async def https_redirect(request: Request, call_next):
    if request.url.scheme != "https" and not request.url.hostname == "localhost":
        url = request.url.replace(scheme="https")
        return RedirectResponse(url, status_code=301)

    return await call_next(request)
```

### Set HSTS Headers

```python
response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
```

## CORS Configuration

### Configure CORS Properly

Don't use wildcard origins in production:

```python
from fastapi.middleware.cors import CORSMiddleware

# BAD - Too permissive
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Anyone can call your API!
    allow_credentials=True,
)

# Good - Specific origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://myapp.com",
        "https://www.myapp.com",
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)
```

## Sensitive Data Handling

### Never Log Sensitive Data

```python
import logging

logger = logging.getLogger(__name__)

# BAD - Logs password!
logger.info(f"User {username} logging in with password {password}")

# Good - No sensitive data
logger.info(f"User {username} attempting login")

# Redact sensitive fields
def redact_sensitive(data: dict) -> dict:
    sensitive_fields = {"password", "ssn", "credit_card", "token"}
    return {
        k: "***REDACTED***" if k in sensitive_fields else v
        for k, v in data.items()
    }
```

### Hash Passwords Properly

```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Hash password
hashed = pwd_context.hash(plain_password)

# Verify password
is_valid = pwd_context.verify(plain_password, hashed)

# NEVER store passwords in plain text!
```

### Encrypt Sensitive Data

```python
from cryptography.fernet import Fernet

# Generate key (store securely, not in code!)
key = Fernet.generate_key()
cipher = Fernet(key)

# Encrypt
encrypted = cipher.encrypt(sensitive_data.encode())

# Decrypt
decrypted = cipher.decrypt(encrypted).decode()
```

## Error Handling

### Don't Leak Information in Errors

```python
# BAD - Reveals internal details
@app.get("/api/users/{user_id}")
async def get_user(user_id: str):
    try:
        user = await db.query(f"SELECT * FROM users WHERE id = {user_id}")
        return user
    except Exception as e:
        # Leaks SQL structure and database details!
        raise HTTPException(status_code=500, detail=str(e))

# Good - Generic error messages
@app.get("/api/users/{user_id}")
async def get_user(user_id: str):
    try:
        user = await User.get(id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user
    except Exception as e:
        # Log detailed error internally
        logger.error(f"Error fetching user {user_id}: {e}")
        # Return generic message to client
        raise HTTPException(status_code=500, detail="Internal server error")
```

## API Security Checklist

Before deploying any API endpoint, verify:

- [ ] Authentication required for all endpoints (except explicit public ones)
- [ ] Authorization checks enforce proper access control
- [ ] All user input validated with strict schemas
- [ ] Parameterized queries used (no SQL concatenation)
- [ ] Output properly escaped/sanitized
- [ ] Rate limiting configured
- [ ] HTTPS enforced
- [ ] Security headers set (CSP, HSTS, X-Frame-Options)
- [ ] CORS configured with specific origins (not wildcard)
- [ ] Passwords hashed with bcrypt/argon2
- [ ] Sensitive data encrypted at rest
- [ ] Error messages don't leak internal details
- [ ] Secrets stored in environment variables (not code)
- [ ] Logging doesn't include sensitive data
- [ ] Dependencies regularly updated for security patches

## Common Vulnerabilities (OWASP Top 10)

1. **Broken Access Control**: Always check authorization, not just authentication
2. **Cryptographic Failures**: Use strong algorithms, proper key management
3. **Injection**: Parameterized queries, input validation, output encoding
4. **Insecure Design**: Security by design, threat modeling
5. **Security Misconfiguration**: Secure defaults, minimal permissions
6. **Vulnerable Components**: Keep dependencies updated
7. **Authentication Failures**: Strong passwords, MFA, secure sessions
8. **Data Integrity Failures**: Sign/encrypt data, verify signatures
9. **Logging Failures**: Log security events, monitor for anomalies
10. **SSRF**: Validate/sanitize URLs, whitelist allowed destinations

## Key Takeaways

1. Require authentication and authorization for every endpoint
2. Validate all input, sanitize all output
3. Use parameterized queries to prevent SQL injection
4. Set security headers (CSP, HSTS, X-Frame-Options)
5. Configure CORS with specific origins, not wildcards
6. Hash passwords with bcrypt, never store plaintext
7. Enforce HTTPS in production
8. Rate limit endpoints to prevent abuse
9. Don't leak information in error messages
10. Log security events without sensitive data
