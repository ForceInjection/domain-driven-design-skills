---
name: pal-codereview
description: Systematic code review covering quality, security, performance, and architecture using PAL MCP. Use for pull request reviews, code audits, or pre-commit validation. Triggers on review requests, PR reviews, or code quality checks.
---

# PAL Code Review

Structured code review with expert validation across quality, security, performance, and architecture.

## When to Use

- Pull request reviews
- Pre-merge code audits
- Security-focused reviews
- Performance reviews
- Code quality assessments

## Quick Start

```python
# Start a code review
result = mcp__pal__codereview(
    step="Reviewing authentication changes for security and quality",
    step_number=1,
    total_steps=2,
    next_step_required=True,
    findings="Beginning comprehensive review",
    review_type="full",
    relevant_files=[
        "/app/auth/login.py",
        "/app/auth/tokens.py"
    ],
    confidence="exploring"
)
```

## Review Types

| Type | Focus |
|------|-------|
| `full` | Comprehensive: quality, security, performance, architecture |
| `security` | Security vulnerabilities and auth issues |
| `performance` | Bottlenecks and optimization |
| `quick` | Fast pass for obvious issues |

## Validation Types

| Type | Description |
|------|-------------|
| `external` | Uses expert model for validation (default) |
| `internal` | Local-only review, no external validation |

## Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `step` | string | Review narrative |
| `step_number` | int | Current step |
| `total_steps` | int | Total steps (usually 2 for external) |
| `next_step_required` | bool | More review needed? |
| `findings` | string | Review findings |

## Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `review_type` | enum | full/security/performance/quick |
| `review_validation_type` | enum | external/internal |
| `severity_filter` | enum | critical/high/medium/low/all |
| `focus_on` | string | Specific emphasis (e.g., "threading") |
| `standards` | string | Coding standards to enforce |
| `relevant_files` | list | Files under review |
| `issues_found` | list | Issues with severity |
| `continuation_id` | string | Continue session |

## Issue Severity Levels

```python
issues_found=[
    {"severity": "critical", "description": "SQL injection vulnerability"},
    {"severity": "high", "description": "Missing authentication check"},
    {"severity": "medium", "description": "Inefficient database query"},
    {"severity": "low", "description": "Inconsistent naming convention"}
]
```

## Example: Security Review

```python
mcp__pal__codereview(
    step="Security-focused review of payment processing code",
    step_number=1,
    total_steps=2,
    next_step_required=True,
    findings="Scanning for injection, auth bypass, data exposure",
    review_type="security",
    severity_filter="medium",  # Report medium and above
    relevant_files=[
        "/app/payments/processor.py",
        "/app/payments/validation.py"
    ],
    focus_on="input validation, PCI compliance",
    confidence="exploring"
)
```

## Review Checklist

### Quality
- [ ] Code readability and clarity
- [ ] Appropriate abstractions
- [ ] Error handling
- [ ] Test coverage

### Security
- [ ] Input validation
- [ ] Authentication/authorization
- [ ] Secrets management
- [ ] Injection prevention

### Performance
- [ ] Database query efficiency
- [ ] Caching strategy
- [ ] Algorithm complexity
- [ ] Resource cleanup

### Architecture
- [ ] Separation of concerns
- [ ] Dependency management
- [ ] API design
- [ ] Scalability considerations

## Best Practices

1. **Cover all aspects** - Quality, security, performance, architecture
2. **Prioritize findings** - Critical issues first
3. **Be constructive** - Suggest improvements, not just problems
4. **Reference code** - Use file paths and line numbers
5. **Consider context** - Time pressure, team experience
