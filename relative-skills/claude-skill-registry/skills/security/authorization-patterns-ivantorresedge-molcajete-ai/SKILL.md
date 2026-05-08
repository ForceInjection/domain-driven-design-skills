---
name: authorization-patterns
description: Authorization patterns including RBAC and ABAC. Use when implementing access control.
---

# Authorization Patterns Skill

This skill covers authorization patterns for controlling access to resources.

## When to Use

Use this skill when:
- Implementing role-based access control (RBAC)
- Setting up attribute-based access control (ABAC)
- Creating permission guards
- Controlling resource access

## Core Principle

**LEAST PRIVILEGE** - Grant minimum permissions needed. Default to deny. Validate on every request.

## Role-Based Access Control (RBAC)

### Role Definition

```typescript
// src/lib/roles.ts
export const Role = {
  USER: 'USER',
  MODERATOR: 'MODERATOR',
  ADMIN: 'ADMIN',
} as const;

export type Role = (typeof Role)[keyof typeof Role];

export const Permission = {
  // Users
  USER_READ: 'user:read',
  USER_CREATE: 'user:create',
  USER_UPDATE: 'user:update',
  USER_DELETE: 'user:delete',

  // Posts
  POST_READ: 'post:read',
  POST_CREATE: 'post:create',
  POST_UPDATE: 'post:update',
  POST_DELETE: 'post:delete',

  // Admin
  ADMIN_ACCESS: 'admin:access',
} as const;

export type Permission = (typeof Permission)[keyof typeof Permission];

export const rolePermissions: Record<Role, Permission[]> = {
  USER: [
    Permission.USER_READ,
    Permission.POST_READ,
    Permission.POST_CREATE,
  ],
  MODERATOR: [
    Permission.USER_READ,
    Permission.POST_READ,
    Permission.POST_CREATE,
    Permission.POST_UPDATE,
    Permission.POST_DELETE,
  ],
  ADMIN: Object.values(Permission),
};
```

### Permission Checker

```typescript
// src/lib/permissions.ts
import { Role, Permission, rolePermissions } from './roles';

export function hasPermission(role: Role, permission: Permission): boolean {
  return rolePermissions[role].includes(permission);
}

export function hasAnyPermission(role: Role, permissions: Permission[]): boolean {
  return permissions.some((p) => hasPermission(role, p));
}

export function hasAllPermissions(role: Role, permissions: Permission[]): boolean {
  return permissions.every((p) => hasPermission(role, p));
}
```

### Authorization Middleware

```typescript
// src/plugins/authorize.ts
import { FastifyPluginAsync, FastifyRequest, FastifyReply } from 'fastify';
import fp from 'fastify-plugin';
import { Permission, hasPermission, hasAnyPermission } from '../lib/permissions';

declare module 'fastify' {
  interface FastifyInstance {
    authorize: (...permissions: Permission[]) => (
      request: FastifyRequest,
      reply: FastifyReply
    ) => Promise<void>;
    authorizeAny: (...permissions: Permission[]) => (
      request: FastifyRequest,
      reply: FastifyReply
    ) => Promise<void>;
  }
}

const authorizePlugin: FastifyPluginAsync = async (fastify) => {
  // Require ALL permissions
  fastify.decorate('authorize', (...permissions: Permission[]) => {
    return async (request: FastifyRequest, reply: FastifyReply) => {
      if (!request.user) {
        return reply.status(401).send({ error: 'Unauthorized' });
      }

      const authorized = permissions.every((p) =>
        hasPermission(request.user.role, p)
      );

      if (!authorized) {
        return reply.status(403).send({ error: 'Forbidden' });
      }
    };
  });

  // Require ANY permission
  fastify.decorate('authorizeAny', (...permissions: Permission[]) => {
    return async (request: FastifyRequest, reply: FastifyReply) => {
      if (!request.user) {
        return reply.status(401).send({ error: 'Unauthorized' });
      }

      const authorized = hasAnyPermission(request.user.role, permissions);

      if (!authorized) {
        return reply.status(403).send({ error: 'Forbidden' });
      }
    };
  });
};

export default fp(authorizePlugin);
```

### Using Authorization

```typescript
// src/routes/admin.ts
import { FastifyPluginAsync } from 'fastify';
import { Permission } from '../lib/roles';

const adminRoutes: FastifyPluginAsync = async (fastify) => {
  // All routes require authentication
  fastify.addHook('preHandler', fastify.authenticate);

  // Admin dashboard - requires admin access
  fastify.get('/dashboard', {
    preHandler: [fastify.authorize(Permission.ADMIN_ACCESS)],
  }, async () => {
    return { stats: await getAdminStats(fastify) };
  });

  // Manage users - requires user management permissions
  fastify.get('/users', {
    preHandler: [fastify.authorize(Permission.USER_READ, Permission.ADMIN_ACCESS)],
  }, async () => {
    return fastify.db.user.findMany();
  });

  fastify.delete('/users/:id', {
    preHandler: [fastify.authorize(Permission.USER_DELETE)],
  }, async (request) => {
    const { id } = request.params as { id: string };
    await fastify.db.user.delete({ where: { id } });
    return { success: true };
  });
};

export default adminRoutes;
```

## Attribute-Based Access Control (ABAC)

### Policy Definition

