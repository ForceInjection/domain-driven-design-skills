# Ground Truth — 聚合、实体、值对象与不变量参考

> 来源：`src/main/java/se/citerus/dddsample/domain/model/{cargo,handling,location,voyage}/` 与 `src/site/apt/characterization.apt`。

## 聚合目录（期望 4 个聚合根）

| 聚合名        | 聚合根         | 包含实体 | 包含值对象                                                                              | 关键不变量                                                                                                     | 关键命令                                                                |
| :------------ | :------------- | :------- | :-------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| **Cargo**     | Cargo          | —        | TrackingId, RouteSpecification, Itinerary, Leg, Delivery, TransportStatus, RoutingStatus | I1 起点永不变；I2 Delivery 只能由 RouteSpec+Itinerary+HandlingHistory 推导；I3 RouteSpec.origin ≠ destination | bookNewCargo, specifyNewRoute, assignToRoute, deriveDeliveryProgress    |
| **HandlingEvent** | HandlingEvent  | —        | HandlingEvent.Type（LOAD/UNLOAD/RECEIVE/CLAIM/CUSTOMS）                                 | I4 LOAD/UNLOAD 必须关联 Voyage；I5 RECEIVE/CLAIM/CUSTOMS 禁止关联 Voyage                                       | registerHandlingEvent（通过 HandlingEventFactory 创建）                 |
| **Voyage**    | Voyage         | —        | VoyageNumber, Schedule, CarrierMovement                                                 | I6 Schedule 的 CarrierMovement 按时间有序；I7 VoyageNumber 唯一                                                | —（样例中由基础数据加载；生产中应有 createVoyage）                      |
| **Location**  | Location       | —        | UnLocode                                                                                | I8 UnLocode 符合 5 字母 UN/LOCODE 规范                                                                         | —（基础数据）                                                           |

> **关键观察**：Itinerary、RouteSpecification、Delivery、HandlingActivity、Leg、TrackingId、UnLocode、VoyageNumber 全部为**不可变值对象**。样例显式偏好 VO > Entity > Event。

## 不变量表（完整）

| 编号 | 不变量                                                                                  | 触发命令                               | 校验位置                         | 违反时行为                                               |
| :--- | :-------------------------------------------------------------------------------------- | :------------------------------------- | :------------------------------- | :------------------------------------------------------- |
| I1   | Cargo 起点在创建后永不变更（即使 RouteSpec 改变）                                         | bookNewCargo, specifyNewRoute          | Cargo 构造器                     | 约束固化在构造器，无法违反                               |
| I2   | Delivery 永远由 (RouteSpec, Itinerary, HandlingHistory) 推导得出，不可被外部直接赋值     | specifyNewRoute, assignToRoute, deriveDeliveryProgress | Cargo 聚合根                     | 模型上禁止暴露 setter；生产中违反 = 状态可被伪造         |
| I3   | RouteSpecification.origin ≠ destination                                                 | new RouteSpecification                 | RouteSpecification 构造器         | 抛出 IllegalArgumentException                            |
| I4   | HandlingEvent.Type ∈ {LOAD, UNLOAD} ⇒ voyage 必须非空                                    | HandlingEventFactory.createHandlingEvent | HandlingEvent 构造器（双重构造） | 抛出 IllegalArgumentException                            |
| I5   | HandlingEvent.Type ∈ {RECEIVE, CLAIM, CUSTOMS} ⇒ voyage 必须为空                          | 同上                                   | 同上                             | 抛出 IllegalArgumentException                            |
| I6   | RouteSpecification.isSatisfiedBy(Itinerary): 起点相同、终点相同、deadline 严格晚于终到日期 | assignToRoute                          | RouteSpecification                | 返回 false → RoutingStatus=MISROUTED                     |
| I7   | VoyageNumber / TrackingId / UnLocode 在系统内唯一                                         | 各聚合的创建                           | 各 VO 构造器 + 仓储              | 违反唯一性 → 仓储拒绝                                    |
| I8   | Cargo 聚合与 HandlingEvent 聚合跨聚合引用必须通过 ID（TrackingId），不得持有对方对象引用 | 任何跨聚合交互                         | 模型约定 + 仓储接口              | 违反 → 死锁/性能退化（ADR-1 已说明）                     |

## 实体与值对象清单

