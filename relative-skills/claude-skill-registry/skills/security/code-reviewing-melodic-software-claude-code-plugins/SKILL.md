---
name: code-reviewing
description: |
  高品質なコードレビューを実施するスキル。セキュリティ、パフォーマンス、保守性、
  アーキテクチャの観点から包括的にレビューし、Must/Should/Nice to haveで
  優先順位付けした建設的なフィードバックを提供します。
---

# Code Reviewing Skill

体系的で建設的なコードレビューを実施するスキル。

## 対応観点

| 観点 | フォーカス | 詳細ガイド |
|------|-----------|-----------|
| Security | SQLi, XSS, 認証/認可, 機密情報 | `./agents/security-reviewer.md` |
| Architecture | レイヤー分離, 依存関係, 責務分離 | `./agents/architecture-reviewer.md` |
| Test | カバレッジ, テストケース設計, TDD準拠 | `./agents/test-reviewer.md` |
| Performance | N+1問題, アルゴリズム効率, メモリ | `./agents/performance-reviewer.md` |

## 判断フロー

```
レビュー対象の規模は？
│
├─ 大規模（10+ファイル、500+行）──→ ✅ サブエージェント並列レビュー
│
├─ 中規模（4-9ファイル、100-500行）─→ ✅ 直接レビュー（全観点）
│
├─ 小規模（1-3ファイル、100行以下）─→ ✅ 直接レビュー（軽量）
│
├─ 特定観点のみ ───────────────────→ ✅ 該当観点のみレビュー
│
└─ PoC・プロトタイプ ──────────────→ ❌ スキップ可
```

## サブエージェント並列レビュー

大規模PRや包括的レビューが必要な場合、専門サブエージェントを並列起動。

```
┌──────────────────────────────────────────────────────────────┐
│ 1. 準備フェーズ                                              │
│    └── レビュー対象のスコープ確認                            │
├──────────────────────────────────────────────────────────────┤
│ 2. 並列レビューフェーズ（サブエージェント起動）              │
│    ├── Security Reviewer   → セキュリティ観点                │
│    ├── Architecture Reviewer → アーキテクチャ観点            │
│    ├── Test Reviewer       → テスト観点                      │
│    └── Performance Reviewer → パフォーマンス観点             │
├──────────────────────────────────────────────────────────────┤
│ 3. 統合フェーズ                                              │
│    └── 結果を統合し、優先順位付け                            │
├──────────────────────────────────────────────────────────────┤
│ 4. フィードバックフェーズ                                    │
│    └── Must / Should / Nice to have で整理して出力           │
└──────────────────────────────────────────────────────────────┘
```

## レビューワークフロー（6ステップ）

```
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    ▼                                                             │
┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐  │
│準備    │──→│第一印象│──→│詳細    │──→│コンテ  │──→│フィード│  │
│        │   │        │   │レビュー│   │キスト  │   │バック  │  │
└────────┘   └────────┘   └────────┘   └────────┘   └────────┘  │
                                                        │        │
                                                        ▼        │
                                                   ┌────────┐   │
                                                   │承認判断│───┘
                                                   └────────┘
```

### Step 1: 準備

- PRのタイトル・説明・関連Issue確認
- 変更範囲の把握（ファイル数・行数）
- CI/CD・Linter・テスト結果の確認

### Step 2: 第一印象

- ファイル構成・アーキテクチャの妥当性
- 変更量の適切さ（1PR = 1機能が理想）
- 明らかなセキュリティ・設計上の問題

### Step 3: 詳細レビュー（優先順位順）

| 順位 | 観点 | チェック項目 |
|:---:|------|-------------|
| 1 | セキュリティ | 入力バリデーション, SQLi/XSS対策, 認証/認可, 機密情報 |
| 2 | 機能性 | 要件充足, バグ, エッジケース, エラーハンドリング |
| 3 | アーキテクチャ | レイヤー分離, 依存関係方向, 責務分離 |
| 4 | テスト | テスト有無, カバレッジ, 正常系/異常系/境界値 |
| 5 | 可読性 | 命名, 定数化, DRY, 関数長 |
| 6 | パフォーマンス | N+1問題, ループ効率, アルゴリズム |

### Step 4: コンテキストレビュー

- 変更が既存コードに与える影響
- インターフェース変更の影響範囲
- 既存テストへの影響

### Step 5: フィードバック作成

**3原則**:
1. **優先順位を明確に**: Must / Should / Nice to have
2. **具体的に**: 問題点 + 理由 + 修正案
3. **ポジティブに**: 良い点も評価

### Step 6: 承認判断

| 判定 | 条件 |
|------|------|
| ✅ Approve | Must全クリア、セキュリティOK、テストOK |
| 💬 Approve with Comments | MustクリアだがShould課題あり |
| 🔄 Request Changes | Must未達、セキュリティ問題、テスト無し |

## フィードバックテンプレート

```markdown
## [優先度] タイトル

### 現状
[問題のあるコード]

### 問題点
[なぜ問題なのか]

### 修正案
[推奨する修正方法]

### 理由
[修正のメリット]
```

### 例：Must（セキュリティ）

