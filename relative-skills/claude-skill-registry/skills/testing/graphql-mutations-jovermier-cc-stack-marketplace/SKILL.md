---
name: graphql-mutations
description: GraphQL mutation design including payload patterns, field-specific errors, input objects, and HTTP semantics. Use when designing or implementing GraphQL mutations.
---

# GraphQL Mutations

Expert guidance for designing effective GraphQL mutations.

## Quick Reference

| Pattern | Use When | Structure |
|---------|----------|-----------|
| Result payload | All mutations | `mutationName(input): MutationNamePayload!` |
| Field-specific errors | Validation failures | `errors: [FieldError!]!` in payload |
| Input objects | Complex arguments | `input: MutationNameInput!` |
| Noun + Verb naming | State changes | `createUser`, `deletePost`, `closeCard` |
| Idempotent mutations | Safe retries | Design for repeatable calls |
| Optimistic UI | Client-side updates | Return predicted result |

## What Do You Need?

1. **Payload design** - Return types, error handling
2. **Input objects** - Structuring mutation arguments
3. **Error patterns** - Field-specific vs top-level errors
4. **Naming** - Mutation naming conventions
5. **Side effects** - Handling async operations

Specify a number or describe your mutation scenario.

## Routing

| Response | Reference to Read |
|----------|-------------------|
| 1, "payload", "return", "response" | [payloads.md](./references/payloads.md) |
| 2, "input", "argument", "parameter" | [inputs.md](./references/inputs.md) |
| 3, "error", "validation", "field error" | [errors.md](./references/errors.md) |
| 4, "naming", "convention" | [naming.md](./references/naming.md) |
| 5, general mutations | Read relevant references |

## Critical Rules

- **Always return a payload**: Never just a boolean or the object
- **Use input objects for complex arguments**: Don't use many scalars
- **Field-specific errors in response**: Let clients handle per-field failures
- **Noun + verb naming**: createUser, deleteUser, not user
- **Mutations are POST-only**: Never use GET for mutations
- **Design for idempotency**: Safe to call multiple times

## Mutation Template

```graphql
# Input object for complex arguments
input CreateUserInput {
    name: String!
    email: String!
    password: String!
}

# Payload with result and errors
type CreateUserPayload {
    user: User
    errors: [UserError!]!
}

# Field-specific error type
type UserError {
    field: [String!]!  # Path to field: ["email"] or ["user", "emails", 0]
    message: String!
}

# Mutation definition
type Mutation {
    """
    Creates a new user account
    """
    createUser(input: CreateUserInput!): CreateUserPayload!
}
```

## Mutation Implementation

```go
// Good: Mutation with proper payload and field errors
func (r *mutationResolver) CreateUser(ctx context.Context, input CreateUserInput) (*CreateUserPayload, error) {
    // Validate
    var errs []UserError
    if input.Name == "" {
        errs = append(errs, UserError{
            Field:   []string{"name"},
            Message: "Name is required",
        })
    }
    if !isValidEmail(input.Email) {
        errs = append(errs, UserError{
            Field:   []string{"email"},
            Message: "Invalid email format",
        })
    }
    if len(errs) > 0 {
        return &CreateUserPayload{Errors: errs}, nil
    }

    // Create
    user, err := r.db.CreateUser(input)
    if err != nil {
        if errors.Is(err, db.ErrDuplicate) {
            return &CreateUserPayload{
                Errors: []UserError{{
                    Field:   []string{"email"},
                    Message: "Email already exists",
                }},
            }, nil
        }
        return nil, fmt.Errorf("failed to create user")
    }

    return &CreateUserPayload{User: user, Errors: []UserError{}}, nil
}
```

## Common Mutation Patterns

### Create
```graphql
type Mutation {
    createUser(input: CreateUserInput!): CreateUserPayload!
}

type CreateUserPayload {
    user: User
    errors: [UserError!]!
}
```

### Update
```graphql
type Mutation {
    updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
}

type UpdateUserPayload {
    user: User
    errors: [UserError!]!
}
```

### Delete
```graphql
type Mutation {
    deleteUser(id: ID!): DeleteUserPayload!
}

type DeleteUserPayload {
    deletedUserId: ID
    errors: [UserError!]!
}
```

### State Change (Noun + Verb)
```graphql
type Mutation {
    """
    Closes a card (marks as closed, not deleted)
    """
    closeCard(id: ID!): CloseCardPayload!
}

type CloseCardPayload {
    card: Card
    errors: [UserError!]!
}
```

## Error Handling Patterns

| Error Type | Response Pattern |
|------------|------------------|
| Validation errors | Return in payload errors field |
| Duplicate unique key | Return in payload errors field |
| Not found | Return in payload errors field |
| Permission denied | Return in payload errors field |
| Internal server error | Return nil, wrap error (don't expose) |

## HTTP Semantics

| Concern | Guidance |
|---------|----------|
| HTTP method | Always POST for mutations |
| Caching | Mutations are never cached |
| Idempotency | Design mutations to be safely repeatable |
| Side effects | Document non-obvious side effects |
| Async operations | Return payload with job ID, query for status |

## Common Mutation Mistakes

| Mistake | Severity | Fix |
|---------|----------|-----|
| Returning just boolean | Medium | Use payload with result |
| No field-specific errors | High | Add errors array to payload |
| Too many scalar arguments | Medium | Use input object |
| Verb + noun naming | Low | Use noun + verb (createUser) |
| Using GET for mutations | Critical | Always use POST |
| No validation errors in payload | High | Return validation failures |

## Reference Index

| File | Topics |
|------|--------|
| [payloads.md](./references/payloads.md) | Result types, error patterns, response structure |
| [inputs.md](./references/inputs.md) | Input objects, nested inputs, validation |
| [errors.md](./references/errors.md) | Field errors, error types, client handling |
| [naming.md](./references/naming.md) | Conventions, verb selection, consistency |

## Success Criteria

Mutations are well-designed when:
- All mutations return a payload type
- Field-specific errors returned in payload
- Input objects used for complex arguments
- Noun + verb naming (createUser, deletePost)
- POST only (never GET)
- Idempotent where possible
- Validation errors returned, not thrown
- No internal errors exposed to clients
