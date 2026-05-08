---
name: lms-auth
description: LMS authentication system including SSO integration, useAuthReady hook patterns, four-layer security architecture, and permission checking. Use this skill when implementing auth flows, handling user sessions, fixing auth-related bugs, or understanding role-based access control.
---

# LMS Auth Skill

> 認證系統、SSO 整合、useAuthReady hook 標準模式、四層安全架構
> Last Updated: 2025-12-29

## 四層安全架構（v1.66.0）

```
1. Authentication (Supabase Auth) - 必須登入
2. RLS (Database Layer) - 粗粒度：authenticated_read, admin_full_access
3. Application Layer (lib/api/permissions.ts) - 細粒度：角色過濾
4. Frontend (AuthGuard) - 頁面存取控制
```

### Application Layer 使用模式

```typescript
import { requireAuth, requireRole, filterByRole } from '@/lib/api/permissions';

// 要求登入
export async function getData() {
  const user = await requireAuth();  // 未登入會 throw Error
  // ...
}

// 要求特定角色
export async function adminOnly() {
  const user = await requireRole(['admin']);
  // ...
}

// 過濾資料
export async function getStudents() {
  const user = await requireAuth();
  const allStudents = await fetchAllStudents();
  return filterByRole(allStudents, user, { gradeField: 'grade' });
}
```

### 關鍵函數

| 函數 | 說明 |
|------|------|
| `getCurrentUser()` | 取得當前用戶，未登入返回 null |
| `requireAuth()` | 要求登入，未登入 throw Error |
| `requireRole(roles)` | 要求特定角色 |
| `filterByRole(data, user, opts)` | 依角色過濾資料 |
| `canAccessGrade(user, grade)` | 檢查是否可存取年級 |
| `canAccessCourseType(user, type)` | 檢查是否可存取課程類型 |

---

## useAuthReady Hook（標準模式）

### 核心規則

**永遠使用 `useAuthReady` hook，不要直接使用 `useAuth`**

### 正確模式

```typescript
import { useAuthReady } from "@/hooks/useAuthReady";

const { userId, isReady, role } = useAuthReady();

useEffect(() => {
  if (!isReady) return;
  fetchData();
}, [userId]);  // primitive 依賴，穩定
```

### 錯誤模式

```typescript
const { user, loading } = useAuth();

useEffect(() => {
  if (loading || !user) return;
  fetchData();
}, [user]);  // 物件依賴，每次都是新參照 → 無限迴圈！
```

### 為什麼這很重要

1. `user` 是物件，React 比較參照而非值
2. 每次 auth 事件都會觸發 useEffect（即使是同一用戶）
3. Supabase 會觸發多個 auth 事件：
   - `INITIAL_SESSION`
   - `SIGNED_IN`
   - `TOKEN_REFRESHED`
4. `useAuthReady` 提取 `userId` 作為穩定的 primitive 值

### Hook 提供的欄位

```typescript
interface UseAuthReadyReturn {
  userId: string | null;           // 穩定，用於 useEffect 依賴
  role: string | null;             // admin/head/teacher/office_member
  isReady: boolean;                // 用戶已登入且權限已載入
  isLoading: boolean;              // 載入中狀態
  permissions: UserPermissions | null;  // 完整權限物件
  grade: number | null;            // HT 年級
  track: string | null;            // HT 課程類型（LT/IT/KCFS）
  teacherType: string | null;      // 教師類型
  fullName: string | null;         // 用戶全名
}
```

---

## AuthContext useRef 修復

### 問題描述

切換 macOS 桌面再切回來時，`onAuthStateChange` 會觸發 `SIGNED_IN` 事件，但 skip 邏輯無法正確判斷。

### 根本原因：React 閉包

```typescript
// 錯誤：userPermissions 是閉包捕獲的初始值（null）
useEffect(() => {
  supabase.auth.onAuthStateChange((event, session) => {
    if (userPermissions?.userId === session?.user?.id) {
      return  // 這個條件永遠不成立！
    }
  })
}, [])  // 空依賴，閉包永遠捕獲初始值
```

### 解決方案：使用 useRef

