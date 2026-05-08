---
name: test-guide
description: テストの書き方とTDDの実践ガイド
---

# テストガイド

## TDD（テスト駆動開発）の基本

### Red-Green-Refactor サイクル

1. **Red**: 失敗するテストを書く
2. **Green**: テストが通る最小限の実装をする
3. **Refactor**: コードを改善する（テストは常にグリーン）

### TDD のメリット

- 要件が明確になる
- リグレッションを防げる
- リファクタリングが安全にできる
- ドキュメントとして機能する

## テストの種類

### 単体テスト（Unit Test）

- 個々の関数・コンポーネントをテスト
- 依存関係はモック化
- 高速に実行できる

### 統合テスト（Integration Test）

- 複数のモジュールの連携をテスト
- データベースや API との連携を含む

### E2E テスト（End-to-End Test）

- ユーザーの操作フローをテスト
- ブラウザを使った実際の操作

## テストの書き方

### 命名規則

```typescript
// describe: テスト対象を記述
describe('PropertySearch', () => {
  // it: 期待する動作を記述
  it('should filter properties by rent range', () => {
    // テスト内容
  })

  it('should return empty array when no properties match', () => {
    // テスト内容
  })
})
```

### AAA パターン

```typescript
it('should calculate total rent correctly', () => {
  // Arrange（準備）
  const property = { rent: 80000, managementFee: 5000 }

  // Act（実行）
  const total = calculateTotalRent(property)

  // Assert（検証）
  expect(total).toBe(85000)
})
```

### 良いテストの特徴

- **独立性**: 他のテストに依存しない
- **再現性**: 何度実行しても同じ結果
- **明確性**: 何をテストしているか分かる
- **高速性**: 素早く実行できる

## テストすべき内容

### 必須

- [ ] 正常系（ハッピーパス）
- [ ] 境界値
- [ ] エラーケース
- [ ] null/undefined の処理

### 推奨

- [ ] エッジケース
- [ ] 非同期処理
- [ ] 状態の変化

## モックの使い方

### 基本

```typescript
// API コールのモック
vi.mock('@/api/properties', () => ({
  fetchProperties: vi.fn(() => Promise.resolve([
    { id: 1, name: 'テスト物件' }
  ]))
}))
```

### 注意点

- モックは最小限に
- 実装の詳細ではなく振る舞いをテスト
- モックが多すぎる場合は設計を見直す

## アンチパターン

### ❌ 避けるべきこと

- 実装の詳細をテスト
- テスト間の依存
- 不安定なテスト（Flaky Test）
- テストのためだけのコード変更
- 過度なモック

### ✅ 推奨すること

- 振る舞いをテスト
- 1つのテストで1つのことを検証
- 分かりやすいテスト名
- テストも保守しやすく書く
