---
name: new-api-route
description: |
  Create new ORPC API routes with contracts, routers, and client integration.
  创建新的 ORPC API 路由，包含合约、路由器和客户端集成。

  Use when:
  - Adding new API endpoints
  - Creating CRUD operations for a new entity
  - User mentions "new API", "add endpoint", "create route", "新增接口", "添加 API"
---

# New API Route Skill / 新增 API 路由技能

> **设计思路 / Design Notes**:
> 1. 这是一个多步骤工作流，需要修改多个文件
> 2. 提供完整的代码模板，保持项目一致性
> 3. 明确文件位置和修改顺序
> 4. 包含常见模式（CRUD、分页等）

## Overview / 概述

Create type-safe ORPC API routes following the project's contract-first pattern.
按照项目的合约优先模式创建类型安全的 ORPC API 路由。

## Step-by-Step Instructions / 分步指令

### Step 1: Create Contract / 创建合约

**File**: `packages/api/src/contracts/<entity>.ts`

```typescript
// [IN]: @orpc/contract, valibot / 依赖 oRPC 合约及验证器
// [OUT]: <entity>Contract object / 导出 <entity> API 合约定义
// [POS]: API layer - <Entity> contract definition / API 层 - <实体>合约定义
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议：更新本文件时，同步更新此头注释及所属文件夹的 .folder.md

import { oc } from '@orpc/contract';
import * as v from 'valibot';

const <entity>Contract = oc
  .prefix('/<entities>')
  .tag('<entity>')
  .router({
    // GET /<entities> - List all
    all: oc
      .route({ method: 'GET', path: '/', summary: 'List all <entities>' })
      .output(v.array(v.object({
        id: v.string(),
        // ... other fields
      }))),

    // GET /<entities>/{id} - Get one
    one: oc
      .route({ method: 'GET', path: '/{id}', summary: 'Get <entity> by ID' })
      .input(v.object({ id: v.pipe(v.string(), v.uuid()) }))
      .output(v.object({
        id: v.string(),
        // ... all fields
      })),

    // POST /<entities> - Create
    create: oc
      .route({ method: 'POST', path: '/', summary: 'Create <entity>' })
      .input(Create<Entity>Schema)
      .output(v.object({})),

    // DELETE /<entities>/{id} - Delete
    delete: oc
      .route({ method: 'DELETE', path: '/{id}', summary: 'Delete <entity>' })
      .input(v.object({ id: v.pipe(v.string(), v.uuid()) }))
      .output(v.object({})),
  });

export default <entity>Contract;
```

### Step 2: Register Contract / 注册合约

**File**: `packages/api/src/contracts/index.ts`

```typescript
import <entity>Contract from './<entity>';

export const appContract = oc
  .errors({ /* existing errors */ })
  .router({
    // ... existing routes
    <entity>: <entity>Contract,  // 👈 Add new contract
  });
```

### Step 3: Create Router / 创建路由器

**File**: `packages/api/src/server/router/<entity>.ts`

```typescript
// [IN]: @repo/db, ../orpc / 依赖数据库及 oRPC 过程
// [OUT]: <entity>Router object / 导出 <entity> 路由处理器
// [POS]: API layer - <Entity> CRUD handlers / API 层 - <实体> CRUD 处理器
// Protocol: When updating me, sync this header + parent folder's .folder.md
// 协议：更新本文件时，同步更新此头注释及所属文件夹的 .folder.md

import { desc, eq } from '@repo/db';
import { <entity> } from '@repo/db/schema';
import { protectedProcedure } from '../orpc';

const <entity>Router = {
  all: protectedProcedure.<entity>.all.handler(({ context }) => {
    return context.db.query.<entity>.findMany({
      orderBy: desc(<entity>.createdAt),
    });
  }),

  one: protectedProcedure.<entity>.one.handler(
    async ({ context, input, errors }) => {
      const [result] = await context.db
        .select()
        .from(<entity>)
        .where(eq(<entity>.id, input.id));

      if (!result) {
        throw errors.NOT_FOUND({ message: `<Entity> not found` });
      }
      return result;
    }
  ),

  create: protectedProcedure.<entity>.create.handler(
    async ({ context, input }) => {
      await context.db.insert(<entity>).values({
        ...input,
        createdBy: context.session.user.id,
      });
      return {};
    }
  ),

  delete: protectedProcedure.<entity>.delete.handler(
    async ({ context, input, errors }) => {
      const res = await context.db
        .delete(<entity>)
        .where(eq(<entity>.id, input.id));

      if (res.rowCount === 0) {
        throw errors.NOT_FOUND({ message: `<Entity> not found` });
      }
      return {};
    }
  ),
};

export default <entity>Router;
```

### Step 4: Register Router / 注册路由器

**File**: `packages/api/src/server/router/index.ts`

```typescript
import <entity>Router from './<entity>';

export const appRouter = {
  // ... existing routers
  <entity>: <entity>Router,  // 👈 Add new router
};
```

### Step 5: Update Documentation / 更新文档

1. Update `.folder.md` files in affected directories
2. Run `pnpm doc-lint` to verify

### Step 6: Push Schema (if new table) / 推送模式（如果是新表）

```bash
pnpm db:push
```

## Client Usage Example / 客户端使用示例

```typescript
// In apps/web
import { apiClient } from '@/clients/apiClient';

// List
const { data } = apiClient.<entity>.all.useQuery();

// Create
const mutation = apiClient.<entity>.create.useMutation();
await mutation.mutateAsync({ /* input */ });
```

## Reference / 参考

- Existing example: `packages/api/src/contracts/posts.ts`
- Router example: `packages/api/src/server/router/post.ts`
