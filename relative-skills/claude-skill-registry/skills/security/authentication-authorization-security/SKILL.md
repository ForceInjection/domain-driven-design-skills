---
name: authentication-authorization-security
description: |
  認証・認可の設計とセキュリティ検証（OAuth 2.0、JWT、セッション管理、アクセス制御）の実務指針を提供するスキル。
  脅威モデリング、トークン管理、権限モデルの選択を整理し、安全な認証基盤の設計判断を支援します。

  Anchors:
  • Web Application Security / 適用: 脅威モデリング / 目的: 認証・認可の脅威整理
  • OAuth 2.0 Simplified / 適用: フロー選定 / 目的: OAuth実装の安全性確保
  • OWASP ASVS / 適用: セキュリティ検証 / 目的: 要件基準の確認

  Trigger:
  Use when designing or reviewing authentication/authorization flows, selecting OAuth/JWT/session strategies, or validating access control and token security.
allowed-tools:
  - bash
  - node
---

# Authentication & Authorization Security

## 概要

認証・認可の設計・実装・検証を一連で整理する。
詳細は `references/` に外部化し、必要時に参照する。

- フロー比較は `references/oauth2-flow-comparison.md`
- トークン検証は `references/jwt-security-checklist.md`
- セッション検証は `references/session-management-patterns.md`

## ワークフロー

### Phase 1: 目的と脅威の整理

**目的**: 認証・認可の要件と脅威モデルを明確化する

**アクション**:

1. `references/Level1_basics.md` で基礎概念を確認
2. `references/requirements-index.md` で適用ルールを確認
3. 目的・制約・脅威を整理する

**Task**: `agents/analyze-auth-context.md`

### Phase 2: フロー設計とアクセス制御

**目的**: OAuth/JWT/セッション戦略とアクセス制御モデルを決定する

**アクション**:

1. `references/oauth2-flow-comparison.md` でOAuthフローを選定
2. `references/jwt-security-checklist.md` でトークン方針を決定
3. `references/access-control-models.md` で権限制御を整理
4. `references/password-hashing-guide.md` でパスワード方針を決定

**Task**:
- `agents/select-auth-flows.md`
- `agents/design-access-controls.md`

### Phase 3: 検証と記録

**目的**: 実装の安全性を検証し、改善点を記録する

**アクション**:

1. `scripts/analyze-auth-endpoints.mjs` でエンドポイントを分析
2. `scripts/check-token-security.mjs` でトークン実装を検証
3. `scripts/validate-session-config.mjs` でセッション設定を検証
4. `scripts/log_usage.mjs` で改善記録を残す

**Task**: `agents/validate-auth-security.md`

## Task仕様ナビ

| Task | 役割 | 入力 | 出力 | 参照先 | 実行タイミング |
| --- | --- | --- | --- | --- | --- |
| 要件整理 | 目的・脅威の整理 | 要件情報 | コンテキスト要約 | `references/Level1_basics.md` | Phase 1 |
| フロー選定 | OAuth/JWT戦略選定 | コンテキスト要約 | フロー選定メモ | `references/oauth2-flow-comparison.md` | Phase 2 前半 |
| 権限設計 | アクセス制御とパスワード方針 | フロー選定メモ | 権限設計メモ | `references/access-control-models.md` | Phase 2 後半 |
| 検証レビュー | スクリプト検証と改善整理 | 対象コード | 検証レポート | `scripts/check-token-security.mjs` | Phase 3 |

## ベストプラクティス

### すべきこと

- 脅威モデルを先に定義し、要件の漏れを防ぐ
- OAuth フローは用途に応じて最小権限で選択する
- JWT/セッションの有効期限と保存先を明示する
- アクセス制御ロジックを集中管理する
- スクリプト検証結果を記録する

### 避けるべきこと

- トークンの無期限化や秘匿情報のペイロード格納
- クライアント側へのセッション情報保存
- アクセス制御を個別実装で分散させる
- 検証無しで設計を確定する

## リソース参照

### 参照資料

- `references/Level1_basics.md`: 基本概念と脅威整理
- `references/Level2_intermediate.md`: 実装パターン
- `references/Level3_advanced.md`: 検証と移行
- `references/Level4_expert.md`: 運用と改善
- `references/oauth2-flow-comparison.md`: OAuthフロー比較
- `references/jwt-security-checklist.md`: JWT検証項目
- `references/password-hashing-guide.md`: パスワード方針
- `references/session-management-patterns.md`: セッション管理
- `references/access-control-models.md`: RBAC/ABAC/ACL
- `references/requirements-index.md`: 適用ルール索引
- `references/legacy-skill.md`: 旧版要約（移行時のみ参照）

### スクリプト

- `scripts/analyze-auth-endpoints.mjs`: エンドポイント分析
- `scripts/check-token-security.mjs`: トークン検証
- `scripts/validate-session-config.mjs`: セッション設定検証
- `scripts/validate-skill.mjs`: スキル構造検証
- `scripts/log_usage.mjs`: 実行ログ記録

### テンプレート

- `assets/oauth2-config-template.json`: OAuth設定テンプレ
- `assets/rbac-policy-template.yaml`: RBACテンプレ
- `assets/session-security-checklist.md`: セッションチェックリスト

## 変更履歴

| Version | Date       | Changes                                             |
| ------- | ---------- | --------------------------------------------------- |
| 2.0.0   | 2025-12-31 | 18-skills準拠、Task仕様追加、scripts整備            |
| 1.1.0   | 2025-12-31 | 18-skills.md仕様準拠、Task仕様ナビ追加              |
| 1.0.0   | 2025-12-24 | 初版作成                                            |
