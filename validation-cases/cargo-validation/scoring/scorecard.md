# Scorecard — Cargo Skills Validation (Blind Run)

> 对 blind 产出 `01`~`08` vs `reference/` 真值逐 skill 打分。评分规则见 [rubric.md](./rubric.md)。

## 术语漂移对照表（不扣分，仅登记）

| Blind 术语                 | 真值术语                                | 语义是否对齐                                             |
| :------------------------- | :-------------------------------------- | :------------------------------------------------------- |
| Shipment / 订单            | Cargo                                   | ✓                                                        |
| HandlingFact               | HandlingEvent                           | ✓                                                        |
| Route（带版本）            | Itinerary                               | ✓（Route 版本化 ≈ Itinerary 整体替换的序列）             |
| RouteCandidate             | TransitPath（外部）→ Itinerary          | ✓                                                        |
| PortCode                   | UnLocode                                | ✓                                                        |
| VoyageRef                  | VoyageNumber                            | ✓                                                        |
| ShippingRequest            | RouteSpecification                      | ≈（真值是下单参数 VO；blind 独立为阶段性概念，语义更松） |
| DeliveryProgress           | Delivery                                | ✓                                                        |
| TrackingView               | Delivery + HandlingActivity（投影视角） | ✓                                                        |
| DeduplicationKey（5 字段） | HandlingEvent 身份五元组                | ✓（字段近似）                                            |

## Skill 01 — ddd-scope（权重 1.0）

| 锚点                                       | 真值 | Blind 命中 | 备注              |
| :----------------------------------------- | :--- | :--------- | :---------------- |
| 业务意图聚焦"一票货物生命周期"             | ✓    | ✓          | 问题/价值陈述精准 |
| 非目标显式（不做计费/CRM/船公司调度/仓储） | ✓    | ✓          | 完整复现          |
| 外部 Routing 依赖列为关键约束              | ✓    | ✓          | 约束表含          |
| 术语种子 ≥ 10 含歧义                       | ✓    | ✓（20 条） | 超额              |
| 风险覆盖 4 类                              | ✓    | ✓          | 10 条覆盖均衡     |

**得分：4 / 4**（优秀；额外识别了"运营规模计算"与"客户通知"）

## Skill 02 — ddd-discover（权重 1.5）

| 锚点                                  | 真值                                    | Blind 命中    | 备注                                                         |
| :------------------------------------ | :-------------------------------------- | :------------ | :----------------------------------------------------------- |
| 主路径：下单 → 指派 → 装卸循环 → 签收 | ✓（16 步）                              | ✓（14 步）    | 步数相近；语义一致                                           |
| 错卸 → 重规划 闭环                    | ✓                                       | ✓（E-C 组）   | 完整                                                         |
| 作业登记异常（重复、非法、迟到）      | 真值仅列 "InvalidHandlingEventRejected" | ✓（E-B 三种） | **超过真值**：补全迟到回放，这是真值 README 也承认的现实扩展 |
| 事件过去时命名                        | ✓                                       | ✓             | 合规                                                         |
| 命令幂等性标注                        | ✓                                       | ✓             | 每条含幂等键                                                 |
| 热点/歧义清单                         | ✓                                       | ✓             | 结构完整                                                     |

**得分：4 / 4**（优秀；E-B 迟到路径是真值没有的主动补强）

## Skill 03 — ddd-subdomains（权重 1.0）

| 锚点                                      | 真值 | Blind 命中                                     | 备注           |
| :---------------------------------------- | :--- | :--------------------------------------------- | :------------- |
| 核心域 = Shipping & Tracking              | ✓    | ✓                                              |                |
| Handling = Supporting（外部作业事实吸收） | ✓    | ✓                                              |                |
| Customer Tracking View = Supporting       | ✓    | ✓                                              |                |
| Routing = Generic（外部）                 | ✓    | ✓                                              |                |
| 非目标（Billing/CRM/Carrier）不被误纳     | ✓    | ✓                                              | 清晰           |
| 识别 Billing/Customer 缺失（加分项）      | —    | ✗（仅非目标列出，未点名"未来应建 Billing BC"） | 可加分但未拿到 |

**得分：3 / 4**（达标；未主动提出"未来 Billing/Customer 独立建模"的加分点）

## Skill 04 — ddd-contexts（权重 1.5）

| 锚点                                          | 真值                                                           | Blind 命中                  | 备注                                                                                                             |
| :-------------------------------------------- | :------------------------------------------------------------- | :-------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| 4 BC：Booking / Handling / Tracking / Routing | ✓                                                              | ✓                           | 完整                                                                                                             |
| Tracking 只读、禁判定                         | ✓                                                              | ✓（ADR-02）                 | 显式                                                                                                             |
| Booking 为核心判定权所有者                    | ✓                                                              | ✓（ADR-01）                 | 显式                                                                                                             |
| 与 Pathfinder 用 ACL                          | ✓                                                              | ✓（ADR-03）                 | 显式                                                                                                             |
| ShippingRequest vs Shipment 区分              | 真值用 RouteSpecification + Cargo，未独立 ShippingRequest 阶段 | ✓（ADR-04，blind 多拆一层） | **轻微语义漂移**：真值里方案选择前就有 Cargo；blind 把"方案未选前"独立为 ShippingRequest。更细腻，但偏离真值模型 |
| 客户通知上下文                                | —                                                              | ✗                           | 真值也未独立                                                                                                     |
| 术语表 per-BC                                 | ✓                                                              | ✓                           |                                                                                                                  |
| 反义词表                                      | ✓                                                              | ✓（5 类）                   |                                                                                                                  |

