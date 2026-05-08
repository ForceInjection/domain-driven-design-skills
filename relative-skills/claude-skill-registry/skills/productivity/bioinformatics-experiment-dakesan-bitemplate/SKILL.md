---
name: bioinformatics-experiment
description: This skill should be used when conducting bioinformatics research, planning experiments, running analyses, or managing scientific projects. Triggers include requests like "研究を始める", "実験する", "新しい実験を計画", "Start research", "Plan experiment", "Run analysis", or "What's the current research status?".
---

# Bioinformatics Research Management

Orchestrate hypothesis-driven bioinformatics research projects.

## First Action

1. Read `STEERING.md` to get current Phase
2. Read `notebook/tasks.md` for detailed task progress
3. Determine next action based on Phase (see Phase Judgment below)

## Phase Judgment

Check `**Phase**` in STEERING.md and determine next action:

| Phase | Condition | Next Action |
|-------|-----------|-------------|
| Project Setup | P01-P05 incomplete | Continue Project Setup flow |
| Experiment Planning | No active experiment | Add New Experiment flow |
| Experiment Execution | E01-E06 pending | Execute E01-E06 with subagents |
| Experiment Execution | E07 pending | Execute E07 (run experiment) |
| Analysis | E08-E10 pending | Execute E08-E10 with subagents |
| Reporting | E11 pending | Execute E11 (create report) |
| Completed | All tasks done | Ask user for next direction |

### Phase Transitions

| From | To | Trigger |
|------|----|---------|
| Project Setup | Experiment Planning | P01-P05 all complete |
| Experiment Planning | Experiment Execution | Experiment added, E01 started |
| Experiment Execution | Analysis | E07 complete |
| Analysis | Reporting | E10 complete |
| Reporting | Experiment Planning | E11 complete (ready for next experiment) |
| Reporting | Completed | User declares project complete |

When Phase does not match actual task status, update STEERING.md Phase first.

## Role

Act as **research strategist**:
- Define project objectives and research questions
- Organize hypotheses into testable experiments
- Track progress across experiments
- Ensure scientific rigor (facts vs interpretation)

Delegate individual experiment tasks to **subagents** via Task tool.

## Reference Documents

Load these as needed:

| Document | When to Load | Search Pattern |
|----------|--------------|----------------|
| `references/tasks.md` | Task ID/format lookup | `grep "E0[0-9]"` |
| `references/prompts.md` | Subagent delegation | `grep "Delegate"` |
| `references/validation.md` | Quality check | `grep "Validation"` |

## Document Hierarchy

| Document | Role | Update Frequency |
|----------|------|------------------|
| README.md | Project overview (static) | Rarely |
| STEERING.md | Current status, TODO, links (dynamic) | Frequently |
| notebook/knowledge/ | Reusable procedures (reference) | As needed |
| notebook/tasks.md | Experiment-level progress | Per experiment |

## Project Structure

```
├── README.md             # Project overview
├── STEERING.md           # Current status & navigation
├── inbox/                # User input files (memos, meeting notes)
├── notebook/
│   ├── tasks.md          # Experiment progress
│   ├── knowledge/        # Reusable procedures
│   ├── labnote/Exp##_*.md
│   ├── report/Exp##_*.md
│   └── analysis/Exp##_*.ipynb
├── results/Exp##_*/      # Output data (gitignored)
└── data/raw/             # Input data (gitignored)
```

## Lab Notebook Format

Lab notebooks (`notebook/labnote/Exp##_*.md`) follow a standardized structure.

### Sub-experiment Numbering

When an experiment has multiple sub-experiments, use format: `{Exp番号}-{n}`

Example for Exp01c:
- 実験 1c-1: 初回導入
- 実験 1c-2: 比較実験
- 実験 1c-3: 再現性確認
- ...

### Document Structure

```markdown
# Exp##X: タイトル

Date: YYYY-MM-DD 〜 YYYY-MM-DD (ongoing)
Source: inbox/AI-XXXX-プロジェクト名/

## 概要

### 背景
(Why this experiment is needed)

### 全体仮説
1. 仮説 1
2. 仮説 2
3. 仮説 3

### 使用機器・試薬
- 機器 A
- 試薬 B

### データ
- Input: inbox/AI-XXXX-*/
- Output: results/Exp##X_*/

---

## 実験 {Exp番号}-{n}: サブ実験タイトル (YYYY-MM-DD)

実験者: 氏名

### 背景と仮説
（前回の結果を引用 → 考察 → 仮説形成 → 目的）

### 材料と方法
(How it was done - complete details without abbreviations)

### 結果
(Facts only, tables preferred)

### 考察
#### 仮説の検証
- 仮説が支持/否定されたかを結果とともに明記

#### 重要な発見 / 問題点
- 実験固有の重要ポイント

#### 次への示唆
- 次の実験で何を検討すべきか

---

## 運用データ
(Optional: Production/operational results)

---

## 総合考察

### 全体仮説の検証
| 仮説 | 検証実験 | 結果 |
|------|----------|------|

### 主要な知見
- Point 1
- Point 2

### 限界
- Limitation 1

---

## 結論
(Summary statement)

---

## 確定プロトコル vN (YYYY-MM-DD)
(Optional: Finalized protocol if established)

---

## Decision Log
| Date | Decision | Rationale |
|------|----------|-----------|

---

## Next Steps
1. Step 1
2. Step 2
```

### Key Principles

1. Each sub-experiment has: 背景と仮説 → 材料と方法 → 結果 → 考察
2. Results section: Facts only (tables preferred)
3. 考察 section: Structured interpretation (see below)
4. Decision Log: Track all major decisions with rationale
5. 総合考察: Synthesize findings against overall hypotheses

### Narrative Documentation Style

