# 06 — ddd-aggregates 产出（Blind Run）

> 输入：`01`~`05`。
> 本文件为 `ddd-aggregates` 在 blind run 下的模拟执行产出，**未参考** `reference/` 下任何真值材料。

## 聚合目录

| 聚合                               | 所属上下文 | 聚合根             | 根 ID                           | 事务边界说明                                                                                                                           |
| :--------------------------------- | :--------- | :----------------- | :------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------- |
| **Shipment 一票货物**              | Booking    | Shipment           | ShipmentId                      | 包含：起终点、最晚到达时间、当前路线（可版本化）、派生的交付进度（位置/下一步/ETA/是否错卸）。一次事务内保证"指派路线"与"派生进度"一致 |
| **RouteCandidate 路线草案**        | Booking    | RouteCandidate     | CandidateId（ACL 内短生命周期） | 由 ACL 从外部候选翻译而来的一次性值；不持久化；供 Shipment 选择后冻结为 Shipment.route                                                 |
| **HandlingFact 作业事实**          | Handling   | HandlingFact       | HandlingFactId                  | 单条作业事实一经写入不可变；判重键命中则复用已有 Id；一次事务写入单条                                                                  |
| **TrackingView 跟踪视图**          | Tracking   | TrackingView       | ShipmentId（1:1）               | 纯读模型；从 Booking 发布的事件投影；不承担业务规则                                                                                    |
| **PortDirectory 港口字典**（假设） | 支撑       | PortDirectoryEntry | PortCode                        | 参考数据；对所有上下文只读                                                                                                             |

> 说明：`RouteCandidate` 作为值而非持久聚合根呈现更合适，这里纳入是为了显式 ACL 产出；正式落地建议定义为 Booking 内部的 VO。

## 实体 / 值对象分类

### Shipment 聚合

| 类型           | 名称                 | 角色           | 关键字段 / 不变量                                                  |
| :------------- | :------------------- | :------------- | :----------------------------------------------------------------- |
| Entity（Root） | Shipment             | 订单聚合根     | id、origin、destination、latestArrival、route、deliveryProgress    |
| VO             | Origin / Destination | 起终点         | PortCode 不变                                                      |
| VO             | LatestArrival        | 最晚到达时间   | 不可变；创建后仅在"客户变更流程"中替换整个值                       |
| Entity（本地） | Route                | 路线（带版本） | version、legs[]、计划到达时间；版本递增                            |
| VO             | Leg                  | 航段           | from、to、loadTime、unloadTime、voyageRef                          |
| VO             | VoyageRef            | 外部船期引用   | 仅持有引用码，不持有外部实体                                       |
| VO             | DeliveryProgress     | 派生进度       | currentLocation、nextExpectedAction、eta、isMisrouted、isDelivered |

### HandlingFact 聚合

| 类型           | 名称             | 关键字段 / 不变量                                                                    |
| :------------- | :--------------- | :----------------------------------------------------------------------------------- |
| Entity（Root） | HandlingFact     | id、shipmentId、type、portCode、occurredAt、voyageLegRef、receivedAt                 |
| VO             | HandlingType     | 枚举（Receive/Load/Unload/Arrive/Transit/Claim）；与是否需要 voyageLegRef 有联动约束 |
| VO             | DeduplicationKey | (shipmentId, type, portCode, occurredAt, voyageLegRef)                               |

### TrackingView 聚合

| 类型           | 名称         | 关键字段                                                                               |
| :------------- | :----------- | :------------------------------------------------------------------------------------- |
| Entity（Root） | TrackingView | shipmentId（=1:1）、currentLocation、nextExpectedAction、eta、isMisrouted、lastUpdated |

## 不变量表

