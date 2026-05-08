# Scoring Rubric — Cargo Skills Validation

> 目的：对 `validation-cases/cargo-validation/01`~`08` 的 blind 产出，与 `reference/` 真值进行 1:1 对比打分。
> 方法：每个 skill 按固定维度给分；记录命中、漏项、误判、主动加分项。

## 打分标度（每维度）

- **4 = 优秀**：完全命中真值要点 + 有额外合理洞察
- **3 = 达标**：命中要点 ≥ 80%，漏项均为次要
- **2 = 可用**：命中 60%–80%，有明显漏项或一处误判
- **1 = 薄弱**：命中 < 60%，存在影响后续阶段的缺陷
- **0 = 缺失**：未产出或完全跑偏

## 加权

| 阶段     | Skill                   |   权重   |
| :------- | :---------------------- | :------: |
| I        | ddd-scope               |   1.0    |
| I        | ddd-discover            |   1.5    |
| II       | ddd-subdomains          |   1.0    |
| II       | ddd-contexts            |   1.5    |
| II       | ddd-context-map         |   1.5    |
| III      | ddd-aggregates          |   2.0    |
| III      | ddd-domain-interactions |   1.5    |
| IV       | ddd-model-review        |   1.0    |
| **合计** | —                       | **11.0** |

加权总分 = Σ(skill 得分 × 权重) / (4 × Σ权重) × 100%

## 关键比对锚点（摘自真值）

| 锚点   | 真值要求                                                                               | 检查点           |
| :----- | :------------------------------------------------------------------------------------- | :--------------- |
| A1     | 4 聚合根：Cargo、HandlingEvent、Voyage、Location                                       | 06 是否全部覆盖  |
| A2     | HandlingEvent 独立聚合（ADR-1 性能理由）                                               | 06 + 05 是否说明 |
| A3     | Delivery 为推导 VO，禁止 setter                                                        | 06 的 I-4/5      |
| A4     | I4/I5：LOAD/UNLOAD 要 voyage；RECEIVE/CLAIM/CUSTOMS 禁止 voyage                        | 06 是否覆盖      |
| A5     | HandlingEvent 身份 = 五元组 (cargo, voyage, completionTime, location, type)            | 06 判重键        |
| A6     | RoutingService 是**领域服务接口**（Domain），ExternalRoutingService 是**基础设施 ACL** | 07 与 05         |
| A7     | Routing 是外部 BC，Booking→Routing 用 ACL + Customer-Supplier                          | 04/05            |
| A8     | HandlingEvent 是跨上下文 Published Language                                            | 05               |
| A9     | RouteSpec.isSatisfiedBy(Itinerary) 作为 Specification 模式                             | 06               |
| A10    | CargoInspectionService 订阅 CargoWasHandled → 派生 misdirected/arrived                 | 07               |
| A11    | 主路径 + 错卸重规划路径 16 步事件流                                                    | 02               |
| A12    | 4+ 个 BC：Booking / Handling / Tracking / Routing                                      | 04               |
| B-加分 | 识别 Billing/Customer/Carrier 缺失                                                     | 05/08            |
| B-加分 | 识别 HandlingEvent/HandlingActivity/TransportStatus 语义重叠                           | 08               |
| B-扣分 | HandlingEventRepository 出现通用 CRUD                                                  | 06/07            |
| B-扣分 | RoutingService 实现塞进领域层                                                          | 07               |
| B-扣分 | Routing 放进 Booking 内、未设 ACL                                                      | 04/05            |
| B-扣分 | Delivery 可 setter / 非推导                                                            | 06               |

## 评分规则

- **A 类锚点**全部 hit 达到 3 分；hit ≥ 80% 但命名不同仍记 hit。
- 命中 `B-加分`：总分 +2% 上限
- 命中 `B-扣分`：总分 -5%/项
- 术语差异（如 Shipment vs Cargo、HandlingFact vs HandlingEvent、Route vs Itinerary、PortCode vs UnLocode）**不扣分**；语义对齐即可，记为"术语漂移"统计。

## 输出

详细逐 skill 打分见 [scorecard.md](./scorecard.md)。
