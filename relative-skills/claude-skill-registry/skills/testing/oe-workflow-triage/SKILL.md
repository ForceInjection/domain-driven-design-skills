---
name: oe-workflow-triage
description: Workflow bug triage for OpenEvent. Use when you have a regression/bug report (wrong step, wrong detour, HIL stuck, site visit issues) and need a minimal reproduction trace plus a fix plan tied to workflow invariants and tests.
---

# oe-workflow-triage

## Minimal reproduction first (avoid “guess fixes”)

1. Pick the closest deterministic scenario:
   - Site visit: `scripts/manual_ux/manual_ux_scenario_I.py`, `scripts/manual_ux/manual_ux_scenario_H.py`
   - Late changes / detours: `scripts/manual_ux/manual_ux_scenario_E.py` etc.

2. Produce a trace:
   - `python3 scripts/manual_ux/manual_ux_scenario_I.py > /tmp/repro.json`

3. Validate with invariants:
   - `python3 scripts/manual_ux/validate_manual_ux_run.py /tmp/repro.json --require_site_visit`

4. If the bug is not covered by existing scenarios:
   - Create a new `scripts/manual_ux_scenario_*.py` by copying the closest scenario.
   - Keep it deterministic (AGENT_MODE=stub + explicit mapping + intent overrides).
   - Add/extend validator checks only when they prevent regressions.

## Fix plan outputs

- A 1–3 PR ladder:
  - PR1: characterization test / scenario reproduction
  - PR2: fix with minimal blast radius
  - PR3: cleanup/refactor (optional)