```typescript
// src/lib/abac/policies.ts
import { User, Post } from '@prisma/client';

interface PolicyContext {
  user: User;
  resource: unknown;
  action: string;
  environment?: {
    time?: Date;
    ip?: string;
  };
}

type PolicyFunction = (context: PolicyContext) => boolean;

const policies: Record<string, PolicyFunction> = {
  // Post policies
  'post:read': ({ resource }) => {
    const post = resource as Post;
    return post.published;
  },

  'post:update': ({ user, resource }) => {
    const post = resource as Post;
    return post.authorId === user.id || user.role === 'ADMIN';
  },

  'post:delete': ({ user, resource }) => {
    const post = resource as Post;
    return post.authorId === user.id || user.role === 'ADMIN';
  },

  // User policies
  'user:update': ({ user, resource }) => {
    const targetUser = resource as User;
    return user.id === targetUser.id || user.role === 'ADMIN';
  },

  // Time-based policy
  'admin:access': ({ user, environment }) => {
    if (user.role !== 'ADMIN') return false;

    // Only during business hours
    const hour = environment?.time?.getHours() ?? new Date().getHours();
    return hour >= 9 && hour <= 17;
  },
};

export function checkPolicy(
  action: string,
  context: Omit<PolicyContext, 'action'>
): boolean {
  const policy = policies[action];
  if (!policy) {
    return false; // Deny by default
  }
  return policy({ ...context, action });
}
```

### ABAC Middleware

```typescript
// src/plugins/abac.ts
import { FastifyPluginAsync, FastifyRequest, FastifyReply } from 'fastify';
import fp from 'fastify-plugin';
import { checkPolicy } from '../lib/abac/policies';

type ResourceLoader<T> = (request: FastifyRequest) => Promise<T>;

declare module 'fastify' {
  interface FastifyInstance {
    checkAccess: <T>(
      action: string,
      loadResource: ResourceLoader<T>
    ) => (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

const abacPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.decorate(
    'checkAccess',
    <T>(action: string, loadResource: ResourceLoader<T>) => {
      return async (request: FastifyRequest, reply: FastifyReply) => {
        if (!request.user) {
          return reply.status(401).send({ error: 'Unauthorized' });
        }

        const resource = await loadResource(request);
        if (!resource) {
          return reply.status(404).send({ error: 'Resource not found' });
        }

        const user = await fastify.db.user.findUnique({
          where: { id: request.user.userId },
        });

        if (!user) {
          return reply.status(401).send({ error: 'Unauthorized' });
        }

        const allowed = checkPolicy(action, {
          user,
          resource,
          environment: {
            time: new Date(),
            ip: request.ip,
          },
        });

        if (!allowed) {
          return reply.status(403).send({ error: 'Forbidden' });
        }

        // Attach resource to request for handler
        (request as FastifyRequest & { resource: T }).resource = resource;
      };
    }
  );
};

export default fp(abacPlugin);
```

### Using ABAC

```typescript
// src/routes/posts.ts
import { FastifyPluginAsync } from 'fastify';

const postsRoutes: FastifyPluginAsync = async (fastify) => {
  // Update post with ABAC
  fastify.put<{ Params: { id: string } }>('/:id', {
    preHandler: [
      fastify.authenticate,
      fastify.checkAccess('post:update', async (request) => {
        const { id } = request.params as { id: string };
        return fastify.db.post.findUnique({ where: { id } });
      }),
    ],
  }, async (request) => {
    const post = (request as unknown as { resource: Post }).resource;
    const { title, content } = request.body as { title: string; content: string };

    return fastify.db.post.update({
      where: { id: post.id },
      data: { title, content },
    });
  });

  // Delete post with ABAC
  fastify.delete<{ Params: { id: string } }>('/:id', {
    preHandler: [
      fastify.authenticate,
      fastify.checkAccess('post:delete', async (request) => {
        const { id } = request.params as { id: string };
        return fastify.db.post.findUnique({ where: { id } });
      }),
    ],
  }, async (request) => {
    const post = (request as unknown as { resource: Post }).resource;
    await fastify.db.post.delete({ where: { id: post.id } });
    return { success: true };
  });
};

export default postsRoutes;
```

## Scope-Based Authorization

```typescript
// src/lib/scopes.ts
export const Scope = {
  READ: 'read',
  WRITE: 'write',
  DELETE: 'delete',
  ADMIN: 'admin',
} as const;

export type Scope = (typeof Scope)[keyof typeof Scope];

export function parseScopes(scopeString: string): Scope[] {
  return scopeString.split(' ').filter((s): s is Scope =>
    Object.values(Scope).includes(s as Scope)
  );
}

export function hasScope(userScopes: Scope[], requiredScope: Scope): boolean {
  if (userScopes.includes(Scope.ADMIN)) return true;
  return userScopes.includes(requiredScope);
}
```

## Best Practices

1. **Default deny** - Require explicit permission grants
2. **Centralize policies** - Single source of truth
3. **Audit access** - Log authorization decisions
4. **Fail closed** - Errors result in denial
5. **Test policies** - Unit test authorization logic
6. **Separate concerns** - Authentication vs authorization

## Notes

- RBAC is simpler for most applications
- ABAC is more flexible for complex rules
- Combine both for best results
- Cache permission checks for performance
