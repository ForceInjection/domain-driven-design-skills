---
name: prioritization-frameworks
description: |
  優先順位付けフレームワークの専門スキル。
  MoSCoW法、RICE Scoring、Kano Modelを用いて、限られたリソースで最大の価値を提供するための意思決定を支援します。

  Anchors:
  • 『Inspired』（Marty Cagan） / 適用: プロダクト優先順位 / 目的: 価値最大化
  • Intercom RICE Scoringガイド / 適用: 定量的スコアリング / 目的: データドリブンな意思決定
  • Kano Model理論（Noriaki Kano） / 適用: 顧客満足度分析 / 目的: 戦略的投資判断

  Trigger:
  Use when prioritizing features, requirements, backlog items, or strategic initiatives. Apply to sprint planning, release planning, roadmap development, feature evaluation, or resource allocation decisions.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# 優先順位付けフレームワークスキル

## 概要

MoSCoW法、RICE Scoring、Kano Model、Value vs Effort、Weighted Scoringなどの優先順位付けフレームワークを提供します。
客観的な基準に基づいて、限られたリソースで最大の価値を提供するための意思決定手法を体系化し、プロダクト開発やプロジェクト管理における優先順位付けを支援します。

詳細な手順や背景は `references/` ディレクトリのガイドを参照してください。

## ワークフロー

### Phase 1: フレームワーク選択

**目的**: タスクの目的と前提条件を明確にし、適用するフレームワークを特定

**アクション**:

1. 優先順位付けの対象（フィーチャー、バグ修正、技術債など）を確認
2. ステークホルダーと制約条件（リソース、予算、時間）を把握
3. 使用するフレームワークを決定
   - MoSCoW法：要件の分類と優先度決定
   - RICE Scoring：定量的なスコアリング
   - Kano Model：顧客満足度分析
   - Value vs Effort：迅速な優先順位付け
   - Weighted Scoring：カスタム評価基準
4. `agents/select-framework.md` のタスク仕様を参照してフレームワーク選択を実行
5. `references/basics.md` でフレームワークの基本を確認

**参照**:

- Task仕様：`agents/select-framework.md`
- 基礎知識：`references/basics.md`

### Phase 2: スコアリング適用

**目的**: 選定したフレームワークに従って優先順位付けを実施

**アクション**:

1. `agents/apply-scoring.md` のタスク仕様を参照してスコアリングを実行
2. 評価基準を定義し、候補項目を定量・定性的に評価
   - MoSCoW法：Must/Should/Could/Won'tに分類
   - RICE Scoring：Reach、Impact、Confidence、Effortを評価
   - Kano Model：Basic/Performance/Excitement/Indifferent/Reverseに分類
3. 定期的に評価結果をレビューし、判断ポイントをドキュメント化
4. フレームワーク別のテンプレートを活用
   - MoSCoW法：`assets/moscow-template.md`
   - RICE Scoring：`assets/rice-scoring-template.md`
   - Kano Model：`assets/kano-model-template.md`
5. `references/patterns.md` で実装パターンを確認

**参照**:

- Task仕様：`agents/apply-scoring.md`
- 詳細知識：`references/patterns.md`（RICE、Kano）
- テンプレート：`assets/*.md`

### Phase 3: 検証と記録

**目的**: 成果物の検証と実行記録の保存

**アクション**:

1. `agents/validate-priorities.md` のタスク仕様を参照して検証を実行
2. 決定理由と評価プロセスをドキュメント化
3. ステークホルダーとの合意を取得
4. 異論や懸念事項を記録
5. 再評価スケジュールを設定
6. `scripts/log_usage.mjs` を実行して記録を保存

**参照**:

- Task仕様：`agents/validate-priorities.md`
- 記録スクリプト：`scripts/log_usage.mjs`

## Task仕様ナビ

| Task仕様書                      | 用途                   | 適用シーン                         |
| ------------------------------- | ---------------------- | ---------------------------------- |
| `agents/select-framework.md`    | フレームワーク選択     | プロジェクト開始時、計画フェーズ   |
| `agents/apply-scoring.md`       | スコアリング適用と評価 | バックログ整理、ロードマップ策定   |
| `agents/validate-priorities.md` | 優先順位検証と合意形成 | レビュー時、ステークホルダー承認時 |

### フレームワーク別ガイド

