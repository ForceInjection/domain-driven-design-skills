---
document_name: "api-documentation.skill.md"
location: ".claude/skills/api-documentation.skill.md"
codebook_id: "CB-SKILL-APIDOC-001"
version: "1.0.0"
date_created: "2026-01-04"
date_last_edited: "2026-01-04"
document_type: "skill"
purpose: "Procedures for API documentation"
skill_metadata:
  category: "documentation"
  complexity: "intermediate"
  estimated_time: "varies"
  prerequisites:
    - "API knowledge"
    - "HTTP fundamentals"
category: "skills"
status: "active"
tags:
  - "skill"
  - "documentation"
  - "api"
ai_parser_instructions: |
  This skill defines procedures for API documentation.
  Used by Doc Chef agent.
---

# API Documentation Skill

=== PURPOSE ===

Procedures for creating comprehensive API documentation.

=== USED BY ===

| Agent | Purpose |
|-------|---------|
| @agent(doc-chef) @ref(CB-AGENT-DOC-001) | Primary skill for API docs |

=== PROCEDURE: Endpoint Documentation ===

**Template:**
```markdown
## [HTTP Method] /path/to/endpoint

[Brief description of what this endpoint does]

### Authentication
[Required auth method]

### Parameters

#### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Resource identifier |

#### Query Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| limit | integer | No | 20 | Max results |
| offset | integer | No | 0 | Skip results |

#### Request Body
```json
{
  "field": "string",
  "nested": {
    "value": "string"
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| field | string | Yes | Description |
| nested.value | string | No | Description |

### Response

#### Success (200)
```json
{
  "success": true,
  "data": {
    "id": "abc123",
    "field": "value"
  }
}
```

#### Error Responses
| Status | Code | Description |
|--------|------|-------------|
| 400 | VALIDATION_ERROR | Invalid request |
| 401 | UNAUTHORIZED | Missing auth |
| 404 | NOT_FOUND | Resource not found |

### Example

```bash
curl -X POST https://api.example.com/v1/resource \
  -H "Authorization: Bearer token" \
  -H "Content-Type: application/json" \
  -d '{"field": "value"}'
```

### Notes
- [Any additional notes]
- [Rate limits, caching, etc.]
```

=== PROCEDURE: Overview Section ===

**API Overview Template:**
```markdown
# API Reference

## Base URL
```
https://api.example.com/v1
```

## Authentication
All requests require authentication via Bearer token:
```
Authorization: Bearer your-api-key
```

## Request Format
- Content-Type: application/json
- UTF-8 encoding

## Response Format
All responses follow this structure:
```json
{
  "success": true|false,
  "data": {},
  "error": {},
  "meta": {}
}
```

## Error Handling
| Status | Meaning |
|--------|---------|
| 400 | Bad request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not found |
| 429 | Rate limited |
| 500 | Server error |

## Rate Limits
- 100 requests per minute
- 10,000 requests per day

## Versioning
API version is in the URL path: `/v1/`, `/v2/`
```

=== PROCEDURE: Resource Documentation ===

**Resource Overview:**
```markdown
# Users

Users represent individual accounts in the system.

## The User Object

```json
{
  "id": "usr_abc123",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

## Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| id | string | Unique identifier |
| email | string | Email address |
| name | string | Display name |
| role | string | User role (user, admin) |
| created_at | datetime | Creation timestamp |
| updated_at | datetime | Last update timestamp |

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /users | List all users |
| POST | /users | Create a user |
| GET | /users/:id | Get a user |
| PATCH | /users/:id | Update a user |
| DELETE | /users/:id | Delete a user |
```

=== PROCEDURE: Code Examples ===

**Multiple Languages:**
```markdown
### Example: Create a User

#### cURL
```bash
curl -X POST https://api.example.com/v1/users \
  -H "Authorization: Bearer token" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "name": "John"}'
```

#### JavaScript
```javascript
const response = await fetch('https://api.example.com/v1/users', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer token',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ email: 'user@example.com', name: 'John' }),
});
```

#### Python
```python
import requests

response = requests.post(
    'https://api.example.com/v1/users',
    headers={'Authorization': 'Bearer token'},
    json={'email': 'user@example.com', 'name': 'John'},
)
```
```

=== PROCEDURE: Error Documentation ===

**Error Catalog:**
```markdown
# Error Reference

## Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": []
  }
}
```

## Error Codes

### Authentication Errors
| Code | Status | Description | Resolution |
|------|--------|-------------|------------|
| UNAUTHORIZED | 401 | Missing token | Include Authorization header |
| INVALID_TOKEN | 401 | Token invalid | Check token or refresh |
| TOKEN_EXPIRED | 401 | Token expired | Refresh token |

### Validation Errors
| Code | Status | Description | Resolution |
|------|--------|-------------|------------|
| VALIDATION_ERROR | 400 | Invalid input | Check error details |
| MISSING_FIELD | 400 | Required field | Include required field |
| INVALID_FORMAT | 400 | Wrong format | Check field format |
```

=== PROCEDURE: Changelog ===

**API Changelog:**
```markdown
# API Changelog

## v2.1.0 (2024-03-15)
### Added
- `GET /users/search` endpoint
- `metadata` field on User object

### Changed
- `limit` max increased to 100

### Deprecated
- `GET /users/find` (use `/users/search`)

## v2.0.0 (2024-01-01)
### Breaking Changes
- Response format changed to include `success` field
- Error format standardized
```

=== RELATED SKILLS ===

| Skill | Relationship |
|-------|--------------|
| @skill(technical-writing) | Writing fundamentals |
| @skill(api-development) | API design context |
