---
name: quarto-task-slides
description: >
  Git から指定範囲のコミットを収集し、Quarto（reveal.js）でスライド（HTML/PDF）を生成する。
  タスクID、コミット範囲、ブランチ間の差分など、柔軟な指定方法に対応。
version: 2.0.0
---

# Quarto Task Slides（Git コミットのスライド生成）

## 目的
- 指定された範囲やタスク（例: `TASK-123`、ブランチ名、コミット範囲）に関連するコミットを抽出し、要約・diffstat・頻出ファイルなどを自動整形。
- Quarto（reveal.js）で HTML / PDF スライドを生成して配布可能にする。

## 前提
- 実行環境に `git`, `python3`, `quarto` が入っていること。
- PDF を出す場合は TinyTeX などの LaTeX が必要（`quarto install tinytex`）。

## 入力パラメータ
- `task_id`（**オプション**）: 例 `TASK-123` / `feature/foo`。省略時はコミットメッセージフィルタなし
- `repo_dir`（既定 `.`）
- `since` / `until`（例 `since=origin/main`, `until=HEAD`。省略時は `merge-base origin/main..HEAD`）
- `paths`（任意: `src/foo,app/` など）
- `grep`（任意の追加フィルタ）
- `include_diff`（bool, 既定 false）
- `max_patch_lines`（既定 600）
- `title`（任意）
- `format`（`html` | `pdf`、既定 `html`）
- `outdir`（既定 `slides/`）

## 自然言語での範囲指定の解釈

ユーザーが自然言語で範囲を指定した場合、以下のように解釈してパラメータに変換する：

### よくある指定パターン

1. **「mainブランチとの差分」「mainとの差分」**
   - `--since origin/main --until HEAD`

2. **「コミットXXXから現在まで」「XXXから今まで」**
   - `--since XXX --until HEAD`

3. **「コミットAからコミットBまで」**
   - `--since A --until B`

4. **「このブランチの変更」「現在のブランチの作業内容」**
   - `--since origin/main --until HEAD`（mainブランチからの差分と解釈）

5. **「最近のN件のコミット」**
   - `--until HEAD` + git log で適切な since を計算

6. **タスクIDなしで範囲のみ指定された場合**
   - task_id を空文字列にして、範囲指定のみでコミットを収集

## 実行手順（Claude が行うべきこと）

1. **ユーザーの指定を解釈する**
   - 自然言語での指定を上記パターンに従って `since` / `until` / `task_id` に変換
   - 不明な点があれば軽く確認するが、合理的な推測ができる場合は自動補完

2. **スクリプトを実行する**（プロジェクト内の相対パス）
   ```bash
   bash .claude/skills/quarto-task-slides/scripts/task_slides.sh \
     ${task_id:+--task "<task_id>"} \
     --repo "<repo_dir>" \
     ${since:+--since "<since>"} ${until:+--until "<until>"} \
     ${paths:+--paths "<paths>"} \
     ${grep:+--grep "<grep>"} \
     ${title:+--title "<title>"} \
     --format "<format>" \
     --outdir "<outdir>" \
     $( [[ "<include_diff>" == "true" ]] && echo --include-diff )
   ```

3. **結果を報告する**
   - 成功したら、出力ファイル（`<outdir>/*.html` or `*.pdf`）のパスを報告
   - 失敗時は、`git`/`quarto` の存在を確認し、必要ならユーザーにインストールを提案

## 例

### タスクIDを使った従来の使い方

* 「`TASK-123` を `src/auth` に限定、HTMLで」
  ```bash
  bash .claude/skills/quarto-task-slides/scripts/task_slides.sh \
    --task TASK-123 --paths src/auth --format html
  ```

* 「ブランチ `feature/2fa` を PDF で、パッチ付き」
  ```bash
  bash .claude/skills/quarto-task-slides/scripts/task_slides.sh \
    --task feature/2fa --include-diff --format pdf
  ```

### 自然言語での範囲指定（新機能）

* 「mainブランチとの差分をスライドにして」
  ```bash
  bash .claude/skills/quarto-task-slides/scripts/task_slides.sh \
    --since origin/main --until HEAD --format html
  ```

* 「コミット abc123 から現在までの変更をPDFで」
  ```bash
  bash .claude/skills/quarto-task-slides/scripts/task_slides.sh \
    --since abc123 --until HEAD --format pdf
  ```

* 「このブランチでの作業内容をスライドに、パッチも含めて」
  ```bash
  bash .claude/skills/quarto-task-slides/scripts/task_slides.sh \
    --since origin/main --until HEAD --include-diff --format html
  ```

* 「src/ ディレクトリの変更だけをスライドに」
  ```bash
  bash .claude/skills/quarto-task-slides/scripts/task_slides.sh \
    --since origin/main --until HEAD --paths src/ --format html
  ```

## 注意

* 変更は読み取り中心だが、`slides/` に成果物（.qmd / .html / .pdf）を出力する。
* ネットワークや外部 API は不要（ローカル Git に依存）。
* セキュリティ: 不要な外部コマンド導入は避ける。必要時のみ最小限に。
