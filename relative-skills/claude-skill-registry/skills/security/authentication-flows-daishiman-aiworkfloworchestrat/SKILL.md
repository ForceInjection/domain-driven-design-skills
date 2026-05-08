---
name: authentication-flows
description: |
  API Key、JWT、OAuth 2.0、mTLS などの認証方式を比較し、適切なフロー設計と実装方針を整理するスキル。
  方式選定、トークン管理、署名戦略、セキュリティ対策を一貫して設計します。

  Anchors:
  • Web Application Security / 適用: 脅威整理 / 目的: 認証フローのリスク把握
  • OWASP Authentication Cheat Sheet / 適用: 実装ベストプラクティス / 目的: 安全な実装指針
  • RFC 6749 & RFC 7519 / 適用: OAuth/JWT仕様 / 目的: 標準準拠の設計

  Trigger:
  Use when selecting authentication flows (API Key/JWT/OAuth/mTLS), designing token strategy, or validating auth configuration.
allowed-tools:
  - bash
  - node
---

# Authentication Flows

## 概要

複数の認証方式を比較し、最適なフローとトークン戦略を設計する。
詳細は `references/` に外部化し、必要時に参照する。

- 方式別ガイドは `references/api-key.md`, `references/jwt.md`, `references/oauth2.md`, `references/mtls.md`
- 実装例は `assets/` を利用

## ワークフロー

### Phase 1: 要件整理

**目的**: 認証要件と制約を整理する

**アクション**:

1. `references/Level1_basics.md` で基礎概念を確認
2. 対象システムの要件と制約を整理
3. セキュリティ要件と脅威を洗い出す

**Task**: `agents/analyze-auth-requirements.md`

### Phase 2: 方式選定と設計

**目的**: 認証方式とトークン戦略を決定する

**アクション**:

1. `references/api-key.md` / `references/jwt.md` / `references/oauth2.md` / `references/mtls.md` を比較
2. トークン構造・署名・有効期限方針を決定
3. `assets/jwt-service-template.ts` / `assets/oauth2-client-template.ts` を参照

**Task**:
- `agents/select-auth-method.md`
- `agents/design-token-strategy.md`

### Phase 3: 検証と記録

**目的**: 設定の妥当性を検証し記録する

**アクション**:

1. `scripts/validate-auth-config.mjs` で設定検証
2. `scripts/validate-skill.mjs` で構造検証
3. `scripts/log_usage.mjs` で改善記録を残す

**Task**: `agents/validate-auth-implementation.md`

## Task仕様ナビ

| Task | 役割 | 入力 | 出力 | 参照先 | 実行タイミング |
| --- | --- | --- | --- | --- | --- |
| 要件整理 | 目的・制約の整理 | 要件情報 | 要件メモ | `references/Level1_basics.md` | Phase 1 |
| 方式選定 | 認証方式の選定 | 要件メモ | 選定メモ | `references/api-key.md` | Phase 2 前半 |
| トークン設計 | 署名と有効期限の設計 | 選定メモ | 設計メモ | `references/jwt.md` | Phase 2 後半 |
| 検証レビュー | 設定の検証 | 設定ファイル | 検証結果 | `scripts/validate-auth-config.mjs` | Phase 3 |

## ベストプラクティス

### すべきこと

- 要件と制約を先に整理する
- トークン有効期限と更新戦略を明記する
- 方式選定の理由を記録する
- 標準仕様に準拠した設定を採用する

### 避けるべきこと

- シークレットのハードコード
- 暗号化無しの認証情報送信
- 複数方式の無計画な混在
- 検証無しで設計を確定する

## リソース参照

### 参照資料

- `references/Level1_basics.md`: 基本概念
- `references/Level2_intermediate.md`: 実装パターン
- `references/Level3_advanced.md`: 脅威と最適化
- `references/Level4_expert.md`: エンタープライズ運用
- `references/api-key.md`: API Key
- `references/jwt.md`: JWT
- `references/oauth2.md`: OAuth 2.0
- `references/mtls.md`: mTLS
- `references/legacy-skill.md`: 旧版要約（移行時のみ参照）

### スクリプト

- `scripts/validate-auth-config.mjs`: 設定検証
- `scripts/validate-skill.mjs`: スキル構造検証
- `scripts/log_usage.mjs`: 実行ログ記録

### テンプレート

- `assets/jwt-service-template.ts`: JWTテンプレ
- `assets/oauth2-client-template.ts`: OAuthテンプレ

## 変更履歴

| Version | Date       | Changes                                             |
| ------- | ---------- | --------------------------------------------------- |
| 2.1.0   | 2025-12-31 | 18-skills準拠、Task仕様追加、scripts整備            |
| 2.0.0   | 2025-12-31 | 18-skills.md仕様に完全準拠                           |
| 1.0.0   | 2025-12-24 | 初版作成                                            |
