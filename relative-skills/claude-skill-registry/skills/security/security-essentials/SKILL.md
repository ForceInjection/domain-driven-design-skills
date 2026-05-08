---
name: security-essentials
description: Security best practices, OWASP compliance, authentication patterns, and vulnerability prevention
triggers: [security, auth, authentication, authorization, OWASP, vulnerability, encryption, secure, XSS, CSRF, SQL injection]
version: 1.0.0
agents: [security-specialist, senior-fullstack-developer, qa-testing-engineer]
context_levels:
  minimal: Critical security rules and quick checklist
  detailed: OWASP Top 10 and implementation patterns
  full: Security scanning scripts and remediation guides
---

# Security Essentials Skill

## Overview
This skill provides comprehensive security guidance following OWASP standards and industry best practices. It ensures secure code development and vulnerability prevention.

## When to Use This Skill
- Implementing authentication/authorization
- Handling sensitive user data
- Security reviews before production
- API security hardening
- Compliance requirements (GDPR, SOC2)
- Vulnerability remediation

## Critical Security Rules (Level 1 - Always Loaded)

### 🔴 MUST Requirements

**SEC-1: Input Validation (CRITICAL)**
```typescript
// ✅ GOOD - Validate at boundaries
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(8).max(128),
  name: z.string().min(1).max(100).regex(/^[a-zA-Z\s]+$/),
});

function createUser(input: unknown) {
  // Validation happens at system boundary
  const validated = userSchema.parse(input);
  return userService.create(validated);
}

// ❌ BAD - No validation
function createUser(input: any) {
  return userService.create(input); // Unsafe!
}
```

**SEC-2: Output Sanitization (CRITICAL)**
```typescript
import DOMPurify from 'isomorphic-dompurify';

// ✅ GOOD - Sanitize before rendering
function displayUserContent(html: string) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em'],
    ALLOWED_ATTR: []
  });
  return <div dangerouslySetInnerHTML={{ __html: clean }} />;
}

// ❌ BAD - XSS vulnerability
function displayUserContent(html: string) {
  return <div dangerouslySetInnerHTML={{ __html: html }} />; // XSS!
}
```

**SEC-3: Secrets Management (CRITICAL)**
```typescript
// ✅ GOOD - Environment variables
const config = {
  apiKey: process.env.API_KEY,
  dbPassword: process.env.DB_PASSWORD,
  jwtSecret: process.env.JWT_SECRET,
};

// Validate at startup
if (!config.apiKey || !config.dbPassword || !config.jwtSecret) {
  throw new Error('Missing required environment variables');
}

// ❌ BAD - Hardcoded secrets
const config = {
  apiKey: 'sk-1234567890abcdef', // NEVER DO THIS!
  dbPassword: 'admin123',
  jwtSecret: 'my-secret-key',
};
```

**SEC-4: Never Log Sensitive Data (CRITICAL)**
```typescript
// ✅ GOOD - Redact sensitive fields
logger.info('User login attempt', {
  userId: user.id,
  email: user.email,
  // password is NOT logged
});

// ❌ BAD - Logging sensitive data
logger.info('User login', {
  email: user.email,
  password: user.password, // NEVER LOG PASSWORDS!
  creditCard: user.creditCard, // NEVER LOG PII!
});
```

**SEC-5: Authentication Best Practices**
```typescript
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// ✅ GOOD - Secure password hashing
async function hashPassword(password: string): Promise<string> {
  const saltRounds = 12;
  return bcrypt.hash(password, saltRounds);
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// ✅ GOOD - Secure JWT generation
function generateToken(userId: string): string {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET!,
    {
      expiresIn: '1h',
      algorithm: 'HS256',
    }
  );
}

// ❌ BAD - Plain text password storage
function savePassword(password: string) {
  db.query('INSERT INTO users (password) VALUES (?)', [password]); // NEVER!
}
```

**SEC-6: SQL Injection Prevention**
```typescript
// ✅ GOOD - Parameterized queries
async function getUserByEmail(email: string) {
  return db.query(
    'SELECT * FROM users WHERE email = $1',
    [email] // Parameterized
  );
}

// ❌ BAD - String concatenation (SQL injection!)
async function getUserByEmail(email: string) {
  return db.query(
    `SELECT * FROM users WHERE email = '${email}'` // SQL Injection!
  );
}
```

**SEC-7: CSRF Protection**
```typescript
import csrf from 'csurf';
import cookieParser from 'cookie-parser';

// ✅ GOOD - CSRF tokens
app.use(cookieParser());
app.use(csrf({ cookie: true }));

app.get('/form', (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});

app.post('/submit', (req, res) => {
  // CSRF token automatically verified
  res.send('Data processed');
});
```

