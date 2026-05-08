---
name: secrets-scanner
description: Scan codebase for secrets, API keys, credentials, and PII. Detect hardcoded sensitive data. Use when auditing for secrets, checking for exposed keys, reviewing security, or scanning for PII.
allowed-tools: Read, Grep, Glob
---

# Secrets Scanner

Detects hardcoded secrets and sensitive data in the codebase.

## When to Use

- "Scan for secrets"
- "Check for API keys"
- "Audit for credentials"
- "Find hardcoded passwords"
- "PII scan"

## What to Detect

### High Priority (Block Merge)

| Type            | Pattern                           | Example                 |
| --------------- | --------------------------------- | ----------------------- |
| API Keys        | `[a-zA-Z0-9_-]{32,}`              | OpenAI, Anthropic, etc. |
| AWS Credentials | `AKIA[A-Z0-9]{16}`                | `AKIAIOSFODNN7EXAMPLE`  |
| Private Keys    | `-----BEGIN.*PRIVATE KEY-----`    | RSA, SSH keys           |
| JWT Secrets     | `jwt.*=.*['"][a-zA-Z0-9+/=]{20,}` | Signing secrets         |
| Database URLs   | `postgres://.*:.*@`               | With password           |
| Bearer Tokens   | `Bearer [a-zA-Z0-9._-]+`          | Hardcoded tokens        |

### Medium Priority (Review)

| Type            | Pattern                |
| --------------- | ---------------------- |
| Generic secrets | `secret.*=.*['"]`      |
| Passwords       | `password.*=.*['"]`    |
| Tokens          | `token.*=.*['"]`       |
| API keys        | `api[_-]?key.*=.*['"]` |

### PII Patterns

| Type            | Pattern                                                    |
| --------------- | ---------------------------------------------------------- |
| Email addresses | `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`           |
| Phone numbers   | `\+?1?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}` |
| SSN             | `\d{3}-\d{2}-\d{4}`                                        |
| Credit cards    | `\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}`                   |

## Allowed Exceptions

These files are expected to have secret-like patterns:

- `.env.example` - Template placeholders only
- `*.test.ts` - Test fixtures
- Documentation files - Examples only

## Procedure

### Step 1: Scan for API Keys

```
Grep: (OPENAI_API_KEY|ANTHROPIC_API_KEY|sk-[a-zA-Z0-9]{32,})
Exclude: .env.example, *.md, node_modules
```

### Step 2: Scan for Credentials

```
Grep: (password|secret|credential|token)\s*[:=]\s*['"][^'"]+['"]
Exclude: .env.example, node_modules
```

### Step 3: Scan for Private Keys

```
Grep: -----BEGIN.*PRIVATE KEY-----
```

### Step 4: Scan for Database URLs

```
Grep: (postgres|mysql|mongodb)://[^:]+:[^@]+@
Exclude: .env.example, docker-compose.yml
```

### Step 5: Check .env Files

```
Glob: **/.env*
Read: Each file (except .env.example)
```

Ensure `.env` is in `.gitignore`.

### Step 6: Generate Report

```markdown
## Secrets Scan Report

### 🔴 Critical Findings

{List of actual secrets found with file:line}

### 🟡 Suspicious Patterns

{Patterns that look like secrets but may be false positives}

### ✅ Verified Safe

- .env.example contains only placeholders
- Test files use mock values
- .gitignore excludes .env files

### Recommendations

{Actions to take}
```

## False Positive Handling

Common false positives:

- Example values in docs: `sk-example-key-123`
- Test fixtures: `test-token-abc`
- Environment variable names: `OPENAI_API_KEY=`
- Base64 encoded data (non-secret)

Verify by checking:

1. Is it in a test/example file?
2. Does it match real credential format?
3. Is it actually used in production code?

## Guardrails

- DO NOT expose found secrets in output (truncate)
- DO NOT assume patterns are secrets without verification
- ALWAYS check .gitignore for .env exclusion
- Report findings privately (not in PR comments)
- Recommend credential rotation if secrets found in history
