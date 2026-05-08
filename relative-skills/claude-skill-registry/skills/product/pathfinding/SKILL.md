---
name: Pathfinding
version: 2.0.0
description: Collaborative Q&A to clarify unclear requirements. Use when user wants to figure something out, brainstorm ideas, work through a challenge, explore approaches, or plan features. Triggers would be when requirements are unclear, when exploring an idea, when planning, or when a user explicitly mentions pathfind(ing), brainstorm(ing), clarify(ing), figur(ing) out, work(ing) through, or `--pathfind`.
---

# Pathfinding

Adaptive Q&A → unclear requirements → clear path.

<when_to_use>

- Ambiguous/incomplete requirements
- Complex features needing exploration
- Greenfield projects with open questions
- Collaborative brainstorming or problem solving

NOT for: time-critical bugs, well-defined tasks, obvious questions

</when_to_use>

<confidence>

| Bar | Lvl | % | Name | Action |
|-----|-----|---|------|--------|
| `░░░░░` | 0 | 0–19 | Prepping | Gather foundational context |
| `▓░░░░` | 1 | 20–39 | Scouting | Ask broad questions |
| `▓▓░░░` | 2 | 40–59 | Exploring | Ask focusing questions |
| `▓▓▓░░` | 3 | 60–74 | Charting | Risky to proceed; gaps remain |
| `▓▓▓▓░` | 4 | 75–89 | Mapped | Viable; push toward 5 |
| `▓▓▓▓▓` | 5 | 90–100 | Ready | Deliver |

Start honest. Clear request → level 4–5. Vague → level 0–2.

At level 4: "Can proceed, but 1–2 more questions would reach full confidence. Continue or deliver now?"

Below level 5: include `△ Caveats` section.

</confidence>

<phases>

Track with TodoWrite. Phases advance only, never regress.

| Phase | Trigger | activeForm |
|-------|---------|------------|
| Prep | level 0–1 | "Prepping" |
| Explore | level 2–3 | "Exploring" |
| Clarify | level 4 | "Clarifying" |
| Deliver | level 5 | "Delivering" |

TodoWrite format — each phase gets context-specific title:

```text
- Prep { domain } requirements
- Explore { approach } options
- Clarify { key unknowns, 3-4 words }
- Deliver { artifact type }
```

Situational (insert before Deliver when triggered):
- Resolve Conflicts → `◆ Caution` or `◆◆ Hazard` pushback
- Validate Assumptions → high-risk assumptions before delivery

Workflow:
- Start: Create phase matching initial confidence `in_progress`
- Transition: Mark current `completed`, add next `in_progress`
- High start (4+): Skip directly to `Clarify` or `Deliver`
- Early delivery: Skip to `Deliver` + `△ Caveats`

</phases>

<gather>

Calibrate first — user may have already provided context (docs, prior conversation, pointed you at files). If enough context exists, skip to level 3–4. Don't re-ask what's already clear.

