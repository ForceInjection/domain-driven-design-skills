---
name: json-outputs-implementer
version: 0.2.1
description: >-
  Use PROACTIVELY when extracting structured data from text/images, classifying content, or formatting API responses with guaranteed schema compliance.
  Implements Anthropic's JSON outputs mode with Pydantic/Zod SDK integration.
  Covers schema design, validation, testing, and production optimization.
  Not for tool parameter validation or agentic workflows (use strict-tool-implementer instead).
---

# JSON Outputs Implementer

## Overview

This skill implements Anthropic's JSON outputs mode for guaranteed schema compliance. With `output_format`, Claude's responses are validated against your schema—ideal for data extraction, classification, and API formatting.

**What This Skill Provides:**
- Production-ready JSON schema design
- SDK integration (Pydantic for Python, Zod for TypeScript)
- Validation and error handling patterns
- Performance optimization strategies
- Complete implementation examples

**Prerequisites:**
- Decision made via `structured-outputs-advisor`
- Model: Claude Sonnet 4.5 or Opus 4.1
- Beta header: `structured-outputs-2025-11-13`

## When to Use This Skill

**Use for:**
- Extracting structured data from text/images
- Classification tasks with guaranteed categories
- Generating API-ready responses
- Formatting reports with fixed structure
- Database inserts requiring type safety

**NOT for:**
- Validating tool inputs → `strict-tool-implementer`
- Agentic workflows → `strict-tool-implementer`

## Response Style

- **Schema-first**: Design schema before implementation
- **SDK-friendly**: Leverage Pydantic/Zod when available
- **Production-ready**: Consider performance, caching, errors
- **Example-driven**: Provide complete working code
- **Limitation-aware**: Respect JSON Schema constraints

## Workflow

| Phase | Description | Details |
|-------|-------------|---------|
| 1 | Schema Design | → [workflow/phase-1-schema-design.md](workflow/phase-1-schema-design.md) |
| 2 | SDK Integration | → [workflow/phase-2-sdk-integration.md](workflow/phase-2-sdk-integration.md) |
| 3 | Error Handling | → [workflow/phase-3-error-handling.md](workflow/phase-3-error-handling.md) |
| 4 | Testing | → [workflow/phase-4-testing.md](workflow/phase-4-testing.md) |
| 5 | Production Optimization | → [workflow/phase-5-production.md](workflow/phase-5-production.md) |

## Quick Reference

### Python Template

```python
from pydantic import BaseModel
from anthropic import Anthropic

class MySchema(BaseModel):
    field: str

response = client.beta.messages.parse(
    model="claude-sonnet-4-5",
    betas=["structured-outputs-2025-11-13"],
    messages=[...],
    output_format=MySchema,
)
result = response.parsed_output  # Validated!
```

### Supported Schema Features

✅ Basic types, enums, format strings, nested objects/arrays, required fields

❌ Recursive schemas, min/max constraints, string length, complex regex

## Reference Materials

- [Common Use Cases](reference/use-cases.md)
- [Schema Limitations](reference/schema-limitations.md)

## Related Skills

- `structured-outputs-advisor` - Choose the right mode
- `strict-tool-implementer` - For tool validation use cases
