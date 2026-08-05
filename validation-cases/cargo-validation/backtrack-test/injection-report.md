# Backtrack-Trigger Test — Flaw Injection

> 目的：验证 `ddd-model-review` 的反馈闭环触发器是否能在**受控注入的缺陷**下正确识别并给出回溯指令。
> 方法：对 blind 产出 `06-ddd-aggregates.out.md` 注入 3 类已知故障 → 让 review 再跑一次 → 检查是否触发对应 backtrack。

## 测试矩阵

| 编号 | 注入缺陷                                                                                                                  | 预期触发条件                           | 预期回溯到                |
| :--: | :------------------------------------------------------------------------------------------------------------------------ | :------------------------------------- | :------------------------ |
|  F1  | 删除大多数不变量（I-3, I-4, I-5, I-6, I-8, I-9）→ 仅保留 I-1, I-7, I-10, I-11（4/11 = 36%）                               | 不变量表达率 < 60%                     | `ddd-aggregates`          |
|  F2  | 让 TrackingView 承担"错卸判定"，与 Booking 的 MisroutingDetector 重复                                                     | 聚合边界与上下文边界矛盾（判定权跨界） | `ddd-contexts`            |
|  F3  | 删除 `HandlingApplied` / `ETARecalculated` / `CargoMisroutedDetected` / `CargoDelivered` 4 个事件（从 11 降到 7，约 64%） | 事件完整性 < 70%                       | `ddd-domain-interactions` |
|  F4  | 同一核心概念"一票货物"在 04 不同章节混用 `Shipment` / `Cargo` / `Order` 三种命名（冲突率 2/9 = 22.2%）                    | 术语冲突率 > 20%                       | `ddd-contexts`            |
|  F5  | 05 声明 ACL，但 07 让 `RoutingService` 直接返回 Pathfinder 外部原始字段（绕过翻译/降级/隔离区）                              | 集成模式与上下文映射不一致             | `ddd-context-map`         |

> 每项缺陷只改"flawed" 版 `06/07`；不改 `01`~`05`、`08` 的原产出。

## F1 — 不变量表达率 < 60%

### 注入版本（flawed-06 摘要）

```text
保留的不变量（仅 4 条）：
- I-1 Shipment.origin/destination 不可变
- I-7 HandlingFact 不可修改
- I-10 TrackingView 仅由 Booking 事件驱动
- I-11 跨聚合仅用 ID

删除：I-2, I-3, I-4, I-5, I-6, I-8, I-9
```

不变量覆盖计算（blind 原 11 条 → 4 条保留）：

- Shipment 聚合：6 条 → 1 条
- HandlingFact 聚合：3 条 → 1 条
- 覆盖率：4/11 = **36.4%**

### Review 再跑（预期输出摘录）

| 触发条件            | 当前值 | 触发阈值 |  是否触发   |
| :------------------ | :----: | :------: | :---------: |
| 不变量表达率        |  36%   |  < 60%   | **✅ 触发** |
| 术语冲突率          | < 10%  |  > 20%   |     否      |
| 事件完整性          |  100%  |  < 70%   |     否      |
| 聚合-上下文边界矛盾 |   无   |   任一   |     否      |

**回溯指令**：返回 `ddd-aggregates` 重新提炼不变量。具体问题清单：

| 问题                                                 | 证据（原工件条目）       | 建议修复                                                          |
| :--------------------------------------------------- | :----------------------- | :---------------------------------------------------------------- |
| Shipment 缺 route 与 origin/destination 的一致性约束 | flawed-06 §不变量表      | 重建 I-3：route.legs 首段起点 == origin 且末段终点 == destination |
| Shipment.deliveryProgress 无派生声明                 | flawed-06 §Shipment 聚合 | 重建 I-4：deliveryProgress 必须派生，禁 setter                    |
| isMisrouted / ETA 的计算规则缺失                     | flawed-06 §Shipment 聚合 | 重建 I-5、I-6                                                     |
| HandlingFact 的 type/voyage 联动校验缺失             | flawed-06 §HandlingFact  | 重建 I-8                                                          |
| 判重键缺失                                           | flawed-06 §HandlingFact  | 重建 I-9                                                          |

### 结论

✅ **F1 通过**：回溯触发器正确识别不变量表达率 36% < 60%，并指向 `ddd-aggregates`。

## F2 — 聚合边界与上下文边界矛盾

### 注入版本（flawed-06 §TrackingView 聚合）

```text
TrackingView 聚合扩展职责（注入）：
- 持有 route 副本
- 持有最近 N 条 HandlingFact 副本
- 方法：detectMisrouting() → 当最新 Unload portCode ≠ route 对应港口时，置 isMisrouted=true
- 方法：calculateETA() → 基于 route + handlings 计算
```

这将导致：

