---
name: security-configuration-review
description: |
  セキュリティ関連設定のレビュー、構成監査、セキュリティベースライン確認を統一的に実施するスキル。脅威モデリングに基づいた設定評価とベストプラクティスの適用を通じて、アプリケーションのセキュリティ態勢を向上させます。

  Anchors:
  • 『Web Application Security』（Andrew Hoffman） / 適用: セキュリティ設定監査 / 目的: セキュリティ態勢の向上

  Trigger:
  セキュリティ設定レビュー、構成監査、セキュリティベースライン確認時に使用。セキュリティヘッダー設定、CORS設定、認証・認可の監査などの場面で自動選択対象。
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Security Configuration Review

## 概要

セキュリティ関連設定のレビュー、構成監査、セキュリティベースライン確認を統一的に実施するスキルです。脅威モデリングに基づいた設定評価とベストプラクティスの適用を通じて、アプリケーションのセキュリティ態勢を向上させます。

本スキルは以下を対象とします：

- **セキュリティヘッダー** (CSP, X-Frame-Options, X-Content-Type-Options など)
- **認証・認可設定** (JWT, CORS, OAuth2 フロー)
- **暗号化と通信セキュリティ** (TLS/SSL, 鍵管理)
- **サードパーティ依存関係** (ライブラリのセキュリティリスク)
- **コンプライアンス要件** (GDPR, PCI-DSS など)

詳細な手順や背景は `references/Level1_basics.md` と `references/Level2_intermediate.md` を参照してください。

## ワークフロー

### Phase 1: 目的と前提の整理

**目的**: タスクの目的と前提条件を明確にする

**アクション**:

1. `references/Level1_basics.md` と `references/Level2_intermediate.md` を確認
2. 必要な references/scripts/templates を特定

### Phase 2: スキル適用

**目的**: スキルの指針に従って具体的な作業を進める

**アクション**:

1. 関連リソースやテンプレートを参照しながら作業を実施
2. 重要な判断点をメモとして残す

### Phase 3: 検証と記録

**目的**: 成果物の検証と実行記録の保存

**アクション**:

1. `scripts/validate-skill.mjs` でスキル構造を確認
2. 成果物が目的に合致するか確認
3. `scripts/log_usage.mjs` を実行して記録を残す

## Task仕様ナビ

| Task                       | 対応リソース                          | 主な検査項目                         | 推奨スクリプト               |
| -------------------------- | ------------------------------------- | ------------------------------------ | ---------------------------- |
| セキュリティヘッダー監査   | `references/security-headers-guide.md` | CSP, X-Frame-Options, HSTS 等        | `check-security-headers.mjs` |
| CORS設定レビュー           | `assets/cors-config-template.js`   | オリジン検証, メソッド制限, 認証情報 | -                            |
| 認証・認可監査             | `references/Level2_intermediate.md`    | JWT トークン, Session 管理, RBAC     | -                            |
| 依存パッケージ脆弱性確認   | `references/requirements-index.md`     | CVE, ライセンス要件                  | -                            |
| セキュリティチェックリスト | `assets/security-checklist.md`     | OWASP Top 10, CWE 対応               | -                            |
| Helmet設定最適化           | `assets/helmet-config-template.js` | ミドルウェア構成, ベストプラクティス | -                            |
| コンプライアンス確認       | `references/Level3_advanced.md`        | GDPR, PCI-DSS, SOC2                  | -                            |
| 脅威モデル分析             | `references/Level4_expert.md`          | 攻撃面, リスク評価, 優先度付け       | -                            |

## ベストプラクティス

### すべきこと

- `references/Level1_basics.md` を参照し、適用範囲を明確にする
- `references/Level2_intermediate.md` を参照し、実務手順を整理する
- **脅威モデリング** に基づいて、攻撃面と優先度を把握する
- **OWASP Top 10** に対応した設定チェックを実施する
- セキュリティヘッダーは **段階的に** 導入し、アプリケーション動作を確認する
- **定期的に** 脆弱性情報を確認し、依存パッケージを更新する
- セキュリティ設定の **変更履歴と根拠** を記録する

### 避けるべきこと

- アンチパターンや注意点を確認せずに進めることを避ける
- セキュリティヘッダーを **厳格に設定しすぎて** アプリケーション機能を破損させる
- **古い設定** のまま進める（定期的にレビューを実施）
- コンプライアンス要件を **見落とす** （業界標準の確認が重要）
- 脆弱性スキャンの結果を **無視する**

## リソース参照

### 📖 References（参考文献と学習リソース）

| カテゴリ       | リソース                              | 説明                                       |
| -------------- | ------------------------------------- | ------------------------------------------ |
| **基礎知識**   | `references/Level1_basics.md`          | セキュリティ設定の基本概念とチェックリスト |
| **実務ガイド** | `references/Level2_intermediate.md`    | 実践的なセキュリティ監査手順               |
| **応用技法**   | `references/Level3_advanced.md`        | 高度な脅威モデリングとリスク評価           |
| **専門知識**   | `references/Level4_expert.md`          | エンタープライズセキュリティ戦略           |
| **業界標準**   | `references/requirements-index.md`     | OWASP, NIST, GDPR 等のコンプライアンス要件 |
| **特定技術**   | `references/security-headers-guide.md` | HTTP セキュリティヘッダーの詳細ガイド      |

### 🔧 Scripts（自動化スクリプト）

| スクリプト                   | 用途                     | コマンド                                         |
| ---------------------------- | ------------------------ | ------------------------------------------------ |
| `check-security-headers.mjs` | セキュリティヘッダー検証 | `node scripts/check-security-headers.mjs --help` |
| `validate-skill.mjs`         | スキル構造の検証         | `node scripts/validate-skill.mjs --help`         |
| `log_usage.mjs`              | 使用記録と自動評価       | `node scripts/log_usage.mjs --help`              |

### 📋 Templates（テンプレート集）

| テンプレート                | 用途                           | 参照パス                              |
| --------------------------- | ------------------------------ | ------------------------------------- |
| `cors-config-template.js`   | CORS設定の実装例               | `assets/cors-config-template.js`   |
| `helmet-config-template.js` | Helmet ミドルウェア設定例      | `assets/helmet-config-template.js` |
| `security-checklist.md`     | セキュリティ監査チェックリスト | `assets/security-checklist.md`     |

### 📚 Legacy（旧バージョンリソース）

- `references/legacy-skill.md`: 旧 SKILL.md の完全版（参考用）

## 変更履歴

| Version | Date       | Changes                                                                                                                                                                                                                                         |
| ------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2.0.0   | 2025-12-31 | 18-skills.md仕様への完全準拠。YAML frontmatterにAnchorsとTriggerを追加。Task仕様ナビテーブルを実装。リソース参照セクションを整理し、References/Scripts/Templatesの3階層に構成。ベストプラクティスを「すべきこと」「避けるべきこと」で大幅拡充。 |
| 1.0.0   | 2025-12-24 | Spec alignment and required artifacts added                                                                                                                                                                                                     |
