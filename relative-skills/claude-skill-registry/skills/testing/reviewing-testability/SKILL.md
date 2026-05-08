---
name: reviewing-testability
description: >
  TypeScript/Reactアプリケーション向けテスト可能なコード設計パターン。
  トリガー: テスタビリティ, testability, テスト可能, テストしやすい,
  モック, mock, 純粋関数, pure function, 依存性注入, dependency injection, DI,
  副作用, side effect, 副作用分離, テスト困難, hard to test.
allowed-tools: Read, Grep, Glob, Task
---

# テスタビリティレビュー - テストしやすいコード設計

目標: 複雑なモッキングやセットアップなしでテストしやすいコード。

## テスタビリティ指標

| 指標 | 良い | 警告 |
| --- | --- | --- |
| モック複雑性 | シンプルなスタブ | 深いモックチェーン |
| テストセットアップ | < 10行 | > 30行 |
| 依存関係 | 明示的（パラメータ/props） | 隠れた（インポート） |
| 副作用 | 分離されている | ロジックと混在 |
| 状態 | 予測可能 | グローバル/ミュータブル |

## セクションベースのロード

| セクション | ファイル | フォーカス | トリガー |
| --- | --- | --- | --- |
| DI | `references/dependency-injection.md` | 注入可能な依存関係 | 依存性注入, DI, mock |
| 純粋 | `references/pure-functions.md` | 純粋関数、副作用分離 | 純粋関数, 副作用 |
| モックフレンドリー | `references/mock-friendly.md` | インターフェース、ファクトリパターン | モック, テスト困難 |

## クイックチェックリスト

### アーキテクチャ

- [ ] 依存関係が注入可能（ハードコードインポートでない）
- [ ] 純粋コードと不純コードの明確な分離
- [ ] 外部サービス用のインターフェース定義

### コンポーネント

- [ ] Presentationalコンポーネントが純粋（props in, JSX out）
- [ ] イベントハンドラーがテスト用に抽出可能
- [ ] 副作用がhooks/containersに分離

### 状態管理

- [ ] グローバルなミュータブル状態なし
- [ ] 状態更新が予測可能（reducers、純粋関数）
- [ ] テスト用に状態を簡単に初期化可能

## 主要原則

| 原則 | 適用 |
| --- | --- |
| DIP（SOLID） | 具象ではなく抽象に依存 |
| 純粋関数 | 同じ入力 = 同じ出力、副作用なし |
| 明示的依存関係 | 依存関係をパラメータとして渡す |
| 単一責任 | テストする理由は1つ、モックするものは1つ |

## 一般的なパターン

### 依存性注入

```typescript
// Bad: テスト困難: 直接依存
class UserService {
  async getUser(id: string) {
    return fetch(`/api/users/${id}`).then(r => r.json())
  }
}

// Good: テスト可能: 注入可能な依存関係
interface HttpClient {
  get<T>(url: string): Promise<T>
}

class UserService {
  constructor(private http: HttpClient) {}
  async getUser(id: string) {
    return this.http.get<User>(`/api/users/${id}`)
  }
}
```

### 純粋関数

```typescript
// Bad: テスト困難: 副作用がロジックと混在
function calculateDiscount(userId: string) {
  const history = api.getPurchaseHistory(userId) // 副作用
  return history.length > 10 ? 0.2 : 0.1
}

// Good: テストしやすい: 純粋関数
function calculateDiscount(purchaseCount: number): number {
  return purchaseCount > 10 ? 0.2 : 0.1
}
```

### Presentationalコンポーネント

```typescript
// Bad: テスト困難: 内部状態とeffect
function SearchBox() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  useEffect(() => { api.search(query).then(setResults) }, [query])
  return <div>...</div>
}

// Good: テストしやすい: 制御されたコンポーネント
interface SearchBoxProps {
  query: string
  results: SearchResult[]
  onQueryChange: (query: string) => void
}

function SearchBox({ query, results, onQueryChange }: SearchBoxProps) {
  return (
    <div>
      <input value={query} onChange={e => onQueryChange(e.target.value)} />
      <ul>{results.map(r => <li key={r.id}>{r.name}</li>)}</ul>
    </div>
  )
}
```

## 参照

### コア原則

- [@~/.claude/skills/applying-code-principles/SKILL.md](../../skills/applying-code-principles/SKILL.md) - 依存性逆転の原則
- [@~/.claude/skills/applying-code-principles/SKILL.md](../../skills/applying-code-principles/SKILL.md) - テスト困難ならシンプルに

### 関連スキル

- `generating-tdd-tests` - TDDプロセスとテスト生成
- `reviewing-type-safety` - 型がテスタビリティを向上

### 使用エージェント

- `testability-reviewer` - このスキルの主要な使用者
