---
name: auth-frontend-backend
description: Expert skill for connecting frontend and backend with Better Auth, implementing user-isolated secure authentication using JWT tokens on every API call with rate limiting in Next.js 16 frontend and FastAPI backend.
---

# Authentication and Authorization Frontend-Backend Integration Skill

This skill provides expert knowledge for connecting frontend and backend with Better Auth, implementing user-isolated secure authentication using JWT tokens on every API call with rate limiting in Next.js 16 frontend and FastAPI backend.

## Overview

This skill focuses on creating a secure, user-isolated authentication and authorization system that connects Next.js 16 frontend with FastAPI backend using Better Auth as the authentication provider. The system implements JWT tokens for every API call and includes rate limiting for security and performance.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Next.js       │    │  Better Auth    │    │   FastAPI       │
│   Frontend      │◄──►│  (Authentication│◄──►│   Backend       │
│                 │    │  Provider)      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Backend Configuration (FastAPI)

### FastAPI JWT Authentication Setup

```python
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional
import jwt
from pydantic import BaseModel
import httpx
import os

app = FastAPI()

# JWT Security
security = HTTPBearer()

class User(BaseModel):
    id: str
    email: str
    name: Optional[str] = None

async def verify_jwt_token(token: str) -> User:
    """
    Verify JWT token with Better Auth and return user information
    """
    try:
        # Verify the token by calling Better Auth's session endpoint
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{os.getenv('BETTER_AUTH_BASE_URL')}/api getSession",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                }
            )

        if response.status_code == 200:
            session_data = response.json()
            return User(
                id=session_data["user"]["id"],
                email=session_data["user"]["email"],
                name=session_data["user"]["name"]
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token verification failed: {str(e)}"
        )

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> User:
    """
    Get current authenticated user from JWT token
    """
    return await verify_jwt_token(credentials.credentials)

# Rate limiting with slowapi
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Example protected endpoint with rate limiting
@app.get("/api/protected-data")
@limiter.limit("10/minute")  # 10 requests per minute per IP
async def get_protected_data(current_user: User = Depends(get_current_user)):
    """
    Example protected endpoint that requires JWT authentication
    and has rate limiting applied
    """
    return {
        "message": f"Hello {current_user.name or current_user.email}",
        "user_id": current_user.id,
        "data": "Protected data for authenticated user"
    }

# User-isolated endpoint example
@app.get("/api/user/profile")
@limiter.limit("20/minute")
async def get_user_profile(current_user: User = Depends(get_current_user)):
    """
    User-isolated endpoint - only returns data for the authenticated user
    """
    # Ensure user can only access their own data
    return {
        "user_id": current_user.id,
        "email": current_user.email,
        "name": current_user.name,
        "isolation_ensured": True
    }
```

## Frontend Configuration (Next.js 16)

### Better Auth Client Setup

```typescript
// lib/auth-client.ts
import { createAuthClient } from "better-auth/client";
import { jwtClient } from "better-auth/client/plugins";

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_BETTER_AUTH_BASE_URL || "http://localhost:3000",
  plugins: [jwtClient()],
  fetchOptions: {
    credentials: "include",
  },
});
```

### API Client with JWT Token Injection

