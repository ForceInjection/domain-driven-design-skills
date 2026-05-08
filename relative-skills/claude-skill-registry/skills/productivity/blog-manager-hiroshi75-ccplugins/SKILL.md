---
name: blog-manager
description: Use for all blog writing tasks including creating articles (Zenn Japanese, dev.to/Medium English), managing ideas, and setting up blog projects. This is the unified entry point for technical blog writing workflow. Supports idea tracking with status management (backlog/in-progress/done).
---

# Blog Manager Skill

技術ブログ執筆の統合ワークフローを提供するスキルです。

## Purpose

- ブログ執筆プロジェクトのセットアップ
- 記事アイデアの状態管理（backlog → in-progress → done）
- 記事の観点（perspective）を適用した記事生成
- 記事生成（Zenn 日本語 / dev.to・Medium 英語）
- 公開後のステータス更新とプロモーション支援

---

## Three-Layer Structure

ブログ執筆は「素材」「観点」「成果物」の3層で管理する:

```
my-blog/
├── ideas/                  # 素材（再利用可能なネタ）
│   ├── YYYYMMDD_langchain-tips.md
│   └── YYYYMMDD_rag-patterns.md
├── perspectives/           # 観点（再利用可能なスタイル）
│   ├── showcase.md         # 製品紹介向け
│   ├── personal.md         # 個人的な考え
│   └── tutorial.md         # ハンズオン教育
├── .draft/                 # 生成された記事（1回の生成結果）
│   └── YYYYMMDD_article-zenn.md
└── articles/               # 公開用
```

| レイヤー | 役割 | 再利用 |
|---------|------|--------|
| `ideas/` | 素材・ネタ（何を書くか） | ○ 何度でも使える |
| `perspectives/` | 観点・スタイル（どう書くか） | ○ 何度でも使える |
| `.draft/` | 生成された記事 | × 1回の生成結果 |

**idea と記事は 1:1 ではない:**
- 1つの idea → 複数の記事（違う観点で）
- 複数の idea → 1つの記事（組み合わせて）
- 同じ idea を再利用して別の記事に

## When to Use

- 「記事を書いて」「ブログ書いて」と言われたとき
- Zenn、dev.to、Medium 向けの記事を作成するとき
- 新しいブログプロジェクトをセットアップするとき
- 記事アイデアの一覧・状態を確認したいとき
- 記事を公開した後にステータスを更新するとき

---

## Input Sources

記事の元ネタは以下の2パターンから取得できる:

### パターン A: ideas/ から

事前に `ideas/` にメモしたアイデアから記事を生成:

```
> ideas/20241215_langchain-tips.md を元に Zenn 記事を書いて
```

### パターン B: 開発ディレクトリから（直接指定）

開発中のプロジェクトの特定機能を直接指定して記事を生成:

```
> /path/to/project の認証機能について Zenn 記事を書いて
> @myproject/ の LangGraph 実装を dev.to 記事にして
> このリポジトリの MCP サーバー機能について記事を書いて
```

**パターン B のワークフロー:**

```
┌─────────────────────────────────────────────────────────────┐
│  1. ユーザーがディレクトリ + 機能を指定                         │
│     「/path/to/project の認証機能について記事を書いて」         │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  2. 該当コードを探索・読み込み                                 │
│     - README.md があれば読む                                  │
│     - 指定された機能に関連するファイルを特定                    │
│     - 実装の要点を把握                                        │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  3. 記事を生成 (.draft/ に出力)                               │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  4. ideas/ に記録を自動作成（重複防止）                        │
│     ideas/YYYYMMDD_project-name-feature.md                   │
│     status: in-progress                                      │
│     source_path: /path/to/project                            │
└─────────────────────────────────────────────────────────────┘
```

**ideas/ に作成される記録ファイルの例:**

```yaml
---
status: in-progress
priority: high
tags: [authentication, nextjs, security]
created: 2024-01-20
source_path: /path/to/project      # 元のプロジェクトパス
source_feature: 認証機能            # 対象の機能
published_to: []
---

# Next.js 認証機能の実装解説

## 元ネタ

/path/to/project の認証機能から記事を生成

## 記事化のポイント

- JWT トークンの実装
- セッション管理
- ミドルウェアでの認証チェック
```

これにより:
- 同じ機能について再度記事を書こうとした時に検知できる
- 公開後に `published_to` で追跡できる
- `source_path` で元のコードに戻れる

---

## Perspective (観点)

記事の「観点」は記事生成時に指定する。素材（ideas/）とは独立して管理。

### 観点の指定方法

