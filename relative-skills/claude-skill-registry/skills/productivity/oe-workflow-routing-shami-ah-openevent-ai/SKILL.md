---
name: oe-workflow-routing
description: Fast routing triage for workflow messages; points to docs/workflow-routing-map.md.
---

## When to use
- Routing bugs, wrong step, detours, out-of-context, or "where did this message go?".
- Requests for a quick routing reference or map.
- Need to point people to the routing doc fast.

## Quick start (do this first)
1) Open `docs/workflow-routing-map.md` and share it.
2) Ask for the minimal routing state (`current_step`, `caller_step`, `thread_state`, key hashes) and any pre-route action.
3) Check pre-route early exits (OOC/duplicate/manager escalation) before step logic.
4) Verify guard forcing (Steps 2-4) and billing/deposit bypasses.
5) Only then inspect step handlers or change-propagation detours.

## Fast response snippet
- "Routing map lives at `docs/workflow-routing-map.md`. Start with state fields, pre-route early exits, guard forcing, then router loop."

## Key files to open
- `docs/workflow-routing-map.md`
- `backend/workflow_email.py`
- `backend/workflows/runtime/pre_route.py`
- `backend/workflows/runtime/router.py`
- `backend/workflow/guards.py`
- `backend/workflows/change_propagation.py`

## Notes
- OOC can drop messages before routing; confirm unified intent vs current step.
- Site visit intercept can fire at any step.
- Step 6/7 HIL tasks are currently skipped.
