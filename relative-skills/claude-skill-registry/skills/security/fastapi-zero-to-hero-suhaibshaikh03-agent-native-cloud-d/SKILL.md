---
name: fastapi-zero-to-hero
description: Complete FastAPI API development framework for Python. Provides comprehensive assistance for building APIs with routing, authentication (JWT, OAuth2, Better Auth), Pydantic models, database integration, and deployment using uv package manager. Use when users ask to build FastAPI applications, implement authentication, create API endpoints, or develop backend services in Python.
---

# FastAPI Zero to Hero - Complete API Development Framework

## Overview

This skill provides comprehensive assistance for FastAPI API development in Python, from basic setup to advanced features. It covers routing, authentication, database integration, testing, and deployment patterns using best practices with uv as the package manager.

## What This Skill Does
- Creates FastAPI project structures with recommended organization
- Implements API routing with proper error handling
- Sets up authentication systems (JWT, OAuth2, Better Auth)
- Creates Pydantic models for request/response validation
- Configures database integration (SQLAlchemy/async)
- Provides testing and deployment patterns
- Follows FastAPI best practices and security guidelines
- Uses uv package manager for dependency management

## What This Skill Does NOT Do
- Create frontend applications (React, Vue, etc.)
- Manage infrastructure (Docker, Kubernetes, cloud deployment)
- Handle specific business logic implementation beyond API patterns
- Provide complete application code without user requirements

---

## Before Implementation

Gather context to ensure successful implementation:

| Source | Gather |
|--------|--------|
| **Codebase** | Existing structure, patterns, conventions to integrate with |
| **Conversation** | User's specific API requirements, authentication needs, database preferences |
| **Skill References** | FastAPI documentation patterns, best practices, security guidelines |
| **User Guidelines** | Project-specific conventions, team standards, deployment requirements |

Ensure all required context is gathered before implementing.
Only ask user for THEIR specific requirements (domain expertise is in this skill).

---

## Required Clarifications

Ask about USER'S context (not domain knowledge):

1. **API scope**: "What specific API endpoints or functionality do you need?"
2. **Authentication**: "Which authentication method do you prefer (JWT, OAuth2, Better Auth)?"
3. **Database**: "Which database are you planning to use (PostgreSQL, MySQL, etc.)?"
4. **Deployment**: "Where do you plan to deploy the API (Docker, cloud, etc.)?"

---

## Workflow

1. Set up project structure and dependencies with uv
2. Create basic FastAPI application with proper configuration
3. Implement authentication system based on requirements
4. Design Pydantic models for data validation
5. Set up database integration with SQLAlchemy
6. Create API routes with proper error handling
7. Add testing framework and write tests
8. Prepare deployment configuration

---

## Project Setup with uv

### Installation with uv (recommended package manager)
```bash
# Install FastAPI with standard dependencies using uv
uv add "fastapi[standard]"
uv add uvicorn[standard]
uv add python-jose[cryptography]
uv add passlib[bcrypt]
uv add python-multipart
uv add sqlalchemy
uv add asyncpg  # For PostgreSQL async support
uv add python-dotenv
uv add pytest
uv add pytest-asyncio
uv add httpx  # For testing
```

### Alternative: Install all dependencies at once
```bash
uv add "fastapi[standard]" uvicorn python-jose passlib python-multipart sqlalchemy asyncpg python-dotenv pytest pytest-asyncio httpx
```

### Recommended Project Structure
```
my-fastapi-project/
├── main.py                 # Application entry point
├── app/
│   ├── __init__.py
│   ├── main.py            # FastAPI app instance
│   ├── api/
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   └── routes/
│   │   │       ├── __init__.py
│   │   │       ├── users.py
│   │   │       └── items.py
│   ├── models/            # Pydantic models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── item.py
│   ├── schemas/           # Database schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── item.py
│   ├── database/
│   │   ├── __init__.py
│   │   └── database.py
│   ├── auth/
│   │   ├── __init__.py
│   │   └── auth.py
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_users.py
│   └── test_items.py
├── requirements.txt
├── .env
├── .gitignore
└── README.md
```

---

## Core FastAPI Application Structure

### main.py - Application Entry Point with Advanced Configuration
```python
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import uvicorn
import os
import logging
import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    logger.info("Starting up...")
    # Initialize database connections, cache, etc.
    # Example: await database.connect()
    yield
    # Shutdown logic
    logger.info("Shutting down...")
    # Cleanup: await database.disconnect()

# Create FastAPI app with lifespan and comprehensive configuration
app = FastAPI(
    title="My FastAPI Application",
    description="A comprehensive API built with FastAPI",
    version="1.0.0",
    lifespan=lifespan,
    # Additional configuration
    docs_url="/docs",  # Swagger UI
    redoc_url="/redoc",  # ReDoc
    openapi_url="/openapi.json",  # OpenAPI schema
)

# Add CORS middleware
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("ALLOWED_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    # Allow specific headers for auth
    allow_credentials=True,
    allow_headers=["*"],
)

# Global request/response logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Request: {request.method} {request.url}")
    response = await call_next(request)
    logger.info(f"Response status: {response.status_code}")
    return response

# Exception handlers
@app.exception_handler(500)
async def internal_exception_handler(request: Request, exc: Exception):
    logger.error(f"Internal server error: {exc}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"}
    )

@app.get("/")
async def root():
    return {"message": "Welcome to FastAPI!", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.datetime.utcnow()}

# Include API routes
from app.api.v1 import router as api_v1_router
app.include_router(api_v1_router, prefix="/api/v1")

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        reload=bool(os.getenv("DEBUG", "False").lower() == "true"),
        log_level=os.getenv("LOG_LEVEL", "info")
    )
```

### Advanced Routing and Path Operations
```python
from fastapi import APIRouter, Path, Query, Body, status
from typing import List, Optional, Union
from pydantic import BaseModel, Field
import datetime

# Create API router
router = APIRouter(prefix="/users", tags=["users"])

# Path parameters with validation
@router.get("/{user_id}", summary="Get user by ID")
async def get_user(
    user_id: int = Path(..., ge=1, description="The ID of the user to retrieve"),
):
    """
    Retrieve a user by ID.

    - **user_id**: The unique identifier of the user
    """
    # Implementation here
    return {"user_id": user_id}

# Query parameters with advanced validation
@router.get("/", summary="Get multiple users")
async def get_users(
    skip: int = Query(0, ge=0, description="Number of users to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of users to return"),
    q: Optional[str] = Query(None, description="Search query"),
    active_only: bool = Query(False, description="Only return active users"),
):
    """
    Get a list of users with pagination and filtering.
    """
    # Implementation here
    return {"skip": skip, "limit": limit, "q": q, "active_only": active_only}

# Request body with Pydantic model
@router.post("/", status_code=status.HTTP_201_CREATED, summary="Create new user")
async def create_user(user: UserCreate):
    """
    Create a new user.

    - **email**: User's email address
    - **username**: User's unique username
    - **full_name**: Optional full name
    """
    # Implementation here
    return user

# Multiple body parameters and query parameters
@router.put("/{user_id}", summary="Update user")
async def update_user(
    user_id: int,
    user_update: UserUpdate = Body(..., embed=True),
    notify: bool = Query(False, description="Send notification to user"),
):
    """
    Update an existing user.
    """
    # Implementation here
    return {"user_id": user_id, "update": user_update, "notify": notify}

# Response models and status codes
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete user")
async def delete_user(user_id: int):
    """
    Delete a user by ID.
    """
    # Implementation here (no return for 204)
    return

# File uploads
from fastapi import UploadFile, File
from typing import List

@router.post("/upload", summary="Upload file")
async def upload_file(file: UploadFile = File(...)):
    """
    Upload a single file.
    """
    contents = await file.read()
    return {
        "filename": file.filename,
        "content_type": file.content_type,
        "size": len(contents)
    }

@router.post("/uploads", summary="Upload multiple files")
async def upload_files(files: List[UploadFile] = File(...)):
    """
    Upload multiple files.
    """
    results = []
    for file in files:
        contents = await file.read()
        results.append({
            "filename": file.filename,
            "content_type": file.content_type,
            "size": len(contents)
        })
    return {"files": results}
```

### Dependency Injection Advanced Patterns
```python
from fastapi import Depends, Header, HTTPException
from typing import Optional
import secrets

# Simple dependency
async def common_parameters(
    q: Optional[str] = None,
    skip: int = 0,
    limit: int = 100
):
    return {"q": q, "skip": skip, "limit": limit}

# Dependency with sub-dependencies
async def verify_token(x_token: str = Header(...)):
    if not secrets.compare_digest(x_token, "fake-super-secret-token"):
        raise HTTPException(status_code=400, detail="X-Token header invalid")

async def verify_key(x_key: str = Header(...)):
    if x_key != "fake-super-secret-key":
        raise HTTPException(status_code=400, detail="X-Key header invalid")
    return x_key

# Complex dependency with database session
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db_session() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

# Dependency with authentication
async def get_current_user(
    token: str = Depends(verify_token),
    db: AsyncSession = Depends(get_db_session)
):
    # In real app, retrieve user from database using token
    user = await get_user_from_token(db, token)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user

# Dependency with validation
async def get_validated_user(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session)
):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# Usage in route with multiple dependencies
@router.get("/me")
async def read_users_me(
    current_user: User = Depends(get_validated_user)
):
    return current_user
```

