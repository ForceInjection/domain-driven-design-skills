---
name: verify-and-coverage
description: |
  仕様を実行可能テスト（verify.md）に変換し、カバレッジを分析するワークフロー。Runme.dev形式でE2E/統合テストを記述。
  使用タイミング:
  (1) 仕様書（spec.md等）から実行可能なテストドキュメントを作成したい場合
  (2) テストカバレッジを分析・可視化したい場合
  (3) 「verify.md作成」「カバレッジチェック」「テスト文書化」リクエスト
  使用しない場合: ユニットテストのみ必要な場合、既存テストフレームワークで十分な場合
allowed-tools: Read, Bash(runme:*), Bash(curl:*), Bash(git:*)
---

# 実行可能テスト & カバレッジ管理

## 目的

仕様書（spec.md等）を実行可能なテストドキュメント（verify.md）に変換し、要件カバレッジを管理します。

## コンセプト

- **verify.md**: Runme.dev形式の実行可能テストドキュメント
- **coverage.md**: 仕様とテストのマッピング・ギャップ分析

## ワークフロー

### 1. verify.md作成

仕様のシナリオを実行可能なテストケースに変換します。

→ [workflows/create-verify.md](workflows/create-verify.md)

### 2. カバレッジチェック

仕様の各要件がテストでカバーされているか分析します。

→ [workflows/check-coverage.md](workflows/check-coverage.md)

## テンプレート

- **verify.md**: [templates/verify-template.md](templates/verify-template.md)
- **README.md**: [templates/README-template.md](templates/README-template.md)
- **coverage.md**: [templates/coverage-template.md](templates/coverage-template.md)

## 詳細ガイド

- [verify.md実装ガイド](references/verify-guide.md)
- [カバレッジチェックガイド](references/coverage-check.md)

## Runme.dev統合

verify.mdはRunme.devで直接実行可能です：

```bash
# テスト一覧を確認
runme list --filename verify.md

# 特定のテストを実行（<prefix>はchange-idに置き換え）
runme run <prefix>-test-create-resource --filename verify.md

# 全テストを一括実行
runme run --all --filename verify.md
```

**注意**: コマンド名はプロジェクト内でユニークである必要があります。`<prefix>`には`change-id`または機能名を使用してください。

## テストピラミッドにおける位置づけ

verify.md（統合テスト）は以下をカバーします：

- End-to-Endフロー（UI/CLI → API → DB）
- 外部リソース依存（実際のDB接続、ファイルI/O）
- 複数コンポーネント結合

**原則**: 可能な限りユニットテストで検証し、外部依存や結合コストが高いものだけverify.mdで確認します。
