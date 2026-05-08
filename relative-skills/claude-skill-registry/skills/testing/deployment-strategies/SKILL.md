---
name: deployment-strategies
description: |
  デプロイ戦略の選定、実装、検証、ロールバック計画を体系化するスキル。
  Blue-Green/Canary/Rolling の適用判断と運用設計を整理する。

  Anchors:
  • Release It! / 適用: デプロイ安定性 / 目的: 本番運用の安全性
  • Continuous Delivery / 適用: 段階的リリース / 目的: リスク低減
  • Observability / 適用: 検証設計 / 目的: 監視による品質担保

  Trigger:
  Use when choosing deployment strategies, designing rollout plans, preparing rollback procedures, or validating deployment readiness.
  blue green, canary, rolling deployment, rollback, smoke test
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---
# deployment-strategies

## 概要

デプロイ戦略の選定から検証・ロールバックまでを一貫して支援する。

## ワークフロー

### Phase 1: 要件整理

**目的**: デプロイ要件と制約を整理する。

**アクション**:

1. `references/Level1_basics.md` で基本概念を確認する。
2. `assets/deployment-strategy-template.md` で要件を整理する。
3. `references/requirements-index.md` で要件整合を確認する。

**Task**: `agents/analyze-deployment-requirements.md` を参照

### Phase 2: 戦略設計

**目的**: デプロイパターンとロールバック戦略を設計する。

**アクション**:

1. `references/deployment-patterns.md` でパターンを比較する。
2. `references/rollback-strategies.md` で復旧方針を整理する。
3. `assets/deployment-runbook.md` を更新する。

**Task**: `agents/design-deployment-strategy.md` を参照

### Phase 3: 実装と準備

**目的**: ヘルスチェックとスモークテストを準備する。

**アクション**:

1. `assets/health-endpoint-template.ts` を確認する。
2. `assets/smoke-test-template.ts` を準備する。
3. `assets/rollback-checklist.md` で検証項目を整理する。

**Task**: `agents/implement-deployment-plan.md` を参照

### Phase 4: 検証と運用

**目的**: デプロイ前の検証と運用記録を残す。

**アクション**:

1. `scripts/health-check.mjs` で検証する。
2. `agents/validate-deployment-readiness.md` の観点で評価する。
3. `scripts/log_usage.mjs` で記録を更新する。

**Task**: `agents/validate-deployment-readiness.md` を参照

## Task仕様ナビ

| Task | 起動タイミング | 入力 | 出力 |
| --- | --- | --- | --- |
| analyze-deployment-requirements | Phase 1開始時 | 要件 | 要件メモ、制約一覧 |
| design-deployment-strategy | Phase 2開始時 | 要件メモ | デプロイ戦略、ロールバック方針 |
| implement-deployment-plan | Phase 3開始時 | 戦略メモ | 準備メモ、検証項目 |
| validate-deployment-readiness | Phase 4開始時 | 準備メモ | 検証レポート、改善提案 |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリを参照

## ベストプラクティス

### すべきこと

| 推奨事項 | 理由 |
| --- | --- |
| パターン選定理由を記録する | 追跡が容易になる |
| ロールバック手順を明文化 | 障害対応が早くなる |
| 検証項目を明確化 | リスクを減らせる |
| 監視指標を整理する | 影響評価ができる |

### 避けるべきこと

| 禁止事項 | 問題点 |
| --- | --- |
| パターン選定を感覚で決める | リスク判断が不明確 |
| 検証を省略する | 障害検知が遅れる |
| ロールバック未定義 | 復旧が難しくなる |
| 記録を残さない | 改善が継続しない |

## リソース参照

### scripts/（決定論的処理）

| スクリプト | 機能 |
| --- | --- |
| `scripts/health-check.mjs` | ヘルスチェック |
| `scripts/validate-skill.mjs` | スキル構造検証 |
| `scripts/log_usage.mjs` | 使用記録と評価メトリクス更新 |

### references/（詳細知識）

| リソース | パス | 読込条件 |
| --- | --- | --- |
| レベル1 基礎 | [references/Level1_basics.md](references/Level1_basics.md) | 要件整理時 |
| レベル2 実務 | [references/Level2_intermediate.md](references/Level2_intermediate.md) | 戦略設計時 |
| レベル3 応用 | [references/Level3_advanced.md](references/Level3_advanced.md) | 実装時 |
| レベル4 専門 | [references/Level4_expert.md](references/Level4_expert.md) | 検証時 |
| デプロイパターン | [references/deployment-patterns.md](references/deployment-patterns.md) | 選定時 |
| ヘルスチェック | [references/health-checks.md](references/health-checks.md) | 検証時 |
| ロールバック | [references/rollback-strategies.md](references/rollback-strategies.md) | 復旧計画時 |
| Railway運用 | [references/railway-deployment.md](references/railway-deployment.md) | Railway利用時 |
| 要求仕様索引 | [references/requirements-index.md](references/requirements-index.md) | 仕様確認時 |
| 旧スキル | [references/legacy-skill.md](references/legacy-skill.md) | 互換確認時 |

### assets/（テンプレート・素材）

| アセット | 用途 |
| --- | --- |
| `assets/deployment-runbook.md` | デプロイ手順 |
| `assets/rollback-checklist.md` | ロールバック確認 |
| `assets/health-endpoint-template.ts` | ヘルスチェック実装 |
| `assets/smoke-test-template.ts` | スモークテスト |
| `assets/deployment-strategy-template.md` | 戦略整理テンプレート |

### 運用ファイル

| ファイル | 目的 |
| --- | --- |
| `EVALS.json` | レベル評価・メトリクス管理 |
| `LOGS.md` | 実行ログの蓄積 |
| `CHANGELOG.md` | 改善履歴の記録 |
