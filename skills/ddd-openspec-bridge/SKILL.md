---
name: ddd-openspec-bridge
description: "将 DDD 战术建模工件映射为 OpenSpec 结构化规范，实现从领域建模到工程实现的平滑衔接。"
risk: safe
source: self
tags: "[ddd, implementation, openspec, sdd]"
date_added: "2026-05-11"
---

# DDD OpenSpec Bridge

## 使用时机

- 战术建模（Stage III）已完成，模型通过验证（Stage IV），准备进入开发阶段。
- 需要将领域模型转换为可供 AI Agent 或开发者执行的结构化工程规范。
- 需要建立业务模型与代码实现之间的"单一事实来源"（Source of Truth）。

## 输入要求

- **必需**：
  - 问题空间定义（来自 `ddd-scope`）
  - 子域分类与核心域声明（来自 `ddd-subdomains`）
  - 上下文目录与 ADR（来自 `ddd-contexts`）
  - 上下文映射与集成模式（来自 `ddd-context-map`）
  - 聚合目录与不变量（来自 `ddd-aggregates`）
  - 领域交互定义：领域事件、领域服务、仓储接口、工厂（来自 `ddd-domain-interactions`）
- **可选**：
  - 发现阶段事件流与边界线索（来自 `ddd-discover`）
  - 模型验证报告（来自 `ddd-model-review`）
- **执行标准**：映射逻辑必须遵循 [ddd-openspec-mapping.md](../../docs/ddd-openspec-mapping.md) 中的标准定义。

## 流程

1. **初始化 OpenSpec 变更集**：在 `openspec/changes/<change-id>/` 下创建目录，生成本次变更的 `.openspec.yaml`。注意：这与全局 `openspec/config.yaml` 不同——后者由 `ddd-contexts` 阶段一次性维护，用于声明领域-限界上下文映射与架构约束。
2. **生成 Proposal（`proposal.md`）**：
   - 将 `ddd-scope` 的问题陈述映射至 Why。
   - 将本次变更涉及的 Capabilities 写入 What Changes；按 `ddd-subdomains` 的分类组织优先级：**Core 子域**须全量 Scenario 化，**Generic 子域**可引用已有规范或外部组件。
   - 在 Impact 中列出受影响的 Capabilities 与聚合变更清单；在 Goals 中定义成功标准（SLO / 验收指标）。
3. **建立 Bounded-Context 目录**：按 `ddd-contexts` 的上下文目录，在 `specs/<bounded-context>/<capability>/spec.md` 下建立每个能力的规范文件。**禁止使用扁平的 `specs/domain-model/` 目录**——它会破坏限界上下文与领域目录的战略对齐。
4. **编写 Requirement 与 Scenario**（严格遵循 [ddd-openspec-mapping.md §2.1](../../docs/ddd-openspec-mapping.md) 的映射方向）：
   - **Requirement** ← `ddd-domain-interactions` 中的命令与领域服务；一个 Requirement 对应**一条可独立验证的业务能力**，Scenario 数 ≤ 5 且不跨聚合根。
   - **Scenario** ← `ddd-aggregates` 中的聚合行为与不变量，以 Given/When/Then 描述；P0 级不变量必须有对应 Scenario。
   - **领域事件**作为副作用写在 Scenario 的 Then/And 子句（如 “And 发布 OrderPlaced 事件”）。
   - **业务规则优先**：Scenario 只描述业务规则与不变量，不得渗入数据库、HTTP、ORM、缓存等技术细节。
