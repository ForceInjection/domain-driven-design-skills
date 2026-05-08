---
name: test-doubles
description: |
  テストダブルの選択・設計・検証を一貫して整理するスキル。
  依存関係の分離と検証戦略を統一し、テストの意図と可読性を高める。

  Anchors:
  • Test-Driven Development: By Example / 適用: テストダブル選択 / 目的: テスト意図の明確化
  • xUnit Test Patterns / 適用: テストパターン / 目的: ダブル設計の一貫性

  Trigger:
  Use when choosing, designing, or validating test doubles such as mocks, stubs, fakes, or spies.
  test doubles, mock, stub, fake, spy
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Test Doubles

## 概要

Mock/Stub/Fake/Spy の使い分けを明確にし、テスト意図に沿った実装と検証を支援するスキル。依存関係の種類と検証目的に基づき、最適なダブル選択と実装手順を整理する。

---

## ワークフロー

### Phase 1: ダブル選定の前提整理

**目的**: テスト目的と依存関係の性質を整理し、選定基準を定義する

**アクション**:

1. テスト対象の依存関係を分類する
2. 状態検証/振る舞い検証の目的を明確化する
3. 選定基準と禁止事項を整理する

**Task**: `agents/double-selection-analysis.md` を参照

### Phase 2: 実装設計とパターン適用

**目的**: 選定基準に沿ってテストダブルの実装方針を設計する

**アクション**:

1. Mock/Stub/Fake/Spy のパターンを選択する
2. 実装粒度と責務を決定する
3. テンプレートを用いて実装計画を作成する

**Task**: `agents/double-implementation-design.md` を参照

### Phase 3: 検証と品質レビュー

**目的**: ダブルの使い分けと検証戦略の妥当性を確認する

**アクション**:

1. 選定基準と実装の整合性を検証する
2. 過剰なモック化やアンチパターンを確認する
3. 実行記録を残す

**Task**: `agents/double-verification.md` を参照

---

## Task仕様ナビ

| Task | 起動タイミング | 入力 | 出力 |
| --- | --- | --- | --- |
| double-selection-analysis | Phase 1 開始時 | テスト目的/依存関係 | 選定基準メモ |
| double-implementation-design | Phase 2 開始時 | 選定基準/制約 | 実装設計書 |
| double-verification | Phase 3 開始時 | 実装結果/テストログ | 検証レポート |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリを参照

---

## ベストプラクティス

### すべきこと

| 推奨事項 | 理由 |
| --- | --- |
| 依存関係の性質を先に整理する | ダブル選択の誤りを防ぐため |
| 検証目的を明文化する | 状態/振る舞いの混在を防ぐため |
| テンプレートで実装計画を残す | 実装の一貫性を保つため |
| 過剰なモック化を避ける | テストの信頼性を維持するため |

### 避けるべきこと

| 禁止事項 | 問題点 |
| --- | --- |
| 目的なしにモックを導入する | テストが意図不明になる |
| 1つのダブルに複数責務を持たせる | 変更に弱くなる |
| 実装詳細に依存した検証を行う | テストが壊れやすくなる |

---

## リソース参照

### scripts/（決定論的処理）

| スクリプト | 機能 |
| --- | --- |
| `scripts/test-double-analyzer.mjs` | テストダブルの品質観点を点検する |
| `scripts/validate-skill.mjs` | スキル構造と必須成果物を検証する |
| `scripts/log_usage.mjs` | 実行記録を保存する |

### references/（詳細知識）

| リソース | パス | 読込条件 |
| --- | --- | --- |
| 基礎概念 | [references/Level1_basics.md](references/Level1_basics.md) | Phase 1 で参照 |
| 実務パターン | [references/Level2_intermediate.md](references/Level2_intermediate.md) | Phase 2 で参照 |
| 応用戦略 | [references/Level3_advanced.md](references/Level3_advanced.md) | 高度化時に参照 |
| エキスパート | [references/Level4_expert.md](references/Level4_expert.md) | 大規模対応時に参照 |
| 種類一覧 | [references/types-overview.md](references/types-overview.md) | 選定時に参照 |
| Mock パターン | [references/mock-patterns.md](references/mock-patterns.md) | Mock 設計時に参照 |
| Stub パターン | [references/stub-patterns.md](references/stub-patterns.md) | Stub 設計時に参照 |
| Fake パターン | [references/fake-patterns.md](references/fake-patterns.md) | Fake 設計時に参照 |
| 検証戦略 | [references/verification-strategies.md](references/verification-strategies.md) | Phase 3 で参照 |

### assets/（テンプレート・素材）

| アセット | 用途 |
| --- | --- |
| `assets/test-double-selection.md` | 選定基準と実装計画のテンプレート |

## 変更履歴

| Version | Date | Changes |
| --- | --- | --- |
| 2.0.0 | 2026-01-02 | Task仕様を再設計し、参照整理と検証フローを刷新 |
| 1.1.0 | 2025-12-31 | 18-skills.md仕様準拠 | 
| 1.0.0 | 2025-12-24 | 初期バージョン |