### Background Tasks
```python
from fastapi import BackgroundTasks
import asyncio

def send_email_task(email: str, message: str):
    """Simulate sending an email in the background"""
    print(f"Sending email to {email}: {message}")
    # In real app: send actual email
    time.sleep(2)  # Simulate async operation
    print("Email sent!")

@router.post("/send-email")
async def send_email(
    email: str,
    background_tasks: BackgroundTasks
):
    """
    Send email in background task.
    """
    background_tasks.add_task(send_email_task, email, "Welcome to our service!")
    return {"message": "Email will be sent in background"}
```

### Custom Response Classes
```python
from fastapi.responses import ORJSONResponse, UJSONResponse, HTMLResponse
from fastapi import Response

# Custom JSON response for performance
@router.get("/optimized-json", response_class=ORJSONResponse)
async def get_optimized_json():
    return {"message": "This uses orjson for faster serialization"}

# HTML response
@router.get("/html", response_class=HTMLResponse)
async def get_html():
    return """
    <html>
        <head>
            <title>FastAPI HTML Response</title>
        </head>
        <body>
            <h1>Hello from FastAPI!</h1>
        </body>
    </html>
    """

# Custom response with headers
@router.get("/custom-response")
async def get_custom_response(response: Response):
    response.headers["X-Custom-Header"] = "Custom value"
    return {"message": "Response with custom header"}
```

---

## Authentication Systems

### JWT Authentication with Security Best Practices
```python
from datetime import datetime, timedelta
from typing import Optional
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
import secrets
import os
import bcrypt

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 scheme
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=True)

# Security configuration
SECRET_KEY = os.getenv("SECRET_KEY", secrets.token_urlsafe(32))
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

class Token(BaseModel):
    access_token: str
    token_type: str
    refresh_token: Optional[str] = None

class TokenData(BaseModel):
    username: Optional[str] = None
    scopes: list[str] = []

class UserBase(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None

class User(UserBase):
    is_active: bool = True
    is_admin: bool = False

class UserInDB(User):
    hashed_password: str

class UserCreate(BaseModel):
    username: str
    email: str
    password: str
    full_name: Optional[str] = None

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def get_user(db, username: str) -> Optional[UserInDB]:
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)
    return None

async def authenticate_user(db, username: str, password: str):
    user = get_user(db, username)
    if not user:
        # Run verification to prevent timing attacks
        verify_password(password, "dummy_hash")
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        token_type: str = payload.get("type")

        if username is None:
            raise credentials_exception
        if token_type != "access":
            raise credentials_exception

        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception

    # In a real application, fetch from database
    user = get_user(fake_users_db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

async def get_current_admin_user(current_user: User = Depends(get_current_active_user)):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return current_user

# Example database
fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": get_password_hash("secret"),
        "disabled": False,
        "is_active": True,
        "is_admin": False,
    },
    "admin": {
        "username": "admin",
        "full_name": "Admin User",
        "email": "admin@example.com",
        "hashed_password": get_password_hash("admin_secret"),
        "disabled": False,
        "is_active": True,
        "is_admin": True,
    }
}

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await authenticate_user(fake_users_db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "scopes": ["user"]},
        expires_delta=access_token_expires
    )

    refresh_token = create_refresh_token(data={"sub": user.username})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "refresh_token": refresh_token
    }

@app.get("/users/me/", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

# Token refresh endpoint
@app.post("/token/refresh")
async def refresh_access_token(refresh_token: str):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        token_type: str = payload.get("type")

        if username is None or token_type != "refresh":
            raise HTTPException(status_code=401, detail="Invalid refresh token")

        # Create new access token
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        new_access_token = create_access_token(
            data={"sub": username, "scopes": ["user"]},
            expires_delta=access_token_expires
        )

        return {"access_token": new_access_token, "token_type": "bearer"}
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
```

### OAuth2 with Authorization Code Flow (Google, GitHub, etc.)
```python
from fastapi import Request
from fastapi.responses import RedirectResponse, JSONResponse
from authlib.integrations.starlette_client import OAuth
import os
from urllib.parse import urlencode

# OAuth setup for Google, GitHub, etc.
oauth = OAuth()

# Register Google OAuth
oauth.register(
    name='google',
    client_id=os.getenv('GOOGLE_CLIENT_ID'),
    client_secret=os.getenv('GOOGLE_CLIENT_SECRET'),
    server_metadata_url='https://accounts.google.com/.well-known/openid_configuration',
    client_kwargs={
        'scope': 'openid email profile'
    }
)

# Register GitHub OAuth
oauth.register(
    name='github',
    client_id=os.getenv('GITHUB_CLIENT_ID'),
    client_secret=os.getenv('GITHUB_CLIENT_SECRET'),
    access_token_url='https://github.com/login/oauth/token',
    authorize_url='https://github.com/login/oauth/authorize',
    api_base_url='https://api.github.com/',
    client_kwargs={'scope': 'user:email'}
)

@app.route('/auth/{provider}/login')
async def auth_login(request: Request, provider: str):
    if provider not in ['google', 'github']:
        raise HTTPException(status_code=404, detail="Provider not supported")

    redirect_uri = request.url_for(f'auth_{provider}_callback')
    return await oauth.create_client(provider).authorize_redirect(request, redirect_uri)

@app.route('/auth/{provider}/callback')
async def auth_provider_callback(request: Request, provider: str):
    try:
        token = await oauth.create_client(provider).authorize_access_token(request)
        user_info = token.get('userinfo') or await oauth.create_client(provider).userinfo(token=token)

        # Process user data and create session
        # In real app: create user in database if doesn't exist, create JWT token
        access_token = create_access_token(data={"sub": user_info.get('email', user_info.get('login'))})

        # Redirect to frontend with token (in real app, you might use a frontend URL)
        params = urlencode({"token": access_token})
        return RedirectResponse(url=f"/auth/success?{params}")

    except Exception as e:
        print(f"OAuth error: {e}")
        return JSONResponse(status_code=400, content={"detail": "Authentication failed"})

import base64
import hashlib

# OAuth2 with PKCE (Proof Key for Code Exchange) for SPA security
@app.get('/auth/{provider}/pkce')
async def auth_pkce_init(request: Request, provider: str):
    if provider not in ['google', 'github']:
        raise HTTPException(status_code=404, detail="Provider not supported")

    # Generate code verifier and challenge
    code_verifier = secrets.token_urlsafe(32)
    code_challenge = base64.urlsafe_b64encode(
        hashlib.sha256(code_verifier.encode()).digest()
    ).decode().rstrip('=')

    # Store code_verifier in session or temporary storage
    request.session['code_verifier'] = code_verifier

    redirect_uri = request.url_for(f'auth_{provider}_callback')
    return await oauth.create_client(provider).authorize_redirect(
        request,
        redirect_uri,
        code_challenge=code_challenge,
        code_challenge_method='S256'
    )
```

### API Key Authentication
```python
from fastapi.security import APIKeyHeader, APIKeyQuery
from typing import Optional
from fastapi import Security

# API Key authentication
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)
api_key_query = APIKeyQuery(name="api_key", auto_error=False)

API_KEYS = os.getenv("API_KEYS", "").split(",")

async def get_api_key(api_key_header: str = Security(api_key_header),
                     api_key_query: str = Security(api_key_query)):
    api_key = api_key_header or api_key_query
    if api_key and api_key in API_KEYS:
        return api_key
    else:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API Key"
        )

@app.get("/api/protected-endpoint")
async def protected_endpoint(api_key: str = Security(get_api_key)):
    return {"message": "Access granted with API key", "key": api_key[:8] + "..." if api_key else None}
```

### Better Auth Integration (Alternative approach)
```python
# Better Auth is typically a frontend authentication solution
# For backend integration, you might implement custom auth middleware
from fastapi import Request, HTTPException
import jwt
import os
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

# For Better Auth integration, you would typically:
# 1. Verify the session token from Better Auth
# 2. Extract user information
# 3. Potentially sync with your own user system

async def verify_better_auth_session(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Not authenticated")

    token = auth_header.split(" ")[1]
    try:
        # In a real Better Auth integration, you would:
        # - Fetch the public key from Better Auth
        # - Verify the JWT signature
        # - Extract user information

        # Example with a public key (in real app, fetch from Better Auth API)
        public_key_pem = os.getenv("BETTER_AUTH_PUBLIC_KEY")
        if not public_key_pem:
            raise HTTPException(status_code=500, detail="Public key not configured")

        # Load public key
        public_key = serialization.load_pem_public_key(
            public_key_pem.encode(),
            backend=default_backend()
        )

        # Verify token
        payload = jwt.decode(
            token,
            public_key,
            algorithms=["RS256"]
        )

        # Return user information from the token
        return {
            "user_id": payload.get("userId"),
            "email": payload.get("email"),
            "name": payload.get("name"),
            "exp": payload.get("exp")
        }
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
    except Exception as e:
        print(f"Better Auth verification error: {e}")
        raise HTTPException(status_code=401, detail="Authentication failed")

# Example usage in a route
@app.get("/better-auth-protected")
async def better_auth_protected_route(user_info: dict = Depends(verify_better_auth_session)):
    return {"message": "Access granted", "user": user_info}
```

