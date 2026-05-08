---
name: Reviewing Authentication and Authorization Security
description: Use when reviewing authentication or authorization code. Provides comprehensive security guidance on JWT validation, token exchange, OAuth 2.0/2.1 compliance, PKCE, Resource Indicators, MCP authorization, session management, and API authentication. Covers critical vulnerabilities including token forwarding, audience validation, algorithm confusion, confused deputy attacks, and authentication bypass. Invoke when analyzing any authentication, authorization, or access control code changes.
---

# Authentication and Authorization Security Review

This skill provides comprehensive security guidance for reviewing authentication and authorization code, with deep expertise in JWT tokens and MCP (Model Context Protocol) servers.

## When to Use This Skill

Invoke this skill when reviewing:
- JWT authentication or authorization implementation
- OAuth 2.0/2.1 flows and token handling
- Service-to-service authentication patterns
- MCP server implementations
- Code that forwards, exchanges, or validates tokens
- Authorization middleware or security filters
- API authentication endpoints
- Session management and cookie-based authentication
- API key or bearer token authentication
- Role-based access control (RBAC) or permission systems
- Multi-factor authentication (MFA) flows

## Key Security Areas

### 1. JWT Token Security

For comprehensive JWT security guidance, see `reference/jwt-security.md`. Key areas:

**Critical Vulnerabilities:**
- **Token Forwarding**: Never forward JWTs to services not in their audience claim
- **Audience Validation**: Every service MUST validate the `aud` claim
- **Algorithm Confusion**: Explicit algorithm enforcement (no `none`, no user-controlled)
- **Signature Validation**: All tokens must be cryptographically verified

**Severity Levels:**
- CRITICAL: Token forwarding, missing signature validation, algorithm confusion
- HIGH: Missing audience/issuer validation, token exchange not used
- MEDIUM: Weak secrets, overly broad scopes, insecure storage

**Correct Pattern - Token Exchange:**
When Service A needs to call Service B on behalf of a user:
1. Service A validates user's token
2. Service A exchanges token for Service B-specific token (RFC 8693)
3. Service A calls Service B with the exchanged token
4. Service B validates the token has correct audience claim

**Review Checklist:**
- [ ] Audience validation for all services
- [ ] Explicit algorithm enforcement
- [ ] Signature validation present
- [ ] Token exchange used (not forwarding)
- [ ] Issuer validation against trusted sources
- [ ] Expiration and other claim validation
- [ ] Secure token storage (not in URLs or localStorage for sensitive data)

### 2. MCP Server Security

For comprehensive MCP authorization guidance, see `reference/mcp-authorization.md`. Key areas:

**MCP Specification Requirements (June 2025):**
- **OAuth 2.1**: MUST use OAuth 2.1 (not 2.0)
- **PKCE**: Mandatory for all authorization flows
- **Resource Indicators (RFC 8707)**: Mandatory for explicit audience targeting
- **Audience Validation**: MCP servers MUST validate tokens are issued for them
- **No Sessions**: MUST NOT use session-based authentication for MCP operations

**Critical MCP Vulnerability - Token Forwarding:**

The most common and critical MCP security issue is forwarding user tokens from inference servers to MCP servers.

```
❌ INSECURE:
User → Inference Server (user JWT) → MCP Server (forwarded user JWT)
Problem: MCP server accepts token not issued for it (confused deputy attack)

✅ SECURE:
User → Inference Server (user JWT) → Auth Server (token exchange)
                                    → MCP Server (MCP-specific JWT)
Benefit: MCP token has correct audience claim and downscoped permissions
```

**Review Checklist:**
- [ ] OAuth 2.1 implementation (not 2.0)
- [ ] PKCE with S256 method in all flows
- [ ] Resource Indicators in token requests
- [ ] Audience validation matches MCP server identifier
- [ ] Token exchange for upstream service calls
- [ ] Scope validation with insufficient_scope responses
- [ ] No session-based authentication for MCP operations
- [ ] HTTPS/TLS for all communication
- [ ] Input validation for tool parameters (prompt injection protection)