| 编号 | 不变量                                                                                                                                            | 所在聚合                | 触发位置                 | 等级 |
| :--- | :------------------------------------------------------------------------------------------------------------------------------------------------ | :---------------------- | :----------------------- | :--- |
| I-1  | Shipment 的 origin/destination 一经创建不可被静默修改；变更必须走"重规划 / 客户变更"显式流程                                                      | Shipment                | 创建、重规划             | 强   |
| I-2  | Shipment 的 latestArrival 只能在重规划流程中通过业务方授权替换                                                                                    | Shipment                | 重规划                   | 强   |
| I-3  | Shipment.route 必须与 Shipment.origin/destination 兼容（route 的首段起点 == origin，末段终点 == destination）；若重规划则首段起点 == 当前实际位置 | Shipment                | 指派路线                 | 强   |
| I-4  | Shipment.deliveryProgress 必须是**派生**值（由 route + 已接受作业推导），绝不可被外部直接设置                                                     | Shipment                | 每次接收已接受作业事件后 | 强   |
| I-5  | isMisrouted 当且仅当最后一条"卸船/到港"作业的港口 ≠ 当前路线版本对应的计划港口                                                                    | Shipment                | 派生                     | 强   |
| I-6  | ETA 必须基于"当前路线版本 + 已接受作业"重新计算，不能基于历史路线                                                                                 | Shipment                | 派生                     | 强   |
| I-7  | HandlingFact 一经写入不可修改；修正必须以"新事实覆盖 + 保留历史"实现                                                                              | HandlingFact            | 写入                     | 强   |
| I-8  | HandlingFact 的 (type, voyageLegRef) 必须自洽：Load/Unload/Transit 必须有 voyageLegRef；Receive/Arrive/Claim 必须没有                             | HandlingFact            | 写入                     | 强   |
| I-9  | 同一 DeduplicationKey 在 HandlingFact 中至多存在 1 条                                                                                             | HandlingFact            | 写入                     | 强   |
| I-10 | TrackingView 仅由 Booking 发布的派生事件驱动；不得被其他源写入                                                                                    | TrackingView            | 投影                     | 强   |
| I-11 | Shipment 只直接引用其 route 的副本；跨聚合引用 HandlingFact 时仅持有 HandlingFactId                                                               | Shipment / HandlingFact | 建模规则                 | 中   |

**不变量覆盖面自检**：11 条不变量中，强约束 10 条、中 1 条。

## 跨聚合一致性

| 场景                                                           | 一致性模式           | 说明                                                                       |
| :------------------------------------------------------------- | :------------------- | :------------------------------------------------------------------------- |
| Handling 接受一条作业 → Booking 更新 Shipment.deliveryProgress | 最终一致（事件驱动） | Handling 提交 + 发事件 + Booking 订阅；Booking 端幂等（以 HandlingFactId） |
| Booking 重指派路线 → Tracking 刷新视图                         | 最终一致             | 通过 RouteReassigned 事件投影                                              |
| 迟到作业 → Booking 回溯重算 → Tracking 重投影                  | 最终一致 + 时间回溯  | 按 occurredAt 重新跑派生                                                   |
| 客户变更 origin/destination/latestArrival                      | 强一致（聚合内事务） | 只能通过"客户变更命令"原子替换，同时重算 deliveryProgress                  |

## 仓储接口草案

```text
interface ShipmentRepository {
    find(id: ShipmentId): Shipment
    save(shipment: Shipment): void   // 整聚合写入，乐观锁基于 route.version 或聚合版本
    findOverdue(asOf: Timestamp): Shipment[]   // 运营用
}

interface HandlingFactRepository {
    appendIfAbsent(fact: HandlingFact): HandlingFactId   // 幂等写入；按 DeduplicationKey 去重
    findById(id: HandlingFactId): HandlingFact
    history(shipmentId: ShipmentId, orderBy: "occurredAt"): HandlingFact[]
}

interface TrackingViewRepository {
    upsertProjection(view: TrackingView): void
    findByShipment(id: ShipmentId): TrackingView
}
```

## 边界与事务策略

- **写边界**：Shipment 一次事务内包含 "route 指派 + deliveryProgress 派生"；HandlingFact 一次事务内单条写入。
- **不允许**：跨聚合大事务。Booking 更新 Shipment 时引用 HandlingFact 只通过 ID + 事件载荷副本。
- **幂等键**：HandlingFact 的 DeduplicationKey；Booking 端对 AcceptedHandlingEvent 的消费以 HandlingFactId 幂等。

## 校验自检

- [x] 每个聚合均有明确的事务边界声明
- [x] 聚合根、实体、VO 清晰区分
- [x] 不变量 ≥ 10 条，且强约束比例高（10/11）
- [x] 跨聚合交互全部走最终一致，未发现隐式大事务
- [x] 仓储接口只以聚合根粒度暴露
- [x] 与 `ddd-context-map` 的契约一致（HandlingFactId 作为幂等键）

## 潜在弱点（诚实记录）

- `RouteCandidate` 的位置稍显尴尬：归入 Booking 的 VO 更干净，这里独立列出只是为 ACL 描述方便。正式落地建议取消独立聚合表述。
- `VoyageRef` 目前仅为引用码；如果未来需要在内部管理"船期"生命周期（非目标外扩），需要升格为独立聚合。当前假设外部托管。
