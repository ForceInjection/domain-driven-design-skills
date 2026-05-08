---
name: detecting-format-string
description: Detects format string vulnerabilities by identifying unsafe printf family function calls with user-controlled format strings. Use when analyzing logging, error handling, or investigating memory disclosure via format strings.
---

# Format String Detection

## Detection Workflow

1. **Identify printf calls**: Find printf, fprintf, sprintf, snprintf, syslog functions
2. **Trace format string source**: Use `xrefs_to` to trace format string to user input
3. **Check format specifier**: Verify if format string is constant literal or user-controlled
4. **Assess exploitability**: Can attacker control format string? Can they read/write memory?

## Key Patterns

- `printf(user_string)` - user input as format string
- `fprintf(file, user_input)` - direct use of user input
- Memory read via %s, %x format specifiers
- Memory write via %n format specifier

## Output Format

Report with: id, type, severity, confidence, location, sink, source, format string, format specifier status, exploitability, attack vector, evidence, mitigation.

## Severity Guidelines

- **CRITICAL**: Format string with %n and user control
- **HIGH**: Format string with user control (read-only)
- **MEDIUM**: Format string with limited user control
- **LOW**: Format string with constant format string

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies