# 09 — ddd-openspec-bridge 产出（Blind Run）

> 输入：`01-ddd-scope.out.md` + `03-ddd-subdomains.out.md` + `04-ddd-contexts.out.md` + `05-ddd-context-map.out.md` + `06-ddd-aggregates.out.md` + `07-ddd-domain-interactions.out.md`（+ 08 自评作可选输入）。
> 执行标准：`docs/ddd-openspec-mapping.md` 标准定义。
> 本文件为 `ddd-openspec-bridge` 在 blind run 下的模拟执行产出，将保险承保与理赔模型映射为 OpenSpec 变更集。

---

## 变更集：`digital-claims-pipeline`

> 覆盖范围：核保决策（Core）→ 定损赔付（Core）→ 支付执行（Generic 引用）。投保报价与保单管理为配套上下文，本次变更集仅涉及其契约消费侧，不重写其规范。

## 1. 全局配置 `openspec/config.yaml`（声明一次，由 `ddd-contexts` 阶段维护）

```yaml
context: |
  ## 项目领域映射
  本系统遵循 DDD 设计，核心限界上下文包括：
  - 承保决策上下文 (Underwriting Context)
  - 保单管理上下文 (Policy Context)
  - 理赔上下文 (Claim Context)
  - 支付上下文 (Payment Context)
  - 客户主体上下文 (Party Context)
  - 投保报价上下文 (Quotation Context)
  - 监管视图上下文 (Regulatory Context)

  ## 技术栈与架构约束
  - 架构风格：事件驱动 + 分层架构（Domain / Application / Infrastructure）
  - 规则：所有聚合变更必须通过领域事件驱动最终一致性；一次事务仅修改一个聚合
  - 集成：外部费率与资金系统经 ACL 接入；跨上下文事件采用 Outbox 模式
```

## 2. 变更集元数据 `changes/digital-claims-pipeline/.openspec.yaml`

```yaml
name: digital-claims-pipeline
created: 2026-08-05
status: proposed
capabilities:
  - underwriting-context/underwriting-decision
  - claim-context/loss-assessment
  - payment-context/payment-execution
```

## 3. `proposal.md`

### Why

承保与理赔环节信息断裂：核保人看不到完整历史赔付表现，理赔员拿不到准确条款信息，管理层无法实时掌握未决赔付规模，导致决策慢、差错多、监管报送被动。

### What Changes

- 在承保决策上下文新增能力：核保决策（UnderwritingDecision）——接受 / 加费 / 限责 / 拒保判定，含分保评估。**Core 子域，全量 Scenario 化**。
- 在理赔上下文新增能力：定损赔付（LossAssessment）——定损、调查挂起、审批、结案。**Core 子域，全量 Scenario 化**。
- 在支付上下文新增能力：支付执行（PaymentExecution）——指令受理、幂等执行、回执。**Generic 子域**，引用既有支付契约。
- 引入领域事件：`UnderwritingDecisionMade`、`PaymentRequested`、`PaymentExecuted`、`ClaimClosed`（沿用 07 事件目录定义）。
- 通用语言：核保案、承保决策、报案、定损、调查挂起、支付指令、支付回执（均在 `ddd-contexts` 词汇表内）。

### Impact

- **Capabilities**: `underwriting-context/underwriting-decision`、`claim-context/loss-assessment`、`payment-context/payment-execution`
- **聚合变更**：
  - UnderwritingCase 聚合：新增决策与分保评估（无破坏性变更）
  - Claim 聚合：新增调查挂起状态机与累计已付口径（I-5 / I-6）
  - PaymentInstruction 聚合：新增指令受理与回执（幂等键规则不可变）

### Goals

- 核保决策 → 出单转化率可观测（决策记录完整率 100%）
- 定损结论计算准确（免赔额 / 除外 / 累计上限自动校验，人工改金额被拒绝）
- 调查挂起期间支付拒绝率 100%（状态机互斥，非人工纪律）
- 支付成功率 ≥ 99.9%，重复支付 0 笔（幂等键保证）

## 4. `design.md`

### 4.1 分层架构映射

| 层             | 内容                                                                                 | 来源                                         |
| :------------- | :----------------------------------------------------------------------------------- | :------------------------------------------- |
| Domain         | 聚合（UnderwritingCase / Claim / PaymentInstruction）、不变量、领域事件              | `ddd-aggregates` + `ddd-domain-interactions` |
| Application    | 领域服务编排（UnderwritingService / LossAssessmentService / PaymentGateway）、审批流 | `ddd-domain-interactions`                    |
| Infrastructure | 仓储实现、事件总线（Outbox）、ACL 适配器（费率 / 资金系统）                          | `ddd-context-map`                            |

### 4.2 数据模型映射

| 聚合               | 持久化边界                            | 关键状态                                                 |
| :----------------- | :------------------------------------ | :------------------------------------------------------- |
| UnderwritingCase   | caseId 主键；决策事件溯源             | 核保中 → 已决策                                          |
| Claim              | claimId 主键；定损记录追加式          | 已报案 → 定损中 → 挂起（调查）/ 已审批 → 已支付 → 已结案 |
| PaymentInstruction | instructionId 主键 + claimId 幂等索引 | 待执行 → 已执行 / 失败重试                               |

### 4.3 核心数据流（事件链）

```text
MakeUnderwritingDecision
  → UnderwritingCase 聚合：判定（接受/加费/限责/拒保），落库
  → 发布 UnderwritingDecisionMade(caseId, applicationId, decision, premiumAdjustment)

AssessLoss
  → Claim 聚合：执行 LossPayableSpec（免赔/除外/累计/挂起互斥），定损结论落库
  → ApprovePayment → 发布 PaymentRequested(instructionId, claimId, amount)
  → Payment 聚合：创建 PaymentInstruction（待执行）→ 发布 PaymentInstructionAccepted

PaymentExecuted（资金系统回执，经 ACL）
  → PaymentInstruction 聚合：幂等收敛，回执落库 → 发布 PaymentExecuted(instructionId, claimId, amount)
  → Claim 消费：累计已付更新（I-5 校验）→ 满足结案条件时 CloseClaim → 发布 ClaimClosed
```

### 4.4 事件驱动范式（对照映射指南附录 A）

- **发布**：跨聚合一致性与跨上下文集成均走事件；`PaymentRequested` 在 Claim 事务内写 Outbox，事务提交后发布。
- **消费**：`PaymentExecuted` 消费端以 `paymentId + claimId` 为幂等键，持久化去重；失败进重试队列，不得回滚上游聚合。
- **补偿**：支付失败（可重试）自动重试 ≤3 次；不可重试转人工通道，结案前必须支付成功。
- **翻译**：外部资金系统回执经 ACL-3 翻译为内部 `PaymentExecuted`；费率经 ACL-1 翻译为 `QuoteTerms`。

### 4.5 接口协议（本变更集涉及）

| 接口 / 契约              | 方向                  | 协议           | 幂等键                   |
| :----------------------- | :-------------------- | :------------- | :----------------------- |
| UnderwritingDecisionMade | Underwriting → Policy | 事件（Outbox） | caseId + decisionVersion |
| PaymentRequested         | Claim → Payment       | 事件（Outbox） | instructionId            |
| PaymentExecuted          | Payment → Claim       | 事件（Outbox） | paymentId + claimId      |
| ClaimClosed              | Claim → Regulatory    | 事件（Outbox） | claimId                  |

## 5. `specs/` 目录（按限界上下文组织）

### 5.1 `specs/underwriting-context/underwriting-decision/spec.md`

#### Requirement: 核保决策能力

系统应支持核保人对投保申请做出接受、加费、限责或拒保的决策，决策一经生效且已出单则不可覆盖；一次申请最多一条生效决策。

##### Scenario: 接受申请并触发出单

- **Given** 一份已报价的投保申请 A 与核保案 C
- **When** 核保人对 C 做出接受决策
- **Then** 创建承保决策 D（decision = 接受）
- **And** 发布 UnderwritingDecisionMade 事件，携带 caseId 与 applicationId
- **And** 该决策 D 成为生效决策

##### Scenario: 已出单后拒绝覆盖决策

- **Given** 决策 D 已生效且已基于 D 出单
- **When** 核保人再次对同一申请提交决策 D'
- **Then** 拒绝提交，返回决策不可覆盖错误
- **And** 不发布任何事件

##### Scenario: 高风险标的触发分保评估

- **Given** 投保申请 A 的标的超过自留额度
- **When** 核保人启动核保
- **Then** 记录分保需求 R（需分保比例）
- **And** 分保结果并入决策依据后完成决策

> 对应 `ddd-aggregates` 不变量 I-3；未渗入数据库 / HTTP / ORM 细节。

### 5.2 `specs/claim-context/loss-assessment/spec.md`

#### Requirement: 定损赔付能力

系统应依据查勘结论与报案时条款快照计算应付金额（免赔额、除外责任、累计上限自动校验），支持调查挂起互斥与多级审批，赔付金额不可手工修改。

##### Scenario: 正常定损并按公式赔付

- **Given** 报案 CL 已关联保单并持有条款快照 S（免赔额 2000）
- **When** 查勘完成，定损金额为 12000
- **Then** 计算应付金额 = 12000 - 2000 = 10000
- **And** 创建定损结论 L（金额 10000，不可修改）
- **And** 发布 LossAssessed 事件

##### Scenario: 调查挂起期间拒绝支付审批

- **Given** 报案 CL 处于调查挂起状态
- **When** 审批人对 CL 发起支付审批
- **Then** 拒绝审批，返回挂起原因
- **And** 不创建支付指令

##### Scenario: 累计赔付超出保额时拒绝新增赔付

- **Given** 报案 CL 的累计已付 90000，保额 100000
- **When** 新定损结论应付金额为 20000
- **Then** 拒绝该定损结论（10000 + 20000 > 100000 中按责任上限约束）
- **And** 提示超额原因

##### Scenario: 材料迟到时进入待补全状态

- **Given** 报案 CL 缺少查勘材料
- **When** 理赔员标记材料缺失
- **Then** 报案进入待补全状态
- **And** 发布 ClaimPendingInformation 事件

##### Scenario: 同一损失重复报案合并

- **Given** 报案 CL-1 已存在且未结案
- **When** 同一标的同一出险时间窗收到重复报案 CL-2
- **Then** CL-2 并入 CL-1，返回主报案号
- **And** 发布 DuplicateClaimMerged 事件

> 对应 `ddd-aggregates` 不变量 I-5 / I-6 / I-8 / I-9；共 5 个 Scenario，满足粒度上限且不跨聚合根。

### 5.3 `specs/payment-context/payment-execution/spec.md`

#### Requirement: 支付执行能力

系统应受理理赔的支付指令，以幂等键保证不重复支付，执行结果以回执形式回传理赔上下文。

##### Scenario: 指令受理并成功执行

- **Given** 理赔 CL 已审批通过，金额 10000
- **When** 理赔发起支付指令 P（instructionId 唯一）
- **Then** 创建待执行的支付指令 P
- **And** 发布 PaymentInstructionAccepted 事件

##### Scenario: 重复指令幂等收敛

- **Given** 支付指令 P 已执行成功
- **When** 相同 instructionId 的指令再次到达
- **Then** 不重复支付，返回既有回执
- **And** 发布 PaymentExecuted 事件（同一次回执）

> Generic 子域，按映射指南可引用既有支付契约；幂等键规则不可变。

