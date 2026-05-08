---
name: typescript-security-checker
description: |
  Next.js/TypeScriptプロジェクト向けセキュリティ診断スキル。OWASP準拠。
  以下の場合に使用:
  (1) PRレビュー時のセキュリティチェック
  (2) API Routes のセキュリティ検証
  (3) 認証・認可ロジックの確認
  (4) 依存パッケージの脆弱性確認
  (5) 環境変数・シークレット管理の確認
---

# TypeScript Security Checker

このスキルは、Next.js/TypeScriptプロジェクト向けのセキュリティ診断を実行します。

## 目的

1. **Next.js固有のセキュリティ検証**: Server Components、API Routes、ミドルウェアのセキュリティチェック
2. **OWASP Top 10対応**: 一般的な脆弱性の検出
3. **依存関係の脆弱性スキャン**: 既知の脆弱性を持つパッケージの検出
4. **環境変数管理**: シークレットの安全な管理を確認
5. **セキュアコーディングパターン**: ベストプラクティスの適用確認

---

## チェック項目

### 1. Next.js固有のセキュリティ

#### 1-1. Server Components

**チェック項目**:
- ✅ サーバー専用コードのクライアント漏洩防止
- ✅ `"use server"` ディレクティブの適切な使用
- ✅ Server Actions のバリデーション確認

**検出パターン**:

❌ 危険なパターン
```typescript
// クライアントコンポーネントでサーバー専用APIを使用
'use client';
import { prisma } from '@/lib/db'; // ❌ クライアントでPrisma使用

export default function MyComponent() {
  // ...
}
```

✅ 安全なパターン
```typescript
// Server Component（デフォルト）
import { prisma } from '@/lib/db'; // ✅ サーバーのみで実行

export default async function MyComponent() {
  const data = await prisma.user.findMany();
  return <div>{/* ... */}</div>;
}
```

---

#### 1-2. API Routes

**チェック項目**:
- ✅ 入力バリデーション（Zod等）の有無
- ✅ 認証ミドルウェアの適用確認
- ✅ レート制限の実装確認
- ✅ CORS設定の検証
- ✅ SQLインジェクション対策（Prismaパラメータ化）

**検出パターン**:

❌ 危険なパターン
```typescript
// app/api/users/route.ts
export async function POST(request: Request) {
  const body = await request.json(); // ❌ バリデーションなし

  // ❌ 認証チェックなし
  const user = await prisma.user.create({
    data: body, // ❌ 未検証データをそのまま使用
  });

  return Response.json(user);
}
```

✅ 安全なパターン
```typescript
// app/api/users/route.ts
import { z } from 'zod';
import { requireAuth } from '@/lib/auth';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
});

export async function POST(request: Request) {
  // ✅ 認証チェック
  const session = await requireAuth(request);
  if (!session) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const body = await request.json();

  // ✅ Zodバリデーション
  const result = CreateUserSchema.safeParse(body);
  if (!result.success) {
    return Response.json(
      { error: result.error.flatten() },
      { status: 400 }
    );
  }

  // ✅ 検証済みデータのみ使用
  const user = await prisma.user.create({
    data: {
      email: result.data.email,
      name: result.data.name,
      tenant_id: session.tenantId, // ✅ セッションからtenantIdを取得
    },
  });

  return Response.json(user);
}
```

---

#### 1-3. ミドルウェア

**チェック項目**:
- ✅ 認証・認可ロジックの確認
- ✅ リダイレクト処理の安全性
- ✅ CSRFトークンの検証

**検出パターン**:

❌ 危険なパターン
```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  const token = request.cookies.get('token');

  if (!token) {
    // ❌ オープンリダイレクト脆弱性
    const returnUrl = request.nextUrl.searchParams.get('return');
    return NextResponse.redirect(returnUrl); // 外部URLにリダイレクト可能
  }
}
```

