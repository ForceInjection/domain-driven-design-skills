---
name: screen-spec-guide
description: 画面ID（SAPP-CTG-030 など）から仕様・ワイヤーフレーム・Figma ノードを特定し、関連ドキュメントや画面遷移を横断して確認したいときに使います。docs/2-requirements/24-画面一覧.csv・23-画面設計.md・assets/*.svg・figma・docs/3-external/31-画面遷移図.md を参照して要件を整理する用途を想定しています。
---

# 画面仕様確認ワークフロー

1. **入力整理**: ユーザーから画面ID・名称・関連機能を聞き、補足がなければ `24-画面一覧.csv` で検索する旨を確認。
2. **CSV 参照**: `python3 skills/screen-spec-guide/scripts/find_screen_spec.py SAPP-CTG-030` をリポジトリルートで実行し、該当行を取得。未ヒット時は `docs/2-requirements/22-機能一覧.csv` で機能から逆引きして ID を再確認。
3. **要件補完**: CSV の `画面メモ` と `画面実装状態` を引用したうえで、`docs/2-requirements/23-画面設計.md` の該当グループ説明を読み、操作フローやコンポーネント制約を抜粋。引用時は同ファイルに記載の更新日を併記。
4. **UIソース確認**:
   - Figma: CSV の `Figma URL` を開き、`Inspect` で余白/typography/カラーを取得。リンクが共通の場合は node-id を差し替え。
   - ワイヤーフレーム: `docs/2-requirements/assets/<画面ID>.svg` をプレビューして静的構造を把握。差分や注記は実装タスクに記録。
5. **画面遷移**: `docs/3-external/31-画面遷移図.md` を開き、対象IDがどのノード間にあるか確認。Mermaid の矢印テキスト（操作名）を引用して遷移条件を説明。
6. **成果整理**: 画面概要、入出力項目、遷移先/戻り先、Figmaリンク、ワイヤーフレームパス、実装状態を表形式でまとめ、最後に検証手段（xcodebuild/Fastlane 等）や懸念点を列挙。

## 参照リソース
- [resource-map.md](references/resource-map.md): 主要ドキュメントと使いどころ。
- `scripts/find_screen_spec.py`: 画面IDの検索スクリプト。`--csv` オプションで別CSVを指定可能。

## メモ
- 追加資料や最新更新日を確認したら、回答内で絶対日付を明記する。
- Figma/Notion URL は必要に応じて `<` `>` で囲み、アクセス権が必要である旨を添える。
- 画面が未実装の場合は `画面メモ` に記載の TODO を引用し、バックログや `docs/testflight-reset-checklist.md` 等への影響を検討する。
