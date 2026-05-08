---
name: fastapi-auth-patterns
description: Implement and validate FastAPI authentication strategies including JWT tokens, OAuth2 password flows, OAuth2 scopes for permissions, and Supabase integration. Use when implementing authentication, securing endpoints, handling user login/signup, managing permissions, integrating OAuth providers, or when user mentions JWT, OAuth2, Supabase auth, protected routes, access control, role-based permissions, or authentication errors.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# FastAPI Authentication Patterns

**Purpose:** Autonomously implement, validate, and debug FastAPI authentication systems with multiple strategies.

**Activation Triggers:**
- Implementing user authentication
- Securing API endpoints
- JWT token generation/validation issues
- OAuth2 flow configuration
- Permission and role-based access control
- Supabase authentication integration
- Authentication errors (401, 403)
- Password hashing and security

**Key Resources:**
- `scripts/setup-jwt.sh` - Initialize JWT authentication system
- `scripts/validate-auth.sh` - Validate authentication configuration
- `templates/jwt_auth.py` - Complete JWT authentication implementation
- `templates/oauth2_flow.py` - OAuth2 password flow with scopes
- `templates/supabase_auth.py` - Supabase integration for FastAPI
- `examples/protected_routes.py` - Protected endpoint patterns
- `examples/permission_system.py` - Role and permission-based access

## Authentication Strategies

### 1. JWT Token Authentication

**Use When:**
- Need stateless authentication
- Building API for mobile/web clients
- Require token expiration control
- Implementing refresh token patterns

**Setup:**
```bash
./scripts/setup-jwt.sh
```

**Core Components:**
- Password hashing with Argon2 (pwdlib)
- JWT token generation with expiration
- Token validation and user extraction
- Secure secret key management

**Implementation Pattern:**
```python
# Hash passwords (never store plaintext)
password_hash = PasswordHash.recommended()
hashed = password_hash.hash(plain_password)

# Generate JWT token
def create_access_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm="HS256")

# Validate token and extract user
async def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    username = payload.get("sub")
    return get_user(username)
```

**Key Points:**
- Use environment variables for SECRET_KEY
- Default token expiration: 30 minutes
- Store username in "sub" claim
- Validate token signature and expiration

### 2. OAuth2 Password Flow

**Use When:**
- Building first-party applications
- Need username/password authentication
- Following OAuth2 standards
- Integrating with OpenAPI documentation

**Template:** `templates/oauth2_flow.py`

**Flow:**
1. User submits credentials via `OAuth2PasswordRequestForm`
2. Server verifies password hash
3. Server returns signed JWT access token
4. Client includes token in Authorization header

**Security Scheme:**
```python
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}
```

### 3. OAuth2 Scopes (Permissions)

**Use When:**
- Need fine-grained permission control
- Implementing role-based access
- Building multi-tenant systems
- Following least-privilege principle

**Template:** See `templates/oauth2_flow.py` (includes scopes)

**Define Scopes:**
```python
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="token",
    scopes={
        "me": "Read information about current user",
        "items": "Read items",
        "items:write": "Create and modify items"
    }
)
```

**Encode Scopes in Token:**
```python
# During login, add user's scopes to token
token_data = {"sub": username, "scopes": user.scopes}
access_token = create_access_token(token_data)
```

**Protect Endpoints with Scopes:**
```python
async def get_current_user(
    security_scopes: SecurityScopes,
    token: str = Depends(oauth2_scheme)
):
    # Validate token has required scopes
    for scope in security_scopes.scopes:
        if scope not in token_data.scopes:
            raise HTTPException(401, "Not enough permissions")

@app.get("/users/me/items/")
async def read_items(
    current_user: User = Security(get_current_active_user, scopes=["items"])
):
    return current_user.items
```

### 4. Supabase Authentication

**Use When:**
- Using Supabase as backend
- Need managed authentication service
- Want OAuth providers (Google, GitHub, etc.)
- Require user management dashboard

**Template:** `templates/supabase_auth.py`

**Setup:**
```python
from supabase import create_client, Client

supabase: Client = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_KEY")
)
```

**Sign Up:**
```python
# Email/password signup
response = supabase.auth.sign_up({
    "email": "user@example.com",
    "password": "secure_password",
    "options": {"data": {"full_name": "John Doe"}}
})
```

**Sign In:**
```python
response = supabase.auth.sign_in_with_password({
    "email": "user@example.com",
    "password": "secure_password"
})
access_token = response.session.access_token
```

