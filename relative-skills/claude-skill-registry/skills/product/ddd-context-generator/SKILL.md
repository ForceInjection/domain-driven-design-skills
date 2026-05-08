---
name: ddd-context-generator
description: Generate complete DDD bounded context with all 4 layers (Domain, Application, Infrastructure, Presentation). Use when user wants to create new business capability, scaffold complete context with CRUD, or build full feature from scratch (e.g., "Create Order context", "Generate Product context with inventory").
allowed-tools: Read, Write, Edit, Glob, Grep
---

# DDD Context Generator

Generate complete Domain-Driven Design bounded contexts with all 4 architectural layers (Domain, Application, Infrastructure, Presentation) for Bun.js + Express + routing-controllers backend applications.

## What This Skill Does

This skill generates production-ready code for a complete bounded context following DDD and Clean Architecture principles. It creates:

- **Domain Layer**: Entities, value objects, repository interfaces, domain events, and errors
- **Application Layer**: Use cases with dependency injection and event listeners
- **Infrastructure Layer**: Mongoose models, repository implementations, and mappers
- **Presentation Layer**: Request DTOs, response serializers, controllers with decorator-based routing and Swagger documentation

## When to Use This Skill

Use this skill when you need to:
- Create a new business capability from scratch
- Scaffold a complete context with CRUD operations
- Add a new bounded context to your DDD backend
- Generate a full feature with all architectural layers

Examples:
- "Create an Order context with CRUD operations"
- "Generate a Product context with inventory management"
- "Build a Payment context with transaction handling"

## How It Works

### Step 1: Requirements Gathering

The skill will ask you to clarify:
- Context name (e.g., "User", "Product", "Order")
- Required operations (CRUD, custom use cases)
- Business rules and invariants
- Required value objects
- Domain events needed

### Step 2: Code Generation

The skill generates code in this order:

1. **Directory Structure** - Shows complete file tree
2. **Domain Layer** - Pure business logic with zero dependencies
   - Value objects (immutable, validated)
   - Domain errors (with error codes)
   - Domain events (past tense naming)
   - Entities (factory methods, encapsulation)
   - Repository interfaces (domain contracts)
   - Barrel export (index.ts)

3. **Application Layer** - Use cases and orchestration
   - Use cases (@injectable, execute method)
   - Event listeners (handle domain events)
   - Barrel export (index.ts)

4. **Infrastructure Layer** - Persistence implementation
   - Mongoose models (with TypeScript interfaces)
   - Mappers (domain ↔ persistence conversion)
   - Repository implementations (@injectable)

5. **Presentation Layer** - HTTP API
   - Request DTOs (class-validator decorators)
   - Response serializers (@JSONSchema decorators)
   - Controllers (@injectable, decorator-based routing with @JsonController)

6. **Integration Code**
   - DI container registration
   - Event listener registration
   - Route registration

### Step 3: Verification

The skill provides a checklist to verify:
- All layers properly structured
- Dependency rules followed
- Proper decorators applied
- Integration code provided

## Architecture Requirements

This skill follows the patterns defined in the project's `CLAUDE.md`:

### Tech Stack
- Runtime: Bun.js
- Framework: Express + routing-controllers
- Database: MongoDB with Mongoose
- Validation: class-validator
- DI Container: tsyringe
- Documentation: routing-controllers-openapi + Swagger UI

### Dependency Rule
```
Presentation → Application → Domain
      ↓            ↓
  Infrastructure
```

- Domain has ZERO external dependencies
- Application depends only on Domain
- Infrastructure implements Domain interfaces
- Presentation depends on Application and Domain

### Key Patterns

**Entity Pattern:**
```typescript
export class EntityName {
  private constructor(...) {}

  static create(data): EntityName {
    // Validation and creation
  }

  static reconstitute(data): EntityName {
    // Load from database
  }

  // Getters and business methods
}
```

**Value Object Pattern:**
```typescript
export class ValueObject {
  private readonly value: string;

  private constructor(value: string) {
    this.value = value;
  }

  static create(value: string): ValueObject {
    // Validation
    return new ValueObject(value);
  }

  equals(other: ValueObject): boolean {
    return this.value === other.value;
  }
}
```

**UseCase Pattern:**
```typescript
@injectable()
export class ActionEntityUseCase {
  constructor(
    @inject('IEntityRepository')
    private readonly repo: IEntityRepository
  ) {}

  async execute(input: Input): Promise<Output> {
    // Business logic
    await eventBus.emit('EventName', event);
    return output;
  }
}
```

**API Pattern:**
```typescript
// Versioned routes with Swagger
new Elysia({ prefix: '/v1/entities' })
  .post('/', controller.create.bind(controller), {
    body: CreateSchema,
    detail: {
      summary: 'Create entity',
      tags: ['Entities'],
      responses: { 201: {}, 400: {}, 409: {} }
    }
  })
```

## Generated Structure

```
/src/contexts/{ContextName}/
├── domain/
│   ├── entities/
│   │   └── {entity}.entity.ts
│   ├── value-objects/
│   │   └── {vo}.vo.ts
│   ├── repositories/
│   │   └── {entity}.repository.interface.ts
│   ├── events/
│   │   └── {event}.event.ts
│   ├── errors/
│   │   └── {context}.errors.ts
│   └── index.ts
├── application/
│   ├── usecases/
│   │   ├── create-{entity}.usecase.ts
│   │   ├── find-{entity}.usecase.ts
│   │   ├── update-{entity}.usecase.ts
│   │   └── delete-{entity}.usecase.ts
│   ├── listeners/
│   │   └── {event}.listener.ts
│   └── index.ts
├── infrastructure/
│   ├── models/
│   │   └── {entity}.model.ts
│   ├── repositories/
│   │   └── {entity}.repository.ts
│   └── mappers/
│       └── {entity}.mapper.ts
└── presentation/
    ├── schemas/
    │   ├── create-{entity}.schema.ts
    │   ├── update-{entity}.schema.ts
    │   ├── query-{entity}.schema.ts
    │   └── {entity}-response.schema.ts
    ├── {context}.controller.ts
    └── {context}.routes.ts
```

## Code Quality Standards

All generated code follows:
- **Type Safety**: No `any` types, use `unknown` if needed
- **Naming**: PascalCase classes, camelCase methods, UPPER_SNAKE_CASE constants
- **Exports**: Named exports only (no default exports)
- **Decorators**: `@injectable()` on all DI classes
- **Error Handling**: Domain errors in domain, HTTP exceptions in presentation
- **Documentation**: Minimal code comments, comprehensive Swagger docs

## Integration Instructions

After generation, you need to:

1. **Register repository in DI container** (`/src/global/container/container.ts`):
```typescript
container.registerSingleton<IEntityRepository>(
  'IEntityRepository',
  EntityRepository
);
```

2. **Register routes** (`/src/main.ts`):
```typescript
import { registerEntityRoutes } from '@/contexts/entity/presentation/entity.routes';
app.use(registerEntityRoutes());
```

3. **Register event listeners** (`/src/main.ts`):
```typescript
import { EntityCreatedListener } from '@/contexts/entity/application';
const listener = container.resolve(EntityCreatedListener);
eventBus.on('EntityCreated', listener.handle.bind(listener));
```

## Before Using This Skill

Ensure you have:
1. Read the main `CLAUDE.md` architecture guide
2. Understanding of DDD and Clean Architecture principles
3. Familiarity with the tech stack (Bun.js, Elysia.js, MongoDB)

## Related Skills

- **ddd-entity-generator**: Generate individual domain entities
- **ddd-usecase-generator**: Generate application layer use cases
- **ddd-api-generator**: Generate presentation layer APIs
- **ddd-validator**: Validate DDD compliance after generation