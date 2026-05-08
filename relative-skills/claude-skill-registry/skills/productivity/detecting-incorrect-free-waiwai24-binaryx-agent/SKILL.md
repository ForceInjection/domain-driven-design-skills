---
name: detecting-incorrect-free
description: Detects incorrect use of free() including freeing non-heap memory, invalid pointers, and mismatched allocators. Use when analyzing memory deallocation, heap management, or investigating free() usage errors.
---

# Incorrect Use of Free Detection

## Detection Workflow

1. **Identify free operations**: Find all free() calls, locate delete/delete[] calls, map deallocation points, note pointers being freed
2. **Trace pointer origins**: Find where pointers originate, identify allocation method, track pointer assignments, assess pointer validity
3. **Analyze memory type**: Verify pointer points to heap memory, check for stack variables, identify static/global variables, assess pointer validity
4. **Assess impact**: Can incorrect free cause crash? Can it cause heap corruption? What's the security impact? Is it exploitable?

## Key Patterns

- Freeing non-heap memory: free() on stack variables, free() on static/global variables, free() on string literals, free() on automatic storage
- Freeing invalid pointers: free() on NULL pointer, free() on already-freed memory, free() on uninitialized pointers, free() on middle of allocations
- Mismatched allocators: free() on new-allocated memory, delete on malloc-allocated memory, cross-allocator deallocation, mixed C/C++ memory management
- Double free patterns: multiple free() on same pointer, free() in multiple code paths, free() in error handling, free() in cleanup functions

## Output Format

Report with: id, type, subtype, severity, confidence, location, vulnerability, freed_pointer, pointer_type, allocation_type, free_operation, exploitable, attack_scenario, impact, mitigation.

## Severity Guidelines

- **HIGH**: Incorrect free causing heap corruption
- **MEDIUM**: Incorrect free causing crashes
- **LOW**: Incorrect free with limited impact

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies