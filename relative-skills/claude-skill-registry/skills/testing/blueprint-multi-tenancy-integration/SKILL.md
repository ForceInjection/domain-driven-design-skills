---
name: "Blueprint Multi-Tenancy Integration"
description: "Integrate the Blueprint multi-tenancy pattern into new features and modules. Use this skill when adding Blueprint-aware functionality, implementing BlueprintMember access control, handling Blueprint ownership (User vs Organization), enforcing resource isolation, and integrating with BlueprintEventBus. Ensures proper multi-tenant architecture where Blueprint defines permission boundaries and all resources respect Blueprint context."
license: "MIT"
---

# Blueprint Multi-Tenancy Integration Skill

This skill helps integrate Blueprint multi-tenancy patterns into features and modules.

## Blueprint System Overview

### Core Concept

**Blueprint is a Permission Boundary, NOT a Data Boundary**

- Blueprint defines WHO can access WHAT resources
- Resources belong to Blueprints
- Users access resources via BlueprintMember role + permissions
- Owner can be User or Organization

### Entity Hierarchy

```
User ─┐
      ├─→ Blueprint ─→ Resources (Tasks, Files, etc.)
Organization ─┘
      ├─→ Team
      └─→ Partner
```

### Key Entities

```typescript
interface Blueprint {
  id: string;
  name: string;
  ownerType: 'user' | 'organization';
  ownerId: string;
  createdAt: Date;
  updatedAt: Date;
}

interface BlueprintMember {
  id: string; // {userId}_{blueprintId}
  blueprintId: string;
  userId: string;
  memberType: 'user' | 'team' | 'partner';
  role: 'owner' | 'admin' | 'member' | 'viewer';
  permissions: string[]; // ['task:create', 'task:update', ...]
  status: 'active' | 'suspended' | 'revoked';
  createdAt: Date;
  updatedAt: Date;
}
```

## Integration Patterns

### 1. Resource with Blueprint Context

All resources MUST include Blueprint reference:

```typescript
interface Task {
  id: string;
  blueprintId: string; // ✅ REQUIRED
  title: string;
  description: string;
  status: 'pending' | 'in-progress' | 'completed';
  assignedTo?: string; // User, Team, or Partner ID
  assignedToType?: 'user' | 'team' | 'partner';
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}
```

### 2. Repository Queries with Blueprint Filter

```typescript
@Injectable({ providedIn: 'root' })
export class TaskRepository extends FirestoreBaseRepository<Task> {
  protected collectionName = 'tasks';
  
  /**
   * ✅ CORRECT: Always filter by blueprintId
   */
  async findByBlueprintId(blueprintId: string): Promise<Task[]> {
    return this.executeWithRetry(async () => {
      const q = query(
        collection(this.firestore, this.collectionName),
        where('blueprint_id', '==', blueprintId),
        where('deleted_at', '==', null),
        orderBy('created_at', 'desc')
      );
      return this.queryDocuments(q);
    });
  }
  
  /**
   * ✅ CORRECT: Include blueprintId in creation
   */
  async create(blueprintId: string, task: Omit<Task, 'id'>): Promise<Task> {
    return this.executeWithRetry(async () => {
      const taskWithBlueprint = {
        ...task,
        blueprintId,
        createdAt: new Date(),
        updatedAt: new Date(),
        deletedAt: null
      };
      return this.createDocument(taskWithBlueprint);
    });
  }
}
```

### 3. Service with Blueprint Context

