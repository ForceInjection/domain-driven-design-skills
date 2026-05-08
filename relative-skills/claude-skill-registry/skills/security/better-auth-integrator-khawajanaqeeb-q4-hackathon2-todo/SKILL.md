---
name: "Better Auth Integrator"
description: "Implement full Better Auth registration/login with JWT tokens and protect routes when authentication is mentioned"
version: "1.0.0"
---

# Better Auth Integrator Skill

## Purpose

Automatically implement complete authentication system with JWT tokens, user registration, login, logout, route protection, and session management when the user requests authentication for the Phase II full-stack todo application.

## When This Skill Triggers

Use this skill when the user asks to:
- "Set up authentication"
- "Implement login and registration"
- "Add JWT auth"
- "Protect routes with authentication"
- "Create user authentication flow"
- Any request to implement auth, login, signup, or session management

## Prerequisites

Before implementing auth:
1. Read `specs/phase-2/spec.md` for auth requirements
2. Read `.specify/memory/constitution.md` for security standards (§VII)
3. Verify both `backend/` and `frontend/` projects exist
4. Ensure User model exists in database
5. Install required packages (PyJWT, bcrypt, jose)

## Step-by-Step Procedure

### Step 1: Install Dependencies

**Backend:**
```bash
cd backend
pip install python-jose[cryptography] passlib[bcrypt] python-multipart
```

**Frontend:**
```bash
cd frontend
npm install jose
```

### Step 2: Create Security Utilities (Backend)

```python
# app/utils/security.py
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.config import settings

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """
    Hash a password using bcrypt.

    Args:
        password: Plain text password

    Returns:
        Hashed password string
    """
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a password against its hash.

    Args:
        plain_password: Plain text password from user input
        hashed_password: Stored hashed password

    Returns:
        True if password matches, False otherwise
    """
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT access token.

    Args:
        data: Data to encode in token (usually {"sub": user_id})
        expires_delta: Optional custom expiration time

    Returns:
        Encoded JWT token string
    """
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "access",
    })

    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )
    return encoded_jwt

def create_refresh_token(data: dict) -> str:
    """
    Create a JWT refresh token (longer expiration).

    Args:
        data: Data to encode in token

    Returns:
        Encoded JWT refresh token
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(
        days=settings.REFRESH_TOKEN_EXPIRE_DAYS
    )

    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "refresh",
    })

    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    """
    Decode and verify a JWT access token.

    Args:
        token: JWT token string

    Returns:
        Decoded payload dict if valid, None if invalid
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )

        # Verify token type
        if payload.get("type") != "access":
            return None

        return payload

    except JWTError:
        return None

def validate_password_strength(password: str) -> tuple[bool, str]:
    """
    Validate password meets security requirements.

    Requirements:
        - Minimum 8 characters
        - At least one uppercase letter
        - At least one lowercase letter
        - At least one number

    Args:
        password: Password to validate

    Returns:
        Tuple of (is_valid, error_message)
    """
    import re

    if len(password) < 8:
        return False, "Password must be at least 8 characters"
    if not re.search(r"[A-Z]", password):
        return False, "Password must contain at least one uppercase letter"
    if not re.search(r"[a-z]", password):
        return False, "Password must contain at least one lowercase letter"
    if not re.search(r"\d", password):
        return False, "Password must contain at least one number"

    return True, "Password is valid"
```

### Step 3: Create Auth Dependency

```python
# app/dependencies/auth.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlmodel import Session
from app.models.user import User
from app.utils.security import decode_access_token
from app.dependencies.database import get_session

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    session: Session = Depends(get_session),
) -> User:
    """
    Extract and verify JWT token, return current authenticated user.

    This dependency should be used to protect endpoints:
        @router.get("/protected")
        async def protected_route(user: User = Depends(get_current_user)):
            return {"user_id": user.id}

    Args:
        credentials: HTTP Bearer credentials from Authorization header
        session: Database session

    Returns:
        Current authenticated User object

    Raises:
        HTTPException: 401 if token is invalid or user not found
    """
    token = credentials.credentials

    # Decode and verify token
    payload = decode_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Extract user ID from token
    user_id: str = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )

    # Fetch user from database
    user = session.get(User, int(user_id))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    # Check if user is active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )

    return user
```

### Step 4: Create Auth Schemas

```python
# app/schemas/auth.py
from pydantic import BaseModel, EmailStr, Field

class UserRegister(BaseModel):
    """Schema for user registration."""
    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., min_length=8, description="Password (min 8 chars)")
    name: str = Field(..., min_length=1, max_length=255, description="Full name")

class UserLogin(BaseModel):
    """Schema for user login."""
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    """Schema for token response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class RefreshTokenRequest(BaseModel):
    """Schema for refresh token request."""
    refresh_token: str
```

### Step 5: Create Auth Router (Backend)

