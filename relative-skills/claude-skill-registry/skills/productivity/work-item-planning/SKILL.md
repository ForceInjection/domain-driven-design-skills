---
name: work-item-planning
description: |
  1作業=1ディレクトリ（docs/<work_item>/）で、implementedplan.md と tasks.md を作る手順とテンプレ。
---

# 目的
planca が短時間で「実装可能な計画」と「完了条件つきタスク」を作れるようにする。

# 手順
1. work_item を決める（`YYYY-MM-DD_<short-slug>_vN`）
2. `docs/<work_item>/` を前提に、次の2ファイルを作成する
   - `implementedplan.md`
   - `tasks.md`
3. tasks は「完了条件」が曖昧にならないように書く

# implementedplan.md テンプレ
`templates/implementedplan.template.md` を参照。

# tasks.md テンプレ
`templates/tasks.template.md` を参照。

# よくある落とし穴
- 「タスクの完了条件」が書かれていない
- 実装に踏み込みすぎて、判断が必要な点を oca に返さない
