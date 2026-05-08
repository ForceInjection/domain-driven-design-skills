---
name: eld-sense-scope
description: |
  PCE (Process-Context Engine) のスコープ管理スキル。入れ子プロセス間のコンテキスト継承を設計し、親子間のハンドオフを最適化する。

  トリガー条件:
  - タスクを子タスクに分解する時
  - サブエージェントに作業を委譲する時（Task tool使用時）
  - 並列タスクを起動する時
  - 「このタスクを分割して」
  - 「サブタスクのコンテキストを設計して」
---

# PCE Scope Skill

入れ子プロセス（親→子→孫）間のコンテキスト継承範囲を設計する。

## スコープ設計の原則

### 親→子へ渡すもの（最小コンテキスト）
```yaml
to_child:
  goal: 子タスクの目的（親目的との関係）
  constraints: 子に適用される制約のみ
  references: 必要な参照のみ（フルパス）
  boundary: 子の責務範囲の明確な境界
```

### 子→親へ戻すもの（要約+差分）
```yaml
from_child:
  summary: 成果の要約（3行以内）
  artifacts: 生成した成果物リスト
  decisions: 子が行った重要な決定
  issues: 発見した問題・懸念
  delta: 潜在プールへ追加すべき知見
```

## スコープ破綻の防止

| 問題 | 症状 | 対策 |
|------|------|------|
| 過剰継承 | 子がノイズで混乱 | 最小コンテキストに絞る |
| 過少継承 | 子が前提を誤認 | 必須参照を明示 |
| 境界曖昧 | 責務が重複・漏れ | boundary明確化 |
| 差分欠落 | 親が子の学びを失う | deltaを必須化 |

## 継承設計テンプレート

```markdown
## Task: [親タスク名]

### Subtask 1: [子タスク名]
**Goal**: [子の目的]
**Boundary**: [責務の境界]
**Inherit**:
  - [継承する参照1]
  - [継承する参照2]
**Return**:
  - summary
  - artifacts
  - delta
```

## 使用例

```
User: API実装タスクを3人で分担したい

Claude:
## 親タスク: REST API実装

### Subtask 1: 認証エンドポイント
**Goal**: /auth/* の実装
**Boundary**: 認証のみ、認可は含まない
**Inherit**:
  - docs/adr/ADR-003.md
  - src/models/user.ts
**Return**: 実装ファイル + 認可境界の懸念

### Subtask 2: ユーザー管理エンドポイント
**Goal**: /users/* のCRUD
**Boundary**: ユーザーのみ、権限管理は含まない

### Subtask 3: API共通基盤
**Goal**: エラーハンドリング、バリデーション
**Boundary**: 横断的関心事のみ
```
