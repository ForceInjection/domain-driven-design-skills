---
name: hashing-passwords
description: CRITICAL security skill teaching proper credential and password handling. NEVER store passwords, use bcrypt/argon2, NEVER accept third-party credentials. Use when handling authentication, passwords, API keys, or any sensitive credentials.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, TodoWrite
version: 1.0.0
---

<role>
This skill prevents CRITICAL security failures found in stress testing where 33% of agents had severe security vulnerabilities including Base64 "encryption" for passwords and accepting PayPal passwords directly.

**THIS IS A ZERO-TOLERANCE SECURITY SKILL. NO EXCEPTIONS.**
</role>

<when-to-activate>
This skill activates when:

- Working with passwords or authentication
- Handling API keys, tokens, or credentials
- Storing sensitive user data
- Implementing login, signup, or password reset
- User mentions passwords, credentials, encryption, hashing, or authentication
- Code contains password storage, credential handling, or third-party auth
</when-to-activate>

<overview>
## Critical Security Rules

**RULE 1: NEVER STORE PASSWORDS**

Store password HASHES only, using bcrypt or argon2. Passwords must be:
- Hashed (NOT encrypted, NOT Base64, NOT plaintext)
- Salted automatically by bcrypt/argon2
- Using modern algorithms (bcrypt cost 12+, argon2id)

**RULE 2: NEVER ACCEPT THIRD-PARTY CREDENTIALS**

NEVER ask users for passwords to other services (PayPal, Google, etc.):
- Use OAuth instead
- Use API keys from the service
- Use service-provided SDKs

**RULE 3: NEVER USE ENCODING AS ENCRYPTION**

- Base64 is NOT encryption (trivially reversible)
- URL encoding is NOT security
- Hex encoding is NOT security

**RULE 4: USE PROPER CRYPTOGRAPHY**

- For passwords: bcrypt or argon2
- For encryption: Use established libraries (crypto module, Web Crypto API)
- For API keys: Store in environment variables, use secret management
</overview>

<critical-anti-patterns>
## NEVER DO THIS

**❌ Base64 "Encryption"**: `Buffer.from(password).toString("base64")` is encoding, NOT encryption. Trivially reversible.

**❌ Third-Party Passwords**: Never accept PayPal/Google/etc passwords. Use OAuth.

**❌ Plaintext Storage**: Never store raw passwords. Always hash.

**❌ Weak Hashing**: MD5/SHA-1/SHA-256 too fast. Use bcrypt/argon2.

See `references/never-do-this.md` for detailed examples and failures.
</critical-anti-patterns>

<correct-patterns>
## ✅ CORRECT: bcrypt Password Hashing

```typescript
import bcrypt from "bcrypt";

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return await bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(
  password: string,
  hash: string
): Promise<boolean> {
  return await bcrypt.compare(password, hash);
}

interface User {
  id: string;
  email: string;
  passwordHash: string;
}
```

**Key Points**:
- bcrypt designed for passwords
- Automatic salting
- Cost factor 12+ (prevents brute force)
- Never stores actual password

## ✅ CORRECT: argon2 (More Modern)

```typescript
import argon2 from "argon2";

async function hashPassword(password: string): Promise<string> {
  return await argon2.hash(password, {
    type: argon2.argon2id,
    memoryCost: 2 ** 16,
    timeCost: 3,
    parallelism: 1
  });
}
```

**Advantages**: Memory-hard, resists GPU attacks, latest standard.

## ✅ CORRECT: OAuth for Third-Party Services

```typescript
import { google } from "googleapis";

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  "http://localhost:3000/auth/callback"
);

function getAuthUrl(): string {
  return oauth2Client.generateAuthUrl({
    access_type: "offline",
    scope: ["https://www.googleapis.com/auth/userinfo.email"]
  });
}
```

**Key Points**: Token-based, never sees user password, revocable.

## ✅ CORRECT: Environment Variables for API Keys

```typescript
function loadConfig(): Config {
  const apiKey = process.env.STRIPE_API_KEY;
  if (!apiKey) {
    throw new Error("Missing required API key");
  }
  return { apiKey };
}
```

