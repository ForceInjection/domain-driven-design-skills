---
name: acceptance-criteria-writing
description: |
  Given-When-Then 形式の受け入れ基準を整理し、テスト可能な完了条件の定義を支援するスキル。
  要件の明確化、シナリオ設計、検証手順を一貫して整理する。

  Anchors:
  • Software Requirements (Karl Wiegers) / 適用: 要件分析・仕様化 / 目的: テスト可能な要件定義の手法
  • BDD in Action (John Ferguson Smart) / 適用: Given-When-Thenパターン / 目的: 振る舞い駆動開発の基盤

  Trigger:
  Use when defining acceptance criteria, user story specifications, or testable requirements.
  acceptance criteria, user story, GWT, Given-When-Then, testable requirements, definition of done
---
# acceptance-criteria-writing

## 概要

Given-When-Then 形式の受け入れ基準を整理し、テスト可能な完了条件の定義を支援する。

## ワークフロー

### Phase 1: 要件整理

**目的**: 受け入れ基準の前提と要件を明確化する。

**アクション**:

1. ユーザーストーリーと目的を整理する。
2. 前提条件と制約を洗い出す。
3. 参照ガイドとテンプレートを確認する。

**Task**: `agents/analyze-criteria-requirements.md` を参照

### Phase 2: 基準設計

**目的**: Given-When-Then 形式の基準を設計する。

**アクション**:

1. 正常系とエッジケースのシナリオを整理する。
2. テスト可能性の観点で基準を設計する。
3. テンプレートで表現を統一する。

**Task**: `agents/design-acceptance-criteria.md` を参照

### Phase 3: 検証と記録

**目的**: 受け入れ基準を検証し、記録を残す。

**アクション**:

1. 検証スクリプトで品質を確認する。
2. 検証結果と改善点を整理する。
3. ログと評価情報を更新する。

**Task**: `agents/validate-acceptance-criteria.md` を参照

## Task仕様ナビ

| Task | 起動タイミング | 入力 | 出力 |
| --- | --- | --- | --- |
| analyze-criteria-requirements | Phase 1開始時 | 要件/制約 | 要件整理メモ、前提一覧 |
| design-acceptance-criteria | Phase 2開始時 | 要件整理メモ | 受け入れ基準、シナリオ一覧 |
| validate-acceptance-criteria | Phase 3開始時 | 受け入れ基準 | 検証レポート、改善方針 |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリを参照

## ベストプラクティス

### すべきこと

| 推奨事項 | 理由 |
| --- | --- |
| Given/When/Then を明確に分ける | 検証可能性が高まるため |
| 正常系とエッジケースを分ける | 抜け漏れが減るため |
| 検証と記録を実施する | 改善が継続できるため |

### 避けるべきこと

| 禁止事項 | 問題点 |
| --- | --- |
| 曖昧な表現を使う | テストが困難になる |
| 実装方法を指定する | 要件が硬直化する |
| 記録を残さない | 改善が続かない |

## リソース参照

### scripts/（決定論的処理）

| スクリプト | 機能 |
| --- | --- |
| `scripts/validate-acceptance-criteria.mjs` | 受け入れ基準の品質検証 |
| `scripts/log_usage.mjs` | 使用記録と評価メトリクス更新 |
| `scripts/validate-skill.mjs` | スキル構造の検証 |

### references/（詳細知識）

| リソース | パス | 読込条件 |
| --- | --- | --- |
| レベル1 基礎 | [references/Level1_basics.md](references/Level1_basics.md) | 初回整理時 |
| レベル2 実務 | [references/Level2_intermediate.md](references/Level2_intermediate.md) | 実務適用時 |
| レベル3 応用 | [references/Level3_advanced.md](references/Level3_advanced.md) | 複雑要件時 |
| レベル4 専門 | [references/Level4_expert.md](references/Level4_expert.md) | 改善ループ時 |
| テスト可能性 | [references/testability-guide.md](references/testability-guide.md) | 4特性確認時 |
| GWTパターン | [references/gwt-patterns.md](references/gwt-patterns.md) | パターン選定時 |
| エッジケース | [references/edge-case-patterns.md](references/edge-case-patterns.md) | 例外設計時 |

### assets/（テンプレート・素材）

| アセット | 用途 |
| --- | --- |
| `assets/acceptance-criteria-template.md` | 受け入れ基準テンプレート |

### 運用ファイル

| ファイル | 目的 |
| --- | --- |
| `EVALS.json` | レベル評価・メトリクス管理 |
| `LOGS.md` | 実行ログの蓄積 |
| `CHANGELOG.md` | 改善履歴の記録 |
