---
name: prompt-engineer
description: MUST use when editing CLAUDE.md, SKILL.md, or slash commands. Applies prompt engineering best practices regardless of task size.
---

# Prompt Engineer Skill

Claude Code向けプロンプト文書（CLAUDE.md、SKILL.md、カスタムスラッシュコマンド）の作成・改善を支援する。

## 対象ファイル

| ファイル種別 | 用途 | 配置場所 |
|------------|------|---------|
| CLAUDE.md | プロジェクト固有のコンテキスト・ルール | リポジトリルート、`~/.claude/` |
| SKILL.md | 再利用可能なスキル定義 | スキルディレクトリ |
| カスタムコマンド | 繰り返しワークフローのテンプレート | `.claude/commands/*.md` |

## 改善ワークフロー

### 1. 分析フェーズ

対象プロンプトを以下の観点で評価：

**構造面**
- 論理的なセクション分け
- XMLタグの適切な使用（`<instructions>`, `<context>`, `<example>`等）
- 情報の優先順位付け

**内容面**
- 目的の明確さ
- 指示の具体性（曖昧な表現の排除）
- 必要十分な情報量（過不足なし）

**Claude特性への適合**
- 命令形・直接的な表現
- 重要事項の強調（`IMPORTANT:`, `MUST`等）
- 出力形式の明示

### 2. 改善フェーズ

**優先順位**
1. 致命的問題（目的不明確、矛盾する指示）
2. 効果に直結（具体性不足、構造の混乱）
3. 品質向上（表現の洗練、エッジケース対応）

**主要テクニック**
- 曖昧な指示 → 具体的な行動指示に変換
- 長文の説明 → 簡潔な箇条書き or 例示
- 暗黙の期待 → 明示的な制約・条件

### 3. 検証フェーズ

改善後、以下をチェック：
- [ ] 元の意図が保持されているか
- [ ] Claudeが誤解しうる表現がないか
- [ ] 不要な情報が削除されているか
- [ ] 重要な情報が強調されているか

## コア原則

### 簡潔さが最優先

コンテキストウィンドウは共有資源。すべてのトークンが他の情報と競合する。

**前提**: Claudeは既に非常に賢い

Claudeが既に知っていることは書かない。各情報に対して以下を問う：
- 「Claudeは本当にこの説明が必要か？」
- 「Claudeは既にこれを知っていると仮定できるか？」
- 「この文はトークンコストに見合う価値があるか？」

```markdown
# Bad（約150トークン）
PDF（Portable Document Format）はテキスト、画像、その他のコンテンツを含む
一般的なファイル形式です。PDFからテキストを抽出するにはライブラリが必要です。
pdfplumberは使いやすく、ほとんどのケースに対応できるのでお勧めです...

# Good（約50トークン）
PDFテキスト抽出にはpdfplumberを使用:

\`\`\`python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
\`\`\`
```

Good版はClaudeがPDFとライブラリの概念を知っていることを前提としている。

### 具体性で曖昧さを排除

```markdown
# Bad
テストを書いてください

# Good
`tests/`に新規テストファイルを作成。edgeケース（null入力、空配列）を含むこと。mockは使用禁止。
```

### 構造で意図を伝える

XMLタグで情報を分離。Claudeはタグ構造を強く認識する。

```markdown
<task>PRをレビューしてコメントを残す</task>

<constraints>
- セキュリティ上の問題は最優先で指摘
- スタイルの指摘は控えめに
- 必ず改善案を提示
</constraints>

<output_format>
各指摘を以下の形式で出力：
- ファイル: 行番号
- 重要度: high/medium/low
- 内容: 指摘事項
- 提案: 改善案
</output_format>
```

## 詳細ガイド

- **CLAUDE.md/コマンド規約**: [references/claude-code-conventions.md](references/claude-code-conventions.md)
- **プロンプトパターン集**: [references/prompt-patterns.md](references/prompt-patterns.md)
