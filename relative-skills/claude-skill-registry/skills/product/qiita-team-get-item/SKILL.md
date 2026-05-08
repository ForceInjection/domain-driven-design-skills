---
name: qiita_team_get_item
description: 社内Qiita:Teamのドキュメントコンテンツを取得する。コード内のコメントやドキュメントにQiita:TeamのURL（https://[team_id].qiita.com/[user_id]/items/[item_id]形式）が含まれている場合に使用する
allowed_tools:
  - Bash(qiita get_item:*)
---

# Qiita:Team ドキュメント取得

このスキルは、認証が必要な社内Qiita:Teamのドキュメントを取得します。

## 概要

- 公開Qiita（`https://qiita.com/`）の記事は標準のWebFetchツールで取得可能
- 社内Qiita:Team（`https://[team_id].qiita.com/[user_id]/items/[item_id]`）の記事は認証が必要なため、このスキルを使用する

## 使用タイミング

以下のような場合にこのスキルを使用する：

1. コード内のコメントにQiita:TeamのURLが含まれている
2. ユーザーがQiita:Teamの記事を参照するよう指示した
3. 実装の参考資料としてQiita:Teamのドキュメントを確認する必要がある

## Instructions

### 1. URLの解析

Qiita:TeamのURLから以下の情報を抽出する：
- URL形式: `https://[team_id].qiita.com/[user_id]/items/[item_id]`
- `team_id`: チームID（サブドメイン部分）
- `user_id`: 投稿ユーザーID（共同編集の場合は`shared`）
- `item_id`: 記事ID（パスの最後の部分）

### 2. コンテンツの取得

Bashツールを使用して以下のコマンドを実行する：

```bash
echo '{}' | qiita get_item [item_id] --team [team_id] | jq -r .body
```

パラメータ：
- `[item_id]`: 手順1で抽出した記事ID
- `[team_id]`: 手順1で抽出したチームID
- 注意: `[user_id]`部分はコマンドには不要（item_idのみで記事を特定できる）

### 3. 結果の処理

- コマンドが成功した場合: 記事本文（Markdown形式）が出力される
- コマンドが失敗した場合: エラーメッセージを確認し、ユーザーに報告する

## Examples

### Example 1: コード内のコメントから記事を取得

```
# コード内のコメント:
# 参考: https://myteam.qiita.com/user_id/items/abc123def456
# または: https://myteam.qiita.com/shared/items/789abc012def

# 実行するコマンド（ユーザー投稿でも共同編集でも同じ形式）:
echo '{}' | qiita get_item abc123def456 --team myteam | jq -r .body
echo '{}' | qiita get_item 789abc012def --team myteam | jq -r .body
```

注意: URLのユーザーID部分（`user_id`や`shared`）はコマンドには不要です。`item_id`と`team_id`のみを使用します。

### Example 2: ユーザーの直接指示

ユーザー: 「このQiita:Teamの記事を確認して: `https://myteam.qiita.com/shared/items/789abc012def` 」

```bash
echo '{}' | qiita get_item 789abc012def --team myteam | jq -r .body
```

## 注意事項

- 認証設定済みの`qiita`コマンドが必要（事前設定済み）
- qiitaコマンドの実装にはincrements/qiita-cliとincrements/qiita-rbの2種類が存在するが、このスキルではqiita-rbを使用
- `echo '{}' |` の部分は、Claude Code経由でqiitaコマンドを使用する場合の標準入力の取り扱いに関する技術的な制約に対する回避策であり、省略不可
