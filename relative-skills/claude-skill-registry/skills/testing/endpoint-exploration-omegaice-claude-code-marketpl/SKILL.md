---
name: endpoint-exploration
description: Document REST API endpoints through systematic empirical testing. Analyzes URL structure, generates minimal test cases, executes requests, and produces concise API documentation. Use when exploring undocumented APIs, reverse-engineering endpoints, or creating integration documentation.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Endpoint Exploration

Create comprehensive API endpoint documentation through systematic empirical testing.

## Process

Copy this checklist and track your progress:

```
Endpoint Exploration Progress:
- [ ] Step 1: Analyze URL structure
- [ ] Step 2: Identify parameters and types
- [ ] Step 3: Generate minimal test cases
- [ ] Step 4: Execute tests and save samples
- [ ] Step 5: Analyze response patterns
- [ ] Step 6: Write documentation
- [ ] Step 7: Review for redundancy and clarity
```

### 1. URL Analysis

Parse the URL to identify path parameters (e.g., `{id}`, `{format}`) and endpoint structure.

**Do not** make assumptions about what the API does - focus only on the URL structure.

### 2. Parameter Identification

For each parameter identified:
- Determine likely type from URL structure
- List normal values (valid inputs)
- List invalid values (wrong types, edge cases)
- Note if parameter appears optional vs required

### 3. Test Case Generation

Create a minimal test set covering:
- **Valid cases**: 1-2 examples with real data
- **Format variations**: If format is a parameter, test each option
- **Edge cases**: Boundary values (0, 1, very large numbers, leading zeros)
- **Invalid cases**: Wrong types, negative values, unsupported formats
- **Header tests**: Accept header variations, conflicts
- **HTTP method tests**: POST, PUT, DELETE (if GET endpoint)
- **Query parameter tests**: Test if query params work

**Avoid redundancy**: If multiple values test the same behavior, pick one.

### 4. Sample Collection

Execute tests and save full HTTP responses (headers + body) to `samples/` directory:
- Use `curl -i` to capture headers
- Number files sequentially: `01-description.ext`, `02-description.ext`
- Use descriptive names indicating what each test validates

### 5. Response Analysis

For each unique response pattern, document:
- HTTP status code
- Content-Type header
- Response structure
- Any caching or rate-limit headers
- Error message formats

Identify:
- How to detect success vs failure
- How to distinguish different error types
- Any quirks (e.g., 200 for not-found, different error messages)

### 6. Documentation Writing

Create `endpoint-documentation.md` following the [template structure](./templates/endpoint-documentation.md) with these sections:

**Required sections:**
- Endpoint (HTTP method + full URL)
- Authentication (if any)
- Parameters (path, headers, query - if applicable)
- Response Codes (table format)
- Response Structure (tables preferred over examples)

**Include only if discovered:**
- Caching behavior
- Format selection rules
- Special detection logic (e.g., how to tell if resource exists)
- Important quirks or edge cases

**Avoid:**
- Speculation or assumptions
- Redundant information (each fact appears once)
- Examples that just repeat table/prose information
- Over-documentation of obvious behavior

### 7. Iterative Refinement

Review documentation against this checklist:
- [ ] **Redundancy**: Each fact appears exactly once
- [ ] **Evidence**: Only documented tested behavior
- [ ] **Clarity**: Concise, no unnecessary detail
- [ ] **Completeness**: All discoveries documented

Remove sections that don't add unique value.