See `references/correct-implementations.md` for complete examples.
</correct-patterns>

<constraints>
**MUST:**

- Use bcrypt (cost 12+) or argon2id for password hashing
- Store password HASHES only, never passwords
- Use OAuth for third-party service authentication
- Store API keys in environment variables
- Validate password strength (min length, complexity)
- Use HTTPS for all authentication endpoints

**NEVER:**

- Store passwords in any form (plaintext, Base64, encrypted)
- Use MD5, SHA-1, or SHA-256 for passwords
- Accept third-party credentials (PayPal, Google, etc.)
- Hardcode API keys or secrets
- Use encoding (Base64, hex) as "encryption"
- Email passwords to users
- Log passwords (even in dev mode)

**SHOULD:**

- Implement password strength requirements
- Rate-limit login attempts
- Use two-factor authentication (2FA)
- Implement account lockout after failed attempts
- Rotate API keys periodically
- Use secret management services (AWS Secrets Manager, HashiCorp Vault)
</constraints>

<password-requirements>
## Minimum Requirements

- **Length**: 12+ characters (prefer 16+)
- **Complexity**: Uppercase, lowercase, numbers, special chars
- **Validation**: Reject common passwords ("password", "12345678")

See `references/password-validation.md` for complete implementation.
</password-requirements>

<installation>
## Installing Password Libraries

**bcrypt**:
```bash
npm install bcrypt
npm install -D @types/bcrypt
```

**argon2**:
```bash
npm install argon2
npm install -D @types/argon2
```

**Note**: Both require native compilation. Ensure build tools are available.
</installation>

<progressive-disclosure>
## Reference Files

**Detailed Examples**:
- `references/never-do-this.md` - Security failures and anti-patterns
- `references/correct-implementations.md` - Complete working examples
- `references/password-validation.md` - Password strength validation
- `references/emergency-response.md` - Breach response and migration

**Related Skills**:
- **Input Validation**: Use the sanitizing-user-inputs skill
- **Dependencies**: Use the auditing-dependencies skill
- **External Data**: Use the validating-external-data skill
</progressive-disclosure>

<validation>
## Security Implementation Checklist

1. **Password Storage**:
   - [ ] Uses bcrypt (cost 12+) or argon2id
   - [ ] NEVER stores actual passwords
   - [ ] Password hashes stored in separate column
   - [ ] No way to retrieve original password

2. **Third-Party Auth**:
   - [ ] Uses OAuth/OpenID Connect
   - [ ] NEVER asks for third-party passwords
   - [ ] Tokens stored securely
   - [ ] Follows service Terms of Service

3. **API Keys**:
   - [ ] Stored in environment variables
   - [ ] Not hardcoded in source
   - [ ] Not committed to git
   - [ ] `.env` file in `.gitignore`

4. **Password Requirements**:
   - [ ] Minimum 12 characters (prefer 16+)
   - [ ] Complexity requirements enforced
   - [ ] Common passwords rejected
   - [ ] Strength meter for users

5. **Additional Security**:
   - [ ] HTTPS required for auth endpoints
   - [ ] Rate limiting on login
   - [ ] Account lockout after failures
   - [ ] Password reset via email only
   - [ ] No password hints or security questions
</validation>

<common-mistakes>
## Why Developers Make These Mistakes

**"I need to retrieve the password later"**
→ You never need to retrieve passwords. Use password reset instead.

**"Base64 is encryption"**
→ Base64 is encoding for transport, not security.

**"I'll encrypt passwords"**
→ If you can decrypt, so can attackers. Hash, don't encrypt.

**"SHA-256 is secure"**
→ SHA-256 is too fast. Use bcrypt/argon2.

**"I need PayPal credentials to check balance"**
→ Use PayPal's API with OAuth tokens.
</common-mistakes>

<emergency-response>
## If You Find Insecure Password Storage

**IMMEDIATE ACTIONS**:

1. **Stop the application** (if running)
2. **Do NOT commit the code**
3. **Implement proper hashing** (bcrypt/argon2)
4. **Force password reset for all users**
5. **Notify security team**
6. **Assess breach scope**

See `references/emergency-response.md` for complete migration guide.
</emergency-response>
