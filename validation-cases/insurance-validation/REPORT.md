# 保险承保与理赔 技能体系验证 — 最终报告

> 案例：**保险承保与理赔**（无规范参考领域）。
> 方法论：**盲跑（blind run）**，完整执行 8 个 Skill 的流水线；因领域无成熟开源 DDD 参考实现，评分采用**专家评审制**（四类判据替代真值锚点，见 `scoring/rubric.md`）。回溯触发器机制已在 Cargo 案例中 5/5 验证，本案例不再重复注入测试（见 `backtrack-test/README.md`）。
> 本报告与全部中间工件均以中文为主。

## 1. 执行摘要

| 项目 | 数值 |
| :--- | :--- |
| 综合加权得分 | **90.9 %**（专家评审制；与 Cargo 的 85.8% 不可直接对比） |
| 最强环节 | 发现（discover）& 领域交互（domain-interactions）—— 均 4.0/4 |
| 最弱环节 | 聚合与模型评审 —— 均 3.5/4（已知改进点的合理扣分） |
| 回溯触发器 | 未重复注入（Cargo 案例已 5/5 验证） |
| 盲跑覆盖 | 简报角色/流程/异常/约束全覆盖，0 项结构性缺失 |
| 模型就绪判定 | 08 自评 Ready（含 2 项实施首迭代补齐项） |

8 个 Skill 的流水线将 600 余字的模糊业务简报收敛为 7 上下文 / 7 聚合 / 27 事件的完整领域模型：报案条款快照（批改并行仲裁）、调查挂起互斥、报价非承诺、累计赔付上限等关键业务规则全部以显式不变量或 ADR 固化，跨 Skill 工件衔接无断裂。

## 2. 验证范围

### 2.1 输入（盲）

- [00-fuzzy-prompt.md](./00-fuzzy-prompt.md) —— 中文业务简报（保险承保与理赔数字化），约 600 字；剔除所有 DDD 术语与专有类名；保留真实世界异常（巨灾、重复/虚假报案、材料迟到、批改冲突、欺诈调查）。

### 2.2 流水线产出（盲）

| 文件 | Skill | 阶段 |
| :--- | :--- | :--- |
| [01-ddd-scope.out.md](./01-ddd-scope.out.md) | ddd-scope | I 发现 |
| [02-ddd-discover.out.md](./02-ddd-discover.out.md) | ddd-discover | I 发现 |
| [03-ddd-subdomains.out.md](./03-ddd-subdomains.out.md) | ddd-subdomains | II 战略 |
| [04-ddd-contexts.out.md](./04-ddd-contexts.out.md) | ddd-contexts | II 战略 |
| [05-ddd-context-map.out.md](./05-ddd-context-map.out.md) | ddd-context-map | II 战略 |
| [06-ddd-aggregates.out.md](./06-ddd-aggregates.out.md) | ddd-aggregates | III 战术 |
| [07-ddd-domain-interactions.out.md](./07-ddd-domain-interactions.out.md) | ddd-domain-interactions | III 战术 |
| [08-ddd-model-review.out.md](./08-ddd-model-review.out.md) | ddd-model-review | IV 验证 |

### 2.3 真值（Ground Truth）

**不适用** —— 本案例为无规范参考案例，无真值来源；评分采用专家评审制（四类判据：业务完整性 / DDD 原则合规 / 内部一致性 / 正向越位识别）。

### 2.4 评分

| 文件 | 内容 |
| :--- | :--- |
| [scoring/rubric.md](./scoring/rubric.md) | 权重、0–4 评分标准、四类判据、保守原则 |
| [scoring/scorecard.md](./scoring/scorecard.md) | 各 Skill 评分 + 证据引用 + 加权总分 |

## 3. 评分总览

| Skill | 权重 | 得分 | 加权得分 | 命中亮点 | 扣分项 |
| :--- | :---: | :---: | :---: | :--- | :--- |
| ddd-scope | 1.0 | 3.5 | 3.50 | 17 条术语种子、四类风险全覆盖 | 歧义未决依赖业务方（保守） |
| ddd-discover | 1.5 | 4.0 | 6.00 | 16 主路径 + 11 异常分支；报案聚合、巨灾高峰 | — |
| ddd-subdomains | 1.0 | 3.5 | 3.50 | Core 判定明确（2/10 ≤ 1/3） | 未决赔付视图权重 |
| ddd-contexts | 1.5 | 3.5 | 5.25 | 5 条 ADR；条款快照 / 挂起互斥 | 上下文粒度偏碎 |
| ddd-context-map | 1.5 | 3.5 | 5.25 | 9 失败模式；契约所有权 | Conformist 命名争议 |
| ddd-aggregates | 2.0 | 3.5 | 7.00 | 10 不变量；外部引用再审视；2 个 Specification | Claim 职责面过大 |
| ddd-domain-interactions | 1.5 | 4.0 | 6.00 | 27 事件全链条；幂等键完整 | — |
| ddd-model-review | 1.0 | 3.5 | 3.50 | 自评诚实（巨灾状态自查） | 已知问题放行即 Ready |
| **合计** | 11.0 | — | **40.00 / 44** | **90.9 %** | |

> 完整判据命中明细与证据引用见 `scoring/scorecard.md`。

## 4. 回溯触发测试结果

**未重复执行**。`ddd-model-review` 的 5 条回溯触发条件已在 Cargo 案例中通过 5/5 缺陷注入验证（F1–F5，见 `../cargo-validation/backtrack-test/injection-report.md`）。本案例聚焦"无规范参考时技能体系的真实表现"，机制本身不随领域变化，故不重复注入。说明见 `backtrack-test/README.md`。

