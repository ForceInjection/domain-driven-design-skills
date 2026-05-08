---
name: security-checklist
description: Security best practices, OWASP guidelines, and vulnerability prevention checklist. (project)
allowed-tools: Read, Grep, Glob, Bash
---

# Security Checklist

## OWASP Top 10 Prevention

### 1. Injection (SQL, NoSQL, Command)
```typescript
// BAD - SQL Injection vulnerable
const query = `SELECT * FROM users WHERE id = ${userId}`;

// GOOD - Parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
await db.query(query, [userId]);
```

### 2. Broken Authentication
- Use strong password hashing (bcrypt, argon2)
- Implement rate limiting on login
- Use secure session management
- Enforce MFA for sensitive operations

```typescript
// Password hashing
const hash = await bcrypt.hash(password, 12);
const isValid = await bcrypt.compare(password, hash);
```

### 3. Sensitive Data Exposure
- Encrypt data at rest and in transit
- Use HTTPS everywhere
- Don't log sensitive data
- Mask sensitive fields in responses

### 4. XML External Entities (XXE)
- Disable DTD processing
- Use JSON instead of XML when possible
- Validate and sanitize XML input

### 5. Broken Access Control
```typescript
// Always verify ownership
const resource = await Resource.findById(id);
if (resource.userId !== currentUser.id) {
  throw new ForbiddenError();
}
```

### 6. Security Misconfiguration
- Remove default credentials
- Disable directory listing
- Keep dependencies updated
- Use security headers

### 7. Cross-Site Scripting (XSS)
```typescript
// BAD - XSS vulnerable
element.innerHTML = userInput;

// GOOD - Escaped output
element.textContent = userInput;

// GOOD - Sanitized HTML
const clean = DOMPurify.sanitize(userInput);
```

### 8. Insecure Deserialization
- Don't deserialize untrusted data
- Use allowlists for class types
- Validate integrity of serialized data

### 9. Using Components with Known Vulnerabilities
- Run `npm audit` regularly
- Use Dependabot or Snyk
- Keep dependencies updated
- Remove unused dependencies

### 10. Insufficient Logging & Monitoring
- Log authentication events
- Log access control failures
- Set up alerts for anomalies
- Retain logs for forensics

## Security Headers

```typescript
// Express.js security headers
app.use(helmet());

// Or manually:
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000');
  res.setHeader('Content-Security-Policy', "default-src 'self'");
  next();
});
```

## Input Validation

```typescript
// Use validation libraries
import { z } from 'zod';

const UserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
  name: z.string().min(1).max(100),
});

const validated = UserSchema.parse(input);
```

## Environment Variables

```bash
# NEVER commit these
.env
.env.local
.env.production

# Use secrets management
# - AWS Secrets Manager
# - HashiCorp Vault
# - Azure Key Vault
```

## CORS Configuration

```typescript
// Restrictive CORS
app.use(cors({
  origin: ['https://myapp.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true,
}));
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per window
});

app.use('/api/', limiter);
```

## Secrets Scanning
- Pre-commit hooks with git-secrets
- CI/CD secret scanning
- Never hardcode API keys or passwords
