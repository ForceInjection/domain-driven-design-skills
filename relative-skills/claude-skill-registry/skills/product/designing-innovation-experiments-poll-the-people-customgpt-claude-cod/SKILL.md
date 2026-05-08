---
name: designing-innovation-experiments
description: Turn Innovation PRDs into concrete experiment plans with explicit hypotheses, metrics, and evaluation methods for RAG quality, agents, and automation outcomes.
---

# Designing Innovation Experiments

You transform a high‑level Innovation project into one or more **concrete
experiments** with clear hypotheses, methods, and success criteria.

## When to Use

Use this skill when the user:

- Has an Innovation PRD and wants to know “how do we test this?”.
- Needs to compare multiple approaches (e.g., query routing vs. baseline,
  different RAG configs, different agent workflows).
- Is preparing for a review where evidence is required.

## Inputs

Expect:

- A PRD or detailed project description.
- Any known baseline metrics or constraints (traffic levels, timelines,
  customers who can pilot this, infra limits).
- The available evaluation options (offline test sets, logs, A/B infra,
  customer cohorts).

## Experiment Design

For each major hypothesis, design an experiment with:

- **Hypothesis** – specific and falsifiable.
- **Experiment Type** – offline eval, synthetic eval, live A/B, single‑customer
  pilot, dogfooding, etc.
- **Design** – what will be changed vs. control.
- **Metrics** – primary success metrics and guardrails (e.g., hallucination
  rate, latency, cost per query).
- **Instrumentation** – how data will be logged and analyzed.
- **Duration & Sample Size** – rough guidance appropriate for Innovation
  (e.g., “1 week with ~N conversations per segment”).

## Output Format

Produce a Markdown plan with sections such as:

- **Experiment 1: Title**
  - Hypothesis
  - Design
  - Metrics
  - Instrumentation
  - Duration & Sample Size
  - Risks / Caveats

Repeat for each experiment, then include a short **Prioritization** section
tagging experiments as High / Medium / Low value vs. effort.

## Guidelines

- Prioritize **fast and informative** experiments over perfect statistical
  rigor, while calling out limitations.
- Propose a small number of **high‑leverage experiments** rather than a
  long laundry list.
- Clearly suggest **go / no‑go thresholds** where appropriate.
