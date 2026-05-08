---
name: prompt-templates
description: Reusable prompt templates for common tasks and optimization patterns
sasmp_version: "1.3.0"
bonded_agent: 05-prompt-optimization-agent
bond_type: PRIMARY_BOND
---

# Prompt Templates Skill

**Bonded to:** `prompt-optimization-agent`

---

## Quick Start

```bash
Skill("custom-plugin-prompt-engineering:prompt-templates")
```

---

## Parameter Schema

```yaml
parameters:
  template_category:
    type: enum
    values: [code, writing, analysis, extraction, generation]
    required: true

  customization_level:
    type: enum
    values: [minimal, standard, full]
    default: standard

  variables:
    type: object
    description: "Key-value pairs for template placeholders"
```

---

## Template Syntax

```yaml
syntax:
  variable: "{variable_name}"
  optional: "{?optional_variable}"
  conditional: "{#if condition}content{/if}"
  list: "{#each items}{.}{/each}"
  default: "{variable|default_value}"

example: |
  You are a {role|software engineer}.
  {#if context}Context: {context}{/if}
  Task: {task}
```

---

## Production Templates

### 1. Code Review Template

```markdown
# Code Review Template

You are a senior {language|software} engineer performing a code review.

## Review Focus
- Security vulnerabilities
- Performance issues
- Code quality and maintainability
- Best practice violations

## Code to Review
```{language}
{code}
```

## Output Format
For each issue found:
- **Location**: [file:line or function name]
- **Severity**: [critical/high/medium/low]
- **Category**: [security/performance/quality/style]
- **Issue**: [description]
- **Recommendation**: [how to fix]

{#if context}
## Additional Context
{context}
{/if}

Provide a summary at the end with:
- Total issues by severity
- Overall code quality score (1-10)
- Top 3 priorities to address
```

### 2. Technical Documentation Template

```markdown
# Documentation Generator Template

You are a technical writer creating documentation for {project_type}.

## Documentation Type
{doc_type|API reference}

## Source Material
{source}

## Output Format
Generate documentation following this structure:

### Overview
- Purpose and use cases
- Key concepts

### {#if is_api}API Reference
For each endpoint/function:
- Signature
- Parameters (name, type, description, required)
- Return value
- Example usage
- Error handling
{/if}

### Examples
- Basic usage
- Common patterns
- Edge cases

### Troubleshooting
- Common issues and solutions
```

### 3. Bug Analysis Template

```markdown
# Bug Analysis Template

You are a debugging expert analyzing a software issue.

## Bug Report
{bug_description}

## Error Information
{#if error_message}
Error: {error_message}
{/if}
{#if stack_trace}
Stack Trace:
```
{stack_trace}
```
{/if}

## Relevant Code
```{language}
{code}
```

## Analysis Output
Provide:
1. **Root Cause**: Most likely cause of the issue
2. **Impact**: What functionality is affected
3. **Fix**: Step-by-step solution
4. **Prevention**: How to prevent similar issues
5. **Test Cases**: Suggested tests to verify fix
```

### 4. Data Extraction Template

```markdown
# Data Extraction Template

You are a data extraction specialist.

## Task
Extract {data_type} from the following {source_type}.

## Source
{source}

## Extraction Schema
{schema}

## Rules
- Extract only explicitly stated information
- Use null for missing fields
- Maintain original formatting for text fields
- {#each additional_rules}{.}{/each}

## Output
Return valid JSON matching the schema above.
```

### 5. Content Generation Template

```markdown
# Content Generation Template

You are a {content_role|content writer} creating {content_type}.

## Target Audience
{audience}

## Tone and Style
- Tone: {tone|professional}
- Style: {style|clear and concise}
- Length: {length|medium}

## Topic
{topic}

## Requirements
{#each requirements}
- {.}
{/each}

## Additional Instructions
{#if instructions}{instructions}{/if}

## Output
Generate the {content_type} following all requirements above.
```

---

## Template Management

```yaml
template_lifecycle:
  creation:
    - Define variables and placeholders
    - Set defaults for optional params
    - Add validation rules
    - Document usage

  usage:
    - Load template
    - Validate variables
    - Substitute placeholders
    - Return final prompt

  maintenance:
    - Version templates
    - Track usage metrics
    - A/B test variants
    - Deprecate outdated
```

---

## Optimization Patterns

### Token Reduction

```yaml
optimization:
  remove_redundancy:
    before: "Please kindly ensure that you carefully..."
    after: "Ensure you..."

  use_lists:
    before: "Check for security issues. Also check for performance. And check for quality."
    after: |
      Check for:
      - Security issues
      - Performance
      - Quality

  template_variables:
    before: "You are a Python expert reviewing Python code for Python best practices"
    after: "You are a {language} expert reviewing code for best practices"
```

---

## Validation

```yaml
validation_checklist:
  structure:
    - [ ] All variables are documented
    - [ ] Defaults provided for optional vars
    - [ ] Clear output format specified

  quality:
    - [ ] Tested with real data
    - [ ] Edge cases handled
    - [ ] Error messages helpful

  maintenance:
    - [ ] Version tracked
    - [ ] Usage documented
    - [ ] Examples provided
```

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Missing variable | Undeclared placeholder | Check variable names |
| Wrong output | Template mismatch | Verify output format |
| Too verbose | Redundant text | Optimize template |
| Inconsistent | Multiple variants | Standardize templates |

---

## References

See `references/GUIDE.md` for template design patterns.
See `assets/config.yaml` for template configuration.