### 3. Common Security Anti-Patterns

**Token Forwarding (CRITICAL):**
```python
# ❌ CRITICAL ISSUE
def call_api(user_token):
    response = requests.get(
        "https://other-service/api",
        headers={"Authorization": f"Bearer {user_token}"}
    )
```

**Missing Audience Validation (CRITICAL):**
```python
# ❌ VULNERABLE
decoded = jwt.decode(token, public_key, algorithms=['RS256'])
# Missing audience validation!

# ✅ SECURE
decoded = jwt.decode(
    token,
    public_key,
    algorithms=['RS256'],
    audience='https://api.myservice.com',
    issuer='https://auth.example.com'
)
```

**Algorithm Confusion (CRITICAL):**
```python
# ❌ VULNERABLE
header = jwt.get_unverified_header(token)
decoded = jwt.decode(token, key, algorithms=[header['alg']])

# ✅ SECURE
decoded = jwt.decode(token, public_key, algorithms=['RS256'])
```

## Review Workflow

### 1. Identify Security-Sensitive Code

Scan for:
- JWT encoding/decoding operations
- OAuth flow implementations
- Token forwarding between services
- MCP server endpoints
- Authorization middleware
- API authentication handlers

### 2. Apply Appropriate Checklist

Use the checklists from:
- `reference/jwt-security.md` for JWT-related code
- `reference/mcp-authorization.md` for MCP server code

### 3. Categorize Findings

Follow the severity guide from the pr-review skill:
- **CRITICAL**: Security vulnerabilities, must block merge
- **HIGH**: Significant security issues, should fix before merge
- **MEDIUM**: Security improvements, should address
- **LOW**: Security suggestions, optional

### 4. Provide Specific Guidance

For each finding:
- Identify the specific vulnerability
- Explain why it's a security issue
- Reference the relevant RFC or standard
- Provide concrete code example of the fix
- Include file:line references

## Key RFCs and Standards

### JWT and OAuth
- **RFC 7519**: JSON Web Token (JWT)
- **RFC 8693**: OAuth 2.0 Token Exchange
- **RFC 8707**: Resource Indicators for OAuth 2.0
- **RFC 9068**: JWT Profile for OAuth 2.0 Access Tokens
- **RFC 9700**: OAuth 2.0 Security Best Current Practice (January 2025)

### MCP
- **MCP Authorization Spec** (June 2025): OAuth 2.1 for MCP
- **RFC 7636**: PKCE (mandatory for MCP)
- **OAuth 2.1**: Required authorization framework for MCP

## When to Escalate

Mark as CRITICAL and escalate if you find:

**JWT Issues:**
- Tokens forwarded to services not in their audience
- Missing signature validation
- Algorithm confusion vulnerabilities
- No audience or issuer validation
- Tokens in URLs or logged in full

**MCP Issues:**
- Token forwarding from inference/API servers to MCP servers
- Missing audience validation in MCP server
- No PKCE in authorization flows
- Missing Resource Indicators in token requests
- Session-based authentication for MCP operations
- MCP tools with code execution and no sandboxing
- HTTP (not HTTPS) in production

## Validation

Before completing security review, ensure:
- [ ] All JWT operations reviewed against JWT checklist
- [ ] All MCP operations reviewed against MCP checklist
- [ ] Token flow patterns verified (exchange vs. forwarding)
- [ ] Severity assigned to each finding
- [ ] Specific remediation guidance provided
- [ ] File:line references included
- [ ] RFC/standard references cited

## Reference Documentation

For detailed security guidance:
- **`reference/jwt-security.md`**: Comprehensive JWT security best practices, common vulnerabilities, and code examples
- **`reference/mcp-authorization.md`**: Complete MCP OAuth 2.1 implementation guide, architecture patterns, and security considerations

These references contain detailed examples, vulnerability explanations, and implementation patterns. Consult them when you need deep technical context for security findings.
