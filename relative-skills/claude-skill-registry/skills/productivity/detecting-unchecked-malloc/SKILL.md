---
name: detecting-unchecked-malloc
description: Detects unchecked return values of memory allocation functions like malloc, calloc, and realloc that can lead to null pointer dereferences. Use when analyzing memory allocation, error handling, or investigating null pointer risks.
---

# Unchecked Return Value of Malloc Detection

## Detection Workflow

1. **Identify allocation operations**: Find all malloc() calls, locate calloc() calls, identify realloc() calls, map new/delete operations
2. **Trace return values**: Follow allocation result, identify first dereference, check for NULL validation, assess error handling
3. **Check error handling**: Verify NULL checks exist, assess error handling completeness, review fallback behavior, check for graceful degradation
4. **Assess impact**: Can allocation fail? What happens on failure? Is crash possible? What's the security impact?

## Key Patterns

- Unchecked malloc: malloc() return value not checked, direct use of malloc() result, no NULL check before dereference, assumption malloc never fails
- Unchecked calloc: calloc() return value not checked, direct use of calloc() result, no NULL check before dereference, assumption calloc never fails
- Unchecked realloc: realloc() return value not checked, direct assignment to original pointer, no NULL check before dereference, losing original pointer on failure
- Unchecked new (C++): new return value not checked, assuming new never throws, no exception handling, missing std::nothrow usage

## Output Format

Report with: id, type, subtype, severity, confidence, location, vulnerability, allocation_call, allocation_type, allocation_size, null_check, first_dereference, exploitable, attack_scenario, impact, mitigation.

## Severity Guidelines

- **HIGH**: Unchecked allocation in critical code
- **MEDIUM**: Unchecked allocation causing crashes
- **LOW**: Unchecked allocation with limited impact

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies