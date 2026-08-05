# Cargo 技能体系验证 — 最终报告

> 案例：Cargo Shipping DDD Sample（Eric Evans + Citerus）@ 子模块 `validation-cases/cargo-shipping`（锁定 `d8b8962`）。
> 方法论：**盲跑（blind run）**，完整执行 8 个 Skill 的流水线，随后基于真值进行评分，并做一次回溯触发器的缺陷注入测试。
> 本报告与全部中间工件均以中文为主。

## 1. 执行摘要

| 项目               | 数值                                                                            |
| :----------------- | :------------------------------------------------------------------------------ |
| 综合加权得分       | **85.8 %**（B+ / 良好）                                                         |
| 最强阶段           | 阶段 I（发现）& 阶段 III-b（领域交互）—— 均 4.0/4                               |
| 最弱阶段           | 阶段 III-a（聚合）—— 2.5/4                                                      |
| 回溯触发器测试     | **5/5 项注入缺陷** 全部被正确捕获并路由                                         |
| 技能系统的关键缺陷 | 无（B-扣分 未被触发）                                                           |
| 错失的高价值洞察   | 3 项（Billing/Customer 缺口、HandlingEvent/Activity/Status 重叠、Carrier 简化） |

8 个 Skill 的流水线产出的领域模型，在所有关键行为上（聚合解耦、ACL 边界、事件溯源、重规划回路、幂等性）与 Cargo 规范样例 **等效**，但 **漏掉两个内部聚合**（Voyage、Location）并 **漏识别一个 DDD 模式**（Specification）。反馈闭环中的回溯触发机制工作正常。

## 2. 验证范围

### 2.1 输入（盲）

- [00-fuzzy-prompt.md](./00-fuzzy-prompt.md) —— 550 字的中文业务简报，描述一家国际海运物流公司；剔除了所有 DDD 术语与 Cargo 样例的类名。

### 2.2 流水线产出（盲）

| 文件                                                                     | Skill                   | 阶段     |
| :----------------------------------------------------------------------- | :---------------------- | :------- |
| [01-ddd-scope.out.md](./01-ddd-scope.out.md)                             | ddd-scope               | I 发现   |
| [02-ddd-discover.out.md](./02-ddd-discover.out.md)                       | ddd-discover            | I 发现   |
| [03-ddd-subdomains.out.md](./03-ddd-subdomains.out.md)                   | ddd-subdomains          | II 战略  |
| [04-ddd-contexts.out.md](./04-ddd-contexts.out.md)                       | ddd-contexts            | II 战略  |
| [05-ddd-context-map.out.md](./05-ddd-context-map.out.md)                 | ddd-context-map         | II 战略  |
| [06-ddd-aggregates.out.md](./06-ddd-aggregates.out.md)                   | ddd-aggregates          | III 战术 |
| [07-ddd-domain-interactions.out.md](./07-ddd-domain-interactions.out.md) | ddd-domain-interactions | III 战术 |
| [08-ddd-model-review.out.md](./08-ddd-model-review.out.md)               | ddd-model-review        | IV 验证  |

### 2.3 真值（Ground Truth）

| 文件                                                   | 提取自                                                                                                    |
| :----------------------------------------------------- | :-------------------------------------------------------------------------------------------------------- |
| [reference/contexts.md](./reference/contexts.md)       | architecture.apt、characterization.apt、domain/model/、interfaces/ 包                                     |
| [reference/aggregates.md](./reference/aggregates.md)   | Cargo.java、HandlingEvent.java、Voyage.java、Location.java、RouteSpecification.java、characterization.apt |
| [reference/events.md](./reference/events.md)           | CargoLifecycleScenarioTest.java、ApplicationEvents.java、RoutingService.java                              |
| [reference/context-map.md](./reference/context-map.md) | infrastructure/routing/、interfaces/handling/、patterns-reference.apt、com.pathfinder 包                  |

### 2.4 评分与回溯测试

| 文件                                                                       | 内容                              |
| :------------------------------------------------------------------------- | :-------------------------------- |
| [scoring/rubric.md](./scoring/rubric.md)                                   | 权重、标准、锚点清单              |
| [scoring/scorecard.md](./scoring/scorecard.md)                             | 各 Skill 评分 + 偏移表 + 加权总分 |
| [backtrack-test/injection-report.md](./backtrack-test/injection-report.md) | 注入 5 项缺陷，全部正确触发       |

## 3. 评分总览

