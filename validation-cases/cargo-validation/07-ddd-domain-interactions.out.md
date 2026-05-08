# 07 — ddd-domain-interactions 产出（Blind Run）

> 输入：`01`~`06`。
> 本文件为 `ddd-domain-interactions` 在 blind run 下的模拟执行产出，**未参考** `reference/` 下任何真值材料。

## 领域事件目录

### Booking 上下文发布

| 事件                       | 关键字段                                                  | 触发者                 | 订阅者                               | 幂等键                                          |
| :------------------------- | :-------------------------------------------------------- | :--------------------- | :----------------------------------- | :---------------------------------------------- |
| `ShippingRequestSubmitted` | requestId, origin, destination, latestArrival             | SubmitShippingRequest  | （内部）                             | requestId                                       |
| `OptionsPresented`         | requestId, candidates[]                                   | ACL 查询成功           | 面向客户前端（通过 Tracking 或直连） | requestId + queryVersion                        |
| `ShipmentBooked`           | shipmentId, requestId, origin, destination, latestArrival | ConfirmBooking         | Tracking, 通知                       | shipmentId                                      |
| `RouteAssigned`            | shipmentId, routeVersion, legs[]                          | AssignRoute            | Tracking                             | shipmentId + routeVersion                       |
| `RouteReassigned`          | shipmentId, newRouteVersion, legs[], reason               | Rerouting 流程         | Tracking                             | shipmentId + newRouteVersion                    |
| `HandlingApplied`          | shipmentId, handlingFactId, type, portCode, occurredAt    | Booking 消费已接受作业 | Tracking                             | shipmentId + handlingFactId                     |
| `CargoMisroutedDetected`   | shipmentId, actualPort, expectedPort, detectedAt          | 派生                   | Tracking, 通知, 运营                 | shipmentId + handlingFactId                     |
| `ETARecalculated`          | shipmentId, newEta, basedOnRouteVersion                   | 派生                   | Tracking                             | shipmentId + (routeVersion, lastHandlingFactId) |
| `CargoDelivered`           | shipmentId, deliveredAt                                   | 派生（签收作业到达后） | Tracking, 通知                       | shipmentId                                      |
| `NoFeasibleOptions`        | requestId                                                 | 外部返回空             | 运营                                 | requestId                                       |
| `SelectedOptionExpired`    | requestId, candidateId                                    | 客户延迟选择           | 客户                                 | requestId + candidateId                         |

### Handling 上下文发布

| 事件                         | 关键字段                                                                         | 触发者                         | 订阅者              | 幂等键              |
| :--------------------------- | :------------------------------------------------------------------------------- | :----------------------------- | :------------------ | :------------------ |
| `AcceptedHandlingEvent`      | handlingFactId, shipmentId, type, portCode, occurredAt, voyageLegRef, receivedAt | RegisterHandling 通过判重+校验 | Booking             | handlingFactId      |
| `DuplicateHandlingRejected`  | inboundPayload, duplicateOfId                                                    | RegisterHandling 判重命中      | 运营审计            | inboundPayload.hash |
| `InvalidHandlingQuarantined` | inboundPayload, violations[]                                                     | RegisterHandling 校验失败      | 运营审计            | inboundPayload.hash |
| `LateHandlingIngested`       | handlingFactId, occurredAt, receivedAt, lagSeconds                               | 接受时检测到迟到               | Booking（触发回溯） | handlingFactId      |

## 集成事件契约（对外）

| 契约                  | 方向                        | 载体      | 版本          | 备注               |
| :-------------------- | :-------------------------- | :-------- | :------------ | :----------------- |
| AcceptedHandlingEvent | Handling → Booking          | 事件总线  | v1            | Published Language |
| Booking 派生事件族    | Booking → Tracking          | 事件总线  | v1            | Open Host Service  |
| RouteCandidate 查询   | Booking ↔ Pathfinder        | 同步 HTTP | —（外部版本） | 经 ACL             |
| 客户通知事件          | Tracking/Booking → 通知通道 | 异步      | v1            | 建议抽独立小服务   |

## 幂等性策略

| 消费端                             | 幂等键                             | 去重窗口                   |
| :--------------------------------- | :--------------------------------- | :------------------------- |
| Booking 消费 AcceptedHandlingEvent | handlingFactId                     | 无限（持久化 applied-set） |
| Tracking 消费 Booking 事件族       | shipmentId + eventVersion          | 持久化最新版本号           |
| Pathfinder 调用响应                | requestId                          | 5 分钟（可缓存）           |
| 客户通知                           | shipmentId + reason + routeVersion | 发送日志持久化             |

## 领域服务

