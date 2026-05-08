---
name: extracting-interactions
description: Extracts interaction specifications from Figma designs (hover states, transitions, animations, triggers). Updates the "インタラクション" section in screen spec.md.
allowed-tools: [Read, Write, Glob, mcp__figma__get_screenshot, mcp__figma__get_design_context, mcp__figma__get_metadata]
---

# Interaction Extraction Skill

Figmaデザインからインタラクション仕様（hover状態、遷移、アニメーション、トリガー）を抽出するスキルです。

## 目次

1. [概要](#概要)
2. [対象範囲](#対象範囲)
3. [クイックスタート](#クイックスタート)
4. [詳細ガイド](#詳細ガイド)
5. [出力形式](#出力形式)

## 概要

このスキルは以下のタスクをサポートします：

1. **コンポーネント状態の抽出**: hover, active, disabled, focused等
2. **トランジション定義**: 状態間のアニメーション仕様
3. **トリガー整理**: ユーザー操作と対応するアクション
4. **画面遷移仕様**: ナビゲーションとアニメーション

## 禁止事項

**以下は絶対に行わないこと：**
- 実装コードの生成（CSS/JS/Swift等）
- アニメーションライブラリの提案（Framer Motion/GSAP等）
- 技術スタック固有の実装詳細

このスキルの目的は「どのようなインタラクションがあるか」の**情報整理のみ**です。

## 対象範囲

### このスキルで扱うもの（コンポーネントレベル）

- ボタンの hover / active / disabled 状態
- 入力フィールドの focus / error / filled 状態
- カードの hover エフェクト
- トグル / チェックボックスの on/off
- アコーディオンの展開/折りたたみ
- タブの選択状態
- ドロップダウンの開閉
- モーダル/ダイアログの表示/非表示
- ツールチップの表示

### documenting-ui-states で扱うもの（画面レベル）

- 画面全体の loading / error / empty 状態
- API通信に伴う画面状態変化

## 出力先

このスキルは**画面仕様書（spec.md）の「インタラクション」セクション**を更新します。

```
.outputs/{screen-id}/
├── spec.md                 # ← このスキルが「インタラクション」セクションを更新
├── index.html              # 参照用HTML
└── assets/
```

## クイックスタート

### 基本的な使い方

```
以下のFigma画面のインタラクション仕様を抽出してください：
https://figma.com/design/XXXXX/Project?node-id=1234-5678
```

エージェントは自動的に：
1. コンポーネントバリアントを検出
2. 状態変化のパターンを整理
3. トリガーとアクションを文書化
4. **spec.md の「インタラクション」セクションを更新**

## 詳細ガイド

詳細な情報は以下のファイルを参照してください：

- **[workflow.md](references/workflow.md)**: インタラクション抽出のワークフロー
- **[interaction-patterns.md](references/interaction-patterns.md)**: 一般的なインタラクションパターン
- **[section-template.md](references/section-template.md)**: セクション出力テンプレート

## Workflow

インタラクション抽出時にこのチェックリストをコピー：

```
Interaction Extraction Progress:
- [ ] Step 0: spec.md の存在確認
- [ ] Step 1: インタラクティブ要素を特定
- [ ] Step 2: コンポーネントバリアントを検出
- [ ] Step 3: 状態変化を整理
- [ ] Step 4: トリガーとアクションを文書化
- [ ] Step 5: トランジション/アニメーションを整理
- [ ] Step 6: 画面遷移を整理
- [ ] Step 7: spec.md の「インタラクション」セクションを更新
```

### Step 0: spec.md の存在確認

```bash
# 確認
ls .outputs/{screen-id}/spec.md

# なければテンプレートから初期化
cp .agents/templates/screen-spec.md .outputs/{screen-id}/spec.md
```

### Step 1: インタラクティブ要素を特定

HTMLまたはFigmaから以下を抽出：

- ボタン（button, a[role="button"]）
- リンク（a）
- 入力フィールド（input, textarea, select）
- インタラクティブカード
- タブ、アコーディオン
- トグル、チェックボックス、ラジオ

### Step 2: コンポーネントバリアントを検出

Figmaコンポーネントのバリアントプロパティを確認：

```
Button
├── State=Default
├── State=Hover
├── State=Pressed
├── State=Disabled
└── State=Loading
```

### Step 3: 状態変化を整理

各コンポーネントの状態遷移を文書化：

| 要素 | From | To | トリガー |
|------|------|-----|----------|
| 送信ボタン | default | hover | マウスオーバー |
| 送信ボタン | hover | pressed | クリック |
| 送信ボタン | pressed | loading | クリック完了 |

### Step 4: トリガーとアクションを文書化

| トリガー | 対象 | アクション |
|----------|------|-----------|
| クリック | 送信ボタン | フォーム送信 |
| クリック | 講座カード | 詳細画面へ遷移 |
| ホバー | カード | 影を強調 |

### Step 5: トランジション/アニメーションを整理

| 要素 | プロパティ | 値 | duration | easing |
|------|-----------|-----|----------|--------|
| ボタン | background-color | #0070e0 → #005bb5 | 150ms | ease-out |
| カード | box-shadow | 0 2px 4px → 0 4px 12px | 200ms | ease |
| モーダル | opacity | 0 → 1 | 300ms | ease-in-out |

### Step 6: 画面遷移を整理

| 起点 | アクション | 遷移先 | アニメーション |
|------|----------|--------|---------------|
| 講座一覧 | カードクリック | 講座詳細 | push (右からスライド) |
| 講座詳細 | 戻るボタン | 講座一覧 | pop (左へスライド) |
| 任意 | ログインボタン | ログインモーダル | fade + scale |

### Step 7: spec.md の「インタラクション」セクションを更新

1. セクションを特定（`## インタラクション`）
2. ステータスを「完了 ✓」に更新
3. `{{INTERACTIONS_CONTENT}}` を内容に置換
4. 完了チェックリストを更新
5. 変更履歴に追記

## 出力形式

### spec.md「インタラクション」セクションの内容

```markdown
## インタラクション

> **ステータス**: 完了 ✓  
> **生成スキル**: extracting-interactions  
> **更新日**: 2024-01-15

### インタラクティブ要素一覧

| 要素 | 種別 | 状態数 | 備考 |
|------|------|--------|------|
| 送信ボタン | button | 5 | default/hover/pressed/disabled/loading |
| 講座カード | card | 2 | default/hover |
| メールフィールド | input | 4 | default/focus/filled/error |

### コンポーネント状態

#### 送信ボタン

| 状態 | 視覚変化 | Figma Node |
|------|----------|------------|
| default | 背景 #0070e0, テキスト白 | `1234:5678` |
| hover | 背景 #005bb5 | `1234:5679` |
| pressed | scale(0.98) | `1234:5680` |
| disabled | opacity 0.5 | `1234:5681` |
| loading | スピナー表示, テキスト非表示 | `1234:5682` |

#### 講座カード

| 状態 | 視覚変化 | Figma Node |
|------|----------|------------|
| default | shadow: 0 2px 4px | `2345:6789` |
| hover | shadow: 0 4px 12px, translateY(-2px) | `2345:6790` |

### トリガーとアクション

| トリガー | 対象要素 | アクション | 条件 |
|----------|----------|-----------|------|
| click | 送信ボタン | フォーム送信 | バリデーション成功時 |
| click | 講座カード | 詳細画面へ遷移 | - |
| hover | 講座カード | 影を強調 | - |
| focus | メールフィールド | ボーダー色変更 | - |
| blur | メールフィールド | バリデーション実行 | - |

### トランジション仕様

| 要素 | プロパティ | duration | easing | 備考 |
|------|-----------|----------|--------|------|
| ボタン | background-color | 150ms | ease-out | hover時 |
| ボタン | transform | 100ms | ease | pressed時 |
| カード | box-shadow, transform | 200ms | ease | hover時 |
| モーダル | opacity | 300ms | ease-in-out | 表示/非表示 |

### 画面遷移

| 起点 | アクション | 遷移先 | アニメーション |
|------|----------|--------|---------------|
| この画面 | カードクリック | 講座詳細 | push (右からスライド) |
| この画面 | 戻るボタン | 前の画面 | pop (左へスライド) |

### 特記事項

- ボタンのloading状態はAPI通信中に表示
- カードホバーはタッチデバイスでは無効化推奨
```

## 完了チェックリスト

生成後、以下を確認：

```
- [ ] spec.md の「インタラクション」セクションが更新されている
- [ ] ステータスが「完了 ✓」になっている
- [ ] 全てのインタラクティブ要素がリストされている
- [ ] 各要素の状態が網羅されている
- [ ] トリガーとアクションが明確
- [ ] トランジション仕様が記載されている
- [ ] 完了チェックリストが更新されている
- [ ] 変更履歴に記録が追加されている
```

## 注意事項

### 他のセクションを変更しない

このスキルは「インタラクション」セクションのみを更新します。

### documenting-ui-states との違い

| 観点 | documenting-ui-states | extracting-interactions |
|------|----------------------|------------------------|
| 対象 | 画面全体の状態 | コンポーネントの状態 |
| 例 | loading, error, empty | hover, pressed, focus |
| トリガー | APIレスポンス等 | ユーザー操作 |

### Figmaプロトタイプの活用

Figmaプロトタイプが設定されている場合、以下を確認：

- インタラクショントリガー（On Click, On Hover等）
- アニメーション設定（Duration, Easing）
- 遷移先フレーム

## 参照

- **[workflow.md](references/workflow.md)**: 詳細なワークフロー
- **[interaction-patterns.md](references/interaction-patterns.md)**: インタラクションパターン集
- **[section-template.md](references/section-template.md)**: セクション出力テンプレート
- **[managing-screen-specs](../managing-screen-specs/SKILL.md)**: 仕様書管理スキル
