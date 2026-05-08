---
name: command-agent-skill-integration
description: |
  コマンド/エージェント/スキルの統合設計を整理し、連携パターンと複合ワークフローを支援するスキル。
  起動パターン、参照パターン、統合検証の手順を一貫して整理する。

  Anchors:
  • The Pragmatic Programmer (Andrew Hunt, David Thomas) / 適用: 連携手順の設計 / 目的: 再現性の確保
  • Multi-Agent Systems (Wooldridge) / 適用: エージェント連携 / 目的: 協調設計の整理
  • Workflow Patterns (van der Aalst) / 適用: 複合ワークフロー / 目的: 実行フローの明確化

  Trigger:
  Use when integrating commands with agents and skills, designing composite workflows, or validating integration rules.
  command agent skill integration, composite workflow, agent invocation, skill reference
---
# command-agent-skill-integration

## 概要

コマンドとエージェント、スキルの連携パターンを整理し、統合フローの設計と検証を行う。

## ワークフロー

### Phase 1: 要件整理

**目的**: 統合対象と連携要件を明確化する。

**アクション**:

1. 統合対象（コマンド/エージェント/スキル）を整理する。
2. 起動パターンと参照パターンを選定する。
3. 参照すべきアーキテクチャ資料を確認する。

**Task**: `agents/analyze-integration-requirements.md` を参照

### Phase 2: 統合設計

**目的**: 連携パターンとワークフロー設計を具体化する。

**アクション**:

1. コマンド→エージェント/スキルの連携フローを設計する。
2. 複合ワークフローをテンプレートで整理する。
3. 例外ケースとガードレールを定義する。

**Task**: `agents/design-integration-flow.md` を参照

### Phase 3: 検証と記録

**目的**: 統合ルールを検証し、記録を残す。

**アクション**:

1. 統合検証スクリプトで整合性を確認する。
2. 検証結果と改善点を記録する。
3. ログと評価情報を更新する。

**Task**: `agents/validate-integration.md` を参照

## Task仕様ナビ

| Task | 起動タイミング | 入力 | 出力 |
| --- | --- | --- | --- |
| analyze-integration-requirements | Phase 1開始時 | 統合対象/要件 | 要件整理メモ、参照一覧 |
| design-integration-flow | Phase 2開始時 | 要件整理メモ | 連携フロー設計、テンプレ適用案 |
| validate-integration | Phase 3開始時 | 連携フロー設計 | 検証レポート、改善方針 |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリを参照

## ベストプラクティス

### すべきこと

| 推奨事項 | 理由 |
| --- | --- |
| 連携パターンを明確に選定する | 連携ミスを防ぐため |
| テンプレートを活用する | 実装の一貫性が保てるため |
| 統合検証を実行する | 逸脱を検知するため |

### 避けるべきこと

| 禁止事項 | 問題点 |
| --- | --- |
| 連携仕様を省略する | 実装がブレる |
| 例外処理を後回しにする | 障害時に対応できない |
| 記録を残さない | 改善が続かない |

## リソース参照

### scripts/（決定論的処理）

| スクリプト | 機能 |
| --- | --- |
| `scripts/validate-integration.mjs` | 統合パターン検証 |
| `scripts/log_usage.mjs` | 使用記録と評価メトリクス更新 |
| `scripts/validate-skill.mjs` | スキル構造の検証 |

### references/（詳細知識）

| リソース | パス | 読込条件 |
| --- | --- | --- |
| Level1 基礎 | [references/Level1_basics.md](references/Level1_basics.md) | 初回整理時 |
| Level2 実務 | [references/Level2_intermediate.md](references/Level2_intermediate.md) | 連携設計時 |
| Level3 応用 | [references/Level3_advanced.md](references/Level3_advanced.md) | 詳細設計時 |
| Level4 専門 | [references/Level4_expert.md](references/Level4_expert.md) | 改善ループ時 |
| 起動パターン | [references/command-to-agent-patterns.md](references/command-to-agent-patterns.md) | 起動設計時 |
| スキル参照 | [references/command-to-skill-patterns.md](references/command-to-skill-patterns.md) | 参照設計時 |
| 複合ワークフロー | [references/composite-workflows.md](references/composite-workflows.md) | 複合設計時 |
| Trinity構成 | [references/trinity-architecture.md](references/trinity-architecture.md) | 構成確認時 |
| 旧スキル | [references/legacy-skill.md](references/legacy-skill.md) | 互換確認時 |

### assets/（テンプレート・素材）

| アセット | 用途 |
| --- | --- |
| `assets/agent-invocation-template.md` | エージェント起動テンプレート |
| `assets/skill-reference-template.md` | スキル参照テンプレート |
| `assets/composite-workflow-template.md` | 複合ワークフローテンプレート |

### 運用ファイル

| ファイル | 目的 |
| --- | --- |
| `EVALS.json` | レベル評価・メトリクス管理 |
| `LOGS.md` | 実行ログの蓄積 |
| `CHANGELOG.md` | 改善履歴の記録 |