| 名称                | 类型   | 所属聚合    | 标识策略 / 相等性                                                            |
| :------------------ | :----- | :---------- | :--------------------------------------------------------------------------- |
| Cargo               | Entity | Cargo       | 标识 = trackingId；sameIdentityAs                                             |
| HandlingEvent       | DomainEvent (身份+不可变) | HandlingEvent | 身份 = (cargo, voyage, completionTime, location, type) 组合；sameEventAs |
| Voyage              | Entity | Voyage      | 标识 = VoyageNumber                                                           |
| Location            | Entity | Location    | 标识 = UnLocode                                                               |
| TrackingId          | VO     | Cargo       | 按 value 相等                                                                 |
| RouteSpecification  | VO     | Cargo       | 按 (origin, destination, arrivalDeadline) 三元组相等                          |
| Itinerary           | VO     | Cargo       | 按 legs 列表相等                                                              |
| Leg                 | VO     | Cargo       | 按 (voyage, loadLoc, unloadLoc, loadTime, unloadTime) 相等                    |
| Delivery            | VO     | Cargo       | 整体替换而非修改                                                              |
| TransportStatus     | VO(enum) | Cargo     | NOT_RECEIVED / IN_PORT / ONBOARD_CARRIER / CLAIMED / UNKNOWN                  |
| RoutingStatus       | VO(enum) | Cargo     | NOT_ROUTED / ROUTED / MISROUTED                                               |
| HandlingActivity    | VO     | Cargo       | (Type, Location, Voyage?) 三元组                                              |
| HandlingEvent.Type  | VO(enum) | HandlingEvent | LOAD / UNLOAD / RECEIVE / CLAIM / CUSTOMS                                   |
| VoyageNumber        | VO     | Voyage      | 按字符串相等                                                                  |
| Schedule            | VO     | Voyage      | 按 CarrierMovement 列表相等                                                   |
| CarrierMovement     | VO     | Voyage      | 按 (from, to, depart, arrive) 相等                                            |
| UnLocode            | VO     | Location    | 按 5 字母码相等                                                               |

## 事务边界说明

- **默认规则**：一个事务只修改一个聚合。
- **Cargo 的同步更新**（assignToRoute/specifyNewRoute）与**异步更新**（deriveDeliveryProgress from HandlingHistory）共存：前者在 Cargo 事务内完成，后者由 HandlingEvent 注册成功后的应用层事件（`cargoWasHandled`）触发，跨聚合最终一致。
- 并发控制：样例使用 Hibernate + 乐观锁（隐式，未在代码中显式标注）。

## 跨聚合一致性策略

| 场景                                     | 触发事件                 | 补偿 / 重试                                            | 幂等保障                                                 |
| :--------------------------------------- | :----------------------- | :----------------------------------------------------- | :------------------------------------------------------- |
| HandlingEvent 登记 → Cargo 重算 Delivery | CargoWasHandled          | 应用层事件机制（样例用 JMS；测试用 SynchronousStub）   | HandlingEvent 身份五元组天然幂等；重放时 Delivery 重算结果相同 |
| Cargo 偏离 Itinerary                     | CargoWasMisdirected      | 通知相关人员 → 触发重新规划航线                         | 由 CargoInspectionService 在 inspectCargo 中一次性判断    |
| Cargo 到达终点                           | CargoHasArrived          | 通知客户 → 等待 CLAIM 事件                              | 同上                                                     |

## 仓储接口草案（期望）

| 聚合          | 方法                                                                                | 语义                                   | 查询边界             |
| :------------ | :---------------------------------------------------------------------------------- | :------------------------------------- | :------------------- |
| Cargo         | `find(TrackingId): Cargo`、`store(Cargo)`、`findAll(): List<Cargo>`、`nextTrackingId()` | 按身份查/存                            | 仅返回 Cargo 聚合根  |
| HandlingEvent | `store(HandlingEvent)`、`lookupHandlingHistoryOfCargo(TrackingId): HandlingHistory`    | 仅提供 store 与按 TrackingId 查历史    | **不提供 CRUD 通用接口** |
| Voyage        | `find(VoyageNumber): Voyage`                                                        | 按身份查                                | —                    |
| Location      | `find(UnLocode): Location`、`findAll(): List<Location>`                              | 按身份查；基础数据                     | —                    |

> **评分关键点**：HandlingEventRepository **不应**有通用 CRUD；若 skill 输出了 `delete`/`update` 方法，扣分。