| 服务                   | 所在上下文 | 职责                                                                       | 为什么不放聚合                                     |
| :--------------------- | :--------- | :------------------------------------------------------------------------- | :------------------------------------------------- |
| `RoutingService`       | Booking    | 调用 ACL，从候选方案筛出可接受方案；为重规划准备"从当前位置出发"的查询参数 | 涉及外部调用与策略算法，不属于 Shipment 内部不变量 |
| `MisroutingDetector`   | Booking    | 基于已接受作业 + 当前路线版本判定 isMisrouted                              | 与单一聚合无关的派生规则集，但结果写入 Shipment 内 |
| `ETACalculator`        | Booking    | 基于已接受作业 + 当前路线版本计算 ETA                                      | 同上，算法易演进                                   |
| `HandlingValidator`    | Handling   | 字段与 (type, voyageLegRef) 规则校验                                       | 规则集合独立演进                                   |
| `DeduplicationService` | Handling   | DeduplicationKey 的幂等写入                                                | 与仓储协同的编排角色                               |

## 仓储接口（在 06 基础上延展）

```text
interface ShipmentRepository {
    find(id): Shipment
    save(shipment)
    findByStatus(predicate): Shipment[]
}

interface HandlingFactRepository {
    appendIfAbsent(fact): HandlingFactId
    findById(id): HandlingFact
    findByShipment(id, orderBy=occurredAt): HandlingFact[]
}

interface TrackingViewRepository {
    upsertProjection(view)
    findByShipment(id)
}
```

## 工厂

| 工厂                                                               | 产出                  | 关键规则                                                      |
| :----------------------------------------------------------------- | :-------------------- | :------------------------------------------------------------ |
| `ShipmentFactory.fromRequestAndOption(request, selectedCandidate)` | 新 Shipment，route v1 | 强校验：origin/destination/latestArrival 与 route 兼容（I-3） |
| `RouteFactory.fromCandidate(candidate)`                            | Route v1              | ACL 翻译结果 → 内部 legs                                      |
| `RouteFactory.reroute(currentShipment, newCandidate)`              | Route v(n+1)          | 校验新路线首段起点 == 当前位置，末段终点 == destination       |
| `HandlingFactFactory.fromRegistration(payload)`                    | HandlingFact          | 经 HandlingValidator；填充 DeduplicationKey                   |

## 订阅关系

| 发布端   | 事件                   | 订阅端   | 处理                                                                                                                                       |
| :------- | :--------------------- | :------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| Handling | AcceptedHandlingEvent  | Booking  | Shipment.apply(handling) → 重算 deliveryProgress → 发布 HandlingApplied + 可能的 ETARecalculated / CargoMisroutedDetected / CargoDelivered |
| Handling | LateHandlingIngested   | Booking  | 触发 Shipment 按 occurredAt 序列回放，发 StateRecomputed 相关事件族                                                                        |
| Booking  | 派生事件族             | Tracking | upsertProjection(TrackingView)                                                                                                             |
| Booking  | CargoMisroutedDetected | 通知通道 | 向客户与运营发告警                                                                                                                         |
| Booking  | CargoDelivered         | 通知通道 | 交付确认通知                                                                                                                               |

## 消息流（关键场景）

### Happy Path

1. Customer `SubmitShippingRequest` → Booking 调 `RoutingService` → `OptionsPresented`
2. Customer `SelectOption` + `ConfirmBooking` → Booking `ShipmentFactory.fromRequestAndOption` → 持久化 + 发 `ShipmentBooked` + `RouteAssigned(v1)`
3. 各港口依次 `RegisterHandling`（Handling 侧）→ 每次发 `AcceptedHandlingEvent`
4. Booking 消费 → 应用到 Shipment → 派生进度 → 发 `HandlingApplied` + `ETARecalculated`
5. 到 Claim → `CargoDelivered`

### Misrouting & Rerouting

1. 某次 Unload 的 portCode ≠ 计划港口 → Booking 派生 `CargoMisroutedDetected`
2. 客服/系统 `RequestReroute` → `RoutingService` 从当前位置查询 → `RouteFactory.reroute` → 发 `RouteReassigned(v(n+1))` + `ETARecalculated`

### Late arrival

1. Handling 收到一条 occurredAt 远早于现在的 fact → 幂等写入 + 发 `LateHandlingIngested`
2. Booking 订阅 → 按 occurredAt 从历史锚点回放 → 修正派生进度 → 发相关派生事件（幂等键让下游收敛）

## 校验自检

- [x] 事件均为过去时命名
- [x] 每个跨上下文事件均定义幂等键
- [x] 领域服务与聚合职责不重叠，且未承载"本该在聚合内的不变量"
- [x] 仓储接口粒度=聚合根
- [x] 工厂承担了"不变量 I-3 / I-8 / I-9" 的入口校验
- [x] 异常场景（重复、非法、迟到、错卸、降级）均有显式订阅关系
