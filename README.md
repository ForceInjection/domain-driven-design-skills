# 领域驱动设计 (DDD) Skill 全景图

> ⚠️ **Work In Progress (WIP)**: 本仓库及其自研体系主干目前正处于积极建设与持续迭代中，部分结构、文档与规范可能随时会发生调整。
>
> 聚合主流 DDD 相关 AI Skill，以 Git Submodule 形式统一管理，方便开发者按需引用与追踪更新。

## 快速开始

克隆本仓库并拉取所有子模块：

```bash
git clone --recurse-submodules https://github.com/<your-org>/domain-driven-design-skills.git
```

如果已克隆但未拉取子模块：

```bash
git submodule update --init --recursive
```

## 已收录 Skill

本项目收录了开源生态中极具代表性的领域驱动设计相关技能，并结合本仓库自研的体系主干，形成了覆盖从战略规划到代码落地的完整工具链。以下表格详细列出了各技能的来源、路径与核心功能。

| 设计层级          | Skill 名称                               | 子模块路径                                      | 源仓库                                                                                      | 简介                                                                     |
| ----------------- | ---------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| **体系主干**      | `ddd-intake-scope`                       | `skills/ddd-intake-scope`                       | 本仓库自研                                                                                  | 范围收敛：目标/非目标、约束、术语候选、风险与下一步准备清单              |
| **体系主干**      | `ddd-event-storming-lite`                | `skills/ddd-event-storming-lite`                | 本仓库自研                                                                                  | 轻量事件风暴：事件流、命令/事件候选、热点与歧义清单                      |
| **体系主干**      | `ddd-subdomain-classification`           | `skills/ddd-subdomain-classification`           | 本仓库自研                                                                                  | 子域分类：核心/支撑/通用 + 核心域声明与团队所有权建议                    |
| **体系主干**      | `ddd-bounded-context-catalog`            | `skills/ddd-bounded-context-catalog`            | 本仓库自研                                                                                  | 上下文目录：职责、边界 ADR、数据所有权与词汇表骨架                       |
| **体系主干**      | `ddd-ubiquitous-language-glossary`       | `skills/ddd-ubiquitous-language-glossary`       | 本仓库自研                                                                                  | 通用语言：定义、同义词、反术语、上下文归属与冲突处理                     |
| **体系主干**      | `ddd-context-map-contracts`              | `skills/ddd-context-map-contracts`              | 本仓库自研                                                                                  | 上下文映射：ACL/OHS/PL 等模式、契约所有权、失败模式与版本策略            |
| **体系主干**      | `ddd-aggregate-design`                   | `skills/ddd-aggregate-design`                   | 本仓库自研                                                                                  | 聚合设计：不变量、命令边界、事务边界与跨聚合一致性策略                   |
| **体系主干**      | `ddd-domain-events-catalog`              | `skills/ddd-domain-events-catalog`              | 本仓库自研                                                                                  | 事件目录：领域/集成事件、订阅者、副作用、幂等/重放与版本策略             |
| **体系主干**      | `ddd-architecture-dependency-rule-check` | `skills/ddd-architecture-dependency-rule-check` | 本仓库自研                                                                                  | 依赖规则体检：违规定位、0-10 评分与可切片重构路线                        |
| **体系主干**      | `ddd-testing-strategy`                   | `skills/ddd-testing-strategy`                   | 本仓库自研                                                                                  | 测试策略：用例清单、命名规约、严格断言与副作用验证（Fail Fast）          |
| **体系主干**      | `ddd-healthcheck-scorecard`              | `skills/ddd-healthcheck-scorecard`              | 本仓库自研                                                                                  | DDD 体检：战略/集成/战术/工程/测试评分 + 问题清单与整改路线              |
| **通用战术建模**  | `domain-driven-design`                   | `relative-skills/wondelai-skills`               | [wondelai/skills](https://github.com/wondelai/skills)                                       | 通用战术建模工具，聚焦实体、值对象、聚合、领域服务、仓库等模式           |
| **架构风格融合**  | `clean-ddd-hexagonal`                    | `relative-skills/robust-skills`                 | [ccheney/robust-skills](https://github.com/ccheney/robust-skills)                           | DDD + 整洁架构 + 六边形架构融合，提供依赖规则决策树                      |
| **战略规划设计**  | `ddd-strategic-design`                   | `relative-skills/antigravity-awesome-skills`    | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 限界上下文、子域、通用语言、上下文映射等战略设计                         |
| **战略规划设计**  | `ddd-context-mapping`                    | `relative-skills/antigravity-awesome-skills`    | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 限界上下文之间的集成，防腐层、开放主机服务等模式                         |
| **战略规划设计**  | `architecture-patterns`                  | `relative-skills/antigravity-awesome-skills`    | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 涵盖整洁架构、六边形架构和 DDD 的综合架构模式集                          |
| **技术栈专精**    | `arch-ddd`                               | `relative-skills/aiee-team`                     | [ai-enhanced-engineer/aiee-team](https://github.com/ai-enhanced-engineer/aiee-team)         | Python DDD 架构师，指导领域模型、仓库模式、工作单元等                    |
| **技术栈专精**    | `ddd-planning`                           | `relative-skills/claude-skill-registry`         | [majiayu000/claude-skill-registry](https://github.com/majiayu000/claude-skill-registry)     | Kotlin DDD 规划器，支持 Event Storming 与 Kotlin 代码生成                |
| **特定框架/平台** | `cleanddd-skills`                        | `relative-skills/cleanddd-skills`               | [netcorepal/cleanddd-skills](https://github.com/netcorepal/cleanddd-skills)                 | Clean DDD 四阶段套件：需求分析 → 建模 → 项目初始化 → 代码实现            |
| **特定框架/平台** | `claude-flow`                            | `relative-skills/agentic-flow`                  | [ruvnet/agentic-flow](https://github.com/ruvnet/agentic-flow)                               | Claude Flow 内核，利用 DDD 构建模块化 AI 代理系统                        |
| **特定框架/平台** | `Solon AI Skills`                        | `relative-skills/solon-ai`                      | [opensolon/solon-ai](https://github.com/opensolon/solon-ai)                                 | Solon AI 框架，将 Skill 视为自治语义上下文，借鉴 DDD 思想                |
| **重点场景/应用** | `microservices-architect`                | `relative-skills/jeffallan-claude-skills`       | [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills)                       | 微服务架构师，运用 DDD 限界上下文指导服务拆分，推荐 Saga、CQRS、事件溯源 |
| **生态集散地**    | `antigravity-awesome-skills`             | `relative-skills/antigravity-awesome-skills`    | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | DDD 技能集散地，一个发布版本包含多个 DDD 相关 Skill                      |

> **注**：`.NET Tactical DDD` 暂未能找到公开独立的 GitHub 源仓库，后续发现后将补充。

## 子模块目录结构

为了清晰区分外部引用与自研资产，本仓库采用双层目录结构：`relative-skills/` 用于存放外部开源仓库子模块，`skills/` 用于存放本仓库自研的体系主干。

```text
relative-skills/
├── wondelai-skills/            # domain-driven-design
├── robust-skills/              # clean-ddd-hexagonal
├── antigravity-awesome-skills/ # ddd-strategic-design, ddd-context-mapping, architecture-patterns
├── aiee-team/                  # arch-ddd
├── claude-skill-registry/      # ddd-planning, fastapi-ddd-guidelines, unit-test-ddd
├── cleanddd-skills/            # cleanddd-skills
├── agentic-flow/               # claude-flow
├── solon-ai/                   # Solon AI Skills
└── jeffallan-claude-skills/    # microservices-architect

skills/
├── ddd-intake-scope/
├── ddd-event-storming-lite/
├── ddd-subdomain-classification/
├── ddd-bounded-context-catalog/
├── ddd-ubiquitous-language-glossary/
├── ddd-context-map-contracts/
├── ddd-aggregate-design/
├── ddd-domain-events-catalog/
├── ddd-architecture-dependency-rule-check/
├── ddd-testing-strategy/
└── ddd-healthcheck-scorecard/
```

## 更新子模块

子模块的独立版本控制特性允许我们随时获取开源社区的最新进展。以下是更新所有子模块或特定子模块的标准操作流程。

更新所有子模块到最新版本：

```bash
git submodule update --remote
```

更新指定子模块：

```bash
cd relative-skills/<submodule-name>
git pull origin main
cd ../..
git add relative-skills/<submodule-name>
git commit -m "update: bump <submodule-name> to latest"
```

## 核心选择指南

面对众多的技能库，开发者可以根据当前项目所处的阶段、技术栈偏好以及团队面临的具体痛点，参考下表快速定位最合适的工具。

| 如果你需要……                              | 推荐 Skill                                                     |
| ----------------------------------------- | -------------------------------------------------------------- |
| 按 DDD 阶段产出标准化工件并闭环到工程落地 | **体系主干**（`skills/` 下的 `ddd-*`）                         |
| 辅助编写符合 DDD 风格的代码               | **通用战术建模类** (`domain-driven-design`)                    |
| 评估或重构现有代码的 DDD 合规性           | **通用战术建模类** (`domain-driven-design`)                    |
| 设计一个新的、架构清晰的系统              | **架构风格融合类** (`clean-ddd-hexagonal`)                     |
| 规划或梳理复杂业务的模块与微服务边界      | **战略规划类** (`ddd-strategic-design`, `ddd-context-mapping`) |
| 项目有明确的技术栈偏好                    | **技术栈专精类** (`arch-ddd`, `ddd-planning`)                  |
| 为团队寻找规范化、结构化的 DDD 实施流程   | **特定框架/平台类** (`cleanddd-skills`)                        |
| 构建复杂的 AI 代理系统                    | **特定框架/平台类** (`claude-flow`, `Solon AI Skills`)         |

## 按阶段使用（体系主干）

当你希望把 DDD 从“讨论”推进到“可交付工件 + 可执行工程决策”时，优先从体系主干开始，然后在每个阶段按需引入外部 Skill 增强能力。

| 阶段 | 目标                 | 体系主干 Skill                                                                                    |
| ---- | -------------------- | ------------------------------------------------------------------------------------------------- |
| 0    | 范围收敛与风险识别   | `ddd-intake-scope`                                                                                |
| 1    | 事件风暴与流程对齐   | `ddd-event-storming-lite`                                                                         |
| 2    | 子域/上下文/通用语言 | `ddd-subdomain-classification`, `ddd-bounded-context-catalog`, `ddd-ubiquitous-language-glossary` |
| 3    | 集成映射与契约治理   | `ddd-context-map-contracts`                                                                       |
| 4    | 聚合与领域事件       | `ddd-aggregate-design`, `ddd-domain-events-catalog`                                               |
| 5    | 依赖规则与测试策略   | `ddd-architecture-dependency-rule-check`, `ddd-testing-strategy`                                  |
| 6    | 体检评分与整改路线   | `ddd-healthcheck-scorecard`                                                                       |

## 相关文档

- [ddd-skill-system-design.md](ddd-skill-system-design.md) — 领域驱动设计自研体系主干设计文档
- [ddd-skills-report.md](ddd-skills-report.md) — 领域驱动设计技能调研报告（含引用与改进 Backlog）