```typescript
// 正確：使用 ref 追蹤最新的 userPermissions
const userPermissionsRef = useRef<UserPermissions | null>(null);

// 同步 ref 與 state
useEffect(() => {
  userPermissionsRef.current = userPermissions;
}, [userPermissions]);

// 在回調中使用 ref
supabase.auth.onAuthStateChange((event, session) => {
  if (['TOKEN_REFRESHED', 'SIGNED_IN', 'INITIAL_SESSION'].includes(event)
      && userPermissionsRef.current?.userId === session?.user?.id) {
    console.log('[AuthContext] Same user auth event, skipping permission refetch:', event)
    return
  }
})
```

### 效果

切換桌面回來時，console 會顯示：
```
[AuthContext] Same user auth event, skipping permission refetch: SIGNED_IN
```
不會重新 fetch 所有頁面資料。

---

## SSO 整合概要

### 架構

```
User → Info Hub (Google OAuth) → Authorization Code →
LMS (Token Exchange) → Supabase User Sync → Session Creation → Dashboard
```

### OAuth 2.0 + PKCE 流程

1. User 點擊 "Login with Google" on LMS
2. LMS 生成 PKCE challenge，重導向到 Info Hub
3. Info Hub 認證用戶（Google OAuth）
4. Info Hub 同步用戶到 Supabase via Webhook
5. Info Hub 返回 Authorization Code to LMS
6. LMS 交換 code 取得用戶資料（server-side）
7. LMS 建立 Supabase session
8. User 登入到 LMS Dashboard

### 角色映射

| Info Hub Role | LMS Role | Teacher Type | Track |
|---------------|----------|--------------|-------|
| admin | admin | null | null |
| office_member | office_member | null | null |
| head (LT) | head | null | LT |
| head (IT) | head | null | IT |
| head (KCFS) | head | null | KCFS |
| teacher (IT) | teacher | IT | international |
| teacher (LT) | teacher | LT | local |
| teacher (KCFS) | teacher | KCFS | null |
| viewer | Denied | - | - |

### 安全措施

- **PKCE**：防止 code 攔截
- **CSRF State Token**：防止跨站請求偽造
- **Webhook Secret**：驗證用戶同步請求
- **Service Role Key 隔離**：LMS 不分享憑證

---

## 權限檢查模式

### 頁面級權限

```typescript
// app/(lms)/admin/page.tsx
import { useAuthReady } from "@/hooks/useAuthReady";
import { redirect } from "next/navigation";

export default function AdminPage() {
  const { isReady, role } = useAuthReady();

  if (!isReady) return <Loading />;
  if (role !== 'admin') redirect('/dashboard');

  return <AdminContent />;
}
```

### 元件級權限

```typescript
// components/SomeComponent.tsx
const { role, grade, track } = useAuthReady();

// Admin 看到全部
if (role === 'admin') {
  return <AllData />;
}

// Head Teacher 看到管轄範圍
if (role === 'head') {
  const filteredData = data.filter(d =>
    d.grade === grade && d.courseType === track
  );
  return <FilteredData data={filteredData} />;
}

// Teacher 看到自己的
if (role === 'teacher') {
  return <OwnData userId={userId} />;
}
```

### API 級權限（Server Actions）

```typescript
// lib/actions/someAction.ts
import { createClient } from '@/lib/supabase/server';

export async function someAction() {
  const supabase = createClient();

  // RLS 會自動根據用戶角色過濾
  const { data, error } = await supabase
    .from('some_table')
    .select('*');

  return data;
}
```

---

## 環境變數

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...

# SSO
INFOHUB_CLIENT_ID=lms-production
INFOHUB_CLIENT_SECRET=xxx
INFOHUB_WEBHOOK_SECRET=xxx
INFOHUB_BASE_URL=https://info-hub.example.com
```

---

## 常見問題

### 登入後重導向不正確

**原因**：SSO callback 後的 redirect 邏輯
**解決**：檢查 `app/api/auth/callback/infohub/route.ts`

### 權限載入延遲

**原因**：AuthContext 尚未完成載入
**解決**：使用 `isReady` 檢查，顯示 Loading 狀態

### 切換用戶後看到舊資料

**原因**：組件沒有正確監聽 userId 變化
**解決**：確保 useEffect 依賴包含 `userId`
