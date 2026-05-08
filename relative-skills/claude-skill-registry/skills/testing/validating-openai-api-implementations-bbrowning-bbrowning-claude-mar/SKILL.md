---
name: Validating OpenAI API Implementations
description: Use when reviewing OpenAI API usage, answering questions about OpenAI endpoints, or validating implementations against the official API specification. Provides expert knowledge on chat completions, embeddings, models, audio, assistants, batch processing, and moderations endpoints. Essential for code reviews involving OpenAI integrations and determining if features/parameters are part of the official API.
---

# OpenAI API Expert

This skill provides comprehensive knowledge of the official OpenAI API specification for validating implementations, answering API questions, and reviewing code that integrates with OpenAI services.

## When to Use This Skill

Invoke this skill when:
- Reviewing pull requests that use OpenAI APIs
- Answering questions about OpenAI API endpoints, parameters, or capabilities
- Validating whether a feature or parameter is part of the official OpenAI API
- Determining correct usage patterns for OpenAI integrations
- Checking authentication and request formatting
- Verifying API endpoint structures and response formats

## Official API Specification

**Authoritative Source**: https://app.stainless.com/api/spec/documented/openai/openapi.documented.yml

This OpenAPI specification is the single source of truth for all OpenAI API details. Always check the version number in the specification to ensure you're working with current information.

## Core API Structure

**Base URL**: `https://api.openai.com/v1`

**Authentication**: API Key-based (Bearer token) using the `ApiKeyAuth` security scheme

## Main Endpoint Categories

### 1. Chat Completions
- Core conversational AI capabilities
- Supports streaming responses
- Multiple model options
- Token counting and usage tracking

### 2. Embeddings
- Text embedding generation
- Vector representations for semantic search
- Multiple embedding models available

### 3. Models
- List and retrieve model information
- Model capabilities and specifications
- Model availability and access

### 4. Audio
- **Speech Generation**: Text-to-speech capabilities
- **Transcription**: Speech-to-text with advanced options
- **Translation**: Audio translation services
- Supports diarization and word-level timestamps
- Streaming capabilities

### 5. Assistants
- Create, modify, list, and delete AI assistants
- Persistent assistant configurations
- Custom behavior and capabilities

### 6. Batch Processing
- Create and manage batch API requests
- Asynchronous processing
- Cost-effective for large-scale operations

### 7. Moderations
- Content moderation capabilities
- Safety and policy compliance

## Key Validation Points

When reviewing OpenAI API implementations, verify:

1. **Endpoint Correctness**: All endpoints match the official specification paths
2. **Authentication**: Proper use of API key with Bearer token scheme
3. **Parameters**: Only official parameters are used; no undocumented features
4. **Model Names**: Valid model identifiers from the models endpoint
5. **Request Format**: Proper JSON structure and content types
6. **Response Handling**: Correct parsing of API responses
7. **Streaming**: Proper implementation when using streaming features
8. **Error Handling**: Appropriate handling of API error responses

## Common Implementation Patterns

### Authentication Header
```
Authorization: Bearer {API_KEY}
```

### Endpoint Structure
All endpoints follow the pattern: `https://api.openai.com/v1/{category}/{action}`

### Streaming Responses
Multiple endpoints support streaming for real-time data delivery

## Referencing the Specification

For detailed validation:
1. Fetch the specification from the official URL
2. Search for the specific endpoint or parameter in question
3. Verify exact schema requirements, data types, and constraints
4. Check for version-specific features or deprecations

## Searching the Specification Effectively

The OpenAPI YAML specification is the authoritative source. The most effective approach is to download it locally and search it directly.

### Recommended Approach: Download and Search Locally

**This is the MOST EFFECTIVE method for searching the OpenAI API spec:**

1. **Download the spec locally**:
   ```bash
   curl -o openai-spec.yml https://app.stainless.com/api/spec/documented/openai/openapi.documented.yml
   ```

2. **Use Grep to find all occurrences** of relevant terms:
   ```bash
   # Case-insensitive search with line numbers and context
   Grep pattern="MCP" path="openai-spec.yml" output_mode="content" -i=true
   ```

3. **Read specific sections** using line numbers from Grep results:
   ```bash
   Read file_path="openai-spec.yml" offset=42619 limit=100
   ```

4. **Iteratively refine searches** as needed without network overhead

