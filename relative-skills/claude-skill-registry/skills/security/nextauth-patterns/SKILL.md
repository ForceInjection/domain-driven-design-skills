---
name: nextauth-patterns
description: |
  NextAuth.js v5の設定とカスタマイズパターンを専門とするスキル。
  OAuth 2.0プロバイダー統合、データベースアダプター、セッション戦略、コールバック実装、型安全なセッション管理を提供する。

  Anchors:
  • Web Application Security (Andrew Hoffman) / 適用: OAuth脅威モデリングとセッションセキュリティ / 目的: 安全な認証フロー設計
  • NextAuth.js v5 Official Docs / 適用: プロバイダー設定とコールバック / 目的: 標準準拠の実装

  Trigger:
  Use when implementing NextAuth.js authentication, configuring OAuth providers (Google, GitHub),
  integrating database adapters (Drizzle), designing session strategies (JWT or database-backed),
  customizing authentication callbacks, or adding role-based data to sessions.
  Keywords: nextauth, oauth, authentication, session, jwt, drizzle adapter, google oauth, github oauth
---

# NextAuth.js Patterns

## 概要

NextAuth.js v5の設定とカスタマイズパターン。OAuth 2.0プロバイダー統合、データベースアダプター、セッション戦略、コールバック実装を扱う。

詳細な実装パターンと背景知識は `references/` を参照。

## ワークフロー

### Phase 1: 要件整理とTask選択

**目的**: 実装要件を明確にし、適切なTaskを選択する

**アクション**:

1. 実装要件を確認（OAuth provider, session strategy, database adapter）
2. `references/basics.md` で基礎知識を確認
3. 必要に応じて以下のTaskを選択：
   - **基本設定Task**: `agents/config-setup.md` - 初期auth.ts設定
   - **Provider統合Task**: `agents/provider-integration.md` - OAuth 2.0プロバイダー設定
   - **Session設計Task**: `agents/session-design.md` - セッション戦略とコールバック実装
   - **検証Task**: `agents/validation.md` - 設定検証とテスト

### Phase 2: Task実行

**目的**: 選択したTaskを順次実行する

**Task呼び出しパターン**:

```markdown
# 基本設定から開始する場合

1. agents/config-setup.md → 基本auth.ts作成
2. agents/provider-integration.md → OAuth設定追加
3. agents/session-design.md → セッションコールバック実装
4. agents/validation.md → 動作確認

# 既存設定の拡張の場合

1. agents/provider-integration.md → 新規プロバイダー追加
2. agents/validation.md → 統合テスト
```

**入出力契約**:

- **入力**: 要件定義（provider種別、session strategy、必須カスタマイズ）
- **中間成果物**: auth.ts設定ファイル、環境変数設定
- **最終成果物**: 動作確認済みの認証システム

### Phase 3: 検証と記録

**目的**: 実装の検証と使用記録の保存

**アクション**:

1. `scripts/validate-nextauth-config.mjs` で設定を検証
2. 動作確認（ログイン/ログアウト/セッション取得）
3. `scripts/log_usage.mjs` で実行記録を保存

```bash
# 設定検証
node .claude/skills/nextauth-patterns/scripts/validate-nextauth-config.mjs <auth-file-path>

# 使用記録
node .claude/skills/nextauth-patterns/scripts/log_usage.mjs \
  --result success \
  --phase "provider-integration" \
  --agent "provider-integration"
```

## Task仕様ナビゲーション

### agents/config-setup.md

**いつ使うか**: NextAuth.js初期セットアップ時

**入力**:

- プロジェクト構造（App Router / Pages Router）
- 使用データベース種別（PostgreSQL, MySQL, SQLite）
- 優先セッション戦略（JWT or Database）

**出力**:

- `auth.ts` 基本設定ファイル
- Route Handler設定（`app/api/auth/[...nextauth]/route.ts`）
- 環境変数テンプレート（`.env.example`）

### agents/provider-integration.md

**いつ使うか**: OAuth 2.0プロバイダー追加時

**入力**:

- プロバイダー種別（Google, GitHub, その他）
- 必要スコープ
- カスタム認可パラメータ

**出力**:

- プロバイダー設定コード
- 環境変数追加項目
- OAuth コンソール設定手順

### agents/session-design.md

**いつ使うか**: セッションカスタマイズが必要な場合

**入力**:

- カスタムセッションデータ（role, permissions, metadata等）
- セッション有効期限要件
- 更新トリガー条件

**出力**:

- `jwt()` コールバック実装
- `session()` コールバック実装
- TypeScript型定義拡張（`next-auth.d.ts`）

### agents/validation.md

**いつ使うか**: 実装完了後の検証フェーズ

**入力**:

- 実装済み `auth.ts`
- 環境変数設定（`.env.local`）
- テストシナリオ

**出力**:

- 検証レポート
- 問題点と修正提案
- セキュリティチェックリスト結果

## ベストプラクティス

### すべきこと

- **環境変数の分離**: クライアントIDとシークレットは必ず `.env.local` で管理
- **型安全性の確保**: `next-auth.d.ts` でセッション型を拡張
- **セッション戦略の選択**: JWT（スケーラビリティ優先）vs Database（即時無効化優先）を要件に応じて選択
- **スコープの最小化**: OAuth スコープは必要最小限に設定
- **コールバックの分離**: 複雑なロジックは別関数に切り出す
- **検証スクリプトの実行**: 設定変更時は必ず `validate-nextauth-config.mjs` を実行

### 避けるべきこと

- **シークレットのハードコード**: 環境変数を使わずコードに直接記述
- **過度なスコープ要求**: 不要な権限を要求する
- **型定義の省略**: any型でセッションを扱う
- **エラーハンドリングの欠如**: コールバック内でエラーを無視
- **セッション期限の未設定**: デフォルト値に依存する
- **検証の省略**: 動作確認なしで本番デプロイ

## リソース参照

### 参照ドキュメント

| ドキュメント                                     | 内容                               |
| ------------------------------------------------ | ---------------------------------- |
| [references/basics.md](references/basics.md)     | 基礎概念、認証フロー、コールバック |
| [references/patterns.md](references/patterns.md) | 実装パターン、アダプター統合       |

### ドメイン知識

- **Provider設定**: [references/provider-configurations.md](references/provider-configurations.md)
  - Google, GitHub, その他OAuth 2.0プロバイダーの詳細設定
- **Session & Callbacks**: [references/session-callbacks-guide.md](references/session-callbacks-guide.md)
  - jwt(), session(), signIn() 各コールバックの実装パターン

### 旧バージョン

- **Legacy Skill**: [references/legacy-skill.md](references/legacy-skill.md)
  - 旧SKILL.md全文（参考用）

## スクリプト

### validate-nextauth-config.mjs

**目的**: NextAuth.js設定ファイルの妥当性検証

**使用法**:

```bash
node scripts/validate-nextauth-config.mjs <auth-file-path>
```

**検証項目**:

- Provider設定の完全性
- 環境変数の存在確認
- Callback実装の型安全性
- Session戦略の一貫性

### log_usage.mjs

**目的**: スキル使用記録と評価メトリクス更新

**使用法**:

```bash
node scripts/log_usage.mjs \
  --result <success|failure> \
  --phase "<phase-name>" \
  --agent "<agent-name>" \
  --notes "<optional-notes>"
```

### validate-skill.mjs

**目的**: Skill構造の整合性検証

**使用法**:

```bash
node scripts/validate-skill.mjs
```

## テンプレート

### nextauth-config-template.ts

**場所**: [assets/nextauth-config-template.ts](assets/nextauth-config-template.ts)

**内容**:

- Google/GitHub OAuth統合
- Drizzle Adapter設定
- JWT/Database session 両戦略
- Role-based session callback

**使用法**:

```bash
# テンプレート参照
cat .claude/skills/nextauth-patterns/assets/nextauth-config-template.ts

# プロジェクトにコピー
cp .claude/skills/nextauth-patterns/assets/nextauth-config-template.ts src/auth.ts
```

## トラブルシューティング

### よくある問題

| 問題                               | 原因                    | 解決策                                                                           |
| ---------------------------------- | ----------------------- | -------------------------------------------------------------------------------- |
| `NEXTAUTH_SECRET` エラー           | 環境変数未設定          | `.env.local` に追加、`openssl rand -base64 32` で生成                            |
| セッションに追加データが含まれない | Callback実装漏れ        | `jwt()` と `session()` 両方で処理                                                |
| OAuth リダイレクトエラー           | Redirect URI不一致      | Providerコンソールで `http://localhost:3000/api/auth/callback/<provider>` を登録 |
| 型エラー                           | `next-auth.d.ts` 未作成 | Session/JWT型を拡張                                                              |

## 評価基準

### 成功基準

- [ ] Provider認証が成功する
- [ ] セッションデータが正しく取得できる
- [ ] カスタムデータ（role等）がセッションに含まれる
- [ ] 型安全性が確保されている（TypeScriptエラーなし）
- [ ] `validate-nextauth-config.mjs` が成功する

### 品質基準

- [ ] 環境変数が適切に分離されている
- [ ] コールバックロジックが明確で保守しやすい
- [ ] セッション戦略が要件に適合している
- [ ] OAuth スコープが最小限である
- [ ] エラーハンドリングが実装されている

## 変更履歴

| Version | Date       | Changes                                         |
| ------- | ---------- | ----------------------------------------------- |
| 2.0.0   | 2025-12-31 | 18-skills.md準拠にリファクタリング、agents/追加 |
| 1.0.0   | 2025-12-24 | Spec alignment and required artifacts added     |
