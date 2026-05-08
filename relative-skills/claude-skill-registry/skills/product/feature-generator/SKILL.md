---
name: feature-generator
description: React Native Feature 模块生成指南。当用户提到"创建 feature"、"新建模块"、"生成功能"、"添加功能模块"、"feature 模板"时使用此 skill。
---

# Feature 模块生成指南

在 `comet` CLI 落地前，本指南提供手动创建符合设计规范的 feature 模块的完整流程。

## 快速生成

### 完整 Feature（三层架构）

```bash
# 创建目录结构
mkdir -p src/features/<feature-name>/{presentation/{screens,components,stores},domain/{entities,repositories},data/{datasources,repositories}}

# 创建测试目录
mkdir -p __tests__/features/<feature-name>/{presentation,domain,data}
```

### 轻量 Feature（仅 Presentation）

```bash
mkdir -p src/features/<feature-name>/presentation/{screens,components,stores}
mkdir -p __tests__/features/<feature-name>/presentation
```

---

## 目录结构

### 完整三层架构

```text
src/features/<feature-name>/
  presentation/
    screens/
      <FeatureName>Screen.tsx       # 页面组件
    components/
      <FeatureName>View.tsx         # 纯展示组件
      <OtherComponent>.tsx          # 其他 UI 组件
    stores/
      use<FeatureName>Store.ts      # Zustand Store
    hooks/
      use<FeatureName>Query.ts      # TanStack Query（可选）

  domain/
    entities/
      <featureName>.ts              # 实体类型定义
    repositories/
      <featureName>Repository.ts    # 仓库接口

  data/
    datasources/
      <FeatureName>RemoteDataSource.ts   # 远程数据源
      <FeatureName>LocalDataSource.ts    # 本地数据源（可选）
    repositories/
      <FeatureName>RepositoryImpl.ts     # 仓库实现
```

---

## 文件模板

### 1. Screen 组件

`presentation/screens/<FeatureName>Screen.tsx`

```tsx
import React from 'react';
import {View, Text} from 'react-native';
// import {use<FeatureName>Store} from '../stores/use<FeatureName>Store';

type Props = {
  // navigation props if needed
};

export function <FeatureName>Screen({}: Props) {
  // const {state, action} = use<FeatureName>Store();

  return (
    <View className="flex-1 items-center justify-center">
      <Text><FeatureName> Screen</Text>
    </View>
  );
}
```

### 2. View 组件

`presentation/components/<FeatureName>View.tsx`

```tsx
import React from 'react';
import {View, Text} from 'react-native';

type Props = {
  // view props
};

export function <FeatureName>View({}: Props) {
  return (
    <View>
      <Text><FeatureName> View</Text>
    </View>
  );
}
```

### 3. Zustand Store

`presentation/stores/use<FeatureName>Store.ts`

```ts
import {create} from 'zustand';

type <FeatureName>State = {
  // state
  isLoading: boolean;
  error: string | null;

  // actions
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  reset: () => void;
};

const initialState = {
  isLoading: false,
  error: null,
};

export const use<FeatureName>Store = create<<FeatureName>State>((set) => ({
  ...initialState,

  setLoading: (isLoading) => set({isLoading}),
  setError: (error) => set({error}),
  reset: () => set(initialState),
}));
```

### 4. TanStack Query Hook（可选）

`presentation/hooks/use<FeatureName>Query.ts`

```ts
import {useQuery, useMutation, useQueryClient} from '@tanstack/react-query';
// import {<featureName>Repository} from '../../domain/repositories/<featureName>Repository';

export const <featureName>Keys = {
  all: ['<featureName>'] as const,
  lists: () => [...<featureName>Keys.all, 'list'] as const,
  list: (filters: string) => [...<featureName>Keys.lists(), {filters}] as const,
  details: () => [...<featureName>Keys.all, 'detail'] as const,
  detail: (id: string) => [...<featureName>Keys.details(), id] as const,
};

export function use<FeatureName>ListQuery() {
  return useQuery({
    queryKey: <featureName>Keys.lists(),
    queryFn: async () => {
      // return <featureName>Repository.getList();
      return [];
    },
  });
}

export function use<FeatureName>DetailQuery(id: string) {
  return useQuery({
    queryKey: <featureName>Keys.detail(id),
    queryFn: async () => {
      // return <featureName>Repository.getById(id);
      return null;
    },
    enabled: !!id,
  });
}
```