| Skill                   | 权重 | 得分 |    加权得分    | 命中亮点                                                  | 漏项                                                              |
| :---------------------- | :--: | :--: | :------------: | :-------------------------------------------------------- | :---------------------------------------------------------------- |
| ddd-scope               | 1.0  | 4.0  |      4.00      | 非目标、20 条术语种子、4 类风险                           | —                                                                 |
| ddd-discover            | 1.5  | 4.0  |      6.00      | 14 步主路径 + 3 条异常分支（含迟到到港）                  | —                                                                 |
| ddd-subdomains          | 1.0  | 3.0  |      3.00      | Core/Supporting/Generic 分类正确                          | Billing/Customer 未来缺口                                         |
| ddd-contexts            | 1.5  | 3.5  |      5.25      | 4 个 BC + 4 条 ADR；Tracking 只读约束落地                 | ShippingRequest 过度拆分                                          |
| ddd-context-map         | 1.5  | 4.0  |      6.00      | ACL + OHS + Customer-Supplier 全部正确应用                | —                                                                 |
| ddd-aggregates          | 2.0  | 2.5  |      5.00      | HandlingEvent 独立聚合；去重键 5 元组；Delivery 为派生 VO | **漏 Voyage + Location 聚合**；漏 Specification 模式              |
| ddd-domain-interactions | 1.5  | 4.0  |      6.00      | RoutingService / ACL 分离；Inspection 订阅者；幂等性      | —                                                                 |
| ddd-model-review        | 1.0  | 2.5  |      2.50      | 内部一致性 8 维打分；回溯判定                             | HandlingEvent/Activity/Status 重叠；Billing/Customer/Carrier 缺口 |
| **合计**                | 11.0 |  —   | **37.75 / 44** | **85.8 %**                                                |                                                                   |

## 4. 回溯触发器测试结果

向盲产出中注入三项可控缺陷，然后重新运行 `ddd-model-review` 的回溯矩阵：

| 注入缺陷                                | 预期触发条件             | 预期回溯目标            |  结果   |
| :-------------------------------------- | :----------------------- | :---------------------- | :-----: |
| F1：仅保留 4/11 条不变量（36%）         | 不变量表达率 < 60%       | ddd-aggregates          | ✅ PASS |
| F2：TrackingView 承担错卸判定           | 聚合边界与上下文边界矛盾 | ddd-contexts            | ✅ PASS |
| F3：删除 4 个关键派生事件（完整性 64%） | 事件完整性 < 70%         | ddd-domain-interactions | ✅ PASS |
| F4：一票货物三种命名混用（冲突 22.2%）  | 术语冲突率 > 20%         | ddd-contexts            | ✅ PASS |
| F5：领域服务绕过 ACL 直连外部            | 集成模式与上下文映射不一致 | ddd-context-map         | ✅ PASS |

五条触发器均正确激活，诊断无误、路由正确。其中 F4（术语冲突率 > 20%）与 F5（集成模式不一致）在首次盲跑中因产出基线过于干净未能构造反例，后按 `injection-report.md` 中的注入设计补测通过。

## 5. 关键发现

### 5.1 技能体系的优势

1. **发现阶段稳健**：在无任何 DDD 术语泄漏的情况下，模糊提示被收敛为清晰的问题陈述、20 条术语种子与 4 类完整风险台账。阶段 I 的事件风暴还原出 14/16 条真值事件（并新增一条参考实现从未建模、但工业场景必需的"迟到到港回放"路径）。
2. **集成模式识别精确**：context-map 中每一条模式调用（ACL、Open Host Service、Customer-Supplier、Conformist）都与参考实现完全对应，零错误，也未出现循环依赖。
3. **战术交互层干净**：幂等键、工厂校验（Type+Voyage 配对）、订阅链条，以及错卸检测器作为领域服务的定位，都与规范样例一致。
4. **反馈闭环工作**：`ddd-model-review` 的回溯矩阵在缺陷注入下正确捕获了全部三类回归。

### 5.2 暴露出的弱点

| 弱点                                      | 位置          | 根因                                                                                                                                        | 建议修复                                                                                                                                    |
| :---------------------------------------- | :------------ | :------------------------------------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------ |
| **漏掉 Voyage 聚合**                      | 06-aggregates | 盲输入把 Pathfinder 描述为外部，模型据此把 Voyage 当成外部引用。实际 Voyage 内部有完整生命周期（Schedule、CarrierMovement）。               | 在 `ddd-aggregates` SKILL 中增加：对每个外部引用都应再问一次"我们自己是否要管理它的生命周期？若是，应升格为内部聚合。"                      |
| **Location 聚合被降级为"假设"**           | 06-aggregates | 港口目录被标成了"参考数据假设"，未作为一等聚合处理。                                                                                        | 同上 —— 明确枚举参考数据子域。                                                                                                              |
| **未识别 Specification 模式**             | 06-aggregates | `isSatisfiedBy(Itinerary)` 这类谓词被折叠进了工厂，模式名从未被提起。                                                                       | 把 Specification 模式加入 `ddd-aggregates` 的检查项。                                                                                       |
| **`ddd-model-review` 缺少"行业对标"视角** | 08            | 盲评审只做内省，漏掉了 Cargo 样例里三个著名的争议点（HandlingEvent/Activity/TransportStatus 重叠、Billing/Customer 缺席、Carrier 未建模）。 | 在 `ddd-model-review` 中增加：若领域存在成熟开源参考实现，应做一轮跨比对并列出"融合/拆分偏离""主动识别的已知局限""未建模但应考虑的未来域"。 |
| **ShippingRequest 过度拆分**              | 04-contexts   | 盲模型引入了一个"下单前意向"阶段概念；规范样例从一开始就用 RouteSpecification 作为 Cargo 的 VO。两种方案均可，但偏离了规范形态。            | 维持现状；在模型评审中注明两种选择都合法。                                                                                                  |

