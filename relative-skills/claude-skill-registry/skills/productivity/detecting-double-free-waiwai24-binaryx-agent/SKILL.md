---
name: detecting-double-free
description: Detects double free vulnerabilities by identifying attempts to free the same memory block twice. Use when analyzing memory management, cleanup paths, or investigating heap corruption issues.
---

# Double Free Detection

## Detection Workflow

1. **Identify free operations**: Find all free() and delete/delete[] calls, note the pointers being freed
2. **Track pointer usage**: Use `xrefs_to` to trace pointers and identify pointer aliases
3. **Analyze control flow**: Map all code paths to free(), check for multiple free() calls on same pointer
4. **Assess exploitability**: Can attacker trigger double free? Is there useful heap corruption?

## Key Patterns

- Direct double free: free() called twice on same pointer
- Conditional double free: free() in multiple code paths
- Indirect double free: freeing same memory through different pointers
- Reference counting issues

## Output Format

Report with: id, type, subtype, severity, confidence, location, freed pointer, first free, second free, double free path, exploitability, attack scenario, impact, mitigation.

## Severity Guidelines

- **CRITICAL**: Double free with code execution potential
- **HIGH**: Double free causing heap corruption
- **MEDIUM**: Double free causing crashes
- **LOW**: Double free with limited impact

## See Also

- `patterns.md` - Detailed detection patterns and exploitation scenarios
- `examples.md` - Example analysis cases and code samples
- `references.md` - CWE references and mitigation strategies