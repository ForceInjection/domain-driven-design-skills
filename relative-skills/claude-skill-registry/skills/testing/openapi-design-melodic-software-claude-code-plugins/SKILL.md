---
name: openapi-design
description: Contract-first REST API design with OpenAPI 3.1 specification
allowed-tools: Read, Glob, Grep, Write, Edit, mcp__perplexity__search, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

# OpenAPI Design Skill

## When to Use This Skill

Use this skill when:

- **Openapi Design tasks** - Working on contract-first rest api design with openapi 3.1 specification
- **Planning or design** - Need guidance on Openapi Design approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Contract-first REST API design using OpenAPI 3.1 specification for consistent, well-documented APIs.

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

## OpenAPI 3.1 Structure

### Basic Template

```yaml
openapi: 3.1.0
info:
  title: Order Management API
  description: |
    API for managing customer orders in the e-commerce platform.

    ## Features
    - Create and manage orders
    - Track order status
    - Process payments
  version: 1.0.0
  contact:
    name: API Team
    email: api-support@example.com
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api.staging.example.com/v1
    description: Staging
  - url: http://localhost:5000/v1
    description: Development

tags:
  - name: Orders
    description: Order management operations
  - name: LineItems
    description: Order line item operations

paths:
  # Define endpoints here

components:
  schemas:
    # Define schemas here
  securitySchemes:
    # Define security here
  responses:
    # Define common responses
  parameters:
    # Define common parameters
```

### Paths Definition

```yaml
paths:
  /orders:
    get:
      operationId: listOrders
      summary: List orders
      description: Retrieve a paginated list of orders with optional filtering
      tags:
        - Orders
      security:
        - bearerAuth: []
      parameters:
        - $ref: '#/components/parameters/PageNumber'
        - $ref: '#/components/parameters/PageSize'
        - name: status
          in: query
          description: Filter by order status
          schema:
            $ref: '#/components/schemas/OrderStatus'
        - name: customerId
          in: query
          description: Filter by customer ID
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderListResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'

    post:
      operationId: createOrder
      summary: Create order
      description: Create a new order in draft status
      tags:
        - Orders
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateOrderRequest'
            examples:
              basic:
                summary: Basic order
                value:
                  customerId: "550e8400-e29b-41d4-a716-446655440000"
                  items:
                    - productId: "prod-123"
                      quantity: 2
      responses:
        '201':
          description: Order created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'
          headers:
            Location:
              description: URL of created order
              schema:
                type: string
                format: uri
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '422':
          $ref: '#/components/responses/ValidationError'

  /orders/{orderId}:
    parameters:
      - name: orderId
        in: path
        required: true
        description: Unique order identifier
        schema:
          type: string
          format: uuid

    get:
      operationId: getOrder
      summary: Get order by ID
      tags:
        - Orders
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'
        '404':
          $ref: '#/components/responses/NotFound'

    patch:
      operationId: updateOrder
      summary: Update order
      description: Partially update an order (only allowed for draft orders)
      tags:
        - Orders
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateOrderRequest'
      responses:
        '200':
          description: Order updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '409':
          $ref: '#/components/responses/Conflict'

    delete:
      operationId: deleteOrder
      summary: Delete order
      description: Delete a draft order (cannot delete submitted orders)
      tags:
        - Orders
      security:
        - bearerAuth: []
      responses:
        '204':
          description: Order deleted
        '404':
          $ref: '#/components/responses/NotFound'
        '409':
          $ref: '#/components/responses/Conflict'

  /orders/{orderId}/submit:
    post:
      operationId: submitOrder
      summary: Submit order
      description: Submit order for processing (transitions from Draft to Submitted)
      tags:
        - Orders
      security:
        - bearerAuth: []
      parameters:
        - name: orderId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Order submitted
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'
        '400':
          description: Order cannot be submitted
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProblemDetails'
        '404':
          $ref: '#/components/responses/NotFound'
```

### Components Definition

