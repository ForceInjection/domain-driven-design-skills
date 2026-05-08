---
name: branch-creator
description: Issue 番号に基づいて feature ブランチを自動作成する。「ブランチ作成」「ブランチを作って」「新しいブランチ」「feature ブランチ」「Issue からブランチ」「作業ブランチを作成」「ブランチ切って」などで起動。feature/[issue番号] 形式でブランチを作成。
allowed-tools: [Read, Bash]
---

# Branch Creator

Issue 番号に基づいて feature ブランチを自動作成します。

## ワークフロー

### 1. Issue 番号の確認

ユーザーに Issue 番号を確認。または以下から推測:

- 直前の会話コンテキスト
- 「Issue #5 のブランチを作って」のような指示

### 2. Issue 情報の取得

```bash
gh issue view {issue番号} --json title,labels
```

### 3. ブランチ名の決定

**命名規則**:

| Issue タイプ | ブランチ形式 |
|--------------|--------------|
| 機能追加（enhancement） | `feature/{issue番号}` |
| バグ修正（bug） | `fix/{issue番号}` |
| ドキュメント（documentation） | `docs/{issue番号}` |
| リファクタリング | `refactor/{issue番号}` |
| その他 | `feature/{issue番号}` |

### 4. ブランチ作成

```bash
# main ブランチから最新を取得
git fetch origin main
git checkout main
git pull origin main

# 新しいブランチを作成
git checkout -b feature/{issue番号}
```

### 5. 結果報告

```
ブランチ `feature/{issue番号}` を作成しました。

関連 Issue: #{issue番号} - {issue タイトル}

作業を開始できます。
```

## 重要な注意事項

- ✅ main ブランチから派生
- ✅ Issue 番号をブランチ名に含める
- ✅ Issue タイプに応じたプレフィックス
- ❌ 既存ブランチを上書きしない
- ❌ main ブランチ以外から派生しない（明示的な指示がない限り）
