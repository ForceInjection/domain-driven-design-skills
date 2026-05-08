---
name: issue-workflow-orchestrator
description: |
  Issueワークフロー統括スキル。Issue受領から実装・検証・PRレビュー完了までを、分類に応じたテンプレートで統括し、フェーズ成果物を構造化して引き継ぎながら進行する。

  トリガー条件:
  - 「Issue #N を修正して」「#N を直してPRまで」
  - 「/fix-issue 123」「/orchestrate-issue 123」
  - Issue修正の全体統括が必要な時

  注意: 実装そのもの、コード生成、レビュー判断の最終決裁は行わない（該当スキルへ委譲し、統括は状態と根拠の整合性を担保する）
---

# Issue Workflow Orchestrator（Issueワークフロー統括）

Issue（タスク要求）の受領から、実装・検証・PRレビュー完了までを、分類に応じたテンプレートで統括し、フェーズ成果物を構造化して引き継ぎながら進行する。

## Non-Goals（このスキルがやらないこと）

- 実装そのもの（該当スキルへ委譲）
- コード生成（該当スキルへ委譲）
- レビュー判断の最終決裁（該当スキルへ委譲）
- 統括は**状態と根拠の整合性を担保する**ことに集中

## 入力

```yaml
input:
  issue_id: "#123"                      # 必須
  repo: "org/repo"                      # 任意（デフォルトはカレント）
  target_branch: "main"                 # 任意
  execution_mode: "auto|assist|manual"  # 任意（デフォルト: assist）
  constraints:
    time_budget_minutes: 120            # 任意（運用上の上限）
    risk_tolerance: "low|medium|high"   # 任意（デフォルト: medium）
    allow_scope_change: false           # 任意
  context_hints:
    related_prs: ["#456"]               # 任意
    suspect_files: ["src/..."]          # 任意
  resume:
    workflow_run_id: "wf_..."           # 任意：途中再開時に指定
```

## 出力

### ワークフロープラン（状態機械＋成果物参照）

```yaml
workflow_plan:
  workflow_run_id: "wf_2025-12-30_abc123"
  issue_id: "#123"
  repo: "org/repo"
  classification:
    type: "bugfix"          # bugfix/feature/refactor/chore/security/docs
    severity: "major"       # trivial/minor/major/critical
    confidence: 0.78
    rationale: ["..."]
  selected_template: "major_bugfix_v2"
  phases: [...]             # 下記参照
  current_phase: "context"
  progress:
    percent: 18
    updated_at: "2025-12-30T..."
  governance:
    stop_conditions: [...]  # 下記参照
    approval_points: [...]
  artifacts: {...}          # 成果物参照
```

### ダッシュボード用要約

```yaml
workflow_status_summary:
  headline: "Issue #123: context収集中（再現条件の特定中）"
  next_actions: ["ログ採取", "再現手順の最小化"]
  blocking_risks: ["repro uncertain", "dependency version mismatch"]
  human_questions: ["期待仕様はAとBどちら？"]
```

## 分類（Classification）

詳細は [references/classification.md](references/classification.md) を参照。

### severity

| severity | 定義 |
|----------|------|
| `trivial` | ドキュメント/typo/コメント/CI設定。機能影響が限定的 |
| `minor` | 限定ケースのバグ、影響範囲が狭い、ロールバック容易 |
| `major` | 主要フローに影響、複数モジュールに波及、テスト追加が必須 |
| `critical` | データ破壊、セキュリティ、広範囲障害、緊急対応が必要 |

### type

| type | 定義 |
|------|------|
| `bugfix` | 既存機能の不具合修正 |
| `feature` | 新機能追加 |
| `refactor` | 機能変更なしの内部改善 |
| `chore` | 依存更新、CI、ドキュメント等 |
| `security` | セキュリティ修正（別テンプレート適用） |
| `docs` | ドキュメントのみ |

## フェーズ定義

各フェーズは以下の契約を持つ:

```yaml
phase:
  id: "phase_id"
  skill: "/skill-name"
  status: "pending|in_progress|completed|failed|skipped"
  entry_criteria: ["前提条件リスト"]
  exit_criteria: ["完了条件リスト"]
  on_failure: "retry|rollback|escalate|halt"
  artifacts_in: ["入力成果物"]
  artifacts_out: ["出力成果物"]
```

