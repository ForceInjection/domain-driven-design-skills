---
name: bruno-endpoint-creation
description: Comprehensive guide for creating REST API endpoints in Bruno. Use when working with Bruno collections, creating .bru files, configuring API endpoints, setting up authentication, writing pre/post-request scripts, organizing Bruno collections, or testing REST APIs with Bruno.
---

# Bruno REST API Endpoint Creation

Follow these patterns when creating Bruno REST API endpoints for professional API testing and documentation.

## Environment Configuration

**Development Environment (Local.bru):**
```
vars {
  baseUrl: http://localhost:3001
  linkId:
  apiKey: dev_api_key_change_in_production
}
```

**Production/Staging Environments:**
```
vars {
  baseUrl: https://api.yourdomain.com
  linkId: 
}
vars:secret [
  apiKey
]
```

**Key Principles:**
- Use plain text variables for development (easier debugging)
- Use `vars:secret` for sensitive data in production/staging
- Never hardcode sensitive values in production configs
- Use descriptive variable names that match your API's naming conventions

## RESTful Endpoint Structure

**Standard CRUD Operations Pattern:**
```
GET    /api/v1/resources          # List all resources
GET    /api/v1/resources/:id      # Get specific resource
POST   /api/v1/resources          # Create new resource
PATCH  /api/v1/resources/:id      # Update specific resource
PUT    /api/v1/resources/:id      # Replace specific resource
DELETE /api/v1/resources/:id      # Delete specific resource
```

## Authentication Configuration

**Collection-Level Authentication (Recommended):**

Set authentication once at the collection level in `collection.bru`:
```
auth {
  mode: bearer
}

auth:bearer {
  token: {{apiKey}}
}
```

Then inherit in all individual endpoints:
```
post {
  url: {{baseUrl}}/api/v1/resources
  body: json
  auth: inherit
}
```

**Individual Endpoint Authentication (When Needed):**

Only use when an endpoint needs different auth than the collection:
```
auth:bearer {
  token: {{apiKey}}
}

auth:basic {
  username: {{username}}
  password: {{password}}
}

headers {
  X-API-Key: {{apiKey}}
}
```

**Benefits of Collection-Level Auth:**
- DRY principle - define once, use everywhere
- Easier maintenance - change auth in one place
- Cleaner endpoint files - focus on request logic
- Consistent authentication across all endpoints

## Request Configuration

**Standard Request Structure:**
```
meta {
  name: "Create Resource"
  type: http
  seq: 1
}

post {
  url: {{baseUrl}}/api/v1/resources
  body: json
  auth: inherit
}

body:json {
  {
    "resource": {
      "field1": "value1",
      "field2": "value2"
    }
  }
}

params:path {
  id: {{resourceId}}
}

params:query {
  page: 1
  limit: 20
  sort: created_at
  order: desc
}
```

## Response Handling & Scripts

**Post-Response Scripts for Data Extraction:**

Use `bru.setVar()` to store values in runtime variables for use across requests in the same run:
```javascript
script:post-response {
  // After creating a resource, store its ID in runtime variable
  if (res.status === 201 && res.body && res.body.id) {
    bru.setVar("resourceId", res.body.id);
    bru.setVar("lastCreatedAt", res.body.created_at);
  }
  
  // After listing resources, extract the first ID for subsequent operations
  if (res.status === 200 && res.body && res.body.length > 0) {
    bru.setVar("resourceId", res.body[0].id);
  }
}
```

**Key Difference:**
- `bru.setEnvVar()` - Stores in environment variables (persists across requests, visible in Environment tab)
- `bru.setVar()` - Stores in runtime variables (temporary, available during current collection run)

**Best Practice:** Use `bru.setVar()` for runtime variables to avoid cluttering your environment variables with ephemeral values like extracted IDs from test runs.

**Pre-Request Scripts for Dynamic Data:**
```javascript
script:pre-request {
  // Generate dynamic test data
  const timestamp = Date.now();
  bru.setVar("uniqueEmail", `test-${timestamp}@example.com`);
  bru.setVar("randomId", Math.random().toString(36).substr(2, 9));
}
```

## Error Handling & Validation

**Expected Status Codes:**
- `200` - Success (GET, PATCH, PUT)
- `201` - Created (POST)
- `204` - No Content (DELETE)
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity
- `500` - Internal Server Error

**Response Validation Scripts:**
```javascript
script:post-response {
  // Validate response structure
  if (res.status === 200) {
    if (!res.body || typeof res.body !== 'object') {
      throw new Error('Expected JSON response body');
    }
    
    if (res.body.id && typeof res.body.id !== 'string') {
      throw new Error('Expected string ID in response');
    }
  }
}
```

## Documentation Standards

**Comprehensive Endpoint Documentation:**
```
docs {
  Create a new resource in the system.
  
  **Required Fields:**
  - field1: Description of required field
  - field2: Another required field description
  
  **Optional Fields:**
  - optional_field: Description of optional field
  
  **Validation Rules:**
  - field1 must be between 3-50 characters
  - field2 must be a valid email format
  
  **Response:**
  - 201 Created: Returns the created resource with ID
  - 422 Unprocessable Entity: Returns validation errors
  - 401 Unauthorized: Invalid or missing authentication
  
  **Example Usage:**
  This endpoint is typically called after user authentication
  to create new resources in the system.
}
```

## Collection Organization

**Recommended Folder Structure:**
```
Bruno Collection/
├── Environments/
│   ├── Local.bru
│   ├── Staging.bru
│   └── Production.bru
├── Authentication/
│   ├── Login.bru
│   └── Refresh Token.bru
├── Resources/
│   ├── List Resources.bru
│   ├── Get Resource.bru
│   ├── Create Resource.bru
│   ├── Update Resource.bru
│   └── Delete Resource.bru
└── Health/
    └── Health Check.bru
```

## Advanced Patterns

**Pagination Support:**
```
params:query {
  page: 1
  per_page: 20
  sort: created_at
  order: desc
}
```

**Filtering & Search:**
```
params:query {
  search: "search term"
  status: active
  created_after: "2024-01-01"
  tags: "tag1,tag2"
}
```

**Bulk Operations:**
```
body:json {
  {
    "resources": [
      {"field1": "value1"},
      {"field1": "value2"}
    ]
  }
}
```

## Testing Strategy

**Test Sequence:**
1. Health Check (no auth required)
2. Authentication (if applicable)
3. Create Resource
4. List Resources
5. Get Specific Resource
6. Update Resource
7. Delete Resource
8. Error Cases (invalid data, missing auth, etc.)

**Environment-Specific Testing:**
- Local: Full CRUD operations with test data
- Staging: Integration testing with real data
- Production: Read-only operations and health checks

## Security Considerations

**Never Include in Version Control:**
- API keys
- Passwords
- Personal data
- Production secrets

**Use Environment Variables:**
- Store sensitive data in Bruno's secret management
- Use different credentials per environment
- Rotate secrets regularly

## Performance Testing

**Load Testing Headers:**
```
headers {
  X-Load-Test: true
  X-Request-ID: {{requestId}}
}
```

**Timing Validation:**
```javascript
script:post-response {
  if (res.timings.duration > 5000) {
    console.warn('Request took longer than 5 seconds');
  }
}
```