### Role-Based Access Control (RBAC)
```python
from enum import Enum
from functools import wraps
from typing import List

class Role(str, Enum):
    USER = "user"
    MODERATOR = "moderator"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"

def require_role(required_roles: List[Role]):
    def role_checker(current_user: User = Depends(get_current_active_user)):
        if current_user.is_admin or current_user.username == "admin":
            return current_user

        user_role = getattr(current_user, 'role', Role.USER)
        if user_role not in required_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required roles: {', '.join([role.value for role in required_roles])}"
            )
        return current_user
    return role_checker

# Usage examples
@app.get("/admin-panel", dependencies=[Depends(require_role([Role.ADMIN, Role.SUPER_ADMIN]))])
async def admin_panel(current_user: User = Depends(get_current_active_user)):
    return {"message": "Admin panel access granted", "user": current_user.username}

@app.get("/moderator-panel", dependencies=[Depends(require_role([Role.MODERATOR, Role.ADMIN, Role.SUPER_ADMIN]))])
async def moderator_panel(current_user: User = Depends(get_current_active_user)):
    return {"message": "Moderator panel access granted", "user": current_user.username}
```

### Security Headers and Rate Limiting
```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

# Rate limiting
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.get("/limited-endpoint")
@limiter.limit("5/minute")  # 5 requests per minute per IP
async def limited_endpoint(request: Request):
    return {"message": "This endpoint is rate limited"}

# Security headers middleware
from starlette.middleware.base import BaseHTTPMiddleware

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        return response

app.add_middleware(SecurityHeadersMiddleware)
```

---

## Pydantic Models

### Advanced Pydantic Models with Validation
```python
from pydantic import (
    BaseModel,
    EmailStr,
    field_validator,
    field_serializer,
    model_validator,
    ConfigDict,
    Field,
    HttpUrl,
    AnyUrl
)
from typing import Optional, List, Dict, Any, Union
from datetime import datetime, date
from enum import Enum
import re
import uuid

# Configuration model
class DatabaseConfig(BaseModel):
    host: str = Field(..., description="Database host")
    port: int = Field(5432, ge=1, le=65535, description="Database port")
    database: str = Field(..., description="Database name")
    username: str = Field(..., description="Database username")
    password: str = Field(..., description="Database password")

    model_config = ConfigDict(extra="forbid")  # Forbid extra fields

# Custom field types and validators
class PyObjectId(str):
    @classmethod
    def __get_pydantic_core_schema__(cls, source_type, handler):
        return handler(str)

class UserRole(str, Enum):
    USER = "user"
    MODERATOR = "moderator"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"

class UserBase(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50, pattern=r'^[a-zA-Z0-9_]+$')
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)
    bio: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[HttpUrl] = None

    @field_validator('username')
    @classmethod
    def username_alphanumeric(cls, v):
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('Username must contain only letters, numbers, and underscores')
        return v

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)
    confirm_password: str

    @model_validator(mode='after')
    def passwords_match(self):
        if self.password != self.confirm_password:
            raise ValueError('Passwords do not match')
        return self

    @field_validator('password')
    @classmethod
    def validate_password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one digit')
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError('Password must contain at least one special character')
        return v

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)
    bio: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[HttpUrl] = None

class UserResponse(UserBase):
    id: PyObjectId
    created_at: datetime
    updated_at: Optional[datetime] = None
    is_active: bool = True
    role: UserRole = UserRole.USER
    email_verified: bool = False

    model_config = ConfigDict(from_attributes=True)  # For ORM compatibility

    @field_serializer('id')
    def serialize_id(self, value: PyObjectId) -> str:
        return str(value)

    @field_serializer('created_at', 'updated_at')
    def serialize_datetime(self, value: datetime) -> str:
        return value.isoformat() if value else None

class UserProfileResponse(BaseModel):
    user: UserResponse
    posts_count: int = 0
    followers_count: int = 0
    following_count: int = 0
    is_following: bool = False

# Item/Resource models
class ItemStatus(str, Enum):
    DRAFT = "draft"
    PUBLISHED = "published"
    ARCHIVED = "archived"

class ItemBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=10000)
    price: float = Field(..., gt=0)
    tags: List[str] = Field(default_factory=list, max_items=10)
    metadata: Dict[str, Any] = Field(default_factory=dict)

    @field_validator('tags')
    @classmethod
    def validate_tags(cls, v):
        if len(v) > 10:
            raise ValueError('Maximum 10 tags allowed')
        for tag in v:
            if len(tag) > 50:
                raise ValueError('Tag must be less than 50 characters')
        return v

class ItemCreate(ItemBase):
    is_public: bool = True

class ItemUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=10000)
    price: Optional[float] = Field(None, gt=0)
    tags: Optional[List[str]] = Field(None, max_items=10)
    status: Optional[ItemStatus] = None
    is_public: Optional[bool] = None
    metadata: Optional[Dict[str, Any]] = Field(None)

class ItemResponse(ItemBase):
    id: PyObjectId
    owner_id: PyObjectId
    created_at: datetime
    updated_at: Optional[datetime] = None
    status: ItemStatus = ItemStatus.DRAFT
    is_public: bool = True
    views_count: int = 0
    likes_count: int = 0
    is_liked: bool = False

    model_config = ConfigDict(from_attributes=True)

    @field_serializer('id', 'owner_id')
    def serialize_id(self, value: PyObjectId) -> str:
        return str(value)

    @field_serializer('created_at', 'updated_at')
    def serialize_datetime(self, value: datetime) -> str:
        return value.isoformat() if value else None

# Pagination models
class PaginationParams(BaseModel):
    page: int = Field(1, ge=1)
    limit: int = Field(20, ge=1, le=100)
    sort_by: str = "created_at"
    sort_order: str = Field("desc", pattern=r"^(asc|desc)$")

    @property
    def offset(self) -> int:
        return (self.page - 1) * self.limit

class PaginationResponse(BaseModel):
    total: int
    page: int
    limit: int
    pages: int
    has_next: bool
    has_prev: bool

class PaginatedResponse(BaseModel):
    items: List[ItemResponse]
    pagination: PaginationResponse

# File upload models
class FileUpload(BaseModel):
    filename: str
    content_type: str
    size: int = Field(..., gt=0, le=10 * 1024 * 1024)  # Max 10MB
    url: HttpUrl

class BulkOperationResult(BaseModel):
    success_count: int
    failure_count: int
    errors: List[Dict[str, Any]] = Field(default_factory=list)

# API Response models
class ApiResponse(BaseModel):
    success: bool = True
    message: str
    data: Optional[Any] = None
    error_code: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str
    refresh_token: Optional[str] = None
    expires_in: Optional[int] = None

class TokenData(BaseModel):
    username: Optional[str] = None
    scopes: List[str] = Field(default_factory=list)

# Error response model
class ErrorResponse(BaseModel):
    detail: str
    error_code: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)

# Configuration models for different environments
class Settings(BaseModel):
    app_name: str = "FastAPI App"
    app_version: str = "1.0.0"
    debug: bool = False
    database_url: str
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    allowed_origins: List[str] = Field(default_factory=list)

    model_config = ConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

# Webhook payload model
class WebhookPayload(BaseModel):
    event_type: str
    event_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    data: Dict[str, Any]
    signature: Optional[str] = None

# Search query model
class SearchQuery(BaseModel):
    q: str = Field(..., min_length=1, max_length=100, description="Search query")
    filters: Dict[str, Any] = Field(default_factory=dict)
    page: int = Field(1, ge=1)
    limit: int = Field(20, ge=1, le=100)
    sort_by: Optional[str] = "created_at"
    sort_order: str = Field("desc", pattern=r"^(asc|desc)$")
```

### Custom Pydantic Data Types and Validators
```python
from pydantic import BaseModel, field_validator
from typing import Optional
import phonenumbers
from phonenumbers import NumberParseException
import ipaddress
from pydantic.functional_validators import AfterValidator
from typing_extensions import Annotated
import json

# Custom phone number validator
def validate_phone_number(v: str) -> str:
    try:
        parsed = phonenumbers.parse(v, None)
        if not phonenumbers.is_valid_number(parsed):
            raise ValueError("Invalid phone number")
        return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)
    except NumberParseException:
        raise ValueError("Invalid phone number format")

PhoneNumber = Annotated[str, AfterValidator(validate_phone_number)]

# Custom IP address validator
def validate_ip_address(v: str) -> str:
    try:
        ipaddress.IPv4Address(v)
        return v
    except ipaddress.AddressValueError:
        raise ValueError("Invalid IP address")

IPAddress = Annotated[str, AfterValidator(validate_ip_address)]

# Custom JSON validator
def validate_json(v: Union[str, dict]) -> dict:
    if isinstance(v, dict):
        return v
    try:
        return json.loads(v)
    except json.JSONDecodeError:
        raise ValueError("Invalid JSON")

JSONType = Annotated[Union[str, dict], AfterValidator(validate_json)]

class ContactInfo(BaseModel):
    phone: Optional[PhoneNumber] = None
    ip_address: Optional[IPAddress] = None
    metadata: Optional[JSONType] = None
    tags: List[str] = Field(default_factory=list)

# Custom validator for complex business logic
class Product(BaseModel):
    name: str
    price: float
    category: str
    tags: List[str] = []
    inventory: int = Field(..., ge=0)
    is_available: bool = True

    @model_validator(mode='after')
    def check_availability(self):
        if self.inventory == 0:
            self.is_available = False
        elif self.inventory > 0 and not self.is_available:
            # If inventory exists but product is marked unavailable, raise warning
            print(f"Warning: Product {self.name} has inventory but is marked as unavailable")
        return self

    @field_validator('tags')
    @classmethod
    def validate_tags_unique(cls, v):
        if len(v) != len(set(v)):
            raise ValueError('Tags must be unique')
        return v
```