```
# テンプレートを参照
> ideas/20241215_mcp-server.md を showcase の観点で Zenn 記事を書いて

# 直接指定
> ideas/20241215_new-feature.md を記事にして
> 観点: 控えめに、個人的な考えとして表現

# 複数の素材 + 観点
> ideas/20241210_langchain-tips.md と ideas/20241212_rag-patterns.md を
> tutorial の観点で Zenn 記事を書いて
```

### 標準 Perspective テンプレート

| perspective | 用途 | トーン |
|-------------|------|--------|
| `showcase` | 製品・ツール紹介 | 熱意あり、使ってもらいたい |
| `personal` | 個人的な考え・開発記録 | 控えめ、提案ベース |
| `tutorial` | ハンズオン教育 | 丁寧、ステップバイステップ |
| `deep-dive` | 技術深掘り | 詳細、専門的 |

詳細は [perspectives.md](references/perspectives.md) を参照。

### 生成された記事のメタデータ

`.draft/YYYYMMDD_article-zenn.md` には使用した perspective と sources が記録される:

```yaml
---
title: "LangChain で RAG を実装する実践ガイド"
emoji: "📚"
type: "tech"
topics: ["langchain", "rag", "python", "ai"]
published: false
_meta:
  perspective: tutorial
  perspective_notes: "ステップバイステップで丁寧に"
  sources:
    - ideas/20241210_langchain-tips.md
    - ideas/20241212_rag-patterns.md
  generated_at: 2024-01-20
---
```

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  1. アイデアを ideas/ に追加                                  │
│     status: backlog でフロントマター作成                      │
│     → references/idea-management.md 参照                     │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  2. 記事設計の確認（執筆前に必ず確認）                         │
│     - 読者の前提知識、概念説明の要否                          │
│     - イントロの型（直球型/悩み系/体験ベース/問いかけ型）       │
│     - 文体・避けたいトーン（マーケティング調など）              │
│     - 視覚化の好み（Mermaid/ツリー/表/なし）                   │
│     - 実際の挙動詳細（ツール紹介の場合、対話の流れなど）        │
│     - 補足情報（カスタマイズの余地、代替手段）                  │
│     → references/idea-management.md の「記事の設計」参照       │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  3. 執筆開始                                                 │
│     status: in-progress に更新                               │
│     プラットフォームを選択:                                    │
│     - Zenn (日本語) → references/zenn-guide.md               │
│     - dev.to/Medium (英語) → references/devto-guide.md       │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  4. .draft/ に記事が生成される                                │
│     - .draft/YYYYMMDD_article-zenn.md (Zenn 用)              │
│     - .draft/YYYYMMDD_article-devto.md (dev.to 用)           │
│     - .draft/YYYYMMDD_article-medium.md (Medium 用、オプション)│
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  5. レビュー・編集                                            │
│     - 内容確認、加筆修正                                      │
│     - 画像・GIF を追加                                        │
│     - Zenn: npx zenn preview で確認                          │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  6. 本番ディレクトリに移動                                    │
│     .draft/YYYYMMDD_article-zenn.md → articles/slug.md      │
│     .draft/YYYYMMDD_article-devto.md → external/devto/published/│
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  7. アイデアの status を done に更新                          │
│     published_to に公開先 URL を記録                          │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  8. 公開 & プロモーション                                     │
│     → references/promotion-tips.md 参照                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Platform Selection

ユーザーの要求に応じてプラットフォームを選択:

| キーワード | プラットフォーム | ガイド |
|-----------|-----------------|--------|
| 「Zenn」「日本語」「技術記事」 | Zenn | [zenn-guide.md](references/zenn-guide.md) |
| 「dev.to」「英語」「ローンチ」 | dev.to | [devto-guide.md](references/devto-guide.md) |
| 「Medium」「ストーリー」 | Medium | [devto-guide.md](references/devto-guide.md) (Medium モード) |
| 「両方」「マルチ」 | Zenn + dev.to | 両方生成 |

**プラットフォームが不明な場合:**
ユーザーに確認する:
- 日本語読者向け → Zenn
- グローバル読者向け → dev.to/Medium
- 両方 → 両プラットフォーム用を生成

---

## References

| ファイル | 内容 |
|---------|------|
| [directory-structure.md](references/directory-structure.md) | プロジェクトのディレクトリ構成 |
| [idea-management.md](references/idea-management.md) | アイデア（素材）のフロントマター管理 |
| [perspectives.md](references/perspectives.md) | 観点テンプレートの定義と使い方 |
| [zenn-guide.md](references/zenn-guide.md) | Zenn 記事生成ガイド（日本語） |
| [devto-guide.md](references/devto-guide.md) | dev.to/Medium 記事生成ガイド（英語） |
| [promotion-tips.md](references/promotion-tips.md) | プロモーション・タイミング戦略 |

