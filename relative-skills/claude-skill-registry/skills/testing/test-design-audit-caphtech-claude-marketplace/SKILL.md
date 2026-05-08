---
name: test-design-audit
description: |
  ELD統合版テスト設計監査スキル。Law/Term駆動でテスト設計の抜け漏れを防止する。
  モデル化とEvidence Ladderを組み合わせ、法則の接地を体系的に検証する。

  Use when:
  - テスト設計、テスト計画作成、QA開始前
  - ELDのGroundフェーズでのテスト設計
  - Law/Termの接地検証
  - 「テスト漏れがないか不安」と感じた時
---

# Test Design Audit（ELD統合版テスト設計監査）

## ELDとの関係

本スキルはELD（Evidence-Loop Development）のGroundフェーズにおける
テスト設計を体系化する。

```
ELD Loop: Sense → Model → Predict → Change → Ground → Record
                                              ↑
                                    test-design-audit
```

**Law/Term → テスト条件への導出**を行い、Evidence Ladderでの接地を保証する。

## 核心原則

**生成AIの限界を理解する**：AIは「それらしい網羅」を"生成"するのは得意だが、「何が未生成か」を"証明"するのは苦手。

**対策**：列挙前に「モデル化」と「監査」を挿入し、抜けを"見える化"する。

**ELD的強化**：Law/Termを要求の源泉とし、Evidence Ladderでカバレッジを階層化する。

## 抜け漏れの定義

現実には状態空間・入力空間・環境差分が巨大で"全組み合わせを全件テスト"は成立しない。
実務的な「抜け漏れがない」の定義：

1. **要求カバレッジ**: スコープ内の要求（機能/非機能/制約/既知リスク）に対してテスト条件が対応づいている
2. **未知の明示**: 未知（不明点）と仮定が明示され、未確定領域がテスト外になっていない

## ワークフロー概要

```
Phase 0: コンテキストパック収集 + pce-memory活性化
    ↓
Phase 1: 要求の棚卸し（REQ-xxx）+ Law/Term対応付け
    ↓
Phase 2: モデル化（5つのモデル + Law/Term視点）
    ↓
Phase 3: カバレッジ基準策定 + Evidence Ladder
    ↓
Phase 4: テスト条件ツリー（TCND-xxx）+ Law Grounding
    ↓
Phase 5: 監査（複数視点 + Law違反チェック）
    ↓
Phase 6: テスト項目生成（TEST-xxx）+ Grounding Map連携
    ↓
Phase 7: トレーサビリティ検証 + Law/Term紐付け
    ↓
Phase 8: 差分運用 + pce-memory記録
```

---

## Phase 0: コンテキストパック収集 + pce-memory活性化

AIに渡す情報を固定する。情報が散らばるとモデルが不安定になり抜けが増える。

### ELD統合: pce-memory活性化

```
pce_memory_activate({
  q: "テスト対象機能 Law Term 既知バグ",
  scope: ["project", "principle"],
  allow: ["*"]
})
```

過去の知識（Law/Term、バグパターン、設計決定）を活性化し、テスト設計に反映する。

### 必須収集項目

| カテゴリ | 収集内容 |
|---------|---------|
| **システム概要** | 何をするシステムか |
| **対象範囲** | スコープ内/スコープ外の明示 |
| **ユースケース** | 主要ユーザーフロー |
| **依存** | 外部API、決済、認証、Push、DB、OS機能 |
| **データ制約** | 入力バリデーション、桁、形式 |
| **権限・ロール** | ユーザー種別とアクセス制御 |
| **非機能** | 性能、セキュリティ、可用性、監査ログ、アクセシビリティ |
| **運用** | 障害時対応、監視、リリース、バックアウト |
| **既知障害** | 過去のインシデント、ヒヤリハット |
| **受入基準** | Doneの定義 |

**警告**: ここが薄いとAIは「一般論のテスト」になり、固有リスクを取り逃がす。

---

## Phase 1: 要求の棚卸し + Law/Term対応付け

**目的**: 要求を「テスト可能な形」に変換し、Law/Termと対応付ける。

### ELD統合: Law/Term対応付け

要求をELDのLaw/Termに対応付けることで、テストの根拠を明確化する。

