---
name: Security Auditing
description: Audit security with vulnerability scanning, input validation checks, and auth/authz review against OWASP Top 10. Use when implementing authentication, reviewing security-sensitive code, or conducting security audits.
---

# Security Auditing

## Purpose
Provides security best practices, patterns, and checklists for ensuring secure code implementation.

## When to Use
- Implementing authentication or authorization systems
- Reviewing code for security vulnerabilities
- Validating input/output handling
- Designing secure APIs
- Conducting security audits
- Analyzing data protection requirements

## Security Checklist

### Input Validation
- ✅ Sanitize all external inputs
- ✅ Validate data types and formats
- ✅ Implement whitelist validation where possible
- ✅ Prevent SQL injection via parameterized queries
- ✅ Guard against XSS attacks
- ✅ Validate file uploads (type, size, content)

### Authentication & Authorization
- ✅ Use strong password hashing (bcrypt, Argon2)
- ✅ Implement proper session management
- ✅ Use secure token generation (JWT with proper signing)
- ✅ Implement token expiration and refresh strategies
- ✅ Apply role-based access control (RBAC)
- ✅ Verify permissions at every access point
- ✅ Use multi-factor authentication for sensitive operations

### Data Protection
- ✅ Encrypt sensitive data at rest
- ✅ Use TLS/HTTPS for data in transit
- ✅ Implement proper key management
- ✅ Avoid storing sensitive data in logs
- ✅ Implement data retention policies
- ✅ Comply with GDPR/HIPAA requirements if applicable

### API Security
- ✅ Implement rate limiting
- ✅ Use API keys or OAuth for authentication
- ✅ Validate and sanitize all API inputs
- ✅ Implement proper CORS policies
- ✅ Use security headers (CSP, HSTS, X-Frame-Options)
- ✅ Version APIs to manage breaking changes safely

### Audit Logging
- ✅ Log all authentication attempts
- ✅ Log authorization failures
- ✅ Track sensitive data access
- ✅ Log configuration changes
- ✅ Implement secure log storage
- ✅ Monitor logs for suspicious activity

## Common Vulnerabilities

### OWASP Top 10
1. **Injection**: Use parameterized queries, input validation
2. **Broken Authentication**: Implement secure session management
3. **Sensitive Data Exposure**: Encrypt data, use HTTPS
4. **XML External Entities (XXE)**: Disable XML external entity processing
5. **Broken Access Control**: Verify permissions at every endpoint
6. **Security Misconfiguration**: Follow security hardening guides
7. **Cross-Site Scripting (XSS)**: Sanitize output, use CSP headers
8. **Insecure Deserialization**: Validate serialized data
9. **Using Components with Known Vulnerabilities**: Keep dependencies updated
10. **Insufficient Logging & Monitoring**: Implement comprehensive logging

## Security Patterns

### Secure Configuration
```yaml
security_config:
  session:
    secure: true
    httpOnly: true
    sameSite: "strict"
    maxAge: 3600

  passwords:
    minLength: 12
    requireSpecialChars: true
    hashAlgorithm: "argon2"

  api:
    rateLimit: 100/minute
    corsOrigins: ["https://trusted-domain.com"]
    requireApiKey: true
```

### Authentication Flow
```
1. User submits credentials
2. Validate input format
3. Check against secure hash in database
4. Generate secure session token (JWT)
5. Set secure, httpOnly cookie
6. Return success with minimal user info
7. Log authentication event
```

### Authorization Pattern
```
1. Receive request with token
2. Validate token signature and expiration
3. Extract user roles/permissions
4. Check if user has required permission
5. Execute action if authorized
6. Log authorization decision
7. Return 403 if unauthorized
```

## Security Commands

### Dependency Scanning
```bash
# Python
pip-audit

# Node.js
npm audit
npm audit fix

# General
snyk test
```

### Static Analysis
```bash
# Python
bandit -r src/

# Node.js
npm run lint:security
```

### Secrets Detection
```bash
# Detect secrets in code
trufflehog filesystem .
git-secrets --scan

# Scan for API keys
detect-secrets scan
```

## Best Practices

### Code Review Security Checklist
- [ ] All inputs validated and sanitized
- [ ] Outputs properly encoded
- [ ] Authentication required for sensitive operations
- [ ] Authorization checked at every access point
- [ ] Sensitive data encrypted
- [ ] Error messages don't leak information
- [ ] Dependencies up to date
- [ ] Security headers implemented
- [ ] Rate limiting in place
- [ ] Audit logging configured

### Secure Development Workflow
1. **Design Phase**: Threat modeling, security requirements
2. **Development**: Follow secure coding guidelines
3. **Testing**: Security unit tests, penetration testing
4. **Review**: Security-focused code review
5. **Deployment**: Security configuration review
6. **Monitoring**: Active security monitoring and alerts

## Additional Resources
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- CWE Top 25: https://cwe.mitre.org/top25/
- Security Headers: https://securityheaders.com/

---
*Use this skill when implementing security features or conducting security reviews*
