---
name: detect-hardcoded-secrets
description: Detect hardcoded secrets, API keys, passwords, and credentials in source code. Security audit for leaked secrets. Works across all languages. Use when user asks about security issues or secret detection.
allowed-tools: mcp__miller__fast_search, mcp__miller__get_symbols, Read, Grep
---

# Hardcoded Secrets Detection

## Activation Announcement

**IMPORTANT**: When this skill activates, ALWAYS start your response with:

```
🔐 **Security Scan: Hardcoded Secrets**
Scanning codebase for exposed credentials and API keys...
```

This provides a visual indicator to the user that a security scan is running.

## Why This Matters

Hardcoded secrets in source code:
- Get committed to git history (hard to remove)
- End up in logs, error messages, stack traces
- Get shared when code is shared
- Are a top cause of security breaches

## Detection Strategy

### Phase 1: High-Confidence Secret Patterns

Search for common secret variable names:

```
fast_search("password = api_key = secret =", method="text", limit=30)
fast_search("apiKey apiSecret accessToken", method="text", limit=30)
fast_search("connectionString credentials privateKey", method="text", limit=30)
fast_search("AWS_SECRET AZURE_KEY GITHUB_TOKEN", method="text", limit=30)
```

### Phase 2: Assignment Pattern Detection

Look for string literals assigned to sensitive variables:

```
# Direct assignments
Grep pattern: '(password|secret|api_key|token|credential)\s*[=:]\s*["\x27][^"\x27]+["\x27]'
Grep pattern: '(Password|Secret|ApiKey|Token)\s*=\s*"[^"]+"'

# Common formats
fast_search("Bearer sk- pk- ghp_ xox", method="text", limit=30)
fast_search("-----BEGIN PRIVATE KEY-----", method="text", limit=10)
fast_search("-----BEGIN RSA PRIVATE KEY", method="text", limit=10)
```

### Phase 3: Connection String Detection

```
fast_search("Server= User Id= Password=", method="text", limit=20)
fast_search("mongodb:// postgres:// mysql://", method="text", limit=20)
fast_search("redis:// amqp:// smtp://", method="text", limit=20)
fast_search("Data Source= Initial Catalog=", method="text", limit=20)
```

### Phase 4: Cloud Provider Patterns

```
# AWS
fast_search("AKIA aws_access_key aws_secret", method="text", limit=20)

# Azure
fast_search("DefaultEndpointsProtocol AccountKey", method="text", limit=20)

# GCP
fast_search("type service_account private_key_id", method="text", limit=20)

# Generic
fast_search("client_secret tenant_id subscription", method="text", limit=20)
```

### Phase 5: Verify Findings

For each suspicious result:

```
get_symbols(file_path="<file>", target="<function_or_class>", mode="full")
```

Determine if:
1. It's a real secret (not a placeholder like "YOUR_KEY_HERE")
2. It's in production code (not test fixtures)
3. It looks like an actual credential format

## Output Format

**IMPORTANT**: Always present findings in this structured format:

```
## Security Scan: Hardcoded Secrets

### ⚠️ WARNING
This scan found potential secrets. If any are real:
1. Rotate the credentials IMMEDIATELY
2. Use git-filter-branch or BFG to remove from history
3. Move secrets to environment variables or secret manager

### Summary
- Files scanned: X
- Potential secrets found: Y
- Severity: Critical: A, High: B, Medium: C

### Findings

#### 1. [CRITICAL] src/config/database.ts:23
**Type**: Database password
**Code**:
```typescript
const dbConfig = {
    password: "Pr0d_P@ssw0rd_2024!"  // ← EXPOSED
};
```
**Risk**: Database credentials exposed in source
**Action**: Move to environment variable `DB_PASSWORD`

#### 2. [CRITICAL] src/services/stripe.cs:15
**Type**: API Key (Live)
**Code**:
```csharp
private const string ApiKey = "sk_live_EXAMPLE_FAKE_KEY_12345";
```
**Risk**: Live payment API key - financial exposure!
**Action**: Use secret manager, rotate key immediately

#### 3. [HIGH] config/settings.py:42
**Type**: Connection string with credentials
**Code**:
```python
MONGO_URI = "mongodb://admin:secretpass@prod.example.com:27017"
```
**Risk**: Full database access embedded
**Action**: Split into components, use env vars

#### 4. [MEDIUM] tests/fixtures/auth.json:8
**Type**: Test credentials
**Code**:
```json
{ "api_key": "test_key_12345" }
```
**Risk**: Lower (test data) but sets bad pattern
**Action**: Use obviously fake values or env vars

### Files to Exclude (False Positives)
- `.env.example` - Template file with placeholders
- `docs/setup.md` - Documentation with fake examples

### Recommendations
1. **Immediate**: Rotate any real exposed credentials
2. **Short-term**: Move secrets to environment variables
3. **Long-term**: Implement secret manager (Vault, AWS Secrets Manager, etc.)
4. **Prevention**: Add pre-commit hooks to detect secrets
```

## Secret Patterns Reference

### High-Confidence Patterns (Likely Real)

| Pattern | Example | Type |
|---------|---------|------|
| `sk_live_` | `sk_live_abc123...` | Stripe Live Key |
| `AKIA` | `AKIAIOSFODNN7EXAMPLE` | AWS Access Key |
| `ghp_` | `ghp_xxxxxxxxxxxx` | GitHub PAT |
| `xox[baprs]-` | `xoxb-123-456-abc` | Slack Token |
| `-----BEGIN.*PRIVATE KEY` | PEM format | Private Key |
| Base64 40+ chars after `=` | `apiKey=aGVsbG8gd29ybGQ...` | Encoded Secret |

### Medium-Confidence (Check Context)

| Pattern | Could Be |
|---------|----------|
| `password =` | Real password OR config key name |
| `secret =` | Real secret OR variable naming |
| `token =` | Auth token OR CSRF token name |
| Connection strings | Real creds OR template |

### Low-Confidence (Often False Positive)

| Pattern | Usually |
|---------|---------|
| `YOUR_KEY_HERE` | Placeholder |
| `xxx` or `***` | Redacted |
| `example.com` | Documentation |
| Test file paths | Test fixtures |

## Files to Skip

These locations often have intentional fake secrets:
- `*.example` files
- `*.sample` files
- `docs/` directory
- `test/fixtures/`
- `.env.template`
- `README.md`

But still flag them if they look like real credentials!

## Success Criteria

This skill succeeds when:
- Clear security warning at start
- Comprehensive search across secret types
- Findings categorized by severity and type
- False positives identified and explained
- Clear remediation steps provided
- Urgency communicated for critical findings
