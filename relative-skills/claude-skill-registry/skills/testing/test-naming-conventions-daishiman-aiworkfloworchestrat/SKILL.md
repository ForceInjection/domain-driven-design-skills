---
name: test-naming-conventions
description: |
  テスト命名規則を設計し、可読性と一貫性を維持するスキル。
  ファイル名、describe/it 構造、シナリオ表現を統一し、チーム運用を支援する。

  Anchors:
  • xUnit Test Patterns / 適用: 命名規則設計 / 目的: 可読性の向上
  • Specification by Example / 適用: シナリオ命名 / 目的: 意図の共有

  Trigger:
  Use when defining, reviewing, or enforcing test naming conventions and file structures.
  test naming, describe/it, file structure
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Test Naming Conventions

## 概要

テストの命名規則を体系化し、チーム全体で読みやすいテストを維持するためのスキル。ファイル構成、describe/it の構造、シナリオ名を統一し、レビュー効率と保守性を高める。

---

## ワークフロー

### Phase 1: 命名要件の整理

**目的**: プロジェクトの規模とテスト目的に合わせて命名要件を整理する

**アクション**:

1. テストフレームワークと対象範囲を確認する
2. 既存の命名規則と課題を整理する
3. 必須要件と禁止事項を定義する

**Task**: `agents/naming-requirements.md` を参照

### Phase 2: 規則設計と適用

**目的**: 命名パターンと構造を設計し、テストに適用する

**アクション**:

1. 命名パターンを選定する
2. describe/it 構造とファイル命名を設計する
3. テンプレートで規則を文書化する

**Task**: `agents/naming-pattern-design.md` を参照

### Phase 3: 検証と運用定着

**目的**: 命名規則の遵守状況を検証し、運用に定着させる

**アクション**:

1. 自動チェックで逸脱を検出する
2. レビュー観点を整理して共有する
3. 実行記録を残す

**Task**: `agents/naming-enforcement-review.md` を参照

---

## Task仕様ナビ

| Task | 起動タイミング | 入力 | 出力 |
| --- | --- | --- | --- |
| naming-requirements | Phase 1 開始時 | プロジェクト情報 | 命名要件メモ |
| naming-pattern-design | Phase 2 開始時 | 命名要件/制約 | 命名規則ガイド |
| naming-enforcement-review | Phase 3 開始時 | チェック結果/レビュー | 改善レポート |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリを参照

---

## ベストプラクティス

### すべきこと

| 推奨事項 | 理由 |
| --- | --- |
| 命名の目的と対象範囲を先に定義する | 規則の過不足を防ぐため |
| describe/it の階層を固定する | 役割が明確になるため |
| テンプレートで運用ルールを共有する | チーム合意を維持するため |
| 自動チェックで逸脱を検知する | 継続的な品質維持のため |

### 避けるべきこと

| 禁止事項 | 問題点 |
| --- | --- |
| 曖昧な動詞や主語を使う | テスト意図が伝わらない |
| 過度に長いテスト名 | 可読性が低下する |
| ファイル命名が不統一 | 探索性が下がる |

---

## リソース参照

### scripts/（決定論的処理）

| スクリプト | 機能 |
| --- | --- |
| `scripts/test-name-linter.mjs` | 命名規則の逸脱を検出する |
| `scripts/validate-skill.mjs` | スキル構造と必須成果物を検証する |
| `scripts/log_usage.mjs` | 実行記録を保存する |

### references/（詳細知識）

| リソース | パス | 読込条件 |
| --- | --- | --- |
| 基礎概念 | [references/Level1_basics.md](references/Level1_basics.md) | Phase 1 で参照 |
| 実務パターン | [references/Level2_intermediate.md](references/Level2_intermediate.md) | Phase 2 で参照 |
| 応用戦略 | [references/Level3_advanced.md](references/Level3_advanced.md) | 高度化時に参照 |
| エキスパート | [references/Level4_expert.md](references/Level4_expert.md) | 大規模対応時に参照 |
| 命名パターン | [references/naming-patterns.md](references/naming-patterns.md) | Phase 2 で参照 |
| describe 構造 | [references/describe-structure.md](references/describe-structure.md) | Phase 2 で参照 |
| ファイル構成 | [references/file-organization.md](references/file-organization.md) | Phase 2 で参照 |

### assets/（テンプレート・素材）

| アセット | 用途 |
| --- | --- |
| `assets/naming-guide.md` | 命名規則ガイドのテンプレート |

## 変更履歴

| Version | Date | Changes |
| --- | --- | --- |
| 2.0.0 | 2026-01-02 | Task仕様と検証フローを再設計し、参照を整理 |
| 1.0.0 | 2025-12-24 | 初期バージョン |
