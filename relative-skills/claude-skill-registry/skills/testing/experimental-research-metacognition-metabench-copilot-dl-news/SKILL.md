---
name: experimental-research-metacognition
description: Do experiment-driven research (hypotheses → minimal repros → evidence) and continuously improve research skills + tooling. Use when behavior is uncertain, contested, or performance-sensitive.
---

# Skill: Experimental Research (Metacognition + Tooling)

## Scope

Use this Skill when you need to **learn by testing reality**:

- You don’t know how a subsystem behaves (or docs conflict with reality).
- You need to choose between implementation approaches and want evidence.
- You suspect a bug, regression, or perf issue and need a minimal, deterministic repro.
- You want to turn “prompt-only lore” into **runnable proof** (checks/tests/scripts) so future agents can move faster.

This Skill is **general** (applies across the repo), but it explicitly supports the repo’s patterns:

- Small `checks/*.check.js` scripts that render/validate quickly
- Jest runs via `npm run test:by-path ...`
- Server safety via `--check` or check scripts (avoid hanging servers)
- Session-based documentation under `docs/sessions/...`

## Inputs (what you must write down first)

- **Research question** (1 sentence): “What is the true behavior of X?”
- **Decision you’ll make** based on the result (1 sentence): “If A, we’ll do …; if B, we’ll do …”
- **Environment**: SSR only / server runtime / browser runtime / mixed activation.
- **Time budget** (minutes) and a stop rule (see below).
- **Success criteria**: what output would convince you (assertions, timings, screenshots, logs).

## Procedure

### 0) Mandatory: open a session

Before making code changes, create a session directory and write down the question + hypothesis:

- `node tools/dev/session-init.js --slug "<short>" --type "research" --title "<title>" --objective "<one-liner>"`

Capture all commands run + key outputs in that session’s `WORKING_NOTES.md`.

### 1) Inventory prior art (don’t reinvent)

Search existing docs and sessions first:

- Guides + AGI docs: `node tools/dev/md-scan.js --dir docs/agi --search "<topic>" --json`
- Sessions: `node tools/dev/md-scan.js --dir docs/sessions --search "<topic>" --json`
- Code reconnaissance: `node tools/dev/js-scan.js --dir src --search "<term1>" "<term2>" --json`

If you find a relevant Skill, follow it. If you find a relevant session, continue it or link it.

### 2) Form a falsifiable hypothesis

Write:

- **Hypothesis**: “I predict X happens because Y.”
- **Falsifier**: “If I observe Z, my hypothesis is wrong.”

If you cannot name a falsifier, you’re not ready to build an experiment.

### 3) Choose the smallest experiment type that can falsify the hypothesis

Prefer earlier items first:

1. **Pure function/unit test** (fastest; no IO)
2. **Check script** under a local `checks/` folder (renders/validates output, exits cleanly)
3. **Fixture + contract test** (if boundaries matter: DB/UI, server/client)
4. **Puppeteer/E2E** (only when browser semantics are required)
5. **Perf micro-benchmark** (only after correctness is pinned down)

Decision notes:

- If it touches a server, prefer a `--check` run or a `checks/*.check.js` script.
- If it touches the browser console/network, use `tools/dev/ui-console-capture.js`.

### 4) Build a minimal reproduction (MVR)

Rules:

- Make the repro **the smallest program** that shows the behavior.
- Use deterministic inputs/fixtures; avoid live network unless that is the subject.
- The experiment must **exit cleanly** (no hanging servers, timers, or open handles).

Good places for MVRs in this repo:

- `src/**/checks/*.check.js` for quick, deterministic checks
- `tests/**` for Jest-based regression/contract tests
- `src/ui/lab/experiments/**` for UI/activation/browser semantic research

### 5) Run, observe, and iterate (tight loop)

Follow this loop:

1. Run the experiment.
2. Record: command, expected output, actual output.
3. Update the hypothesis (or abandon it) based on evidence.
4. Repeat until you can make the decision confidently.

Do not “interpret” without recording the raw evidence.