```typescript
// lib/api-client.ts
import { authClient } from "./auth-client";

class ApiClient {
  private async getJwtToken(): Promise<string> {
    try {
      // Generate JWT token using Better Auth client
      const result = await authClient.jwt.generate();
      if (result.error) {
        throw new Error(result.error.message);
      }
      return result.data?.token || "";
    } catch (error) {
      console.error("Failed to get JWT token:", error);
      throw error;
    }
  }

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    // Get JWT token for authentication
    const token = await this.getJwtToken();

    // Set up headers with JWT token
    const headers = {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${token}`,
      ...options.headers,
    };

    try {
      const response = await fetch(`/api/${endpoint}`, {
        ...options,
        headers,
      });

      if (!response.ok) {
        if (response.status === 401) {
          // Token might be expired, redirect to login
          window.location.href = "/login";
          throw new Error("Authentication required");
        }
        throw new Error(`API request failed: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error(`API request error for ${endpoint}:`, error);
      throw error;
    }
  }

  // Specific API methods
  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: "GET" });
  }

  async post<T>(endpoint: string, data: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: "POST",
      body: JSON.stringify(data),
    });
  }

  async put<T>(endpoint: string, data: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: "PUT",
      body: JSON.stringify(data),
    });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: "DELETE" });
  }
}

export const apiClient = new ApiClient();
```

### Next.js API Route Protection

```typescript
// app/api/protected/route.ts
import { auth } from "@/lib/auth";
import { NextRequest } from "next/server";

export async function GET(request: NextRequest) {
  // Extract JWT token from Authorization header
  const authHeader = request.headers.get("authorization");

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return Response.json(
      { error: "Unauthorized: Missing or invalid authorization header" },
      { status: 401 }
    );
  }

  const token = authHeader.substring(7);

  try {
    // Verify JWT token with Better Auth
    const decoded = await auth.jwt.verify(token);

    // User is authenticated, proceed with the request
    return Response.json({
      message: "Access granted",
      userId: decoded.userId,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    return Response.json(
      { error: "Invalid or expired token" },
      { status: 401 }
    );
  }
}

// User-isolated data endpoint
export async function POST(request: NextRequest) {
  const authHeader = request.headers.get("authorization");

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return Response.json(
      { error: "Unauthorized" },
      { status: 401 }
    );
  }

  const token = authHeader.substring(7);

  try {
    const decoded = await auth.jwt.verify(token);
    const userId = decoded.userId;

    // Only allow user to access their own data
    const body = await request.json();
    const requestedUserId = body.userId;

    if (requestedUserId && requestedUserId !== userId) {
      return Response.json(
        { error: "Access denied: Cannot access other user's data" },
        { status: 403 }
      );
    }

    // Process the request for the authenticated user
    return Response.json({
      message: "User-isolated data processed successfully",
      userId: userId,
    });
  } catch (error) {
    return Response.json(
      { error: "Invalid or expired token" },
      { status: 401 }
    );
  }
}
```

### Rate Limiting in Next.js Middleware

```typescript
// middleware.ts
import { NextRequest, NextResponse } from "next/server";
import { auth } from "@/lib/auth";

// Simple in-memory rate limiter (use Redis in production)
const rateLimitMap = new Map();

const RATE_LIMIT = 100; // requests per 15 minutes
const TIME_WINDOW = 15 * 60 * 1000; // 15 minutes in milliseconds

function isRateLimited(identifier: string): boolean {
  const now = Date.now();
  const record = rateLimitMap.get(identifier);

  if (!record) {
    rateLimitMap.set(identifier, { count: 1, resetTime: now + TIME_WINDOW });
    return false;
  }

  if (now > record.resetTime) {
    // Reset the counter after the time window
    rateLimitMap.set(identifier, { count: 1, resetTime: now + TIME_WINDOW });
    return false;
  }

  if (record.count >= RATE_LIMIT) {
    return true; // Rate limited
  }

  // Increment the counter
  rateLimitMap.set(identifier, {
    count: record.count + 1,
    resetTime: record.resetTime
  });

  return false;
}

export async function middleware(request: NextRequest) {
  // Extract IP address for rate limiting
  const ip = request.headers.get("x-forwarded-for") || "127.0.0.1";

  // Apply rate limiting to API routes
  if (request.nextUrl.pathname.startsWith("/api/")) {
    if (isRateLimited(ip)) {
      return new NextResponse("Rate limit exceeded", { status: 429 });
    }
  }

  // Check authentication for protected routes
  if (request.nextUrl.pathname.startsWith("/dashboard") ||
      request.nextUrl.pathname.startsWith("/api/protected")) {

    const authHeader = request.headers.get("authorization");

    if (!authHeader && !request.cookies.get("better-auth.session_token")) {
      return NextResponse.redirect(new URL("/login", request.url));
    }

    // If there's an authorization header, verify the JWT token
    if (authHeader && authHeader.startsWith("Bearer ")) {
      const token = authHeader.substring(7);
      try {
        await auth.jwt.verify(token);
      } catch (error) {
        return NextResponse.redirect(new URL("/login", request.url));
      }
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/dashboard/:path*",
    "/api/:path*",
  ],
};
```

## Better Auth Configuration

### Backend Auth Setup

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { jwt } from "better-auth/plugins";

export const auth = betterAuth({
  database: {
    provider: "postgresql", // or your preferred database
    url: process.env.DATABASE_URL!,
  },
  secret: process.env.BETTER_AUTH_SECRET!,
  baseURL: process.env.BETTER_AUTH_BASE_URL,
  trustKey: process.env.BETTER_AUTH_TRUST_KEY,
  plugins: [
    jwt({
      algorithm: "HS256",
      expiresIn: "15m", // Short-lived access tokens
      issuer: process.env.BETTER_AUTH_ISSUER || "https://yourdomain.com",
      audience: [process.env.BETTER_AUTH_AUDIENCE || "https://api.yourdomain.com"],
    }),
  ],
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
  },
  socialProviders: {
    // Configure social providers as needed
  },
  rateLimit: {
    // Global rate limiting configuration
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
  },
});
```

### API Route Integration

```typescript
// app/api/auth/[...betterAuth]/route.ts
import { auth } from "@/lib/auth";

export const {
  GET,
  POST
} = auth;
```

## User Isolation Patterns

### Database Query Isolation

```python
# FastAPI endpoint with user isolation
@app.get("/api/user/tasks")
async def get_user_tasks(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    User-isolated endpoint - only returns tasks belonging to the authenticated user
    """
    # Ensure user can only access their own tasks
    tasks = db.query(Task).filter(Task.user_id == current_user.id).all()

    return {
        "tasks": [task.to_dict() for task in tasks],
        "user_id": current_user.id,
        "count": len(tasks)
    }

@app.put("/api/user/tasks/{task_id}")
async def update_user_task(
    task_id: int,
    task_update: TaskUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    User-isolated update - only allows updating tasks belonging to the authenticated user
    """
    # Verify the task belongs to the authenticated user
    task = db.query(Task).filter(
        Task.id == task_id,
        Task.user_id == current_user.id
    ).first()

    if not task:
        raise HTTPException(
            status_code=404,
            detail="Task not found or does not belong to user"
        )

    # Update the task
    for field, value in task_update.dict(exclude_unset=True).items():
        setattr(task, field, value)

    db.commit()
    db.refresh(task)

    return task
```

### Frontend User Isolation

```typescript
// components/TaskManager.tsx
"use client";

import { useState, useEffect } from "react";
import { apiClient } from "@/lib/api-client";
import { useAuth } from "@/contexts/AuthContext";

interface Task {
  id: number;
  title: string;
  completed: boolean;
  user_id: string;
}

export default function TaskManager() {
  const { user } = useAuth();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      fetchUserTasks();
    }
  }, [user]);

  const fetchUserTasks = async () => {
    try {
      setLoading(true);
      // Only fetch tasks for the authenticated user
      const data = await apiClient.get<{tasks: Task[]}>("user/tasks");
      setTasks(data.tasks);
    } catch (error) {
      console.error("Failed to fetch tasks:", error);
    } finally {
      setLoading(false);
    }
  };

  const updateTask = async (taskId: number, updates: Partial<Task>) => {
    try {
      // Ensure user can only update their own tasks by including user ID in the request
      const response = await apiClient.put<Task>(`user/tasks/${taskId}`, {
        ...updates,
        user_id: user?.id // Include user ID to enforce server-side isolation
      });

      setTasks(tasks.map(task =>
        task.id === taskId ? response : task
      ));
    } catch (error) {
      console.error("Failed to update task:", error);
    }
  };

  if (loading) return <div>Loading tasks...</div>;

  return (
    <div>
      <h2>Your Tasks</h2>
      <ul>
        {tasks.map(task => (
          <li key={task.id}>
            <span>{task.title}</span>
            <button onClick={() => updateTask(task.id, { completed: !task.completed })}>
              {task.completed ? 'Undo' : 'Complete'}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

## Rate Limiting Implementation

### FastAPI Rate Limiting with SlowAPI

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi import FastAPI, Request

# Initialize limiter
limiter = Limiter(key_func=get_remote_address)

def create_app():
    app = FastAPI()

    # Add rate limiting to the app
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

    return app

app = create_app()

# Apply rate limits to specific endpoints
@app.post("/api/messages")
@limiter.limit("5/minute")  # 5 messages per minute per IP
async def send_message(
    message: MessageCreate,
    current_user: User = Depends(get_current_user)
):
    # Implementation here
    pass

# Different rate limits for different user roles
@app.get("/api/data")
async def get_data(
    request: Request,  # Required for rate limiting
    current_user: User = Depends(get_current_user)
):
    # Apply different rate limits based on user role
    if current_user.role == "premium":
        # Premium users get higher limits
        @limiter.limit("100/minute")
        def _get_data_impl():
            return {"data": "premium user data"}
    else:
        @limiter.limit("10/minute")
        def _get_data_impl():
            return {"data": "standard user data"}

    return _get_data_impl()
```

### Advanced Rate Limiting with User Context

```python
from slowapi import Limiter
from slowapi.util import get_remote_address
import time

# Custom key function that combines IP and user ID for more granular rate limiting
def get_user_rate_limit_key(request: Request):
    # Get user from request (assuming it's been authenticated)
    auth_header = request.headers.get("authorization")
    user_id = "anonymous"

    if auth_header and auth_header.startswith("Bearer "):
        token = auth_header[7:]
        try:
            # Verify token and get user ID
            decoded = jwt.decode(token, os.getenv("JWT_SECRET"), algorithms=["HS256"])
            user_id = decoded.get("user_id", "anonymous")
        except:
            user_id = "invalid_token"

    # Combine IP and user ID for rate limiting
    ip = get_remote_address(request)
    return f"{ip}:{user_id}"

# Initialize limiter with custom key function
user_limiter = Limiter(key_func=get_user_rate_limit_key)

@app.post("/api/user/action")
@user_limiter.limit("30/minute")  # 30 requests per minute per user+IP combination
async def user_action(
    action_data: ActionData,
    current_user: User = Depends(get_current_user)
):
    # Implementation here
    pass
```

## Security Best Practices

### JWT Token Security

```typescript
// Enhanced JWT handling with security best practices
class SecureJwtHandler {
  private async refreshAccessTokenIfNeeded(): Promise<string> {
    // Check if token needs refresh (e.g., if it expires in the next 5 minutes)
    const token = localStorage.getItem("jwt_token");
    if (!token) {
      throw new Error("No token found");
    }

    try {
      // Decode to check expiration
      const payload = JSON.parse(atob(token.split('.')[1]));
      const exp = payload.exp * 1000; // Convert to milliseconds
      const now = Date.now();

      // Refresh if token expires in less than 5 minutes
      if (exp - now < 5 * 60 * 1000) {
        const refreshToken = localStorage.getItem("refresh_token");
        if (refreshToken) {
          // Call refresh endpoint
          const response = await fetch("/api/auth/refresh", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${refreshToken}`
            }
          });

          if (response.ok) {
            const data = await response.json();
            localStorage.setItem("jwt_token", data.access_token);
            return data.access_token;
          }
        }
      }

      return token;
    } catch (error) {
      console.error("Token refresh failed:", error);
      throw error;
    }
  }
}
```

### Environment Configuration

```env
# Backend Environment Variables
DATABASE_URL=postgresql://user:password@localhost:5432/myapp
BETTER_AUTH_SECRET=your-super-secret-key-here
BETTER_AUTH_BASE_URL=https://yourdomain.com
BETTER_AUTH_ISSUER=https://yourdomain.com
BETTER_AUTH_AUDIENCE=https://api.yourdomain.com

# Frontend Environment Variables
NEXT_PUBLIC_BETTER_AUTH_BASE_URL=https://yourdomain.com
NEXT_PUBLIC_API_BASE_URL=https://api.yourdomain.com

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000  # 15 minutes
RATE_LIMIT_MAX_REQUESTS=100
```

## Testing and Validation

### Authentication Testing

```python
# test_auth.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_protected_endpoint_without_auth():
    """Test that protected endpoints return 401 without authentication"""
    response = client.get("/api/protected-data")
    assert response.status_code == 401

def test_protected_endpoint_with_valid_token():
    """Test that protected endpoints work with valid JWT token"""
    # This would require a valid JWT token from Better Auth
    headers = {"Authorization": "Bearer valid_token_here"}
    response = client.get("/api/protected-data", headers=headers)
    assert response.status_code == 200

def test_user_isolation():
    """Test that users can't access other users' data"""
    # Test with a token for user A trying to access user B's data
    headers = {"Authorization": "Bearer user_a_token"}
    response = client.get("/api/user/tasks", headers=headers)
    # Should only return user A's tasks, not user B's
    assert response.status_code == 200
    data = response.json()
    # Verify that all tasks belong to user A
    for task in data["tasks"]:
        assert task["user_id"] == "user_a_id"
```

This skill provides comprehensive knowledge for implementing secure, user-isolated authentication between Next.js frontend and FastAPI backend using Better Auth, with JWT tokens for every API call and rate limiting for security and performance.