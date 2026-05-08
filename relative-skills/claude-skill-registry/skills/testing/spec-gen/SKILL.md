---
name: spec-gen
description: |
  コードからspecを生成するスキル。As-Is spec（現状仕様）を根拠付きで抽出し、3層構造（インターフェース/振る舞い/業務意味）で整理。
  使用タイミング: (1)「コードからspecを生成」(2)「仕様書を作成」(3)「APIドキュメント生成」(4)「現状の振る舞いを文書化」(5)「変更で壊れたspecを検出」(6)「コードと仕様の乖離を確認」と言われた時。
  生成するのはAs-Is spec（現状仕様）であり、To-Be spec（あるべき仕様）は人間の判断が必要。
---

# Spec-Gen: コードからSpec生成

## 核心原理

**コードから生成できるのはAs-Is spec（現状仕様）のみ**

- As-Is: 今このコードが"そう振る舞う"こと
- To-Be: 本来"そうあるべき"こと ← コードには書かれていない

To-Beを推測すると「整った嘘」になる。As-Isとして厳密に抽出し、不明は不明として残す。

## 3層構造

| 層 | 生成難易度 | 出力形式 | 説明 |
|-----|----------|---------|------|
| **A: インターフェース** | 高精度 | YAML | 型/スキーマ/パス/ステータス |
| **B: 振る舞い** | 中精度 | YAML | 前提/事後/副作用/状態遷移 |
| **C: 業務意味** | 低精度 | Markdown | 意図/理由/トレードオフ（草案止まり） |

詳細: [references/spec-layers.md](references/spec-layers.md)

## 確度ラベル

すべての断定に確度を付与:

| ラベル | 定義 | 扱い |
|--------|------|------|
| **Verified** | テスト/実行で確認済み | 信頼可 |
| **Observed** | コードで確認（テスト未確認） | 要検証 |
| **Assumed** | 一般的推測 | 要確認 |
| **Unknown** | 判断不能 | 明示的に残す |

詳細: [references/confidence-labels.md](references/confidence-labels.md)

## 実行手順

### Step 1: 公開面（Surface）の特定

対象コードのエントリポイントを特定:

```
- HTTP: ハンドラ/ルーティング
- CLI: コマンド/サブコマンド
- Event: 購読/パブリッシュ
- Job: スケジューラ起点
- Library: public/export
```

### Step 2: 層Aの抽出（インターフェースspec）

**抽出対象**:
- リクエスト/レスポンス型
- パス、メソッド、ステータスコード
- 必須/任意、デフォルト、列挙値
- エラーコード一覧

**出力形式**: YAML（OpenAPI互換推奨）

```yaml
# 層A: インターフェースspec
endpoint:
  path: /api/users/{id}
  method: GET
  confidence: Observed
  evidence: src/api/users.ts:45

request:
  params:
    id:
      type: string
      required: true
      confidence: Verified
      evidence: tests/api/users.test.ts:23

response:
  success:
    status: 200
    schema:
      id: string
      name: string
      email: string
    confidence: Observed
    evidence: src/api/users.ts:52

  errors:
    - status: 404
      code: USER_NOT_FOUND
      confidence: Observed
      evidence: src/api/users.ts:48
```

### Step 3: 層Bの抽出（振る舞いspec）

**抽出対象**:
- 前提条件（preconditions）
- 事後条件（postconditions）
- 禁止条件
- 副作用（DB書込み、外部API、イベント発行）
- 状態遷移

**出力形式**: YAML

```yaml
# 層B: 振る舞いspec
behavior:
  preconditions:
    - condition: "ユーザーIDが存在する"
      confidence: Observed
      evidence: src/services/user.ts:34

  postconditions:
    - condition: "ユーザー情報が返却される"
      confidence: Verified
      evidence: tests/services/user.test.ts:45

  side_effects:
    - type: db_read
      target: users table
      confidence: Observed
      evidence: src/repositories/user.ts:23

  state_transitions:
    - from: null
      to: null
      note: "読み取り専用、状態変更なし"
      confidence: Observed
      evidence: src/api/users.ts:45-55

  invariants:
    - statement: "同一IDで常に同一ユーザーが返る"
      confidence: Assumed
      evidence: null
```

### Step 4: 層Cの生成（業務意味spec）

**注意**: この層はコードから断定困難。草案として生成し、人間レビュー必須。

**出力形式**: Markdown

```markdown
# 業務意味spec（草案）

## 概要
[Assumed] ユーザー情報取得API

## 目的
[Unknown] 具体的なビジネス目的は不明

## 使用コンテキスト
[Assumed] ユーザープロフィール表示に使用される可能性

## 設計判断
[Unknown] なぜこの実装になったかは不明

---
**レビュー依頼**: この層の内容は人間による確認が必要
```

### Step 5: 根拠リンクの検証

すべてのevidenceを検証:

```
[ ] ファイルパスが存在する
[ ] 行番号が有効範囲内
[ ] シンボル名が一致する
[ ] confidence: Verified には対応テストがある
```

## 差分検出

### 手動比較ガイド

既存specとコードを比較:

1. spec内のevidenceリンクを抽出
2. 各リンク先が変更されていないか確認
3. 変更があれば該当specを「要更新」としてマーク

### git連携

```bash
# 変更ファイルからspec影響を検出
git diff --name-only HEAD~1 | xargs -I {} grep -l "{}" specs/*.yaml

# 特定コミット範囲のspec影響
git diff --name-only <from>..<to> | while read file; do
  grep -r "evidence:.*$file" specs/
done
```

詳細: [references/diff-detection.md](references/diff-detection.md)

## 出力テンプレート

詳細: [references/output-templates.md](references/output-templates.md)

## 品質チェックリスト

```markdown
### 層A（インターフェース）
- [ ] すべてのエンドポイントを網羅したか
- [ ] 型情報に根拠リンクがあるか
- [ ] エラーコードを列挙したか

### 層B（振る舞い）
- [ ] 副作用を列挙したか
- [ ] 前提条件/事後条件を記述したか
- [ ] 状態遷移を図示したか（該当する場合）

### 層C（業務意味）
- [ ] 草案として明示したか
- [ ] Unknown/Assumedを正直に付けたか
- [ ] レビュー依頼を記載したか

### 全体
- [ ] As-IsとTo-Beを混同していないか
- [ ] 根拠のない断定がないか
- [ ] 確度ラベルが適切か
```

## 連携スキル

- **eld-model-law-card**: 層Bで発見した不変条件をLaw Cardへ昇格
- **spec-observation**: specから受入テストを生成
- **doc-gen**: 層A/Bを開発者ドキュメントに統合
