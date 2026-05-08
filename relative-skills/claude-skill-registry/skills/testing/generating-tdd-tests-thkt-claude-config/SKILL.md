---
name: generating-tdd-tests
description: >
  RGRCサイクルとBaby Steps方法論を用いたTDD。トリガー: TDD, テスト駆動開発,
  Red-Green-Refactor, Baby Steps, test generation, テスト生成, テスト設計,
  テストケース, boundary value, 境界値分析, coverage, カバレッジ, unit test
allowed-tools: Read, Write, Edit, Grep, Glob, Task
---

# TDDテスト生成

## 目的

RGRCサイクル、Baby Steps、テスト設計技法を組み合わせた体系的なテスト駆動開発。

## Baby Steps - 2分サイクル

**「各ステップで可能な最小の変更を行う」** - t_wada

| ステップ | 時間 | アクション |
| --- | --- | --- |
| 1 | 30秒 | 最小の失敗テストを作成 |
| 2 | 1分 | 最小限でパスさせる |
| 3 | 10秒 | テスト実行 |
| 4 | 30秒 | 小さなリファクタ（必要なら） |
| 5 | 20秒 | グリーンならコミット |

**理由**: バグは常に最後の2分の変更にある。常にグリーンまで数秒。

## RGRCチェックリスト

コピーして進捗を追跡:

```markdown
TDDサイクル:
- [ ] Red - 失敗するテスト作成（正しい失敗理由を確認）
- [ ] Green - 最小限のコードで通過（dirtyでもOK）
- [ ] Refactor - コード改善（テストをグリーンに保つ）
- [ ] Commit - 変更をコミット（すべてのチェックをパス）
```

### フェーズ詳細

| フェーズ | 目標 | ルール |
| --- | --- | --- |
| Red | 失敗テスト | 失敗理由が正しいことを確認 |
| Green | テストをパス | 「罪を犯してよい」- quick/dirty OK |
| Refactor | クリーンなコード | SOLID/DRYを適用、グリーンを保つ |
| Commit | 状態を保存 | すべてのチェックをパス |

## テスト設計技法

| 技法 | 用途 | 例 |
| --- | --- | --- |
| 同値分割 | 同じ振る舞いの入力をグループ化 | 年齢: <18, 18-120, >120 |
| 境界値 | 境界をテスト | 17, 18, 120, 121 |
| 決定表 | 複雑な複数条件ロジック | isLoggedIn × isPremium → access |

## カバレッジ目標

| レベル | ターゲット | フォーカス |
| --- | --- | --- |
| C0（ステートメント） | 80% | すべての行を実行 |
| C1（ブランチ） | 70% | すべてのブランチを通過 |

**これらのターゲットの理由**: コスト効果バランス、クリティカルパスにフォーカス。

## AAAパターン

```typescript
test('説明的な名前', () => {
  // Arrange - セットアップ
  // Act - 実行
  // Assert - 検証
})
```

## TDDを使わないとき

- プロトタイプ（使い捨てコード）
- 外部API統合（モックを使用）
- シンプルな一回限りのスクリプト
- UI実験（ビジュアル優先）

## テスト優先度マトリクス

すべてをテストする必要はない。影響度で優先順位付け。

### [優先度1] 必須テスト

- **ビジネスロジック**: 計算、バリデーション、状態遷移
- **Service/Repositoryレイヤー**: シンプルなCRUD以上のデータ操作
- **クリティカルパス**: 課金、認証、データ永続化
- **エッジケース**: 境界値、null/undefined、空配列

### [優先度2] 状況次第

- **ユーティリティ関数**: 複雑なもののみ
- **カスタムフック**: 状態管理ロジック部分
- **変換**: 複雑なマッピング/フォーマット

### [スキップ] テスト不要

- シンプルなプロパティアクセサ/ゲッター
- UIレイアウト/スタイリング
- 外部ライブラリの動作検証
- プロトタイプ/実験コード
- シンプルなCRUD（フレームワーク提供）
- 設定ファイル読み込み

**判断基準**: 「このロジックが壊れたらユーザーに影響するか？」

## 命名規則（Jest/Vitest）

一貫した命名でテストの意図を明確に。

### 推奨パターン

```typescript
describe('[対象クラス/関数名]', () => {
  describe('[メソッド名/シナリオ]', () => {
    it('when [条件], should [期待結果]', () => {
      // Arrange - Act - Assert
    })
  })
})
```