**得分：3.5 / 4**（接近优秀；ShippingRequest 的独立引入是合理改进，但与真值不完全对齐，扣 0.5）

## Skill 05 — ddd-context-map（权重 1.5）

| 锚点                                            | 真值 | Blind 命中                | 备注                                |
| :---------------------------------------------- | :--- | :------------------------ | :---------------------------------- |
| Booking ↔ Pathfinder：ACL + Customer-Supplier   | ✓    | ✓                         | 命中                                |
| Handling → Booking/Tracking：Published Language | ✓    | ✓（OHS + PL）             | 命中                                |
| 外部作业方 → Handling：Conformist + edge ACL    | ✓    | ≈（blind 称"通道适配层"） | 语义等价；命名非标                  |
| 失败模式与降级                                  | ✓    | ✓                         | 覆盖完整                            |
| 契约所有权                                      | ✓    | ✓                         | 完整                                |
| 版本策略                                        | ✓    | ✓                         | 二维度（事件 + RouteVersion）更明确 |
| 无循环依赖                                      | ✓    | ✓                         | 图示清晰                            |

**得分：4 / 4**（优秀）

## Skill 06 — ddd-aggregates（权重 2.0，最高权重）

| 锚点                                                  | 真值 | Blind 命中                   | 备注                                                                                                                                              |
| :---------------------------------------------------- | :--- | :--------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| 4 聚合根：Cargo / HandlingEvent / Voyage / Location   | ✓    | ✗ 部分                       | **Blind 给出 Shipment + HandlingFact + TrackingView + RouteCandidate + PortDirectory；缺 Voyage；Location 以 PortDirectory 形式出现但仅标"假设"** |
| HandlingEvent 独立聚合（ADR-1 性能）                  | ✓    | ✓（HandlingFact 独立）       | ✓ 理由说得通但未点"性能"                                                                                                                          |
| Delivery 为推导 VO 禁 setter                          | ✓    | ✓（I-4 显式）                | 命中                                                                                                                                              |
| I4/I5（voyage/type 联动）                             | ✓    | ✓（I-8 一体表达）            | 命中                                                                                                                                              |
| HandlingEvent 身份五元组                              | ✓    | ✓（DeduplicationKey 5 字段） | 命中                                                                                                                                              |
| RouteSpec.isSatisfiedBy(Itinerary) Specification 模式 | ✓    | ✗                            | 未识别 Specification 模式；由 factory 校验代替                                                                                                    |
| 仓储：HandlingEventRepository 无通用 CRUD             | ✓    | ≈                            | appendIfAbsent + findById + history 合格，但暴露了"findByShipment" 广查询（轻微越界）                                                             |
| Cargo 聚合禁引用 HandlingEvent 对象，只持 ID          | ✓    | ✓（I-11 显式）               | 命中                                                                                                                                              |
| RouteCandidate 被误列为聚合                           | —    | ✗                            | 自我审查（08）已标注为 P1，建议降级为 VO；扣 0.25                                                                                                 |

**漏项**：

- **缺 Voyage 聚合**：`VoyageRef` 只做引用，真值里 Voyage 是独立聚合（Schedule、CarrierMovement）。Blind 假设"外部托管"，但真值样例里 Voyage 是内部聚合。这是语义差距，不是术语差异。
- **缺 Location 独立聚合**：`PortDirectory` 仅"假设存在"，未明确聚合根/不变量。
- 未识别 Specification 模式。

**得分：2.5 / 4**（可用偏上；关键漏了 Voyage/Location 两个聚合的显式声明）

## Skill 07 — ddd-domain-interactions（权重 1.5）

| 锚点                                                               | 真值      | Blind 命中                                              | 备注                       |
| :----------------------------------------------------------------- | :-------- | :------------------------------------------------------ | :------------------------- |
| RoutingService 是领域服务接口 + 基础设施 ACL 实现分离              | ✓         | ✓（RoutingService 在 Booking 领域层；ACL 归设基础设施） | 命中                       |
| CargoInspectionService 订阅 CargoWasHandled 发 misdirected/arrived | ✓         | ✓（MisroutingDetector + CargoDelivered 事件）           | 命中，职责划分略不同但等价 |
| CargoWasHandled 是跨 BC Published Language                         | ✓         | ✓（AcceptedHandlingEvent）                              | 命中（术语差异）           |
| 幂等键 = HandlingEvent 身份五元组                                  | ✓         | ✓（HandlingFactId + DeduplicationKey）                  | 命中                       |
| HandlingEventFactory 的 Type+Voyage 联动校验                       | ✓         | ✓（HandlingFactFactory）                                | 命中                       |
| 主路径 + 错卸 + 迟到三场景                                         | ✓（前两） | ✓ 全三场景                                              | 迟到场景超过真值           |
| 订阅者与副作用                                                     | ✓         | ✓                                                       |                            |

