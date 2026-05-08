---
name: .claude/skills/agent-quality-standards/SKILL.md
description: |
  エージェント品質基準と検証プロセスを専門とするスキル。
  
  📖 参照書籍:
  - 『The Pragmatic Programmer』（Andrew Hunt, David Thomas）: 手順設計
  
  📚 リソース参照:
  - `resources/Level1_basics.md`: レベル1の基礎ガイド
  - `resources/Level2_intermediate.md`: レベル2の実務ガイド
  - `resources/Level3_advanced.md`: レベル3の応用ガイド
  - `resources/Level4_expert.md`: レベル4の専門ガイド
  - `resources/legacy-skill.md`: 旧SKILL.mdの全文
  - `resources/quality-metrics.md`: Quality Metrics
  - `scripts/calculate-quality-score.mjs`: calculate-quality-score.mjs
  - `scripts/log_usage.mjs`: 使用記録・自動評価スクリプト
  - `scripts/validate-skill.mjs`: スキル構造検証スクリプト
  - `templates/quality-checklist-template.md`: Quality Checklist Template
  - `resources/requirements-index.md`: 要求仕様の索引（docs/00-requirements と同期）
  
  Use proactively when handling agent quality standards tasks.
version: 1.0.0
level: 1
last_updated: 2025-12-24
references:
  - book: "The Pragmatic Programmer"
    author: "Andrew Hunt, David Thomas"
    concepts:
      - "手順設計"
      - "実践的改善"
---

# Agent Quality Standards

## 概要

エージェント品質基準と検証プロセスを専門とするスキル。

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
- エージェントの完了条件を設計する時
- 品質メトリクスを定義する時
- エラーハンドリング戦略を設計する時
- 品質評価とスコアリングを行う時

### 避けるべきこと
- アンチパターンや注意点を確認せずに進めることを避ける

## コマンドリファレンス

### リソース読み取り
```bash
cat .claude/skills/agent-quality-standards/resources/Level1_basics.md
cat .claude/skills/agent-quality-standards/resources/Level2_intermediate.md
cat .claude/skills/agent-quality-standards/resources/Level3_advanced.md
cat .claude/skills/agent-quality-standards/resources/Level4_expert.md
cat .claude/skills/agent-quality-standards/resources/legacy-skill.md
cat .claude/skills/agent-quality-standards/resources/quality-metrics.md
```

### スクリプト実行
```bash
node .claude/skills/agent-quality-standards/scripts/calculate-quality-score.mjs --help
node .claude/skills/agent-quality-standards/scripts/log_usage.mjs --help
node .claude/skills/agent-quality-standards/scripts/validate-skill.mjs --help
```

### テンプレート参照
```bash
cat .claude/skills/agent-quality-standards/templates/quality-checklist-template.md
```

## 変更履歴

| Version | Date | Changes |
| --- | --- | --- |
| 1.0.0 | 2025-12-24 | Spec alignment and required artifacts added |
