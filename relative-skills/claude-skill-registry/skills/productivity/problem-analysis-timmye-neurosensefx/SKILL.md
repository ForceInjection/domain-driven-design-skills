---
name: problem-analysis
description: Invoke IMMEDIATELY via python script for structured problem analysis and decision reasoning. Do NOT explore first - the script orchestrates the workflow.
---

# Problem Analysis

When this skill activates, IMMEDIATELY invoke the script. The script IS the workflow.

## Invocation

```bash
python3 scripts/thinkdeep.py \
  --step 1 \
  --total-steps 6 \
  --thoughts "Problem: <describe>"
```

| Argument        | Required | Description                               |
| --------------- | -------- | ----------------------------------------- |
| `--step`        | Yes      | Current step (starts at 1)                |
| `--total-steps` | Yes      | Minimum 6; adjust as script instructs     |
| `--thoughts`    | Yes      | Accumulated state from all previous steps |

Do NOT analyze or explore first. Run the script and follow its output.
