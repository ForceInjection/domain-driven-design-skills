---
name: security-engineering
version: 1.0.0
description: Security auditing and vulnerability detection using OWASP patterns, CWE analysis, and threat modeling. Use when auditing code for security issues, reviewing authentication/authorization, evaluating input validation, analyzing cryptographic usage, reviewing dependency security, or when security-audit, vulnerability-scan, OWASP, threat-model, or --security are mentioned.
---

# Security Engineering

Threat-aware code review → vulnerability detection → risk-ranked remediation.

<when_to_use>

- Security audits and code reviews
- Authentication/authorization review
- Input validation and sanitization checks
- Cryptographic implementation review
- Dependency and supply chain security
- Threat modeling for new features
- Security incident investigation

NOT for: performance optimization, general code review without security focus, feature implementation

</when_to_use>

<phases>

Track with TodoWrite. Phases build comprehensive security assessment.

| Phase | Trigger | activeForm |
|-------|---------|------------|
| Threat Model | Session start, feature review | "Building threat model" |
| Attack Surface | Threat model complete | "Mapping attack surface" |
| Vulnerability Scan | Attack surface mapped | "Scanning for vulnerabilities" |
| Risk Assessment | Vulnerabilities identified | "Assessing risk levels" |
| Remediation Plan | Risks assessed | "Planning remediation" |

Workflow:
- Start: Create "Threat Model" as `in_progress`
- Transition: Mark current `completed`, add next `in_progress`
- Critical findings: Add urgent remediation task immediately
- Each phase feeds next — build comprehensive security picture

</phases>

<severity_levels>

Risk indicator with CVSS-aligned severity:

◆◆ **Critical** (9.0–10.0)
- Remote code execution
- Authentication bypass
- Mass data exposure
- Privilege escalation to admin

◆ **High** (7.0–8.9)
- SQL injection
- Stored XSS
- Authentication weaknesses
- Sensitive data leaks

◇ **Medium** (4.0–6.9)
- CSRF vulnerabilities
- Reflected XSS
- Information disclosure
- Weak cryptography

△ **Low** (0.1–3.9)
- Security misconfigurations
- Missing security headers
- Verbose error messages
- Minor information leaks

Use indicators in findings: "◆◆ Remote code execution via unsanitized shell command"

</severity_levels>

<threat_modeling>

## STRIDE Framework

**S**poofing — can attacker impersonate users/systems?
- Authentication mechanisms
- Token generation/validation
- Session management
- API key handling

**T**ampering — can attacker modify data?
- Input validation boundaries
- Data integrity checks
- Immutable audit logs
- Database access controls

**R**epudiation — can actions be denied?
- Logging and audit trails
- Transaction signatures
- Timestamp verification
- Non-repudiation controls

**I**nformation Disclosure — can attacker access sensitive data?
- Data classification
- Encryption at rest/transit
- Access control enforcement
- Logging sensitive data

**D**enial of Service — can attacker disrupt service?
- Rate limiting
- Resource exhaustion
- Timeout handling
- Input size validation

**E**levation of Privilege — can attacker gain unauthorized access?
- Authorization checks
- Role-based access control
- Principle of least privilege
- Permission validation

## Attack Trees

Map attack paths from goal to entry points:

```
Goal: Steal user credentials
├─ Attack login endpoint
│  ├─ SQL injection in username field
│  ├─ Brute force (no rate limiting)
│  └─ Session fixation
├─ Intercept network traffic
│  ├─ HTTPS downgrade
│  └─ Man-in-the-middle
└─ Social engineering
   ├─ Phishing (out of scope)
   └─ Password reset exploit
```

For each branch, assess:
- Feasibility — how easy to exploit?
- Impact — what damage if successful?
- Detection — will we notice attack?
- Mitigation — current defenses?

</threat_modeling>

<attack_surface>

## Entry Points Inventory

**External Interfaces**:
- HTTP/API endpoints (REST, GraphQL, gRPC)
- WebSocket connections
- File uploads
- OAuth/SAML flows
- Webhooks

**Data Inputs**:
- User-supplied data (forms, query params, headers)
- File uploads (type, size, content)
- API payloads (JSON, XML, protobuf)
- Database queries
- Third-party integrations

**Authentication Boundaries**:
- Public endpoints (no auth required)
- Authenticated endpoints
- Admin/privileged endpoints
- Service-to-service auth

**Trust Boundaries**:
- User browser → web server
- Web server → database
- Service → third-party API
- Internal services (microservices)

## Exposure Analysis

For each entry point document:
- Authentication required? (none/user/admin)
- Input validation? (none/basic/strict)
- Rate limiting? (yes/no)
- Logging? (yes/no)
- Encryption? (transit/rest/both/none)

Prioritize review:
1. Unauthenticated external inputs
2. Privileged operations
3. Data persistence layers
4. Third-party integrations

