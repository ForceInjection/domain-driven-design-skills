---
name: httpyac
description: Work with httpyac .http files for HTTP, gRPC, GraphQL, and WebSocket API testing and contract validation. Use when creating or executing API test requests.
---

# httpyac API Testing

Work with httpyac .http files to test and validate HTTP, gRPC, GraphQL, and WebSocket APIs following established patterns and best practices.

## Quick Start

This Skill provides comprehensive rules for working with httpyac. Before any httpyac task:

1. Read [HTTPYAC-RULES.md](HTTPYAC-RULES.md) for all protocol-specific rules
2. STRICTLY follow these rules while creating or executing .http files
3. RESPECT rules by severity: Critical [C] > High [H] > Medium [M] > Low [L]
4. Understand proto file paths relative to .http file location for gRPC

## When to Use This Skill

- Creating new .http files for API testing
- Writing HTTP REST requests with authentication
- Creating gRPC requests (unary or streaming)
- Crafting GraphQL queries and mutations
- Building WebSocket test scenarios
- Validating API contracts against proto definitions
- Debugging API integration issues
- Executing API tests via CLI

## Rule Categories Overview

The [HTTPYAC-RULES.md](HTTPYAC-RULES.md) file contains detailed rules in these categories:

- **[P] Protocol Selection**: Choose appropriate protocol based on service definition
- **[H] HTTP Requests**: REST API patterns, headers, authentication, body formats
- **[G] gRPC Requests**: Proto imports, unary and streaming patterns, message formatting
- **[Q] GraphQL Requests**: Queries, mutations, fragments, variable passing
- **[W] WebSocket Requests**: Connections, streaming, bidirectional communication
- **[M] Meta Data and Variables**: Request naming, dependencies, variable scoping
- **[S] Scripting and Testing**: Pre/post-request scripts, assertions, async patterns
- **[E] Environment and Configuration**: CLI execution, proto path resolution, variables

## Rule Severity Levels

- **[C]ritical**: Must never be violated - will cause execution failure
- **[H]igh**: Should almost never be violated - core patterns
- **[M]edium**: Follow unless good reason not to - best practices
- **[L]ow**: Guidelines and preferences - style choices

## MCP Integration

This skill works best with:

**serena MCP** - for proto file discovery and navigation:
- `find_file`: Locate proto files and existing .http examples
- `read_file`: Read proto definitions to understand service contracts
- `search_for_pattern`: Find existing patterns across .http files
- `get_symbols_overview`: Understand proto service structure
- `find_symbol`: Locate specific service methods

**context7 MCP** - for up-to-date httpyac documentation:
- `resolve-library-id`: Get httpyac library ID
- `get-library-docs`: Fetch documentation for specific httpyac features

## Troubleshooting

**Proto file not found**:
- Verify proto path is relative from .http file to proto file
- Count directories from .http file location to proto location
- Ensure `includeDirs` points to proto root directory for nested imports
- Use serena MCP `find_file` to locate proto files

**gRPC connection failure**:
- Verify `{{HOST}}` variable is defined
- Check service and method names match proto exactly
- Ensure Authorization header if required
- Check gRPC status code in response (0 = success)

**Variable not defined**:
- Check if request has `@name` metadata for capture
- Verify `@ref` or `@forceRef` for dependent requests
- Check variable syntax: `{{variable}}` not `{variable}`
- Ensure referenced request executed before current request

**CLI execution error**:
- Use `-o=body` for output format and `-a` to execute all requests
- Example: `httpyac -o=body -a ./path/to/file.http`
- Check if .http file path is correct relative to current directory

## Example Workflow

When creating a new API test:

1. Locate the proto file: `find_file` with pattern
2. Read proto to understand service contract: `read_file`
3. Create .http file in desired location
4. Calculate proto path relative to .http file location
5. Add proto import with correct relative path and includeDirs
6. Write request with proper protocol syntax
7. Add variables and authentication
8. Execute from CLI: `httpyac -o=body -a ./path/to/file.http`
9. Add assertions in post-request script if needed
