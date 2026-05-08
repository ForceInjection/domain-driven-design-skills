---
name: playwright-bdd-analyzer
description: |
  Playwright-BDD/Cucumberテストの品質分析スキル。
  以下の場合に使用:
  (1) .featureファイルのレビュー・品質チェック時
  (2) ステップ定義の再利用性分析時
  (3) シナリオ網羅性の確認時
  (4) E2Eテスト実行結果の分析時
  (5) テストの保守性評価時
---

# Playwright-BDD Analyzer

このスキルは、Playwright-BDDテストの品質・網羅性を分析し、改善点を提案します。

## 目的

1. **Gherkin品質分析**: シナリオの記述品質を評価
2. **網羅性分析**: テストカバレッジのギャップを特定
3. **ステップ定義分析**: 再利用性と重複を検出
4. **実行効率分析**: テストの実行効率を評価
5. **保守性評価**: テストの保守性を定量化

---

## 分析項目

### 1. Gherkin品質分析

#### 1-1. 構文の正確性

- ✅ Feature/Scenario/Given/When/Thenの正しい使用
- ✅ Backgroundの適切な使用
- ✅ Scenario Outlineとデータテーブルの活用

#### 1-2. スタイルの評価

**宣言的 vs 命令的**

❌ 命令的（避けるべき）
```gherkin
When ユーザー名フィールドに "test@example.com" を入力する
And パスワードフィールドに "password123" を入力する
And ログインボタンをクリックする
```

✅ 宣言的（推奨）
```gherkin
When ユーザーが有効な認証情報でログインする
```

#### 1-3. シナリオの独立性チェック

各シナリオは他のシナリオに依存せず、単独で実行可能であること。

---

### 2. 網羅性分析

#### 2-1. 機能ごとのシナリオカバレッジ

| 機能 | ハッピーパス | エラーパス | 境界値 | 同時実行 | カバレッジ |
|-----|------------|-----------|-------|---------|-----------|
| ユーザーログイン | ✅ | ✅ | ✅ | - | 75% |
| 予約作成 | ✅ | ✅ | ✅ | ✅ | 100% |
| メニュー管理 | ✅ | ⚠️ | ❌ | - | 50% |

#### 2-2. パターン別チェック

- [ ] ハッピーパス（正常系）
- [ ] エラーパス（異常系）
- [ ] 境界値ケース
- [ ] 認証・認可パターン
- [ ] ローディング/エラー状態
- [ ] 同時実行制御
- [ ] セキュリティ（XSS/CSRF）

---

### 3. ステップ定義分析

#### 3-1. 再利用率の計算

```
再利用率 = (再利用されたステップ数) / (総ステップ数) × 100%
```

**目標**: 60%以上

#### 3-2. 重複ステップの検出

類似したステップ定義を検出し、統合を提案。

```typescript
// 重複例
When('ユーザーが {string} にアクセスする', ...)
When('ユーザーが {string} ページにアクセスする', ...)
// → 統合可能
```

#### 3-3. パラメータ化の提案

```gherkin
# Before（パラメータ化前）
When ユーザーがログインページにアクセスする
When ユーザーがダッシュボードページにアクセスする
When ユーザーが予約ページにアクセスする

# After（パラメータ化後）
When ユーザーが "/login" にアクセスする
When ユーザーが "/dashboard" にアクセスする
When ユーザーが "/booking" にアクセスする
```

---

### 4. 実行効率分析

#### 4-1. 並列実行可能性

- シナリオの独立性確認
- 共有リソースの競合検出

#### 4-2. セットアップ/ティアダウンの効率

- Backgroundの適切な使用
- データセットアップの重複排除

#### 4-3. フレーキーテストの検出

実行が不安定なテストを検出。

**検出パターン**:
- `page.waitForTimeout()` の多用
- テキストセレクタの使用
- ハードコードされた待機時間

---

## 分析実行手順

### ステップ1: Featureファイルの収集

```bash
# reserve-app/features/ ディレクトリ内の .feature ファイルを再帰的に走査
```

### ステップ2: シナリオの解析

各Featureファイルを解析し、以下を抽出：
- Feature名
- Scenario数
- Background使用有無
- タグ付け状況
- ステップ数

### ステップ3: ステップ定義との対応確認

`reserve-app/src/__tests__/e2e/*.spec.ts` のステップ定義と対応を確認。

### ステップ4: レポート生成

分析結果を markdown 形式で出力。

---

## 出力フォーマット

### サマリー

