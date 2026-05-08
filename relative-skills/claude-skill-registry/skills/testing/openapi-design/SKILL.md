---
name: openapi-design
description: Contract-first REST API design with OpenAPI 3.1 specification
allowed-tools: Read, Glob, Grep, Write, Edit, mcp__perplexity__search, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

# OpenAPI Design Skill

## When to Use This Skill

Use this skill when:

- **Designing REST APIs** - OpenAPI 3.1 for contract-first API design
- **Defining API contracts** - Schemas, paths, parameters, responses
- **API best practices** - Naming conventions, status codes, versioning

## MANDATORY: Documentation-First Approach

Before creating OpenAPI specifications:

1. **Invoke `docs-management` skill** for API design patterns
2. **Verify OpenAPI 3.1 syntax** via MCP servers (context7 for latest spec)
3. **Base all guidance on OpenAPI 3.1 specification**

## Contract-First Approach

### Why Contract-First?

1. **Design before implementation**: Think through API before coding
2. **Parallel development**: Frontend and backend can work simultaneously
3. **Clear contract**: Unambiguous specification for all parties
4. **Auto-generation**: Generate clients, servers, documentation
5. **Validation**: Validate requests/responses against schema

### Workflow

```text
Requirements → OpenAPI Spec → Review → Generate → Implement → Test
     ↑                                                      ↓
     ←←←←←←←←←←←←← Iterate as needed ←←←←←←←←←←←←←←←←←←←←←←
```

## OpenAPI 3.1 Structure Overview

```yaml
openapi: 3.1.0
info:
  title: API Title
  version: 1.0.0
  description: API description

servers:
  - url: https://api.example.com/v1
    description: Production

tags:
  - name: Orders
    description: Order management

paths:
  # Define endpoints - see paths-definition.md

components:
  schemas: { }
  securitySchemes: { }
  responses: { }
  parameters: { }
```

**For complete template**: See [paths-definition.md](references/paths-definition.md)

## Quick Reference

### HTTP Methods

| Method | Purpose | Idempotent |
|--------|---------|------------|
| GET | Retrieve resource(s) | Yes |
| POST | Create resource | No |
| PUT | Replace resource | Yes |
| PATCH | Partial update | No |
| DELETE | Remove resource | Yes |

### Common Status Codes

| Code | Use For |
|------|---------|
| 200 | Successful GET, PUT, PATCH |
| 201 | Resource created (POST) |
| 204 | Successful DELETE |
| 400 | Malformed request |
| 401 | Authentication required |
| 404 | Resource not found |
| 422 | Validation error |

**For complete guidance**: See [design-best-practices.md](references/design-best-practices.md)

## Design Workflow

1. **Understand requirements**: What operations are needed?
2. **Design resources**: Identify entities and relationships
3. **Define schemas**: Create reusable component schemas
4. **Specify endpoints**: Define paths and operations
5. **Add security**: Configure authentication/authorization
6. **Document examples**: Add request/response examples
7. **Validate**: Use linting tools (Spectral, etc.)
8. **Review**: Get team feedback before implementation

## References

Load on-demand based on need:

| Reference | Load When |
|-----------|-----------|
| [paths-definition.md](references/paths-definition.md) | Defining REST endpoints, operations, parameters |
| [components-definition.md](references/components-definition.md) | Creating schemas, responses, security schemes |
| [design-best-practices.md](references/design-best-practices.md) | Reviewing naming, status codes, versioning |

## Related Skills (Cross-Plugin)

| Phase | Skill | Plugin | Purpose |
| ----- | ----- | ------ | ------- |
| DESIGN | `openapi-design` (this skill) | formal-specification | Architecture research, pattern selection |
| AUTHORING | `openapi-authoring` | spec-driven-development | Concrete YAML file creation |
| GOVERNANCE | `contract-first-design` | spec-driven-development | API governance, code generation |

**Workflow:** Design (research patterns) → Author (create YAML) → Govern (enforce contracts)

## External References

- [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0) - Official specification
- [RFC 7231 - HTTP Semantics](https://datatracker.ietf.org/doc/html/rfc7231) - HTTP methods and status codes
- [RFC 7807 - Problem Details](https://datatracker.ietf.org/doc/html/rfc7807) - Standard error response format
- [Spectral](https://stoplight.io/open-source/spectral) - OpenAPI linting tool

## MCP Research

For current OpenAPI patterns and tools:

```text
perplexity: "OpenAPI 3.1 specification" "REST API design patterns"
context7: "openapi" (for official documentation)
ref: "OpenAPI spec examples" "JSON Schema patterns"
```

## Version History

- **v2.0.0** (2026-01-17): Refactored to progressive disclosure pattern
  - Extracted 3 reference files (~500 lines)
  - Hub reduced from 698 to ~130 lines
- **v1.0.0** (2025-12-26): Initial release

---

**Last Updated:** 2026-01-17
