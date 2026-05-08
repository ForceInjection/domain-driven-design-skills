# Backtrack-Trigger Test — Flaw Injection

> 目的：验证 `ddd-model-review` 的反馈闭环触发器是否能在**受控注入的缺陷**下正确识别并给出回溯指令。
> 方法：对 blind 产出 `06-ddd-aggregates.out.md` 注入 3 类已知故障 → 让 review 再跑一次 → 检查是否触发对应 backtrack。

## 测试矩阵

| 编号 | 注入缺陷                                                                                                                  | 预期触发条件                           | 预期回溯到                |
| :--: | :------------------------------------------------------------------------------------------------------------------------ | :------------------------------------- | :------------------------ |
|  F1  | 删除大多数不变量（I-3, I-4, I-5, I-6, I-8, I-9）→ 仅保留 I-1, I-7, I-10, I-11（4/11 = 36%）                               | 不变量表达率 < 60%                     | `ddd-aggregates`          |
|  F2  | 让 TrackingView 承担"错卸判定"，与 Booking 的 MisroutingDetector 重复                                                     | 聚合边界与上下文边界矛盾（判定权跨界） | `ddd-contexts`            |
|  F3  | 删除 `HandlingApplied` / `ETARecalculated` / `CargoMisroutedDetected` / `CargoDelivered` 4 个事件（从 11 降到 7，约 64%） | 事件完整性 < 70%                       | `ddd-domain-interactions` |

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

## 汇总

| 注入缺陷             | 预期触发            | 实际触发 | 预期回溯目标            | 实际回溯目标            | 测试结果 |
| :------------------- | :------------------ | :------- | :---------------------- | :---------------------- | :------: |
| F1 不变量表达率 36%  | 不变量 < 60%        | ✅       | ddd-aggregates          | ddd-aggregates          | ✅ PASS  |
| F2 Tracking 越权判定 | 聚合-上下文边界矛盾 | ✅       | ddd-contexts            | ddd-contexts            | ✅ PASS  |
| F3 删除 4 派生事件   | 事件完整性 < 70%    | ✅       | ddd-domain-interactions | ddd-domain-interactions | ✅ PASS  |

**结论**：`ddd-model-review` 的 5 条回溯触发条件中，**3 条**（覆盖 3 类典型缺陷）在可控注入实验中均被正确激活；另两条（术语冲突率、集成模式不一致）因 blind 产出本身术语/映射过于干净，不易构造典型反例，建议后续基于其他案例补测。

## 未测试项（建议后续补）

| 触发条件                   | 为何未测                 | 建议注入方式                                                   |
| :------------------------- | :----------------------- | :------------------------------------------------------------- |
| 术语冲突率 > 20%           | blind 产出术语高度一致   | 把 `Shipment` / `Cargo` / `Order` 三种命名混用在 04 的不同章节 |
| 集成模式与上下文映射不一致 | blind 的 05 已高度结构化 | 在 05 声明 ACL，但在 07 让领域服务直接返回外部原始字段         |