| 対応パターン | 説明 |
|--------------|------|
| REQ → Law | 要求が既存Lawの検証に対応 |
| REQ → Term | 要求がTermの境界検証に対応 |
| REQ → 新Law候補 | 新しいLawの発見（`/eld-model-law-discovery`へ） |

### 出力フォーマット

```markdown
| REQ ID | 種類 | 要求概要 | 受入条件（観測可能） | Law/Term |
|--------|------|---------|-------------------|----------|
| REQ-001 | 機能 | ログイン機能 | 正しい資格情報でセッション発行 | LAW-auth-valid-credential |
| REQ-002 | 非機能 | レスポンス2秒以内 | 95%タイルで2秒以下 | LAW-response-time-sla |
| REQ-003 | 制約 | パスワード8文字以上 | 7文字以下でエラー | TERM-password |
```

### 種類の分類

- 機能（Functional）→ 多くの場合Law（Invariant/Pre/Post）に対応
- 非機能（Non-functional）→ Policy Lawに対応
- 制約（Constraint）→ Termの境界条件に対応
- 運用（Operational）→ Policy Lawに対応
- 法令・規約（Regulatory）→ S0 Lawに対応
- UX（User Experience）→ 新Law候補として検討

### 必須セクション

要求一覧とは別に「**不明点・矛盾・仮定**」セクションを設ける。これがないと仮定が埋め込まれたまま進む。

**Law/Termが未定義の場合**は `(NEW-LAW)` または `(NEW-TERM)` ラベルを付け、
`/eld-model-law-card` または `/eld-model-term-card` で定義する。

---

## Phase 2: モデル化 + Law/Term視点

**核心**: テストは列挙ではなく、モデルから導出する。Law/Termを軸に整理する。

詳細テンプレートは `references/model-templates.md` を参照。

### ELD統合: モデルとLaw/Termの対応

| モデル | Law/Termとの対応 |
|--------|------------------|
| 機能分解 | 各機能の不変条件（Invariant）をLaw化 |
| 状態モデル | 状態遷移制約をLaw化、状態をTermとして定義 |
| データモデル | エンティティをTerm化、整合性制約をLaw化 |
| 外部IFモデル | API契約をPre/Post条件としてLaw化 |
| リスクモデル | 失敗モードを「Law違反パターン」として整理 |

### 2-1. 機能分解（Feature Tree）+ Invariant

```
機能 → サブ機能 → 操作/イベント → 期待結果 → [関連Law]
```

各機能に関連するLaw（不変条件）を紐付ける。

### 2-2. 状態モデル（State Machine）+ 状態遷移Law

主要状態と遷移イベントを明確化。

例：`未ログイン → ログイン中 → トークン期限切れ → 退会済み`

**Law化**: 状態遷移制約（「退会済み→ログイン中」は不可など）

### 2-3. データモデル + Term定義

エンティティ、属性、制約、整合性、更新規則。PIIや秘匿データの扱い。

**Term化**: 主要エンティティをTerm Cardとして定義（境界、観測写像）

### 2-4. 外部IFモデル + Pre/Post条件

API一覧、リクエスト/レスポンス、エラーコード、リトライ方針、タイムアウト、冪等性。

**Law化**: API契約をPre条件（入力制約）/Post条件（出力保証）として明示

### 2-5. リスクモデル + Law違反パターン

失敗モード → 影響 → 検出方法 → 予防/緩和 → テスト観点

**ELD観点**: 各失敗モードを「どのLawが破られるか」で分類

---

## Phase 3: カバレッジ基準策定 + Evidence Ladder

「何を満たすと網羅と言えるか」を明示。これがないとAIは"それっぽい数"で止まる。

詳細は `references/coverage-criteria.md` を参照。

### ELD統合: Evidence Ladder

ELDの「証拠の梯子」を基準に、テストの深さを階層化する。

| Level | 検証内容 | 対象 | テスト種別 |
|-------|----------|------|------------|
| **L0** | 静的整合 | 全Law/Term | 型チェック、Lint |
| **L1** | 単体での成立 | S0-S2 Law | ユニットテスト、Property-based test |
| **L2** | 連携での成立 | S0-S1 Law | 統合テスト、E2Eテスト |
| **L3** | 異常時の維持 | S0 Law | 失敗注入、Fuzz testing |
| **L4** | 実運用での成立 | S0-S1 Law | 本番Telemetry、監視 |

