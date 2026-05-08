---
name: security/input-validation
description: Input Validation security skill
---

# Input Validation

All external data is hostile. Validate exhaustively at trust boundaries, reject by default.

## ikigai Application

**Trust boundaries in ikigai:**
- Terminal input (keystrokes, escape sequences)
- Config files (JSON, paths)
- LLM responses (streaming chunks)
- Environment variables

**Injection vectors:**
- Command injection: Never pass user strings to `system()` or `popen()`
- Path traversal: Reject `..`, canonicalize paths before use
- Format string: Never `printf(user_input)`, always `printf("%s", user_input)`
- Null byte: Truncates C strings, bypasses extension checks

**Validation principles:**
- Allowlist over blocklist
- Validate type, length, format, range
- Reject on first failure
- Sanitize for context (shell, SQL, HTML, ANSI)

**After validation:** Internal functions can `assert()` preconditions. The boundary function already validated.

**Review red flags:** User data in format strings, string concatenation for paths/commands, unchecked lengths.
