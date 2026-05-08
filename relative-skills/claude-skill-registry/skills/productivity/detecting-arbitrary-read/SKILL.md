---
name: detecting-arbitrary-read
description: Detects arbitrary read vulnerabilities by identifying unchecked array indexing and out-of-bounds memory access. Use when analyzing array access patterns, pointer arithmetic, or investigating information disclosure vulnerabilities.
---

# Arbitrary Read Detection

## Detection Workflow

1. **Identify read operations**: Array accesses, pointer dereferences, format strings, struct member access
2. **Trace input sources**: Use `xrefs_to` to trace user-controlled data to read points
3. **Check bounds validation**: Verify array bounds, pointer arithmetic safety, format string validation
4. **Assess exploitability**: Can attacker control read address? What information can be disclosed?

## Key Patterns

- Unchecked array indexing with user-controlled indices
- Format string vulnerabilities with %s, %x
- Dereferencing user-controlled pointers
- Wrong struct member access via type confusion

## Output Format

Report with: id, type, severity, confidence, location (function, address, line), read operation, index source, bounds check status, exploitability, attack scenario, potential disclosure, mitigation.

## Severity Guidelines

- **CRITICAL**: Arbitrary read of sensitive data (keys, passwords)
- **HIGH**: Arbitrary read enabling ASLR bypass
- **MEDIUM**: Arbitrary read with limited disclosure
- **LOW**: Minor information disclosure

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and tool documentation