If gaps remain, explore focus areas (pick what's relevant):
- Purpose: What problem? Why now?
- Constraints: Time, tech, team, dependencies
- Success: How will we know it works?
- Scope: What's in, what's out?

When multiple approaches exist:
- Propose 2–3 options with trade-offs
- Lead with recommendation ★ and reasoning
- Let user pick, combine, or redirect

Principles:
- YAGNI — cut what's not needed
- DRY — don't duplicate effort or logic
- Simplest thing — prefer boring solutions

</gather>

<questions>

Use `EnterPlanMode` for each question — enables keyboard navigation of options.

Structure:
- Prose above tool: context, reasoning, ★ recommendation if clear lean
- Inside tool: options only (concise, scannable)

At level 0 — start with session intent:
- Quick pulse check vs deep dive?
- Exploring possibilities or solving a specific problem?
- What does "done" look like?

Levels 1–4 — focus on substance:
- 2–4 options per question + "5. Something else"
- Inline `[★]` on recommended option + *italicized rationale*
- User replies: number, modifications, or combos

</questions>

<workflow>

Loop: Answer → Restate → Update Confidence → Next action

After each answer emit:
- Confidence: {BAR} {NAME}
- Assumptions: { if material }
- Unknowns: { what we can clarify; note unknowables when relevant }
- Decisions: { what's locked in }
- Concerns: { what feels off + why }

Next action by level:
- 0–2: Ask clarifying questions
- 3: Summarize (3 bullets max), fork toward 5
- 4: Offer choice: refine or proceed
- 5: Deliver

</workflow>

<issues>

When answer reveals a concern mid-stream:
- Pause before next question
- Surface with `△` + brief description
- Ask: clarify now, note for later, or proceed with assumption?

Example: "△ This assumes the API supports batch operations — clarify now, note for later, or proceed?"

If user proceeds despite significant gap → escalate to `pushback` protocol.

</issues>

<pushback>

Escalate when choice conflicts with goals/constraints/best practices:

- `◇ Alternative`: Minor misalignment. Present option + reasoning.
- `◆ Caution`: Clear conflict. Recommend alternative, explain risks, ask to proceed. Triggers Resolve Conflicts.
- `◆◆ Hazard`: High failure risk. Require mitigation or explicit override. Triggers Resolve Conflicts.

Override: Accept "Proceed anyway: {REASON}" → log in next reflection → mark Resolve Conflicts complete.

</pushback>

<skeptic>

Integrate skeptic agent for complexity sanity checks:

**Recommend** (offer choice):
- Level 5 reached with △ Caveats > 2
- Red flag language in decisions: "might need later", "more flexible", "best practice"

```text
Before finalizing — you have {N} caveats. Want to run skeptic for a sanity check?
[AskUserQuestion]
1. Yes, quick check [★] — I'll challenge complexity interactively
2. Yes, deep analysis — launch skeptic agent in background
3. No, proceed — deliver as-is
```

**Auto-invoke** (no choice):
- Level 4+ with 3+ unknowns persisting across 2+ question cycles
- ◆◆ Hazard escalation triggered during session

When auto-invoking:

```text
[Auto-invoking skeptic — {REASON}]
```

Launch with Task tool:
- subagent_type: "outfitter:skeptic"
- prompt: Include current decisions, unknowns, and caveats
- run_in_background: false (wait for findings before delivery)

After skeptic returns:
- Present findings to user
- If verdict is `block` → add Resolve Conflicts phase
- If verdict is `caution` → offer choice to address or acknowledge
- If verdict is `proceed` → continue to delivery

</skeptic>

<completion>

Level 5: Produce artifact immediately (doc, plan, code, outline). If none specified, suggest one.

After delivering, ask where to persist (if applicable):

```text
[EnterPlanMode]
1. { discovered path } [★] — { source: `CLAUDE.md` preference | existing directory | convention }
2. Create issue — { Linear/GitHub/Beads based on project context }
3. ADR — { if architectural decision }
4. Don't persist — keep in conversation only
5. Something else — different location or format
```

Discovery order for option 1:
1. `CLAUDE.md` or project instructions with explicit plan storage preference
2. Existing `.agents/plans/` directory
3. Existing `docs/plans/` directory
4. Fall back to `.agents/plans/` if nothing found

Always suggest filename based on topic. Match existing conventions if present.

Mark Deliver `completed` after artifact is delivered (persistence is optional follow-up).

Below 5: Append `△ Caveats`:
- Open questions + context
- Assumed decisions + defaults
- Known concerns + impact
- Deferred items + revisit timing

</completion>

<rules>

ALWAYS:
- TodoWrite phase matching initial confidence at start
- `EnterPlanMode` for each question (keyboard nav)
- Prose above tool for context + ★ recommendation
- One question at a time, wait for response
- Restate + update confidence before next move
- Update todos at level 4, level 5 thresholds
- Apply pushback protocol on conflicts
- Check skeptic triggers at level 4+ (unknowns, caveats, red flags)

NEVER:
- Proceed from 0–3 without clarifying questions
- Hide uncertainty below level 5
- Stack questions or bury decisions in paragraphs
- Put recommendation inside plan tool (keep in prose)
- Skip reflection after answer
- Regress phases
- Ignore skeptic auto-invoke triggers

</rules>

<references>

- [confidence.md](references/confidence.md) — confidence deep dive
- [questions.md](references/questions.md) — question crafting
- [examples/](examples/) — session examples
- [FORMATTING.md](../../shared/`rules/`FORMATTING.md) — formatting conventions
- skeptic agent (outfitter:skeptic) — complexity sanity checks

</references>
