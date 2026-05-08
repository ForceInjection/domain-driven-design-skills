---
name: api-connector-design
description: |
  外部APIとの統合設計パターンに関する専門知識。RESTful API、GraphQL、WebSocket等の統合設計と実装指針を提供します。

  Anchors:
  • 『RESTful Web APIs』（Leonard Richardson）/ 適用: RESTful API設計、HTTPセマンティクス / 目的: リソース中心の設計パターン理解
  • 『Building Microservices』（Sam Newman）/ 適用: APIコントラクト設計、マイクロサービス間通信 / 目的: サービス境界の明確化

  Trigger:
  Use when designing authentication flows (OAuth 2.0, API Key, JWT), implementing rate limiting and retry strategies, or reviewing API integration architecture.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# API Connector Design

## 概要

外部APIとの統合設計パターンを専門とするスキル。RESTful、GraphQL、WebSocket等のAPI統合の設計と実装を支援します。

## ワークフロー

### Phase 1: 統合要件の整理

**目的**: APIの型、認証要件、制約を明確化

**タスク**:

- APIの種類（REST/GraphQL/WebSocket）を特定
- 認証方式（OAuth 2.0/API Key/JWT等）を確認
- Rate Limit、タイムアウト、リトライポリシーを把握

**Task**: `agents/analyze-connector-context.md` を参照

### Phase 2: 統合設計の実装

**目的**: 認証、エラーハンドリング、リトライロジックの設計

**タスク**:

- `references/authentication-flows.md` で認証フロー選択
- `references/error-handling-patterns.md` でエラーハンドリング設計
- `references/rate-limiting-strategies.md` でリトライ戦略を適用
- テンプレートから実装コード生成

**Task**: `agents/design-connector.md` を参照

### Phase 3: 検証と最適化

**目的**: 設計の完全性とベストプラクティス準拠を確認

**タスク**:

- エッジケース（接続失敗、タイムアウト）の処理確認
- API仕様との整合性チェック
- パフォーマンス・セキュリティ要件の検証

**Task**: `agents/validate-connector.md` を参照

## Task仕様ナビ

| Task                   | 入力                      | 出力                      | 複雑度 |
| ---------------------- | ------------------------- | ------------------------- | ------ |
| 認証フロー設計         | API仕様、認可要件         | auth-config-template.json | 中     |
| APIクライアント実装    | エンドポイント、認証      | APIクライアントコード     | 高     |
| エラーハンドリング設計 | エラー仕様、リトライ      | エラーハンドリング手順    | 中     |
| Rate Limit対応         | API制限仕様、トラフィック | リトライ・バックオフ戦略  | 低     |
| 統合アーキレビュー     | 設計書、実装コード        | レビューコメント、改善案  | 高     |

## ベストプラクティス

### すべきこと

- 外部API（Google Drive、Slack、GitHub等）との統合設計時にこのスキルを使用
- 複数の認証方式を検討し、API要件に最適なものを選択
- エラーハンドリング（タイムアウト、リトライ、バックオフ）を最初から設計に含める
- Rate Limitingやクォータ管理を実装設計の段階で考慮
- テンプレートを参照して実装の一貫性を保証
- セキュリティレビュー（認証情報の扱い、暗号化通信）を実施

### 避けるべきこと

- 認証方式を軽く考えて後付けする（最初から設計に含めること）
- エラーハンドリングを「エラーが起きたら例外」で済ませる（具体的なリトライ戦略が必須）
- Rate Limitに対応しないまま実装を進める（接続失敗の原因になる）
- APIドキュメントを確認しないまま実装を始める（余分な手戻りが発生）
- 認証トークンやAPIキーをコード内に埋め込む（設定ファイル化すること）

## リソース参照

- `references/Level1_basics.md`: 基礎概念と標準パターン
- `references/Level2_intermediate.md`: 実装レベルの詳細ガイド
- `references/Level3_advanced.md`: マイクロサービス間通信等の応用パターン
- `references/Level4_expert.md`: 複雑な統合シナリオと最適化
- `references/authentication-flows.md`: OAuth 2.0、API Key、JWT等の詳細比較
- `references/error-handling-patterns.md`: エラー分類、リトライ戦略、タイムアウト管理
- `references/rate-limiting-strategies.md`: Rate Limit検出、バックオフ、トークンバケット

## 関連スキル

- `.claude/skills/api-client-patterns`: クライアント実装パターンの詳細
- `.claude/skills/api-contract-design`: APIコントラクト設計
- `.claude/skills/authentication-flows`: 認証フロー実装

## 変更履歴

| Version | Date       | Changes                                     |
| ------- | ---------- | ------------------------------------------- |
| 2.0.0   | 2025-12-31 | agents/3ファイル追加、Phase別Task参照を追加 |
| 1.0.2   | 2025-12-31 | 18-skills.md仕様への準拠、Task仕様ナビ追加  |
| 1.0.1   | 2025-12-24 | アーティファクト追加とspec整合化            |
