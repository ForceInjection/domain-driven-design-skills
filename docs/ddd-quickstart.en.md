# DDD Skill Quickstart

> 🌐 中文版本: [Chinese](ddd-quickstart.md)

---

> This article answers three questions: what are these Skills, where do they run, and how do you complete a domain modeling run from scratch?
> Target readers: developers who are new to this repository and want to try it immediately.

## 1. What are these Skills?

- **Not installable software** — they are **instruction packages** for AI assistants (conversational environments that support Agent Skills).
- Each Skill is a `SKILL.md` file: it tells the AI "which process to follow and which artifact format to produce" at a given modeling stage.
- 9 Skills form a **5-stage pipeline**: Scope convergence (I) → Strategic design (II) → Tactical design (III) → Model validation (IV) → OpenSpec specification bridging (V). Each stage's artifact is the next stage's input.

```text
@ddd-scope → @ddd-discover → @ddd-subdomains → @ddd-contexts → @ddd-context-map
   → @ddd-aggregates → @ddd-domain-interactions → @ddd-model-review → @ddd-openspec-bridge
```

## 2. Prerequisites

| Need                                  | Description                                                                                                   |
| :------------------------------------ | :------------------------------------------------------------------------------------------------------------ |
| An AI tool that supports Agent Skills | e.g. Claude Code, Qoder, or any environment supporting `@skill` syntax or a Skills directory                  |
| Git                                   | To clone this repository                                                                                      |
| Runtime                               | **None** — this is a documentation/specification repository; no dependencies to install, no services to start |

Clone the repository:

```bash
git clone --recurse-submodules https://github.com/ForceInjection/domain-driven-design-skills.git
```

Two ways to obtain the Skills (pick one):

- **Option A (recommended)**: copy the `skills/ddd-*/` directories into your AI tool's Skills directory (e.g. Claude Code's `~/.claude/skills/` or a project-level `.claude/skills/`), then reference them directly with `@ddd-*`.
- **Option B**: without copying, paste the contents of `skills/<skill>/SKILL.md` into the conversation as instructions, then provide your business description as input.

## 3. Before you start: interview & requirements discovery (key step)

`@ddd-scope` takes a **business description** as input — and that description does not come out of thin air: it comes from **interviewing the business** and **discovering requirements**. The ceiling of modeling quality is set by your understanding of the business, so this is the key step before launching the Skills.

### 3.1 Whom to interview

| Interviewee                                             | What they provide                                              |
| :------------------------------------------------------ | :------------------------------------------------------------- |
| Business people (domain experts)                        | Business goals, full process picture, rules and exceptions     |
| Front-line operators (CS / underwriting / claims, etc.) | How work actually happens, what goes wrong, system pain points |
| Management                                              | Goals and constraints (compliance, budget, pace)               |
| System owners (if a legacy system exists)               | Existing system boundaries, data sources                       |

### 3.2 What to ask (interview outline)

- **Business goals**: What problem are you trying to solve? What metric defines success?
- **Core process**: How does a single case flow from start to finish? (Ask them to walk through it completely)
- **Roles**: Who participates? What does each person do?
- **Exceptions**: What goes wrong? How is it handled when it does?
- **Terminology**: What do you call these things? (Record their exact words — these are likely Ubiquitous Language seeds for modeling)

### 3.3 How to turn notes into a business description

Interview notes → requirements discovery → one business description:

1. Goals and non-goals (what to do / explicitly what not to do)
2. Main process + exception scenarios (think through at least 2–3 failure cases)
3. Role list
4. Business glossary (their exact words)
5. Constraints and risks

Condense into a 3–5 sentence problem description (current pain + desired outcome) — that is the input to `@ddd-scope`.

> If you are the business stakeholder yourself: just describe it in your own words directly to the AI; the interview step can be skipped.

## 4. First conversation: `@ddd-scope`

