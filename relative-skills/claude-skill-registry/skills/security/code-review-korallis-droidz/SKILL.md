---
name: code-review
description: |
  Review code changes following RT Stack conventions and best practices.
  按照 RT Stack 规范和最佳实践审查代码变更。

  Use when:
  - Reviewing pull requests
  - Checking code quality before commit
  - User mentions "review", "check code", "审查代码", "代码检查"
allowed-tools: Read, Grep, Glob, Bash
---

# Code Review Skill / 代码审查技能

> **设计思路 / Design Notes**:
> 1. `allowed-tools` 限制为只读工具，确保审查过程不会修改代码
> 2. 提供项目特定的检查清单
> 3. 按重要性分级（Critical > Warning > Info）
> 4. 包含自动化检查命令

## Overview / 概述

Review code changes following RT Stack patterns and conventions.
按照 RT Stack 模式和规范审查代码变更。

## Review Checklist / 审查清单

### 🔴 Critical Issues / 严重问题

1. **Type Safety / 类型安全**
   - No `any` types without justification / 无理由不使用 `any`
   - Proper Valibot schemas for API inputs/outputs / API 输入输出使用正确的 Valibot 模式
   - Database queries use proper types / 数据库查询使用正确类型

2. **Security / 安全**
   - Protected routes use `protectedProcedure` / 受保护路由使用 `protectedProcedure`
   - No secrets in code / 代码中无密钥
   - Input validation on all user inputs / 所有用户输入都有验证

3. **Error Handling / 错误处理**
   - API errors use defined error codes / API 错误使用定义的错误码
   - No unhandled promise rejections / 无未处理的 Promise 拒绝

### 🟡 Warning Issues / 警告问题

1. **Architecture / 架构**
   - New code follows existing patterns / 新代码遵循现有模式
   - Packages don't import from apps / 包不从 apps 导入
   - Environment variables use correct prefix / 环境变量使用正确前缀

2. **Documentation / 文档**
   - New files have `[IN]/[OUT]/[POS]` headers / 新文件有头注释
   - Affected `.folder.md` updated / 受影响的 `.folder.md` 已更新
   - Bilingual comments / 双语注释

3. **Performance / 性能**
   - No N+1 queries / 无 N+1 查询
   - Proper use of TanStack Query caching / 正确使用 TanStack Query 缓存

### 🔵 Info / Style / 信息/风格

1. **Naming / 命名**
   - Database columns use `snake_case` / 数据库列使用 `snake_case`
   - TypeScript uses `camelCase` / TypeScript 使用 `camelCase`
   - Components use `PascalCase` / 组件使用 `PascalCase`

2. **Imports / 导入**
   - Use `@/` alias for web app / Web 应用使用 `@/` 别名
   - Use `#/` alias for UI package / UI 包使用 `#/` 别名
   - Use `@repo/*` for cross-package / 跨包使用 `@repo/*`

## Automated Checks / 自动化检查

Run these commands before approving:

```bash
# Type check / 类型检查
pnpm typecheck

# Lint / 代码检查
pnpm lint

# Format check / 格式检查
pnpm format

# Documentation check / 文档检查
pnpm doc-lint
```

## Review Process / 审查流程

### Step 1: Understand Changes / 理解变更

```bash
# View changed files / 查看变更文件
git diff --name-only HEAD~1

# View full diff / 查看完整差异
git diff HEAD~1
```

### Step 2: Check Patterns / 检查模式

For each file type, verify:

| File Location | Check |
|--------------|-------|
| `packages/api/src/contracts/` | Valibot schemas, OpenAPI annotations |
| `packages/api/src/server/router/` | Uses `protectedProcedure`, proper error handling |
| `packages/db/src/schemas/` | Foreign keys, timestamps, snake_case |
| `apps/web/src/routes/` | TanStack Router patterns, proper loaders |
| `apps/web/src/routes/-components/` | Reusable, no direct API calls |

### Step 3: Run Checks / 运行检查

```bash
pnpm lint && pnpm typecheck && pnpm doc-lint
```

### Step 4: Provide Feedback / 提供反馈

Use this format / 使用此格式：

```markdown
## Code Review / 代码审查

### 🔴 Critical / 严重
- [ ] Issue description / 问题描述

### 🟡 Warnings / 警告
- [ ] Issue description / 问题描述

### 🔵 Suggestions / 建议
- [ ] Suggestion / 建议

### ✅ Approved / 批准
- Code follows RT Stack conventions / 代码遵循 RT Stack 规范
- All checks pass / 所有检查通过
```

## Common Issues / 常见问题

### Missing Protected Procedure / 缺少受保护过程
```typescript
// ❌ Wrong
const router = {
  create: publicProcedure.create.handler(...)
};

// ✅ Correct
const router = {
  create: protectedProcedure.create.handler(...)
};
```

### Direct Database Import in Web / Web 中直接导入数据库
```typescript
// ❌ Wrong (in apps/web)
import { db } from '@repo/db';

// ✅ Correct (use API client)
import { apiClient } from '@/clients/apiClient';
```

### Missing Error Handling / 缺少错误处理
```typescript
// ❌ Wrong
const [result] = await db.select().from(table).where(...);
return result; // Could be undefined!

// ✅ Correct
if (!result) {
  throw errors.NOT_FOUND({ message: 'Not found' });
}
return result;
```