## 6. `tasks.md`（节选）

| 任务                | 描述                                                                        | 关联 Spec                                                                               | 验收标准                       |
| :------------------ | :-------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------- | :----------------------------- |
| T1 领域模型落地     | 实现 UnderwritingCase / Claim / PaymentInstruction 聚合、不变量校验、状态机 | `underwriting-decision/spec.md`、`loss-assessment/spec.md`、`payment-execution/spec.md` | 对应 Scenario 全部通过         |
| T2 仓储接口实现     | 按 06 仓储草案实现（含 `findByPolicyAndLossWindow` 报案合并预检）           | `loss-assessment/spec.md`（重复报案 Scenario）                                          | 重复报案合并返回主报案号       |
| T3 领域服务与工厂   | UnderwritingService / LossAssessmentService / PaymentGateway；对应工厂校验  | 全部三个 spec                                                                           | 定损公式与挂起互斥通过场景测试 |
| T4 事件发布与消费   | Outbox 发布、`PaymentExecuted` 幂等消费、重试与死信                         | `loss-assessment/spec.md`（累计上限）、`payment-execution/spec.md`（幂等）              | 幂等消费无重复累计             |
| T5 应用服务与审批流 | 审批链配置化（大额升级）                                                    | `loss-assessment/spec.md`                                                               | 升级审批场景通过               |
| T6 ACL 适配         | 费率 ACL-1、资金系统 ACL-3 翻译与降级                                       | design.md §4.4                                                                          | 超时降级与隔离区行为通过       |

---

## 校验自检（对照 SKILL.md 校验清单）

| 校验项                                                                     | 结果 | 证据                                                                                                                 |
| :------------------------------------------------------------------------- | :--: | :------------------------------------------------------------------------------------------------------------------- |
| OpenSpec 目录结构规范；`specs/` 按限界上下文分目录，无扁平 `domain-model/` |  ✅  | §5 三个 spec 按 `underwriting-context/`、`claim-context/`、`payment-context/` 组织                                   |
| Requirement 粒度达标（≤5 Scenario，未跨聚合根）                            |  ✅  | loss-assessment 恰 5 个 Scenario；全部单聚合根                                                                       |
| Scenario 业务规则优先（无 DB / HTTP / ORM / 缓存细节）                     |  ✅  | 全部 Scenario 仅含业务规则与事件副作用                                                                               |
| P0 不变量均已转化为 Scenario                                               |  ✅  | I-3（决策不可覆盖）、I-5（累计上限）、I-6（挂起禁支付）、I-8（重复报案合并）、I-9（金额不可手工改）均有对应 Scenario |
| 术语一致性（均在 04 词汇表内）                                             |  ✅  | 核保案 / 承保决策 / 报案 / 定损 / 调查挂起 / 支付指令 / 支付回执 均见 04 §词汇表                                     |
| 事件驱动范式落地（Outbox / 幂等键 / 一事务一聚合）                         |  ✅  | design.md §4.4；PaymentExecuted 幂等键 (paymentId, claimId)                                                          |
| 小步快跑（变更集规模可控）                                                 |  ✅  | 3 个能力，聚焦核心闭环，未滑向微瀑布                                                                                 |
| tasks 可执行且有 Spec 引用                                                 |  ✅  | §6 六个任务均关联 Spec 与验收标准                                                                                    |
| 中英文排版规范                                                             |  ✅  | 中英文间空格、专有名词反引号                                                                                         |

## 回溯触发判定

- 未触发任何回溯：Scenario 撰写中未发现领域逻辑歧义；无无法表达的集成模式；无技术细节渗入；无超粒度 Requirement；术语全部在词汇表内。
- **本 Skill 的回溯链路（→ aggregates / domain-interactions / context-map / contexts）在本案例中为"零触发"**——与 08 自评一致，模型质量门禁通过后阶段 V 平滑衔接。