✅ 安全なパターン
```typescript
// middleware.ts
import { verifyToken } from '@/lib/auth';

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('token')?.value;

  if (!token || !(await verifyToken(token))) {
    // ✅ 安全なリダイレクト
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('from', request.nextUrl.pathname);
    return NextResponse.redirect(loginUrl);
  }

  // ✅ CSRFトークンの検証（POST/PUT/DELETE）
  if (['POST', 'PUT', 'DELETE'].includes(request.method)) {
    const csrfToken = request.headers.get('x-csrf-token');
    if (!csrfToken || !verifyCsrfToken(csrfToken)) {
      return NextResponse.json(
        { error: 'CSRF token missing' },
        { status: 403 }
      );
    }
  }
}
```

---

### 2. OWASP Top 10対応

#### A01: アクセス制御の不備

**チェック項目**:
- ✅ 認証なしアクセスの防止
- ✅ 権限チェックの実装
- ✅ テナント分離の確認

**検出パターン**:

```typescript
// ❌ テナント分離なし
const reservations = await prisma.restaurantReservation.findMany({
  where: { id: params.id },
});

// ✅ テナント分離あり
const reservations = await prisma.restaurantReservation.findMany({
  where: {
    id: params.id,
    tenant_id: session.tenantId, // ✅ 必須
  },
});
```

---

#### A02: 暗号化の失敗

**チェック項目**:
- ✅ パスワードのハッシュ化
- ✅ 機密データの暗号化
- ✅ HTTPSの使用

**検出パターン**:

```typescript
// ❌ プレーンテキストでパスワード保存
await prisma.user.create({
  data: {
    email: 'user@example.com',
    password: 'password123', // ❌ プレーンテキスト
  },
});

// ✅ ハッシュ化
import bcrypt from 'bcryptjs';

const hashedPassword = await bcrypt.hash('password123', 10);
await prisma.user.create({
  data: {
    email: 'user@example.com',
    password: hashedPassword, // ✅ ハッシュ化
  },
});
```

---

#### A03: インジェクション

**チェック項目**:
- ✅ SQLインジェクション対策
- ✅ XSS対策
- ✅ コマンドインジェクション対策

**検出パターン**:

```typescript
// ❌ XSSリスク
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ XSS対策
import DOMPurify from 'isomorphic-dompurify';

<div dangerouslySetInnerHTML={{
  __html: DOMPurify.sanitize(userInput)
}} />
```

---

#### A07: 認証の不備

**チェック項目**:
- ✅ セッション管理の安全性
- ✅ パスワードポリシーの適用
- ✅ 多要素認証（MFA）の推奨

---

### 3. 危険なコードパターン

#### パターン1: eval(), new Function()

```typescript
// ❌ コードインジェクションリスク
eval(userInput);
new Function(userInput)();

// ✅ 使用しない
```

#### パターン2: dangerouslySetInnerHTML

```typescript
// ❌ XSSリスク
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ サニタイズ
import DOMPurify from 'isomorphic-dompurify';
<div dangerouslySetInnerHTML={{
  __html: DOMPurify.sanitize(userInput)
}} />
```

#### パターン3: process.env.* (クライアント)

```typescript
// ❌ クライアントで環境変数漏洩
'use client';
const apiKey = process.env.API_KEY; // ❌ バンドルに含まれる

// ✅ サーバーのみで使用
// Server Component または API Route
const apiKey = process.env.API_KEY; // ✅ サーバーのみ
```

---

### 4. 依存関係の脆弱性

**チェック方法**:

```bash
# npm audit
npm audit

# pnpm audit
pnpm audit

# Snyk（推奨）
npx snyk test
```

**自動修正**:

```bash
npm audit fix
pnpm audit fix --fix
```

---

## 診断レポート形式

```markdown
# セキュリティ診断レポート

生成日時: 2026-01-01 10:00:00

## サマリー

| 重大度 | 件数 | 状態 |
|--------|------|------|
| 🔴 Critical | 0 | ✅ |
| 🟠 High | 2 | ⚠️ |
| 🟡 Medium | 5 | ⚠️ |
| 🔵 Low | 8 | 💡 |
| 合計 | 15 | ⚠️ |

## OWASP Top 10準拠状況

| 項目 | 状態 | スコア |
|------|------|--------|
| A01: アクセス制御 | ⚠️ | 70/100 |
| A02: 暗号化 | ✅ | 95/100 |
| A03: インジェクション | ✅ | 90/100 |
| A07: 認証 | ⚠️ | 75/100 |

## 検出された問題

### 🟠 High: バリデーション不足

**ファイル**: `app/api/reservations/route.ts:15`

**問題**:
\`\`\`typescript
const body = await request.json(); // バリデーションなし
\`\`\`

**推奨**:
Zodなどのバリデーションライブラリを使用してください。

\`\`\`typescript
import { z } from 'zod';

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

const result = schema.safeParse(body);
if (!result.success) {
  return Response.json({ error: result.error }, { status: 400 });
}
\`\`\`

---

### 🟡 Medium: テナント分離不足

**ファイル**: `app/api/admin/reservations/route.ts:22`

**問題**:
\`\`\`typescript
const reservations = await prisma.restaurantReservation.findMany({
  where: { status: 'pending' },
});
\`\`\`

**推奨**:
必ず `tenant_id` でフィルタリングしてください。

\`\`\`typescript
const reservations = await prisma.restaurantReservation.findMany({
  where: {
    tenant_id: session.tenantId,
    status: 'pending',
  },
});
\`\`\`
```

---

## ESLint統合

推奨ESLint設定:

```javascript
// eslint.config.mjs
import security from 'eslint-plugin-security';
import sonarjs from 'eslint-plugin-sonarjs';

export default [
  {
    plugins: { security, sonarjs },
    rules: {
      'security/detect-object-injection': 'warn',
      'security/detect-non-literal-regexp': 'warn',
      'security/detect-eval-with-expression': 'error',
      'security/detect-non-literal-fs-filename': 'warn',
      'sonarjs/no-hardcoded-credentials': 'error',
      'sonarjs/no-hardcoded-passwords': 'error',
    }
  }
];
```

---

## スクリプト

### check-security.ts

セキュリティ診断を実行。

```bash
npx ts-node .claude/skills/typescript-security-checker/scripts/check-security.ts
```

### check-dependencies.ts

依存パッケージの脆弱性をチェック。

```bash
npx ts-node .claude/skills/typescript-security-checker/scripts/check-dependencies.ts
```

---

## 使用例

### 全体診断

```
「プロジェクトのセキュリティ診断を実行して」
```

### 特定ファイルの診断

```
「app/api/reservations/route.ts のセキュリティをチェックして」
```

### 依存関係の脆弱性チェック

```
「依存パッケージの脆弱性をチェックして」
```

---

## CI/CD統合

```yaml
# .github/workflows/security-check.yml
name: Security Check

on: [pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm install

      - name: Security Audit
        run: npm audit --audit-level=moderate

      - name: Custom Security Check
        run: npx ts-node .claude/skills/typescript-security-checker/scripts/check-security.ts
```

---

## リファレンス

詳細なチェックリストとパターンは以下を参照：

- [security-checklist.md](references/security-checklist.md) - セキュリティチェックリスト
- [owasp-api-mapping.md](references/owasp-api-mapping.md) - OWASP API Security Top 10対応表
- [secure-patterns.md](references/secure-patterns.md) - セキュアコーディングパターン集

---

## 補足

このスキルは、プロジェクトのセキュリティを継続的に監視し、脆弱性を早期に発見することを目的としています。

参照ドキュメント:
- `documents/architecture/システムアーキテクチャ.md`
- `documents/api/API設計書.md`
