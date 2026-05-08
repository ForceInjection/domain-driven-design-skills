---
name: submit-issue
description: Handle user questions, feature requests, and bug reports for connectrpc-axum. This skill should be used when users ask questions about the library, request new features, or report bugs. It first attempts to answer using project documentation, verifies bugs with integration tests, and submits GitHub issues when needed.
---

# Submit Issue

Handle user questions, feature requests, and bug reports for the connectrpc-axum project.

## Workflow

### 1. Understand the Request

Determine the request type:
- **Question**: User wants to understand how something works
- **Feature Request**: User wants new functionality
- **Bug Report**: User believes something is broken

### 2. For Questions - Answer First

Before suggesting an issue submission, attempt to answer using project documentation:

1. Read `references/README.md` for usage patterns and API
2. Read `references/architecture.md` for internal design
3. Reference the connect-go-reference skill for protocol details
4. Search the codebase for implementation specifics

If the question can be answered from documentation, provide the answer and ask if more clarification is needed.

### 3. For Bug Reports - Verify First

Before submitting a bug report:

1. **Reproduce the issue** - Ask user for reproduction steps if not provided
2. **Run integration tests** - Use the `/test` skill command
3. **Check connect-go behavior** - Use connect-go-reference skill to verify expected protocol behavior
4. **Document findings** - Note whether tests pass/fail and any discrepancies

Only proceed to issue submission if the bug is verified or plausible.

### 4. Submit to GitHub

When issue submission is appropriate, use the `gh` CLI:

```bash
# For bug reports
gh issue create \
  --repo "frankgreco/connectrpc-axum" \
  --title "Bug: <concise description>" \
  --body "$(cat <<'EOF'
## Description
<what's broken>

## Steps to Reproduce
1. <step>
2. <step>

## Expected Behavior
<what should happen>

## Actual Behavior
<what happens instead>

## Environment
- connectrpc-axum version: <version>
- Rust version: <version>

## Additional Context
<test results, connect-go comparison, etc.>
EOF
)"

# For feature requests
gh issue create \
  --repo "frankgreco/connectrpc-axum" \
  --title "Feature: <concise description>" \
  --body "$(cat <<'EOF'
## Description
<what you want>

## Use Case
<why you need it>

## Proposed Solution
<how it might work>

## Alternatives Considered
<other approaches>
EOF
)"
```

### 5. Label Issues Appropriately

Add labels based on issue type:
- `bug` - For verified bugs
- `enhancement` - For feature requests
- `question` - For questions that need discussion
- `documentation` - For docs improvements

```bash
gh issue edit <number> --add-label "bug"
```

## Reference Skills

- **connect-go-reference**: Use to verify protocol behavior against official Go implementation
- **test**: Use to run integration tests and verify bugs

## Documentation References

When answering questions, check these files in order:

1. `references/README.md` - Quick start, features, examples
2. `references/architecture.md` - Internal design and module structure
3. Codebase search for implementation details