### 標準フェーズ構成

| # | phase_id | skill | 目的 |
|---|----------|-------|------|
| 1 | intake | `/issue-intake` | Issue初期トリアージ |
| 2 | context | `/eld-sense-activation` | コンテキスト活性化 |
| 3 | onboarding | `/ai-led-onboarding` | 最小スキーマ構築 |
| 4 | uncertainty | `/resolving-uncertainty` | 不確実性解消 |
| 5 | task_decomposition | `/eld-sense-task-decomposition` | タスク分解 |
| 6 | observation | `/observation-minimum-set` | 観測計画 |
| 7 | implementation | `/eld` | 実装ループ |
| 8 | review | `/eld-ground-pr-review` | PRレビュー |

詳細は [references/phase-definitions.md](references/phase-definitions.md) を参照。

## 成果物契約（Artifact Contract）

フェーズ間で引き継ぐ成果物の構造。詳細は [references/artifact-contracts.md](references/artifact-contracts.md) を参照。

### 主要成果物

| artifact_id | 生成フェーズ | 構造 |
|-------------|--------------|------|
| `intake_report` | intake | Issue要約、受け入れ条件、リスク初期値 |
| `context_pack` | context | 再現手順、ログ、関連コード範囲 |
| `risk_register` | context/uncertainty | unknown一覧、影響と確度、解消手段 |
| `task_plan` | task_decomposition | タスク分解、スコープ境界、テスト計画 |
| `observation_plan` | observation | 観測点、計測方法、リグレッション観点 |
| `diff_summary` | implementation | 変更差分、影響ファイル |
| `test_report` | implementation | テスト結果、失敗ログ |
| `review_report` | review | レビュー結果、マージ可否 |

## 停止条件（Stop Conditions）

stop_conditions は「検知→判断→遷移」の3点セットで定義。

```yaml
stop_conditions:
  - id: "security_vulnerability_detected"
    detection:
      - "sast_findings.critical > 0"
      - "secret_leak detected"
      - "dependency_cve.severity == high"
    threshold: "any"
    action: "halt_and_escalate"

  - id: "scope_change_detected"
    detection:
      - "affected_modules_count > 3"
      - "new_requirements_added"
    threshold: "any"
    action: "pause_for_approval"

  - id: "test_failure_threshold"
    detection:
      - "test_report.failed_count > 5"
    threshold: "exceeded"
    action: "halt_and_review"

  - id: "time_budget_exceeded"
    detection:
      - "elapsed_minutes > time_budget_minutes"
    threshold: "exceeded"
    action: "pause_for_approval"
```

### action の種類

| action | 説明 |
|--------|------|
| `halt_and_escalate` | 即座に停止し、人間にエスカレーション |
| `pause_for_approval` | 一時停止し、承認を待つ |
| `halt_and_review` | 停止し、レビューを要求 |
| `retry` | 再試行 |
| `rollback` | 前フェーズに戻る |

## 承認ポイント（Approval Points）

```yaml
approval_points:
  - id: "scope_change_approval"
    required_when: "scope_change_detected"
    approver: "human"

  - id: "security_fix_handling"
    required_when: "security_vulnerability_detected"
    approver: "security_team"

  - id: "major_refactor_approval"
    required_when: "type == refactor AND affected_files > 10"
    approver: "tech_lead"
```

## 再開・冪等性

### 再開（Resume）

`resume.workflow_run_id` を指定することで、中断したワークフローを再開可能。

```yaml
# 再開時の入力
input:
  issue_id: "#123"
  resume:
    workflow_run_id: "wf_2025-12-30_abc123"
```

再開時の動作:
1. `workflow_run_id` から状態を復元
2. `current_phase` から継続
3. 完了済みフェーズはスキップ
4. 成果物は既存を再利用

### 冪等性

各フェーズは以下を保証:
- 同じ入力に対して同じ出力
- 成果物が既に存在する場合は再生成をスキップ（`force: true` で上書き可）
- 副作用（コミット、PR作成等）は重複実行を防止

