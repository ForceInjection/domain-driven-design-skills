# 领域驱动设计 (DDD) Skill 全景图

> 聚合主流 DDD 相关 AI Skills，以 Git Submodule 形式统一管理，方便开发者按需引用与追踪更新。

## 快速开始

克隆本仓库并拉取所有子模块：

```bash
git clone --recurse-submodules https://github.com/<your-org>/domain-driven-design-skills.git
```

如果已克隆但未拉取子模块：

```bash
git submodule update --init --recursive
```

## 已收录 Skills

| 设计层级 | Skill 名称 | 子模块路径 | 源仓库 | 简介 |
|---|---|---|---|---|
| **通用战术建模** | `domain-driven-design` | `skills/wondelai-skills` | [wondelai/skills](https://github.com/wondelai/skills) | 通用战术建模工具，聚焦实体、值对象、聚合、领域服务、仓库等模式 |
| **架构风格融合** | `clean-ddd-hexagonal` | `skills/robust-skills` | [ccheney/robust-skills](https://github.com/ccheney/robust-skills) | DDD + 整洁架构 + 六边形架构融合，提供依赖规则决策树 |
| **战略规划设计** | `ddd-strategic-design` | `skills/antigravity-awesome-skills` | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 限界上下文、子域、通用语言、上下文映射等战略设计 |
| **战略规划设计** | `ddd-context-mapping` | `skills/antigravity-awesome-skills` | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 限界上下文之间的集成，防腐层、开放主机服务等模式 |
| **战略规划设计** | `architecture-patterns` | `skills/antigravity-awesome-skills` | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 涵盖整洁架构、六边形架构和 DDD 的综合架构模式集 |
| **技术栈专精** | `arch-ddd` | `skills/aiee-team` | [ai-enhanced-engineer/aiee-team](https://github.com/ai-enhanced-engineer/aiee-team) | Python DDD 架构师，指导领域模型、仓库模式、工作单元等 |
| **技术栈专精** | `ddd-planning` | `skills/claude-skill-registry` | [majiayu000/claude-skill-registry](https://github.com/majiayu000/claude-skill-registry) | Kotlin DDD 规划器，支持 Event Storming 与 Kotlin 代码生成 |
| **特定框架/平台** | `cleanddd-skills` | `skills/cleanddd-skills` | [netcorepal/cleanddd-skills](https://github.com/netcorepal/cleanddd-skills) | Clean DDD 四阶段套件：需求分析 → 建模 → 项目初始化 → 代码实现 |
| **特定框架/平台** | `claude-flow` | `skills/agentic-flow` | [ruvnet/agentic-flow](https://github.com/ruvnet/agentic-flow) | Claude Flow 内核，利用 DDD 构建模块化 AI 代理系统 |
| **特定框架/平台** | `Solon AI Skills` | `skills/solon-ai` | [opensolon/solon-ai](https://github.com/opensolon/solon-ai) | Solon AI 框架，将 Skill 视为自治语义上下文，借鉴 DDD 思想 |
| **重点场景/应用** | `microservices-architect` | `skills/jeffallan-claude-skills` | [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) | 微服务架构师，运用 DDD 限界上下文指导服务拆分，推荐 Saga、CQRS、事件溯源 |
| **生态集散地** | `antigravity-awesome-skills` | `skills/antigravity-awesome-skills` | [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | DDD 技能集散地，一个发布版本包含多个 DDD 相关 Skills |

> **注**：`.NET Tactical DDD` 暂未能找到公开独立的 GitHub 源仓库，后续发现后将补充。

## 子模块目录结构

```
skills/
├── wondelai-skills/          # domain-driven-design
├── robust-skills/            # clean-ddd-hexagonal
├── antigravity-awesome-skills/  # ddd-strategic-design, ddd-context-mapping, architecture-patterns, antigravity-awesome-skills
├── aiee-team/                # arch-ddd
├── claude-skill-registry/    # ddd-planning
├── cleanddd-skills/          # cleanddd-skills
├── agentic-flow/             # claude-flow
├── solon-ai/                 # Solon AI Skills
└── jeffallan-claude-skills/  # microservices-architect
```

## 更新子模块

更新所有子模块到最新版本：

```bash
git submodule update --remote
```

更新指定子模块：

```bash
cd skills/<submodule-name>
git pull origin main
cd ../..
git add skills/<submodule-name>
git commit -m "update: bump <submodule-name> to latest"
```

## 核心选择指南

| 如果你需要…… | 推荐 Skill |
|---|---|
| 辅助编写符合 DDD 风格的代码 | **通用战术建模类** (`domain-driven-design`) |
| 评估或重构现有代码的 DDD 合规性 | **通用战术建模类** (`domain-driven-design`) |
| 设计一个新的、架构清晰的系统 | **架构风格融合类** (`clean-ddd-hexagonal`) |
| 规划或梳理复杂业务的模块与微服务边界 | **战略规划类** (`ddd-strategic-design`, `ddd-context-mapping`) |
| 项目有明确的技术栈偏好 | **技术栈专精类** (`arch-ddd`, `ddd-planning`) |
| 为团队寻找规范化、结构化的 DDD 实施流程 | **特定框架/平台类** (`cleanddd-skills`) |
| 构建复杂的 AI 代理系统 | **特定框架/平台类** (`claude-flow`, `Solon AI Skills`) |

## 相关文档

- [background.md](background.md) — DDD Skills 全景图详细说明

## License

参见 [LICENSE](LICENSE) 文件。