**SEC-8: Secure Headers**
```typescript
import helmet from 'helmet';

// ✅ GOOD - Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}));

// Cookie security
app.use(session({
  secret: process.env.SESSION_SECRET!,
  cookie: {
    secure: true, // HTTPS only
    httpOnly: true, // No JavaScript access
    sameSite: 'strict', // CSRF protection
    maxAge: 3600000, // 1 hour
  },
}));
```

## Security Checklist (Quick Reference)

Before deploying to production:
- [ ] All inputs validated at system boundaries
- [ ] All outputs sanitized (XSS prevention)
- [ ] No hardcoded secrets (use env vars/vault)
- [ ] Passwords hashed with bcrypt (saltRounds >= 12)
- [ ] SQL queries parameterized (no string concatenation)
- [ ] CSRF protection enabled
- [ ] Security headers configured (Helmet.js)
- [ ] HTTPS enforced (TLS 1.2+)
- [ ] Rate limiting implemented
- [ ] Authentication tokens expire
- [ ] Sensitive data never logged
- [ ] Dependency vulnerabilities checked
- [ ] Error messages don't leak info

## OWASP Top 10 Quick Reference

1. **Broken Access Control** → Implement proper authorization checks
2. **Cryptographic Failures** → Use strong encryption, TLS everywhere
3. **Injection** → Parameterized queries, input validation
4. **Insecure Design** → Security by design, threat modeling
5. **Security Misconfiguration** → Secure defaults, minimal permissions
6. **Vulnerable Components** → Keep dependencies updated
7. **Authentication Failures** → MFA, secure session management
8. **Data Integrity Failures** → Verify data integrity, use signatures
9. **Logging Failures** → Log security events, protect logs
10. **SSRF** → Validate URLs, whitelist allowed domains

## Detailed Patterns (Level 2 - Load on Request)

See companion files:
- `owasp-guide.md` - Detailed OWASP Top 10 implementations
- `auth-patterns.md` - JWT, OAuth2, MFA implementations
- `encryption-guide.md` - Encryption at rest and in transit

## Security Tools (Level 3 - Load When Needed)

See scripts directory:
- `scripts/security-scan.sh` - Run comprehensive security scan
- `scripts/dependency-check.sh` - Check for vulnerable dependencies
- `scripts/secret-scan.sh` - Scan for exposed secrets

## Integration with Agents

**security-specialist:**
- Primary agent for security reviews
- Uses this skill for all security assessments
- Read-only access (no code modification)

**senior-fullstack-developer:**
- Uses this skill when implementing auth/security features
- References patterns for secure implementation

**qa-testing-engineer:**
- Uses this skill for security test cases
- Validates against security checklist

## Common Vulnerabilities & Fixes

### XSS (Cross-Site Scripting)
```typescript
// Vulnerable
function renderHTML(userInput: string) {
  document.innerHTML = userInput; // XSS!
}

// Fixed
import DOMPurify from 'isomorphic-dompurify';
function renderHTML(userInput: string) {
  const clean = DOMPurify.sanitize(userInput);
  document.innerHTML = clean;
}
```

### Path Traversal
```typescript
// Vulnerable
app.get('/file/:filename', (req, res) => {
  const file = path.join(__dirname, req.params.filename);
  res.sendFile(file); // Path traversal: ../../etc/passwd
});

// Fixed
app.get('/file/:filename', (req, res) => {
  const filename = path.basename(req.params.filename); // Remove path
  const file = path.join(__dirname, 'uploads', filename);

  // Ensure file is within allowed directory
  if (!file.startsWith(path.join(__dirname, 'uploads'))) {
    return res.status(403).send('Forbidden');
  }

  res.sendFile(file);
});
```

### NoSQL Injection
```typescript
// Vulnerable
function findUser(username: string) {
  return db.users.findOne({ username }); // Can inject: {$ne: null}
}

// Fixed
function findUser(username: string) {
  if (typeof username !== 'string') {
    throw new ValidationError('Username must be a string');
  }
  return db.users.findOne({ username });
}
```

## Emergency Response

If a security vulnerability is discovered:
1. **Contain:** Disable affected feature if critical
2. **Assess:** Determine scope and impact
3. **Fix:** Apply patch immediately
4. **Test:** Verify fix doesn't break functionality
5. **Deploy:** Emergency deployment with monitoring
6. **Notify:** Inform stakeholders if data breach
7. **Postmortem:** Document incident and prevention

---

*Version 1.0.0 | OWASP Top 10 Compliant | GDPR Aware*
