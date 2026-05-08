---
name: implementation-loop
description: |
  implca が tasks を更新しながら実装→テスト→修正を回すための手順。
---

# 目的
実装の進捗・検証結果・詰まりを docs/<work_item>/ に残し、レビュー/引き継ぎを楽にする。

# 手順
1. `docs/<work_item>/implementedplan.md` を読む
2. `docs/<work_item>/tasks.md` を上から順に進める
3. 実装後は最小限の確認（lint/test/build）を回す
4. 結果を tasks.md（必要なら notes.md）に短く残す
5. review.md が来たら Must から順に潰す

# 記録ルール
- tasks.md: 完了した項目にチェックを付け、必要なら1行メモ
- notes.md: 判断が必要そうな点、妥協点、残課題だけを短く

# 実行コマンドの扱い
- 原則: lint/test/build/dev（非破壊）
- 実行したら「何を実行しどうだったか」を必ず残す
