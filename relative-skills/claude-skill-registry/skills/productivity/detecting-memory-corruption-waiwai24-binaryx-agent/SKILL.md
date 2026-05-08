---
name: detecting-memory-corruption
description: Detects various memory corruption vulnerabilities beyond simple buffer overflows including heap overflow, stack smashing, and double free. Use when analyzing complex memory management, heap operations, or investigating memory safety issues.
---

# Memory Corruption Detection

## Detection Workflow

1. **Identify memory operations**: Find all malloc/free/realloc calls, stack buffer allocations, pointer arithmetic operations
2. **Trace memory usage**: Use `xrefs_to` to trace data, track pointer values through code, identify all access patterns
3. **Check bounds**: Verify size calculations, check array index validation, assess pointer arithmetic safety
4. **Assess impact**: Can corruption control execution? Is there information disclosure? Can corruption cause DoS?

## Key Patterns

- Heap overflow: malloc() followed by unchecked writes, off-by-one errors, integer overflow in size calculations
- Stack smashing: large stack buffer allocations, unchecked array access, variable-length arrays, return address overwrites
- Pointer arithmetic: pointer arithmetic without bounds checking, array indexing with user-controlled indices, out-of-bounds pointer access
- Memory leaks: missing free() after malloc(), reference cycles, exception paths skipping cleanup

## Output Format

Report with: id, type, subtype, severity, confidence, location, allocation (function, address, size), corruption (function, address, source), vulnerability, root cause, exploitable, attack scenario, mitigation.

## Severity Guidelines

- **CRITICAL**: Memory corruption allowing code execution
- **HIGH**: Memory corruption with data corruption or DoS
- **MEDIUM**: Memory leaks or minor corruption
- **LOW**: Potential issues with limited impact

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies