---
name: repo-recap
description: Generate a 2025 year-in-review visualization for a repository. Use when user asks for "repo recap", "年間レポート", "yearly summary", "2025 recap", or wants to see repository statistics and contributions. (user)
---

# Repo Recap 2025 - Repository Year in Review Generator

**重要**: Read/Writeツールを使わず、Bashのみで高速に生成します。

## Step 1: データ収集 (並列実行)

以下の4コマンドを**並列で**実行:

```bash
# コマンド1: コミットデータ
git log --since="2025-01-01" --until="2025-12-31" --format="%ad|%aN|%s" --date=format:"%Y-%m-%d|%H|%u" 2>/dev/null

# コマンド2: PR/Issueデータ
gh pr list --state all --search "created:2025-01-01..2025-12-31" --json number,title,author,comments,additions,deletions,changedFiles --limit 100 2>/dev/null || echo "[]"
gh issue list --state all --search "created:2025-01-01..2025-12-31" --json number,title,author,comments --limit 100 2>/dev/null || echo "[]"

# コマンド3: リポジトリ名
basename $(git rev-parse --show-toplevel)

# コマンド4: コントリビューター名寄せマップ (GitHub API から取得)
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
noglob gh api "repos/${REPO}/commits" --paginate --jq '.[] | .commit.author.name + "|" + (.author.login // "unknown")' 2>/dev/null | sort -u
```

コマンド4の出力から名寄せマップを作成:
```
# 出力例:
# Hiroki Nakashima|him0
# him0|him0
# Claude|claude
```
→ `{"Hiroki Nakashima": "him0", "him0": "him0", "Claude": "claude"}` に変換

## Step 2: データをJSONに変換

コミットログの各行を以下の形式に変換（Claude Code内で処理）:
```json
{"date":"2025-12-25","hour":14,"day":4,"name":"Hiroki","message":"fix: bug"}
```

## Step 3: JSON書き出し & HTML生成

**Bashのみで実行** (Read/Writeツール不要):

```bash
# JSONデータを一時ファイルに書き出し
cat > /tmp/recap-data.json << 'JSONEOF'
{
  "repoName": "REPO_NAME_HERE",
  "year": "2025",
  "rawCommits": [RAW_COMMITS_ARRAY],
  "prs": [PRS_ARRAY],
  "issues": [ISSUES_ARRAY],
  "contributorAliases": {"git author name": "github username", ...}
}
JSONEOF

# ジェネレータスクリプトでHTML生成
SKILL_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")"
# プラグインディレクトリのパスを使用
"$HOME/.claude/plugins/cache/him0-claude-marketplace/him0-repo-recap/1.0.0/skills/repo-recap/generate-recap.sh" /tmp/recap-data.json > repo-recap-2025.html

# 一時ファイル削除
rm /tmp/recap-data.json
```

## Step 4: ブラウザで開く

```bash
open repo-recap-2025.html   # macOS
```

## Notes

- テンプレートの読み書きはシェルスクリプトが行うため高速
- GitHub avatarsは `https://github.com/{username}.png` から取得
- 全データはHTML内に埋め込み、オフラインで動作
- **名寄せ機能**: `contributorAliases` で git author name → GitHub username のマッピングを指定すると、同一人物の異なる名前表記を統合して集計