## 5. 关键发现

### 5.1 技能体系的优势（在无参考领域）

1. **发现阶段稳健**：无 DDD 术语泄漏的简报被收敛为 16 步主路径 + 11 条异常分支，简报中"异常情形"五类（巨灾、重复/虚假、迟到、批改冲突、欺诈）全部事件化，无遗漏。
2. **关键业务规则被正确建模**：报案条款快照（批改并行仲裁）、调查挂起禁支付（状态机互斥）、累计赔付上限、报价非承诺——均以显式不变量或 ADR 固化，且边界归位准确（快照归 Claim、条款版本归 Policy）。
3. **跨 Skill 工件衔接零断裂**：discover 提出的 16 个主路径事件在 interactions 中全部正式定义；上下文/聚合/事件三方引用一致。
4. **已采纳改进生效**：外部引用再审视（4 处引用全部给出生命周期结论）、Specification 模式（2 处显式抽取）、行业对标（本案例无参考，正确未启用）——三条 Cargo 反哺补丁在无参考场景下行为符合预期。

### 5.2 暴露出的弱点

| 弱点 | 位置 | 根因 | 建议修复 |
| :--- | :--- | :--- | :--- |
| **Claim 聚合职责面过大**（报案/查勘/调查/追偿/结案 4 实体 + 8 命令） | 06-aggregates | 简报将理赔描述为单一段落，事件风暴未在理赔内部再分层 | 在 `ddd-aggregates` SKILL 中增加"聚合规模论证"检查：单个聚合 > 5 实体或 > 8 命令时，必须给出拆分分析（与既有"单聚合 ≤ 5 实体"检查合并） |
| **"先收后补"高峰模式无显式状态** | 06 vs 08 | 巨灾高峰在 discover 中被标注为性能热点，但未被固化为聚合状态 | 在 `ddd-discover` SKILL 中增加：性能热点若涉及状态语义（先收后补、挂起等待），需同步产出候选状态清单 |
| **无参考时评审口径依赖专家主观性** | scoring | 无真值时业务完整性判据无法外部验证 | 方法总纲补充：无参考案例的评分应至少 2 名评审交叉评分，或业务方抽验 3 条关键不变量 |

### 5.3 正向越位（值得表扬）

- **报案聚合（重复报案合并）**：简报仅提"同一损失被多次报案"，盲跑设计出去重指纹（标的 + 出险时间窗 + 描述）与"保留主报案号"的合并机制，且沉淀为显式不变量 I-8。
- **审批升级链（E10）**：简报仅提"多级审批"，盲跑补齐了"大额需更高权限"的升级路径与挂起互斥的联动。
- **支付幂等键规则不可变**：07 将 PaymentInstruction 的幂等键规则声明为"不可变更"，是防重复支付底线的合理工程强化。
- **报价有效期**：简报未提及，盲跑在 ACL-1 中补"有效期由内部生成"，规避报价无限期承诺。

## 6. 对技能系统的建议

### 6.1 建议的 SKILL.md 更新

**`skills/ddd-aggregates/SKILL.md`** —— 校验清单补充：

> 若单个聚合实体数 > 5 或命令数 > 8，须输出拆分分析（聚合边界是否过宽、是否可拆分为受理/处理两个聚合），不允许仅以"聚合大但一致性强"带过。

**`skills/ddd-discover/SKILL.md`** —— 流程第 4 步（标注热点）补充：

> 性能热点若蕴含状态语义（如"先收后补"的受理中状态、"等待补齐"的挂起状态），需同步产出**候选状态清单**，供战术阶段直接消费。

### 6.2 方法总纲更新（`validation-cases/README.md`）

- 在 §4 评分中补充**无参考案例的评审要求**：至少 2 名评审交叉评分或业务方抽验关键不变量，缓解无真值时的主观性。
- 在 §6 案例表中登记本案例。

## 7. 工件索引

```text
validation-cases/insurance-validation/
├── 00-fuzzy-prompt.md                     盲输入的业务简报（约 600 字）
├── 01-ddd-scope.out.md                    盲跑 阶段 I
├── 02-ddd-discover.out.md                 盲跑 阶段 I
├── 03-ddd-subdomains.out.md               盲跑 阶段 II
├── 04-ddd-contexts.out.md                 盲跑 阶段 II
├── 05-ddd-context-map.out.md              盲跑 阶段 II
├── 06-ddd-aggregates.out.md               盲跑 阶段 III
├── 07-ddd-domain-interactions.out.md      盲跑 阶段 III
├── 08-ddd-model-review.out.md             盲跑 阶段 IV（自评）
├── scoring/
│   ├── rubric.md                          权重、0–4 标准、四类判据
│   └── scorecard.md                       各 Skill 评分、证据、总分 90.9%
├── backtrack-test/
│   └── README.md                          未重复注入说明（Cargo 已 5/5 验证）
└── REPORT.md                              （本文件）
```

## 8. 结论

在**无规范参考**的领域（保险承保与理赔）中，8 个 Skill 的 DDD 建模流水线将模糊业务简报收敛为一份专家评审 **90.9 %** 的领域模型：简报要素全覆盖、关键业务规则正确建模、跨 Skill 工件衔接零断裂。这回应了 `validation-cases/README.md` §7 已知局限中"无规范参考案例缺失"的缺口——**当领域不存在规范参考实现时，本技能体系具备上线可用性**。

本案例得分与 Cargo 案例（85.8%，有真值对标）**不可直接对比**：评分制不同（专家评审 vs 真值锚点）。若需可比性，后续可对同一领域采用"行业标准弱真值"方案（如 ACORD 保险标准）复评。
