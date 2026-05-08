---
name: using-vertical-tdd
description: |
  OpenSpec駆動の垂直TDDスケルトン戦略。提案作成・技術検証・設計・実装・アーカイブの全ライフサイクルをサポート。
  使用タイミング:
  (1) OpenSpecスラッシュコマンド実行時（`OpenSpec: Propose`, `OpenSpec: Apply`, `OpenSpec: Archive`）
  (2) 新機能開発の開始時（「新機能を追加」「〜を実装」リクエスト、OpenSpec提案がまだ存在しない場合）
  (3) 提案の修正・継続（openspec/changes/配下にファイルが存在、「提案を修正」「設計を見直し」リクエスト）
  (4) 実装の再開（tasks.mdに未完了タスクがある、「実装を続ける」「次のステップ」リクエスト）
  (5) 技術検証が必要（design.md作成前、複数技術選択肢がある、「技術検証」「ライブラリ調査」リクエスト）
  使用しない場合: バグ修正、タイポ修正、ドキュメント更新のみ、設定ファイル変更のみ
allowed-tools: Read, Bash(openspec:*), Bash(runme:*), Bash(git:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(cat:*), Bash(jq:*), Bash(rg:*), Bash(mkdir:*), WebSearch, WebFetch, mcp__plugin_context7_context7__resolve-library-id, mcp__plugin_context7_context7__query-docs
---

# 垂直TDDスケルトン戦略

## ビジョン

- **常にデプロイ可能**: すべてのPRでmainブランチにマージ可能な状態を維持
- **シフトレフト結合**: システム統合を最終段階ではなく最初のPR（スケルトン）で完了
- **AI共生**: AIアシスタントが一貫したワークフローで効率的に作業できる構造

## OpenSpecライフサイクル統合

OpenSpecの3ステージに垂直TDDステップをマッピング：

### Stage 1: Creating Changes（提案作成）

- **Step 1: Proposal** → [workflows/step1-proposal.md](workflows/step1-proposal.md)
  - OpenSpec提案の作成、インターフェース合意、tasks.md開始
  - **PR #1**: proposal.md + tasks.md

- **Step 1a: Tech Spike**（任意） → [workflows/step1a-tech-spike.md](workflows/step1a-tech-spike.md)
  - 技術的妥当性の検証、Context7でライブラリ調査

- **Step 1b: Design**（任意） → [workflows/step1b-design.md](workflows/step1b-design.md)
  - design.mdで設計判断を文書化
  - **PR #1a/1b**（任意）: spike/results.md + design.md

### Stage 2: Implementing Changes（実装）

- **Step 2: Runbook & Red** → [workflows/step2-runbook-red.md](workflows/step2-runbook-red.md)
  - Runme.dev形式でverify.md作成、RED確認

- **Step 3: Skeleton Green** → [workflows/step3-skeleton-green.md](workflows/step3-skeleton-green.md)
  - 最小実装でGREEN、**PR #2**マージ（フィーチャーフラグOFF）

- **Step 4: Logic Meat** → [workflows/step4-logic-meat.md](workflows/step4-logic-meat.md)
  - ユニットTDDでロジック実装、**PR #3**マージ

### Stage 3: Archiving Changes（アーカイブ）

- **Step 5: Archive & Release** → [workflows/step5-archive-release.md](workflows/step5-archive-release.md)
  - spec.md TBDチェック → [references/tbd-check.md](references/tbd-check.md)
  - verify.md / coverage.md正式版昇格 → [references/verify-promotion.md](references/verify-promotion.md)
  - 全テスト検証、アーカイブ、フィーチャーフラグ有効化、**PR #N**（リリース）

## 関連スキル

- **tech-spike**: [.claude/skills/tech-spike/](./../tech-spike/) - 技術検証ワークフロー
- **verify-and-coverage**: [.claude/skills/verify-and-coverage/](./../verify-and-coverage/) - 実行可能テスト&カバレッジ管理

## コミット戦略

安定チェックポイントでこまめにコミット。詳細は [references/commit-strategy.md](references/commit-strategy.md) を参照。

## 実装再開時

```bash
openspec show <change-id>
cat openspec/changes/<change-id>/tasks.md
# → tasks.mdの進捗に基づき次のステップを提案
```

## Context7統合

Step 1a（Tech Spike）でライブラリ調査、Step 1b（Design）でベストプラクティス調査に使用。

```bash
# MCPツール: mcp__plugin_context7_context7__resolve-library-id
# → mcp__plugin_context7_context7__query-docs
```

## 重要な原則

### tasks.md即時更新ルール（最重要）

> **警告: このルールは絶対に守ること**

各タスクを完了したら、**次の作業に進む前に必ず**tasks.mdを更新してください。

- 完了したタスクは**即座に** `- [x]` に変更
- PR作成時にまとめて更新するのは**禁止**
- 1タスク完了 → 1回更新（バッチ更新禁止）

**更新タイミングの例**:
- verify.md作成完了 → 即座にtasks.md更新
- RED確認完了 → 即座にtasks.md更新
- スケルトン実装完了 → 即座にtasks.md更新
- GREEN確認完了 → 即座にtasks.md更新

### ドキュメント先行更新ルール（SSoT原則）

> **警告: ドキュメントがSingle Source of Truth（SSoT）**

実装中に仕様の定義漏れや設計の考慮漏れに気づいた場合、**実装を変更する前に**ドキュメントを先に更新してください。

#### 更新対象と判断基準

| ドキュメント | 更新が必要なケース |
|------------|------------------|
| **spec.md** | 機能要件の追加・変更・削除、シナリオの修正、インターフェース変更 |
| **design.md** | アーキテクチャ変更、技術選択の見直し、コンポーネント構成の変更 |
| **tasks.md** | タスクの追加・分割・削除、完了状態の更新 |

#### ワークフロー

1. **発見**: 実装中に仕様/設計の問題に気づく
2. **中断**: 実装作業を一時中断
3. **更新**: 該当ドキュメント（spec.md/design.md/tasks.md）を修正
4. **コミット**: ドキュメント変更をコミット
5. **再開**: 更新されたドキュメントに基づいて実装を再開

#### 具体例

**NG（禁止）**:
```
コード変更 → 後でドキュメント更新
```

**OK（推奨）**:
```
問題発見 → spec.md/design.md更新 → コミット → コード変更
```

#### なぜドキュメント先行か

- **追跡可能性**: ドキュメント変更がコミット履歴に残り、なぜ方針が変わったか追跡可能
- **整合性**: ドキュメントと実装の乖離を防止
- **レビュー効率**: PRレビュー時に意図が明確

### その他の原則

1. **疎通優先、ロジック後回し**: Step 3ではUIからDBまで貫通させ、ビジネスロジックは書かない
2. **フィーチャーフラグで段階的リリース**: 環境変数で制御、スケルトンはOFFでマージ
3. **柔軟なPRで段階的マージ**: 提案フェーズは厳密に、実装フェーズは柔軟に分割
4. **verify.mdは実行可能なドキュメント**: Runme.devでそのまま実行可能

## 実装フェーズのバリエーション

状況に応じて実装フェーズのPR構成を選択します。詳細は [references/pr-splitting-guide.md](references/pr-splitting-guide.md) を参照。

### パターンA: アプリケーション型（従来通り）

既存システムへの機能追加、インフラ変更が少ない場合：

```
PR #1 → [PR #1a] → [PR #1b] → PR #2（スケルトン）→ PR #3（ロジック）→ PR #N（リリース）
```

### パターンB: インフラ先行型

新規インフラ構築、デプロイ基盤整備が必要な場合：

```
PR #1 → [PR #1a] → [PR #1b] → PR #2a（デプロイ基盤）→ PR #2b（スケルトン）→ PR #3+（ロジック）→ PR #N（リリース）
```

### PR分割の目安

- **変更ファイル数**: 10ファイル以下
- **意味のある単位**: レイヤー単位、機能単位、デプロイ単位など

## 詳細ワークフロー

- [Step 1: Proposal](workflows/step1-proposal.md)
- [Step 1a: Tech Spike](workflows/step1a-tech-spike.md)
- [Step 1b: Design](workflows/step1b-design.md)
- [Step 2: Runbook & Red](workflows/step2-runbook-red.md)
- [Step 3: Skeleton Green](workflows/step3-skeleton-green.md)
- [Step 4: Logic Meat](workflows/step4-logic-meat.md)
- [Step 5: Archive & Release](workflows/step5-archive-release.md)

## よくある質問

→ [references/faq.md](references/faq.md)
