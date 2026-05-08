---
name: review
description: GitHub issueの対応内容をレビューし、改善タスクを作成します。専門家エージェント（coding/architecture/testing/document-specialist）によるレビューを実施し、指摘点を元にtmp/todoフォルダにタスクファイルを作成します。
---

## 使用方法

### 作業手順

1. **GitHub issueの内容を把握する**
   - issue番号を引数として受け取る
   - リポジトリ情報は `git remote -v` で確認

2. **デフォルトブランチとの差分を確認**
   - デフォルトブランチを特定
   - そのブランチと現在のブランチの差分を確認して修正内容を把握

3. **専門家エージェントでレビューを行う**
   - **coding-specialist**: コーディングルール（docs/01_coding_rules.md）への準拠を確認
   - **architecture-specialist**: アーキテクチャルール（docs/02_architecture_rules.md）への準拠を確認
   - **testing-specialist**: テストルール（docs/03_testing_rules.md）への準拠を確認
   - **document-specialist**: 文書化ルール（docs/07_document_rules.md）への準拠を確認

4. **レビューでの指摘点を元にタスクファイルを作成**
   - 1ファイル1タスクとしてtmp/todoフォルダにファイルを作成

## タスクファイル作成ガイド

### ファイル名フォーマット

```
issue_{GitHub issue番号（#なし）}_plan_{2桁0埋めの1からの連番}_{タスク概要（英語）}.md
```

**例**: issue #1に対するタスクの場合

```
issue_1_plan_01_fix_error_handling.md
issue_1_plan_02_add_missing_tests.md
issue_1_plan_03_update_documentation.md
```

### ファイル内容のテンプレート

```markdown
## 対応内容の概要

## 対応内容の詳細

### 編集対象ファイル

### 完了条件

### 備考
- 適当な粒度でコミットすること。
```

## 注意事項

- tmp/todoフォルダが存在しない場合は自動的に作成されます
- 各専門家エージェントは順番に起動して、それぞれの観点からレビューを受けます
- すべてのエージェントからのレビュー完了後にタスクファイルを作成します
- レビュー指摘がない場合でも、確認した旨を記録してください

## 関連エージェント

- **coding-specialist**: コーディングルールの準拠確認
- **architecture-specialist**: アーキテクチャルールの準拠確認
- **testing-specialist**: テストルールの準拠確認
- **document-specialist**: 文書化ルールの準拠確認

## 関連ドキュメント

- [コーディングルール](../../../docs/01_coding_rules.md)
- [アーキテクチャルール](../../../docs/02_architecture_rules.md)
- [テストルール](../../../docs/03_testing_rules.md)
- [文書化ルール](../../../docs/07_document_rules.md)
- [コントリビューションガイド](../../../docs/04_contributing.md)