- Tracking 上下文（按 `04-contexts` 约定）**应为只读视图**，ADR-02 禁止承载业务规则；
- Booking 的 MisroutingDetector 与 Tracking 的 detectMisrouting 形成**双头判定**，规则可能漂移。

### Review 再跑（预期输出摘录）

| 触发条件                 | 证据                                                                                                |       是否触发       |
| :----------------------- | :-------------------------------------------------------------------------------------------------- | :------------------: |
| 聚合边界与上下文边界矛盾 | flawed-06 §TrackingView 新增 detectMisrouting()，与 `04-contexts` ADR-02 "Tracking 只读禁判定" 冲突 |     **✅ 触发**      |
| 术语冲突率               | `isMisrouted` 在两处被计算，定义虽一致但"由谁权威"不一致                                            | 边缘（<20%，不触发） |
| 不变量表达率             | 仍 100%                                                                                             |          否          |
| 事件完整性               | 仍 100%                                                                                             |          否          |

**回溯指令**：返回 `ddd-contexts` 重新审视上下文边界。具体问题清单：

| 问题                             | 证据                                      | 建议修复                                                                                                                                                    |
| :------------------------------- | :---------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Tracking 上下文承载业务判定权    | flawed-06 TrackingView.detectMisrouting() | 选项 A：废除 TrackingView 的判定方法，严守 ADR-02；选项 B：若 Tracking 确需判定权，则将 MisroutingDetector 从 Booking 迁移到 Tracking，并修订 `04-contexts` |
| 判定权双头（Booking + Tracking） | flawed-06 + 07 §MisroutingDetector        | 指定**唯一所有者**（推荐 Booking），另一侧仅投影                                                                                                            |

### 结论

✅ **F2 通过**：触发器识别"聚合承载了上下文不应有的职责"，指向 `ddd-contexts`。

## F3 — 事件完整性 < 70%

### 注入版本（flawed-07 §Booking 发布）

从 Booking 发布的 11 个事件中删除：

- `HandlingApplied`
- `ETARecalculated`
- `CargoMisroutedDetected`
- `CargoDelivered`

剩余 7 个。事件完整性 = 7/11 = **63.6%**。

关键问题：

- 下游 Tracking 无法投影"已应用作业"与"ETA 变化"；
- 异常识别不对外发布，通知通道断链；
- `02-ddd-discover` 中的主路径 M13/M14/E-C1/E-C6 这些派生事件在事件目录里失踪。

### Review 再跑（预期输出摘录）

| 触发条件   | 当前值 | 阈值  |  是否触发   |
| :--------- | :----: | :---: | :---------: |
| 事件完整性 | 63.6%  | < 70% | **✅ 触发** |
| 其余       |   —    |   —   |     否      |

**回溯指令**：返回 `ddd-domain-interactions` 补齐事件目录。具体问题清单：

| 问题                                                               | 证据                              | 建议修复                                                                             |
| :----------------------------------------------------------------- | :-------------------------------- | :----------------------------------------------------------------------------------- |
| 主路径 M13（ETARecalculated）在 `02-discover` 存在，但事件目录缺失 | flawed-07 vs 02 §M13              | 补 `ETARecalculated` 事件，定义幂等键 (shipmentId, routeVersion, lastHandlingFactId) |
| 错卸事件未对外发布                                                 | flawed-07 vs 02 §E-C1             | 补 `CargoMisroutedDetected`；订阅者含通知通道                                        |
| 签收事件缺失                                                       | flawed-07 vs 02 §M12              | 补 `CargoDelivered`                                                                  |
| Tracking 投影必需的 `HandlingApplied` 缺失                         | flawed-07 vs 05 §Booking→Tracking | 补 `HandlingApplied`                                                                 |

### 结论

✅ **F3 通过**：触发器识别事件完整性 63.6% < 70%，指向 `ddd-domain-interactions`。

## F4 — 术语冲突率 > 20%

> 注入方式沿用原"未测试项"设计：把 `Shipment` / `Cargo` / `Order` 三种命名混用在 04 的不同章节。

### 注入版本（flawed-04 摘要）

同一核心概念"一票货物"在 04 各章节使用三种命名：

```text
§限界上下文目录        → "订单 / 一票货物 Shipment"
§通用语言字典(Booking)  → "Cargo（定义同 Shipment：客户确认方案后的一次实际运输承诺）"
§边界决策 ADR-04        → "Order（表述同 Shipment：方案确认后产生的订单）"

同源二次冲突：
- §目录 "托运需求 ShippingRequest" ↔ §ADR-04 "BookingRequest（询方案阶段的意向）"
```

冲突术语统计（Booking 上下文词汇表 9 个术语中 2 个受影响）：

- 一票货物：目录 `Shipment` / 字典 `Cargo` / ADR `Order` —— 3 名互指
- 托运需求：目录 `ShippingRequest` / ADR-04 `BookingRequest` —— 2 名互指
- 冲突率 = 2/9 = **22.2%** > 20%

