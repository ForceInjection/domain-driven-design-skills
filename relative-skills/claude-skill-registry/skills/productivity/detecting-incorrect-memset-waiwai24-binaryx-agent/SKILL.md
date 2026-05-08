---
name: detecting-incorrect-memset
description: Detects incorrect use of memset() including wrong argument order, incorrect size calculations, and misunderstood behavior. Use when analyzing memory initialization, buffer clearing, or investigating memset() usage errors.
---

# Incorrect Use of Memset Detection

## Detection Workflow

1. **Identify memset operations**: Find all memset() calls, locate buffer clearing operations, identify memory initialization, map sensitive data handling
2. **Analyze argument order**: Verify memset argument order, check pointer/value/size order, assess argument correctness, review common mistakes
3. **Check size calculation**: Verify size parameter, check sizeof usage, assess size correctness, review buffer dimensions
4. **Assess security impact**: Does incorrect memset leave data? Is sensitive data exposed? Can compiler optimize away memset? What's the security impact?

## Key Patterns

- Wrong argument order: memset with wrong argument order, size and value arguments swapped, pointer and size arguments swapped, common memset mistakes
- Incorrect size calculation: sizeof on pointer instead of buffer, off-by-one errors in size, size calculation with overflow, wrong size for buffer type
- Misunderstood memset behavior: expecting memset to return filled value, assuming memset validates arguments, thinking memset checks for NULL, misunderstanding memset return value
- Ineffective clearing: memset on optimized-away variables, compiler removing memset calls, incomplete buffer clearing, missing memset on sensitive data

## Output Format

Report with: id, type, subtype, severity, confidence, location, vulnerability, memset_call, correct_order, arguments, actual_operation, expected_operation, exploitable, attack_scenario, impact, mitigation.

## Severity Guidelines

- **HIGH**: Incorrect memset leaving sensitive data
- **MEDIUM**: Incorrect memset causing memory corruption
- **LOW**: Minor memset errors

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies