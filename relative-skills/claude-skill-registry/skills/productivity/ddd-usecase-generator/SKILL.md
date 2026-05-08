---
name: ddd-usecase-generator
description: Generate application layer use cases and event listeners with proper DI and orchestration. Use when adding business operations, creating workflows, or implementing event-driven logic (e.g., "Create RegisterUser use case", "Generate PlaceOrder with inventory check").
allowed-tools: Read, Write, Edit, Glob, Grep
---

# DDD UseCase Generator

Generate application layer use cases and event listeners with proper dependency injection, domain event emission, and orchestration logic.

## What This Skill Does

Creates application layer components that orchestrate domain logic:

- **Use Cases**: Single-responsibility classes with `execute()` method
- **Event Listeners**: Handlers for domain events
- **Proper DI**: tsyringe decorators and injection patterns
- **Event Emission**: Domain event publishing after operations
- **Error Handling**: Domain error propagation

## When to Use This Skill

Use when you need to:
- Add new business operations to existing context
- Create complex workflows orchestrating multiple entities
- Implement event-driven logic
- Add CRUD operations for entities

Examples:
- "Create a RegisterUser use case with email verification"
- "Generate a PlaceOrder use case with inventory check"
- "Add a ProcessPayment use case with transaction handling"

## UseCase Pattern

```typescript
import { inject, injectable } from 'tsyringe';
import type { IEntityRepository } from '@/contexts/context/domain';
import { EntityNotFoundError } from '@/contexts/context/domain';
import { eventBus } from '@/global/events/event-bus';
import { EntityCreated } from '@/contexts/context/domain';

export interface ExecuteInput {
  field1: string;
  field2: number;
}

export interface ExecuteOutput {
  id: string;
  field1: string;
  field2: number;
}

@injectable()
export class ActionEntityUseCase {
  constructor(
    @inject('IEntityRepository')
    private readonly entityRepo: IEntityRepository,

    @inject(OtherUseCase)
    private readonly otherUseCase: OtherUseCase
  ) {}

  async execute(input: ExecuteInput): Promise<ExecuteOutput> {
    this.validateInput(input);

    const entity = await this.entityRepo.findById(input.id);
    if (!entity) {
      throw new EntityNotFoundError(input.id);
    }

    entity.performBusinessLogic(input.field1);

    await this.entityRepo.save(entity);

    await eventBus.emit('EntityCreated', new EntityCreated(
      entity.getId(),
      entity.getField1()
    ));

    return this.toOutput(entity);
  }

  private validateInput(input: ExecuteInput): void {
    if (!input.field1) {
      throw new InvalidDataError('Field1 required');
    }
  }

  private toOutput(entity: Entity): ExecuteOutput {
    return {
      id: entity.getId(),
      field1: entity.getField1(),
      field2: entity.getField2(),
    };
  }
}
```

## Event Listener Pattern

```typescript
import { inject, injectable } from 'tsyringe';
import type { EntityCreated } from '@/contexts/context/domain';
import type { IRelatedRepository } from '@/contexts/related/domain';

@injectable()
export class EntityCreatedListener {
  constructor(
    @inject('IRelatedRepository')
    private readonly relatedRepo: IRelatedRepository
  ) {}

  async handle(event: EntityCreated): Promise<void> {
    try {
      await this.performAction(event);
    } catch (error) {
      console.error('Error handling EntityCreated:', error);
    }
  }

  private async performAction(event: EntityCreated): Promise<void> {
    // Listener logic
  }
}
```

## Dependency Injection Rules

**Repositories**: Inject by string token
```typescript
constructor(
  @inject('IUserRepository')
  private readonly userRepo: IUserRepository
) {}
```

**Use Cases**: Inject by class
```typescript
constructor(
  @inject(OtherUseCase)
  private readonly otherUseCase: OtherUseCase
) {}
```

**Services**: Inject by token or class depending on type

## Common Use Case Types

### Create Use Case
```typescript
@injectable()
export class CreateEntityUseCase {
  constructor(
    @inject('IEntityRepository')
    private readonly repo: IEntityRepository
  ) {}

  async execute(input: CreateInput): Promise<CreateOutput> {
    this.validateInput(input);

    const entity = Entity.create({
      field1: input.field1,
      field2: input.field2,
    });

    await this.repo.save(entity);

    await eventBus.emit('EntityCreated', new EntityCreated(
      entity.getId()
    ));

    return this.toOutput(entity);
  }
}
```

### Find Use Case
```typescript
@injectable()
export class FindEntityUseCase {
  constructor(
    @inject('IEntityRepository')
    private readonly repo: IEntityRepository
  ) {}

  async execute(id: string): Promise<FindOutput> {
    const entity = await this.repo.findById(id);

    if (!entity) {
      throw new EntityNotFoundError(id);
    }

    return this.toOutput(entity);
  }
}
```

### Update Use Case
```typescript
@injectable()
export class UpdateEntityUseCase {
  constructor(
    @inject('IEntityRepository')
    private readonly repo: IEntityRepository
  ) {}

  async execute(input: UpdateInput): Promise<UpdateOutput> {
    const entity = await this.repo.findById(input.id);
    if (!entity) {
      throw new EntityNotFoundError(input.id);
    }

    entity.updateField(input.field);

    await this.repo.save(entity);

    await eventBus.emit('EntityUpdated', new EntityUpdated(
      entity.getId()
    ));

    return this.toOutput(entity);
  }
}
```

### Delete Use Case
```typescript
@injectable()
export class DeleteEntityUseCase {
  constructor(
    @inject('IEntityRepository')
    private readonly repo: IEntityRepository
  ) {}

  async execute(id: string): Promise<void> {
    const exists = await this.repo.exists(id);
    if (!exists) {
      throw new EntityNotFoundError(id);
    }

    await this.repo.delete(id);

    await eventBus.emit('EntityDeleted', new EntityDeleted(id));
  }
}
```

## Critical Rules

**MUST DO:**
- Add `@injectable()` decorator
- Inject repositories with string tokens
- Inject use cases by class
- Single public `execute()` method
- Define input/output interfaces
- Validate input
- Emit domain events after success
- Throw domain errors (not HTTP exceptions)
- Return plain objects (not entities)

**MUST NOT:**
- Forget `@injectable()` decorator
- Mix injection patterns (token vs class)
- Include HTTP concerns (status codes)
- Put business logic in use case (belongs in entity)
- Return domain entities directly
- Skip input validation
- Throw HTTP exceptions

## Generated Files

```
/src/contexts/{Context}/application/
├── usecases/
│   ├── create-{entity}.usecase.ts
│   ├── find-{entity}.usecase.ts
│   ├── find-all-{entity}.usecase.ts
│   ├── update-{entity}.usecase.ts
│   └── delete-{entity}.usecase.ts
├── listeners/
│   └── {event}.listener.ts
└── index.ts
```

## Integration

### Update Application Barrel Export
```typescript
// application/index.ts
export * from './usecases/create-entity.usecase';
export * from './usecases/find-entity.usecase';
export * from './usecases/update-entity.usecase';
export * from './usecases/delete-entity.usecase';
export * from './listeners/entity-created.listener';
```

### Register Event Listener
Add to `/src/main.ts`:
```typescript
import { EntityCreatedListener } from '@/contexts/entity/application';

const listener = container.resolve(EntityCreatedListener);
eventBus.on('EntityCreated', listener.handle.bind(listener));
```

## Validation Checklist

After generation, verify:
- [ ] All use cases have `@injectable()`
- [ ] Repositories injected with string tokens
- [ ] Use cases injected by class
- [ ] Single `execute()` method present
- [ ] Input/output interfaces defined
- [ ] Input validation implemented
- [ ] Domain events emitted after success
- [ ] Domain errors thrown (not HTTP)
- [ ] Returns plain objects
- [ ] Event listeners have `@injectable()`
- [ ] Listeners have `handle()` method
- [ ] Listeners catch and log errors

## Related Skills

- **ddd-context-generator**: Generate complete context
- **ddd-entity-generator**: Generate entities used by use cases
- **ddd-api-generator**: Generate controllers that call use cases
- **di-helper**: Check DI registration