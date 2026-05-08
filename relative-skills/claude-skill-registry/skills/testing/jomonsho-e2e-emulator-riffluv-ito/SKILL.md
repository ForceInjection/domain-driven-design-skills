---
name: jomonsho-e2e-emulator
description: エミュレータを使った Playwright E2E を2回連続で実行する。
metadata:
  short-description: Emulator E2E（Playwright / workers=1 / 2回連続）。
---

# Emulator E2E（日本語）

Firebase Emulator Suite と Playwright（workers=1）を使う。
  - 重要変更や明示指示があるときのみ実行（軽微変更では走らせない）。

コマンドテンプレート:
  npx firebase emulators:exec --only firestore,auth,database \
    "npx playwright test --workers=1 <spec>"

ルール:
- 同一 spec を2回連続で実行（フレーク検出）
- 全件実行は避け、必要な spec だけ実行
- 失敗したら修正後に2回連続で再実行

報告:
- 2回連続 PASS の結果を簡潔に記載