```markdown
# Playwright-BDD 品質分析レポート

生成日時: 2026-01-01 10:00:00

## サマリー

| 項目 | 値 | 目標 | 状態 |
|-----|-----|------|------|
| 総Feature数 | 12 | - | - |
| 総Scenario数 | 87 | - | - |
| ステップ再利用率 | 68% | 60% | ✅ |
| 宣言的シナリオ率 | 75% | 80% | ⚠️ |
| タグ付け率 | 95% | 90% | ✅ |
| フレーキーテスト | 3件 | 0件 | ⚠️ |
```

### 詳細分析

```markdown
## 品質スコア: 78/100

### 優れている点 ✅

1. ステップ再利用率が高い（68%）
2. ほぼすべてのシナリオにタグが付いている（95%）
3. Backgroundを適切に使用している

### 改善が必要な点 ⚠️

1. 命令的なシナリオが多い（25%）
   - 📁 features/admin/dashboard.feature (5/7シナリオ)
   - 推奨: UIの詳細をステップ定義に移動

2. 境界値テストが不足
   - 📁 features/booking/create-reservation.feature
   - 推奨: 人数0人、11人のケースを追加

3. フレーキーテストの可能性
   - 📁 src/__tests__/e2e/booking.spec.ts:42
   - `page.waitForTimeout(2000)` を使用 → `waitForSelector` に変更

### 欠落しているシナリオ 🔴

1. **予約キャンセル機能**
   - ハッピーパス: ✅
   - エラーパス: ❌ 欠落
   - 推奨: キャンセル失敗ケースを追加

2. **メニュー管理**
   - 境界値テスト: ❌ 欠落
   - 推奨: 価格0円、負の値のテストを追加
```

### 改善提案

```markdown
## 改善提案

### 優先度: 高

1. **features/booking/create-reservation.feature**
   - 境界値テストを追加（人数0人、11人）
   - 所要時間: 30分
   - 期待効果: カバレッジ向上

2. **src/__tests__/e2e/booking.spec.ts**
   - フレーキーな待機処理を修正
   - 所要時間: 15分
   - 期待効果: テスト安定性向上

### 優先度: 中

3. **ステップ定義の統合**
   - 重複ステップ3件を統合
   - 所要時間: 20分
   - 期待効果: 保守性向上

### 優先度: 低

4. **宣言的スタイルへのリファクタリング**
   - 命令的シナリオ22件を宣言的に変更
   - 所要時間: 2時間
   - 期待効果: 可読性向上
```

---

## 分析ルール

詳細な分析ルールとパターンは以下を参照：

- [analysis-rules.md](references/analysis-rules.md) - 分析ルール詳細
- [quality-metrics.md](references/quality-metrics.md) - 品質メトリクス
- [improvement-patterns.md](references/improvement-patterns.md) - 改善パターン集

---

## スクリプト

### analyze-features.ts

Featureファイルを解析し、統計情報を収集。

```bash
npx ts-node .claude/skills/playwright-bdd-analyzer/scripts/analyze-features.ts
```

### check-step-coverage.ts

ステップ定義のカバレッジをチェック。

```bash
npx ts-node .claude/skills/playwright-bdd-analyzer/scripts/check-step-coverage.ts
```

### detect-flaky-patterns.ts

フレーキーテストになりやすいパターンを検出。

```bash
npx ts-node .claude/skills/playwright-bdd-analyzer/scripts/detect-flaky-patterns.ts
```

---

## 使用例

### 全体分析

```
「Playwright-BDDテストの品質を分析して」
```

### 特定Featureファイルのレビュー

```
「features/booking/create-reservation.feature をレビューして」
```

### 改善提案の取得

```
「テストカバレッジのギャップを特定して、改善提案を出して」
```

---

## 定期実行

CI/CDパイプラインに統合して、定期的に品質分析を実行することを推奨。

```yaml
# .github/workflows/test-quality-check.yml
name: Test Quality Check

on:
  pull_request:
  schedule:
    - cron: '0 0 * * 0' # 毎週日曜日

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Analyze BDD Tests
        run: npx ts-node .claude/skills/playwright-bdd-analyzer/scripts/analyze-features.ts
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: bdd-quality-report
          path: bdd-quality-report.md
```

---

## 補足

このスキルは、プロジェクトのBDD開発プロセスを支援し、テストの品質を継続的に改善することを目的としています。

参照ドキュメント:
- `.cursor/rules/開発プロセスルール.md`
- `documents/testing/gherkin網羅性評価レポート.md`