**Validate Token in FastAPI:**
```python
async def get_current_user(token: str = Depends(oauth2_scheme)):
    # Validate Supabase JWT token
    user = supabase.auth.get_user(token)
    return user
```

**Integration Pattern:**
- Store Supabase session in HTTP-only cookies (server-side)
- Use PKCE flow for OAuth providers
- Implement token refresh logic
- Leverage Supabase RLS policies for data access

## Validation Workflow

### 1. Run Authentication Validator

```bash
./scripts/validate-auth.sh
```

**Checks Performed:**
- ✅ Required packages installed (fastapi, python-jose[cryptography], passlib[argon2], pwdlib)
- ✅ Environment variables set (SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES)
- ✅ Security scheme configured correctly
- ✅ Password hashing implemented
- ✅ Token generation and validation functions present
- ✅ Protected endpoints use proper dependencies

### 2. Common Issues & Fixes

**Missing SECRET_KEY:**
```bash
# Generate secure random key
openssl rand -hex 32

# Add to .env
echo 'SECRET_KEY=your_generated_key' >> .env
```

**Token Expired (401):**
- Increase ACCESS_TOKEN_EXPIRE_MINUTES
- Implement refresh token pattern
- Check server/client time sync

**Invalid Credentials:**
- Verify password hashing algorithm matches
- Check user exists in database
- Validate password comparison logic

**Missing Permissions (403):**
- Verify user has required scopes
- Check scope encoding in token
- Validate SecurityScopes configuration

**Supabase Connection Failed:**
- Verify SUPABASE_URL and SUPABASE_KEY
- Check project settings in Supabase dashboard
- Validate network connectivity

## Protected Routes Pattern

**Example:** `examples/protected_routes.py`

```python
# Public endpoint (no auth)
@app.get("/")
async def root():
    return {"message": "Public endpoint"}

# Protected endpoint (requires authentication)
@app.get("/users/me")
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

# Protected with specific permission
@app.post("/items/")
async def create_item(
    item: Item,
    current_user: User = Security(get_current_active_user, scopes=["items:write"])
):
    return create_item_for_user(current_user, item)

# Admin-only endpoint
@app.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(get_current_admin_user)
):
    return delete_user_by_id(user_id)
```

## Permission System Pattern

**Example:** `examples/permission_system.py`

**Role-Based Access Control (RBAC):**
```python
class Role(str, Enum):
    ADMIN = "admin"
    USER = "user"
    GUEST = "guest"

class User(BaseModel):
    username: str
    role: Role
    permissions: List[str]

def has_permission(user: User, required_permission: str) -> bool:
    # Admins have all permissions
    if user.role == Role.ADMIN:
        return True
    return required_permission in user.permissions

async def require_permission(permission: str):
    async def permission_checker(current_user: User = Depends(get_current_user)):
        if not has_permission(current_user, permission):
            raise HTTPException(403, f"Permission '{permission}' required")
        return current_user
    return permission_checker

# Usage
@app.delete("/items/{item_id}")
async def delete_item(
    item_id: int,
    current_user: User = Depends(require_permission("items:delete"))
):
    return delete_item_by_id(item_id)
```

## Best Practices

**Security:**
- Never store passwords in plaintext
- Use Argon2 for password hashing (recommended over bcrypt)
- Store SECRET_KEY in environment variables (never commit)
- Use HTTPS in production
- Implement rate limiting on login endpoints
- Add token refresh mechanism for long sessions

**Token Management:**
- Short access token expiration (15-30 minutes)
- Long refresh token expiration (7-30 days)
- Rotate refresh tokens on use
- Implement token revocation list for logout

**Scope Design:**
- Use hierarchical scopes (e.g., items, items:read, items:write)
- Follow least-privilege principle
- Document all scopes in OpenAPI
- Validate scopes on every request

**Error Handling:**
- Return 401 for authentication failures
- Return 403 for authorization failures
- Include WWW-Authenticate header with 401
- Log authentication attempts for security monitoring

## Dependencies

**Required Packages:**
```bash
pip install fastapi
pip install python-jose[cryptography]
pip install pwdlib[argon2]
pip install supabase  # If using Supabase
```

**Environment Variables:**
```
SECRET_KEY=your_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# For Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_anon_key
```

---

**Supported Auth Strategies:** JWT, OAuth2 Password Flow, OAuth2 Scopes, Supabase

**Version:** 1.0.0
**FastAPI Compatibility:** 0.100+