</attack_surface>

<vulnerability_patterns>

## Input Validation

**SQL Injection**:

```typescript
// VULNERABLE
const query = `SELECT * FROM users WHERE email = '${userEmail}'`;

// SECURE — parameterized queries
const query = 'SELECT * FROM users WHERE email = ?';
db.execute(query, [userEmail]);
```

**XSS (Cross-Site Scripting)**:

```typescript
// VULNERABLE — direct HTML insertion
element.innerHTML = userInput;

// SECURE — sanitized or use textContent
element.textContent = userInput;
// OR use DOMPurify for rich content
element.innerHTML = DOMPurify.sanitize(userInput);
```

**Command Injection**:

```typescript
// VULNERABLE
exec(`convert ${userFilename} output.png`);

// SECURE — parameterized or whitelist
execFile('convert', [userFilename, 'output.png']);
```

**Path Traversal**:

```typescript
// VULNERABLE
const filePath = `/uploads/${userFileName}`;

// SECURE — validate and normalize
const safeName = path.basename(userFileName);
const filePath = path.join('/uploads', safeName);
if (!filePath.startsWith('/uploads/')) {
  throw new Error('Invalid path');
}
```

**XML External Entity (XXE)**:

```typescript
// VULNERABLE
const parser = new DOMParser();
const doc = parser.parseFromString(xmlInput, 'text/xml');

// SECURE — disable external entities
const parser = new DOMParser({
  locator: {},
  errorHandler: {},
  // Disable DTD processing
  entityResolver: () => null,
});
```

## Authentication & Sessions

**Password Storage**:

```typescript
// VULNERABLE — plain text or weak hash
const hash = md5(password);

// SECURE — bcrypt/argon2 with salt
const hash = await bcrypt.hash(password, 12);
```

**Session Management**:

```typescript
// VULNERABLE — predictable session IDs
const sessionId = userId + Date.now();

// SECURE — cryptographically random
const sessionId = crypto.randomBytes(32).toString('hex');

// Add security attributes
res.cookie('session', sessionId, {
  httpOnly: true,
  secure: true, // HTTPS only
  sameSite: 'strict',
  maxAge: 3600000, // 1 hour
});
```

**JWT Handling**:

```typescript
// VULNERABLE — no signature verification
const payload = JSON.parse(atob(token.split('.')[1]));

// SECURE — verify signature
const payload = jwt.verify(token, SECRET_KEY, {
  algorithms: ['HS256'], // Specify allowed algorithms
  issuer: 'your-app',
  audience: 'your-api',
});
```

**Password Reset**:

```typescript
// VULNERABLE — predictable tokens
const resetToken = userId + '-' + Date.now();

// SECURE — cryptographically random with expiry
const resetToken = crypto.randomBytes(32).toString('hex');
await db.execute(
  'INSERT INTO reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
  [userId, await bcrypt.hash(resetToken, 10), Date.now() + 3600000]
);
```

## Authorization

**Broken Access Control**:

```typescript
// VULNERABLE — client-side only check
if (user.isAdmin) {
  // show admin panel
}

// SECURE — server-side enforcement
app.get('/admin/users', requireAdmin, (req, res) => {
  // Verify on every request
  if (!req.user?.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  // Admin operation
});
```

**Insecure Direct Object Reference (IDOR)**:

```typescript
// VULNERABLE — no ownership check
app.get('/api/documents/:id', async (req, res) => {
  const doc = await db.getDocument(req.params.id);
  res.json(doc);
});

// SECURE — verify ownership
app.get('/api/documents/:id', async (req, res) => {
  const doc = await db.getDocument(req.params.id);
  if (doc.userId !== req.user.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  res.json(doc);
});
```

**Privilege Escalation**:

```typescript
// VULNERABLE — role from client input
app.post('/api/users', async (req, res) => {
  const user = await createUser({
    ...req.body, // Includes role: 'admin' from malicious client
  });
});

// SECURE — explicit allowlist
app.post('/api/users', async (req, res) => {
  const allowedFields = ['name', 'email', 'password'];
  const userData = pick(req.body, allowedFields);
  const user = await createUser({
    ...userData,
    role: 'user', // Server controls role
  });
});
```

## Cryptography

**Weak Algorithms**:

```typescript
// VULNERABLE — deprecated algorithms
const hash = crypto.createHash('md5').update(data).digest('hex');
const cipher = crypto.createCipher('des', key);

// SECURE — modern algorithms
const hash = crypto.createHash('sha256').update(data).digest('hex');
const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
```

**Hardcoded Secrets**:

```typescript
// VULNERABLE
const API_KEY = 'sk-1234567890abcdef';
const DB_PASSWORD = 'admin123';

// SECURE — environment variables
const API_KEY = process.env.API_KEY;
const DB_PASSWORD = process.env.DB_PASSWORD;

if (!API_KEY || !DB_PASSWORD) {
  throw new Error('Missing required environment variables');
}
```

