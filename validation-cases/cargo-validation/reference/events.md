# Ground Truth — 事件流与领域交互参考

> 来源：`src/test/java/se/citerus/dddsample/scenario/CargoLifecycleScenarioTest.java`（端到端生命周期）、`src/main/java/se/citerus/dddsample/application/ApplicationEvents.java`（应用事件）、`src/main/java/se/citerus/dddsample/domain/service/RoutingService.java`（领域服务）。

## 事件流表（期望，基于 CargoLifecycleScenarioTest 主路径 + 异常路径）

> 标注 **M** = 主路径（HK→NYC→CHI→STO），**R** = 重新规划路径（HK→TOKYO 错卸 → TOKYO→HAMBURG→STO）。

| 序号 | 事件名（过去时）             | 触发命令                                  | 参与者           | 关键输入/输出                              | 分支   |
| :--- | :--------------------------- | :---------------------------------------- | :--------------- | :----------------------------------------- | :----- |
| 1    | CargoBooked                  | bookNewCargo                              | 订舱员           | (origin, destination, arrivalDeadline) → TrackingId | M      |
| 2    | RouteCandidatesRequested     | requestPossibleRoutesForCargo             | 订舱员           | TrackingId → List<Itinerary>               | M      |
| 3    | RouteAssigned                | assignCargoToRoute                        | 订舱员           | (TrackingId, Itinerary)                    | M      |
| 4    | CargoReceived                | registerHandlingEvent (type=RECEIVE)      | 港口作业员       | (trackingId, HONGKONG, 2009-03-01)         | M      |
| 5    | CargoLoaded                  | registerHandlingEvent (type=LOAD)         | 港口作业员       | (trackingId, HONGKONG, voyage=v100)        | M      |
| 6    | InvalidHandlingEventRejected | registerHandlingEvent（错误 voyage+UnLocode） | 外部系统       | → CannotCreateHandlingEventException       | 异常   |
| 7    | CargoUnloaded                | registerHandlingEvent (type=UNLOAD)       | 港口作业员       | (trackingId, TOKYO, v100) — **错卸**       | R      |
| 8    | CargoWasMisdirected          | CargoInspectionService.inspectCargo       | 系统（应用事件） | Cargo.isMisdirected() == true              | R      |
| 9    | DestinationChanged / RouteRespecified | specifyNewRoute                  | 调度员/客服       | (trackingId, new RouteSpecification TOKYO→STOCKHOLM) | R |
| 10   | RouteReAssigned              | assignCargoToRoute                        | 调度员           | (trackingId, new Itinerary)                | R      |
| 11   | CargoLoaded (2)              | registerHandlingEvent(LOAD)               | 港口作业员       | (TOKYO, v300)                              | R      |
| 12   | CargoUnloaded (2)            | registerHandlingEvent(UNLOAD)             | 港口作业员       | (HAMBURG, v300)                            | R      |
| 13   | CargoLoaded (3)              | registerHandlingEvent(LOAD)               | 港口作业员       | (HAMBURG, v400)                            | R      |
| 14   | CargoUnloaded (3)            | registerHandlingEvent(UNLOAD)             | 港口作业员       | (STOCKHOLM, v400)                          | R      |
| 15   | CargoHasArrived              | CargoInspectionService.inspectCargo       | 系统（应用事件） | 触发到达通知                                | R      |
| 16   | CargoClaimed                 | registerHandlingEvent(CLAIM)              | 客户             | (STOCKHOLM) — 生命周期结束                 | R      |

## 命令候选清单