5. **通用语言校验**：对照 `ddd-contexts` 的词汇表，确保 `proposal.md` 与所有 `spec.md` 中的术语均落在词汇表内；未收录术语必须先回写词汇表或改用同义词。
6. **设计技术方案（`design.md`）**：整合 `ddd-context-map` 的集成模式与 `ddd-domain-interactions` 的协作机制；描述分层架构映射、跨上下文翻译（ACL）、事件发布/消费范式（Outbox 模式、幂等键、一次事务仅修改一个聚合——见 [ddd-openspec-mapping.md 附录 A](../../docs/ddd-openspec-mapping.md)）。
7. **拆解开发任务（`tasks.md`）**：按 Spec 依赖顺序（Domain Model → Repository → Application Service → API/集成）拆解任务，每个任务关联对应的 Requirement 或 Scenario 作为验收标准。

## 输出

| 工件          | 结构要求                                                              |
| :------------ | :-------------------------------------------------------------------- |
| `proposal.md` | 包含 Why, What Changes, Impact（Capabilities / 聚合变更）, Goals。    |
| `design.md`   | 包含架构设计、数据模型映射、核心数据流、接口协议定义。                |
| `specs/` 目录 | 按能力组织的子文件夹，包含 `spec.md`（Requirement + Scenario 格式）。 |
| `tasks.md`    | 包含任务标题、任务描述、关联 Spec 路径、验收标准。                    |

## 校验清单

- [ ] OpenSpec 目录结构符合规范（config, specs, changes）；`specs/` 按限界上下文分目录，未出现扁平的 `domain-model/`。
- [ ] **Requirement 粒度达标**：每个 Requirement 对应一条可独立验证的业务能力，Scenario 数 ≤ 5 且未跨聚合根。
- [ ] **Scenario 保持业务规则优先**：未出现数据库、HTTP、ORM、缓存等技术细节；所有 `ddd-aggregates` 的 P0 不变量均已转化为 Scenario。
- [ ] **术语一致性**：`proposal.md` 与所有 `spec.md` 中的术语均可在 `ddd-contexts` 词汇表中查到；`proposal.md` 中的 Capabilities 与 `ddd-contexts` 保持一致。
- [ ] **事件驱动范式落地**：跨聚合场景在 `design.md` 中明确遵循 Outbox 模式、幂等键与“一次事务仅修改一个聚合”约束。
- [ ] **迭代节奏可控（小步快跑）**：本次变更集规模可在单次 Apply 阶段内完成规范与代码合流，未滑向微型瀑布。
- [ ] `tasks.md` 中的任务具备可执行性，且每个任务都有明确的 Requirement / Scenario 引用作为验收标准。
- [ ] 中英文排版符合项目规范（中英文间加空格，专有名词加反引号）。

## 回溯触发

- 编写 Scenario 时发现领域逻辑存在歧义或冲突 → 回溯至 `ddd-aggregates` 或 `ddd-domain-interactions`。
- 无法在 OpenSpec 结构下清晰表达某种集成模式 → 回溯至 `ddd-context-map`。
- Scenario 中无法移除技术细节（数据库 / HTTP / ORM 等）→ 违反业务规则优先原则；先在本 Skill 内重写，若语义仍无法纯化则回溯至 `ddd-aggregates` 重新界定聚合行为。
- 单个 Requirement 挂载超过 5 个 Scenario 或跨多聚合根 → 违反粒度约定，回溯至 `ddd-domain-interactions` 拆分命令与领域服务。
- 术语未收录在 `ddd-contexts` 词汇表 → 回溯至 `ddd-contexts` 补录或统一术语。

## 示例

```text
@ddd-openspec-bridge
根据已完成的"会议室预订系统"建模产出，生成 OpenSpec 变更集规范：
- 聚合：Booking, RoomSchedule
- 关键流程：预订申请、冲突检测、签到、取消
- 上下文：Booking Context, Room Catalog Context
请输出 proposal.md, design.md 以及 specs/booking-context/booking/spec.md 的核心 Requirement 与 Scenario 片段。
```

> 完整的 Requirement / Scenario 写法示范见 [ddd-openspec-mapping.md §5](../../docs/ddd-openspec-mapping.md)（以“用户注册”为例的端到端最小可行示例）。