```typescript
@Injectable({ providedIn: 'root' })
export class TaskService {
  private taskRepository = inject(TaskRepository);
  private blueprintMemberRepository = inject(BlueprintMemberRepository);
  private eventBus = inject(BlueprintEventBus);
  
  /**
   * Get tasks for specific Blueprint
   */
  async getTasks(blueprintId: string): Promise<Task[]> {
    // Validate user has access to Blueprint
    await this.validateBlueprintAccess(blueprintId);
    
    return await this.taskRepository.findByBlueprintId(blueprintId);
  }
  
  /**
   * Create task in Blueprint context
   */
  async createTask(
    blueprintId: string,
    task: Omit<Task, 'id' | 'blueprintId'>
  ): Promise<Task> {
    // Validate user has permission
    await this.validatePermission(blueprintId, 'task:create');
    
    // Create task with Blueprint context
    const created = await this.taskRepository.create(blueprintId, task);
    
    // Publish Blueprint event
    this.eventBus.publish({
      type: 'task.created',
      blueprintId,
      timestamp: new Date(),
      actor: this.getCurrentUserId(),
      data: created
    });
    
    return created;
  }
  
  private async validateBlueprintAccess(blueprintId: string): Promise<void> {
    const userId = this.getCurrentUserId();
    const member = await this.blueprintMemberRepository.findByUserAndBlueprint(
      userId,
      blueprintId
    );
    
    if (!member || member.status !== 'active') {
      throw new Error('Access denied to Blueprint');
    }
  }
  
  private async validatePermission(
    blueprintId: string,
    permission: string
  ): Promise<void> {
    const userId = this.getCurrentUserId();
    const member = await this.blueprintMemberRepository.findByUserAndBlueprint(
      userId,
      blueprintId
    );
    
    if (!member || member.status !== 'active') {
      throw new Error('Access denied to Blueprint');
    }
    
    if (!member.permissions.includes(permission)) {
      throw new Error(`Missing permission: ${permission}`);
    }
  }
}
```

### 4. Component with Blueprint Context

```typescript
@Component({
  selector: 'app-task-list',
  standalone: true,
  imports: [SHARED_IMPORTS],
  template: `
    <div class="task-list">
      <h2>Tasks for {{ blueprintName() }}</h2>
      
      @if (loading()) {
        <nz-spin nzSimple />
      } @else {
        @for (task of tasks(); track task.id) {
          <app-task-item [task]="task" />
        } @empty {
          <nz-empty />
        }
      }
    </div>
  `
})
export class TaskListComponent {
  private taskService = inject(TaskService);
  private blueprintService = inject(BlueprintService);
  
  // ✅ Blueprint context from input or route
  blueprintId = input.required<string>();
  
  loading = signal(false);
  tasks = signal<Task[]>([]);
  blueprintName = signal<string>('');
  
  constructor() {
    effect(() => {
      const id = this.blueprintId();
      this.loadBlueprint(id);
      this.loadTasks(id);
    });
  }
  
  async loadBlueprint(blueprintId: string): Promise<void> {
    const blueprint = await this.blueprintService.getBlueprint(blueprintId);
    this.blueprintName.set(blueprint.name);
  }
  
  async loadTasks(blueprintId: string): Promise<void> {
    this.loading.set(true);
    try {
      const tasks = await this.taskService.getTasks(blueprintId);
      this.tasks.set(tasks);
    } finally {
      this.loading.set(false);
    }
  }
}
```

## Ownership Patterns

### User-Owned Blueprint

```typescript
// When ownerType = 'user'
interface Blueprint {
  ownerType: 'user';
  ownerId: string; // User ID
}

// Members can only be:
// - Users (collaborators)
interface BlueprintMember {
  memberType: 'user';
  userId: string;
}
```

### Organization-Owned Blueprint

```typescript
// When ownerType = 'organization'
interface Blueprint {
  ownerType: 'organization';
  ownerId: string; // Organization ID
}

// Members can be:
// - Organization members
// - Teams (sub-accounts)
// - Partners (external relations)
interface BlueprintMember {
  memberType: 'user' | 'team' | 'partner';
  userId?: string; // If memberType = 'user'
  teamId?: string; // If memberType = 'team'
  partnerId?: string; // If memberType = 'partner'
}
```

## Permission System

### Role + Permissions Model

```typescript
// Roles provide base permissions
type Role = 'owner' | 'admin' | 'member' | 'viewer';

// Permissions are granular capabilities
type Permission = 
  | 'task:create' 
  | 'task:read' 
  | 'task:update' 
  | 'task:delete'
  | 'file:upload'
  | 'file:download'
  | 'member:invite'
  | 'member:remove';

// BlueprintMember combines both
interface BlueprintMember {
  role: Role; // High-level access
  permissions: Permission[]; // Granular capabilities
}
```

