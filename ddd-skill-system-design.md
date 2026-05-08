# 领域驱动设计体系主干设计

开源生态提供了大量单点能力，但团队真正需要的是一条可重复的 DDD 交付链路：从需求澄清到战略边界、从战术模型到工程落地，并最终用体检评分与整改路线形成持续演进闭环。为此，本仓库在 `skills/` 下补充了一组 `ddd-*` 自研 Skill 作为体系主干，将关键阶段的输入、输出与验收口径统一，并允许在每个阶段按需挂接外部 Skill 做增强。

## 1. 阶段闭环与技能映射

领域驱动设计的落地是一个从宏观到微观的渐进过程。下表展示了从需求输入到架构体检的 7 个标准阶段（阶段 0 至 6），明确了每个阶段的核心交付物，并指定了对应的自研体系主干 Skill 与可用于增强特性的外部 Skill。

| 阶段 | 目标与关键输出                                       | 体系主干 Skill                                                                                    | 可选增强（外部 Skill）                                                                         |
| :--- | :--------------------------------------------------- | :------------------------------------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------- |
| 0    | 范围收敛、约束与风险、术语候选                       | `ddd-intake-scope`                                                                                | `microservices-architect`（拆分动因与约束梳理）                                                |
| 1    | 事件流、命令/事件候选、歧义清单                      | `ddd-event-storming-lite`                                                                         | `ddd-planning`（事件风暴支持与模板化输出）                                                     |
| 2    | 子域分类、限界上下文目录、通用语言词汇表             | `ddd-subdomain-classification`, `ddd-bounded-context-catalog`, `ddd-ubiquitous-language-glossary` | `ddd-strategic-design`（战略工件强化）                                                         |
| 3    | 上下文映射、契约所有权、ACL 翻译、失败模式与版本策略 | `ddd-context-map-contracts`                                                                       | `ddd-context-mapping`（集成模式与契约定义强化）                                                |
| 4    | 聚合边界、不变量、领域事件目录、跨聚合一致性策略     | `ddd-aggregate-design`, `ddd-domain-events-catalog`                                               | `domain-driven-design`（战术建模框架与常见错误检查）                                           |
| 5    | 依赖方向体检、重构切片路线、测试策略与严格断言规则   | `ddd-architecture-dependency-rule-check`, `ddd-testing-strategy`                                  | `clean-architecture`, `unit-test-ddd`, `arch-ddd`, `fastapi-ddd-guidelines`, `cleanddd-skills` |
| 6    | 体系化评分、问题清单、可切片整改路线与复测口径       | `ddd-healthcheck-scorecard`                                                                       | `clean-architecture`（评分机制补强与改造建议）                                                 |

## 2. 参考资料与 Skill 映射

为支撑后续对 `skills/ddd-*` 自研体系主干的持续优化，本节将 `ddd-crew/free-ddd-learning-resources` 中的免费学习资料固化为可复用引用清单，并给出每条资料可直接补强的 Skill 与章节位置，确保改动可追溯、可复用、可分批迭代。

### 2.1 引用清单（带元数据）

为了确保理论来源的权威性与全面性，以下清单收集了领域驱动设计领域的经典著作、实践指南与案例研究。这些文献涵盖了战略设计、协作建模与战术落地等多个维度，构成了后续优化体系主干的知识底座。