| フレームワーク   | 用途                         | 適用シーン                     | リソース                 |
| ---------------- | ---------------------------- | ------------------------------ | ------------------------ |
| MoSCoW法         | 要件の分類と優先度決定       | スプリント計画、リリース計画   | `references/basics.md`   |
| RICE Scoring     | 定量的なスコアリング         | ロードマップ策定、複数案の比較 | `references/patterns.md` |
| Kano Model       | 顧客満足度と要件の関係分析   | 要件定義、機能企画             | `references/patterns.md` |
| Value vs Effort  | シンプルな2軸分析            | 迅速な優先順位付け             | `references/basics.md`   |
| Weighted Scoring | カスタム重み付けスコアリング | 複数基準の統合評価             | `references/basics.md`   |

## ベストプラクティス

### すべきこと

- 優先順位付けの前にステークホルダー合意を得る
- 複数のフレームワークを比較検討し、最適なものを選択する
- 定量と定性の両面から評価を実施する
- 評価基準と結果を透明性高くドキュメント化する
- 定期的に優先順位を見直し、変更理由を記録する
- データに基づいて客観的に判断する
- フレームワーク別のテンプレートを活用する

### 避けるべきこと

- 単一の視点のみで優先順位を決定する（HiPPO）
- フレームワークに無理やり当てはめようとする
- 評価基準を明確にせずに判断する
- 一度決めた優先順位を見直さない
- ステークホルダーとの合意を得ずに独断で決定する
- 主観的な評価のみに依存する
- Must haveを過剰に設定する（MoSCoW法）

## リソース参照

### Task仕様書（agents/）

| Task仕様書                      | 目的                       | 実行タイミング     |
| ------------------------------- | -------------------------- | ------------------ |
| `agents/select-framework.md`    | 最適なフレームワークの選択 | プロジェクト開始時 |
| `agents/apply-scoring.md`       | スコアリング実施と定量評価 | バックログ整理時   |
| `agents/validate-priorities.md` | 優先順位の検証と合意形成   | レビュー・承認時   |

### ナレッジベース（references/）

| リソース                 | 内容                                                                      | 対象レベル |
| ------------------------ | ------------------------------------------------------------------------- | ---------- |
| `references/basics.md`   | MoSCoW法、Value vs Effort、Weighted Scoringの詳細、フレームワーク選択基準 | 初級〜中級 |
| `references/patterns.md` | RICE Scoring、Kano Modelの詳細、実装パターン、アンチパターン              | 中級〜上級 |

### アセット（assets/）

| アセット                          | 用途                             | 関連Task仕様書            |
| --------------------------------- | -------------------------------- | ------------------------- |
| `assets/moscow-template.md`       | MoSCoW分類結果テンプレート       | `agents/apply-scoring.md` |
| `assets/rice-scoring-template.md` | RICE Scoreランキングテンプレート | `agents/apply-scoring.md` |
| `assets/kano-model-template.md`   | Kanoカテゴリ分類テンプレート     | `agents/apply-scoring.md` |

### スクリプト（scripts/）

| スクリプト              | 用途               | 実行方法                     |
| ----------------------- | ------------------ | ---------------------------- |
| `scripts/log_usage.mjs` | 使用記録と自動評価 | `node scripts/log_usage.mjs` |

## 参照書籍

- 『Inspired: How to Create Tech Products Customers Love』（Marty Cagan）：プロダクト価値の最大化
- Intercom社のRICE Scoringガイド：定量的優先順位付け手法
- Noriaki Kano研究論文：顧客満足度と機能の関係分析
- 『The Pragmatic Programmer』（Andrew Hunt, David Thomas）：実践的改善と品質維持

## 変更履歴

| Version | Date       | Changes                                                                                                               |
| ------- | ---------- | --------------------------------------------------------------------------------------------------------------------- |
| 3.0.0   | 2026-01-02 | 18-skills.md仕様完全準拠：references/を2ファイルに統合、agents/を3つに集約、assets/追加、フレームワーク別知識を外部化 |
| 2.0.0   | 2025-01-02 | 18-skills.md仕様準拠：Task仕様書を3つに再編成、references/を2ファイルに簡素化、assets/追加、ワークフロー明確化        |
| 1.0.1   | 2025-12-31 | 18-skills.md仕様に準拠：YAMLフロントマター改善、Task仕様ナビ追加、リソース参照リニューアル、ベストプラクティス拡充    |
| 1.0.0   | 2025-12-24 | Spec alignment and required artifacts added                                                                           |