```yaml
components:
  schemas:
    # Enums
    OrderStatus:
      type: string
      enum:
        - draft
        - submitted
        - paid
        - shipped
        - delivered
        - cancelled
      description: Current status of the order

    # Value Objects
    Money:
      type: object
      required:
        - amount
        - currency
      properties:
        amount:
          type: number
          format: decimal
          minimum: 0
          example: 99.99
        currency:
          type: string
          pattern: '^[A-Z]{3}$'
          example: USD

    # Entities
    Order:
      type: object
      required:
        - id
        - customerId
        - status
        - createdAt
      properties:
        id:
          type: string
          format: uuid
          readOnly: true
        customerId:
          type: string
          format: uuid
        status:
          $ref: '#/components/schemas/OrderStatus'
        items:
          type: array
          items:
            $ref: '#/components/schemas/LineItem'
        subtotal:
          $ref: '#/components/schemas/Money'
        tax:
          $ref: '#/components/schemas/Money'
        total:
          $ref: '#/components/schemas/Money'
        createdAt:
          type: string
          format: date-time
          readOnly: true
        updatedAt:
          type: string
          format: date-time
          readOnly: true

    LineItem:
      type: object
      required:
        - productId
        - productName
        - quantity
        - unitPrice
      properties:
        id:
          type: string
          format: uuid
          readOnly: true
        productId:
          type: string
        productName:
          type: string
        quantity:
          type: integer
          minimum: 1
          maximum: 1000
        unitPrice:
          $ref: '#/components/schemas/Money'
        lineTotal:
          $ref: '#/components/schemas/Money'
          readOnly: true

    # Request/Response Wrappers
    CreateOrderRequest:
      type: object
      required:
        - customerId
      properties:
        customerId:
          type: string
          format: uuid
        items:
          type: array
          items:
            $ref: '#/components/schemas/CreateLineItemRequest'

    CreateLineItemRequest:
      type: object
      required:
        - productId
        - quantity
      properties:
        productId:
          type: string
        quantity:
          type: integer
          minimum: 1

    UpdateOrderRequest:
      type: object
      properties:
        customerId:
          type: string
          format: uuid

    OrderResponse:
      allOf:
        - $ref: '#/components/schemas/Order'
        - type: object
          properties:
            _links:
              $ref: '#/components/schemas/OrderLinks'

    OrderLinks:
      type: object
      properties:
        self:
          type: string
          format: uri
        submit:
          type: string
          format: uri
        cancel:
          type: string
          format: uri

    OrderListResponse:
      type: object
      required:
        - items
        - pagination
      properties:
        items:
          type: array
          items:
            $ref: '#/components/schemas/OrderResponse'
        pagination:
          $ref: '#/components/schemas/Pagination'

    Pagination:
      type: object
      required:
        - page
        - pageSize
        - totalItems
        - totalPages
      properties:
        page:
          type: integer
          minimum: 1
        pageSize:
          type: integer
          minimum: 1
          maximum: 100
        totalItems:
          type: integer
          minimum: 0
        totalPages:
          type: integer
          minimum: 0

    # Error Responses
    ProblemDetails:
      type: object
      required:
        - type
        - title
        - status
      properties:
        type:
          type: string
          format: uri
          description: URI reference identifying the problem type
        title:
          type: string
          description: Short, human-readable summary
        status:
          type: integer
          description: HTTP status code
        detail:
          type: string
          description: Human-readable explanation
        instance:
          type: string
          format: uri
          description: URI reference to specific occurrence
        errors:
          type: object
          additionalProperties:
            type: array
            items:
              type: string
          description: Validation errors by field

  parameters:
    PageNumber:
      name: page
      in: query
      description: Page number (1-based)
      schema:
        type: integer
        minimum: 1
        default: 1

    PageSize:
      name: pageSize
      in: query
      description: Number of items per page
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20

  responses:
    BadRequest:
      description: Invalid request
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetails'

    Unauthorized:
      description: Authentication required
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetails'

    Forbidden:
      description: Insufficient permissions
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetails'

    NotFound:
      description: Resource not found
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetails'

    Conflict:
      description: Resource conflict (e.g., state transition not allowed)
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetails'

    ValidationError:
      description: Validation failed
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetails'

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT token from authentication service

    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
      description: API key for service-to-service calls
```

## Design Best Practices

### Naming Conventions

```yaml
# Use camelCase for properties
customerId: string  # ✓ Good
customer_id: string # ✗ Avoid

# Use plural for collections
/orders          # ✓ Good
/order           # ✗ Avoid

# Use nouns for resources
/orders          # ✓ Good
/getOrders       # ✗ Avoid

# Use kebab-case for multi-word paths
/line-items      # ✓ Good
/lineItems       # ✗ Avoid
```

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Retrieve resource(s) | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Replace resource | Yes | No |
| PATCH | Partial update | No* | No |
| DELETE | Remove resource | Yes | No |

### Status Codes

| Code | Use For |
|------|---------|
| 200 | Successful GET, PUT, PATCH |
| 201 | Successful POST (resource created) |
| 204 | Successful DELETE (no content) |
| 400 | Malformed request syntax |
| 401 | Authentication required |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (state transition, duplicate) |
| 422 | Validation error |
| 500 | Server error |

### Versioning Strategies

```yaml
# URL Path (recommended for breaking changes)
servers:
  - url: https://api.example.com/v1

# Header-based
parameters:
  - name: API-Version
    in: header
    schema:
      type: string
      enum: ['2024-01-01', '2024-06-01']
```

## Validation

### JSON Schema Validation

```yaml
# Use constraints
quantity:
  type: integer
  minimum: 1
  maximum: 1000

email:
  type: string
  format: email
  maxLength: 255

productCode:
  type: string
  pattern: '^[A-Z]{3}-\d{6}$'

# Use enums for known values
status:
  type: string
  enum: [draft, submitted, paid]

# Use nullable for optional fields (OpenAPI 3.1)
middleName:
  type: ['string', 'null']
```

## Workflow

When designing OpenAPI contracts:

1. **Understand requirements**: What operations are needed?
2. **Design resources**: Identify entities and relationships
3. **Define schemas**: Create reusable component schemas
4. **Specify endpoints**: Define paths and operations
5. **Add security**: Configure authentication/authorization
6. **Document examples**: Add request/response examples
7. **Validate**: Use linting tools (Spectral, etc.)
8. **Review**: Get team feedback before implementation

## References

For detailed guidance:

- [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0) - Official OpenAPI specification
- [RFC 7231 - HTTP Semantics](https://datatracker.ietf.org/doc/html/rfc7231) - HTTP methods and status codes
- [RFC 7807 - Problem Details](https://datatracker.ietf.org/doc/html/rfc7807) - Standard error response format
- [Spectral](https://stoplight.io/open-source/spectral) - OpenAPI linting tool
- [OpenAPI Generator](https://openapi-generator.tech/) - Client/server code generation

---

**Last Updated:** 2025-12-26