Give the AI the business description you discovered in step 3 (still allowed to be fuzzy and unstructured):

```text
@ddd-scope
Business description: Our post-sales order process is a mess, cross-system collaboration is hard, and customer complaint response is slow.
Please converge this into DDD modeling inputs: problem statement, goals/non-goals, constraints and assumptions, terminology seeds, risk inventory.
```

The AI will produce a structured artifact: problem & value statements, goals/non-goals, constraints & assumptions table, terminology seed list (≥10), and a risk inventory.

## 5. Passing artifacts: `@ddd-discover` → … → `@ddd-model-review`

Paste the previous Skill's output into the next Skill:

```text
@ddd-discover
Based on the scope output below, help me do domain discovery:
[paste the previous artifact]
Please output an event flow table (main path + exception branches), command/event candidates, hotspot annotations, and an ambiguity list.
```

Work through the 8 modeling Skills (Stages I–IV) in order. **You don't have to finish in one sitting**: you can enter at any stage (new project / existing system / local deepening / model health check — see the entry-selection table in [README](../README.en.md)), pause anytime, and resume later with the artifacts you already have.

## 6. What do you get when you finish?

After the pipeline, you hold a full set of **structured artifacts**:

| Stage         | Example outputs                                                                                                                                                   |
| :------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| I Discovery   | Problem statement, event flow table (main + exception paths), terminology seeds                                                                                   |
| II Strategic  | Subdomain classification (Core/Supporting/Generic), bounded context directory, Ubiquitous Language glossary, boundary ADRs, context map with integration patterns |
| III Tactical  | Aggregate directory & invariant table, entity/VO list, domain event directory, domain services, repository interfaces, factories                                  |
| IV Validation | Dimension scores, issue list, backtrack determination (Ready / Not Ready)                                                                                         |

Want to see what the finished product looks like? Two end-to-end cases live under `validation-cases/`:

- [cargo-validation](../validation-cases/cargo-validation/): logistics domain, benchmarked against an authoritative reference (score 85.8%), with all 01–08 artifacts
- [insurance-validation](../validation-cases/insurance-validation/): insurance underwriting & claims, no reference implementation (expert review 90.9%), with full 01–09 artifacts (09 is the OpenSpec changeset)

## 7. Bridging to implementation: `@ddd-openspec-bridge` (Stage V)

The modeling artifacts are finally converted into executable engineering specifications via Stage V:

```text
@ddd-openspec-bridge
Based on the completed modeling artifacts, generate an OpenSpec changeset:
[paste the 04–07 context, aggregate, and event artifacts]
Please output proposal.md, design.md, and spec.md files under specs/ (Requirement + Scenario).
```

The output is an OpenSpec specification (Requirements + Scenarios in Gherkin format). Hand it to developers or downstream AI tools to implement the code — **this repository does not generate business code**; modeling and specification bridging is its boundary.

## 8. FAQ

| Question                                        | Answer                                                                                                                                         |
| :---------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| Where do the Skills run?                        | In an AI assistant environment, not as standalone programs; invoke with `@skill-name` syntax                                                   |
| Do I need to write code?                        | No. This repository focuses on domain modeling and specification bridging (OpenSpec); implementation is done by developers or downstream AI    |
| What are all those tables for?                  | They are the inputs to the next Skill (ensuring artifact continuity), and the source of the OpenSpec specification                             |
| Can I skip stages?                              | Yes. See the entry-selection table in [README](../README.en.md)                                                                                |
| What are the output requirements of each Skill? | Each Skill's `SKILL.md` defines the output tables, validation checklist, and backtrack triggers, which the AI follows                          |
| How is model quality ensured?                   | Stage IV `ddd-model-review` scores dimensions and triggers backtracking (e.g. invariant expression rate < 60% routes back to `ddd-aggregates`) |
| Where can I see full examples?                  | The 01–09 artifacts of the two cases under `validation-cases/` are complete walkthroughs                                                       |
