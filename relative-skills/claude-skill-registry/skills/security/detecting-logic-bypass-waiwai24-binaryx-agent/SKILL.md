---
name: detecting-logic-bypass
description: Detects logic bypass vulnerabilities including authentication bypass, authorization bypass, and business logic flaws. Use when analyzing authentication mechanisms, access controls, or investigating security control bypasses.
---

# Logic Bypass Detection

## Detection Workflow

1. **Identify security controls**: Find authentication mechanisms, authorization checks, validation functions, business logic rules
2. **Trace control flow**: Use `xrefs_to` to trace paths, identify bypass opportunities, check for missing checks
3. **Check validation logic**: Review validation functions, test bypass scenarios, assess validation completeness
4. **Assess bypass impact**: What security control is bypassed? What's the business impact? How severe is the bypass?

## Key Patterns

- Authentication bypass: weak password checks, session token weaknesses, timing attacks
- Authorization bypass: missing permission checks, insecure direct object references, privilege escalation
- Input validation bypass: blacklist-based validation, insufficient sanitization, regex bypass
- Business logic bypass: race conditions, state manipulation, transaction abuse

## Output Format

Report with: id, type, subtype, severity, confidence, location, vulnerability, security control, bypass method, attack scenario, bypass steps, exploitability, impact, mitigation.

## Severity Guidelines

- **CRITICAL**: Complete bypass of primary security control
- **HIGH**: Bypass of important security control
- **MEDIUM**: Partial bypass or edge case bypass
- **LOW**: Limited bypass with minor impact

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies