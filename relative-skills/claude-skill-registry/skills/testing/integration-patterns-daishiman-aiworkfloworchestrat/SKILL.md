---
name: integration-patterns
description: |
  MCPサーバーと外部システム間の統合パターン設計。同期・非同期通信、イベント駆動アーキテクチャ、データ同期パターンの設計指針を提供します。

  Anchors:
  • Enterprise Integration Patterns (Hohpe/Woolf) / 適用: パターン選択・設計 / 目的: スケーラブルな連携設計
  • Designing Data-Intensive Applications (Kleppmann) / 適用: 非同期・イベント駆動 / 目的: 分散システムの信頼性
  • The Pragmatic Programmer / 適用: 実装品質 / 目的: 実践的な改善

  Trigger:
  Use when designing system integration, API connectivity, service communication, async processing, or event-driven architecture.
  integration patterns, mcp server, async communication, event-driven, message queue, api integration
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# 統合パターン

## 概要

MCPサーバーと外部システム間の統合パターン設計。同期・非同期通信、イベント駆動アーキテクチャ、データ同期パターンを提供。

## ワークフロー

### Phase 1: パターン選択

**Objective**: 要件から最適な統合パターンを特定

**Actions**:

1. Invoke Task: `agents/select-pattern.md`
2. Reference: `references/sync-patterns.md`, `references/async-patterns.md`
3. Use template: `assets/integration-design-template.md`

**Outputs**: 推奨パターンと選定理由

### Phase 2: 詳細設計

**Objective**: メッセージスキーマとフロー設計

**Actions**:

1. Invoke Task: `agents/design-integration.md`
2. Reference: `references/event-driven-guide.md`
3. Use template: `assets/message-schema-template.json`
4. Run: `node scripts/validate-message-schema.mjs <schema>`

**Outputs**: 統合設計ドキュメント、メッセージスキーマ

### Phase 3: 検証

**Objective**: 設計の品質を確保

**Actions**:

1. Invoke Task: `agents/validate-integration.md`
2. Run: `node scripts/review-integration-design.mjs <design>`
3. Run: `node scripts/log_usage.mjs --result success --phase complete`

**Outputs**: 検証済み設計、改善提案

## Task仕様ナビ

| Taskファイル                     | When to Use | Inputs   | Outputs          |
| -------------------------------- | ----------- | -------- | ---------------- |
| `agents/select-pattern.md`       | Phase 1     | 要件     | 推奨パターン     |
| `agents/design-integration.md`   | Phase 2     | パターン | 設計ドキュメント |
| `agents/validate-integration.md` | Phase 3     | 設計     | 検証結果         |

## ベストプラクティス

### すべきこと

- 要件に基づくパターン選択
- メッセージスキーマのバージョン管理
- Dead Letter Queueでエラーハンドリング
- メッセージフローの監視設計
- Pub-Subでスケーラビリティ確保

### 避けるべきこと

- 高負荷時の過度な同期通信
- スキーマレス設計
- エラー処理の欠落
- 監視なしの統合

## リソース参照

### 参照資料

| Resource       | Path                                                                     | Purpose                   |
| -------------- | ------------------------------------------------------------------------ | ------------------------- |
| 同期パターン   | See [references/sync-patterns.md](references/sync-patterns.md)           | Request-Response, Gateway |
| 非同期パターン | See [references/async-patterns.md](references/async-patterns.md)         | Message Queue, Pub-Sub    |
| イベント駆動   | See [references/event-driven-guide.md](references/event-driven-guide.md) | Event Sourcing, CQRS      |

### スクリプト

| スクリプト                      | Usage                                               | Purpose      |
| ------------------------------- | --------------------------------------------------- | ------------ |
| `validate-message-schema.mjs`   | `node scripts/validate-message-schema.mjs <file>`   | スキーマ検証 |
| `review-integration-design.mjs` | `node scripts/review-integration-design.mjs <file>` | 設計レビュー |
| `log_usage.mjs`                 | `node scripts/log_usage.mjs --result success`       | 使用記録     |

### アセット

| テンプレート                     | Purpose              |
| -------------------------------- | -------------------- |
| `integration-design-template.md` | 統合設計テンプレート |
| `message-schema-template.json`   | メッセージスキーマ   |

## 変更履歴

| Version | Date       | Changes                      |
| ------- | ---------- | ---------------------------- |
| 1.2.0   | 2026-01-02 | 18-skills.md準拠、agents追加 |
| 1.1.0   | 2025-12-31 | Anchors/Trigger追加          |
