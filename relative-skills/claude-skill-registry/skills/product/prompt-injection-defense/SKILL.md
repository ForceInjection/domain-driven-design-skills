---
name: prompt-injection-defense
description: |
  AIシステムへのプロンプトインジェクション攻撃を防ぎ、入力検証とコンテキスト分離の設計指針を提供するスキル。

  Anchors:
  • OWASP LLM Top 10 / 適用: LLMセキュリティ脅威モデリング / 目的: インジェクション攻撃の分類と防御パターン理解
  • Simon Willison's Prompt Injection Research / 適用: 実攻撃パターン分析 / 目的: 実世界の攻撃事例から防御戦略を導出
  • Defense in Depth principle / 適用: 多層防御設計 / 目的: 単一障害点の排除

  Trigger:
  Use when designing prompt injection defenses, implementing AI security measures, sanitizing user inputs for LLM systems, separating trusted and untrusted contexts, conducting security reviews for LLM applications, mitigating indirect prompt injection risks.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# プロンプトインジェクション対策

## 概要

AIシステムへのプロンプトインジェクション攻撃を防ぎ、入力検証とコンテキスト分離の設計指針を提供する。攻撃パターンの識別、防御メカニズムの選択、安全なプロンプト設計の実装をサポート。

## ワークフロー

### Phase 1: 脅威モデリング

**目的**: システムの攻撃面と脅威を特定

**アクション**:

1. システムアーキテクチャの信頼境界を特定
2. プロンプトインジェクション攻撃パターンを分類
3. 攻撃の実現可能性と影響度を評価
4. 優先度の高い脅威シナリオを文書化

**Task**: `agents/threat-modeling.md` を参照

### Phase 2: 防御設計

**目的**: 多層防御戦略の設計と実装パターン選択

**アクション**:

1. 脅威ごとの防御メカニズムを選択
2. 入力検証・出力エスケープ・プロンプト構造化を設計
3. コンテキスト分離と最小権限原則を適用
4. 実装ガイドラインを文書化

**Task**: `agents/defense-design.md` を参照

### Phase 3: 検証・評価

**目的**: セキュリティ設計の検証と改善

**アクション**:

1. `assets/defense-checklist.md` で設計を評価
2. `scripts/validate-defense.mjs` でコード検証
3. セキュリティレビューを実施
4. 改善推奨事項を文書化

**Task**: `agents/validate-defense.md` を参照

## Task仕様（ナビゲーション）

| Task             | 起動タイミング | 入力                             | 出力                       |
| ---------------- | -------------- | -------------------------------- | -------------------------- |
| threat-modeling  | Phase 1開始時  | システムアーキテクチャ、入力仕様 | 脅威モデル、攻撃パターン   |
| defense-design   | Phase 2開始時  | 脅威モデル                       | 防御設計書、実装ガイド     |
| validate-defense | Phase 3開始時  | 防御設計書                       | 検証レポート、改善推奨事項 |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリを参照

## ベストプラクティス

### すべきこと

| 推奨事項                           | 理由                     |
| ---------------------------------- | ------------------------ |
| システム全体の信頼境界を明確化     | 攻撃面を正確に把握       |
| 多層防御（defense-in-depth）を実装 | 単一障害点を排除         |
| 既知攻撃パターンへの対策を明示     | 見落としを防止           |
| セキュリティレビューを共有         | チーム全体で脆弱性を発見 |
| 最新の攻撃トレンドを定期確認       | 新種の攻撃に対応         |

### 避けるべきこと

| 禁止事項                                 | 問題点                 |
| ---------------------------------------- | ---------------------- |
| 単一の対策方法への依存                   | 防御層が薄くなる       |
| 信頼境界が曖昧なまま実装                 | 攻撃ベクトルを見落とす |
| 攻撃パターンと対策の対応関係が不明確     | セキュリティ検証困難   |
| 最新情報確認をスキップして古い前提で設計 | 新しい攻撃手法に脆弱   |

## リソース参照

### references/（詳細知識）

| リソース           | パス                                             | 読込条件               |
| ------------------ | ------------------------------------------------ | ---------------------- |
| 基本概念           | [references/basics.md](references/basics.md)     | 初回使用時・概念理解時 |
| 実践的防御パターン | [references/patterns.md](references/patterns.md) | 設計・実装時           |

### scripts/（決定論的処理）

| スクリプト             | 用途           | 使用例                                      |
| ---------------------- | -------------- | ------------------------------------------- |
| `validate-defense.mjs` | 防御実装の検証 | `node scripts/validate-defense.mjs <path>`  |
| `log_usage.mjs`        | 使用記録       | `node scripts/log_usage.mjs --result <...>` |

### assets/（テンプレート）

| アセット                   | 用途                       |
| -------------------------- | -------------------------- |
| `defense-checklist.md`     | セキュリティ評価項目       |
| `threat-model-template.md` | 脅威モデル文書テンプレート |

## 変更履歴

| Version | Date       | Changes                                        |
| ------- | ---------- | ---------------------------------------------- |
| 2.0.0   | 2026-01-02 | 18-skills.md仕様完全準拠版に再構築             |
| 1.2.0   | 2025-12-31 | Task仕様ナビテーブル追加、frontmatter統一      |
| 1.0.0   | 2025-12-24 | 初版：基本ワークフロー、ベストプラクティス定義 |
