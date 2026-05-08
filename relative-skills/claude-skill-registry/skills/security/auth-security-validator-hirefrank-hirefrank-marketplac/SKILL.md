---
name: auth-security-validator
description: Autonomous validation of authentication security. Checks password hashing, cookie configuration, CSRF protection, and session management for OWASP compliance.
triggers: ["auth file changes", "session config changes", "security-related modifications", "pre-deployment"]
---

# Auth Security Validator SKILL

## Activation Patterns

This SKILL automatically activates when:
- Files matching `**/auth/**` are created/modified
- Session configuration files modified (app.config.ts, auth.ts)
- Password hashing code changes
- Cookie configuration changes
- Before deployment operations

## Validation Rules

### P1 - Critical (Block Operations)

**Password Hashing**:
- ✅ Uses Argon2id (`@node-rs/argon2`)
- ❌ NOT using: bcrypt, MD5, SHA-256, plain text
- ✅ Memory cost ≥ 19456 KB
- ✅ Time cost ≥ 2 iterations

**Cookie Security**:
- ✅ `secure: true` (HTTPS-only)
- ✅ `httpOnly: true` (XSS prevention)
- ✅ `sameSite: 'lax'` or `'strict'` (CSRF mitigation)

**Session Configuration**:
- ✅ Session password/secret ≥ 32 characters
- ✅ Max age configured (not infinite)

### P2 - Important (Warn)

**CSRF Protection**:
- ⚠️ CSRF protection enabled (automatic in better-auth)
- ⚠️ No custom form handlers bypassing CSRF

**Rate Limiting**:
- ⚠️ Rate limiting on login endpoint
- ⚠️ Rate limiting on register endpoint
- ⚠️ Rate limiting on password reset

**Input Validation**:
- ⚠️ Email format validation
- ⚠️ Password minimum length (8+ characters)
- ⚠️ Input sanitization

### P3 - Suggestions (Inform)

- ℹ️ Session rotation on privilege escalation
- ℹ️ 2FA/MFA support
- ℹ️ Account lockout after failed attempts
- ℹ️ Password complexity requirements
- ℹ️ OAuth state parameter validation

## Validation Output

```
🔒 Authentication Security Validation

✅ P1 Checks (Critical):
   ✅ Password hashing: Argon2id with correct params
   ✅ Cookies: secure, httpOnly, sameSite configured
   ✅ Session secret: 32+ characters

⚠️ P2 Checks (Important):
   ⚠️ No rate limiting on login endpoint
   ✅ Input validation present
   ✅ CSRF protection enabled

ℹ️ P3 Suggestions:
   ℹ️ Consider adding session rotation
   ℹ️ Consider 2FA for sensitive operations

📋 Summary: 1 warning found
💡 Run /es-auth-setup to fix issues
```

## Security Patterns Detected

**Good Patterns** ✅:
```typescript
// Argon2id with correct params
const hash = await argon2.hash(password, {
  memoryCost: 19456,
  timeCost: 2,
  outputLen: 32,
  parallelism: 1
});

// Secure cookie config
cookie: {
  secure: true,
  httpOnly: true,
  sameSite: 'lax'
}
```

**Bad Patterns** ❌:
```typescript
// Weak hashing
const hash = crypto.createHash('sha256').update(password).digest('hex'); // ❌

// Insecure cookies
cookie: {
  secure: false, // ❌
  httpOnly: false // ❌
}

// Weak session secret
password: '12345' // ❌ Too short
```

## Escalation

Complex scenarios escalate to `better-auth-specialist` agent:
- Custom authentication flows
- Advanced OAuth configuration
- Passkey implementation
- Multi-factor authentication setup
- Security audit requirements

## Notes

- Runs automatically on auth-related file changes
- Can block deployments with P1 security issues
- Follows OWASP Top 10 guidelines
- Integrates with `/validate` and `/es-deploy` commands
- Queries better-auth MCP for provider security requirements
