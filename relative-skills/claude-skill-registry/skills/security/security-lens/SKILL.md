---
name: security-lens
description: Apply security awareness during code review and implementation. Catches common vulnerabilities without requiring full security audit.
allowed-tools:
  - Read
  - Grep
  - Glob
---

# Security Awareness Lens

When reviewing or writing code, check for:

## Input Handling

- [ ] User input validated before use
- [ ] SQL uses parameterized queries (never string concat)
- [ ] HTML output escaped to prevent XSS
- [ ] File paths validated (no path traversal)

## Authentication/Authorization

- [ ] Auth checks at controller level, not just UI
- [ ] Sensitive operations re-verify permissions
- [ ] Session tokens are httpOnly, secure, sameSite

## Data Exposure

- [ ] Logs don't contain secrets, tokens, PII
- [ ] Error messages don't leak internal details
- [ ] API responses don't include unnecessary fields

## Secrets

- [ ] No hardcoded credentials
- [ ] Secrets from environment/vault, not config files
- [ ] .gitignore covers .env, credentials

See @owasp-quick-ref.md for detailed vulnerability patterns.
