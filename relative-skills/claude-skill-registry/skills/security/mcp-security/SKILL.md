---
name: mcp-security
description: Multi-agent and MCP pipeline security with 5-layer defense architecture. Use when building MCP servers, multi-agent systems, or any pipeline that handles user input to prevent prompt injection and ensure proper authorization.
---

# MCP Security Skill

This skill enforces security best practices for MCP servers and multi-agent pipelines.

## 5-Layer Defense Architecture

1. **Input Validation** - Sanitize all user inputs
2. **Prompt Injection Prevention** - Detect and block injection attempts
3. **SQL/NoSQL Validation** - Prevent query injection
4. **User Context Propagation** - Maintain identity through pipeline
5. **Authorization (RBAC/ABAC)** - Enforce access controls

## Prompt Injection Prevention

```python
# Always validate and sanitize inputs
def sanitize_input(user_input: str) -> str:
    # Remove potential injection patterns
    # Escape special characters
    # Limit length
    pass

# Never directly concatenate user input into prompts
# ❌ Bad
prompt = f"Process this: {user_input}"

# ✅ Good
prompt = sanitize_input(user_input)
validated_prompt = validate_against_schema(prompt)
```

## User Context Propagation

```python
@dataclass
class UserContext:
    user_id: str
    roles: list[str]
    permissions: list[str]
    tenant_id: str

# Pass context through all pipeline stages
async def process_request(context: UserContext, request: Request):
    # Validate permissions at each step
    if not has_permission(context, "read:data"):
        raise AuthorizationError()
```

## Authorization Patterns

### RBAC (Role-Based Access Control)
```python
ROLE_PERMISSIONS = {
    "admin": ["read", "write", "delete", "admin"],
    "editor": ["read", "write"],
    "viewer": ["read"],
}
```

### ABAC (Attribute-Based Access Control)
```python
def can_access(user: User, resource: Resource) -> bool:
    return (
        user.department == resource.department
        and user.clearance >= resource.sensitivity
    )
```

## Security Checklist

- [ ] All user inputs validated and sanitized
- [ ] Prompt injection patterns detected
- [ ] SQL queries parameterized
- [ ] User context propagated through pipeline
- [ ] Authorization checked at each step
- [ ] Sensitive data encrypted
- [ ] Audit logging enabled