### 5. Domain Entity

`domain/entities/<featureName>.ts`

```ts
// Domain entity - pure TypeScript, no RN dependencies

export type <FeatureName> = {
  id: string;
  // other properties
  createdAt: Date;
  updatedAt: Date;
};

export type Create<FeatureName>Input = Omit<<FeatureName>, 'id' | 'createdAt' | 'updatedAt'>;
export type Update<FeatureName>Input = Partial<Create<FeatureName>Input>;
```

### 6. Repository Interface

`domain/repositories/<featureName>Repository.ts`

```ts
import type {<FeatureName>, Create<FeatureName>Input, Update<FeatureName>Input} from '../entities/<featureName>';

export type <FeatureName>Repository = {
  getAll(): Promise<<FeatureName>[]>;
  getById(id: string): Promise<<FeatureName> | null>;
  create(input: Create<FeatureName>Input): Promise<<FeatureName>>;
  update(id: string, input: Update<FeatureName>Input): Promise<<FeatureName>>;
  delete(id: string): Promise<void>;
};
```

### 7. Remote DataSource

`data/datasources/<FeatureName>RemoteDataSource.ts`

```ts
import type {<FeatureName>, Create<FeatureName>Input, Update<FeatureName>Input} from '../../domain/entities/<featureName>';
// import {httpClient} from '@/core/network/httpClient';

export type <FeatureName>RemoteDataSource = {
  fetchAll(): Promise<<FeatureName>[]>;
  fetchById(id: string): Promise<<FeatureName> | null>;
  create(input: Create<FeatureName>Input): Promise<<FeatureName>>;
  update(id: string, input: Update<FeatureName>Input): Promise<<FeatureName>>;
  delete(id: string): Promise<void>;
};

export function create<FeatureName>RemoteDataSource(): <FeatureName>RemoteDataSource {
  const BASE_PATH = '/<feature-name>s';

  return {
    async fetchAll() {
      // const response = await httpClient.get<{data: <FeatureName>[]}>(BASE_PATH);
      // return response.data.data;
      return [];
    },

    async fetchById(id) {
      // const response = await httpClient.get<{data: <FeatureName>}>(`${BASE_PATH}/${id}`);
      // return response.data.data;
      return null;
    },

    async create(input) {
      // const response = await httpClient.post<{data: <FeatureName>}>(BASE_PATH, input);
      // return response.data.data;
      throw new Error('Not implemented');
    },

    async update(id, input) {
      // const response = await httpClient.patch<{data: <FeatureName>}>(`${BASE_PATH}/${id}`, input);
      // return response.data.data;
      throw new Error('Not implemented');
    },

    async delete(id) {
      // await httpClient.delete(`${BASE_PATH}/${id}`);
    },
  };
}
```

### 8. Repository Implementation

`data/repositories/<FeatureName>RepositoryImpl.ts`

```ts
import type {<FeatureName>Repository} from '../../domain/repositories/<featureName>Repository';
import type {<FeatureName>RemoteDataSource} from '../datasources/<FeatureName>RemoteDataSource';

export function create<FeatureName>Repository(
  remoteDataSource: <FeatureName>RemoteDataSource
): <FeatureName>Repository {
  return {
    async getAll() {
      return remoteDataSource.fetchAll();
    },

    async getById(id) {
      return remoteDataSource.fetchById(id);
    },

    async create(input) {
      return remoteDataSource.create(input);
    },

    async update(id, input) {
      return remoteDataSource.update(id, input);
    },

    async delete(id) {
      return remoteDataSource.delete(id);
    },
  };
}
```

---

## 路由注册

### 1. 添加路由常量

`app/navigation/routes.ts`

```ts
export const AppRoutes = {
  // ... existing routes
  <FeatureName>: '<FeatureName>',
} as const;

export type RootStackParamList = {
  // ... existing params
  <FeatureName>: undefined;  // 或 { id: string } 等参数
};
```

### 2. 注册到 Navigator

`app/navigation/RootNavigator.tsx`

```tsx
import {<FeatureName>Screen} from '@/features/<feature-name>/presentation/screens/<FeatureName>Screen';

// 在 Stack.Navigator 中添加
<Stack.Screen name="<FeatureName>" component={<FeatureName>Screen} />
```

---

## 测试模板

### Store 测试

