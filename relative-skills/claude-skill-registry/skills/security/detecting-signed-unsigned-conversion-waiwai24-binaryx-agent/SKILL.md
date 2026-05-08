---
name: detecting-signed-unsigned-conversion
description: Detects unsafe signed/unsigned integer conversions that can lead to integer overflow and security check bypasses. Use when analyzing integer operations, comparisons, or investigating conversion-related vulnerabilities.
---

# Signed/Unsigned Conversion Detection

## Detection Workflow

1. **Identify conversions**: Find all signed/unsigned conversions, locate implicit conversions, identify comparison operations, map arithmetic operations
2. **Analyze conversion safety**: Check for negative values, assess overflow potential, verify conversion correctness, review comparison logic
3. **Trace value flow**: Follow values through conversions, identify impact on operations, assess security implications, verify value constraints
4. **Assess exploitability**: Can attacker trigger negative value? Can conversion bypass security checks? What's the potential impact? Is it exploitable?

## Key Patterns

- Comparison errors: comparing signed with unsigned values, negative values treated as large positive, bypassed bounds checks, incorrect loop conditions
- Arithmetic errors: signed to unsigned conversion in arithmetic, integer overflow after conversion, underflow after conversion, unexpected results
- Function parameter issues: passing signed to unsigned parameters, implicit conversions in function calls, missing explicit casting, type mismatch in APIs
- Size calculation issues: signed values used for sizes, negative sizes after conversion, overflow in size calculations, incorrect buffer allocations

## Output Format

Report with: id, type, subtype, severity, confidence, location, vulnerability, comparison_operation, signed_variable, unsigned_variable, issue, exploitable, attack_scenario, impact, mitigation.

## Severity Guidelines

- **HIGH**: Conversion bypassing security checks
- **MEDIUM**: Conversion causing logic errors
- **LOW**: Minor conversion issues

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies