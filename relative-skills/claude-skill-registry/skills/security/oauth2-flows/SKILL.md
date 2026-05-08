---
name: oauth2-flows
description: |
  OAuth 2.0認可フローの実装パターンとセキュリティベストプラクティス。
  Authorization Code Flow、PKCE、Refresh Token Flowの正確な実装を提供。
  Web/SPA/モバイルアプリでの安全な認可フロー実装を支援。

  Anchors:
  • OAuth 2.0 Simplified (Aaron Parecki) / 適用: 認可フロー全般 / 目的: RFC準拠の正確な実装
  • Web Application Security (Andrew Hoffman) / 適用: セキュリティ設計 / 目的: 脅威モデリングと対策
  • RFC 6749 (OAuth 2.0 Framework) / 適用: プロトコル仕様 / 目的: 標準準拠の担保

  Trigger:
  Use when implementing OAuth 2.0 authentication, configuring authorization flows, integrating with OAuth providers, implementing PKCE for SPAs, or managing token lifecycle.
  oauth2, authorization code, pkce, access token, refresh token, oauth provider, google auth, github oauth
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# OAuth 2.0 Flows Implementation

## 概要

OAuth 2.0認可フローの実装パターンとセキュリティベストプラクティスを提供。
Authorization Code Flow、PKCE、Refresh Token Flowの正確な実装を支援する。

## ワークフロー

### Phase 1: フロー選定

**目的**: アプリケーション特性に基づき適切な認可フローを選定

**アクション**:

1. クライアントタイプを特定（サーバーサイド/SPA/モバイル/CLI）
2. 適切なフローを選定
3. セキュリティ要件を確認

**Task**: `agents/select-flow.md` を参照

### Phase 2: 実装

**目的**: 選定したフローを実装

**アクション**:

1. OAuth プロバイダー設定
2. 認可エンドポイント実装
3. トークン交換実装
4. エラーハンドリング実装

**Task**: `agents/implement-flow.md` を参照

### Phase 3: セキュリティ検証

**目的**: セキュリティベストプラクティスへの準拠を確認

**アクション**:

1. `scripts/validate-oauth-config.mjs` で設定検証
2. `references/security-checklist.md` でチェック
3. トークンストレージ戦略の確認

## Task仕様（ナビゲーション）

| Task           | 起動タイミング | 入力                 | 出力           |
| -------------- | -------------- | -------------------- | -------------- |
| select-flow    | Phase 1開始時  | アプリケーション要件 | フロー選定結果 |
| implement-flow | Phase 2開始時  | フロー選定結果       | 実装コード     |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリの対応ファイルを参照

## フロー選定ガイド

| クライアントタイプ           | 推奨フロー                | 理由                 |
| ---------------------------- | ------------------------- | -------------------- |
| サーバーサイドWeb            | Authorization Code        | シークレット保護可能 |
| SPA (ブラウザ)               | Authorization Code + PKCE | シークレット保護不可 |
| モバイルアプリ               | Authorization Code + PKCE | シークレット保護不可 |
| CLI / デスクトップ           | Device Authorization      | ブラウザ連携が複雑   |
| 信頼されたファーストパーティ | Resource Owner Password   | 非推奨・限定使用     |

## ベストプラクティス

### すべきこと

- 常に`state`パラメータを使用（CSRF対策）
- SPAとモバイルではPKCEを必須使用
- トークンは安全なストレージに保存
- Refresh Tokenは必要最小限のスコープで取得
- HTTPSを必須使用
- `redirect_uri`を厳密に検証

### 避けるべきこと

- Implicit Flow の使用（非推奨）
- トークンのURLパラメータ露出
- ワイルドカード`redirect_uri`
- 過度に広いスコープ要求
- トークンのlocalStorage保存（XSS脆弱性）

## リソース参照

### references/（詳細知識）

| リソース           | パス                                                                                 | 用途                 |
| ------------------ | ------------------------------------------------------------------------------------ | -------------------- |
| 基礎知識           | See [references/basics.md](references/basics.md)                                     | OAuth 2.0基本概念    |
| Authorization Code | See [references/authorization-code-flow.md](references/authorization-code-flow.md)   | 認可コードフロー詳細 |
| PKCE実装           | See [references/pkce-implementation.md](references/pkce-implementation.md)           | PKCE実装詳細         |
| セキュリティ       | See [references/security-checklist.md](references/security-checklist.md)             | セキュリティチェック |
| トークンストレージ | See [references/token-storage-strategies.md](references/token-storage-strategies.md) | ストレージ戦略       |

### scripts/（決定論的処理）

| スクリプト                  | 用途               | 使用例                                            |
| --------------------------- | ------------------ | ------------------------------------------------- |
| `validate-oauth-config.mjs` | 設定検証           | `node scripts/validate-oauth-config.mjs <config>` |
| `log_usage.mjs`             | フィードバック記録 | `node scripts/log_usage.mjs --result success`     |

### assets/（テンプレート）

| テンプレート                      | 用途                                    |
| --------------------------------- | --------------------------------------- |
| `auth-code-flow-template.ts`      | サーバーサイドOAuth認可コードフロー実装 |
| `pkce-implementation-template.ts` | SPA/モバイル向けPKCE実装                |

## 変更履歴

| Version | Date       | Changes                    |
| ------- | ---------- | -------------------------- |
| 2.0.0   | 2026-01-02 | 18-skills.md仕様に完全準拠 |
| 1.0.0   | 2025-12-24 | 初期バージョン             |