**Insufficient Randomness**:

```typescript
// VULNERABLE — predictable
const token = Math.random().toString(36);

// SECURE — cryptographically secure
const token = crypto.randomBytes(32).toString('hex');
```

## Data Exposure

**Sensitive Data in Logs**:

```typescript
// VULNERABLE
logger.info('User login', { email, password, ssn });

// SECURE — redact sensitive fields
logger.info('User login', {
  email,
  password: '[REDACTED]',
  ssn: '[REDACTED]',
});
```

**Error Message Disclosure**:

```typescript
// VULNERABLE — exposes internals
catch (err) {
  res.status(500).json({ error: err.stack });
}

// SECURE — generic message
catch (err) {
  logger.error('Internal error', err);
  res.status(500).json({ error: 'Internal server error' });
}
```

**Timing Attacks**:

```typescript
// VULNERABLE — early exit leaks info
if (user.password !== inputPassword) {
  return false;
}

// SECURE — constant-time comparison
return crypto.timingSafeEqual(
  Buffer.from(user.password),
  Buffer.from(inputPassword)
);
```

</vulnerability_patterns>

<owasp_top_10>

2021 OWASP Top 10 — primary vulnerability categories.

**A01:2021 – Broken Access Control**
- Missing function/resource level access control
- IDOR vulnerabilities
- CORS misconfigurations
- Force browsing to authenticated pages

CWE: 200, 201, 352, 359, 377, 402, 425, 639, 759, 639, 918, 1275

**A02:2021 – Cryptographic Failures**
- Sensitive data transmitted in clear text
- Old/weak cryptographic algorithms
- Missing encryption at rest
- Weak key generation/management

CWE: 259, 327, 331

**A03:2021 – Injection**
- SQL, NoSQL, OS command injection
- LDAP, XPath injection
- Expression language injection
- ORM injection

CWE: 20, 74, 75, 77, 78, 79, 80, 83, 89, 91, 93, 94, 95, 96, 97, 183, 184

**A04:2021 – Insecure Design**
- Missing security controls by design
- Ineffective security design patterns
- Lack of threat modeling
- Insecure reference architecture

CWE: 209, 256, 257, 266, 269, 280, 311, 312, 313, 316, 419, 430, 434, 444

**A05:2021 – Security Misconfiguration**
- Missing security hardening
- Unnecessary features enabled
- Default accounts/passwords
- Verbose error messages
- Missing security headers

CWE: 2, 11, 13, 15, 16, 260, 315, 520, 526, 537, 541, 547, 611, 614, 756, 776

**A06:2021 – Vulnerable & Outdated Components**
- Outdated dependencies with known CVEs
- Unsupported libraries
- No dependency scanning
- Missing security patches

CWE: 1035, 1104

**A07:2021 – Identification & Authentication Failures**
- Permits brute force attacks
- Weak password requirements
- Exposed session IDs in URLs
- Session fixation
- Missing MFA

CWE: 287, 288, 290, 294, 295, 297, 300, 302, 304, 306, 307, 346, 384, 521, 613, 640, 798, 940, 1216

**A08:2021 – Software & Data Integrity Failures**
- Unsigned/unverified CI/CD pipelines
- Insecure deserialization
- Missing integrity checks
- Auto-update without verification

CWE: 345, 353, 426, 494, 502, 565, 784, 829

**A09:2021 – Security Logging & Monitoring Failures**
- No audit trail for critical operations
- Insufficient log detail
- Logs not monitored
- Logs stored insecurely

CWE: 117, 223, 532, 778

**A10:2021 – Server-Side Request Forgery (SSRF)**
- Fetching remote resources without validation
- URL redirection to untrusted sites
- No network segmentation

CWE: 918

See [owasp-top-10.md](references/owasp-top-10.md) for detailed breakdowns.

</owasp_top_10>

<workflow>

Loop: Model Threats → Map Surface → Scan Vulnerabilities → Assess Risk → Plan Remediation

1. **Threat Model** — identify what could go wrong
   - STRIDE analysis for feature/component
   - Build attack trees for critical paths
   - Identify trust boundaries
   - Document threat actors (external/internal/privileged)

2. **Attack Surface** — map entry points
   - Inventory all inputs (API, files, user data)
   - Classify by authentication level
   - Identify data flows across trust boundaries
   - Prioritize high-risk entry points

3. **Vulnerability Scan** — systematic code review
   - Check each entry point against OWASP Top 10
   - Review authentication/authorization
   - Validate input handling
   - Check cryptographic usage
   - Scan dependencies for CVEs

4. **Risk Assessment** — severity and likelihood
   - Rate each vulnerability (◆◆/◆/◇/△)
   - Consider exploitability
   - Assess impact (confidentiality/integrity/availability)
   - Calculate risk score

