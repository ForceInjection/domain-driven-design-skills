# DDD to OpenSpec 映射指南：从领域模型到工程规范

> 🌐 English version: [English](ddd-openspec-mapping.en.md)

本指南定义了领域驱动设计（DDD）产出物向 OpenSpec 规范化工作流转化的标准映射路径。通过将 DDD 的领域洞察力与 OpenSpec 的结构化执行力相结合，建立一套从模型到代码的高可靠衔接体系。

---

## 1. 战略对齐：用“领域”组织“规范”

在大型系统设计中，战略层面的对齐是确保架构整洁的关键。通过将 DDD 的空间划分方法论引入 OpenSpec 的目录结构，可以实现设计与规格的天然对应。

### 1.1 限界上下文与领域目录的映射

DDD 的“限界上下文”是划分功能边界的核心工具，每个边界内部拥有自洽的领域模型和通用语言。在 OpenSpec 中，这对应为 `specs/` 目录下的子领域目录。这种对齐方式确保了每一个 DDD 识别出的业务边界在工程规格中都有明确的归属，避免了领域知识的割裂。

### 1.2 配置文件中的全景视图

通过在 `openspec/config.yaml` 中声明这种映射关系，可以为 AI Agent 提供全局的架构上下文，使其在处理具体变更时能够理解所属的业务边界。

```yaml
# openspec/config.yaml 示例：领域-限界上下文映射
context: |
  ## 项目领域映射
  本系统遵循 DDD 设计，核心限界上下文包括：
  - 用户管理上下文 (User Context)
  - 订单管理上下文 (Order Context)
  - 支付上下文 (Payment Context)

  ## 技术栈与架构约束
  - 架构风格：六边形架构 (Hexagonal)
  - 后端：Java Spring Boot + MyBatis
  - 规则：所有聚合变更必须通过领域事件驱动最终一致性
```

---

## 2. 战术落地：执行 DDD 战术设计

战术设计决定了代码实现的质量。OpenSpec 提供了一套结构化的表达方式，将 DDD 的构造块转化为可验证、可执行的任务序列，并通过 **Delta 机制** 支持增量演进。

### 2.1 构造块与 OpenSpec 结构的映射

我们将 DDD 的产出物映射为 OpenSpec 的核心组件，从而驱动 AI 进行精确的实现。

| OpenSpec 规范结构       | 对应的 DDD 产出物                                    | 描述与说明                                                |
| :---------------------- | :--------------------------------------------------- | :-------------------------------------------------------- |
| **领域（Domain）**      | **限界上下文（Bounded Context）**                    | 一个领域目录对应一个限界上下文。                          |
| **需求（Requirement）** | **领域服务（Domain Service）** / **命令（Command）** | 描述一个核心业务功能或操作。                              |
| **场景（Scenario）**    | **聚合（Aggregate）行为**                            | 使用 **Given/When/Then (Gherkin)** 格式精确描述聚合行为。 |
| **技术设计（Design）**  | **应用服务（Application Service）**                  | 协调多个领域服务，管理事务与安全。                        |
| **实施任务（Tasks）**   | **战术设计待办列表**                                 | 将实体、值对象、仓储接口等具体实现任务化。                |

> **防呆约定 · Requirement 粒度**：每个 Requirement 应聚焦到**一个可独立验证的业务能力**（通常对应一个命令或一条领域服务职责）。当一个 Requirement 需要挂载 5 个以上 Scenario，或覆盖多个聚合根时，应拆分为多个 Requirement，避免 AI 实施时失焦。

### 2.2 工作流驱动的生命周期

OpenSpec 的工作流与 DDD 的迭代建模高度契合，特别强调 **存量优先 (Brownfield-first)** 的重构能力：