### 6) Distill to durable memory (the point of the work)

Once the experiment is stable:

- Record evidence in the session notes (commands + outcomes).
- Create/update a Skill or Pattern when it will recur:
  - Skills registry: `docs/agi/SKILLS.md`
  - Patterns: `docs/agi/PATTERNS.md`
- If it’s subsystem-level knowledge, write a guide under `docs/guides/`.

A good distillation answers:

- What was the question?
- What experiment(s) prove the answer?
- What decision should future agents make by default?
- What command(s) re-validate the claim in <30 seconds?

## Metacognition: improve how you research

### Stop rules (anti-rabbit-hole)

Stop and write a reset note when:

- **15 minutes** without new evidence → write down the hypothesis + falsifier again.
- You’ve made **3 edits** without a single passing/meaningful run → shrink the experiment.
- You’re debugging in the dark → add instrumentation (logs, counters, assertions) before more edits.

### Confidence calibration

Track a simple confidence score in the session notes:

- **0** = guess
- **1** = plausible
- **2** = supported by a passing experiment
- **3** = supported + regression guard exists (test/check committed)

Only ship behavior changes at confidence **2+**.

### Research loop (SENSE → THINK → ACT → REFLECT → IMPROVE)

In the session, keep a tiny reflection block:

- **SENSE**: what did we observe?
- **THINK**: what does it imply? what are alternatives?
- **ACT**: what experiment/change next?
- **REFLECT**: what was wasted? what worked?
- **IMPROVE**: what tooling/doc should we add so this is faster next time?

### When to improve tooling (optional, but sometimes autonomous)

Tooling improvements are **optional by default**. Do them autonomously when the expected ROI is high.

**Autonomously improve tooling when any of these are true:**

- You created the same ad-hoc script/command sequence **twice** (or you see two sessions doing it).
- The experiment required non-obvious cleanup to avoid hangs (servers, timers, puppeteer) and you had to rediscover it.
- The workflow will clearly recur (e.g., “render a control and validate HTML”, “start server then capture browser console”).
- The absence of tooling caused a rabbit hole (hit a stop rule), and a small CLI/check would prevent it.

**What “tooling improvement” usually means (in increasing effort):**

1. Add a tiny `checks/*.check.js` script near the feature (preferred) so validation is <30s.
2. Add/extend a focused Jest test (preferred when correctness/regression matters).
3. Add a small `tools/dev/*` CLI when multi-step workflows keep repeating.
4. If you can’t implement tooling now, at least add a **Follow-up** in the current session describing:
  - the command sequence,
  - what should be automated,
  - and why it matters.

## Tooling: default commands and guardrails

### Fast discovery

- Docs search: `node tools/dev/md-scan.js --dir docs --search "<topic>" --json`
- Code search: `node tools/dev/js-scan.js --dir src --search "<term>" --json`

### Safe server verification (don’t hang)

- Prefer `--check`: `node src/ui/server/<server>.js --check`
- Or run a check script: `node src/ui/server/checks/<name>.check.js`

### Focused tests (don’t run the world)

- `npm run test:by-path tests/<path>.test.js`

### Browser semantics debugging

- `node tools/dev/ui-console-capture.js --server="src/ui/server/<server>.js" --url="http://localhost:3000"`

## Escalation / research request

Ask for dedicated research help (or hand off to a research agent) when:

- The correct repro requires cross-cutting harness work (fixtures, server lifecycle, puppeteer setup)
- The behavior appears nondeterministic/flaky and you need determinism infrastructure
- You’ve hit the stop rules twice and still can’t name a falsifier

## References

- Skills registry: `docs/agi/SKILLS.md`
- Session discipline: `docs/agi/skills/session-discipline/SKILL.md`
- Targeted testing: `docs/agi/skills/targeted-testing/SKILL.md`
- Instruction adherence (re-anchor loop): `docs/agi/skills/instruction-adherence/SKILL.md`
- jsgui3 lab experimentation (UI-specific proving ground): `docs/agi/skills/jsgui3-lab-experimentation/SKILL.md`
