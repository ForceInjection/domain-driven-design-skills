---
name: backlog-api
description: This skill should be used when the user asks to "create issue", "search issues", "update ticket", "check notifications", mentions "Backlog", "バックログ", "課題", "チケット", discusses project management with Nulab Backlog, or needs to interact with Backlog API for issue tracking.
version: 1.0.0
---

# Backlog API Skill

Nulab Backlogと連携するためのスキル。Bashツールでスクリプトを実行してBacklog APIを呼び出します。

## スクリプトの実行方法

```bash
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts <command> [args...]
```

> **注:** `${CLAUDE_PLUGIN_ROOT}` はClaude Codeが自動的にプラグインのルートディレクトリに展開します。

**環境変数が必要:**
- `BACKLOG_DOMAIN` - Backlogスペースのドメイン（例: mycompany.backlog.com）
- `BACKLOG_API_KEY` - Backlog APIキー

**出力形式:** すべてのコマンドはJSON形式で出力します。

## 利用可能なコマンド

### 情報取得

```bash
# スペース情報
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-space

# 自分の情報
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-myself

# ユーザー一覧
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-users

# 優先度一覧
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-priorities
```

### プロジェクト

```bash
# プロジェクト一覧
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-projects

# プロジェクト詳細
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-project MYPROJ

# 課題種別一覧（課題作成に必要）
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-issue-types MYPROJ

# カテゴリ一覧
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-categories MYPROJ
```

### 課題

```bash
# 課題検索
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-issues --project=123 --status=2 --keyword=バグ --count=20

# 課題詳細
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-issue MYPROJ-123

# 課題作成（JSON形式）
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts create-issue '{"projectId":123,"summary":"タイトル","issueTypeId":456,"priorityId":3}'

# 課題更新（JSON形式）
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts update-issue MYPROJ-123 '{"statusId":3,"comment":"完了しました"}'

# コメント追加
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts add-comment MYPROJ-123 "進捗報告です"

# コメント一覧
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-comments MYPROJ-123
```

### 通知

```bash
# 通知一覧
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-notifications --count=20

# 未読件数
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts count-notifications
```

## 重要: 課題作成の手順

課題を作成するには、事前にIDを取得する必要があります：

1. **プロジェクトIDを取得**
   ```bash
   bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-project MYPROJ
   # → id フィールドを確認
   ```

2. **課題種別IDを取得**
   ```bash
   bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-issue-types MYPROJ
   # → 「タスク」「バグ」等のidを確認
   ```

3. **優先度IDを取得**
   ```bash
   bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-priorities
   # → 通常: 2=高, 3=中, 4=低
   ```

4. **課題作成**
   ```bash
   bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts create-issue '{"projectId":12345,"summary":"課題タイトル","issueTypeId":67890,"priorityId":3,"description":"詳細説明"}'
   ```

## ステータスID（標準設定）

| ID | ステータス |
|----|----------|
| 1 | 未対応 |
| 2 | 処理中 |
| 3 | 処理済み |
| 4 | 完了 |

## get-issues オプション

| オプション | 説明 | 例 |
|-----------|------|-----|
| `--project=ID` | プロジェクトIDで絞り込み | `--project=123` |
| `--status=ID` | ステータスIDで絞り込み | `--status=2` |
| `--priority=ID` | 優先度IDで絞り込み | `--priority=2` |
| `--assignee=ID` | 担当者IDで絞り込み | `--assignee=456` |
| `--keyword=TEXT` | キーワード検索 | `--keyword=バグ` |
| `--count=N` | 取得件数（最大100） | `--count=50` |
| `--offset=N` | オフセット | `--offset=20` |
| `--sort=FIELD` | ソート項目 | `--sort=updated` |
| `--order=asc|desc` | ソート順 | `--order=desc` |

## create-issue パラメータ

| パラメータ | 必須 | 説明 |
|-----------|------|------|
| `projectId` | Yes | プロジェクトID（数値） |
| `summary` | Yes | 課題タイトル |
| `issueTypeId` | Yes | 課題種別ID（数値） |
| `priorityId` | Yes | 優先度ID（数値） |
| `description` | No | 詳細説明 |
| `assigneeId` | No | 担当者ID（数値） |
| `dueDate` | No | 期限日（yyyy-MM-dd） |
| `startDate` | No | 開始日（yyyy-MM-dd） |

## update-issue パラメータ

| パラメータ | 説明 |
|-----------|------|
| `summary` | 新しいタイトル |
| `description` | 新しい説明 |
| `statusId` | 新しいステータスID |
| `priorityId` | 新しい優先度ID |
| `assigneeId` | 新しい担当者ID |
| `dueDate` | 新しい期限日 |
| `comment` | 更新時のコメント |

## エラーハンドリング

| エラー | 原因 | 対処 |
|--------|------|------|
| `BACKLOG_DOMAIN environment variable is required` | 環境変数未設定 | BACKLOG_DOMAINを設定 |
| `BACKLOG_API_KEY environment variable is required` | 環境変数未設定 | BACKLOG_API_KEYを設定 |
| `API Error 401` | 認証エラー | APIキーを確認 |
| `API Error 404` | リソースなし | 課題キー/プロジェクトキーを確認 |
| `API Error 400` | パラメータ不正 | 必須パラメータを確認 |

## 使用例

### 自分が担当の処理中課題を表示

```bash
# 1. 自分のIDを取得
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-myself
# → id: 12345

# 2. 課題検索
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts get-issues --assignee=12345 --status=2
```

### 課題をクローズしてコメント

```bash
bun run ${CLAUDE_PLUGIN_ROOT}/scripts/backlog.ts update-issue MYPROJ-123 '{"statusId":4,"comment":"対応完了しました"}'
```