---

## Usage Examples

### 1. プロジェクトセットアップ
```
> ブログ執筆用のプロジェクトをセットアップして
```
→ [directory-structure.md](references/directory-structure.md) に従ってディレクトリ作成

### 2. アイデア管理
```
> ideas/ の backlog を一覧して
> ideas/20241215_xxx.md の status を in-progress にして
```
→ [idea-management.md](references/idea-management.md) のフロントマターを操作

### 3. Zenn 記事生成（ideas/ から）
```
> ideas/20241215_langchain-tips.md を元に Zenn 記事を書いて
```
→ [zenn-guide.md](references/zenn-guide.md) に従って `.draft/YYYYMMDD_article-zenn.md` を生成

### 4. 観点（perspective）を指定して記事生成
```
> ideas/20241215_mcp-server.md を showcase の観点で Zenn 記事を書いて
> ideas/20241215_new-lib.md を personal の観点で記事にして
```
→ perspectives/ のテンプレートを適用して記事生成

### 5. 複数の素材を組み合わせて記事生成
```
> ideas/20241210_langchain-tips.md と ideas/20241212_rag-patterns.md を
> tutorial の観点で Zenn 記事を書いて
```
→ 複数の素材を統合し、指定した観点で記事生成

### 6. 開発ディレクトリから記事生成
```
> /path/to/myproject の認証機能について Zenn 記事を書いて
> @langgraph-plugin/ の並列処理パターンを showcase で記事にして
```
→ コードを読み込み → 記事生成 → `ideas/` に記録を自動作成

### 7. dev.to 記事生成
```
> この README を元に dev.to 記事を書いて
> @my-cli-tool/ を showcase で dev.to 記事を書いて
```
→ [devto-guide.md](references/devto-guide.md) に従って `.draft/YYYYMMDD_article-devto.md` を生成

### 8. 両方生成
```
> ideas/20241215_mcp-intro.md を showcase で Zenn と dev.to 両方の記事を書いて
```
→ 同じ観点で日本語版と英語版を両方生成

### 9. 公開後の更新
```
> ideas/20241215_langchain-tips.md の status を done にして
> published_to に https://zenn.dev/xxx/articles/yyy を追加して
```
→ フロントマターを更新

### 10. プロモーション相談
```
> この記事のプロモーション戦略を教えて
```
→ [promotion-tips.md](references/promotion-tips.md) を参照してアドバイス

---

## Output Files

| ファイル | 説明 |
|---------|------|
| `.draft/YYYYMMDD_article-zenn.md` | Zenn 用日本語記事 |
| `.draft/YYYYMMDD_article-devto.md` | dev.to 用英語記事 |
| `.draft/YYYYMMDD_article-medium.md` | Medium 用英語記事（オプション） |

**ファイル名の形式:** `YYYYMMDD_` は生成日の8桁日付（例: `20241215_article-zenn.md`）

---

## 記事生成時の確認チェックリスト

ユーザーから「記事を書いて」と依頼されたとき、以下の情報が不足していれば確認する:

| 項目 | 確認が必要な場合 | 質問例 |
|------|-----------------|--------|
| 読者の前提知識 | 対象が不明確 | 「読者は◯◯を知っている前提でよいですか？」 |
| 概念説明の要否 | ツール/技術紹介 | 「◯◯とは何かの説明は必要ですか？」 |
| イントロの型 | 特に指定がない | 「直球型・悩み系・体験ベースなど、イントロの好みはありますか？」 |
| 避けたいトーン | 特に指定がない | 「避けたい表現やトーンはありますか？」 |
| 視覚化の好み | 構造を説明する内容 | 「図（Mermaid等）を使いますか？テキストで十分ですか？」 |
| 実際の挙動 | ツール/機能紹介 | 「ユーザーが◯◯すると何が起こりますか？」 |
| 補足情報 | カスタマイズ可能なツール | 「読者が調整できる部分や代替手段も触れますか？」 |

**ポイント**: これらを最初に確認することで、執筆後の手戻りを大幅に減らせる。

---

## Notes

- すべての記事生成は `.draft/` に出力（一時置き場）
- 完成したら `articles/` (Zenn) または `external/` (他) に移動
- アイデアの状態管理で重複記事を防止
- 同じアイデアを複数プラットフォームに投稿可能（`published_to` で追跡）
- 生成後の細かい修正は、手動で編集しても Claude Code に依頼してもよい