**得分：4 / 4**（优秀）

## Skill 08 — ddd-model-review（权重 1.0）

| 锚点                                                             | 真值期望 | Blind 命中 | 备注                                                                                                            |
| :--------------------------------------------------------------- | :------- | :--------- | :-------------------------------------------------------------------------------------------------------------- |
| 自检 8 维度评分                                                  | —        | ✓          | 结构完整                                                                                                        |
| 回溯触发判定                                                     | —        | ✓          | 5 条均判定                                                                                                      |
| 识别 HandlingEvent/Activity/TransportStatus 语义重叠（关键加分） | ✓        | ✗          | **漏**：未识别此重叠（blind 的 TrackingView 把 HandlingActivity 与 TransportStatus 融在一起了，所以体感不明显） |
| 识别 Billing/Customer 缺失（加分）                               | ✓        | ≈          | 非目标已声明，但未作为"模型未来演进的已知缺口"独立提出                                                          |
| 识别 Carrier 缺失（加分）                                        | ✓        | ✗          | VoyageRef "外部托管" 实则绕过了 Carrier 建模，未主动点出                                                        |

**得分：2.5 / 4**（可用；3 个关键加分项未拿到，但内部一致性评审合格）

## 加权总分

| Skill                   | 得分 | 权重 |   加权    |
| :---------------------- | :--: | :--: | :-------: |
| ddd-scope               | 4.0  | 1.0  |    4.0    |
| ddd-discover            | 4.0  | 1.5  |    6.0    |
| ddd-subdomains          | 3.0  | 1.0  |    3.0    |
| ddd-contexts            | 3.5  | 1.5  |   5.25    |
| ddd-context-map         | 4.0  | 1.5  |    6.0    |
| ddd-aggregates          | 2.5  | 2.0  |    5.0    |
| ddd-domain-interactions | 4.0  | 1.5  |    6.0    |
| ddd-model-review        | 2.5  | 1.0  |    2.5    |
| **合计**                |  —   | 11.0 | **37.75** |

**加权综合**：37.75 / 44 = **85.8%**（B+ / 良）

## 加分与扣分项

|                            项                            |  +/-   | 说明                                                   |
| :------------------------------------------------------: | :----: | :----------------------------------------------------- |
|              B-加分 1 Billing/Customer 识别              | 未拿到 | 仅非目标声明                                           |
| B-加分 2 HandlingEvent/Activity/TransportStatus 重叠识别 | 未拿到 | 盲模型合并了这些概念，反而"没感觉到重叠"，值得引以为戒 |
|              B-加分 3 Carrier 外部建模简化               | 未拿到 | VoyageRef "外部托管" 说法模糊                          |
|        B-扣分 1 HandlingEventRepository 通用 CRUD        |   无   | blind 未犯此错                                         |
|           B-扣分 2 RoutingService 实现入领域层           |   无   | blind 明确区分                                         |
|              B-扣分 3 Routing 放进 Booking               |   无   | blind 明确外部化                                       |
|               B-扣分 4 Delivery 可 setter                |   无   | blind 显式 I-4 禁止                                    |

**最终加权**：无扣分，加分未拿 → **85.8%** 保持。

## 关键观察

### 做得好的地方

1. **Stage I / III（discover / interactions）表现最强（4.0）**：事件风暴覆盖、幂等策略、ACL 分层都精准。
2. **超出真值的补强**：迟到回放（E-B3）与 RouteVersion 版本化是真值未显式涵盖的工业级补强。
3. **非目标纪律**：Billing/CRM/Carrier/Warehousing 被严格排除，未发生范围蔓延。

### 待改进的地方

1. **聚合识别偏保守（最严重）**：Voyage 和 Location 未独立为聚合，把它们降为 "外部引用 / 假设字典"。这是 blind run 的真实弱点——在没有看到 Cargo 源码的情况下，难以推断出 "Voyage 是内部管理的航程"。
2. **Specification 模式缺失**：RouteSpec.isSatisfiedBy 这一经典 DDD 模式未被识别。
3. **model-review 加分项全漏**：HandlingEvent/Activity/TransportStatus 重叠、Billing/Customer 演进、Carrier 建模均未主动识别。说明 review 当前以"内部一致性"为主，缺少"与行业标准实现比较"的视角。

### 对 Skill 体系的反馈

1. **ddd-aggregates 的 SKILL.md 建议增补**："除了从业务不变量出发，也要从'外部引用对象是否需要内部生命周期管理'这一视角审视，避免遗漏看似外部但实际需内建的聚合（如 Voyage）。"
2. **ddd-model-review 的 SKILL.md 建议增补**："若行业有成熟开源参考实现，review 应主动与之对比，列出己方模型中的语义重叠/融合点（如 Activity vs Status vs Event）。"
3. **ddd-contexts 的 ShippingRequest vs Cargo 拆分**：blind 的细分更精致，值得保留；真值未拆是因为 Spring + Hibernate 落地约束，不是模型本身要求。