### Nested Models and Relationships
```python
from typing import List, Optional
from pydantic import BaseModel, Field

class Address(BaseModel):
    street: str
    city: str
    state: str
    zip_code: str = Field(..., pattern=r'^\d{5}(-\d{4})?$')
    country: str = "US"

class Company(BaseModel):
    id: Optional[PyObjectId] = None
    name: str
    description: Optional[str] = None
    website: Optional[HttpUrl] = None
    address: Optional[Address] = None

class UserWithCompany(UserResponse):
    company: Optional[Company] = None
    colleagues: List[UserResponse] = Field(default_factory=list)

class OrderItem(BaseModel):
    product_id: PyObjectId
    quantity: int = Field(..., ge=1)
    price: float = Field(..., ge=0)

class Order(BaseModel):
    id: Optional[PyObjectId] = None
    user_id: PyObjectId
    items: List[OrderItem]
    total_amount: float = Field(..., ge=0)
    status: str = "pending"
    shipping_address: Address
    billing_address: Optional[Address] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

    @field_validator('items')
    @classmethod
    def validate_items_not_empty(cls, v):
        if not v:
            raise ValueError('Order must have at least one item')
        return v

    @property
    def calculated_total(self) -> float:
        return sum(item.price * item.quantity for item in self.items)
```

---

## Database Integration

### SQLAlchemy Async Setup with Advanced Configuration
```python
from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    DateTime,
    Boolean,
    Float,
    Text,
    Index,
    ForeignKey,
    UniqueConstraint,
    text
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.pool import AsyncAdaptedQueuePool
from datetime import datetime
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database URL configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:password@localhost/dbname")

# Async engine with connection pooling
async_engine = create_async_engine(
    DATABASE_URL,
    poolclass=AsyncAdaptedQueuePool,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,  # Verify connections before use
    pool_recycle=300,    # Recycle connections after 5 minutes
    echo=bool(os.getenv("DB_ECHO", "False").lower() == "true")  # Enable SQL logging in debug
)

AsyncSessionLocal = sessionmaker(
    async_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Sync engine for non-async operations
sync_engine = create_engine(
    DATABASE_URL.replace("postgresql+asyncpg", "postgresql"),
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    pool_recycle=300,
    echo=bool(os.getenv("DB_ECHO", "False").lower() == "true")
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=sync_engine)

Base = declarative_base()

# Dependency to get DB session
async def get_async_db():
    async with AsyncSessionLocal() as db:
        try:
            yield db
        finally:
            await db.close()

def get_sync_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Enhanced Base class with common columns
class TimestampMixin:
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

class BaseModel(Base, TimestampMixin):
    __abstract__ = True
    id = Column(Integer, primary_key=True, index=True)

# User model with relationships
class User(BaseModel):
    __tablename__ = "users"

    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(50), unique=True, index=True, nullable=False)
    full_name = Column(String(100))
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    role = Column(String(20), default="user", nullable=False)

    # Relationships
    items = relationship("Item", back_populates="owner", cascade="all, delete-orphan")
    profile = relationship("UserProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")

    # Indexes for performance
    __table_args__ = (
        Index('idx_user_email', 'email'),
        Index('idx_user_username', 'username'),
        Index('idx_user_active', 'is_active'),
    )

class UserProfile(BaseModel):
    __tablename__ = "user_profiles"

    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    bio = Column(Text)
    avatar_url = Column(String(500))
    phone = Column(String(20))
    birth_date = Column(DateTime)

    # Relationship
    user = relationship("User", back_populates="profile")

class Item(BaseModel):
    __tablename__ = "items"

    title = Column(String(200), nullable=False)
    description = Column(Text)
    price = Column(Float, nullable=False)
    is_public = Column(Boolean, default=False, nullable=False)
    status = Column(String(20), default="draft", nullable=False)
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # Relationships
    owner = relationship("User", back_populates="items")
    tags = relationship("ItemTag", back_populates="item", cascade="all, delete-orphan")

    # Indexes
    __table_args__ = (
        Index('idx_item_owner', 'owner_id'),
        Index('idx_item_public', 'is_public'),
        Index('idx_item_status', 'status'),
    )

class ItemTag(BaseModel):
    __tablename__ = "item_tags"

    item_id = Column(Integer, ForeignKey("items.id"), nullable=False)
    tag_name = Column(String(50), nullable=False)

    # Relationships
    item = relationship("Item", back_populates="tags")

    # Composite index
    __table_args__ = (
        UniqueConstraint('item_id', 'tag_name', name='uq_item_tag'),
        Index('idx_item_tag_name', 'tag_name'),
    )

# Audit log model for tracking changes
class AuditLog(BaseModel):
    __tablename__ = "audit_logs"

    table_name = Column(String(100), nullable=False)
    record_id = Column(Integer, nullable=False)
    action = Column(String(20), nullable=False)  # CREATE, UPDATE, DELETE
    old_values = Column(Text)  # JSON string of old values
    new_values = Column(Text)  # JSON string of new values
    user_id = Column(Integer, ForeignKey("users.id"))
    timestamp = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User")

# Database utility functions
async def init_db():
    """Initialize database tables"""
    async with async_engine.begin() as conn:
        # Create all tables
        await conn.run_sync(Base.metadata.create_all)
        logger.info("Database tables created successfully")

async def drop_db():
    """Drop all database tables (use with caution!)"""
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        logger.info("Database tables dropped successfully")

# Database session manager with transaction support
from contextlib import asynccontextmanager

@asynccontextmanager
async def get_db_session():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

### Async Database Operations and Repository Pattern
```python
from typing import List, Optional, Dict, Any
from sqlalchemy import select, update, delete, and_, or_, func
from sqlalchemy.orm import selectinload
from sqlalchemy.exc import IntegrityError
import json

class BaseRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, model, **kwargs):
        """Create a new record"""
        try:
            instance = model(**kwargs)
            self.session.add(instance)
            await self.session.commit()
            await self.session.refresh(instance)
            return instance
        except IntegrityError as e:
            await self.session.rollback()
            raise ValueError(f"Integrity error: {str(e)}")

    async def get_by_id(self, model, id: int):
        """Get a record by ID"""
        stmt = select(model).where(model.id == id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_ids(self, model, ids: List[int]):
        """Get multiple records by IDs"""
        stmt = select(model).where(model.id.in_(ids))
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def update(self, model, id: int, **kwargs):
        """Update a record by ID"""
        stmt = update(model).where(model.id == id).values(**kwargs)
        result = await self.session.execute(stmt)

        if result.rowcount == 0:
            return None

        await self.session.commit()

        # Return updated record
        return await self.get_by_id(model, id)

    async def delete(self, model, id: int):
        """Delete a record by ID"""
        stmt = delete(model).where(model.id == id)
        result = await self.session.execute(stmt)

        if result.rowcount == 0:
            return False

        await self.session.commit()
        return True

    async def list(self, model, skip: int = 0, limit: int = 100, **filters):
        """List records with pagination and filtering"""
        stmt = select(model)

        # Apply filters
        if filters:
            conditions = []
            for key, value in filters.items():
                if hasattr(model, key):
                    if isinstance(value, list):
                        conditions.append(getattr(model, key).in_(value))
                    else:
                        conditions.append(getattr(model, key) == value)
            if conditions:
                stmt = stmt.where(and_(*conditions))

        stmt = stmt.offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def count(self, model, **filters):
        """Count records with filters"""
        stmt = select(func.count(model.id))

        if filters:
            conditions = []
            for key, value in filters.items():
                if hasattr(model, key):
                    if isinstance(value, list):
                        conditions.append(getattr(model, key).in_(value))
                    else:
                        conditions.append(getattr(model, key) == value)
            if conditions:
                stmt = stmt.where(and_(*conditions))

        result = await self.session.execute(stmt)
        return result.scalar_one()

class UserRepository(BaseRepository):
    async def get_by_username(self, username: str):
        """Get user by username"""
        stmt = select(User).where(User.username == username)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str):
        """Get user by email"""
        stmt = select(User).where(User.email == email)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_active_users(self, skip: int = 0, limit: int = 100):
        """Get active users with pagination"""
        stmt = select(User).where(User.is_active == True).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def search_users(self, query: str, skip: int = 0, limit: int = 100):
        """Search users by username or email"""
        search_filter = or_(
            User.username.contains(query),
            User.email.contains(query),
            User.full_name.contains(query) if query else False
        )
        stmt = select(User).where(search_filter).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