- **提案（Propose） → 领域建模**：使用 `/opsx:propose` 快速初始化变更，沉淀领域建模结论。
- **实施（Apply） → 规范驱动开发**：利用 AI 依据规范（Requirement + Scenario）进行代码实现与自动化验证（Test to Spec）。
- **归档（Archive） → 知识合并**：通过 `openspec archive` 将 Delta Spec 合并至主规范，确保领域知识的单一事实来源（Source of Truth）。

> **避免微瀑布**：DDD 强调持续迭代演进，OpenSpec 又天然具备“先规范后实施”的倾向，两者叠加时容易滑向微型瀑布。建议**小步快跑**——在单个变更集内保持规范片段与代码实现尽早合流，不要等领域模型“完美”再进入 Apply 阶段；每一轮 Archive 都视为模型的一次阶段性固化，而非最终答案。

---

## 3. 核心机制：增强 AI 协同确定性

OpenSpec 不仅仅是文档，它通过一套动态指令体系和校验机制，显著提升了 DDD 模型落地的确定性。

### 3.1 AI 动态指令体系 (OPSX)

OpenSpec 1.0+ 引入的 OPSX 工作流实现了**动作而非阶段**的协作。AI 不再被动接收静态指令，而是主动查询 CLI 了解当前项目状态（如当前的限界上下文边界 and 已有的聚合定义），从而做出更符合领域约束的决策。

### 3.2 结构化校验与自动化验证

OpenSpec 内部使用结构化 Schema 对 Spec 文档进行校验。这使得“规范即测试”成为可能：

- **Schema 校验**：确保 Requirement 和 Scenario 格式正确，防止领域逻辑表达不规范。
- **自动化验证闭环**：AI 基于 Spec 生成集成测试（Scenario 映射），验证代码实现是否真正符合 DDD 的不变量约束。

---

## 4. 最佳实践建议

为了实现 DDD 与 OpenSpec 的有效结合，建议将“通用语言”贯穿于整个工作流，并充分利用其增量管理特性。

### 4.1 通用语言的贯穿执行

在编写 `proposal.md`、`design.md` 及 `spec.md` 时，必须严格使用团队形成的通用语言。OpenSpec 的 `config.yaml` 确保了这些术语在每次 AI 规划请求中都能作为“上下文锚点”被精准引用。

### 4.2 场景驱动的 BDD 风格验证

利用 OpenSpec 场景天然支持 Given/When/Then 的特性，为聚合设计建立严密的行为基准。每个 P0 级的聚合不变量都应有对应的 Scenario，作为 AI 实施和自动化测试的唯一标准。

> **业务规则优先原则**：Scenario 只描述**业务规则与不变量**，不得渗入技术细节（如数据库操作、HTTP 接口、ORM 调用、缓存策略）。技术细节归入 `design.md` 或 `tasks.md`。这一约束对人与 AI 同等重要：让 Scenario 保持领域纯洁性，是 AI 正确生成领域层代码和测试的前提。

### 4.3 充分利用 Delta 与变更管理

OpenSpec 允许团队在 `changes/` 目录下并行开发不同的领域特性。通过 Delta 机制，团队可以只关注当前变更受影响的能力（Capability），避免在大型 DDD 项目中因文档冗余而丢失重点。

---

## 5. 最小可行示例：以“用户注册”为例

为帮助团队快速上手，本节给出一个端到端的微型示例，展示通用语言如何从 `proposal.md` 贯穿到 `spec.md`。假设限界上下文为 **User Context**，需要新增“邮箱注册”能力。

### 5.1 `proposal.md` 片段

```markdown
## Why

当前系统缺少独立的用户注册入口，导致新用户无法自主创建账号。

## What Changes

- 在 User Context 下新增能力：邮箱注册（EmailRegistration）
- 引入领域事件：UserRegistered
- 通用语言：注册者（Registrant）、邮箱（Email）、激活链接（ActivationLink）

## Impact

- Capabilities: user-context/email-registration
- 聚合变更：新增 User 聚合根及其不变量（邮箱唯一性、激活态机）

## Goals

- 注册提交成功率 ≥ 99%（排除因邮箱已占用的业务拒绝）
- 注册 → 激活 转化率 ≥ 80%
- 端到端注册响应时间 P95 ≤ 500 ms
```

