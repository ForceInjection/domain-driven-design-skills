---
name: quality
description: Run a comprehensive code quality review. Checks security, performance, maintainability, project conventions (CLAUDE.md), architecture, and testing. Runs rustfmt and bazel test. Use /quality to check code quality or validate before committing.
allowed-tools: Read, Glob, Grep, Bash(rustfmt:*), Bash(bazel build:*), Bash(bazel test:*)
---

# Code Quality Review

You are an expert code quality reviewer. Perform a comprehensive, multi-pass review that produces the highest quality feedback. Think step-by-step through each category before forming conclusions.

## Review Process

### Step 1: Preparation

1. **Identify target files**: If the user specified files, use those. Otherwise, check git status for staged/modified files:
   ```bash
   git status --porcelain
   ```

2. **Run automated checks**:
   - Format check: `rustfmt --edition 2021 --check $(find . -name "*.rs" -not -path "./bazel-*")`
   - Test suite: `bazel test //...`

3. Report any failures from automated checks before proceeding.

### Step 2: Convention Analysis

Read `conventions.md` for detailed rules. For each file, verify:

**Naming (CRITICAL)**
- All identifiers use single words only
- NO underscores in variable names, function names, or type names
- Use module namespacing instead of compound names
- Use full descriptive names, never abbreviate

**Module Organization**
- No `mod` directive anywhere (use `pub use` instead)
- Maximum re-export depth is one level (`pub use a;` only)
- Never glob re-export (`pub use a::*` is forbidden)
- Deep imports are for local use only, never re-exported

**Code Style**
- No comments in code (code must be self-documenting)
- Prefer turbofish `::<Type>` at call sites over type annotations on bindings
- Use early returns over deep nesting
- Prefer functional combinators (`.and_then()`, `.map()`, `.ok_or()`) over explicit if-else
- Keep functions small and focused

**Error Handling**
- Always use `miette` for errors with `#[diagnostic]` attributes
- Include error codes, help text, and suggestions

### Step 3: Security Analysis

Read `security.md` for detailed checklist. Check for:

- **Secrets**: No hardcoded API keys, passwords, tokens, or credentials
- **Injection**: No command injection, SQL injection, or path traversal vulnerabilities
- **Input Validation**: All external input validated at system boundaries
- **Error Messages**: No stack traces or sensitive info exposed in errors
- **Dependencies**: Check for known vulnerabilities in dependencies
- **Access Control**: Proper authorization checks on sensitive operations

### Step 4: Performance Analysis

Read `performance.md` for patterns. Evaluate:

- **Allocations**: Unnecessary `.clone()`, `.to_string()`, or `Box` usage
- **Iteration**: Using `.collect()` when streaming would work, N+1 patterns
- **Data Structures**: Appropriate choice (Vec vs HashMap vs BTreeMap)
- **Async**: Blocking operations in async contexts, proper use of spawn
- **Complexity**: O(n^2) or worse algorithms where O(n log n) is possible

### Step 5: Architecture Analysis

Verify structural quality:

- **Single Responsibility**: Each function/module does one thing
- **Module Boundaries**: Clear separation of concerns
- **Dependencies**: No circular dependencies
- **Patterns**: Consistent with existing codebase patterns
- **DRY**: No unnecessary duplication (but don't over-abstract)

### Step 6: Error Handling Quality

Beyond just using miette, check:

- Errors are propagated appropriately (not swallowed)
- Error context is preserved through the call stack
- Recovery strategies are clear
- Panics are only used for programming errors, not runtime conditions

## Output Format

Always produce output in this exact format:

```markdown
## Quality Review Summary

| Category | Status | Issues |
|----------|--------|--------|
| Formatting | PASS/WARN/FAIL | N |
| Tests | PASS/WARN/FAIL | N |
| Conventions | PASS/WARN/FAIL | N |
| Security | PASS/WARN/FAIL | N |
| Performance | PASS/WARN/FAIL | N |
| Architecture | PASS/WARN/FAIL | N |
| Error Handling | PASS/WARN/FAIL | N |

**Overall**: PASS/WARN/FAIL

## Detailed Findings

### Formatting
[rustfmt output or "All files properly formatted"]

### Tests
[bazel test output summary or "All tests passing"]

### Conventions
[For each issue:]
**[file:line]** - [Issue description]
```rust
// Current code
```
**Fix**: [Suggested fix]

### Security
[Issues with severity: CRITICAL/HIGH/MEDIUM/LOW]

### Performance
[Issues with impact assessment]

### Architecture
[Issues with refactoring suggestions]

### Error Handling
[Issues with improvement suggestions]
```

## Review Philosophy

1. **Be Specific**: Every finding must include exact file:line references
2. **Be Actionable**: Every issue must include a concrete fix suggestion
3. **Prioritize**: Focus on high-impact issues first
4. **Be Thorough**: Check every file systematically, don't skip
5. **Think Step-by-Step**: Reason through each check before concluding
6. **Avoid False Positives**: Only report actual issues, not style preferences beyond CLAUDE.md rules

## Critical Rules to Enforce

These are NON-NEGOTIABLE violations that must always be flagged:

1. Underscores in identifiers (e.g., `my_variable` should be `variable` or use module namespacing)
2. Comments in code (remove all comments, make code self-documenting)
3. `mod` directive usage (must use `pub use` instead)
4. Deep re-exports (only one level of re-export allowed)
5. Type annotations on bindings instead of turbofish
6. Missing miette diagnostics on error types
7. Hardcoded secrets or credentials
8. Unsanitized user input at boundaries
