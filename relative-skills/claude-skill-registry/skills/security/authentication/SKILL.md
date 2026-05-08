---
name: authentication
description: Authentication and authorization including JWT, OAuth2, sessions, and RBAC. Activate for login, auth flows, security, access control, and identity management.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Authentication Skill

Provides comprehensive authentication and authorization capabilities for the Golden Armada AI Agent Fleet Platform.

## When to Use This Skill

Activate this skill when working with:
- User authentication flows
- JWT token management
- OAuth2 integration
- Session management
- Role-based access control (RBAC)

## JWT Authentication

### Token Generation
\`\`\`python
from jose import jwt
from datetime import datetime, timedelta
from passlib.context import CryptContext

SECRET_KEY = os.environ["JWT_SECRET"]
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(user_id: str, roles: list[str]) -> str:
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {
        "sub": user_id,
        "roles": roles,
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "access"
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(user_id: str) -> str:
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    payload = {
        "sub": user_id,
        "exp": expire,
        "type": "refresh"
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
\`\`\`

### Password Hashing
\`\`\`python
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# Usage
async def authenticate_user(email: str, password: str) -> User | None:
    user = await get_user_by_email(email)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user
\`\`\`

## FastAPI Auth Dependencies

\`\`\`python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/token")

async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    payload = verify_token(token)
    user = await get_user(payload["sub"])
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user

async def get_current_active_user(user: User = Depends(get_current_user)) -> User:
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return user

# Role-based access
def require_roles(*roles: str):
    async def role_checker(user: User = Depends(get_current_user)):
        if not any(role in user.roles for role in roles):
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user
    return role_checker

# Usage
@app.get("/admin")
async def admin_route(user: User = Depends(require_roles("admin"))):
    return {"message": "Admin access granted"}
\`\`\`

## OAuth2 Integration

### Google OAuth2
\`\`\`python
from authlib.integrations.starlette_client import OAuth

oauth = OAuth()
oauth.register(
    name='google',
    client_id=os.environ['GOOGLE_CLIENT_ID'],
    client_secret=os.environ['GOOGLE_CLIENT_SECRET'],
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)

@app.get('/auth/google')
async def google_login(request: Request):
    redirect_uri = request.url_for('google_callback')
    return await oauth.google.authorize_redirect(request, redirect_uri)

@app.get('/auth/google/callback')
async def google_callback(request: Request):
    token = await oauth.google.authorize_access_token(request)
    user_info = token.get('userinfo')

    # Find or create user
    user = await get_or_create_user(
        email=user_info['email'],
        name=user_info['name'],
        provider='google'
    )

    # Generate JWT
    access_token = create_access_token(user.id, user.roles)
    return {"access_token": access_token, "token_type": "bearer"}
\`\`\`

### GitHub OAuth2
\`\`\`python
oauth.register(
    name='github',
    client_id=os.environ['GITHUB_CLIENT_ID'],
    client_secret=os.environ['GITHUB_CLIENT_SECRET'],
    authorize_url='https://github.com/login/oauth/authorize',
    access_token_url='https://github.com/login/oauth/access_token',
    api_base_url='https://api.github.com/',
    client_kwargs={'scope': 'user:email'}
)
\`\`\`

## Session Management

\`\`\`python
from fastapi import Request, Response
import secrets

async def create_session(user_id: str, response: Response) -> str:
    session_id = secrets.token_urlsafe(32)

    # Store in Redis
    await redis.hset(f"session:{session_id}", mapping={
        "user_id": user_id,
        "created_at": datetime.utcnow().isoformat()
    })
    await redis.expire(f"session:{session_id}", 86400)  # 24 hours

    # Set cookie
    response.set_cookie(
        key="session_id",
        value=session_id,
        httponly=True,
        secure=True,
        samesite="lax",
        max_age=86400
    )

    return session_id

async def get_session(request: Request) -> dict | None:
    session_id = request.cookies.get("session_id")
    if not session_id:
        return None

    session = await redis.hgetall(f"session:{session_id}")
    if not session:
        return None

    # Refresh TTL
    await redis.expire(f"session:{session_id}", 86400)
    return session

async def destroy_session(request: Request, response: Response):
    session_id = request.cookies.get("session_id")
    if session_id:
        await redis.delete(f"session:{session_id}")
    response.delete_cookie("session_id")
\`\`\`

## RBAC Implementation

\`\`\`python
from enum import Enum
from typing import Set

class Permission(str, Enum):
    READ_AGENTS = "read:agents"
    WRITE_AGENTS = "write:agents"
    DELETE_AGENTS = "delete:agents"
    ADMIN = "admin"

ROLE_PERMISSIONS: dict[str, Set[Permission]] = {
    "viewer": {Permission.READ_AGENTS},
    "operator": {Permission.READ_AGENTS, Permission.WRITE_AGENTS},
    "admin": {Permission.READ_AGENTS, Permission.WRITE_AGENTS, Permission.DELETE_AGENTS, Permission.ADMIN},
}

def has_permission(user_roles: list[str], required: Permission) -> bool:
    for role in user_roles:
        if role in ROLE_PERMISSIONS and required in ROLE_PERMISSIONS[role]:
            return True
    return False

def require_permission(permission: Permission):
    async def permission_checker(user: User = Depends(get_current_user)):
        if not has_permission(user.roles, permission):
            raise HTTPException(status_code=403, detail="Permission denied")
        return user
    return permission_checker

# Usage
@app.delete("/agents/{id}")
async def delete_agent(
    id: str,
    user: User = Depends(require_permission(Permission.DELETE_AGENTS))
):
    await agent_service.delete(id)
    return {"status": "deleted"}
\`\`\`

## Security Best Practices

1. **Use HTTPS** always in production
2. **Hash passwords** with bcrypt or argon2
3. **Short-lived access tokens** (15-30 minutes)
4. **Refresh token rotation** on each use
5. **HttpOnly, Secure cookies** for tokens
6. **Rate limit** authentication endpoints
7. **Log authentication events** for auditing
8. **Implement account lockout** after failed attempts
