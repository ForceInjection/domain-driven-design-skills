# Ground Truth — 上下文关系与集成模式参考

> 来源：`src/main/java/com/pathfinder/`（外部路由服务）、`src/main/java/se/citerus/dddsample/infrastructure/routing/ExternalRoutingService.java`（ACL 实现）、`src/main/java/se/citerus/dddsample/interfaces/handling/`（入站 HandlingReport API）、`src/site/apt/patterns-reference.apt`。

## 上下文关系矩阵（期望）

| 上游               | 下游               | 模式                         | 数据 / 事件                                       | 风险 / 失败模式                                       |
| :----------------- | :----------------- | :--------------------------- | :------------------------------------------------ | :--------------------------------------------------- |
| Booking            | Routing (Pathfinder) | **ACL + Customer-Supplier** | 请求：RouteSpecification；响应：List<TransitPath> → 翻译为 List<Itinerary> | 外部系统不可用 → 降级：不能路由但可下单；超时需熔断 |
| Handling           | Cargo（通过 Booking BC 内聚合） | **Published Language（HandlingEvent）** | 异步事件 CargoWasHandled；Cargo 通过 TrackingId 引用 | 事件丢失 → Delivery 状态滞后；重复投递需幂等         |
| Handling           | Tracking           | **Published Language**       | 同上 CargoWasHandled + 派生事件 CargoWasMisdirected / CargoHasArrived | 状态一致性窗口（读者看到旧状态）                    |
| 外部作业系统（仓储/港口） | Handling           | **Conformist + ACL at edge** | HandlingReport（JSON/CSV）→ HandlingEventRegistrationAttempt | 脏数据、重复提交、时钟偏移                         |
| Tracking           | Booking            | **Conformist**（只读 Cargo 投影） | 读 Cargo 聚合                                     | 读的是 eventually consistent 快照                   |

> **评分关键点**：
> 1. Routing 必须被识别为**外部上下文**且用 **ACL** 保护 Booking；若 skill 把 Routing 放进 Booking 或不设 ACL，扣分。
> 2. HandlingEvent 必须被识别为**跨上下文的 Published Language**；若 skill 把它当成 Booking 内部事件，扣分。
> 3. 不应出现循环依赖（Booking → Handling → Booking）。

## 契约所有权矩阵（期望）

| 契约                                          | Owner              | 消费者                   | 变更流程                                               | 发布策略                       |
| :-------------------------------------------- | :----------------- | :----------------------- | :----------------------------------------------------- | :----------------------------- |
| HandlingReport REST API（POST /dddsample/handlingReport） | Handling 团队      | 外部作业系统             | 向后兼容；字段新增优先；破坏性变更须 deprecation 通知 | v1 路径版本；6 个月兼容窗口    |
| CargoWasHandled 集成事件 schema               | Handling 团队      | Tracking、Cargo Inspection | 向后兼容；字段新增优先                                | schema registry + contract tests |
| RoutingService 域接口                         | Booking 团队       | Booking（唯一）          | 接口变更需与 Pathfinder 团队协商                      | 无外部版本；内部演进            |
| TransitPath/TransitEdge（Pathfinder 外部 API）| Pathfinder 外部团队 | Booking（通过 ACL 消费） | Booking 不可驱动变更；由 Pathfinder 发布              | 外部控制；ACL 吸收差异          |

## 翻译与 ACL 决策（期望）

| 对象 / 事件           | 翻译规则                                                                                      | 语义差异说明                                                        | 实现位置                                                      |
| :-------------------- | :-------------------------------------------------------------------------------------------- | :------------------------------------------------------------------ | :------------------------------------------------------------ |
| TransitPath → Itinerary | 每个 TransitEdge → Leg；extract voyage/location；过滤不满足 RouteSpec 的路径                 | Pathfinder 不知道 Cargo 存在；只知 origin/destination/deadline      | `infrastructure/routing/ExternalRoutingService`               |
| HandlingReport JSON → HandlingEventRegistrationAttempt | 字段重命名、时区归一化、UnLocode 校验 | 外部可能用不同字段名、时区；需宽容解析                              | `interfaces/handling/ws/HandlingReportServiceImpl`（ACL）     |

## 失败模式与缓解（期望）

| 失败模式                          | 影响                          | 检测方式                       | 缓解措施                                                       | 补偿策略                                    |
| :-------------------------------- | :---------------------------- | :----------------------------- | :------------------------------------------------------------- | :------------------------------------------ |
| Pathfinder 超时                   | 客户无法看到可选航线          | 请求超时 + 指标 routing_timeout | 超时熔断；返回空列表 + 用户提示"稍后重试"                        | 无补偿；用户重试即可                        |
| Pathfinder 返回异常路径           | 客户误选不可行 Itinerary      | RouteSpecification.isSatisfiedBy | Booking 端二次校验；不满足则拒绝 assignCargoToRoute             | 拒绝并要求重新选择                          |
| HandlingEvent 丢失                | Delivery 状态滞后             | 对比外部系统的事件流水         | 对账任务；重放窗口                                               | 从外部系统回拉并重新注册（幂等保证无重复）  |
| HandlingEvent 重复                | 可能误判 misdirected          | 身份五元组天然去重             | Factory 去重                                                    | —                                           |
| 外部作业系统时钟偏移              | completionTime 错乱           | 注册时打印 registrationTime 与 completionTime 差 | 异常报警；容忍窗口 ±2 小时                                    | 人工修正                                    |
| Cargo 重算失败（inspectCargo 异常）| Delivery 状态不一致            | 监控 inspect_failure_rate      | 重试（幂等）；死信队列                                           | 人工介入                                    |

## 版本策略（期望）

- **HandlingReport API**：v1 路径版本；破坏性变更需 6 个月 deprecation 期；字段新增必须向后兼容。
- **CargoWasHandled 事件 schema**：在 schema registry 注册；消费者提供 contract tests。
- **RoutingService 内部接口**：无版本化需求，随代码库演进。

## 已知设计权衡（评分时作为加分项）

- **HandlingEvent 独立聚合**（非 Cargo 子资源）：O(n) 写入代替 O(cargo_size × events) 加载，见 `characterization.apt` "The main reason for not making HandlingEvent part of the cargo aggregate is performance"。
- **Delivery 为推导值对象**：天然防止状态不一致。
- **RouteSpecification 作为 Specification 模式**：`isSatisfiedBy(Itinerary)` 可复用于搜索与校验。

## 评分加分项（Cargo 官方样例的已知不足）

以下是 O&B 与社区普遍承认的 Cargo 样例局限，若 skill 能主动识别并提出，加分：

1. **Billing 上下文缺失**：官方样例没有 Billing；skill 若提出"当客户完成 CLAIM 时应触发计费"，加分。
2. **Customer 上下文缺失**：没有独立的客户管理；skill 若提出 Customer 作为 Generic 子域，加分。
3. **Carrier（承运方）与 Voyage 的关系未建模**：Voyage 有 VoyageNumber 但承运公司不在模型中；skill 若指出这是外部建模简化，加分。
4. **HandlingEvent / HandlingActivity / TransportStatus 语义重叠**：O&B 明确指出应合并为 HandlingActivity；skill 若在 `ddd-model-review` 中识别此重叠，**关键加分**。