| ID  | 主题                    | 题名                                                      | 类型          | 作者/组织                            | 年份 | 链接                                                                                                          |
| :-- | :---------------------- | :-------------------------------------------------------- | :------------ | :----------------------------------- | :--- | :------------------------------------------------------------------------------------------------------------ |
| R01 | Fundamentals            | Domain-Driven Design Reference                            | EBook (PDF)   | Eric Evans                           | 2015 | https://domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf                               |
| R02 | Fundamentals            | Domain-Driven Design Quickly                              | EBook         | Abel Avram, Floyd Marinescu          |      | https://www.infoq.com/minibooks/domain-driven-design-quickly/                                                 |
| R03 | Fundamentals            | DDD: The First 15 Years                                   | EBook         | Various Authors                      |      | https://leanpub.com/ddd_first_15_years                                                                        |
| R04 | Fundamentals            | The Anatomy of Domain-Driven Design                       | EBook         | Scott Millett, Samuel Knight         |      | https://leanpub.com/theanatomyofdomain-drivendesign                                                           |
| R05 | Fundamentals            | Domain-Driven Design                                      | Article       | Martin Fowler                        |      | https://martinfowler.com/bliki/DomainDrivenDesign.html                                                        |
| R06 | Fundamentals            | Domain-driven design needn't be hard. Here's how to start | Article       | Thoughtworks (Andrew Hamel-law)      |      | https://www.thoughtworks.com/insights/blog/domain-driven-design-neednt-be-hard-heres-how-start                |
| R07 | Process                 | DDD Starter Modelling Process                             | Repo          | `ddd-crew`                           |      | https://github.com/ddd-crew/ddd-starter-modelling-process                                                     |
| R08 | Fundamentals            | What is DDD?                                              | Video         | Eric Evans                           |      | https://www.youtube.com/watch?v=pMuiVlnGqjk                                                                   |
| R09 | Fundamentals            | Tackling Complexity in the Heart of Software              | Video         | Eric Evans                           |      | https://www.youtube.com/watch?v=dnUFEg68ESM                                                                   |
| R10 | Collaborative Modelling | Event Storming                                            | Practice      | Open Practice Library                |      | https://openpracticelibrary.com/practice/event-storming/                                                      |
| R11 | Collaborative Modelling | Domain Storytelling                                       | Practice      | Open Practice Library                |      | https://openpracticelibrary.com/practice/domain-storytelling/                                                 |
| R12 | Collaborative Modelling | 100,000 Orange Stickies Later                             | Video         | Alberto Brandolini                   |      | https://www.youtube.com/watch?v=fGm62ra_mQ8                                                                   |
| R13 | Collaborative Modelling | Awesome EventStorming                                     | Repo          | Mariusz Gil                          |      | https://github.com/mariuszgil/awesome-eventstorming                                                           |
| R14 | Strategic Design        | Bounded Context                                           | Article       | Martin Fowler                        |      | https://martinfowler.com/bliki/BoundedContext.html                                                            |
| R15 | Strategic Design        | Bounded Contexts                                          | Video         | Cyrille Martraire                    |      | https://www.youtube.com/watch?v=ZEJ2Vyk1HA0                                                                   |
| R16 | Strategic Design        | Practical DDD: Bounded Contexts + Events                  | Video         | Indu Alagarsamy                      |      | https://www.youtube.com/watch?v=Nr6jAwOunGM                                                                   |
| R17 | Strategic Design        | Emergent Boundaries                                       | Article/Video | Matthias Verraes                     | 2017 | https://verraes.net/2017/04/emergent-boundaries/                                                              |
| R18 | Strategic Design        | Socio-technical architecture                              | Video         | Ora Egozi Barzilai, Evelyn van Kelle |      | https://www.youtube.com/watch?v=9Ft39wz6fHM                                                                   |
| R19 | Tactical DDD            | All Our Aggregates Are Wrong                              | Video         | Mauro Servienti                      |      | https://www.youtube.com/watch?v=KkzvQSuYd5I                                                                   |
| R20 | Strategic Design        | Aligning organization and architecture with strategic DDD | Slides        | Michael Plöd                         |      | https://speakerdeck.com/mploed/aligning-organization-and-architecture-with-strategic-ddd                      |
| R21 | Strategic Design        | Strategic Domain-Driven Design Kata: Delivericious        | Case Study    | Nick Tune                            |      | https://medium.com/nick-tune-tech-strategy-blog/strategic-domain-driven-design-kata-delivericious-b114ca77163 |
| R22 | Tactical DDD            | Architecture Patterns with Python                         | EBook         | Harry Percival, Bob Gregory          |      | http://www.cosmicpython.com                                                                                   |
| R23 | Tactical DDD            | Aggregates & Entities in Domain-Driven Design             | Article       | Paul Rayner                          |      | http://thepaulrayner.com/blog/aggregates-and-entities-in-domain-driven-design/                                |
| R24 | Tactical DDD            | Strengthening your domain: a primer                       | Article       | Jimmy Bogard                         | 2010 | https://lostechies.com/jimmybogard/2010/02/04/strengthening-your-domain-a-primer/                             |
| R25 | Tactical DDD            | Domain Modeling Made Functional                           | Video         | Scott Wlaschin                       |      | https://www.youtube.com/watch?v=1pSH8kElmM4                                                                   |
| R26 | Tactical DDD            | Design in the small                                       | Video         | Yves Reynhout                        |      | https://www.youtube.com/watch?v=3iLW4puXHvc                                                                   |
| R27 | Engineering             | Refactoring for DDD Without Microservicing Your Monolith  | Video         | Harry Brumleve                       |      | https://www.youtube.com/watch?v=y2mL-6CcYBw                                                                   |
| R28 | Tactical DDD            | DDD By Examples                                           | Repo          | Jakub Pilimon, Bartłomiej Słota      |      | https://github.com/ddd-by-examples/library                                                                    |
| R29 | Case Study              | 10 Lessons from a Long Running DDD Project (Part 1)       | Article       | Jimmy Bogard                         | 2016 | https://lostechies.com/jimmybogard/2016/06/13/10-lessons-from-a-long-running-ddd-project-part-1/              |
| R30 | Case Study              | OOps I DDD it again and again                             | Slides        | Ora Egozi-Barzilai                   |      | https://www.slideshare.net/OraEgoziBarzilai/mucon-2019-oops-i-ddd-it-again-and-again                          |

