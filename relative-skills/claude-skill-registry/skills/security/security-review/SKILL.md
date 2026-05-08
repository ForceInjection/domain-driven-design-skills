---
name: security-review
description: セキュリティ脆弱性を自動検出する。認証情報のハードコード、コマンドインジェクション、危険なシェル構文などをチェック。
---

# Security Review Skill

Claude がコード変更時に自動的に適用する、セキュリティ観点のチェックと警告能力。

## 自動適用条件

- すべてのシェルスクリプト変更時（`.sh`, `.bash`, `.zsh`）
- 設定ファイル変更時（`.bashrc`, `.zshrc`, `.gitconfig` 等）
- 特に以下のパターンで重点チェック:
  - 環境変数の設定
  - 外部コマンドの実行
  - ファイル操作

## 検出パターン

### 1. ハードコードされた認証情報

```bash
# ❌ 危険: ハードコード
export API_KEY="sk-xxxxxxxxxxxx"
PASSWORD="secret123"
TOKEN="Bearer eyJhbGci..."

# ✅ 安全: 環境変数から取得（別ファイルで管理）
export API_KEY="${API_KEY:-}"
# または .env ファイルから読み込み（.envはgitignore）
```

### 2. コマンドインジェクション

```bash
# ❌ 危険: 変数未クォート
rm $filename
cat $user_input

# ❌ 危険: eval使用
eval "$user_command"

# ✅ 安全: 変数クォート
rm "$filename"
cat "$user_input"

# ✅ 安全: evalを避ける
"$user_command"  # 直接実行（信頼できる場合のみ）
```

### 3. 危険なシェル構文

```bash
# ❌ 危険: バッククォート（ネスト問題）
result=`command`

# ❌ 危険: 変数展開のクォート忘れ
if [ $var = "value" ]; then

# ✅ 安全: $() を使用
result=$(command)

# ✅ 安全: 変数をクォート
if [ "$var" = "value" ]; then
```

### 4. ファイル権限の問題

```bash
# ❌ 危険: 過度な権限
chmod 777 script.sh
chmod a+w config.sh

# ✅ 安全: 最小限の権限
chmod 755 script.sh  # 実行可能スクリプト
chmod 644 config     # 設定ファイル（読み取りのみ）
```

### 5. パス・ファイル名のインジェクション

```bash
# ❌ 危険: ユーザー入力をパスに使用
cat "/tmp/$user_input"

# ✅ 安全: バリデーション付き
if [[ "$user_input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    cat "/tmp/$user_input"
fi
```

## 重大度レベル

| レベル | 説明 | 対応 |
|--------|------|------|
| **Critical** | 認証情報露出、コマンドインジェクション | 即時修正必須 |
| **High** | 変数クォート漏れ、eval使用 | コミット前に修正 |
| **Medium** | ファイル権限問題、バッククォート使用 | 計画的に修正 |
| **Low** | ベストプラクティス違反 | 改善推奨 |

## 自動アクション

1. **Critical/High** を検出したら、コミット前に警告を表示
2. 修正案を具体的に提示
3. セキュリティ関連の変更は `/review --security` を推奨

## チェックリスト

- [ ] ハードコードされた認証情報がない
- [ ] すべての変数が適切にクォートされている
- [ ] `eval` を使用していない
- [ ] ファイル権限が最小限に設定されている
- [ ] ユーザー入力がサニタイズされている
