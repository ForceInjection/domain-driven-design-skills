---
name: vitest-advanced
description: |
  Vitestの高度な機能を活用したテスト実装スキル。
  並列実行、カバレッジ最適化、非同期テスト処理、モック戦略を実装します。

  Anchors:
  • 『Test-Driven Development: By Example』（Kent Beck） / 適用: テスト設計 / 目的: 品質向上

  Trigger:
  Use when optimizing Vitest tests, configuring parallel execution, improving coverage, implementing async testing patterns, or designing mock strategies.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Vitest Advanced

## 概要

Vitestの高度な機能と最適化パターンに特化したスキル。並列テスト実行による高速化、カバレッジ最適化による品質向上、非同期テスト処理、包括的なモック戦略を実装するための体系的なガイダンスを提供します。Red-Green-Refactor循環を中心に、テスト駆動開発の最高実践を実現します。

詳細な手順や背景は各レベルガイドと専門リソースを参照してください。

## エージェント構成

| エージェント             | 役割             | 主な機能                      |
| ------------------------ | ---------------- | ----------------------------- |
| test-structure-architect | テスト構造設計   | ファイル組織化、命名規則      |
| coverage-optimizer       | カバレッジ最適化 | 分析、改善提案、閾値設定      |
| mock-strategist          | モック戦略       | テストダブル選定、vi.mock活用 |
| async-test-specialist    | 非同期テスト     | Promise、タイマー、イベント   |

## ワークフロー

### Phase 1: 目的と前提の整理

**目的**: タスクの目的と前提条件を明確にし、適切なリソースを特定する

**アクション**:

1. `references/Level1_basics.md` で基礎概念を確認
2. `references/Level2_intermediate.md` で実務パターンを把握
3. タスク内容に基づいて必要なスペシャライズドリソース（async-testing、coverage-optimization等）を特定
4. テンプレート（test-file-template.ts）の準備状況を確認

### Phase 2: スキル適用と実装

**目的**: スキルの指針に従って高度なテスト機能を実装する

**アクション**:

1. 適切なレベル（Level3_advanced.md / Level4_expert.md）を参照しながら実装
2. 関連リソースやテンプレートを参照しながら作業を実施
3. モックパターン、非同期処理、並列化戦略を適用
4. 重要な判断点や技術的ポイントをドキュメント化

### Phase 3: 検証、最適化と記録

**目的**: 成果物の検証と実行記録の保存、継続的な改善

**アクション**:

1. `scripts/validate-skill.mjs` でスキル構造と実装を確認
2. `scripts/coverage-analyzer.mjs` でカバレッジ分析を実施
3. 成果物がパフォーマンス要件に合致するか確認
4. `scripts/log_usage.mjs` を実行して記録を残す

## Task仕様ナビゲーション

| タスク種別     | 該当リソース                                 | 主要スクリプト        | テンプレート          | 説明                             |
| -------------- | -------------------------------------------- | --------------------- | --------------------- | -------------------------------- |
| 基本テスト構造 | Level1_basics.md, test-structure.md          | validate-skill.mjs    | test-file-template.ts | テストファイルの基本構成         |
| 並列実行設定   | Level2_intermediate.md, performance-tips.md  | validate-skill.mjs    | -                     | 複数テスト並列実行の最適化       |
| カバレッジ分析 | Level3_advanced.md, coverage-optimization.md | coverage-analyzer.mjs | -                     | テストカバレッジの測定と最適化   |
| 非同期テスト   | Level2_intermediate.md, async-testing.md     | validate-skill.mjs    | test-file-template.ts | async/await、Promise処理         |
| モック戦略     | Level3_advanced.md, mocking-patterns.md      | validate-skill.mjs    | -                     | vi.fn()、vi.mock()の実装         |
| パフォーマンス | Level4_expert.md, performance-tips.md        | coverage-analyzer.mjs | -                     | テスト実行速度の最適化           |
| 高度な手法     | Level4_expert.md                             | log_usage.mjs         | -                     | エキスパートレベルの実装パターン |

## ベストプラクティス

### すべきこと ✓

- **段階的な学習**: Level1→Level2→Level3→Level4の順序で進める
- **リソース活用**: タスク種別に応じた専門リソースを参照する
- **テンプレート利用**: test-file-template.ts から開始して時間を短縮する
- **検証実施**: validate-skill.mjs でコード品質を継続的に確認する
- **カバレッジ測定**: coverage-analyzer.mjs で品質メトリクスを追跡する
- **非同期対応**: async-testing.md のパターンに従い信頼性を確保する
- **モックの適切化**: mocking-patterns.md で過度なモック化を避ける
- **ドキュメント化**: 複雑なテストロジックには説明コメントを追加する

### 避けるべきこと ✗

- **スキップしない**: 基礎レベルをスキップして応用レベルに進まない
- **無関連リソース**: タスクに無関係なリソースは参照しない
- **過度なモック**: 実装の詳細までモック化しすぎない
- **低カバレッジ**: 重要コード部分のカバレッジを低いままにしない
- **非同期無視**: 非同期処理の本質的な複雑性を軽視しない
- **並列化リスク**: 並列実行によるテスト干渉を検証なしに有効化しない
- **検証スキップ**: 本番運用前の検証フェーズを省略しない

## リソース参照

### レベル別ガイド

- **`references/Level1_basics.md`**: Vitest基礎、テスト基本構造、簡単なテストケース作成
- **`references/Level2_intermediate.md`**: 実務的なテスト手法、非同期テスト基礎、簡単なモック
- **`references/Level3_advanced.md`**: 高度なモック戦略、カバレッジ最適化、パフォーマンス改善
- **`references/Level4_expert.md`**: エキスパートレベルのパターン、複合的なテスト設計、業界最高実践

### スペシャライズドリソース

- **`references/async-testing.md`**: 非同期コード（Promise、async/await）のテスト方法
- **`references/coverage-optimization.md`**: カバレッジ分析と最適化戦略
- **`references/mocking-patterns.md`**: モック・スタブ・スパイの使い分けと実装パターン
- **`references/performance-tips.md`**: テスト実行速度とリソース最適化
- **`references/test-structure.md`**: テストファイル組織と命名規則
- **`references/legacy-skill.md`**: 旧SKILL.mdの全文、バージョン管理用

### スクリプトと自動化

- **`scripts/coverage-analyzer.mjs`**: カバレッジ分析と可視化
  ```bash
  node .claude/skills/vitest-advanced/scripts/coverage-analyzer.mjs --help
  ```
- **`scripts/validate-skill.mjs`**: スキル構造と実装品質の検証
  ```bash
  node .claude/skills/vitest-advanced/scripts/validate-skill.mjs --help
  ```
- **`scripts/log_usage.mjs`**: 使用記録・自動評価の実施
  ```bash
  node .claude/skills/vitest-advanced/scripts/log_usage.mjs --help
  ```

### テンプレート

- **`assets/test-file-template.ts`**: テストファイルの標準テンプレート
  ```bash
  cat .claude/skills/vitest-advanced/assets/test-file-template.ts
  ```

## 変更履歴

| Version | Date       | Changes                                                              |
| ------- | ---------- | -------------------------------------------------------------------- |
| 1.1.0   | 2025-12-31 | 18-skills.md仕様への全面更新、Task仕様ナビ追加、リソース参照の構造化 |
| 1.0.0   | 2025-12-24 | 仕様準拠と必要なアーティファクト追加                                 |
