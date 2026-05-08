---
name: security-reporting
description: |
  セキュリティ診断レポートの作成と脆弱性報告の文書化を支援するスキル。
  脅威分析、脆弱性評価、リスク採点、レポート生成の一連のプロセスを体系化し、
  専門的で実用性の高いセキュリティドキュメントを作成する。

  Anchors:
  • OWASP Top 10 (2021) / 適用: 脆弱性分類・評価基準 / 目的: 業界標準への準拠
  • CVSS v3.1 (FIRST) / 適用: リスクスコア計算 / 目的: 定量的脆弱性評価
  • Web Application Security (Andrew Hoffman) / 適用: 脅威モデリング / 目的: 体系的分析手法
  • CWE Top 25 / 適用: 脆弱性分類 / 目的: 共通語彙での報告

  Trigger:
  Use when creating security audit reports, vulnerability assessments, penetration test documentation, or risk analysis documents.
  security report, vulnerability report, security audit, penetration test report, risk assessment, 脆弱性レポート, セキュリティ監査
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# Security Reporting

## 概要

セキュリティ診断結果、脆弱性評価、監査結果を専門的かつ体系的にレポート化するスキル。脅威モデリングからレポート生成、レビューまでの一連のワークフローを提供し、信頼性と実用性の高いセキュリティドキュメントを作成する。

## ワークフロー

```
analyze-threats → assess-vulnerabilities → calculate-risk-score
                                                    ↓
                         validate-report ← generate-report
```

### Phase 1: 脅威分析（analyze-threats）

**目的**: 対象システムのセキュリティ脅威を特定・分類する

**アクション**:

1. 対象システムのスコープを定義
2. 攻撃ベクトルと脅威アクターを特定
3. STRIDEモデルで脅威を分類

**Task**: `agents/analyze-threats.md` を参照

### Phase 2: 脆弱性評価（assess-vulnerabilities）

**目的**: 検出された脆弱性を体系的に評価・分類する

**アクション**:

1. 脆弱性をOWASP Top 10/CWEで分類
2. 影響範囲と悪用可能性を評価
3. 証跡と再現手順を文書化

**Task**: `agents/assess-vulnerabilities.md` を参照

### Phase 3: リスク採点（calculate-risk-score）

**目的**: 脆弱性に定量的なリスクスコアを付与する

**アクション**:

1. CVSSスコアを計算・参照
2. 悪用可能性・影響範囲・コンテキストを加味
3. リスクレベルと優先度を決定

**Task**: `agents/calculate-risk-score.md` を参照

### Phase 4: レポート生成（generate-report）

**目的**: 調査結果を体系的なレポートにまとめる

**アクション**:

1. エグゼクティブサマリーを作成
2. 技術的詳細を記述
3. 修正推奨事項とアクションプランを策定

**Task**: `agents/generate-report.md` を参照

### Phase 5: 検証・レビュー（validate-report）

**目的**: レポートの品質と完全性を検証する

**アクション**:

1. 必須セクションの存在確認
2. 技術的正確性の検証
3. 推奨事項の実現可能性確認

**Task**: `agents/validate-report.md` を参照

## Task仕様（ナビゲーション）

| Task                   | 責務             | 入力                 | 出力                 |
| ---------------------- | ---------------- | -------------------- | -------------------- |
| analyze-threats        | 脅威特定・分類   | システム情報         | 脅威リスト           |
| assess-vulnerabilities | 脆弱性評価・分類 | 脅威リスト・検出結果 | 脆弱性評価書         |
| calculate-risk-score   | リスク定量化     | 脆弱性評価書         | リスクスコア一覧     |
| generate-report        | レポート作成     | 全評価結果           | セキュリティレポート |
| validate-report        | 品質検証         | レポート草案         | 検証済みレポート     |

**詳細仕様**: 各Taskの詳細は `agents/` ディレクトリの対応ファイルを参照
**注記**: 1 Task = 1 責務。複数責務を1ファイルに入れない。

## ベストプラクティス

### すべきこと

| 推奨事項                           | 理由                                 |
| ---------------------------------- | ------------------------------------ |
| CVSS v3.1でリスクを定量化する      | 主観的評価を排除し、比較可能にする   |
| OWASP/CWEで脆弱性を分類する        | 業界標準の共通語彙で報告する         |
| 再現手順と証跡を必ず含める         | 検証可能性と信頼性を担保する         |
| 修正推奨事項に具体的なコードを示す | 実装担当者がすぐ対応できるようにする |
| エグゼクティブサマリーを先頭に配置 | 経営層が即座に重要度を把握できる     |
| アクションプランに期限を明記する   | 対応の優先順位と進捗を管理する       |

### 避けるべきこと

| 禁止事項                         | 問題点                             |
| -------------------------------- | ---------------------------------- |
| 主観的なリスク評価のみで報告する | 定量比較ができず優先度が曖昧になる |
| 脆弱性を報告するだけで終わる     | 修正方法がないと対応できない       |
| 技術用語のみで記述する           | ステークホルダーが理解できない     |
| 発見日時・検証環境を省略する     | 再現性と信頼性が損なわれる         |
| 全脆弱性を同じ優先度で報告する   | 緊急度が伝わらず対応が遅れる       |

## リソース参照

### references/（詳細知識）

| リソース           | パス                                                                             | 読込条件      |
| ------------------ | -------------------------------------------------------------------------------- | ------------- |
| 脅威モデリング手法 | [references/threat-modeling.md](references/threat-modeling.md)                   | Phase 1で参照 |
| 脆弱性分類         | [references/vulnerability-categories.md](references/vulnerability-categories.md) | Phase 2で参照 |
| リスクスコア計算   | [references/risk-scoring-methodology.md](references/risk-scoring-methodology.md) | Phase 3で参照 |
| レポート構造       | [references/report-structure.md](references/report-structure.md)                 | Phase 4で参照 |

### scripts/（決定論的処理）

| スクリプト                    | 機能                         |
| ----------------------------- | ---------------------------- |
| `scripts/validate-report.mjs` | レポート構造・必須項目の検証 |
| `scripts/log_usage.mjs`       | 使用記録とフィードバック     |

### assets/（テンプレート）

| アセット                             | 用途                       |
| ------------------------------------ | -------------------------- |
| `assets/security-report-template.md` | セキュリティレポートの雛形 |

### コマンド例

**スクリプト実行**:

```bash
# レポート検証
node .claude/skills/security-reporting/scripts/validate-report.mjs <report-path>

# 使用記録
node .claude/skills/security-reporting/scripts/log_usage.mjs --result success --phase "Phase 5"
```

## 変更履歴

| Version | Date       | Changes                                                 |
| ------- | ---------- | ------------------------------------------------------- |
| 3.0.0   | 2026-01-02 | 18-skills.md仕様完全準拠。agents/追加、責務ベース再構成 |
| 2.0.0   | 2025-12-31 | 18-skills.md仕様への準拠開始                            |
| 1.0.0   | 2025-12-24 | 初版作成                                                |