class ItemRepository(BaseRepository):
    async def get_by_owner(self, owner_id: int, skip: int = 0, limit: int = 100):
        """Get items by owner"""
        stmt = select(Item).where(Item.owner_id == owner_id).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_public_items(self, skip: int = 0, limit: int = 100):
        """Get public items"""
        stmt = select(Item).where(Item.is_public == True).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_items_with_tags(self, tag_names: List[str], skip: int = 0, limit: int = 100):
        """Get items that have specific tags"""
        stmt = (
            select(Item)
            .join(ItemTag)
            .where(ItemTag.tag_name.in_(tag_names))
            .offset(skip)
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_items_with_eager_loading(self, skip: int = 0, limit: int = 100):
        """Get items with owner data loaded eagerly"""
        stmt = (
            select(Item)
            .options(selectinload(Item.owner))
            .offset(skip)
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

# Example usage in API endpoints
from fastapi import Depends, HTTPException, status

async def get_user_repository(db: AsyncSession = Depends(get_async_db)) -> UserRepository:
    return UserRepository(db)

async def get_item_repository(db: AsyncSession = Depends(get_async_db)) -> ItemRepository:
    return ItemRepository(db)

# Example endpoints using repositories
@router.get("/users/{user_id}")
async def get_user(
    user_id: int,
    repo: UserRepository = Depends(get_user_repository)
):
    user = await repo.get_by_id(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.get("/users/{user_id}/items")
async def get_user_items(
    user_id: int,
    skip: int = 0,
    limit: int = 100,
    repo: ItemRepository = Depends(get_item_repository)
):
    items = await repo.get_by_owner(user_id, skip, limit)
    return items
```

### Database Migrations with Alembic
```python
# alembic.ini configuration example
"""
[alembic]
# path to migration scripts
script_location = alembic

# template used to generate migration files
# file_template = %%(rev)s_%%(slug)s

# sys.path path, will be prepended to sys.path if present.
# defaults to the current working directory.
prepend_sys_path = .

# timezone to use when rendering the date within the migration file
# as well as the filename.
# If specified, requires the python-dateutil library that can be
# installed by adding `alembic[tz]` to the pip requirements
# string value is passed to dateutil.tz.gettz()
# leave blank for localtime
# timezone =

# max length of characters to apply to the
# "slug" field
# max_length = 40

# version number format
# version_num_format = %04d

# version path separator; As mentioned above, this is the character used to split
# version_locations. The default within new alembic.ini files is "os", which uses
# os.pathsep. If this key is omitted entirely, it falls back to the legacy
# behavior of splitting on spaces and/or commas.
# Valid values for version_path_separator are:
#
# version_path_separator = :
# version_path_separator = ;
# version_path_separator = space
version_path_separator = os  # Use os.pathsep. Default configuration used for new projects.

# the output encoding used when revision files
# are written from script.py.mako
# output_encoding = utf-8

sqlalchemy.url = driver://user:pass@localhost/dbname


[post_write_hooks]
# post_write_hooks defines scripts or Python functions that are invoked
# automatically whenever a new revision file is created.
# Options include:
#
# hooks = black, isort
# black.type = exec
# black.executable = black
# black.args = -l 79 REVISION_SCRIPT_FILENAME
# isort.type = exec
# isort.executable = isort
# isort.args = REVISION_SCRIPT_FILENAME
#

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
"""

# Example migration file (generated by Alembic)
"""
Revision ID: abc123def456
Revises:
Create Date: 2023-10-01 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = 'abc123def456'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Create users table
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('username', sa.String(length=50), nullable=False),
        sa.Column('full_name', sa.String(length=100), nullable=True),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True),
        sa.Column('is_verified', sa.Boolean(), nullable=False, default=False),
        sa.Column('role', sa.String(length=20), nullable=False, default='user'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('email'),
        sa.UniqueConstraint('username')
    )

    # Create user_profiles table
    op.create_table(
        'user_profiles',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('bio', sa.Text(), nullable=True),
        sa.Column('avatar_url', sa.String(length=500), nullable=True),
        sa.Column('phone', sa.String(length=20), nullable=True),
        sa.Column('birth_date', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id')
    )

    # Create items table
    op.create_table(
        'items',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(length=200), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('price', sa.Float(), nullable=False),
        sa.Column('is_public', sa.Boolean(), nullable=False, default=False),
        sa.Column('status', sa.String(length=20), nullable=False, default='draft'),
        sa.Column('owner_id', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.ForeignKeyConstraint(['owner_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )

    # Create indexes
    op.create_index('idx_user_email', 'users', ['email'])
    op.create_index('idx_user_username', 'users', ['username'])
    op.create_index('idx_user_active', 'users', ['is_active'])
    op.create_index('idx_item_owner', 'items', ['owner_id'])
    op.create_index('idx_item_public', 'items', ['is_public'])
    op.create_index('idx_item_status', 'items', ['status'])

def downgrade() -> None:
    # Drop indexes first
    op.drop_index('idx_item_status', table_name='items')
    op.drop_index('idx_item_public', table_name='items')
    op.drop_index('idx_item_owner', table_name='items')
    op.drop_index('idx_user_active', table_name='users')
    op.drop_index('idx_user_username', table_name='users')
    op.drop_index('idx_user_email', table_name='users')

    # Drop tables
    op.drop_table('items')
    op.drop_table('user_profiles')
    op.drop_table('users')
```

### Database Connection Pooling and Performance Optimization
```python
# Database configuration with performance optimization
from sqlalchemy import event
from sqlalchemy.pool import Pool
import time

# Connection pool configuration
DATABASE_CONFIG = {
    "pool_size": 20,
    "max_overflow": 30,
    "pool_pre_ping": True,
    "pool_recycle": 300,  # 5 minutes
    "pool_timeout": 30,
    "echo": bool(os.getenv("DB_ECHO", "False").lower() == "true")
}

# Connection event listeners for performance monitoring
@event.listens_for(sync_engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    """Set SQLite pragmas for performance (if using SQLite)"""
    if "sqlite" in DATABASE_URL:
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.execute("PRAGMA journal_mode=WAL")
        cursor.execute("PRAGMA synchronous=NORMAL")
        cursor.close()

@event.listens_for(async_engine, "connect")
def set_async_sqlite_pragma(dbapi_connection, connection_record):
    """Set SQLite pragmas for async engine"""
    if "sqlite" in DATABASE_URL:
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.execute("PRAGMA journal_mode=WAL")
        cursor.execute("PRAGMA synchronous=NORMAL")
        cursor.close()

# Connection timing for monitoring
@event.listens_for(sync_engine.pool, "connect")
def time_connect(dbapi_connection, connection_record):
    connection_record.start_time = time.time()

@event.listens_for(sync_engine.pool, "checkout")
def time_checkout(dbapi_connection, connection_record, connection_proxy):
    if hasattr(connection_record, 'start_time'):
        total_time = time.time() - connection_record.start_time
        if total_time > 1:  # Log if connection creation took more than 1 second
            logger.warning(f"Slow connection creation: {total_time:.2f}s")

# Example of using raw SQL for performance-critical operations
class PerformanceRepository(BaseRepository):
    async def get_user_stats(self, user_id: int) -> Dict[str, Any]:
        """Get user statistics using raw SQL for performance"""
        sql = """
        SELECT
            u.id,
            u.username,
            u.email,
            COUNT(i.id) as items_count,
            COALESCE(SUM(i.price), 0) as total_value,
            MAX(i.created_at) as last_item_created
        FROM users u
        LEFT JOIN items i ON u.id = i.owner_id
        WHERE u.id = :user_id
        GROUP BY u.id, u.username, u.email
        """

        result = await self.session.execute(text(sql), {"user_id": user_id})
        row = result.fetchone()

        if row:
            return {
                "user_id": row[0],
                "username": row[1],
                "email": row[2],
                "items_count": row[3],
                "total_value": float(row[4]) if row[4] else 0.0,
                "last_item_created": row[5]
            }
        return None

    async def bulk_insert_items(self, items_data: List[Dict[str, Any]]) -> int:
        """Bulk insert items for better performance"""
        stmt = Item.__table__.insert()
        result = await self.session.execute(stmt, items_data)
        await self.session.commit()
        return result.rowcount

    async def get_items_with_custom_query(self, filters: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Get items with complex filtering using raw SQL"""
        conditions = []
        params = {}

        if filters.get("min_price"):
            conditions.append("price >= :min_price")
            params["min_price"] = filters["min_price"]

        if filters.get("max_price"):
            conditions.append("price <= :max_price")
            params["max_price"] = filters["max_price"]

        if filters.get("status"):
            conditions.append("status = :status")
            params["status"] = filters["status"]

        if filters.get("owner_id"):
            conditions.append("owner_id = :owner_id")
            params["owner_id"] = filters["owner_id"]

        where_clause = f"WHERE {' AND '.join(conditions)}" if conditions else ""

        sql = f"""
        SELECT id, title, description, price, is_public, status, owner_id, created_at, updated_at
        FROM items
        {where_clause}
        ORDER BY created_at DESC
        LIMIT :limit OFFSET :offset
        """

        params["limit"] = filters.get("limit", 100)
        params["offset"] = filters.get("offset", 0)

        result = await self.session.execute(text(sql), params)
        rows = result.fetchall()

        return [
            {
                "id": row[0],
                "title": row[1],
                "description": row[2],
                "price": float(row[3]),
                "is_public": row[4],
                "status": row[5],
                "owner_id": row[6],
                "created_at": row[7],
                "updated_at": row[8]
            }
            for row in rows
        ]
```

---

## Deployment and Testing Patterns

### Production Deployment Configuration
```python
# gunicorn.conf.py - Production WSGI configuration
import multiprocessing

# Server socket
bind = "0.0.0.0:8000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000
timeout = 30
keepalive = 2

# Restart settings
max_requests = 1000
max_requests_jitter = 100
preload_app = True
reload = False  # Disable reload in production

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "fastapi_app"

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190
```

### Docker Configuration for Production
```dockerfile
# Dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN uv pip install -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["gunicorn", "main:app", "-c", "gunicorn.conf.py"]
```

### Docker Compose for Development and Production
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://user:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=your-super-secret-key-here
      - DEBUG=False
    depends_on:
      - db
      - redis
    volumes:
      - ./logs:/app/logs  # For log persistence
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

### Environment Configuration
```python
# config.py - Application configuration
import os
from pydantic import BaseModel, Field
from typing import Optional, List

class Settings(BaseModel):
    # App settings
    app_name: str = "My FastAPI App"
    app_version: str = "1.0.0"
    debug: bool = Field(default=False, env="DEBUG")
    environment: str = Field(default="development", env="ENVIRONMENT")

    # Database settings
    database_url: str = Field(..., env="DATABASE_URL")
    database_pool_size: int = Field(default=20, env="DATABASE_POOL_SIZE")
    database_max_overflow: int = Field(default=30, env="DATABASE_MAX_OVERFLOW")

    # Security settings
    secret_key: str = Field(..., env="SECRET_KEY")
    algorithm: str = Field(default="HS256", env="ALGORITHM")
    access_token_expire_minutes: int = Field(default=30, env="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(default=7, env="REFRESH_TOKEN_EXPIRE_DAYS")

    # CORS settings
    allowed_origins: List[str] = Field(default=["*"], env="ALLOWED_ORIGINS")

    # Redis settings
    redis_url: Optional[str] = Field(default=None, env="REDIS_URL")

    # Logging settings
    log_level: str = Field(default="INFO", env="LOG_LEVEL")
    log_format: str = Field(default="%(asctime)s - %(name)s - %(levelname)s - %(message)s", env="LOG_FORMAT")

    # External service settings
    sentry_dsn: Optional[str] = Field(default=None, env="SENTRY_DSN")
    mailgun_api_key: Optional[str] = Field(default=None, env="MAILGUN_API_KEY")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False

# Initialize settings
settings = Settings()

# Example usage in main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
import logging

# Configure logging based on settings
logging.basicConfig(
    level=getattr(logging, settings.log_level.upper()),
    format=settings.log_format
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print(f"Starting {settings.app_name} v{settings.app_version}")

    # Initialize database
    await init_db()

    # Initialize Redis (if configured)
    if settings.redis_url:
        # Initialize Redis connection
        pass

    yield

    # Shutdown
    print(f"Shutting down {settings.app_name}")

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    debug=settings.debug,
    lifespan=lifespan
)
```

### Testing Framework Setup
```python
# conftest.py - Pytest configuration
import pytest
import asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from app.main import app
from app.database import Base
import os

# Use in-memory SQLite for testing
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for each test case."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture(scope="session", autouse=True)
async def create_test_database():
    """Create test database before tests and clean up after."""
    engine = create_async_engine(
        TEST_DATABASE_URL,
        poolclass=StaticPool,
        connect_args={"check_same_thread": False}
    )

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()

@pytest.fixture
async def async_client():
    """Create an async test client."""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

@pytest.fixture
async def db_session():
    """Create a test database session."""
    engine = create_async_engine(
        TEST_DATABASE_URL,
        poolclass=StaticPool,
        connect_args={"check_same_thread": False}
    )

    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    async with async_session() as session:
        yield session
        await session.rollback()

# test_main.py - Main API tests
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_root_endpoint(async_client: AsyncClient):
    """Test the root endpoint."""
    response = await async_client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()

@pytest.mark.asyncio
async def test_health_check(async_client: AsyncClient):
    """Test the health check endpoint."""
    response = await async_client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

# test_auth.py - Authentication tests
from app.auth import create_access_token
import jwt

@pytest.mark.asyncio
async def test_token_creation():
    """Test JWT token creation."""
    data = {"sub": "testuser"}
    token = create_access_token(data=data)

    # Verify the token
    payload = jwt.decode(token, os.getenv("SECRET_KEY"), algorithms=["HS256"])
    assert payload["sub"] == "testuser"

@pytest.mark.asyncio
async def test_protected_route(async_client: AsyncClient):
    """Test accessing a protected route."""
    # Create a test token
    token = create_access_token(data={"sub": "testuser"})

    # Access protected endpoint
    response = await async_client.get(
        "/users/me/",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200

# test_models.py - Database model tests
from app.models import User
from app.database import get_async_db
from sqlalchemy import select

@pytest.mark.asyncio
async def test_user_model(db_session: AsyncSession):
    """Test user model creation and retrieval."""
    # Create a user
    user = User(
        email="test@example.com",
        username="testuser",
        hashed_password="hashed_password"
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)

    # Retrieve the user
    result = await db_session.execute(select(User).where(User.id == user.id))
    retrieved_user = result.scalar_one_or_none()

    assert retrieved_user is not None
    assert retrieved_user.email == "test@example.com"
    assert retrieved_user.username == "testuser"

# test_endpoints.py - API endpoint tests
from app.models import Item
from app.schemas import ItemCreate

@pytest.mark.asyncio
async def test_create_item(async_client: AsyncClient, db_session: AsyncSession):
    """Test creating an item."""
    # First, create a user for the test
    user = User(
        email="test@example.com",
        username="testuser",
        hashed_password="hashed_password"
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)

    # Create item data
    item_data = {
        "title": "Test Item",
        "description": "Test description",
        "price": 10.99,
        "owner_id": user.id
    }

    # Create the item
    response = await async_client.post("/items/", json=item_data)
    assert response.status_code == 200

    item_response = response.json()
    assert item_response["title"] == "Test Item"
    assert item_response["price"] == 10.99
    assert item_response["owner_id"] == user.id

# test_integration.py - Integration tests
@pytest.mark.asyncio
async def test_user_item_workflow(async_client: AsyncClient):
    """Test complete user-item workflow."""
    # Create user
    user_data = {
        "email": "integration@example.com",
        "username": "integration_user",
        "password": "SecurePassword123!",
        "confirm_password": "SecurePassword123!"
    }

    response = await async_client.post("/users/", json=user_data)
    assert response.status_code == 200

    # Login to get token
    login_data = {
        "username": "integration_user",
        "password": "SecurePassword123!"
    }

    response = await async_client.post("/token", data=login_data)
    assert response.status_code == 200

    token_data = response.json()
    assert "access_token" in token_data
    assert token_data["token_type"] == "bearer"
```

### Performance Testing
```python
# load_test.py - Load testing with Locust
from locust import HttpUser, task, between
import json

class FastAPIUser(HttpUser):
    wait_time = between(1, 3)

    def on_start(self):
        """Login before starting tasks."""
        self.login()

    def login(self):
        """Login to get JWT token."""
        response = self.client.post("/token", data={
            "username": "testuser",
            "password": "testpassword"
        })

        if response.status_code == 200:
            token_data = response.json()
            self.token = token_data["access_token"]
            self.headers = {"Authorization": f"Bearer {self.token}"}
        else:
            self.token = None
            self.headers = {}

    @task(3)
    def get_items(self):
        """Get items endpoint."""
        self.client.get("/items/", headers=self.headers)

    @task(1)
    def create_item(self):
        """Create item endpoint."""
        item_data = {
            "title": "Load Test Item",
            "description": "Item created during load test",
            "price": 99.99
        }
        self.client.post("/items/", json=item_data, headers=self.headers)

    @task(2)
    def get_user_profile(self):
        """Get user profile."""
        self.client.get("/users/me/", headers=self.headers)

# pytest-benchmark tests
def test_user_creation_performance(benchmark):
    """Benchmark user creation performance."""
    def create_user():
        # Simulate user creation logic
        user_data = {
            "email": "perf_test@example.com",
            "username": "perf_test_user",
            "password": "SecurePassword123!"
        }
        # This would be your actual user creation function
        # return create_user_in_db(user_data)
        pass

    result = benchmark(create_user)
    # Performance should be under 100ms for user creation
    assert benchmark.stats["mean"] < 0.100  # 100ms

# test_security.py - Security tests
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_rate_limiting(async_client: AsyncClient):
    """Test rate limiting functionality."""
    # Make multiple requests to test rate limiting
    for i in range(10):
        response = await async_client.get("/limited-endpoint")

    # The 6th request should be rate limited (if limit is 5/minute)
    assert response.status_code == 429  # Too Many Requests

@pytest.mark.asyncio
async def test_sql_injection_protection(async_client: AsyncClient):
    """Test protection against SQL injection."""
    malicious_payload = {
        "q": "'; DROP TABLE users; --",
        "username": "'; DROP TABLE users; --"
    }

    # This should not cause a database error
    response = await async_client.get("/search", params=malicious_payload)
    # Should return a valid response, not a 500 error
    assert response.status_code != 500

# test_error_handling.py - Error handling tests
@pytest.mark.asyncio
async def test_not_found_error(async_client: AsyncClient):
    """Test 404 error handling."""
    response = await async_client.get("/nonexistent-endpoint")
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_validation_error(async_client: AsyncClient):
    """Test validation error handling."""
    invalid_data = {
        "title": "",  # Empty title should fail validation
        "price": -10  # Negative price should fail validation
    }

    response = await async_client.post("/items/", json=invalid_data)
    assert response.status_code == 422  # Unprocessable Entity

# coverage.py - Test coverage configuration
"""
[run]
source = app/
omit =
    */venv/*
    */env/*
    */tests/*
    */migrations/*
    app/main.py  # Omit main app file from coverage if it's just startup code

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:

[html]
directory = htmlcov
"""
```

### CI/CD Pipeline Configuration
```yaml
# .github/workflows/test.yml
name: Test and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install uv
      run: pip install uv

    - name: Install dependencies
      run: uv pip install -r requirements.txt

    - name: Run tests
      run: |
        uv pip install pytest pytest-asyncio pytest-cov
        python -m pytest tests/ -v --cov=app --cov-report=xml

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella

  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Run Bandit security scan
      run: |
        pip install bandit
        bandit -r app/ -f json -o bandit-report.json || true

    - name: Run safety check
      run: |
        pip install safety
        safety check -r requirements.txt

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: myapp:${{ github.sha }}, myapp:latest
        platforms: linux/amd64
```

### Monitoring and Observability
```python
# monitoring.py - Application monitoring setup
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from fastapi import Request, Response
from functools import wraps
import time
import logging

# Prometheus metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

ACTIVE_CONNECTIONS = Gauge(
    'active_connections',
    'Number of active connections'
)

def monitor_request(func):
    """Decorator to monitor API requests."""
    @wraps(func)
    async def wrapper(*args, **kwargs):
        start_time = time.time()
        request = kwargs.get('request') or (args[0] if args and hasattr(args[0], 'method') else None)

        try:
            result = await func(*args, **kwargs)
            status_code = getattr(result, 'status_code', 200)
        except Exception as e:
            status_code = getattr(e, 'status_code', 500)
            raise
        finally:
            duration = time.time() - start_time

            if request:
                REQUEST_COUNT.labels(
                    method=request.method,
                    endpoint=request.url.path,
                    status=status_code
                ).inc()

                REQUEST_DURATION.labels(
                    method=request.method,
                    endpoint=request.url.path
                ).observe(duration)

        return result
    return wrapper

# Middleware for monitoring
class MonitoringMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            return await self.app(scope, receive, send)

        start_time = time.time()

        async def send_wrapper(message):
            if message["type"] == "http.response.start":
                duration = time.time() - start_time
                REQUEST_DURATION.labels(
                    method=scope["method"],
                    endpoint=scope["path"]
                ).observe(duration)
            await send(message)

        await self.app(scope, receive, send_wrapper)

# Add middleware to app
app.add_middleware(MonitoringMiddleware)

# Health check with detailed status
@app.get("/detailed-health")
async def detailed_health():
    """Detailed health check with external service status."""
    import asyncio
    import asyncpg

    health_status = {
        "status": "healthy",
        "timestamp": time.time(),
        "services": {
            "database": "unknown",
            "redis": "unknown",
            "external_api": "unknown"
        },
        "details": {}
    }

    # Check database connection
    try:
        # Test database connection
        engine = create_async_engine(settings.database_url)
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        health_status["services"]["database"] = "healthy"
    except Exception as e:
        health_status["services"]["database"] = "unhealthy"
        health_status["details"]["database_error"] = str(e)
        health_status["status"] = "unhealthy"
    finally:
        await engine.dispose()

    # Check Redis connection if configured
    if settings.redis_url:
        try:
            import redis.asyncio as redis
            redis_client = redis.from_url(settings.redis_url)
            await redis_client.ping()
            health_status["services"]["redis"] = "healthy"
        except Exception as e:
            health_status["services"]["redis"] = "unhealthy"
            health_status["details"]["redis_error"] = str(e)
            health_status["status"] = "unhealthy"
        finally:
            await redis_client.close()

    return health_status

# Metrics endpoint for Prometheus
@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint."""
    return Response(content=generate_latest(), media_type="text/plain")
```

### Logging Configuration
```python
# logging_config.py - Advanced logging setup
import logging
import sys
from logging.handlers import RotatingFileHandler
import json
from datetime import datetime
from fastapi import Request
import traceback

class JSONFormatter(logging.Formatter):
    """Custom JSON formatter for structured logging."""

    def format(self, record):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }

        # Add exception info if present
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)

        # Add extra fields if present
        if hasattr(record, 'user_id'):
            log_entry['user_id'] = record.user_id
        if hasattr(record, 'request_id'):
            log_entry['request_id'] = record.request_id

        return json.dumps(log_entry)

def setup_logging():
    """Setup application logging."""
    # Create formatters
    json_formatter = JSONFormatter()
    standard_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )

    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(standard_formatter)
    console_handler.setLevel(logging.INFO)

    # File handler with rotation
    file_handler = RotatingFileHandler(
        'app.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setFormatter(json_formatter)
    file_handler.setLevel(logging.INFO)

    # Error file handler
    error_handler = RotatingFileHandler(
        'error.log',
        maxBytes=10*1024*1024,
        backupCount=5
    )
    error_handler.setFormatter(json_formatter)
    error_handler.setLevel(logging.ERROR)

    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(console_handler)
    root_logger.addHandler(file_handler)
    root_logger.addHandler(error_handler)

    # Configure specific loggers
    logging.getLogger('sqlalchemy.engine').setLevel(logging.WARNING)
    logging.getLogger('uvicorn').setLevel(logging.INFO)
    logging.getLogger('fastapi').setLevel(logging.INFO)

# Middleware for request logging
class RequestLoggingMiddleware:
    def __init__(self, app):
        self.app = app
        self.logger = logging.getLogger(__name__)

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            return await self.app(scope, receive, send)

        # Generate request ID
        request_id = f"req_{int(time.time() * 1000000)}"

        # Log request
        self.logger.info(
            f"Request started: {scope['method']} {scope['path']}",
            extra={'request_id': request_id}
        )

        start_time = time.time()

        async def send_wrapper(message):
            if message["type"] == "http.response.start":
                duration = time.time() - start_time
                status_code = message["status"]

                self.logger.info(
                    f"Request completed: {scope['method']} {scope['path']} - "
                    f"Status: {status_code} - Duration: {duration:.3f}s",
                    extra={
                        'request_id': request_id,
                        'status_code': status_code,
                        'duration': duration
                    }
                )
            await send(message)

        await self.app(scope, receive, send_wrapper)

# Setup logging when module is imported
setup_logging()
```

### Example API Router
```python
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import UserResponse, UserCreate, UserUpdate, ItemResponse, ItemCreate, ItemUpdate
from app.database import get_async_db
from app.auth import get_current_active_user, get_current_admin_user
from app.repositories import UserRepository, ItemRepository

# Create API router
api_router = APIRouter()

@api_router.get("/users/", response_model=List[UserResponse], tags=["users"])
async def get_users(
    skip: int = 0,
    limit: int = 100,
    search: str = None,
    db: AsyncSession = Depends(get_async_db)
):
    """Get a list of users with optional search and pagination."""
    repo = UserRepository(db)

    filters = {}
    if search:
        filters["search"] = search

    users = await repo.list(User, skip=skip, limit=limit, **filters)
    return users

@api_router.get("/users/{user_id}", response_model=UserResponse, tags=["users"])
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_async_db)
):
    """Get a specific user by ID."""
    repo = UserRepository(db)
    user = await repo.get_by_id(User, user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return user

@api_router.post("/users/", response_model=UserResponse, status_code=status.HTTP_201_CREATED, tags=["users"])
async def create_user(
    user_create: UserCreate,
    db: AsyncSession = Depends(get_async_db)
):
    """Create a new user."""
    repo = UserRepository(db)

    # Check if user already exists
    existing_user = await repo.get_by_email(user_create.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Check username availability
    existing_user = await repo.get_by_username(user_create.username)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already taken"
        )

    # Hash password
    hashed_password = get_password_hash(user_create.password)

    # Create user
    user_data = user_create.model_dump(exclude={'password', 'confirm_password'})
    user_data['hashed_password'] = hashed_password

    user = await repo.create(User, **user_data)
    return user

@api_router.put("/users/{user_id}", response_model=UserResponse, tags=["users"])
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_async_db)
):
    """Update a user. Users can only update their own profile unless they are admin."""
    repo = UserRepository(db)

    # Check if user exists
    user = await repo.get_by_id(User, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Check permissions
    if current_user.id != user_id and not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this user"
        )

    # Prepare update data
    update_data = user_update.model_dump(exclude_unset=True)

    # Update user
    updated_user = await repo.update(User, user_id, **update_data)
    return updated_user

@api_router.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["users"])
async def delete_user(
    user_id: int,
    current_user: User = Depends(get_current_admin_user)  # Only admins can delete users
):
    """Delete a user (admin only)."""
    repo = UserRepository(db)

    # Check if user exists
    user = await repo.get_by_id(User, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Cannot delete yourself
    if user_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )

    # Delete user
    success = await repo.delete(User, user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return

# Item endpoints
@api_router.get("/items/", response_model=List[ItemResponse], tags=["items"])
async def get_items(
    skip: int = 0,
    limit: int = 100,
    is_public: bool = True,
    db: AsyncSession = Depends(get_async_db)
):
    """Get a list of items."""
    repo = ItemRepository(db)

    filters = {"is_public": is_public}
    items = await repo.list(Item, skip=skip, limit=limit, **filters)
    return items

@api_router.get("/items/{item_id}", response_model=ItemResponse, tags=["items"])
async def get_item(
    item_id: int,
    db: AsyncSession = Depends(get_async_db)
):
    """Get a specific item by ID."""
    repo = ItemRepository(db)
    item = await repo.get_by_id(Item, item_id)

    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    # Check if item is public or user owns it
    current_user = await get_current_active_user_from_request()  # This would need implementation
    if not item.is_public and current_user.id != item.owner_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to access this item"
        )

    return item

@api_router.post("/items/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED, tags=["items"])
async def create_item(
    item_create: ItemCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_async_db)
):
    """Create a new item."""
    repo = ItemRepository(db)

    # Create item with owner
    item_data = item_create.model_dump()
    item_data["owner_id"] = current_user.id

    item = await repo.create(Item, **item_data)
    return item

@api_router.put("/items/{item_id}", response_model=ItemResponse, tags=["items"])
async def update_item(
    item_id: int,
    item_update: ItemUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_async_db)
):
    """Update an item. Users can only update items they own."""
    repo = ItemRepository(db)

    # Check if item exists
    item = await repo.get_by_id(Item, item_id)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    # Check ownership
    if item.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this item"
        )

    # Prepare update data
    update_data = item_update.model_dump(exclude_unset=True)

    # Update item
    updated_item = await repo.update(Item, item_id, **update_data)
    return updated_item

@api_router.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["items"])
async def delete_item(
    item_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_async_db)
):
    """Delete an item. Users can only delete items they own."""
    repo = ItemRepository(db)

    # Check if item exists
    item = await repo.get_by_id(Item, item_id)
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    # Check ownership
    if item.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to delete this item"
        )

    # Delete item
    success = await repo.delete(Item, item_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    return

# Include the router in main app
# app.include_router(api_router, prefix="/api/v1")
```

---

## Summary and Best Practices

### FastAPI Zero to Hero - Key Takeaways

This comprehensive FastAPI skill covers all essential aspects of API development:

1. **Project Structure**: Organized, scalable structure with proper separation of concerns
2. **Authentication**: Multiple auth methods (JWT, OAuth2, API keys) with security best practices
3. **Data Validation**: Pydantic models with comprehensive validation and serialization
4. **Database Integration**: Async SQLAlchemy with repository pattern and performance optimization
5. **API Design**: RESTful endpoints with proper error handling and documentation
6. **Testing**: Comprehensive test suite with unit, integration, and performance tests
7. **Deployment**: Production-ready configuration with Docker, monitoring, and CI/CD

### Security Best Practices
- Use HTTPS in production
- Implement proper authentication and authorization
- Validate and sanitize all inputs
- Use parameterized queries to prevent SQL injection
- Implement rate limiting
- Use secure session management
- Regular security audits and dependency scanning

### Performance Optimization
- Use connection pooling
- Implement caching strategies
- Optimize database queries with proper indexing
- Use async/await for I/O-bound operations
- Implement pagination for large datasets
- Use raw SQL for complex queries when needed

### Production Considerations
- Proper logging and monitoring
- Health checks and metrics
- Error tracking and alerting
- Backup and recovery procedures
- Security scanning and vulnerability assessments
- Performance monitoring and optimization

### Common Patterns and Solutions

#### 1. Repository Pattern for Database Operations
- Encapsulates data access logic
- Improves testability
- Separates business logic from data access

#### 2. Dependency Injection
- Improves code maintainability
- Enables easy testing
- Promotes loose coupling

#### 3. Pydantic for Data Validation
- Automatic validation and serialization
- Type safety
- Automatic API documentation

#### 4. Middleware for Cross-Cutting Concerns
- Authentication and authorization
- Logging and monitoring
- Request/response transformation

This skill provides a complete foundation for building robust, scalable, and secure FastAPI applications from basic concepts to advanced production patterns.

@router.post("/", response_model=UserResponse)
async def create_user(user: UserCreate, db: AsyncSession = Depends(get_async_db)):
    # Implementation for creating a user
    pass

@router.get("/", response_model=List[UserResponse])
async def read_users(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_async_db)
):
    # Implementation for reading users
    pass

@router.get("/{user_id}", response_model=UserResponse)
async def read_user(user_id: int, db: AsyncSession = Depends(get_async_db)):
    # Implementation for reading a specific user
    pass

@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    db: AsyncSession = Depends(get_async_db)
):
    # Implementation for updating a user
    pass

@router.delete("/{user_id}")
async def delete_user(user_id: int, db: AsyncSession = Depends(get_async_db)):
    # Implementation for deleting a user
    pass

# Include this router in main app
# app.include_router(router)
```

---

## Dependency Injection Examples

### Common Dependencies
```python
from fastapi import Depends, Query
from typing import Optional

# Simple dependency
async def common_parameters(
    q: Optional[str] = Query(None, title="Query", description="Query string"),
    skip: int = Query(0, ge=0, le=100, title="Skip", description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=100, title="Limit", description="Maximum number of records to return")
):
    return {"q": q, "skip": skip, "limit": limit}

# Dependency with database connection
async def get_db_session():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Dependency with authentication
def require_admin_user(current_user: User = Depends(get_current_active_user)):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return current_user

# Usage in endpoint
@app.get("/items/")
async def read_items(
    commons: dict = Depends(common_parameters),
    db: Session = Depends(get_db_session)
):
    return commons
```

---

## Testing Patterns

### Pytest Examples
```python
import pytest
from fastapi.testclient import TestClient
from main import app
from app.database import get_async_db
from app.models import UserCreate
from unittest.mock import AsyncMock

client = TestClient(app)

# Override dependency for testing
@pytest.fixture
def override_db():
    app.dependency_overrides[get_async_db] = lambda: AsyncMock()
    yield
    app.dependency_overrides.clear()

def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to FastAPI!"}

def test_create_user(override_db):
    user_data = {
        "email": "test@example.com",
        "username": "testuser",
        "password": "TestPass123"
    }
    response = client.post("/users/", json=user_data)
    assert response.status_code == 200
    assert response.json()["email"] == user_data["email"]

# Async tests
@pytest.mark.asyncio
async def test_async_endpoint():
    # Example for testing async endpoints
    pass
```

---

## Deployment Configuration

### Dockerfile
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install uv
RUN pip install uv

# Copy requirements and install dependencies
COPY requirements.txt .
RUN uv pip install -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Requirements.txt
```
fastapi[standard]==0.104.1
uvicorn[standard]==0.24.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
sqlalchemy==2.0.23
asyncpg==0.29.0
python-dotenv==1.0.0
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.0
```

### Gunicorn Configuration for Production
```python
# gunicorn.conf.py
bind = "0.0.0.0:8000"
workers = 4
worker_class = "uvicorn.workers.UvicornWorker"
timeout = 120
keepalive = 5
max_requests = 1000
max_requests_jitter = 100
preload_app = True
```

---

## Best Practices

### Error Handling
```python
from fastapi import HTTPException, status
from fastapi.responses import JSONResponse

# Custom exception handlers
@app.exception_handler(ValueError)
async def value_error_handler(request, exc):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": str(exc)}
    )

# Using HTTPException for validation
def validate_user_id(user_id: int):
    if user_id <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User ID must be positive"
        )
```

### Middleware Examples
```python
from fastapi import FastAPI
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
import time
import logging

# Custom logging middleware
class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()

        response = await call_next(request)

        process_time = time.time() - start_time
        response.headers["X-Process-Time"] = str(process_time)

        logging.info(f"{request.method} {request.url} - {response.status_code} - {process_time:.2f}s")

        return response

# Add middleware to app
app.add_middleware(LoggingMiddleware)
```

### Security Best Practices
```python
# Use HTTPS in production
from fastapi.security import HTTPBearer

security = HTTPBearer()

# Rate limiting (using slowapi or similar)
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(429, _rate_limit_exceeded_handler)

@app.get("/slow-endpoint")
@limiter.limit("5/minute")
async def slow_endpoint(request: Request):
    return {"message": "This is a slow endpoint"}
```

---

## Using Context7 MCP Server for Documentation

When you need the latest FastAPI documentation, patterns, or examples, you can use the fetch-library-docs skill:

```bash
# Use the fetch-library-docs skill to get the latest FastAPI documentation
# This will provide you with the most up-to-date patterns and best practices
```

---

## Output Checklist

Before delivering, verify:
- [ ] Project structure follows recommended organization
- [ ] Authentication system is properly implemented
- [ ] Pydantic models include proper validation
- [ ] Database integration is configured correctly
- [ ] API routes follow REST conventions
- [ ] Error handling is comprehensive
- [ ] Tests are included for critical functionality
- [ ] Documentation is clear and complete
- [ ] Security best practices are followed
- [ ] uv package manager is used for dependencies

---

## Reference Files

| File | When to Read |
|------|--------------|
| `references/fastapi-docs.md` | When implementing advanced FastAPI features |
| `references/security-best-practices.md` | When configuring authentication and authorization |
| `references/database-patterns.md` | When setting up database integration |
| `references/deployment-guidelines.md` | When preparing for production deployment |