```python
# app/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from app.models.user import User
from app.schemas.auth import UserRegister, UserLogin, TokenResponse, RefreshTokenRequest
from app.schemas.user import UserResponse
from app.utils.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    validate_password_strength,
    decode_access_token,
)
from app.dependencies.database import get_session
from app.dependencies.auth import get_current_user

router = APIRouter(
    prefix="/auth",
    tags=["authentication"],
)

@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
)
async def register(
    user_data: UserRegister,
    session: Session = Depends(get_session),
):
    """
    Register a new user account.

    Requirements:
        - Email must be unique
        - Password must meet strength requirements (8+ chars, upper, lower, number)

    Returns:
        Created user object (without password)
    """
    # Check if user already exists
    existing_user = session.exec(
        select(User).where(User.email == user_data.email)
    ).first()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    # Validate password strength
    is_valid, message = validate_password_strength(user_data.password)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message,
        )

    # Create user
    user = User(
        email=user_data.email,
        name=user_data.name,
        hashed_password=hash_password(user_data.password),
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    return user

@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Login and receive tokens",
)
async def login(
    credentials: UserLogin,
    session: Session = Depends(get_session),
):
    """
    Login with email and password.

    Returns:
        Access token (short-lived) and refresh token (long-lived)

    Security:
        - Uses generic error message to prevent user enumeration
        - Verifies password with constant-time comparison (bcrypt)
    """
    # Find user by email
    user = session.exec(
        select(User).where(User.email == credentials.email)
    ).first()

    # Generic error message (don't reveal if user exists)
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Check if user is active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account is inactive",
        )

    # Generate tokens
    access_token = create_access_token(data={"sub": str(user.id)})
    refresh_token = create_refresh_token(data={"sub": str(user.id)})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
    )

@router.post(
    "/refresh",
    response_model=TokenResponse,
    summary="Refresh access token",
)
async def refresh_token(
    request: RefreshTokenRequest,
    session: Session = Depends(get_session),
):
    """
    Get a new access token using a refresh token.

    Use this when access token expires.
    """
    payload = decode_access_token(request.refresh_token)

    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    user_id = payload.get("sub")
    user = session.get(User, int(user_id))

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    # Generate new tokens
    access_token = create_access_token(data={"sub": str(user.id)})
    new_refresh_token = create_refresh_token(data={"sub": str(user.id)})

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
    )

@router.get(
    "/me",
    response_model=UserResponse,
    summary="Get current user profile",
)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
):
    """
    Get the profile of the currently authenticated user.

    Requires valid JWT token in Authorization header.
    """
    return current_user
```

### Step 6: Create Auth Context (Frontend)

```typescript
// app/contexts/AuthContext.tsx
'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';

interface User {
  id: number;
  email: string;
  name: string;
}

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, name: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    // Check for existing token on mount
    checkAuth();
  }, []);

  const checkAuth = async () => {
    const token = localStorage.getItem('access_token');
    if (token) {
      try {
        const response = await fetch('http://localhost:8000/auth/me', {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (response.ok) {
          const userData = await response.json();
          setUser(userData);
        } else {
          // Token invalid, clear it
          localStorage.removeItem('access_token');
          localStorage.removeItem('refresh_token');
        }
      } catch (error) {
        console.error('Auth check failed:', error);
      }
    }
    setIsLoading(false);
  };

  const register = async (email: string, password: string, name: string) => {
    const response = await fetch('http://localhost:8000/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, name }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Registration failed');
    }

    // After registration, login automatically
    await login(email, password);
  };

  const login = async (email: string, password: string) => {
    const response = await fetch('http://localhost:8000/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    if (!response.ok) {
      throw new Error('Invalid credentials');
    }

    const data = await response.json();
    localStorage.setItem('access_token', data.access_token);
    localStorage.setItem('refresh_token', data.refresh_token);

    // Fetch user profile
    const userResponse = await fetch('http://localhost:8000/auth/me', {
      headers: {
        'Authorization': `Bearer ${data.access_token}`,
      },
    });

    const userData = await userResponse.json();
    setUser(userData);
  };

  const logout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    setUser(null);
    router.push('/login');
  };

  return (
    <AuthContext.Provider value={{ user, login, register, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

### Step 7: Create Middleware (Frontend)

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('access_token')?.value ||
                request.headers.get('authorization')?.split(' ')[1];

  const isAuthPage = request.nextUrl.pathname.startsWith('/login') ||
                     request.nextUrl.pathname.startsWith('/register');
  const isProtectedPage = request.nextUrl.pathname.startsWith('/dashboard');

  // Redirect authenticated users away from auth pages
  if (isAuthPage && token) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  // Redirect unauthenticated users to login
  if (isProtectedPage && !token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/login', '/register'],
};
```

## Output Format

### Generated Files Structure
```
backend/
├── app/
│   ├── routers/
│   │   └── auth.py              # Auth endpoints
│   ├── schemas/
│   │   └── auth.py              # Auth schemas
│   ├── dependencies/
│   │   └── auth.py              # get_current_user
│   └── utils/
│       └── security.py          # JWT & password utils

frontend/
├── app/
│   ├── contexts/
│   │   └── AuthContext.tsx      # Auth state management
│   ├── login/
│   │   └── page.tsx             # Login page
│   └── register/
│       └── page.tsx             # Register page
└── middleware.ts                # Route protection
```

## Quality Criteria

**Security (CRITICAL):**
- ✅ Passwords hashed with bcrypt (12+ rounds)
- ✅ JWT signed with strong secret (256-bit)
- ✅ Tokens have expiration times
- ✅ Generic error messages (don't reveal user existence)
- ✅ HTTPS in production
- ✅ No passwords in logs or responses

**Functionality:**
- ✅ Registration creates new users
- ✅ Login returns valid tokens
- ✅ Token refresh works
- ✅ Protected routes require auth
- ✅ Logout clears tokens
- ✅ User profile endpoint works

**User Experience:**
- ✅ Clear error messages
- ✅ Loading states during auth
- ✅ Redirect after login/logout
- ✅ Password strength validation
- ✅ Remember user across sessions

## Success Indicators

The skill execution is successful when:
- ✅ Users can register with secure passwords
- ✅ Login returns valid JWT tokens
- ✅ Protected endpoints require authentication (401 without token)
- ✅ Tokens can be refreshed before expiration
- ✅ Frontend redirects work correctly
- ✅ User state persists across page refreshes
- ✅ Logout clears all tokens and redirects
- ✅ No security vulnerabilities (OWASP Top 10)
