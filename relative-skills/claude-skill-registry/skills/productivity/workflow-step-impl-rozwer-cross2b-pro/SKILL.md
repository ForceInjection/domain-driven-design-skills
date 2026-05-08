---
name: workflow-step-impl
description: Temporal+LangGraph の工程（step）追加/修正の実装テンプレ。Activity 冪等性、output_path/output_digest、承認待ち、監査ログを含む。
---

## 使いどころ（トリガー例）

- 「工程を追加したい」「stepX を実装したい」「Activity を増やす」「LangGraph ノード追加」

## 手順（最小）

1) 仕様書で工程ID/入出力/承認ポイントを確定（`仕様書/`）  
2) 入力の正規化と `input_digest`（sha256）を定義  
3) Activity 実装（冪等：既存 `output_path` があれば再計算しない）  
4) 成果物は storage に保存し、返すのは参照のみ（`output_path/output_digest/summary/metrics`）  
5) Temporal Workflow に組み込み（工程3後は signal 待機）  
6) DB（`step_executions` / `generated_files` / `audit_logs`）の記録を追加  
7) レビューUI/ファイル取得APIが必要なら同時に更新

## テンプレ

- `templates/activity_skeleton.py`
- `templates/step_node_skeleton.py`
