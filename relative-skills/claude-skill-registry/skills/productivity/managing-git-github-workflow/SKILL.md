---
name: managing-git-github-workflow
description: Git操作(add, commit, switch, push)とGitHub CLI(PR作成・編集、Issue作成、コメント取得)を実行。コミット作成、ブランチ管理、プルリクエスト作成・編集、Issue管理が必要な場合に使用。「コミットして」「PRを作成」「Issueを作成」「ブランチを切って」などのリクエストで起動。
allowed-tools: Bash, Read, Grep, Glob
---

# Git & GitHub ワークフロー

## 基本ワークフロー

1. ブランチ作成
2. 変更のコミット
3. リモートへプッシュ
4. PR作成
5. レビュー対応・確認

## コミット規約

日本語で簡潔に。タイプ例: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

```bash
git commit -m "feat: 新機能の概要"
```

詳細なテンプレートは [references/commit-templates.md](references/commit-templates.md) を参照。

## ブランチ作成とコミット

```bash
# mainは保護されているため新ブランチで作業
git switch -c feature-<機能名>

git add .
git commit -m "feat: 変更内容"

# コミット後の確認
git log -1

git push -u origin feature-<機能名>

# プッシュ後の確認
git status
```

## PR作成

HEREDOCで複数行のボディを作成:

```bash
gh pr create --title "feat: 機能追加" --body "$(cat <<'EOF'
## 概要
変更の概要

## 変更内容
- 詳細1
- 詳細2

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

詳細なPRテンプレートは [references/pr-templates.md](references/pr-templates.md) を参照。

## PR編集・確認

```bash
# PR確認
gh pr view <PR番号>
gh pr view <PR番号> --comments

# ボディ編集
gh pr edit <PR番号> --body "$(cat <<'EOF'
更新内容
EOF
)"

# コメント詳細取得
gh api repos/{owner}/{repo}/pulls/<PR番号>/comments
```

## Issue作成

```bash
gh issue create --title "タイトル" --body "$(cat <<'EOF'
## 問題の説明
詳細

## 再現手順
1. ステップ1
2. ステップ2
EOF
)"
```

詳細なIssueテンプレートは [references/issue-templates.md](references/issue-templates.md) を参照。

## 注意事項

- mainブランチでは直接作業しない
- コミットメッセージは日本語
- Co-Authored-By等の作成者情報は不要
