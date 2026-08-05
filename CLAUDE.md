# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **DDD Skill Aggregation Repository** — a hub for Domain-Driven Design AI Agent Skills. It combines:

- **In-house system backbone** (`skills/`) — 9 self-developed `ddd-*` skills forming a 5-stage DDD modeling & specification pipeline
- **External open-source references** — 20+ ecosystem DDD skills researched and documented (README ecosystem table, `docs/ddd-skills-report.md`); no longer bundled as submodules

Status: WIP. License: Apache 2.0. Documentation is Chinese-primary with English `.en.md` mirrors.

**Design boundary**: covers domain modeling (strategic + tactical) and specification bridging (OpenSpec). It does **not** generate business code and does **not** prescribe a tech stack.

## Commands

There is **no build system, linter, or test suite** — this is a documentation/specification repository; the primary artifacts are `SKILL.md` files. The only commands are git submodule operations:

```bash
# Clone with all submodules (only validation-cases/cargo-shipping remains)
git clone --recurse-submodules <repo-url>

# Initialize the ground-truth submodule after clone
git submodule update --init --recursive
```

## Architecture

### Directory Structure

```text
skills/              → In-house system backbone (9 skills, 5 stages)
validation-cases/    → E2E validation methodology + completed cases (cargo-validation)
docs/                → Design documents (bilingual)
```

External ecosystem skills are documented as references (README table, `docs/ddd-skills-report.md`) but are not distributed in this repository.

### 5-Stage DDD Modeling Pipeline (In-House Backbone)

| Stage           | Skill                     | Purpose                                                               |
| --------------- | ------------------------- | --------------------------------------------------------------------- |
| I Discovery     | `ddd-scope`               | Converge fuzzy requirements into modeling inputs                      |
| I Discovery     | `ddd-discover`            | Collaborative domain discovery (event storming / domain storytelling) |
| II Strategic    | `ddd-subdomains`          | Identify capabilities, classify subdomains (core/supporting/generic)  |
| II Strategic    | `ddd-contexts`            | Design bounded contexts with their ubiquitous language                |
| II Strategic    | `ddd-context-map`         | Map inter-context relationships and integration patterns              |
| III Tactical    | `ddd-aggregates`          | Aggregate design from invariants: roots, entities, value objects      |
| III Tactical    | `ddd-domain-interactions` | Events, domain services, repository interfaces, factories             |
| IV Validation   | `ddd-model-review`        | Holistic model quality assessment with feedback loop triggers         |
| V Specification | `ddd-openspec-bridge`     | Bridge tactical models to OpenSpec structured specifications          |

### Non-Linear Feedback Loops

Stages are NOT strictly sequential. Each skill ends with explicit **backtrack triggers** ("回溯触发" section) that route back to upstream skills when quality gates fail (e.g., invariant expression rate < 60% → return to `ddd-aggregates`; terminology conflict rate > 20% → return to `ddd-contexts`). The trigger matrix is documented in Appendix B of `docs/ddd-skill-system-design.md`. When editing one skill's triggers, check they stay consistent with what upstream skills declare.

### SKILL.md Interface Contract

Every in-house skill follows a mandatory structure:

1. **YAML frontmatter** — `name`, `description`, `risk`, `source`, `tags`, `date_added` (English files additionally have `lang: en`)
2. **Sections** — 使用时机 (Usage Timing), 输入要求 (Input Requirements), 流程 (Process), 输出 (Output, a table), 校验清单 (Validation Checklist), 回溯触发 (Backtrack Triggers), 示例 (Example)

Skills are invoked via `@skill-name` syntax in agent conversations; artifacts of one skill feed the next.

### Validation Methodology (`validation-cases/`)

The 6-step blind-run process validates the pipeline objectively (see `validation-cases/README.md`):

1. Construct a fuzzy business prompt (no DDD terms, no reference class names) → `00-fuzzy-prompt.md`
2. Blind-run the skills (stages I–IV; the insurance-validation case additionally runs 09 `ddd-openspec-bridge`, stage V) → `NN-ddd-<skill>.out.md`, reading only upstream artifacts
3. Extract ground truth from the reference implementation into `reference/` (contexts/aggregates/events/context-map) — **never before blind run completes**
4. Score against `scoring/rubric.md` (weights, A-class anchors, B-class ±points) → `scoring/scorecard.md`
5. Inject controlled defects (`backtrack-test/injection-report.md`) to verify backtrack triggers fire and route correctly
6. Produce `REPORT.md` with a mandatory 8-section structure

Cargo validation (against Citerus dddsample-core submodule) currently scores **85.8%**; its findings feed SKILL.md improvements (feedback loop). To start a new case, follow section 5 of `validation-cases/README.md`.

## Conventions

- Skill directories use kebab-case: `ddd-<skill-name>`
- Domain entities/events use PascalCase; events in past tense (e.g., `OrderCreated`)
- All SKILL.md outputs must be structured as **tables with explicit column requirements**
- Every skill must have validation checklists and backtrack triggers
- Code identifiers and DDD pattern names use English; prose is Chinese

### Bilingual Convention

- Chinese originals live at default paths (`SKILL.md`, `README.md`, `docs/*.md`); English translations use the `.en.md` suffix (`SKILL.en.md`, `README.en.md`, `docs/ddd-skill-system-design.en.md`)
- Every Chinese file carries a language switcher line linking to its English counterpart and vice versa: `> 🌐 English version: [English](SKILL.en.md)` / `> 🌐 中文版本: [Chinese](SKILL.md)`
- In `SKILL.en.md` frontmatter, `name`, `tags`, `risk`, `source`, `date_added` stay identical to the Chinese original; `description` is translated; `lang: en` is added
- Internal links in English files point to other `.en.md` files; links to out-of-scope targets (e.g., submodule content) are annotated `(in Chinese)`
- Excluded from bilingual treatment: `AGENTS.md` (English-only) and `LICENSE`

## Key Documents

- `README.md` / `README.en.md` — hub documentation with skill selection guides and submodule management
- `docs/ddd-skill-system-design.md` — system design: 5-stage model, dependency graph, trigger-recycle matrix (Appendix B), example (Appendix A)
- `docs/ddd-openspec-mapping.md` — standard definitions for converting DDD tactical artifacts to OpenSpec specifications
- `docs/ddd-skills-report.md` — research report on 20+ DDD skills with evaluation and improvement backlog
- `docs/ddd-pipeline-article.md` — narrative article on the skill pipeline (4-stage / 8-skill first version + Cargo validation conclusions)
