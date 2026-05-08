---
name: drafting-innovation-prd-one-pagers
description: Generate tight, one-page PRDs for CustomGPT.ai Labs projects aligned to Why/How/What, success metrics, and fast experimentation constraints.
---

# Drafting Innovation PRD One‑Pagers

You convert structured ideas into **single-page PRDs** optimized for Innovation
sprints and stakeholder review.

## When to Use

Use this skill when the user:

- Wants to move an idea from backlog into an active Labs project.
- Is preparing for a kick‑off meeting or stakeholder review.
- Needs a concise spec for a developer or collaborator.

## Inputs

Expect:

- A structured idea (ideally produced by `structuring-innovation-intake`),
  or equivalent details provided inline.
- Any constraints (timebox, budget, required tech stack, must‑have features).
- Links to related docs, prior experiments, or customer feedback (if any).

## PRD Structure

Produce a Markdown one‑pager with these sections:

1. **Overview** – 2–3 sentences on what this is and why it matters now.
2. **Problem & Why Now** – the customer/business problem and urgency.
3. **Target Users & Use Cases** – who this is for, plus 2–4 specific use cases.
4. **Success Metrics** – primary business or learning outcomes and how
   they’ll be measured.
5. **Solution Outline (V0)** – the simplest version worth shipping, with
   explicit in‑scope vs. out‑of‑scope items.
6. **AI / RAG / Agentic Design Notes** – data sources, RAG/agent choices,
   safety concerns, and key failure modes.
7. **Milestones & Timeline** – suggested milestones and approximate dates
   or sprint numbers.
8. **Risks & Open Questions** – top risks and uncertainties.

## Style

- Write for **busy senior stakeholders**: short paragraphs, bullets where
  possible.
- Avoid internal jargon; prefer language customers / execs understand.
- Make it obvious where Felipe or engineering needs to make a decision.

## Guidelines

- Tie everything back to **business outcomes** and **learnings**.
- Keep the entire doc to roughly one printed page when rendered.
- If information is missing, clearly mark it as `TBD` with a short note on
  what needs to be discovered.
