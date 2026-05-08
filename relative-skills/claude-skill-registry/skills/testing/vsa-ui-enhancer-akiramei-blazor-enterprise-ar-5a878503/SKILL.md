---
name: vsa-ui-enhancer
description: >
  Vertical Slice Architecture (VSA) 向け UI 強化スキル。
  Phase 1（spec-kit + カタログ）で生成されたプレーンな .razor ファイルを、
  Phase 2 で MudBlazor ベースのリッチな UI に変換する。
  アーキテクチャには一切手を触れず、UI だけを強化する。
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
---

# VSA UI Enhancer

このスキルは、**アーキテクチャには一切手を触れずに、UI だけを強化する** ことを目的とする。

---

## 適用場面

- プレーンな HTML ベースの .razor を MudBlazor コンポーネントベースに変換する
- Domain Entity の `CanXxx()` 結果を UI（ボタン活性/ツールチップ/色/バッジ等）に反映する
- 状態・ロール・ビジネスルールに応じた UI 制御を行う

---

## やること / やらないこと

### やること

| 項目 | 説明 |
|------|------|
| HTML → MudBlazor 変換 | `<input>` → `<MudTextField>` など |
| CanXxx() 連携 | ボタン活性/非活性、ツールチップ表示 |
| 状態に応じた装飾 | 色、バッジ、アイコンの切り替え |
| バリデーション表示強化 | MudBlazor のバリデーション機能活用 |

### やらないこと

| 項目 | 説明 |
|------|------|
| Command/Query/Handler 変更 | アーキテクチャの骨格は維持 |
| Store/PageActions 変更 | 状態管理の構造は維持 |
| ドメインロジック変更 | Entity/ValueObject は変更しない |
| インフラ層変更 | Repository/DbContext は変更しない |

---

## 2フェーズアプローチ

### Phase 1: spec-kit + カタログ

- 責務: アーキテクチャと最低限 UI の生成
- 代表的な生成物:
  - Command / Query / Handler
  - Validator
  - Entity（`CanXxx()` を含む）
  - Store / PageActions
  - プレーンな `.razor`（基本的な HTML + `@code`）

### Phase 2: UI-Skill（本 Skill）

- 責務: 見た目のリッチ化のみ
- 入力:
  - `.razor`（Phase 1 で生成済み）
  - 対応する Command / Query
  - 対応する Domain Entity（`CanXxx()` を含む場合）
- 出力:
  - MudBlazor コンポーネントベースに書き換えられた .razor
  - `CanXxx()` 連動済みのボタン/リンク/バッジ
  - 状態に応じた色・装飾

---

## 入力要件

詳細は `input-requirements.md` を参照。

| 分類 | ファイル | 目的 |
|------|----------|------|
| 必須 | .razor | 現在の UI 構造を把握 |
| 必須 | Command / Query | フォーム項目との対応を理解 |
| 条件付き必須 | Domain Entity | CanXxx() がある場合 |
| 任意 | Validator | バリデーション表示を強化する場合 |

---

## 変換ルール

詳細は `component-mapping.md` を参照。

| HTML | MudBlazor |
|------|-----------|
| `<input type="text">` | `<MudTextField>` |
| `<select>` | `<MudSelect>` |
| `<button>` | `<MudButton>` |
| `<table>` | `<MudTable>` / `<MudDataGrid>` |
| `<input type="checkbox">` | `<MudCheckBox>` |

---

## Boundary 連携

詳細は `boundary-integration.md` を参照。

### CanXxx() パターン

```razor
@{
    var canExtend = loan.CanExtend(hasReservations);
}

<MudTooltip Text="@(canExtend.IsAllowed ? string.Empty : canExtend.Reason)">
    <MudButton ButtonType="ButtonType.Submit"
               Disabled="@(!canExtend.IsAllowed || isSubmitting)"
               Color="Color.Primary"
               Variant="Variant.Filled">
        @if (isSubmitting)
        {
            <MudProgressCircular Size="Size.Small" Indeterminate="true" />
        }
        延長する
    </MudButton>
</MudTooltip>
```

- `CanExtend()` の結果でボタン活性/非活性を制御
- `Reason` をツールチップで表示
- 送信中はローディングインジケータを表示

---

## UI パターン

詳細は `ui-patterns/*.md` を参照。

| パターン | ファイル | 用途 |
|----------|----------|------|
| フォーム | `form-pattern.md` | 作成・編集フォーム |
| 一覧 | `list-pattern.md` | データ一覧表示 |
| 詳細 | `detail-pattern.md` | 詳細表示 + 操作ボタン |
| ダイアログ | `dialog-pattern.md` | 確認・入力ダイアログ |

---

## 変換の流れ

1. `.razor` の構造を解析して、UI 要素を抽出
2. それぞれを既存の UI パターン（form/list/detail/dialog）にマッピング
3. `component-mapping.md` に従って HTML → MudBlazor に変換
4. Domain Entity の `CanXxx()` を参照し、UI 制御を追加
5. 必要に応じて Validator を読み込み、バリデーション表示を拡張

---

## 責務の分離

| レイヤー | 担当 | 説明 |
|----------|------|------|
| Command / Handler / Store | spec-kit + カタログ | UI 強化では変更しない |
| Domain Entity (`CanXxx()`) | Domain モデル | UI はこれを利用するだけ |
| UI 見た目 | 本 Skill | プレゼンテーションのみ |

---

## チェックリスト

```
□ HTML → MudBlazor コンポーネントに変換されているか？
□ CanXxx() があれば Disabled/Tooltip に反映されているか？
□ Command/Handler/Store の構造は維持されているか？
□ バリデーションエラーが適切に表示されるか？
□ ローディング状態が表示されるか？
```

---

## 参照

- `input-requirements.md` - 入力要件の詳細
- `component-mapping.md` - HTML → MudBlazor 対応表
- `boundary-integration.md` - CanXxx() 連携パターン
- `ui-patterns/*.md` - UI パターン定義
