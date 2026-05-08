---
name: mcp-cipher-complex-analysis
description: Complex analysis using Cipher MCP (10-30s) for library research via context7, design pattern memory search, and multi-tool integration for LoRAIro strategic planning
allowed-tools: cipher_memory_search, cipher_store_reasoning_memory, cipher_extract_entities, cipher_query_graph, mcp__context7__resolve-library-id, mcp__context7__get-library-docs, WebSearch, WebFetch
---

# Cipher Complex Analysis Skill

このSkillは、Cipher MCPツールを使った複雑な分析（10-30秒）の最適な使い方を提供します。特に、設計判断、ライブラリ研究、長期記憶化において効果を発揮します。

## 使用タイミング

Claudeは以下の場合にこのSkillを自動的に使用すべきです：

- **設計パターン検索**: 過去の類似設計や実装パターンを調査
- **ライブラリ研究**: context7経由での技術ドキュメント・APIリファレンス取得
- **長期記憶化**: 設計判断、実装アプローチ、技術的根拠を永続化
- **複雑な関係分析**: 設計要素間の依存関係やアーキテクチャ理解
- **戦略的意思決定**: 複数アプローチの評価、トレードオフ分析

## Cipher複雑分析パターン

### 1. 設計知識検索（10-30秒）

#### cipher_memory_search - 過去の設計パターン検索
```
用途: 類似機能の設計判断、実装パターン、技術的教訓を検索
タイミング: 新機能設計前、アーキテクチャ判断時、技術選定時
パラメータ:
  - query: 検索クエリ（例: "widget communication pattern"）
  - limit: 取得する結果数（デフォルト: 5）

検索対象:
  - 過去の設計アプローチと判断根拠
  - アーキテクチャパターンと適用事例
  - 技術選定の基準と結果
  - 実装時の課題と解決策
  - ベストプラクティスとアンチパターン
```

#### cipher_extract_entities - 重要設計要素の特定
```
用途: 設計ドキュメントや実装計画から重要な概念・技術要素を抽出
タイミング: 設計レビュー、アーキテクチャ分析時
パラメータ:
  - text: 分析対象のテキスト
  - entity_types: 抽出するエンティティタイプ（オプション）

抽出対象:
  - アーキテクチャコンポーネント
  - 技術スタック
  - デザインパターン
  - 制約条件
  - 依存関係
```

#### cipher_query_graph - 設計要素間の関係分析
```
用途: 設計要素、コンポーネント、技術の依存関係を分析
タイミング: アーキテクチャ影響分析、リファクタリング計画時
パラメータ:
  - query: グラフクエリ
  - depth: 検索深度

分析対象:
  - コンポーネント間依存
  - 技術スタック関係
  - パターン適用箇所
  - 影響範囲
```

### 2. 長期記憶化（設計知識の永続化）

#### cipher_store_reasoning_memory - 設計判断と根拠の保存
```
用途: 設計アプローチ、技術判断、実装根拠を長期記憶として保存
タイミング: 設計完了後、重要な技術判断後、実装完了後
保存内容:
  - 設計アプローチと選択理由
  - アーキテクチャ判断の背景と意図
  - 技術選定の評価基準と結果
  - パフォーマンス・保守性の考慮
  - 実装時の課題と解決策
  - ベストプラクティスと得られた教訓

記憶形式:
  - タイトル: 簡潔な要約
  - コンテキスト: 背景状況
  - 判断内容: 具体的な決定事項
  - 根拠: なぜその判断をしたか
  - 結果: 実装結果と効果
  - 教訓: 将来への知見
```

### 3. ライブラリ研究（context7経由）

#### mcp__context7__resolve-library-id - ライブラリID解決
```
用途: ライブラリ名からcontext7のIDを解決
タイミング: 新しいライブラリの調査開始時
パラメータ:
  - library_name: ライブラリ名（例: "pyside6", "sqlalchemy"）

対応ライブラリ例:
  - Python標準ライブラリ
  - PySide6（Qt for Python）
  - SQLAlchemy
  - pytest
  - その他主要Pythonライブラリ
```

