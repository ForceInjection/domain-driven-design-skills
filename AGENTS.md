# AGENTS.md

This file provides guidance to Qoder (qoder.com) when working with code in this repository.

## Project Overview

This is a **DDD Skill Aggregation Repository** — a unified hub for Domain-Driven Design AI Agent Skills. It combines:

- **In-house system backbone** (`skills/`) — 8 self-developed skills forming a 4-stage DDD modeling pipeline
- **External open-source modules** (`relative-skills/`) — 9 git submodules with 20+ DDD skills from the ecosystem

Primary language: Chinese (documentation and skill definitions). License: Apache 2.0. Status: WIP.

**Design boundary**: This system covers **domain modeling only** (strategic + tactical). No code implementation, testing, or architecture compliance.

## Commands

```bash
# Clone with all submodules
git clone --recurse-submodules <repo-url>

# Initialize submodules after clone
git submodule update --init --recursive

# Update all external submodules to latest
git submodule update --remote

# Update a specific submodule
cd relative-skills/<name> && git pull origin main && cd ../.. && git add relative-skills/<name>
```

There is no build system, linter, or test suite at root level. This is a documentation/specification repository — the primary artifacts are SKILL.md files.

## Architecture

### Dual-Layer Directory Structure

```text
skills/              → In-house system backbone (8 skills, 4 stages)
relative-skills/     → External git submodules (9 repos, frozen references)
```

### 4-Stage DDD Modeling Pipeline (In-House Backbone)

| Stage         | Skill                     | Purpose                                                               |
| ------------- | ------------------------- | --------------------------------------------------------------------- |
| I Discovery   | `ddd-scope`               | Converge fuzzy requirements into modeling inputs                      |
| I Discovery   | `ddd-discover`            | Collaborative domain discovery (event storming / domain storytelling) |
| II Strategic  | `ddd-subdomains`          | Identify capabilities, classify subdomains (core/supporting/generic)  |
| II Strategic  | `ddd-contexts`            | Design bounded contexts with their ubiquitous language                |
| II Strategic  | `ddd-context-map`         | Map inter-context relationships and integration patterns              |
| III Tactical  | `ddd-aggregates`          | Aggregate design from invariants: roots, entities, value objects      |
| III Tactical  | `ddd-domain-interactions` | Events, domain services, repository interfaces, factories             |
| IV Validation | `ddd-model-review`        | Holistic model quality assessment with feedback loop triggers         |

### Non-Linear Feedback Loops

Stages are NOT strictly sequential. Later skills can trigger returns to earlier skills via explicit "trigger-recycle conditions" (defined in Appendix B of `ddd-skill-system-design.md`). For example:

- Invariant expression rate < 60% → return to `ddd-aggregates`
- Terminology conflict rate > 20% → return to `ddd-contexts`
- Cannot distinguish core from supporting → return to `ddd-scope`

### SKILL.md Interface Contract

Every in-house skill follows a mandatory interface structure:

1. **YAML frontmatter** — name, description, risk, source, tags, date_added
2. **Sections** — Usage Timing, Input Requirements, Process, Output (table), Validation Checklist, Backtrack Triggers, Example

### Invocation Pattern

Skills are invoked via `@skill-name` syntax in AI agent contexts:

```text
@ddd-scope <business problem description>
@ddd-model-review <existing model artifacts>
```

## Key Documents

- `README.md` — Hub documentation with skill selection guides
- `ddd-skill-system-design.md` — System design: 4-stage model, skill mapping, dependency graph, reference materials, trigger-recycle matrix (Appendix B), example (Appendix A)
- `ddd-skills-report.md` — Research report on 20+ DDD skills with evaluation

## Conventions

- Skill directories use kebab-case: `ddd-<skill-name>`
- Domain entities/events: PascalCase, events in past tense (e.g., `OrderCreated`)
- All SKILL.md outputs must be structured as tables with explicit column requirements
- Each skill must have validation checklists and backtrack triggers before advancing stages
- Documentation is Chinese-primary; code identifiers and DDD patterns use English terminology
