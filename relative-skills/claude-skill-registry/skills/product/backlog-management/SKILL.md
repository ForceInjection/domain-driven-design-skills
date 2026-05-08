---
name: backlog-management
description: |
  プロダクトバックログの作成・整理・優先順位付けを行うためのスキル。
  ユーザーストーリー作成、DEEP原則の適用、健全性分析を通じて実装可能な状態を維持します。

  Anchors:
  • Agile Estimating and Planning / 適用: 見積もりと優先度 / 目的: 計画精度の向上
  • User Stories Applied / 適用: ストーリー作成 / 目的: 要件の明確化
  • The Product Owner's Handbook / 適用: バックログ運用 / 目的: 価値最大化

  Trigger:
  Use when managing product backlogs, refining user stories, prioritizing items, or assessing backlog health.
allowed-tools:
  - bash
  - node
---

# バックログ管理スキル

## 概要

バックログを実装可能な状態に保つために、ストーリー作成、優先順位付け、健全性分析を整理する。
詳細は `references/` に外部化し、必要時に参照する。

- ストーリーテンプレは `assets/user-story-template.md`
- DEEP原則は `references/deep-principles.md`

## ワークフロー

### Phase 1: 現状整理

**目的**: バックログの目的と現状を整理する

**アクション**:

1. `references/Level1_basics.md` で基礎概念を確認
2. バックログの状態と制約を整理
3. `references/deep-principles.md` でDEEP原則を確認

**Task**: `agents/analyze-backlog-context.md`

### Phase 2: 作成と優先順位付け

**目的**: ストーリー作成と優先順位付けを行う

**アクション**:

1. `assets/user-story-template.md` を使ってストーリーを作成
2. `references/Level2_intermediate.md` で優先順位付けの観点を整理
3. 必要に応じて `references/deep-principle-guide.md` を参照

**Task**:
- `agents/refine-backlog-items.md`
- `agents/prioritize-backlog.md`

### Phase 3: 検証と改善

**目的**: 健全性分析と改善記録を行う

**アクション**:

1. `scripts/analyze-backlog.mjs` で健全性を分析
2. `scripts/validate-skill.mjs` で構造検証
3. `scripts/log_usage.mjs` で改善記録

**Task**: `agents/validate-backlog-health.md`

## Task仕様ナビ

| Task | 役割 | 入力 | 出力 | 参照先 | 実行タイミング |
| --- | --- | --- | --- | --- | --- |
| 現状整理 | 目的・制約の整理 | 既存バックログ | コンテキスト要約 | `references/Level1_basics.md` | Phase 1 |
| リファインメント | ストーリー整備 | コンテキスト要約 | 更新ストーリー | `assets/user-story-template.md` | Phase 2 前半 |
| 優先順位付け | 価値/依存の整理 | 更新ストーリー | 優先順位メモ | `references/Level2_intermediate.md` | Phase 2 後半 |
| 健全性検証 | 分析と改善提案 | バックログ | 検証レポート | `scripts/analyze-backlog.mjs` | Phase 3 |

## ベストプラクティス

### すべきこと

- ストーリー形式を統一する
- 受け入れ基準を必ず記載する
- 優先度の根拠を記録する
- 定期的に健全性分析を行う

### 避けるべきこと

- ストーリーの粒度を揃えないまま進める
- 優先順位を固定化して更新しない
- 見積もりや受け入れ基準のない項目を放置する

## リソース参照

### 参照資料

- `references/Level1_basics.md`: 基本概念
- `references/Level2_intermediate.md`: リファインメントと優先度
- `references/Level3_advanced.md`: 分析とメトリクス
- `references/Level4_expert.md`: エンタープライズ運用
- `references/deep-principles.md`: DEEP原則
- `references/deep-principle-guide.md`: DEEP実装ガイド
- `references/legacy-skill.md`: 旧版要約（移行時のみ参照）

### スクリプト

- `scripts/analyze-backlog.mjs`: 健全性分析
- `scripts/validate-skill.mjs`: スキル構造検証
- `scripts/log_usage.mjs`: 実行ログ記録

### テンプレート

- `assets/user-story-template.md`: ストーリーテンプレ

## 変更履歴

| Version | Date       | Changes                                             |
| ------- | ---------- | --------------------------------------------------- |
| 2.1.0   | 2025-12-31 | 18-skills準拠、Task仕様追加、scripts整備            |
| 2.0.0   | 2025-12-31 | 18-skills.md仕様に完全準拠                           |
| 1.0.0   | 2025-12-24 | 初版作成                                            |