| 命令                          | 发起者            | 期望结果                                          | 幂等性要求                                                                       |
| :---------------------------- | :---------------- | :------------------------------------------------ | :------------------------------------------------------------------------------- |
| bookNewCargo                  | 订舱员            | 返回 TrackingId；Cargo 聚合落库                   | **非幂等**（每次创建新 Cargo）；但客户端可用外部幂等键                              |
| specifyNewRoute               | 调度员            | Cargo.routeSpecification 被替换；Delivery 同步重算 | **幂等**：相同 RouteSpecification 再次调用无副作用（VO 相等性）                    |
| assignCargoToRoute            | 订舱员 / 调度员   | Cargo.itinerary 被替换；Delivery 同步重算         | **幂等**（同上）                                                                 |
| changeDestination             | 客服              | RouteSpecification 目的地被替换                   | 幂等                                                                             |
| registerHandlingEvent         | 港口作业员 / 外部系统 | HandlingEvent 落库；异步触发 Cargo 重算 Delivery  | **幂等关键**：HandlingEvent 身份 = (cargo, voyage, completionTime, location, type) 组合，重复注册应去重 |
| inspectCargo                  | 系统（订阅 CargoWasHandled） | 判断 misdirected/arrived 并发应用事件           | 幂等：判断基于当前快照                                                            |

## 事件候选清单

| 事件                        | 关键字段                                                             | 范围          | 是否跨上下文      | 是否对外发布         |
| :-------------------------- | :------------------------------------------------------------------- | :------------ | :---------------- | :------------------- |
| CargoWasHandled             | HandlingEvent（含 cargo, voyage, location, type, completionTime）    | Domain Event  | 是（Handling→Cargo→Tracking） | 是（Published Language）|
| CargoWasMisdirected         | Cargo（只读投影）                                                    | Application   | 否（内部通知）      | 对客户通知：是       |
| CargoHasArrived             | Cargo                                                                | Application   | 否                | 对客户通知：是       |
| HandlingEventRegistrationAttempt | raw request fields                                              | Interfaces    | 否                | 否（入站数据）       |

## 领域服务（期望）

| 服务名                     | 职责                                                                 | 输入                  | 输出                | 依赖聚合/事件            | 不应包含的逻辑                     |
| :------------------------- | :------------------------------------------------------------------- | :-------------------- | :------------------ | :----------------------- | :--------------------------------- |
| **RoutingService**（域接口）| 根据 RouteSpecification 查找可行 Itinerary 列表                       | RouteSpecification    | List<Itinerary>     | —（外部上下文 Pathfinder） | 不负责路线分配、不触碰 Cargo 状态 |
| **CargoInspectionService**（应用服务，但承载领域判断） | 基于最新 HandlingHistory 重算 Delivery 并发出 misdirected/arrived 通知 | TrackingId            | 副作用：更新 Cargo + 发事件 | Cargo, HandlingEvent 仓储 | 不写入新 HandlingEvent             |

> **评分关键点**：RoutingService 是领域服务接口（领域层），其**实现** `ExternalRoutingService` 在基础设施层，充当 ACL。skill 若把 RoutingService 的实现塞进领域层，扣分。

## 工厂（期望）

| 工厂名/方法                         | 创建目标      | 创建条件                                                                                         | 验证规则                                                                          | 初始状态                        |
| :---------------------------------- | :------------ | :----------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------- | :------------------------------ |
| CargoFactory.newCargo               | Cargo         | (origin UnLocode, destination UnLocode, arrivalDeadline)                                         | 起点/终点必须存在；起点 ≠ 终点；TrackingId 唯一                                    | Delivery=NOT_RECEIVED, NOT_ROUTED |
| HandlingEventFactory.createHandlingEvent | HandlingEvent | (completionTime, trackingId, voyageNumber?, unLocode, type)                                 | Cargo/Location/Voyage（若需要）必须存在；Type 与 Voyage 的搭配合法                 | 立即可落库                       |

## 订阅者与副作用

| 事件                | 订阅者                         | 触发动作                                       | 补偿策略                              | 监控指标                            |
| :------------------ | :----------------------------- | :--------------------------------------------- | :------------------------------------ | :---------------------------------- |
| CargoWasHandled     | CargoInspectionService         | 重算 Delivery；若 misdirected 发通知；若 arrived 发通知 | 失败重试（幂等）；死信 → 人工介入       | handled_event_lag、inspect_failure_rate |
| CargoWasMisdirected | （对外）客户通知通道            | 推送客户                                        | 重试；降级为邮件                       | misdirected_count                   |
| CargoHasArrived     | （对外）客户通知通道            | 推送客户                                        | 同上                                   | arrived_count                       |