#### mcp__context7__get-library-docs - ライブラリドキュメント取得
```
用途: context7経由で公式ドキュメント、APIリファレンス、ガイドを取得
タイミング: 技術選定時、実装方法調査時
パラメータ:
  - library_id: resolve-library-idで取得したID
  - section: ドキュメントのセクション（オプション）

取得可能な情報:
  - 公式APIリファレンス
  - ベストプラクティスガイド
  - チュートリアル
  - アーキテクチャガイド
  - サンプルコード
```

### 4. Web検索との統合

#### WebSearch - 最新情報の検索
```
用途: context7に無い最新情報、ブログ記事、事例研究の検索
タイミング: context7で情報不足の場合、最新動向調査時
```

#### WebFetch - 特定URLの詳細取得
```
用途: 検索で見つかった記事の詳細内容を取得
タイミング: WebSearchの結果から有用なページを深掘りする時
```

## Cipherとの効果的な統合

### 最適な使用フロー

#### 設計フェーズ
```
1. Memory検索: cipher_memory_search で過去の類似設計を調査
   → 既存の知見を活用、重複設計を回避

2. Entity抽出: cipher_extract_entities で設計要素を特定
   → 重要な技術要素、パターンを明確化

3. Graph分析: cipher_query_graph で依存関係を分析
   → アーキテクチャ影響を評価

4. Library研究: context7 でライブラリ詳細を調査
   → 最適な技術選択

5. 長期記憶: cipher_store_reasoning_memory で判断を記録
   → 将来の参照資産として蓄積
```

#### 実装フェーズ
```
1. Memory検索: cipher_memory_search で実装パターンを確認
   → 過去の成功パターンを再利用

2. Library調査: context7 で実装詳細を確認
   → 正しいAPIの使い方を理解

3. 長期記憶: 実装完了後、cipher_store_reasoning_memory で記録
   → 実装判断と教訓を永続化
```

## SerenaとCipherの使い分け

### Serena Fast Ops (1-3秒) を使うべき場合
- シンボル検索（クラス、メソッド、関数）
- ファイル構造把握
- 短期メモリ操作（進捗記録）
- 基本コード編集

### Cipher Complex Analysis (10-30秒) を使うべき場合
- 過去の設計パターン検索
- ライブラリ研究（context7経由）
- 設計判断の長期記憶化
- 複雑な依存関係分析
- 戦略的意思決定

### 併用パターン
```
効率的な開発フロー:
1. Serena: 現在状況確認（read_memory）
2. Cipher: 過去の類似設計検索（cipher_memory_search）
3. Cipher: ライブラリ調査（context7）
4. Serena: コード実装（find_symbol, replace_symbol_body）
5. Serena: 進捗記録（write_memory）
6. Cipher: 長期記憶化（cipher_store_reasoning_memory）
```

## タイムアウト対策

Cipher操作は10-30秒かかるため、以下の戦略で効率化：

### 段階的アプローチ
1. **検索範囲の絞り込み**: 具体的なクエリで検索
2. **並行実行回避**: Cipher操作を順次実行
3. **Serenaへのフォールバック**: タイムアウト時はSerena + WebSearchで代替

### エラー時の対処
- **Cipher timeout**: 操作を小さく分割して再試行
- **Connection error**: Serena操作 + WebSearch の組み合わせで代替
- **複雑すぎる分析**: Investigation/Library-Research/Solutionsエージェントを使用

## LoRAIro固有のCipher活用

### 記憶化すべき設計判断
- **アーキテクチャパターン**: Repository Pattern、Service Layer、Direct Widget Communication
- **技術選定**: SQLAlchemy、PySide6、pytest選択理由
- **パフォーマンス改善**: キャッシュ戦略、非同期処理判断
- **リファクタリング**: 大規模変更の意図と効果

### context7で調査すべきライブラリ
- **PySide6**: Signal/Slot、QThread、Qt Designer統合
- **SQLAlchemy**: ORM、トランザクション、マイグレーション
- **pytest**: フィクスチャ、モック、パラメタライズ
- **Pillow**: 画像処理、メタデータ抽出

### 検索クエリ例
- "widget signal slot direct communication pattern"
- "sqlalchemy repository pattern best practices"
- "pytest fixture setup teardown pattern"
- "pyside6 qthread worker pattern"

## Examples
詳細な使用例は [examples.md](./examples.md) を参照してください。

## Reference
CipherツールとContext7の完全なAPIリファレンスは [reference.md](./reference.md) を参照してください。