**Why this works better:**
- ✅ No WebFetch limitations or timeouts
- ✅ Can search multiple times instantly (local file)
- ✅ Grep finds ALL occurrences, not just what WebFetch extracts
- ✅ Can examine exact line numbers and surrounding context
- ✅ No reliance on AI summarization of spec content
- ✅ Can verify findings by reading exact schema definitions

**When to use this approach:**
- Searching for specific schemas (e.g., MCPTool, ChatCompletion)
- Finding all references to a feature (e.g., all "authorization" occurrences)
- Examining exact field definitions and types
- Any detailed technical investigation of the API

### Alternative: WebFetch (Less Reliable)

If you cannot download the spec locally, WebFetch can be used but has limitations:

#### Specification Organization

The spec uses standard OpenAPI structure:
- **`components/schemas/`**: All type definitions (e.g., `MCPTool`, `ChatCompletion`)
- **`paths/`**: Endpoint definitions and operations
- **Request/response schemas**: Referenced via `$ref` to components

#### WebFetch Search Strategy

1. **Use precise technical terms** in prompts:
   - Schema names: "MCPTool schema definition", "ChatCompletion schema"
   - Exact field names: "authorization field", "server_url parameter"
   - Component paths: "components/schemas/MCPTool"

2. **Try multiple targeted prompts** on the SAME spec URL:
   - If first prompt fails, refine the search terms
   - Try variations: "find all schema definitions", "search for MCP"
   - Don't immediately jump to secondary sources

3. **Trust the authoritative source**:
   - The official spec has the answer
   - Secondary docs (cookbooks, blogs) may be outdated or incomplete
   - Web searches are useful for context, but verify against the spec

### What Doesn't Work

**Avoid these ineffective patterns:**
- ❌ Multiple WebFetch attempts when local download would work better
- ❌ Vague prompts: "search for OAuth token handling"
- ❌ Jumping to web searches when spec search doesn't work
- ❌ Relying on secondary documentation without spec verification
- ❌ Using general terms instead of schema/component names

**Use these effective patterns:**
- ✅ **Download spec locally and use Grep** (BEST approach)
- ✅ Specific prompts if using WebFetch: "find MCPTool schema definition with authorization field"
- ✅ Read exact line numbers from Grep results
- ✅ Verify findings against the authoritative spec

### Example: Finding MCPTool Schema

**Ineffective approach:**
1. Use WebFetch with vague prompt: "search for OAuth tokens and MCP"
2. When that fails, try different WebFetch prompts
3. When that fails, search web for "OpenAI MCP OAuth"
4. Find outdated blog posts with incomplete information

**Effective approach:**
1. Download spec: `curl -o openai-spec.yml https://app.stainless.com/api/spec/documented/openai/openapi.documented.yml`
2. Search for all MCP references: `Grep pattern="MCP" path="openai-spec.yml" output_mode="content" -i=true`
3. Identify relevant line numbers (e.g., line 42619 for MCPTool schema)
4. Read exact schema: `Read file_path="openai-spec.yml" offset=42619 limit=100`
5. Examine complete field definitions including `authorization`, `headers`, `server_url`, etc.

## Usage in Code Reviews

When reviewing OpenAI integration code:
1. Identify which endpoints are being used
2. Fetch the official spec to validate endpoint paths and parameters
3. Check that all parameters match the specification exactly
4. Verify authentication implementation
5. Confirm error handling covers API response codes
6. Validate that streaming is implemented correctly if used

## Critical Security Considerations

- **API Keys**: Must never be hardcoded or committed to version control
- **Bearer Token**: Always use HTTPS to protect authentication
- **Rate Limiting**: Implement appropriate retry logic with backoff
- **Error Responses**: Handle all error cases from the API

## Determining Feature Availability

To check if a feature exists in the OpenAI API:
1. Reference the official specification at the URL above
2. Search for the endpoint, parameter, or capability
3. If not found in the spec, it is NOT part of the official API
4. Check the API version to ensure feature availability

## Progressive Detail Reference

For comprehensive endpoint details, request/response schemas, and advanced features, always reference the official specification. This skill provides the knowledge framework; the specification provides the exact implementation details.

## Important Notes

- The specification is versioned - always check the current version in the spec file
- Features not in the official spec are not supported
- Use the specification URL as the authoritative reference for all validation
- When uncertain, fetch and search the specification directly