```markdown
## [Must] SQLインジェクションの脆弱性

### 現状
query = f"SELECT * FROM users WHERE email = '{email}'"

### 問題点
ユーザー入力を直接SQL文に埋め込んでおり、SQLインジェクション攻撃の危険性があります。

### 修正案
user = db.query(User).filter(User.email == email).first()

### 理由
ORMを使用することでセキュリティリスクを排除し、型安全性も向上します。
```

### 例：ポジティブフィードバック

```markdown
## [Good] エラーハンドリングが素晴らしい

具体的な例外を捕捉し、適切なログを出力し、
ユーザーにわかりやすいエラーメッセージを返している点が良いです。
このパターンを他の箇所でも参考にさせてください。
```

## レビューチェックリスト

### 🔴 Must（必須）

- [ ] セキュリティ上の問題がない
- [ ] 機能要件を満たしている
- [ ] テストが実装されている
- [ ] アーキテクチャが守られている
- [ ] 重大なバグがない

### 🟡 Should（推奨）

- [ ] 命名が適切
- [ ] DRY原則が守られている
- [ ] エラーハンドリングが適切
- [ ] パフォーマンス問題がない
- [ ] コードスタイルが統一されている

### 🟢 Nice to have（改善提案）

- [ ] より良い設計パターン
- [ ] ドキュメント充実
- [ ] 拡張性の考慮

## Backend (Python/FastAPI) レビューポイント

### レイヤー分離

```python
# ❌ Bad: Routerにビジネスロジック
@router.post("/users")
async def create_user(data: UserCreate):
    if not data.email or "@" not in data.email:
        raise HTTPException(400, "Invalid email")
    return await db.create(data)

# ✅ Good: Service層に委譲
@router.post("/users")
async def create_user(
    data: UserCreate,
    service: UserService = Depends(get_user_service)
):
    return await service.create_user(data)
```

### データベース

```python
# ✅ 外部キーはINTEGER + ON DELETE CASCADE
user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))

# ❌ user_uuidを外部キーに使用しない
```

### 型ヒント

```python
# ✅ 完全な型ヒント
def get_user_by_id(self, user_id: int) -> Optional[User]:
    return self.repository.get(user_id)

# ❌ Anyの使用は避ける
```

## Frontend (TypeScript/SvelteKit) レビューポイント

### 型安全性

```typescript
// ✅ Good: 明確な型定義
interface User {
  id: number;
  email: string;
  name: string;
}

function getUser(id: number): Promise<User> { ... }

// ❌ Bad: anyの使用
function getUser(id: number): Promise<any> { ... }
```

### エラーハンドリング

```typescript
// ✅ Good: 適切なエラーハンドリング
async function fetchUser(id: number): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;
  }
}
```

## よくある指摘パターン

| パターン | 問題 | 指摘例 |
|---------|------|--------|
| セキュリティ | SQLi, XSS, 機密情報漏洩 | `[Must] SQLインジェクションの危険性` |
| アーキテクチャ | レイヤー違反, 責務混在 | `[Must] Routerにビジネスロジックが混在` |
| テスト不足 | テスト無し, カバレッジ低 | `[Must] 異常系のテストが不足` |
| パフォーマンス | N+1問題, 非効率ループ | `[Should] N+1問題が発生しています` |
| 可読性 | 不適切な命名, マジックナンバー | `[Should] マジックナンバーを定数化` |

## セルフレビューチェックリスト

PR作成前に自分でチェック：

### 基本
- [ ] PRのタイトル・説明が明確
- [ ] 自動テストがパス
- [ ] Linterエラーなし

### コード
- [ ] 命名が適切
- [ ] マジックナンバーを定数化
- [ ] エラーハンドリングが適切

### テスト
- [ ] テストを実装
- [ ] 正常系・異常系・境界値をカバー

### セキュリティ
- [ ] 入力バリデーションあり
- [ ] 機密情報をハードコードしていない

### アーキテクチャ
- [ ] レイヤー分離が守られている
- [ ] 依存関係の方向が正しい

## レビュー効率化のコツ

1. **小さなPRを推奨**: 1PR = 1機能、300行以内が理想
2. **自動化活用**: Linter、型チェック、テストを事前実行
3. **優先順位明確化**: Must → Should → Nice to have の順
4. **ポジティブフィードバック**: 良い点も積極的に評価

## ベストプラクティス

### DO ✅

- 問題点と修正案をセットで提示
- 理由を説明して学習機会を提供
- 良いコードを積極的に褒める
- Must/Should/Niceで優先順位を明確化
- 小さなPRへの分割を提案

### DON'T ❌

- 理由なく「これは良くない」と言う
- スタイルの好みを押し付ける
- 全てを完璧にしようとする
- ブロッキングコメントを曖昧にする
- 人格攻撃をする

## 参照ファイル

| ファイル | 説明 |
|---------|------|
| `./agents/security-reviewer.md` | セキュリティレビュー詳細 |
| `./agents/architecture-reviewer.md` | アーキテクチャレビュー詳細 |
| `./agents/test-reviewer.md` | テストレビュー詳細 |
| `./agents/performance-reviewer.md` | パフォーマンスレビュー詳細 |
| `.claude/rules/code-review-rules.md` | レビュールール詳細 |
| `.claude/rules/code-style.md` | コードスタイル規約 |
| `.claude/rules/backend/layer-rules.md` | Backendレイヤールール |