**重要**: L0だけで完了扱いしない。S0 LawはL2以上必須。

### Law Severity別の必須レベル

| Severity | 必須レベル | 推奨レベル |
|----------|------------|------------|
| S0（致命的） | L0 + L1 + L2 + L3 | L4 |
| S1（重要） | L0 + L1 + L2 | L3 + L4 |
| S2（中程度） | L0 + L1 | L2 |
| S3（低） | L0 | L1 |

### 基本基準

| 基準 | 定義 | Evidence Ladder |
|------|------|-----------------|
| **要求カバレッジ** | 全REQに対して少なくとも1つのTCND | - |
| **Law接地カバレッジ** | 全Lawが必須レベルを達成 | L0-L4 |
| **状態遷移カバレッジ** | 主要遷移（正常/異常）をすべて通す | L1-L2 |
| **入力空間カバレッジ** | 同値分割＋境界値（Termの境界） | L1 |
| **エラー網羅** | 外部IFの代表的失敗（timeout/5xx/4xx/不正payload） | L2-L3 |
| **品質特性カバレッジ** | 性能・セキュリティ・可用性・監査ログ・アクセシビリティ | L2-L4 |
| **環境カバレッジ** | OS/端末/ネットワーク/言語/権限（必要な範囲） | L2 |

---

## Phase 4: テスト条件ツリー作成 + Law Grounding

**テスト項目を直接書かせず、まずテスト条件の木を作らせる。**
**Law/Termの接地（Grounding）を意識した構造にする。**

### ELD統合: Law Grounding視点

テスト条件をLaw/Termの接地レベル（Evidence Ladder）で分類する。

```
Feature A [LAW-xxx]
├── L1: ユニットテスト条件
│   ├── TCND-001: 基本フロー成功 [L1]
│   └── TCND-002: 境界値検証 [L1]
├── L2: 統合テスト条件
│   ├── TCND-003: 外部IF連携成功 [L2]
│   └── TCND-004: 状態遷移正常 [L2]
├── L3: 失敗注入テスト条件
│   ├── TCND-005: timeout時の回復 [L3]
│   └── TCND-006: 5xx応答時のフォールバック [L3]
└── L4: 運用観測条件
    └── TCND-007: Telemetry記録確認 [L4]
```

### 構造（ELD統合版）

```
Feature A [LAW-feature-a-invariant]
├── 正常系
│   ├── TCND-001: 基本フロー成功 [L1] [LAW-xxx]
│   └── TCND-002: オプション付きフロー [L2] [LAW-xxx]
├── 入力バリデーション [TERM-input-xxx]
│   ├── TCND-003: 必須項目欠落 [L1]
│   └── TCND-004: 形式不正（境界値） [L1]
├── 状態依存 [LAW-state-transition]
│   ├── TCND-005: 状態S1からの操作 [L2]
│   └── TCND-006: 状態S2からの操作 [L2]
├── 外部IF失敗 [LAW-external-if-contract]
│   ├── TCND-007: timeout [L3]
│   └── TCND-008: 5xx応答 [L3]
├── セキュリティ [LAW-security-xxx]
│   ├── TCND-009: 権限不足 [L2]
│   └── TCND-010: 不正操作 [L3]
├── 性能/負荷 [LAW-performance-sla]
│   └── TCND-011: 同時接続100件 [L2-L4]
└── 監査ログ [LAW-audit-trail]
    └── TCND-012: 操作記録確認 [L4]
```

### 必須ルール

- 各葉に `TCND-xxx` のIDを付与
- どのREQに対応するか（REQ-xxx）を必ず紐づける
- **どのLaw/Termを検証するか**を紐づける
- **Evidence Ladderのレベル**（L1-L4）を明示
- 不明点がある葉は `(UNKNOWN)` ラベルをつけて残す（消さない）

---

## Phase 5: 監査 + Law違反チェック

**核心**: 生成AIを「批判側」に回す。役割を変えると見つかる抜けが増える。
**ELD的追加**: Law/Termの接地状況を監査する。

### 監査役プロンプト

```
あなたはテスト監査人（生成した本人ではない体）。
以下のテスト条件ツリーを監査し、抜け漏れの可能性を列挙せよ。
特に以下の観点で監査：
1. 全てのLaw/Termに対してテスト条件が存在するか
2. Law Severityに応じたEvidence Ladderレベルを満たしているか
3. Law違反時の動作がテストされているか
```

