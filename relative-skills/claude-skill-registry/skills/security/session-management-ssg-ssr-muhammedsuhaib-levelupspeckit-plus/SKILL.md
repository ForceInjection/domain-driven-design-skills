---
name: "session-management-ssg-ssr"
description: "Expert skill for implementing session management in SSG (Static Site Generation) and SSR (Server-Side Rendering) contexts. Covers stateless authentication with JWT, database session management, client-side session handling, and security best practices for different rendering strategies. Use when implementing session management in static sites (SSG), handling authentication in server-side rendered applications (SSR), or implementing stateless authentication with JWT tokens."
---

# Session Management for SSG/SSR Skill

## When to Use This Skill

- User wants to implement session management in static sites (SSG)
- Need to handle authentication in server-side rendered applications (SSR)
- Looking for stateless authentication with JWT tokens
- Want to implement database session management in web applications
- Need to handle sessions across different rendering strategies (SSG/SSR/CSR)

## How This Skill Works (Step-by-Step Execution)

1. **Context Analysis**
   - Determine if application uses SSG, SSR, or CSR
   - Identify authentication requirements for each context
   - Plan session strategy based on rendering approach

2. **Stateless Authentication Setup**
   - Implement JWT-based session management
   - Configure token generation and verification
   - Set up expiration and refresh mechanisms

3. **Database Session Management**
   - Create session models for database storage
   - Implement session creation and validation
   - Add session cleanup and expiration handling

4. **Client-Side Session Handling**
   - Implement token storage strategies (localStorage, cookies)
   - Create session state management
   - Add token refresh and renewal mechanisms

5. **Security Implementation**
   - Configure proper session security headers
   - Implement secure token transmission
   - Add session hijacking prevention measures

## Output You Will Receive

After activation, I will deliver:

- Complete session management strategy for your context
- JWT implementation for stateless sessions
- Database session models and management
- Client-side session handling code
- Security best practices for session management
- Context-specific implementation guides

## Example Usage

**User says:**
"I have a Next.js app with SSG and need to implement session management."

**This Skill Instantly Activates → Delivers:**

- JWT-based authentication strategy for static sites
- Client-side session management with token storage
- Server-side verification for API routes
- Session persistence across page navigations
- Security best practices for SSG contexts

**User says:**
"Implement session management in my SSR application."

**This Skill Responds:**
→ Creates database session management approach
→ Implements server-side session validation
→ Adds client-side session synchronization
→ Provides security headers configuration
→ Sets up session cleanup and expiration

## Activate This Skill By Saying

- "Add session management to my SSG app"
- "Implement sessions in my SSR application"
- "JWT session management for static sites"
- "Database session management for web apps"

## Core Implementation Steps

### 1. Database Session Model (SQLModel/SQLAlchemy)
```python
from sqlmodel import SQLModel, Field, Session
from typing import Optional

class Session(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str
    session_token: str
    expires_at: datetime
    created_at: datetime
    ip_address: str
    user_agent: str
```

### 2. Session Management Explanation
```
Session = database connection wrapper that:
- Opens DB connection
- Sends queries
- Manages transactions
- Commits or rolls back
- Closes automatically

Usage:
with Session(engine) as session:
  # Open connection
  # Use during request
  # Auto-close after request

Why sessions are needed:
- Transaction safety
- Prevents connection leaks
- Handles commit / rollback
- Isolates each request

Rule: 1 request = 1 DB session
```

### 3. JWT Stateless Session (Frontend)
```typescript
// Store JWT token in localStorage
localStorage.setItem('auth_token', jwt_token);

// Include in API requests
fetch('/api/protected', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('auth_token')}`
  }
});
```

### 4. Session Validation (Backend)
```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer

security = HTTPBearer()

def validate_session(token: str = Depends(security)):
    # Verify JWT token or check database session
    # Return user info if valid
    pass

@app.get("/protected")
def protected_route(user = Depends(validate_session)):
    return {"message": "Access granted"}
```

### 5. SSG Session Handling
```javascript
// Check session on client-side after page load
if (typeof window !== 'undefined') {
  const token = localStorage.getItem('auth_token');
  if (token) {
    // Validate token with backend
    fetch('/api/validate-session', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
  }
}
```
