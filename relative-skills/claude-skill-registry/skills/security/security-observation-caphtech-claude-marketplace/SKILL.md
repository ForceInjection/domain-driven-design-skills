---
name: security-observation
description: "セキュリティ観測。認可漏れ、インジェクション、機密漏えい、暗号誤用、依存脆弱性を検出。Use when: 認証/認可実装、外部入力処理、依存更新、コミット前チェック、セキュリティレビューして、脅威分析が必要な時。"
---

# Security Observation（セキュリティ観測）

## 目的

セキュリティバグは生成コードで最も"損失が大きい"失敗モードで、レビューで見落としやすい。
このスキルは、**破局（情報漏えい・不正操作）の確率を下げる**。

## 観測の恩恵

- 破局（情報漏えい・不正操作）の確率を下げる
- "悪用可能性"という視点を、実装前に持ち込める
- セキュリティ事故は再発しやすいので、観測がそのまま再発防止策になる

## Procedure

### Step 0: 信頼境界と資産の列挙（ミニ脅威分析）

以下の3点を明確化する（これがないとテストも静的解析も焦点が合わない）：

| 観点 | 質問 |
|------|------|
| 境界 | どこからが外部入力か？ |
| 資産 | 守るべきデータは何か？ |
| 権限 | 誰が何をできるべきか？ |

### Step 1: Secret Scan

鍵・トークン・パスワードの混入をスキャン：

```bash
# gitleaks
gitleaks detect --source . --verbose

# truffleHog
trufflehog filesystem .

# git-secrets
git secrets --scan
```

### Step 2: 依存の脆弱性スキャン

lockfile前提で脆弱性をスキャン：

```bash
# Node.js
npm audit

# Python
pip-audit

# Go
govulncheck ./...

# Rust
cargo audit
```

### Step 3: 認可の否定テスト

**権限がない主体で必ず失敗する**ことを検証：

```python
def test_admin_endpoint_requires_admin_role():
    # 一般ユーザーでログイン
    token = login_as("user@example.com")

    # 管理者エンドポイントへアクセス → 403
    response = client.get("/admin/users", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403
```

**チェックすべき境界**：
- 各エンドポイント × 各ロール
- リソースの所有権（自分のデータのみアクセス可能か）
- 水平権限昇格（他ユーザーのリソースへのアクセス）
- 垂直権限昇格（上位ロールの機能へのアクセス）

### Step 4: 入力汚染テスト

攻撃っぽい入力を当てる：

```python
MALICIOUS_INPUTS = [
    "'; DROP TABLE users; --",           # SQLi
    "<script>alert('xss')</script>",     # XSS
    "../../../etc/passwd",               # Path traversal
    "{{7*7}}",                            # SSTI
]

@pytest.mark.parametrize("payload", MALICIOUS_INPUTS)
def test_input_is_sanitized(payload):
    response = client.post("/api/search", json={"query": payload})
    # 実行されずエスケープされていること、または拒否されること
    assert response.status_code in [200, 400]
    assert payload not in response.text  # 反射されていない
```

### Step 5: 運用観測（検知と証跡）

- **監査ログ**: 誰が何をしたか
- **認可失敗メトリクス**: 急増は攻撃やバグの兆候
- **レート制限**: 観測があって初めて作動する

## 最小セット

- **(D1)** Secret scan
- **(D2)** 依存脆弱性スキャン（lockfile固定込み）
- **(D3)** 認可の否定テストを"境界（エンドポイント/操作）ごとに最低1つ"

## 脅威カタログ

詳細は `references/threat-catalog.md` を参照。

## Outputs

- 信頼境界図（簡易）
- Secret scan設定（.gitleaks.toml等）
- 認可否定テストコード
- 入力汚染テストコード

## Examples

### 簡易信頼境界図

```
                    ┌─────────────────────────────────────┐
                    │           信頼境界内                 │
                    │  ┌─────────┐    ┌─────────────┐    │
  ─────────────────►│  │   API   │───►│  Database   │    │
  外部入力           │  │ Gateway │    │ (資産: PII) │    │
  (信頼境界外)       │  └─────────┘    └─────────────┘    │
                    │       │                            │
                    │       ▼                            │
                    │  ┌─────────────┐                   │
                    │  │ Auth Service│                   │
                    │  │ (資産: 認証情報)               │
                    │  └─────────────┘                   │
                    └─────────────────────────────────────┘
```

### 認可マトリクス

| エンドポイント | anonymous | user | admin | owner_only |
|---------------|-----------|------|-------|------------|
| GET /public   | ✅        | ✅   | ✅    | -          |
| GET /profile  | ❌        | ✅   | ✅    | self       |
| PUT /profile  | ❌        | ✅   | ✅    | self       |
| GET /admin    | ❌        | ❌   | ✅    | -          |
| DELETE /users | ❌        | ❌   | ✅    | -          |