### 5.2 `specs/user-context/email-registration/spec.md` 片段

```markdown
## Requirement: 邮箱注册能力

系统应支持注册者通过邮箱创建账号，并在激活前保持 Pending 状态。

### Scenario: 使用未占用的邮箱成功注册

- **Given** 系统中不存在邮箱为 "alice@example.com" 的用户
- **When** 注册者提交邮箱 "alice@example.com" 与合法密码
- **Then** 创建一个状态为 Pending 的 User 聚合
- **And** 发布 UserRegistered 事件，携带 UserId 与 Email

### Scenario: 邮箱已被占用时拒绝注册

- **Given** 系统中已存在邮箱为 "alice@example.com" 的 User
- **When** 另一注册者提交相同邮箱
- **Then** 拒绝注册，返回 EmailAlreadyRegistered 错误
- **And** 不发布任何领域事件
```

> 说明：Scenario 聚焦业务规则（邮箱唯一性、初始态为 Pending、注册成功必发事件），未涉及具体数据库、HTTP 状态码、ORM 实现——这些归入 `design.md` 的技术设计与 `tasks.md` 的任务拆解。

---

## 6. 总结

OpenSpec 与 DDD 的结合，是“道”与“术”的协同。DDD 提供了分析复杂业务领域的战略和战术思维，为软件开发指明了方向；而 OpenSpec 则通过“存量优先”、“规范驱动” and “AI 动态指令体系”，将这些领域设计高效、可验证地转化为工程成果。

---

## 附录 A：事件驱动最终一致性的落地范式

`config.yaml` 中声明的“所有聚合变更必须通过领域事件驱动最终一致性”这条规则，需要配套具体范式才能让 AI 准确生成实现。下面给出两类常见场景。

### A.1 何时发布事件（Publish）

- **跨聚合一致性**：当一次用户命令需要影响多个聚合时（例如下单导致库存扣减、账户余额变化），只在**命令直接作用的聚合**内同步更新状态，并发布领域事件，由事件处理器异步更新其他聚合。
- **跨上下文集成**：当外部上下文（如通知、积分、审计）需要感知本上下文的状态变化时，发布领域事件作为契约出口，避免下游系统直接读取本上下文的聚合状态。
- **触发时机**：事件应在**聚合状态落库后**、事务提交时发布（推荐使用 Outbox 模式），保证事件与状态变更的一致性。

### A.2 如何消费事件（Consume）

- **幂等消费**：事件处理器必须携带幂等键（通常为 `AggregateId + Version` 或 `EventId`），防止重复投递导致聚合状态漂移。
- **失败策略**：消费失败时应进入重试队列或死信队列，不得回滚上游聚合；跨聚合的补偿逻辑通过发布补偿事件（如 `OrderCancelled`）完成。
- **上下文翻译**：跨上下文消费事件时，需经过防腐层（ACL）将上游语义翻译为本上下文的通用语言，避免上游模型泄漏。

### A.3 下单场景的事件链示例

```text
PlaceOrderCommand
  → Order 聚合：创建 Order（状态 = Pending），落库
  → 发布 OrderPlaced(OrderId, Items, TotalAmount)

OrderPlaced
  → Inventory 聚合：扣减库存 → 发布 InventoryReserved 或 InventoryInsufficient
  → Payment 聚合：创建待支付单 → 发布 PaymentRequested

InventoryInsufficient
  → Order 聚合：将 Order 置为 Cancelled → 发布 OrderCancelled（补偿）
```

> 该链路中，每个聚合仅对本地状态负责，跨聚合一致性通过事件与补偿完成。AI 在实现这类流程时，应严格遵循“一次事务只修改一个聚合”的约束。