### 監査観点

詳細チェックリストは `references/audit-checklist.md` を参照。

**必須観点**:
- 要求カバレッジ欠落（REQに紐づかない/未対応REQ）
- **Law/Term接地カバレッジ欠落**（Law/Termに紐づかない/未接地）
- **Evidence Ladder未達成**（S0 LawがL2未満など）
- 状態遷移の未カバー
- エラー処理、復旧、冪等性、再試行、タイムアウト
- **Law違反時の動作テスト欠落**
- 競合（同時操作、二重送信）、順序逆転、遅延
- 権限/認可、ログ、監査、個人情報
- 互換性/環境差分
- テストデータ（境界値、相関制約）
- "未知/仮定"が放置されてテスト不能になっていないか

### ELD統合: Law接地監査

`/eld-ground-check` を使用してLaw/Termの接地状況を検証:

```
/eld-ground-check LAW-xxx

結果:
✅ L0: 型チェック通過
✅ L1: Unit Test (3/3)
❌ L2: Integration Test なし
❌ L3: 失敗注入テストなし
⚠️ L4: Telemetry設定済み（未検証）

推奨アクション:
- L2: 統合テスト TCND-xxx を追加
- L3: timeout/5xx時の動作テストを追加
```

### 複数視点での監査（必須）

監査は**最低2回、異なる視点**で行う：

1. **1回目**: QA視点（一般的な抜け漏れ）
2. **2回目**: **Law接地視点**（ELD固有）
3. **3回目**（推奨）: 以下から選択
   - 運用担当視点
   - セキュリティ担当視点
   - 性能担当視点
   - アクセシビリティ担当視点

---

## Phase 6: テスト項目生成 + Grounding Map連携

ツリーの「葉」から生成する。葉IDがあるので抜けが追える。
**ELD的追加**: Grounding Mapと連携してLaw/Termの接地を保証する。

### 出力フォーマット（ELD統合版）

```markdown
| TEST ID | TCND | REQ | Law/Term | Level | 前提条件 | 入力 | 期待結果 |
|---------|------|-----|----------|-------|---------|-----|---------|
| TEST-001 | TCND-001 | REQ-001 | LAW-auth | L1 | 未ログイン状態 | 有効なID/PW | セッション発行 |
| TEST-002 | TCND-003 | REQ-003 | TERM-password | L1 | - | 7文字PW | エラー表示 |
| TEST-003 | TCND-007 | REQ-004 | LAW-external-if | L3 | 外部API停止中 | 任意 | フォールバック動作 |
```

### ELD統合: Grounding Map更新

テスト項目をGrounding Mapに反映:

```yaml
# grounding-map.yaml
laws:
  LAW-auth-valid-credential:
    severity: S0
    verification:
      unit:
        - TEST-001  # ← test-design-auditから追加
        - TEST-002
      integration:
        - TEST-010
      runtime:
        - AuthService.validateCredential
    observation:
      telemetry:
        - auth.success_rate
      alert:
        - auth_failure_spike
```

### ルール

- 各TESTは必ず1つ以上のTCNDに紐づく
- **各TESTは必ず1つ以上のLaw/Termに紐づく**
- **Evidence Ladderのレベルを明示**
- 期待結果は観測可能な形（UI表示/状態/ログ/APIレスポンス）
- `(UNKNOWN)` はテストを捏造せず、質問・前提の形で残す

---

## Phase 7: トレーサビリティ検証 + Law/Term紐付け

### 対応表の作成（ELD統合版）

```markdown
| REQ ID | Law/Term | TCND | TEST | Level | ステータス |
|--------|----------|------|------|-------|----------|
| REQ-001 | LAW-auth | TCND-001, TCND-002 | TEST-001, TEST-002 | L1, L2 | カバー済 |
| REQ-002 | LAW-perf | - | - | - | **未対応** |
| REQ-003 | TERM-password | TCND-003 | TEST-003 | L1 | カバー済 |
```

### ELD統合: Law/Term接地状況表

