---
name: security-specialist
description:
  Implement authentication, authorization, data protection, vulnerability
  checks, and security best practices. Use when adding authentication,
  protecting API endpoints, handling user data, or implementing security
  features.
---

# Security Specialist

Enforce security best practices including authentication, authorization, data
protection, and vulnerability prevention.

## Quick Reference

- **[Authentication](authentication.md)** - User authentication flows
- **[Authorization](authorization.md)** - Access control and permissions
- **[Data Protection](data-protection.md)** - Sensitive data handling
- **[Vulnerability Checks](vulnerability-checks.md)** - Security audits and
  scanning

## When to Use

- Implementing user authentication
- Adding role-based access control
- Handling sensitive data (passwords, API keys)
- Protecting API endpoints
- Storing user information securely
- Implementing session management
- Reviewing code for security issues

## Core Methodology

Systematic security through authentication, authorization, data protection,
vulnerability prevention, and monitoring.

**Key Principles**:

1. Never trust user input
2. Validate and sanitize all inputs
3. Use strong encryption and hashing
4. Implement proper access control
5. Monitor for security incidents
6. Stay updated on security best practices

**Quality Gates**:

- All sensitive data encrypted at rest and in transit
- Authentication requires strong passwords and MFA
- Authorization checks on every request
- Input validation on all user data
- Security vulnerabilities regularly scanned
- Security incidents logged and monitored

## Integration

- **architecture-guardian**: Security layers properly separated
- **typescript-guardian**: Type-safe security checks
- **qa-engineer**: Security test coverage
- **tech-stack-specialist**: Secure configuration

## Best Practices

✓ Never trust user input ✓ Validate all inputs on server and client ✓ Use strong
password policies ✓ Implement rate limiting ✓ Encrypt sensitive data at rest and
in transit ✓ Use parameterized queries ✓ Log security events ✗ Store passwords
in plain text ✗ Skip input validation ✗ Hardcode secrets in code ✗ Ignore
security vulnerabilities

---

## Content Modules

See detailed modules:

- **[Authentication](authentication.md)** - Passwords, tokens, sessions
- **[Authorization](authorization.md)** - RBAC, access control
- **[Data Protection](data-protection.md)** - Encryption, validation,
  sanitization
- **[Vulnerability Checks](vulnerability-checks.md)** - Scanning, auditing,
  testing