`__tests__/features/<feature-name>/presentation/use<FeatureName>Store.test.ts`

```ts
import {use<FeatureName>Store} from '@/features/<feature-name>/presentation/stores/use<FeatureName>Store';

describe('use<FeatureName>Store', () => {
  beforeEach(() => {
    use<FeatureName>Store.getState().reset();
  });

  it('should initialize with default state', () => {
    const state = use<FeatureName>Store.getState();
    expect(state.isLoading).toBe(false);
    expect(state.error).toBeNull();
  });

  it('should update loading state', () => {
    use<FeatureName>Store.getState().setLoading(true);
    expect(use<FeatureName>Store.getState().isLoading).toBe(true);
  });

  it('should reset to initial state', () => {
    use<FeatureName>Store.getState().setLoading(true);
    use<FeatureName>Store.getState().setError('test error');
    use<FeatureName>Store.getState().reset();

    const state = use<FeatureName>Store.getState();
    expect(state.isLoading).toBe(false);
    expect(state.error).toBeNull();
  });
});
```

### Screen 测试

`__tests__/features/<feature-name>/presentation/<FeatureName>Screen.test.tsx`

```tsx
import React from 'react';
import {render, screen} from '@testing-library/react-native';
import {<FeatureName>Screen} from '@/features/<feature-name>/presentation/screens/<FeatureName>Screen';

describe('<FeatureName>Screen', () => {
  it('should render correctly', () => {
    render(<<FeatureName>Screen />);
    expect(screen.getByText(/<FeatureName>/i)).toBeTruthy();
  });
});
```

---

## 命名规范速查

| 类型           | 命名格式                        | 文件名                             | 示例                             |
| -------------- | ------------------------------- | ---------------------------------- | -------------------------------- |
| Feature 目录   | `kebab-case`                    | -                                  | `user-profile/`                  |
| Screen         | `<FeatureName>Screen`           | `<FeatureName>Screen.tsx`          | `UserProfileScreen.tsx`          |
| View           | `<FeatureName>View`             | `<FeatureName>View.tsx`            | `UserProfileView.tsx`            |
| Store          | `use<FeatureName>Store`         | `use<FeatureName>Store.ts`         | `useUserProfileStore.ts`         |
| Query Hook     | `use<FeatureName>Query`         | `use<FeatureName>Query.ts`         | `useUserProfileQuery.ts`         |
| Entity         | `<FeatureName>`                 | `<featureName>.ts`                 | `userProfile.ts`                 |
| Repository     | `<FeatureName>Repository`       | `<featureName>Repository.ts`       | `userProfileRepository.ts`       |
| DataSource     | `<FeatureName>RemoteDataSource` | `<FeatureName>RemoteDataSource.ts` | `UserProfileRemoteDataSource.ts` |
| RepositoryImpl | `<FeatureName>RepositoryImpl`   | `<FeatureName>RepositoryImpl.ts`   | `UserProfileRepositoryImpl.ts`   |

---

## 分层依赖规则

```text
presentation ──► domain ◄── data
     │              │          │
     │              │          │
     ▼              │          ▼
  core/*            │       core/network
  (UI, theme)       │       core/storage
                    │
              纯 TypeScript
              (无 RN 依赖)
```

| 层级            | 可依赖                         | 禁止依赖                       |
| --------------- | ------------------------------ | ------------------------------ |
| `presentation/` | `domain/`、`core/`、React/RN   | 其他 feature 的 store/组件     |
| `domain/`       | 纯 TypeScript 类型             | `react-native`、UI 包、`data/` |
| `data/`         | `domain/` 接口、`core/network` | `presentation/`                |

---

## 子代理执行建议

创建 feature 时，建议通过子代理执行以确保一致性：

```typescript
Task({
  subagent_type: 'general-purpose',
  description: '创建 user-profile feature',
  prompt: `按照 .claude/skills/feature-generator/SKILL.md 创建完整的 user-profile feature，包含三层架构`,
});
```

---

## Checklist

创建 Feature 时的检查清单：

- [ ] 目录结构符合规范（`presentation/domain/data`）
- [ ] 文件命名遵循约定（PascalCase/camelCase）
- [ ] Store 使用 Zustand 模式
- [ ] Domain 层不依赖 React Native
- [ ] 已注册路由（如需要）
- [ ] 已创建基础测试文件
- [ ] 导出路径配置正确（tsconfig paths）
