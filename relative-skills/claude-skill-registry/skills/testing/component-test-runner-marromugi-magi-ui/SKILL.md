---
name: component-test-runner
description: 指定されたコンポーネントの全テスト（unit, a11y, vrt, interaction）を実行し、結果をレポートする。
---

# Component Test Runner

指定されたコンポーネントに対して、すべてのテストを実行し、結果を統合してレポートするSkill。

## 概要

このSkillは以下の4種類のテストエージェントを順番に呼び出し、結果を統合します:

1. **unit-test-runner**: ロジックユニットテスト（Vitest）
2. **a11y-test-runner**: アクセシビリティテスト（markup + axe-core）
3. **vrt-test-runner**: Visual Regression Test
4. **interaction-test-runner**: Storybookインタラクションテスト

## 使い方

```
/component-test-runner Button
```

または

```
component-test-runner を使って Button コンポーネントをテストして
```

## 実行手順

### 1. 入力の確認

ユーザーから対象コンポーネント名を受け取る。

例: `Button`, `Alert`, `TextField`

### 2. テストエージェントの呼び出し

以下の順序で各テストエージェントを呼び出す:

#### 2.1 ロジックユニットテスト

`unit-test-runner` エージェントを呼び出し:

```
unit-test-runner: {Component}
```

#### 2.2 アクセシビリティテスト

`a11y-test-runner` エージェントを呼び出し:

```
a11y-test-runner: {Component}
```

#### 2.3 VRTテスト

`vrt-test-runner` エージェントを呼び出し:

```
vrt-test-runner: {Component}
```

#### 2.4 インタラクションテスト

`interaction-test-runner` エージェントを呼び出し:

```
interaction-test-runner: {Component}
```

### 3. 結果の統合

すべてのテスト結果を統合し、以下のフォーマットでレポート。

## 出力フォーマット

````markdown
## テスト結果サマリー: {Component}

### 検出されたファイル

| テスト種別  | ファイル               | 存在  |
| ----------- | ---------------------- | ----- |
| Unit Test   | `{path}.test.tsx`      | ✅/❌ |
| A11y Test   | `{path}.a11y.test.tsx` | ✅/❌ |
| VRT         | `{path}.vrt.test.tsx`  | ✅/❌ |
| Interaction | `{path}.stories.tsx`   | ✅/❌ |

### テスト結果サマリー

| テスト種別  | 結果     | 備考 |
| ----------- | -------- | ---- |
| Unit Test   | ✅/❌/⏭️ |      |
| Markup Lint | ✅/❌/⏭️ |      |
| A11y Test   | ✅/❌/⏭️ |      |
| VRT         | ✅/❌/⏭️ |      |
| Interaction | ✅/❌/⏭️ |      |

### 修正が必要な項目（失敗がある場合）

#### {テスト種別}

**エラー概要**: {概要}

**影響範囲**: {影響を受ける機能/コンポーネント}

**優先度**: High/Medium/Low

**修正箇所**:

- ファイル: `{path}`
- 行番号: {line}
- 問題: {説明}

**修正案**:

```tsx
// 修正コード例
```
````

### 次のアクション

- [ ] {修正が必要な項目}
- [ ] VRTスクリーンショット更新（意図した変更の場合）

### 懸念事項・考慮点

| アクション | 懸念事項                       | リスクレベル    | 対策                 |
| ---------- | ------------------------------ | --------------- | -------------------- |
| {修正内容} | {副作用やリグレッションリスク} | High/Medium/Low | {推奨される検証手順} |

```

## 関連エージェント

各テストで問題が検出された場合、以下のエージェントを使用:

- **vrt-reviewer**: VRT差分の詳細分析
- **vrt-updater**: VRTスクリーンショットの更新

## 注意事項

- VRT差分が検出された場合、自動でスクリーンショットを更新しない
- テストファイルが存在しない場合はそのテストをスキップ
- 複数のエラーがある場合は優先度順にレポート
```
