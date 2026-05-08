---
name: eld-sense-task-decomposition
description: |
  PCE (Process-Context Engine) のタスク分解スキル。親→子→孫の入れ子構造でタスクを分解し、各プロセスへのコンテキスト継承を設計する。

  トリガー条件:
  - 大きなタスクを受け取った時
  - 「このタスクを分解して」
  - 「実装計画を立てて」
  - 「作業を整理して」
  - 複雑な機能の実装開始時
---

# PCE Task Decomposition Skill

タスクを入れ子構造で分解し、各レベルでのコンテキスト継承を設計する。

## 分解の原則

1. **3段階まで**: 親→子→孫の3レベルを上限とする
2. **単一責務**: 各タスクは1つの責務に集中
3. **独立性**: 可能な限り並列実行可能に
4. **境界明確**: 責務の重複・漏れを防ぐ

## 分解テンプレート

```markdown
# Task Decomposition: [親タスク名]

## Level 0: Root Task
**Goal**: [全体目標]
**Constraints**: [全体制約]
**Success Criteria**: [完了条件]

## Level 1: Major Components
### 1.1 [子タスク1]
- Goal: [目的]
- Boundary: [責務境界]
- Dependencies: [依存関係]
- Parallel: Yes/No

### 1.2 [子タスク2]
...

## Level 2: Sub-tasks (必要な場合)
### 1.1.1 [孫タスク1]
...

## Context Inheritance Map
| From | To | Inherit | Return |
|------|-----|---------|--------|
| Root | 1.1 | [継承情報] | [戻す情報] |
```

## 分解パターン

### パターン1: 機能分割
```
機能A実装
├── データ層
├── ビジネスロジック層
└── API層
```

### パターン2: フェーズ分割
```
機能A実装
├── 設計フェーズ
├── 実装フェーズ
└── テストフェーズ
```

### パターン3: ドメイン分割
```
Eコマース機能
├── 商品管理
├── カート管理
└── 決済処理
```

## 使用例

```
User: ユーザー認証システムを実装して

Claude:
# Task Decomposition: ユーザー認証システム

## Level 0: Root Task
**Goal**: JWT認証による安全なユーザー認証
**Constraints**: OWASP準拠、既存DBスキーマ活用
**Success Criteria**: ログイン/ログアウト/リフレッシュ動作

## Level 1: Major Components

### 1.1 認証コア
- Goal: JWTトークン生成・検証
- Boundary: トークン操作のみ、ユーザー管理は含まない
- Dependencies: なし
- Parallel: Yes

### 1.2 ユーザーセッション管理
- Goal: セッション状態の管理
- Boundary: セッションのみ、認証ロジックは含まない
- Dependencies: 1.1
- Parallel: No

### 1.3 API エンドポイント
- Goal: /auth/* のREST API
- Boundary: HTTPインターフェースのみ
- Dependencies: 1.1, 1.2
- Parallel: No

### 1.4 テスト
- Goal: 単体テスト + 統合テスト
- Dependencies: 1.1-1.3
- Parallel: No

## Context Inheritance Map
| From | To | Inherit | Return |
|------|-----|---------|--------|
| Root | 1.1 | ADR-003, セキュリティ要件 | トークン仕様 |
| Root | 1.2 | セッション要件 | セッション設計 |
| 1.1 | 1.3 | トークン仕様 | API仕様 |

分解完了。1.1から開始しますか？
```
