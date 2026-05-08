# 05 — ddd-context-map 产出（Blind Run）

> 输入：`01`~`04` 的 blind 产出。
> 本文件为 `ddd-context-map` 在 blind run 下的模拟执行产出，**未参考** `reference/` 下任何真值材料。

## 上下文关系矩阵

| 上游 → 下游                                                              | 关系模式                                   | 集成方式                     | 传输契约                                                                                                                                 | 方向                         |
| :----------------------------------------------------------------------- | :----------------------------------------- | :--------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------- |
| Handling → Booking                                                       | Customer-Supplier                          | 异步事件（"作业事实已接受"） | Published Language：AcceptedHandlingEvent（order, handlingType, occurredAt, location, voyageLeg, version）                               | 单向（Handling 上游）        |
| Booking → Tracking                                                       | Open Host Service + Published Language     | 异步事件订阅                 | TrackingProjection 事件族：ShipmentBooked / RouteAssigned / RouteReassigned / CargoMisroutedDetected / ETARecalculated / HandlingApplied | 单向（Booking 上游）         |
| Booking → Pathfinder（调用方向）<br>Pathfinder → Booking（概念供应方向） | Customer-Supplier + ACL（Conformist 反面） | 同步请求/响应                | 外部 OpenAPI → 经 ACL 翻译为内部 "RouteCandidate / Leg / VoyageSchedule" 草案                                                            | 双向对话（Booking 主动调用） |
| Handling → Tracking                                                      | 无直接关系                                 | —                            | 禁止；必须经 Booking 中转                                                                                                                | —                            |

## 契约所有权

| 契约                                   | 所有者                            | 变更策略                                                                    |
| :------------------------------------- | :-------------------------------- | :-------------------------------------------------------------------------- |
| AcceptedHandlingEvent（Handling 发布） | Handling 团队                     | 向后兼容优先：新增字段允许；删除/改名需版本号并灰度                         |
| Booking 的派生事件族（发给 Tracking）  | Booking 团队                      | 作为 Open Host Service 的 Published Language 维护；变更走同样的向后兼容规则 |
| RouteCandidate 内部草案格式            | Booking 团队（经 ACL 定义）       | 外部变更时由 ACL 吸收，Booking 内部模型不变                                 |
| ACL 翻译规则                           | Booking 团队 + 集成负责人（共治） | 每次外部接口变更触发 ACL 回归测试                                           |

## 翻译 / ACL 决策

### ACL-1：Pathfinder → Booking

- **入**：外部候选方案（字段命名、单位、时间时区均可能外部独立演进）。
- **出**：内部 `RouteCandidate { origin, destination, legs[], estimatedArrival }`。
- **规则**：
  - 港口代码外部可能是三字或自定义编码 → ACL 统一为内部港口标识；未知编码进隔离区并报警。
  - 时间一律转为 UTC + occurredAt 语义。
  - 价格相关字段**丢弃**（非目标）。
  - 不兼容版本：ACL 层兜底到上一个已知版本的缓存方案；若无则返回"降级空列表"。

### ACL-2：Handling 入口的"方言适配"

- Handling 虽然是内部上下文，但其对外（Web/API/文件）通道差异很大，内部先建**通道适配层**把多种载荷归一为统一的"登记命令"，再进入幂等与校验流水线。
- 该适配层不算 ACL（对内不对外），但角色相似。

## 失败模式与降级

| 场景                   | 影响                     | 处理                                                                                         |
| :--------------------- | :----------------------- | :------------------------------------------------------------------------------------------- |
| Pathfinder 超时 / 5xx  | 下单阶段：无法返回方案   | ACL 返回"缓存 + 降级为空列表"；Booking 上层将 `ShippingRequest` 置为"待稍后重试"，不生成订单 |
| Pathfinder 返回空      | 无可行方案               | 发 `NoFeasibleOptions` 事件，推送运营复核                                                    |
| Handling 上游中断      | Booking 无法推进状态派生 | Booking 冻结 ETA 更新；Tracking 视图展示"数据滞后中"标记                                     |
| Handling 批量迟到      | 历史状态需回溯重算       | Booking 订阅 `LateHandlingIngested`，按 occurredAt 重新跑派生流水线；Tracking 视图异步刷新   |
| Booking 事件发布失败   | Tracking 视图落后        | 事件总线持久化 + 重放；消费者幂等                                                            |
| ACL 无法识别外部新字段 | 潜在数据丢失             | 原始载荷进隔离区，报警；Booking 不接受未知语义                                               |

## 版本与演进策略

- 所有对外发布的事件采用**结构版本号**；字段只增不删；删字段走 2 个大版本的 deprecation 窗口。
- ACL 针对 Pathfinder 接口维持**最近两个版本**的翻译能力，自动选择。
- Booking 的内部路线版本号（同一订单下的 RouteVersion）与事件版本号是两个不同维度，不可混用。

## 已知缺口与假设（blind run 限制下的坦白）

| 项                             | 状态                   | 备注                                                                                                                   |
| :----------------------------- | :--------------------- | :--------------------------------------------------------------------------------------------------------------------- |
| 客户通知渠道（邮件/短信/站内） | 未纳入正式上下文       | 从 `02-discover` 的 `CustomerNotifiedOfReroute` 抽象出来，但本期是否独立成上下文未定；建议作为 Tracking 的一个外发端口 |
| Billing / CRM                  | 明确非目标             | 已在 `scope` 中排除；未来若加入，其与 Booking 的关系需重新制图                                                         |
| 船公司调度、仓储               | 明确非目标             | 同上                                                                                                                   |
| 港口标识的主数据               | 假设存在"内部港口字典" | 实际是否单独成支撑上下文待确认                                                                                         |

## 依赖方向图（文字版）

```text
Customer ──submit──▶ Booking ──query──▶ [ACL] ──────▶ Pathfinder (external)
                       ▲                  │
                       │                  └── translate ──▶ RouteCandidate
                       │
                       │ subscribes AcceptedHandlingEvent
                       │
                    Handling ◀──register── PortOperators / External Partners
                       │
                       │
                       ▼
                    Tracking ◀── subscribe(Booking published events) ── Booking
                       ▲
                       │
                    Customer (self-service)
```

## 校验自检

- [x] 每对上下文间的关系模式、集成方式、契约名均已标注
- [x] 契约所有权清晰（谁拥有、谁变更）
- [x] ACL 的翻译规则与失败降级均已说明
- [x] 失败模式覆盖上下游双向
- [x] 版本演进策略明确（结构版本 + 路线版本两维度）
- [x] 与 `ddd-contexts` 的 ADR-01/02/03/04 保持一致
