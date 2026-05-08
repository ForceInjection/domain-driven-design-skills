---
name: .claude/skills/nextauth-patterns/SKILL.md
description: |
  NextAuth.js v5の設定とカスタマイズパターン。
  プロバイダー設定、アダプター統合、セッション戦略、
  コールバックカスタマイズ、型安全性の確保を提供。
  
  📖 参照書籍:
  - 『Web Application Security』（Andrew Hoffman）: 脅威モデリング
  
  📚 リソース参照:
  - `resources/Level1_basics.md`: レベル1の基礎ガイド
  - `resources/Level2_intermediate.md`: レベル2の実務ガイド
  - `resources/Level3_advanced.md`: レベル3の応用ガイド
  - `resources/Level4_expert.md`: レベル4の専門ガイド
  - `resources/legacy-skill.md`: 旧SKILL.mdの全文
  - `resources/provider-configurations.md`: NextAuth.js Provider Configurations
  - `resources/session-callbacks-guide.md`: NextAuth.js Session Callbacks Guide
  - `scripts/log_usage.mjs`: 使用記録・自動評価スクリプト
  - `scripts/validate-nextauth-config.mjs`: NextAuth.js設定ファイルの妥当性検証とプロバイダー設定・コールバック実装の検査スクリプト
  - `scripts/validate-skill.mjs`: スキル構造検証スクリプト
  - `templates/nextauth-config-template.ts`: Google/GitHub OAuth統合・Drizzleアダプター・JWT/Databaseセッション戦略を含むauth.ts設定テンプレート
  
  Use proactively when handling nextauth patterns tasks.
version: 1.0.0
level: 1
last_updated: 2025-12-24
references:
  - book: "Web Application Security"
    author: "Andrew Hoffman"
    concepts:
      - "脅威モデリング"
      - "セキュア設計"
---

# NextAuth.js Patterns

## 概要

NextAuth.js v5の設定とカスタマイズパターン。
プロバイダー設定、アダプター統合、セッション戦略、
コールバックカスタマイズ、型安全性の確保を提供。

詳細な手順や背景は `resources/Level1_basics.md` と `resources/Level2_intermediate.md` を参照してください。


## ワークフロー

### Phase 1: 目的と前提の整理

**目的**: タスクの目的と前提条件を明確にする

**アクション**:

1. `resources/Level1_basics.md` と `resources/Level2_intermediate.md` を確認
2. 必要な resources/scripts/templates を特定

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


## ベストプラクティス

### すべきこと
- NextAuth.jsの初期設定時
- OAuth 2.0プロバイダー統合時
- セッション戦略（JWT/Database）の実装時
- カスタムページ・コールバックの実装時
- Drizzleアダプター統合時

### 避けるべきこと
- アンチパターンや注意点を確認せずに進めることを避ける

## コマンドリファレンス

### リソース読み取り
```bash
cat .claude/skills/nextauth-patterns/resources/Level1_basics.md
cat .claude/skills/nextauth-patterns/resources/Level2_intermediate.md
cat .claude/skills/nextauth-patterns/resources/Level3_advanced.md
cat .claude/skills/nextauth-patterns/resources/Level4_expert.md
cat .claude/skills/nextauth-patterns/resources/legacy-skill.md
cat .claude/skills/nextauth-patterns/resources/provider-configurations.md
cat .claude/skills/nextauth-patterns/resources/session-callbacks-guide.md
```

### スクリプト実行
```bash
node .claude/skills/nextauth-patterns/scripts/log_usage.mjs --help
node .claude/skills/nextauth-patterns/scripts/validate-nextauth-config.mjs --help
node .claude/skills/nextauth-patterns/scripts/validate-skill.mjs --help
```

### テンプレート参照
```bash
cat .claude/skills/nextauth-patterns/templates/nextauth-config-template.ts
```

## 変更履歴

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0 | 2025-12-24 | Spec alignment and required artifacts added |