5. **Remediation Plan** — prioritized fixes
   - Critical (◆◆) — immediate action required
   - High (◆) — fix before release
   - Medium (◇) — schedule in sprint
   - Low (△) — backlog or accept risk

Update todos as you progress through phases.

</workflow>

<security_review_checklist>

Before completing security review, verify:

**Authentication**:
- [ ] Passwords hashed with bcrypt/argon2 (cost ≥12)
- [ ] Session tokens cryptographically random
- [ ] Session cookies have httpOnly, secure, sameSite
- [ ] Password reset tokens random + expiring
- [ ] Rate limiting on login attempts
- [ ] MFA available for sensitive accounts

**Authorization**:
- [ ] All endpoints check authentication server-side
- [ ] Resource ownership verified before access
- [ ] Role checks on server, not client
- [ ] Principle of least privilege applied
- [ ] No IDOR vulnerabilities

**Input Validation**:
- [ ] All inputs validated (type, length, format)
- [ ] SQL queries use parameterized statements
- [ ] HTML output escaped or sanitized
- [ ] File uploads validated (type, size, content)
- [ ] Path traversal prevented in file operations
- [ ] Command injection prevented

**Cryptography**:
- [ ] No hardcoded secrets in code
- [ ] Strong algorithms (AES-256, SHA-256+)
- [ ] Cryptographically secure random generation
- [ ] HTTPS enforced (no HTTP)
- [ ] Certificate validation not disabled

**Data Protection**:
- [ ] Sensitive data encrypted at rest
- [ ] TLS 1.2+ for data in transit
- [ ] Sensitive data not logged
- [ ] Error messages don't leak internals
- [ ] PII handling complies with regulations

**Dependencies**:
- [ ] All dependencies up to date
- [ ] No known CVEs in dependencies
- [ ] Dependency scanning in CI/CD
- [ ] Package lock files committed
- [ ] Source verification for dependencies

**Logging & Monitoring**:
- [ ] Authentication events logged
- [ ] Authorization failures logged
- [ ] Sensitive operations audited
- [ ] Security events monitored
- [ ] Logs protected from tampering

</security_review_checklist>

<reporting>

## Security Findings Format

For each vulnerability found:

```markdown
## {SEVERITY_INDICATOR} {VULNERABILITY_NAME}

**Category**: {OWASP_CATEGORY}
**CWE**: {CWE_IDS}
**Severity**: {CRITICAL/HIGH/MEDIUM/LOW}

### Location
- File: {FILE_PATH}
- Lines: {LINE_RANGE}
- Function: {FUNCTION_NAME}

### Description
{CLEAR_EXPLANATION_OF_VULNERABILITY}

### Impact
{WHAT_ATTACKER_COULD_DO}

### Proof of Concept
{CODE_SNIPPET_OR_STEPS_TO_EXPLOIT}

### Remediation
{SPECIFIC_FIX_WITH_CODE_EXAMPLE}

### References
- OWASP: {URL}
- CWE: {URL}
```

## Summary Report Structure

```markdown
# Security Audit Report

**Date**: {DATE}
**Scope**: {COMPONENTS_REVIEWED}
**Reviewer**: {NAME}

## Executive Summary
{HIGH_LEVEL_OVERVIEW}

## Risk Summary
- Critical (◆◆): {COUNT}
- High (◆): {COUNT}
- Medium (◇): {COUNT}
- Low (△): {COUNT}

## Key Findings
{TOP_3_MOST_CRITICAL}

## Detailed Findings
{FULL_VULNERABILITY_LIST}

## Recommendations
{PRIORITIZED_REMEDIATION_PLAN}

## Conclusion
{OVERALL_SECURITY_POSTURE_ASSESSMENT}
```

</reporting>

<rules>

ALWAYS:
- Start with threat modeling before code review
- Map complete attack surface
- Check against all OWASP Top 10 categories
- Use severity indicators (◆◆/◆/◇/△) consistently
- Provide specific remediation with code examples
- Verify fixes don't introduce new vulnerabilities
- Document security assumptions
- Update todos when transitioning phases

NEVER:
- Skip threat modeling for "simple" features
- Assume input is trustworthy
- Rely on client-side security
- Use deprecated cryptographic algorithms
- Log sensitive data
- Disable security checks "temporarily"
- Recommend quick fixes without understanding context
- Mark complete without remediation plan

</rules>

<references>

Core methodology:
- [owasp-top-10.md](references/owasp-top-10.md) — detailed OWASP Top 10 breakdown with CWE mappings
- [FORMATTING.md](../../shared/rules/FORMATTING.md) — formatting conventions

Related skills:
- codebase-analysis — evidence-based investigation (foundation)
- debugging — systematic investigation when security issues manifest as bugs

</references>