### 例

```typescript
describe('PriceCalculator', () => {
  describe('calculateTotal', () => {
    it('when empty array, should return 0', () => {
      expect(calculator.calculateTotal([])).toBe(0)
    })

    it('when discount code applied, should return discounted total', () => {
      const items = [{ price: 1000, quantity: 2 }]
      expect(calculator.calculateTotal(items, 'SAVE10')).toBe(1800)
    })

    it('when tax included, should return total with correct tax', () => {
      const items = [{ price: 1000, quantity: 1 }]
      expect(calculator.calculateTotal(items, null, { includeTax: true })).toBe(1100)
    })
  })
})
```

### 命名ガイドライン

| 要素 | 良い | 悪い |
| --- | --- | --- |
| 条件 | `when empty array` | `test1` |
| 期待 | `should return 0` | `works correctly` |
| コンテキスト | `when discount applied` | `discount` |

**ヒント**: ドキュメントとして機能する説明的な名前を使用

## test-generatorエージェントパターン

test-generatorエージェントは仕様やバグ記述からテストスケルトンを作成。

### パターン1: 仕様駆動生成（機能開発）

**ユースケース**: `/code`コマンドでspec.mdからテストを生成

```typescript
Task({
  subagent_type: "test-generator",
  description: "仕様からスキップテストを生成",
  prompt: `
機能: "${featureDescription}"
仕様: ${specContent}

SKIPモードでテストを生成:
1. FR-xxx要件 → スキップテストケース
2. Given-When-Thenシナリオ → スキップ実行可能テスト
3. テスト順序: シンプル → 複雑（Baby Steps順）
4. フレームワーク適切なスキップマーカーを使用:
   - Jest/Vitest: it.skip() + // TODO: [SKIP]コメント
  `
})
```

### パターン2: バグ駆動生成（バグ修正）

**ユースケース**: `/fix`コマンドでリグレッションテストを生成

```typescript
Task({
  subagent_type: "test-generator",
  description: "バグ修正のリグレッションテストを生成",
  prompt: `
バグ: "${bugDescription}"
根本原因: "${rootCause}"
適用した修正: "${fixSummary}"

生成:
1. 元のバグを再現するテスト（今は通るはず）
2. 修正に関連するエッジケーステスト
3. コンポーネント間修正の場合は統合テスト
  `
})
```

### パターン3: カバレッジ駆動生成

**ユースケース**: カバレッジ向上のためのテスト追加

```typescript
Task({
  subagent_type: "test-generator",
  description: "未カバーコードパスのテストを生成",
  prompt: `
ファイル: ${filePath}
未カバー行: ${uncoveredLines}
既存テストスタイル: ${testStyle}

未カバーコードパスのテストを生成。
目標カバレッジ: 80%+
  `
})
```

## フレームワーク別スキップマーカー

| フレームワーク | スキップ構文 |
| --- | --- |
| Jest/Vitest | `it.skip('test', () => { // TODO: [SKIP] FR-001 })` |
| Mocha | `it.skip('test', function() { })` または `xit('test', ...)` |
| 不明 | `// TODO: [SKIP]`マーカー付きでコメントアウト |

## ベストプラクティス

| プラクティス | 良い | 悪い |
| --- | --- | --- |
| コンテキスト | 具体的な要件 | 「テストを生成」 |
| マーカー | FR-xxx付きの明確なスキップマーカー | マーカーなし |
| 順序 | シンプル → 複雑（Baby Steps） | ランダム順 |
| フォーカス | テストごとに1つの振る舞い | 複数のアサーション |

## 参照

### 原則（rules/）

- [@~/.claude/rules/development/TDD_RGRC.md](~/.claude/rules/development/TDD_RGRC.md) - 完全なTDD方法論

### スキル参照

- [@./references/tdd-rgrc.md](./references/tdd-rgrc.md) - 完全なRGRCガイド
- [@./references/test-design.md](./references/test-design.md) - テスト設計技法
- [@./references/feature-driven.md](./references/feature-driven.md) - 機能駆動TDDワークフロー
- [@./references/bug-driven.md](./references/bug-driven.md) - バグ駆動TDDワークフロー

### 関連スキル

- `applying-code-principles` - コード原則適用

### 使用コマンド

- `/code` - TDD実装サイクル
- `/fix` - バグ修正のリグレッションテスト
- `/test` - テスト実行・検証