## ワークフローテンプレート

分類に応じて異なるテンプレートを選択。詳細は [references/workflow-templates.md](references/workflow-templates.md) を参照。

### テンプレート一覧

| template_id | 適用条件 | 特徴 |
|-------------|----------|------|
| `trivial_fix_v1` | severity=trivial | intake→implementation→review（簡略化） |
| `minor_bugfix_v1` | severity=minor, type=bugfix | 標準フロー |
| `major_bugfix_v2` | severity=major, type=bugfix | 標準フロー＋強化観測 |
| `critical_hotfix_v1` | severity=critical | 緊急フロー（並列化、承認省略可） |
| `security_fix_v1` | type=security | セキュリティ強化フロー |
| `feature_v1` | type=feature | 設計フェーズ追加 |

## 進捗可視化

出力に必ず含まれる可視化データ:

```yaml
progress:
  percent: 45                    # 完了フェーズ数/総フェーズ数
  current_phase: "implementation"
  phases_completed: ["intake", "context", "uncertainty", "task_decomposition"]
  phases_remaining: ["implementation", "review"]
  updated_at: "2025-12-30T10:30:00Z"

timeline:
  - phase: "intake"
    started_at: "2025-12-30T09:00:00Z"
    completed_at: "2025-12-30T09:05:00Z"
    duration_minutes: 5
  - phase: "context"
    started_at: "2025-12-30T09:05:00Z"
    completed_at: "2025-12-30T09:20:00Z"
    duration_minutes: 15
  # ...

blocking_risks:
  - id: "repro_uncertain"
    description: "再現条件が不安定"
    impact: "high"
    mitigation: "追加ログ収集中"

human_questions:
  - id: "spec_clarification"
    question: "期待仕様はAとBどちら？"
    context: "Issue本文に両方の解釈が可能な記述"
    blocking_phase: "implementation"
```

## 処理フロー

### Step 1: 初期化

1. `issue_id` からIssue情報を取得
2. `/issue-intake` を呼び出して初期分類
3. 分類結果に基づきテンプレート選択
4. `workflow_run_id` を生成
5. 状態を初期化

### Step 2: フェーズ実行ループ

```
for each phase in selected_template.phases:
  1. entry_criteria をチェック
     - 満たさない場合: 前フェーズに問題あり → on_failure 処理

  2. 該当スキルを呼び出し
     - artifacts_in を渡す
     - 結果を artifacts_out に格納

  3. exit_criteria をチェック
     - 満たす場合: status = "completed"
     - 満たさない場合: on_failure 処理

  4. stop_conditions をチェック
     - 該当する場合: action を実行

  5. approval_points をチェック
     - 該当する場合: 承認待ち

  6. progress を更新
```

### Step 3: 完了

1. 全フェーズ完了 → `workflow_status = "completed"`
2. 最終レポート生成
3. 成果物アーカイブ

## 使用例

```
User: Issue #123 を修正して

Claude:
## Workflow Orchestrator 起動

### Issue取得中...
Issue #123: "認証エラーが発生する"

### intake フェーズ実行中...
/issue-intake を呼び出し

### 分類結果
- type: bugfix
- severity: major
- confidence: 0.72

### テンプレート選択
major_bugfix_v2 を適用

### ワークフロープラン
workflow_run_id: wf_2025-12-30_xyz789

| # | phase | status |
|---|-------|--------|
| 1 | intake | completed |
| 2 | context | in_progress |
| 3 | onboarding | pending |
| 4 | uncertainty | pending |
| 5 | task_decomposition | pending |
| 6 | observation | pending |
| 7 | implementation | pending |
| 8 | review | pending |

### 現在のフェーズ: context
/eld-sense-activation を実行中...

続行しますか？
```

## リファレンス

- [references/classification.md](references/classification.md) - 分類の詳細定義
- [references/phase-definitions.md](references/phase-definitions.md) - 各フェーズの詳細
- [references/artifact-contracts.md](references/artifact-contracts.md) - 成果物スキーマ
- [references/workflow-templates.md](references/workflow-templates.md) - テンプレート定義