### 2.2 引用 → 自研 Skill/章节的改造映射（建议 Backlog）

将外部知识转化为可执行的工程规范是体系演进的关键。下表建立了从理论文献到具体 Skill 改造点的直接映射，根据业务价值与基础缺失程度划分了优先级（P0 至 P2），为后续的技能迭代提供了清晰的执行积压工作（Backlog）。

| 引用 ID | 优先级 | 目标 Skill                               | 目标章节                | 建议改动点                                                                                 |
| :------ | :----- | :--------------------------------------- | :---------------------- | :----------------------------------------------------------------------------------------- |
| R07     | P0     | `ddd-intake-scope`                       | 流程 / 输出 / 校验清单  | 引入“非线性、可回环”的建模过程原则；增加“何时回到上一阶段”的触发条件与产物验收口径。       |
| R10     | P0     | `ddd-event-storming-lite`                | 输入要求 / 流程 / 输出  | 补齐 `Event Storming` 标准步骤与参与角色；将异常流、热点标注、歧义处理固化为输出字段。     |
| R12     | P1     | `ddd-event-storming-lite`                | 常见陷阱                | 增补大规模协作建模的典型失败模式：主持节奏、贴纸语义一致性、分歧收敛与会后沉淀。           |
| R14     | P0     | `ddd-bounded-context-catalog`            | 流程 / 校验清单         | 强化 `Bounded Context` 的语言边界与模型边界；增加“非职责”与“数据所有权冲突”检查项。        |
| R20     | P0     | `ddd-bounded-context-catalog`            | 输出 / 常见陷阱         | 引入组织与架构对齐视角：团队边界、Owner、决策权；补齐“边界不随团队演进”的风险提示。        |
| R21     | P1     | `ddd-subdomain-classification`           | 输出 / 示例             | 提供可复用的 `Kata` 演练方式与输出模板；将练习产物映射到子域分类表与核心域声明。           |
| R11     | P2     | `ddd-ubiquitous-language-glossary`       | 流程 / 输出             | 引入 `Domain Storytelling` 的叙事视角，强化“角色-动作-对象”对术语归属与定义的约束。        |
| R23     | P0     | `ddd-aggregate-design`                   | 流程 / 校验清单         | 把聚合划分的核心原则显式化：不变量、事务边界、跨聚合引用；增加“以外键划聚合”的反例检查。   |
| R19     | P0     | `ddd-aggregate-design`                   | 常见陷阱                | 增补“聚合普遍划错”的反模式集合与纠偏步骤：拆小一致性边界、事件驱动最终一致、补偿策略。     |
| R22     | P1     | `ddd-architecture-dependency-rule-check` | 输出 / 重构切片路线     | 增加 Python 领域建模与工程结构的对齐建议：仓储、UoW、服务层边界的依赖规则清单。            |
| R27     | P0     | `ddd-architecture-dependency-rule-check` | 重构切片路线            | 引入“棕地 DDD 重构但不强拆微服务”的切片策略：先立边界与反腐层，再抽离依赖，再逐步拆分。    |
| R24     | P1     | `ddd-testing-strategy`                   | 严格验证规则 / 常见陷阱 | 强化领域模型的“强度”要求：不变量测试优先；补齐错误示例与最低可接受断言粒度。               |
| R29     | P2     | `ddd-healthcheck-scorecard`              | 问题清单 / 整改路线     | 抽取长期项目经验的共性问题：边界漂移、事件泛滥、测试退化；沉淀为评分扣分项与整改建议模板。 |
