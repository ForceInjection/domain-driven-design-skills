---
name: "docusaurus-auth"
description: "Expert skill for implementing authentication in Docusaurus static sites. Handles FastAPI backend setup for authentication, JWT token management, and secure API communication. Includes setup for static site generation, client-side authentication, and user data protection. Use when adding authentication to Docusaurus static sites, implementing FastAPI backend for authentication services, or securing API routes with JWT tokens in static site context."
---

# Docusaurus Authentication Skill

## When to Use This Skill

- User wants to add authentication to a Docusaurus static site
- Need to implement FastAPI backend for authentication services
- Want to secure API routes with JWT tokens in static site context
- Looking for client-side authentication with server verification
- Need to implement user data personalization in documentation sites

## How This Skill Works (Step-by-Step Execution)

1. **Docusaurus Setup Analysis**
   - Identify static site generation requirements
   - Determine where authentication UI should be placed
   - Plan static vs dynamic content strategy

2. **FastAPI Authentication Backend**
   - Set up user registration/login endpoints
   - Implement JWT token generation and verification
   - Create protected API routes for personalized content
   - Configure database for user management

3. **Client-Side Integration**
   - Implement login form in Docusaurus
   - Add token storage and management
   - Create authentication state management
   - Add protected content rendering

4. **Security Implementation**
   - Configure proper CORS settings
   - Implement token refresh mechanisms
   - Add secure token storage
   - Set up user data isolation

## Output You Will Receive

After activation, I will deliver:

- Complete FastAPI backend setup with authentication
- Docusaurus client-side authentication integration
- JWT token management implementation
- Protected content rendering examples
- Security best practices for static sites
- CORS and API communication configuration

## Example Usage

**User says:**
"I have a Docusaurus site and need to add user authentication with personalized content."

**This Skill Instantly Activates → Delivers:**

- FastAPI backend with user registration/login
- JWT token generation and verification
- Docusaurus login form implementation
- Client-side token management
- Protected content rendering
- User data isolation in API responses

**User says:**
"Secure my Docusaurus documentation with authentication."

**This Skill Responds:**
→ Creates FastAPI authentication backend
→ Implements JWT-based security
→ Adds client-side login integration
→ Provides personalized content delivery
→ Sets up user data protection

## Activate This Skill By Saying

- "Add authentication to my Docusaurus site"
- "Implement login for my documentation site"
- "Secure Docusaurus with JWT authentication"
- "I need personalized content in Docusaurus"

## Core Implementation Steps

### 1. FastAPI Backend Setup
```bash
uv add pyjwt passlib[bcrypt]
```

### 2. User Model
```python
from sqlmodel import SQLModel, Field
from typing import Optional

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str
    password_hash: str
```

### 3. Login Endpoint (Issue JWT)
```python
import jwt
from datetime import datetime, timedelta
from fastapi import HTTPException

SECRET = "super-secret"  # Use environment variable
ALGO = "HS256"

@app.post("/login")
def login(email: str, password: str):
    user = get_user_by_email(email)
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(status_code=401)

    payload = {
        "sub": str(user.id),
        "exp": datetime.utcnow() + timedelta(days=7),
    }

    token = jwt.encode(payload, SECRET, algorithm=ALGO)
    return {"token": token}
```

### 4. Docusaurus Client Integration
```js
// Login and store token
const res = await fetch("http://localhost:8000/login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email, password }),
});

const { token } = await res.json();
localStorage.setItem("token", token);
```

### 5. Token Verification Dependency
```python
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Depends

security = HTTPBearer()

def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(security),
):
    try:
        payload = jwt.decode(
            creds.credentials,
            SECRET,
            algorithms=[ALGO],
        )
        return payload["sub"]  # user_id
    except jwt.PyJWTError:
        raise HTTPException(status_code=401)
```

### 6. Protect API Routes
```python
@app.get("/me")
def me(user_id: str = Depends(get_current_user)):
    return {"user_id": user_id}

# Call from Docusaurus with token
fetch("http://localhost:8000/me", {
  headers: {
    Authorization: `Bearer ${localStorage.getItem("token")}`,
  },
});
```
