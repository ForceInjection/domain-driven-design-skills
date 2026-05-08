# 03 — ddd-subdomains 产出（Blind Run）

> 输入：`01-ddd-scope.out.md` + `02-ddd-discover.out.md`。
> 本文件为 `ddd-subdomains` 在 blind run 下的模拟执行产出，**未参考** `reference/` 下任何真值材料。

## 能力清单（从事件流与边界线索抽取）

| 能力编号 | 能力名称              | 描述                                             | 主要事件 / 命令                                                                               |
| :------- | :-------------------- | :----------------------------------------------- | :-------------------------------------------------------------------------------------------- |
| C1       | 托运需求受理          | 接收、校验、编号客户托运意图                     | ShippingRequestSubmitted, RequestRejected                                                     |
| C2       | 方案查询与呈现        | 基于起终点与最晚到达时间，获取并呈现候选方案     | QueryRoutingOptions, OptionsPresented                                                         |
| C3       | 订单确认（订舱）      | 客户选定方案后生成一票货物                       | ShipmentBooked, ConfirmBooking                                                                |
| C4       | 路线指派与版本化      | 将选中方案落为可执行路线，支持重指派             | RouteAssigned, RouteReassigned                                                                |
| C5       | 作业事实吸收          | 异步接收多通道作业登记，做幂等+校验+隔离         | RegisterHandling, DuplicateHandlingRejected, InvalidHandlingQuarantined, LateHandlingIngested |
| C6       | 货物状态派生          | 基于作业事实 + 当前路线，推导位置/在途/已卸/已签 | CargoReceivedAtOrigin/Loaded/Unloaded/Arrived/Claimed, TrackingStateRecomputed                |
| C7       | 异常识别（错卸/延迟） | 基于路线计划 vs 实际作业，判定错卸与延迟         | CargoMisroutedDetected                                                                        |
| C8       | 重规划协作            | 错卸或客户变更后，从当前位置到终点重算方案       | ReroutingRequested, AlternativeRoutingQueried, RouteReassigned                                |
| C9       | ETA 计算              | 基于剩余路线估算到达时间                         | ETARecalculated                                                                               |
| C10      | 客户自助查询视图      | 面向客户聚合位置/状态/下一步/ETA 的读模型        | TrackingViewRefreshed, QueryTracking                                                          |
| C11      | 外部作业方集成        | 与外部港口合作方异步通道对接（Web/API/文件）     | —（C5 的集成面）                                                                              |
| C12      | 外部航线提供方集成    | 与第三方航线数据服务对接（防腐层）               | —（C2/C8 的集成面）                                                                           |
| C13      | 客户通知              | 异常与新方案的对外通知                           | CustomerNotifiedOfReroute                                                                     |

## 子域分类

| 子域                                    | 类型                 | 包含能力                         | 分类理由                                                                                 |
| :-------------------------------------- | :------------------- | :------------------------------- | :--------------------------------------------------------------------------------------- |
| **Shipping & Tracking 运输与跟踪**      | **Core**             | C1, C3, C4, C6, C7, C9           | 业务差异化核心：一票货物全生命周期、状态权威推导、错卸判定——竞争力来源，必须自研         |
| **Handling Ingestion 作业事实吸收**     | **Supporting**       | C5, C11                          | 业务上必须（无之则无法驱动状态），但业务规则较稳定、可复用于任何物流公司；自研但非差异化 |
| **Rerouting Orchestration 重规划协作**  | **Core**（边缘核心） | C8                               | "保住客户承诺到达时间"是客户体验差异化点；但 C8 的算法依赖 C12 外部                      |
| **Customer Tracking View 客户查询视图** | **Supporting**       | C10, C13                         | 读模型与通知：高价值但本质是"把核心推导的结果呈现给客户"，不含独特业务逻辑               |
| **Routing / Pathfinding 航线规划**      | **Generic**          | C12（以及 C2/C8 内部的算法部分） | 明确由外部提供方承担，本期不自研                                                         |
| **方案请求受理**                        | **Supporting**       | C2                               | 虽然与 Core 相邻，但"问方案"本质是 C12 的前置编排，不承载业务差异                        |

## 核心域宣告

**核心域：Shipping & Tracking（含 Rerouting Orchestration）。**

### 宣告依据

1. **差异化价值定位**：竞争对手也能调同一批航线提供方，真正的差异化在于——
   - 把一票货物的"当前真实状态"以权威口径持续、准确地推导出来；
   - 在错卸等异常发生时，能快速重新规划并优先保住客户承诺。
2. **业务规则集中度**：事件流中最复杂的规则集中在"状态派生"与"异常识别"上（时间回溯、路线版本对齐、判重），这些是典型的核心域特征。
3. **组织归属对齐**：订舱/客服团队恰好对应该核心域；其稳定性与投入水平可控。
4. **与 Generic 子域的解耦**：航线规划由外部承担，核心域只依赖其"候选方案"契约，不承担航线数据本身的建设——使核心域得以聚焦。

### 非核心域投资策略

- **Handling Ingestion（支撑）**：采用成熟幂等吸收模式，可考虑复用行业通用组件，但入库契约必须由核心域定义。
- **Customer Tracking View（支撑）**：只读派生，禁止承载业务规则；可用成熟查询/缓存技术栈。
- **Routing / Pathfinding（通用）**：完全外部化；内部只建设防腐层。

## 输出

| 工件       | 内容                                                                     |
| :--------- | :----------------------------------------------------------------------- |
| 能力清单   | 13 条（C1–C13）                                                          |
| 子域分类   | 6 个子域；1 个 Core（含 1 个 Core 延伸）+ 3 个 Supporting + 1 个 Generic |
| 核心域声明 | Shipping & Tracking，含重规划协作                                        |

## 校验自检

- [x] 能力清单覆盖所有主路径与异常路径的事件/命令
- [x] 核心 / 支撑 / 通用三类均已出现
- [x] 核心域宣告附带"为什么它是核心"的业务差异化依据
- [x] 与 `ddd-scope` 的非目标一致（未把计费/CRM/船公司调度/仓储误纳入能力清单）
- [x] 结构可被 `ddd-contexts` 直接消费
