# Ground Truth — 限界上下文参考

> 来源：[validation-cases/cargo-shipping](../../cargo-shipping/)（Eric Evans + Citerus 官方 DDD Sample）。仅用于评分阶段与 skill 输出做 1:1 对比，**不得在 blind run 期间暴露给 skill**。

## 证据出处

- `src/site/apt/architecture.apt`（分层架构与领域层职责）
- `src/site/apt/characterization.apt`（4 个聚合根确认）
- `src/site/apt/patterns-reference.apt`（模式到代码路径的映射）
- `src/main/java/se/citerus/dddsample/interfaces/{booking,handling,tracking}/`（三个 UI/API 入口面）
- `src/main/java/com/pathfinder/`（外部路由服务，独立包）

## 上下文目录（期望）

> Cargo 样例的官方实现把所有聚合放在单一包 `se.citerus.dddsample`，但接口层按 **booking / handling / tracking** 三个用例面做了物理分离；同时 `com.pathfinder` 是一个独立的外部上下文。权威观察（O&B 2014）明确指出"官方样例只有 1 个 BC 是局限性，实践中应至少拆出 3~4 个"。因此评分时以"拆出 3 + 1 外部"为满分基线，"单一 BC"视为不及格。

| 上下文名                | 职责                                           | 核心术语                                                                  | 主要事件                                                          | 数据所有权                             | 负责团队（期望）     |
| :---------------------- | :--------------------------------------------- | :------------------------------------------------------------------------ | :---------------------------------------------------------------- | :------------------------------------- | :------------------- |
| **Booking**             | 货物下单、改目的地、请求与分配航线             | Cargo, TrackingId, RouteSpecification, Itinerary, Leg, UnLocode           | CargoBooked（隐式）、RouteAssigned（隐式）、DestinationChanged    | Cargo 聚合、Itinerary/RouteSpec 值对象 | 订舱/客服团队        |
| **Handling**            | 港口作业事件的登记（RECEIVE/LOAD/UNLOAD/CLAIM/CUSTOMS） | HandlingEvent, HandlingEventType, HandlingHistory, HandlingEventRegistrationAttempt | HandlingEventRegistered、CargoWasHandled                          | HandlingEvent 聚合                     | 港口/仓储作业方      |
| **Tracking**            | 向客户呈现货物当前状态与下一步预期动作         | Delivery, TransportStatus, RoutingStatus, NextExpectedActivity            | CargoWasMisdirected、CargoHasArrived（订阅端）                    | 只读：订阅 Handling 事件并投影 Cargo    | 客户侧/前端团队      |
| **Routing (Pathfinder)** | 基于 RouteSpecification 搜索可行航线组合       | TransitPath, TransitEdge, GraphTraversalService                           | —（请求/响应式，无事件）                                          | 外部路由图数据                         | 外部团队（不受控）   |

## 通用语言词汇表（抽样，期望）

| 术语                 | 定义                                                                    | 示例                                                     | 所属上下文 | 同义词（业务常见） | 反术语 / 冲突处理                                          |
| :------------------- | :---------------------------------------------------------------------- | :------------------------------------------------------- | :--------- | :----------------- | :--------------------------------------------------------- |
| Cargo                | 客户一次托运的货物聚合，由 TrackingId 唯一标识                          | HONGKONG→STOCKHOLM 的一票货                              | Booking    | 订单、运单         | 禁用 "Order"（业务不等价）                                 |
| RouteSpecification   | 客户要求：起点、终点、到达截止时间                                      | HONGKONG→STOCKHOLM，截止 2009-03-18                      | Booking    | 下单要求           | 禁用 "Request"（无业务含义）                               |
| Itinerary            | 计划航线，由若干 Leg 组成；**值对象**，整体替换而非修改                  | [HK→NYC via v100, NYC→CHI via v200, CHI→STO via v200]    | Booking    | 路由方案           | 与 Route 区分：Route 暗示图算法结果，Itinerary 是业务承诺  |
| HandlingEvent        | 港口真实发生的作业事实（LOAD/UNLOAD/RECEIVE/CLAIM/CUSTOMS）             | "2009-03-03 HK 装上 v100"                                | Handling   | 作业记录           | 禁用 "Operation"（泛化）；与 HandlingActivity 区分         |
| HandlingActivity     | Cargo 当前预期的下一步动作（值对象）                                    | (UNLOAD, NEWYORK, v100)                                  | Tracking   | 下一步             | **已知语义重叠**：HandlingEvent / HandlingActivity / TransportStatus 有重叠，模型健康度项 |
| Delivery             | 交付状态快照，由 RouteSpec+Itinerary+HandlingHistory **推导**而出       | 含 transportStatus, lastKnownLocation, isMisdirected     | Tracking   | 状态               | **不变量**：永远不可直接 set                               |
| Voyage               | 一次承运航程（vessel + schedule），由 VoyageNumber 唯一标识             | v100: HK→NYC→...                                         | Booking    | 航次               | 与 Vessel 区分：Voyage 是"一次行程"，非船舶本身             |
| Misdirected          | 实际作业事实偏离 Itinerary 的状态                                        | 本应在 NYC 卸，实际在 TOKYO 卸                           | Tracking   | 走错、错运         | —                                                          |

## 反术语（期望）

| 禁用词   | 禁用原因                                  | 推荐替代                    |
| :------- | :---------------------------------------- | :-------------------------- |
| Manager  | 技术词污染，无业务含义                    | BookingService / (领域服务) |
| Handler  | 技术词污染                                | —（改用业务动词）           |
| Order    | 业务不等价（物流不是电商）                | Cargo                       |
| Status   | 过于笼统                                  | TransportStatus/RoutingStatus 等具体枚举 |

## 关键 ADR（期望）

- **ADR-1**：HandlingEvent 独立成聚合，不内嵌 Cargo。理由：事件来自外部系统、吞吐高、需异步；把 HandlingEvent 放进 Cargo 聚合会产生同步加载开销与死锁风险。权衡：Cargo 状态需通过 `deriveDeliveryProgress(HandlingHistory)` 重算，是最终一致性。
- **ADR-2**：Delivery 设计为**推导值对象**而非可变实体。理由：保证"状态来自事实（RouteSpec+Itinerary+HandlingHistory）"的不变量，杜绝 setter 反模式。
- **ADR-3**：路由能力（Pathfinder）作为独立外部上下文通过 `RoutingService` 域接口 + 基础设施层 ACL（`ExternalRoutingService`）接入。