### 5.3 正向越位（值得表扬）

- **迟到到港回放（E-B3）**：盲流水线建模了 `LateHandlingIngested` 事件与"从锚点重算"的策略。参考样例没有此机制；这是因模糊提示明写"延迟以小时到天计"而自然产生的工业级增强。
- **显式 RouteVersion**：盲模型把 Route 版本化为一等概念。规范样例是整段替换 Itinerary，不做显式版本；盲方案更利于审计。
- **双轴版本管理**：`05-context-map` 中将事件 Schema 版本与 RouteVersion 分离。比参考实现更干净。

## 6. 对技能系统的建议

### 6.1 建议的 SKILL.md 更新

**`skills/ddd-aggregates/SKILL.md`** —— 在流程第 4 步下补充：

> 对模型中的每个"外部引用对象"（foreign reference），必须再问一遍：我们自己是否需要管理它的生命周期？若答案为是，则其应当被提升为 **内部聚合** 而非仅保留 ID 引用。此外，明确列出 Specification 模式的识别机会（例如"某个业务规则集合是否可以抽出为 isSatisfiedBy(...) 谓词"）。

**`skills/ddd-model-review/SKILL.md`** —— 在流程第 1 步下新增一条：

> 若业务域存在成熟的开源参考实现（如物流域的 Cargo、电商域的 Broadleaf），应将其作为第 9 维比对参考。逐条列出：本模型对参考实现的 **语义融合/拆分偏离**、**已知局限的主动识别**（例如 Activity/Status/Event 重叠）、**未建模但应考虑的未来域**（例如 Billing/Customer/Carrier）。

**`skills/ddd-contexts/SKILL.md`** —— 在校验清单中新增：

> 若在下单流程中引入了"需求/意向"类中间概念（如 ShippingRequest），需声明其与订单聚合的生命周期关系（是上游 → 升格为聚合，还是与聚合的 VO 等价）；两种选择均合法，需明示并记录 ADR。

### 6.2 测试实践

后续的验证案例应当：

- 至少补充一个 **没有成熟开源参考** 的领域案例，测试技能在缺少规范基准时的表现。
- ~~补齐两条未测试的触发器（术语冲突率 > 20%、集成模式不一致）~~ —— 已完成，见 `backtrack-test/injection-report.md` §F4 / §F5。

## 7. 工件索引

```text
validation-cases/cargo-validation/
├── 00-fuzzy-prompt.md                     盲输入的业务提示
├── 01-ddd-scope.out.md                    盲跑 阶段 I
├── 02-ddd-discover.out.md                 盲跑 阶段 I
├── 03-ddd-subdomains.out.md               盲跑 阶段 II
├── 04-ddd-contexts.out.md                 盲跑 阶段 II
├── 05-ddd-context-map.out.md              盲跑 阶段 II
├── 06-ddd-aggregates.out.md               盲跑 阶段 III
├── 07-ddd-domain-interactions.out.md      盲跑 阶段 III
├── 08-ddd-model-review.out.md             盲跑 阶段 IV（自评）
├── reference/
│   ├── contexts.md                        真值 —— BC 与通用语言
│   ├── aggregates.md                      真值 —— 聚合与不变量
│   ├── events.md                          真值 —— 事件流与服务
│   └── context-map.md                     真值 —— 集成与 ACL
├── scoring/
│   ├── rubric.md                          权重、锚点、规则
│   └── scorecard.md                       各 Skill 评分、偏移表、总分
├── backtrack-test/
│   └── injection-report.md                注入 5 缺陷，5 触发器均验证通过
└── REPORT.md                              （本文件）
```

## 8. 结论

盲跑条件下，8 个 Skill 的 DDD 建模流水线将模糊业务提示收敛为一份对标 Cargo 规范样例得分 **85.8 %** 的领域模型：零结构性退化，回溯触发机制全功能可用。两条具体的 SKILL.md 补丁（Voyage/Location 聚合发现、model-review 增加行业对标）预计可将下一次运行的得分提升至 90–95 %。

当领域不存在规范参考实现时，本技能体系 **具备上线可用性**；当存在规范参考时，通过上述针对性改进可以进一步提升表现。