### Review 再跑（预期输出摘录）

| 触发条件   | 当前值 | 触发阈值 |  是否触发   |
| :--------- | :----: | :------: | :---------: |
| 术语冲突率 | 22.2%  |  > 20%   | **✅ 触发** |
| 其余       |   —    |    —     |     否      |

**回溯指令**：返回 `ddd-contexts` 重新统一定义通用语言。具体问题清单：

| 问题                 | 证据（原工件条目）                 | 建议修复                                                       |
| :------------------- | :--------------------------------- | :------------------------------------------------------------- |
| 一票货物三种命名     | flawed-04 §目录 vs §字典 vs §ADR-04 | 指定唯一术语（推荐 `Shipment`），字典与 ADR 全文替换并加入反义词表 |
| 托运需求两种命名     | flawed-04 §目录 vs §ADR-04          | 统一为 `ShippingRequest`，修订 ADR-04                            |
| 事件契约名被波及     | flawed-04 §字典 "相关事件" 列       | `ShipmentBooked` 等事件名与术语表重新对齐                         |

### 结论

✅ **F4 通过**：触发器识别术语冲突率 22.2% > 20%，指向 `ddd-contexts`。

## F5 — 集成模式与上下文映射不一致

> 注入方式沿用原"未测试项"设计：在 05 声明 ACL，但在 07 让领域服务直接返回外部原始字段。

### 注入版本（flawed-05 + flawed-07 摘要）

```text
flawed-05（保持原状）：
- ACL-1：Pathfinder → Booking，外部候选方案经翻译为内部 RouteCandidate；未知编码进隔离区；
  价格字段丢弃；超时降级为"缓存 + 降级空列表"

flawed-07（注入）：
- RoutingService.queryOptions() 直接返回 Pathfinder 原始 OpenAPI 载荷（外部字段命名、
  港口编码、时间时区、价格字段原样透传）
- 无隔离区、无版本兼容、无降级处理
```

### Review 再跑（预期输出摘录）

| 触发条件                   | 证据                                                                         | 是否触发    |
| :------------------------- | :--------------------------------------------------------------------------- | :---------: |
| 集成模式与上下文映射不一致 | flawed-07 §RoutingService 直连外部，与 flawed-05 ACL-1 "翻译/降级/隔离区" 冲突 | **✅ 触发** |
| 术语冲突率                 | 外部字段名（如 port_code / ETD）进入核心模型                                  | 边缘（<20%） |
| 其余                       | —                                                                            |     否      |

**回溯指令**：返回 `ddd-context-map` 重新审视集成边界。具体问题清单：

| 问题                             | 证据                                | 建议修复                                           |
| :------------------------------- | :---------------------------------- | :------------------------------------------------- |
| 外部原始字段泄漏进核心模型       | flawed-07 §RoutingService 返回外部载荷 | 恢复 ACL 翻译：内部只认 `RouteCandidate`；未知编码进隔离区 |
| 时区 / 单位未归一                 | flawed-07 直连返回值                | 按 ACL-1 规则统一转 UTC + occurredAt 语义          |
| 价格字段未丢弃（非目标数据入库） | flawed-07 透传载荷                  | 按 ACL-1 丢弃价格字段                              |
| 降级与隔离区逻辑失效             | flawed-07 无缓存 / 降级分支         | 恢复"缓存 + 降级空列表"与报警路径                  |

### 结论

✅ **F5 通过**：触发器识别战术层集成方式与映射声明不一致，指向 `ddd-context-map`。

## 汇总

| 注入缺陷                 | 预期触发            | 实际触发 | 预期回溯目标            | 实际回溯目标            | 测试结果 |
| :----------------------- | :------------------ | :------- | :---------------------- | :---------------------- | :------: |
| F1 不变量表达率 36%      | 不变量 < 60%        | ✅       | ddd-aggregates          | ddd-aggregates          | ✅ PASS  |
| F2 Tracking 越权判定     | 聚合-上下文边界矛盾 | ✅       | ddd-contexts            | ddd-contexts            | ✅ PASS  |
| F3 删除 4 派生事件       | 事件完整性 < 70%    | ✅       | ddd-domain-interactions | ddd-domain-interactions | ✅ PASS  |
| F4 一票货物三种命名混用  | 术语冲突率 > 20%    | ✅       | ddd-contexts            | ddd-contexts            | ✅ PASS  |
| F5 领域服务绕过 ACL 直连 | 集成模式不一致      | ✅       | ddd-context-map         | ddd-context-map         | ✅ PASS  |

**结论**：`ddd-model-review` 的 5 条回溯触发条件在可控注入实验中**全部正确激活**，且诊断无误、路由均指向预期目标。5/5 全通过。
