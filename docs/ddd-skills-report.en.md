# Domain-Driven Design Skills Research Report

> 🌐 中文版本: [Chinese](ddd-skills-report.md)

This document systematically reviews DDD-related AI skills from the open-source ecosystem and local pre-installed resource repositories. Through in-depth analysis of each skill's underlying logic, rule constraints, and actual execution paths, it aims to provide development teams with precise intelligent tooling selection and architectural decision references for complex business modeling, system boundary delineation, and multi-language tactical code implementation.

---

## 1. Strategic Planning & Architecture Design

The strategic planning phase is the core starting point of Domain-Driven Design. Through event storming, domain partitioning, and context mapping, architects can quickly establish clear system boundaries, aligning business requirements with technical implementation at the macro level.

### 1.1 Strategic Modeling & Context Integration

Clarifying complex integration relationships relies on precise context boundary definitions. By establishing interaction contracts such as Anti-Corruption Layers and Open Host Services, development teams can effectively isolate coupling risks between core subdomains and external systems. The following skills focus on macro-level business domain boundary delineation and system integration mapping.

| Skill Name             | Submodule Path                               | Source Repository            | Use Case                                                                                      |
| :--------------------- | :------------------------------------------- | :--------------------------- | :-------------------------------------------------------------------------------------------- |
| `ddd-strategic-design` | `relative-skills/antigravity-awesome-skills` | `antigravity-awesome-skills` | Organizing complex business domains, planning microservice architecture boundaries.           |
| `ddd-context-mapping`  | `relative-skills/antigravity-awesome-skills` | `antigravity-awesome-skills` | Legacy system modernization or multi-business-line system integration design.                 |
| `ddd-planning`         | `relative-skills/claude-skill-registry`      | `claude-skill-registry`      | Aligning cognition between business experts and technical teams during requirements analysis. |

- **`ddd-strategic-design` In-Depth Analysis**:
  This skill focuses on extracting and classifying domain subdomains (core, supporting, generic) and breaking down monolithic architecture domain boundaries. It mandates outputting structured subdomain classification tables, Bounded Context directories, Ubiquitous Language glossaries with anti-pattern terms, and capturing context boundaries through ADRs (Architecture Decision Records) before code implementation. It emphasizes not just technical partitioning but also team ownership alignment with Bounded Contexts.
- **`ddd-context-mapping` In-Depth Analysis**:
  Focuses on relationship mapping and integration contract design between Bounded Contexts. It guides developers in identifying dependency directions and planning integration patterns such as ACL (Anti-Corruption Layer) and Open Host Service. Core outputs include context relationship diagrams, contract ownership matrices, and known coupling risks with mitigation plans — particularly suited for preventing external domain model leakage into core domains.
- **`ddd-planning` In-Depth Analysis**:
  Leveraging a comprehensive skill registry ecosystem, it provides supplementary event storming support and requirements decomposition capabilities, helping teams quickly establish business consensus in early project phases.

### 1.2 Architecture Style Fusion

Domain model implementation must rest on a robust system architecture foundation. Injecting clean architecture or hexagonal architecture core rules into engineering scaffolding ensures business entities remain independent of databases and external interface frameworks. The following skills provide complete architectural support from theoretical principles to scaffold generation.

| Skill Name           | Submodule Path                    | Source Repository | Use Case                                                                      |
| :------------------- | :-------------------------------- | :---------------- | :---------------------------------------------------------------------------- |
| `clean-architecture` | `relative-skills/wondelai-skills` | `wondelai-skills` | Building highly testable, easily evolvable long-term maintenance projects.    |
| `cleanddd-skills`    | `relative-skills/cleanddd-skills` | `cleanddd-skills` | Promoting standardized domain-driven development workflows within .NET teams. |

- **`clean-architecture` In-Depth Analysis**:
  Based on Robert C. Martin's Clean Architecture theory, it provides a strict 0-10 architecture scoring mechanism. It enforces the Dependency Inversion Principle, ensuring inner layers (entities and use cases) never depend on outer layers (frameworks and databases). The skill details concentric circle rules, component cohesion and coupling principles (REP, CCP, CRP, etc.), and uses the Humble Object pattern to guide interface adapter design, completely severing ORM or web framework intrusion into business logic.
- **`cleanddd-skills` In-Depth Analysis**:
  A complete workflow skill set tailored for the .NET platform. It decouples the development process into four coherent sub-skills: requirements decomposition (generating structured event flows), analytical modeling (generating aggregate/command/query/event designs), project initialization (generating scaffolding based on `NetCorePal.Template`), and code implementation. The skill strictly prescribes C# PascalCase naming conventions and file placement conventions, greatly lowering the barrier for DDD adoption in the .NET ecosystem.

---

## 2. Tactical Implementation & Code Generation

Abstract business models need to be concretized through precise code structures. Deep code-level intelligent review and generation tools can directly guide the standardized writing of aggregate roots, value objects, and domain services.

### 2.1 General Tactical Modeling

General-purpose consolidation of object-oriented design principles abstracts away underlying programming language differences. Cross-tech-stack entity identification and repository interface generation capabilities ensure high cohesion of business logic within the domain layer. The following skills are dedicated to mapping business models to standardized code building blocks.

| Skill Name             | Submodule Path                    | Source Repository | Use Case                                                                 |
| :--------------------- | :-------------------------------- | :---------------- | :----------------------------------------------------------------------- |
| `domain-driven-design` | `relative-skills/wondelai-skills` | `wondelai-skills` | Foundational modeling of complex core business logic in backend systems. |

