---
name: secrets-management-gha
description: |
  GitHub Actionsワークフローでの安全な秘密情報管理を実現する。
  リポジトリ/環境/組織/Dependabotの4種類のシークレット使い分け、OIDCによるクラウド認証、ローテーション、監査を包括的に提供する。

  Anchors:
  • Web Application Security (Andrew Hoffman) / 適用: 脅威モデリング・セキュア設計 / 目的: シークレット管理戦略の基盤
  • GitHub Actions Secrets API / 適用: シークレット設定・アクセス制御 / 目的: 各タイプの正確な使い分け
  • OpenID Connect (OIDC) Specification / 適用: クラウドプロバイダー認証 / 目的: 長期認証情報の排除

  Trigger:
  Use when configuring GitHub Actions secrets, implementing cloud OIDC authentication, rotating secrets, or auditing secret access patterns.
  GitHub secrets, OIDC, secret rotation, environment secrets, organization secrets, cloud authentication
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# GitHub Actions Secrets Management

## 概要

GitHub Actionsワークフローでの安全な秘密情報管理を実現するスキル。リポジトリ/環境/組織/Dependabotの4種類のシークレット使い分け、OIDCクラウド認証、ローテーション、アクセス監査を段階的に提供する。

## ワークフロー

```
secret-type-determination → oidc-authentication → secret-rotation → access-audit
```

### Task 1: シークレットタイプ判定（secret-type-determination）

要件に基づき4種類のGitHubシークレットから最適なタイプを選定する。

**Task**: `agents/secret-type-determination.md` を参照

### Task 2: OIDC認証実装（oidc-authentication）

AWS/Azure/GCPへのOIDC認証を実装し、長期認証情報を排除する。

**Task**: `agents/oidc-authentication.md` を参照

### Task 3: シークレットローテーション（secret-rotation）

定期的なシークレット更新プロセスを自動化する。

**Task**: `agents/secret-rotation.md` を参照

### Task 4: アクセス監査（access-audit）

ワークフロー内のシークレット使用パターンを分析し、セキュリティリスクを特定する。

**Task**: `agents/access-audit.md` を参照

## Task仕様（ナビゲーション）

| Task                      | 責務                   | 入力               | 出力                       |
| ------------------------- | ---------------------- | ------------------ | -------------------------- |
| secret-type-determination | シークレットタイプ選定 | プロジェクト要件   | シークレット設計書         |
| oidc-authentication       | OIDC認証実装           | シークレット設計書 | OIDCワークフロー設定       |
| secret-rotation           | ローテーション自動化   | シークレット設計書 | ローテーションワークフロー |
| access-audit              | セキュリティ監査       | ワークフロー定義   | 監査レポート               |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリを参照
**注記**: 1 Task = 1 責務。必要なTaskのみ実行する。

## ベストプラクティス

### すべきこと

| 推奨事項                   | 理由                                      |
| -------------------------- | ----------------------------------------- |
| 環境ごとにシークレット分離 | 本番/ステージングの誤用を防止             |
| OIDC認証を優先             | 長期認証情報不要、自動ローテーション      |
| 最小権限の原則             | 必要なワークフロー/環境のみにアクセス許可 |
| 監査ログ定期レビュー       | 異常アクセスの早期検出                    |
| 90日以内のローテーション   | 漏洩時の影響範囲を限定                    |

### 避けるべきこと

| 禁止事項                       | 問題点                                 |
| ------------------------------ | -------------------------------------- |
| シークレットのログ出力         | 漏洩後の消去が不可能                   |
| `secrets: inherit` の濫用      | 外部Actionへの過剰な露出               |
| コミット履歴への含有           | Git履歴からの完全削除が困難            |
| 同一シークレットの複数環境共有 | 影響範囲の拡大                         |
| Dependabotシークレットの混同   | スコープが異なり意図しないアクセス不可 |

## リソース参照

### references/（詳細知識）

| リソース                       | パス                                                                       | 読込条件           |
| ------------------------------ | -------------------------------------------------------------------------- | ------------------ |
| シークレットタイプ詳細         | [references/secret-types.md](references/secret-types.md)                   | タイプ選定時       |
| OIDC認証フロー                 | [references/oidc-authentication.md](references/oidc-authentication.md)     | クラウド認証実装時 |
| セキュリティベストプラクティス | [references/secret-best-practices.md](references/secret-best-practices.md) | 監査・レビュー時   |

### scripts/（決定論的処理）

| スクリプト                       | 機能                               |
| -------------------------------- | ---------------------------------- |
| `scripts/check-secret-usage.mjs` | ワークフロー内シークレット静的解析 |
| `scripts/log_usage.mjs`          | フィードバック記録                 |

### assets/（テンプレート）

| アセット                    | 用途                               |
| --------------------------- | ---------------------------------- |
| `assets/oidc-examples.yaml` | AWS/Azure/GCP OIDC設定テンプレート |

## 変更履歴

| Version | Date       | Changes                                                   |
| ------- | ---------- | --------------------------------------------------------- |
| 2.0.0   | 2026-01-02 | 18-skills.md仕様完全準拠（Level1-4削除、Trigger英語化）   |
| 1.0.0   | 2025-12-31 | 18-skills.md仕様へ初期準拠（Frontmatter改訂、本文再構成） |