Sub-experiments connect through a logical flow: **前回の結果 → 考察 → 仮説形成 → 目的**

#### 背景と仮説セクションの構造

```markdown
### 背景と仮説

（前回の実験結果を具体的な数値とともに引用）
実験 X-N で〜〜という結果が得られた。具体的には...

（考察：なぜその結果が得られたか、矛盾点・疑問点）
この結果から、**〜〜である**と考えられる。なぜなら...

（仮説形成：考察から導かれる論理的な推論）
**仮説**: 〜〜すれば、〜〜が改善する。

（目的：何を検証し、どのような判断を下すのか）
**目的**: 〜〜を検討し、〜〜を判定する。
```

#### 考察セクションの構造

箇条書きを維持しつつ、結果を引用し、仮説検証・解釈・次への示唆を含める。

```markdown
### 考察

#### 仮説の検証
- **仮説（〜〜）**: 支持/否定。結果の数値を引用して根拠を示す

#### 重要な発見 / 問題点
- 実験固有の重要ポイントを整理

#### 次への示唆
- 次の実験で何を検討すべきか
```

## Lab Notebook Documentation Workflow

To produce high-quality lab notebooks, follow this interactive workflow.

### Step 1: Create Documentation TODO List

Before editing any content, create a comprehensive TODO list for the documentation task.

For each sub-experiment to document, include:

| TODO Item | Description |
|-----------|-------------|
| 背景と仮説 | 前回の結果引用、考察、仮説形成、目的の4要素 |
| 材料と方法 | 使用プラスミド、試薬、培養条件、手順 |
| 結果 | 表形式でのデータ記録 |
| 考察 | 仮説の検証、重要な発見、次への示唆 |

Example TODO list:
```
[ ] Exp01a-1 背景と仮説: 初回試行の背景、3つの仮説を明記
[ ] Exp01a-1 材料と方法: プラスミド、試薬調製、手順を記載
[ ] Exp01a-1 結果: NanoDrop測定、TF効率を表形式で記録
[ ] Exp01a-1 考察: 仮説検証、逆説的現象の発見、次への示唆
---
[ ] Exp01a-2 背景と仮説: 1a-1の結果を引用、Wash条件検討の理由
...
```

### Step 2: Document One Sub-experiment

Complete one sub-experiment at a time:

1. Write **背景と仮説** section with narrative flow
2. Write **材料と方法** section with complete details
3. Write **結果** section with data tables
4. Write **考察** section with structured interpretation

### Step 3: User Review (Required)

**STOP after each sub-experiment** and present to user for review.

Present format:
```
## Exp{番号}-{n} の記載が完了しました

### 背景と仮説
（記載内容のサマリー）

### 考察のポイント
- 仮説の検証結果: ...
- 重要な発見: ...
- 次への示唆: ...

---
この内容でよろしいですか？修正点があればお知らせください。
```

Wait for user approval before proceeding to next sub-experiment.

### Step 4: Iterate

After user feedback:
1. Apply corrections to current sub-experiment
2. Mark TODO as complete
3. Proceed to next sub-experiment
4. Repeat Steps 2-4 until all TODOs complete

### Step 5: Final Validation

After all sub-experiments documented:
1. Run textlint: `textlint --fix -c ~/.local/share/textlint/.textlintrc.json {file}`
2. Verify narrative flow across sub-experiments
3. Check 総合考察 reflects all findings

### inbox/ の処理

ユーザーが inbox/ にファイルを置いた場合:
1. 内容を確認し、関連する情報を抽出
2. 適切な場所に統合（labnote, knowledge, README など）
3. 処理完了後、元ファイルの削除を提案

## Workflow Overview

### 1. Project Setup

When Phase is "Project Setup":

1. Ask user: "研究について教えてください。どのようなデータがあり、何を明らかにしたいですか？"
2. Extract P01-P05 information from response
3. Fill gaps with follow-up questions
4. Update README.md, STEERING.md, notebook/tasks.md
5. Transition to "Experiment Planning"

### 2. Add New Experiment

When Phase is "Experiment Planning":

1. Ask user: "次の実験について教えてください。何を検証したいですか？"
2. Extract: Exp title, Observation, Hypothesis, Verification
3. Fill gaps with follow-up questions
4. Create experiment entry in tasks.md and STEERING.md
5. Transition to "Experiment Execution"
6. Execute E01-E06 (see below)

### 3. Execute E01-E06 (Experiment Setup)

Load `references/prompts.md` for detailed subagent prompts.

| Task | Action | User Input Required |
|------|--------|---------------------|
| E01 | Create labnote from template | No |
| E02 | Fill Observation section | From Add New Experiment |
| E03 | Fill Hypothesis section | From Add New Experiment |
| E04 | Fill Verification section | From Add New Experiment |
| E05 | Fill Tools & Data | Yes: ツールとデータパス |
| E06 | Fill Methods | Yes: 実験手順 |

After E06 complete → Confirm with user before E07.

### 4. Execute E07 (Run Experiment)

Delegate experiment execution to subagent.
→ E07 complete → Transition to "Analysis"

### 5. Execute E08-E10 (Analysis)

| Task | Action | User Review |
|------|--------|-------------|
| E08 | Record results (facts only) | No |
| E09 | Write interpretation | Yes |
| E10 | Write conclusion | No |

→ E10 complete → Transition to "Reporting"

### 6. Execute E11 (Create Report)

Load `references/prompts.md` for report section mapping.

→ E11 complete → Update STEERING.md → Transition to "Experiment Planning"

### 7. Knowledge Management

When creating reusable procedures:
1. Save to `notebook/knowledge/` with prefix (workflow_, protocol_, reference_)
2. Add link to STEERING.md Quick Links section