### Checking Permissions

```typescript
// In Service
async checkPermission(
  blueprintId: string,
  permission: Permission
): Promise<boolean> {
  const member = await this.getMember(blueprintId);
  return member?.permissions.includes(permission) ?? false;
}

// In Component (UI-level check)
canCreateTask = computed(() => {
  const member = this.currentMember();
  return member?.permissions.includes('task:create') ?? false;
});
```

## Security Rules Integration

### Blueprint-Aware Rules

```javascript
// Firestore Security Rules
match /tasks/{taskId} {
  // Validate Blueprint membership
  allow read: if isAuthenticated() && 
                 isBlueprintMember(resource.data.blueprint_id);
  
  // Validate permissions
  allow create: if isAuthenticated() && 
                   isBlueprintMember(request.resource.data.blueprint_id) &&
                   hasPermission(request.resource.data.blueprint_id, 'task:create');
}

// Helper functions
function isBlueprintMember(blueprintId) {
  let memberId = request.auth.uid + '_' + blueprintId;
  return exists(/databases/$(database)/documents/blueprintMembers/$(memberId));
}

function hasPermission(blueprintId, permission) {
  let memberId = request.auth.uid + '_' + blueprintId;
  let member = get(/databases/$(database)/documents/blueprintMembers/$(memberId));
  return permission in member.data.permissions &&
         member.data.status == 'active';
}
```

## Event-Driven Integration

### Publishing Blueprint Events

```typescript
// When task changes in Blueprint context
this.eventBus.publish({
  type: 'task.created', // Domain event
  blueprintId: task.blueprintId, // ✅ Blueprint context
  timestamp: new Date(),
  actor: this.getCurrentUserId(),
  data: task
});
```

### Subscribing to Blueprint Events

```typescript
// Subscribe to events in specific Blueprint
this.eventBus.subscribe('task.created')
  .pipe(
    filter(event => event.blueprintId === this.blueprintId()),
    takeUntilDestroyed(this.destroyRef)
  )
  .subscribe(event => {
    console.log('Task created in current Blueprint:', event.data);
    this.refreshTasks();
  });
```

## Testing Blueprint Integration

```typescript
describe('Task Service with Blueprint', () => {
  it('should filter tasks by blueprint', async () => {
    const blueprint1Tasks = await service.getTasks('blueprint1');
    const blueprint2Tasks = await service.getTasks('blueprint2');
    
    expect(blueprint1Tasks.every(t => t.blueprintId === 'blueprint1')).toBe(true);
    expect(blueprint2Tasks.every(t => t.blueprintId === 'blueprint2')).toBe(true);
  });
  
  it('should reject access without membership', async () => {
    // User not member of blueprint
    await expectAsync(
      service.getTasks('blueprint3')
    ).toBeRejectedWithError('Access denied to Blueprint');
  });
  
  it('should reject action without permission', async () => {
    // User has read but not create permission
    await expectAsync(
      service.createTask('blueprint1', { title: 'Test' })
    ).toBeRejectedWithError('Missing permission: task:create');
  });
});
```

## Checklist

When integrating Blueprint pattern:

- [ ] All resources include blueprintId
- [ ] Repository queries filter by Blueprint
- [ ] Service validates Blueprint access
- [ ] Service checks granular permissions
- [ ] Components receive Blueprint context
- [ ] Events include blueprintId
- [ ] Security Rules validate membership
- [ ] Security Rules check permissions
- [ ] Tests cover multi-tenancy isolation
- [ ] Tests cover permission enforcement
- [ ] No cross-Blueprint data leakage

## References

- [Architecture Guide](.github/instructions/ng-gighub-architecture.instructions.md)
- [Security Rules](.github/instructions/ng-gighub-security-rules.instructions.md)
- [Event Bus Integration](./event-bus-integration/SKILL.md)