- **`domain-driven-design` In-Depth Analysis**:
  Emphasizes the core philosophy of "model is code," requiring the business Ubiquitous Language to be precisely reflected in class names, method names, and event names. This skill meticulously guides the distinction between entities (with persistent identity) and value objects (fully defined by attributes, immutable), and establishes aggregate roots as absolute consistency boundaries. It also standardizes domain event temporal naming and cross-context decoupling strategies, combined with repository and factory patterns, ensuring business logic is insulated from infrastructure layer code contamination.

### 2.2 Specific Tech Stack Specialization

Mainstream programming languages have accumulated distinctly different implementation paradigms in engineering practice. Deep binding with Python, Java, or other language features provides developers with out-of-the-box experiences aligned with native framework ecosystems. The following skills focus on tactical design and testing standards for specific backend tech stacks.

| Skill Name               | Submodule Path                          | Source Repository                | Use Case                                                         |
| :----------------------- | :-------------------------------------- | :------------------------------- | :--------------------------------------------------------------- |
| `arch-ddd`               | `relative-skills/aiee-team`             | `ai-enhanced-engineer/aiee-team` | Python backend service refactoring or greenfield projects.       |
| `fastapi-ddd-guidelines` | `relative-skills/claude-skill-registry` | `claude-skill-registry`          | Microservice development based on Python FastAPI.                |
| `unit-test-ddd`          | `relative-skills/claude-skill-registry` | `claude-skill-registry`          | Improving test coverage for Spring Boot domain model core logic. |

- **`arch-ddd` In-Depth Analysis**:
  Proposes four tactical pillars for Python: pure domain models, repository pattern, service layer (use case orchestration and transaction boundaries), and Unit of Work pattern (managing atomic operations). It also provides a service partitioning decision framework based on domain ownership and data ownership, guiding functional attribution in microservice architectures.
- **`fastapi-ddd-guidelines` In-Depth Analysis**:
  An architectural guide deeply integrated with FastAPI features. It clearly prescribes dependency directions for the `domain/application/infrastructure/controller` four-layer structure. Its core highlight is integrating Pydantic, SQLAlchemy (SQLModel), and Alembic usage standards, mandating single-request-single-session management through FastAPI's `Depends` mechanism.
- **`unit-test-ddd` In-Depth Analysis**:
  DDD unit testing standards for Spring Boot with JUnit5+Mockito. It mandates AAA (Arrange-Act-Assert) pattern and "Fail Fast" strict verification principles. It prohibits omitting assertions for DTO fields, mock invocation counts, and exception side effects in tests, and absolutely forbids service layers from directly returning entity objects. Its extremely strict naming rules ensure the test suite serves as living documentation.

---

## 3. Infrastructure & Intelligent Agent Frameworks

The design philosophy of high cohesion and low coupling is permeating into AI engineering. Introducing concepts like Bounded Context into intelligent agent architecture systems provides robust infrastructure for handling multimodal context and state transitions.

### 3.1 Agent Workflows & Underlying Kernel

Multi-step task orchestration requires systems with extremely strong state management capabilities. Encapsulating agent execution state and long-term memory as aggregate roots grants complex intelligent modules a high degree of autonomy and extensibility. The following frameworks demonstrate how to integrate system architecture design thinking into the AI agent ecosystem.

| Skill Name     | Submodule Path                 | Source Repository | Use Case                                                                 |
| :------------- | :----------------------------- | :---------------- | :----------------------------------------------------------------------- |
| `agentic-flow` | `relative-skills/agentic-flow` | `agentic-flow`    | Developing multi-step, strongly context-dependent complex agent systems. |
| `solon-ai`     | `relative-skills/solon-ai`     | `solon-ai`        | Building high-cohesion intelligent skill ecosystem components in Java.   |

- **`agentic-flow` In-Depth Analysis**:
  A highly mature production-grade AI agent orchestration framework. It includes built-in SONA (Self-Optimizing Neural Architecture) and AgentDB, supporting ultra-low-latency pattern learning and Graph Neural Network (GNN) query optimization. The framework implements multi-agent coordination consensus mechanisms based on Flash Attention and Hyperbolic Attention (such as Byzantine fault tolerance and Raft protocol), and includes 66 self-learning professional agents, demonstrating strong autonomy and collaboration capabilities in complex agent networks.
- **`solon-ai` In-Depth Analysis**:
  An LLM and RAG application development framework based on the Java ecosystem. Its architectural design exhibits strong extensibility and constraint enforcement, seamlessly integrating LLM calls (ChatModel), prompt engineering, MCP protocol, and agent orchestration into the Solon system. It supports dynamic skill admission mechanisms and directive injection, and through graph-driven orchestration patterns, transforms agent ReAct (reflective reasoning) and TeamAgent (team collaboration) into observable, governable computational flow graphs — an ideal foundation for enterprise-grade AI business process orchestration.

---

## 4. In-House Backbone Skills

To form a repeatable DDD delivery pipeline, we designed a set of in-house backbone skills under `skills/`. For detailed design of stage closures and skill mapping, please refer to the independent design document: [ddd-skill-system-design.en.md](ddd-skill-system-design.en.md).

---

## 5. Research Conclusions

The current DDD skills ecosystem has formed a complete chain from macro strategy to micro code to AI-native infrastructure. Strategic planning skills greatly reduce communication costs between domain experts and developers while clarifying system boundaries; tactical implementation skills deeply integrate with Python, C#, Java, and other language features, ensuring rich domain model implementation through strict architectural rules and testing standards; and the emergence of `agentic-flow` and `solon-ai` marks the successful penetration of modular, loosely-coupled architectural thinking into the engineering practice of complex multi-agent collaborative systems. Teams can precisely adopt the above skill libraries according to their project phase and tech stack preferences to significantly improve development efficiency.

---