```markdown
| Law/Term | Severity | 必須Level | 現在Level | TCND | ステータス |
|----------|----------|-----------|-----------|------|----------|
| LAW-auth | S0 | L0-L3 | L0-L2 | TCND-001,002 | **L3未達** |
| LAW-perf | S1 | L0-L2 | L0 | - | **未接地** |
| TERM-password | S1 | L0-L1 | L1 | TCND-003 | ✅ 達成 |
```

### 抜け検出

- `未対応` = REQに紐づくTCND/TESTがない → **抜け確定**
- **`未接地`** = Law/Termに紐づくTCND/TESTがない → **ELD的抜け確定**
- **`Level未達`** = 必須Evidence Ladderレベルに未到達 → **追加テスト必要**
- `TESTのみ存在` = REQ/Law紐づきなし → 探索テストか不要かを判断

---

## Phase 8: 差分運用 + pce-memory記録

仕様変更時に再発しないための運用。
**ELD的追加**: 設計決定とパターンをpce-memoryに記録する。

### 手順

1. 仕様差分（REQの追加/変更/削除）を特定
2. **Law/Term差分**（新規Law/変更されたLaw）を特定
3. 影響範囲（どのFeature/State/Data/IF/**Law**に波及するか）を分析
4. 影響のあるTCND/TESTだけを更新
5. 対応表を更新して「未対応REQゼロ」「未接地Law/Termゼロ」を維持
6. **pce-memoryに記録**

### ELD統合: pce-memory記録

テスト設計で発見した知識をpce-memoryに記録:

```
pce_memory_upsert({
  text: "認証機能のテスト設計完了。LAW-auth-valid-credentialに対してL1-L2のテストを設計。L3（失敗注入）は次スプリントで対応予定。",
  kind: "fact",
  scope: "project",
  boundary_class: "internal",
  provenance: {
    at: "2024-01-15T10:00:00Z",
    actor: "test-design-audit"
  }
})
```

### 記録すべき内容

| 種類 | 内容 | scope |
|------|------|-------|
| テスト設計決定 | カバレッジ基準の選択理由 | project |
| 未対応項目 | 意図的に除外した項目とその理由 | project |
| 発見したパターン | 再利用可能なテスト条件パターン | principle |
| 新Law/Term | テスト設計中に発見した暗黙の法則 | project |

---

## 最小セット（時間がない場合）

- **(T1)** 要求一覧（REQ-xxx）を作成し、不明点を明示、**Law/Term対応付け**
- **(T2)** 主要な観点（正常系・異常系・境界・セキュリティ）でテスト条件を作成、**Evidence Ladder明示**
- **(T3)** 監査を1回実施（**Law接地視点を含める**）
- **(T4)** トレーサビリティ表で未対応REQと**未接地Law/Term**を確認

---

## 出力物

- `requirements.md`: 要求一覧（REQ-xxx）+ 不明点・仮定 + **Law/Term対応**
- `models/`: 5つのモデル（Feature tree、状態、データ、外部IF、リスク）+ **Law/Term視点**
- `coverage-criteria.md`: このプロジェクトのカバレッジ基準 + **Evidence Ladder**
- `test-conditions.md`: テスト条件ツリー（TCND-xxx）+ **Law Grounding**
- `audit-report.md`: 監査結果（抜け候補と対応）+ **Law接地監査**
- `test-cases.md`: テスト項目一覧（TEST-xxx）+ **Grounding Map連携**
- `traceability.md`: 要求↔テスト対応表 + **Law/Term接地状況表**
- **`grounding-map.yaml`**: Law/Term → Test/Telemetry対応表（ELD共通）

---

## ELD関連スキル

| スキル | 用途 |
|--------|------|
| `/eld` | ELD統合開発手法のメイン |
| `/eld-model-law-discovery` | 新しいLawの発見 |
| `/eld-model-law-card` | Law Cardの作成 |
| `/eld-model-term-card` | Term Cardの作成 |
| `/eld-ground-check` | Law/Termの接地状況検証 |
| `/eld-ground-evaluate` | 成果物評価 |
| `/systematic-test-design` | 体系的テスト設計（ユニットテスト＋PBT統合） |

---

## 参照

- `references/model-templates.md`: モデル化テンプレート
- `references/coverage-criteria.md`: カバレッジ基準詳細
- `references/audit-checklist.md`: 監査チェックリスト
- `references/eld-integration.md`: ELD統合ガイド
