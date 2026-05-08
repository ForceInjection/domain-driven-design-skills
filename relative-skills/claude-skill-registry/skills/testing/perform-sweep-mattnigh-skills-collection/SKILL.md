---
name: perform-sweep
description: Design, configure, launch, and analyze ablation sweeps for GRPO training. Use for hypothesis testing, hyperparameter experiments, and systematic comparisons.
---

# Perform Sweep

End-to-end workflow for running ablation experiments on the Diplomacy GRPO training pipeline.

## Quick Reference

| Phase | Action | Command |
|-------|--------|---------|
| **Configure** | Create sweep.yaml | See [YAML Reference](yaml-reference.md) |
| **Validate** | Dry run | `python scripts/launch_sweep.py <path> --dry-run` |
| **Info** | Show config | `python scripts/launch_sweep.py <path> --info` |
| **Launch** | Start sweep | `python scripts/launch_sweep.py <path>` |
| **Status** | Check progress | `python scripts/launch_sweep.py <path> --status` |
| **List** | List all sweeps | `python scripts/launch_sweep.py --list` |
| **Analyze** | Compare results | Use `experiment-analysis` skill |

## Workflow

### 1. Hypothesis Design

- Review recent experiments in `experiments/experiment-tracker.md`
- Identify one variable to test (e.g., horizon length, scoring function)
- Predict expected outcome
- Document reasoning in sweep.yaml `hypothesis` field

### 2. YAML Configuration

Create `experiments/sweeps/<name>/sweep.yaml`:

```yaml
metadata:
  name: "my-ablation"
  description: "Testing hypothesis X"
  hypothesis: "Longer horizons should improve strategic play"
  experiment_tag_prefix: "my-ablation"

defaults:
  total_steps: 100

runs:
  A:
    name: "control"
    description: "Baseline configuration"
    config:
      experiment_tag: "${metadata.experiment_tag_prefix}-A"
  B:
    name: "treatment"
    description: "With longer horizon"
    config:
      rollout_horizon_years: 8
      experiment_tag: "${metadata.experiment_tag_prefix}-B"
```

See [YAML Reference](yaml-reference.md) for full schema.

### 3. Validate Configuration

```bash
# Show sweep info
python scripts/launch_sweep.py experiments/sweeps/<name>/ --info

# Dry run (validates config, shows what would run)
python scripts/launch_sweep.py experiments/sweeps/<name>/ --dry-run
```

### 4. Launch and Monitor

```bash
# Launch (fire-and-forget - runs in cloud)
python scripts/launch_sweep.py experiments/sweeps/<name>/

# Check status anytime
python scripts/launch_sweep.py experiments/sweeps/<name>/ --status

# List all sweeps
python scripts/launch_sweep.py --list
```

### 5. Analysis

After sweep completes, use the `experiment-analysis` skill:

```bash
# Full analysis for each run
uv run python .claude/skills/experiment-analysis/analyze_elo.py <run-name>

# Compare in WandB
# Filter by experiment_tag_prefix (e.g., "my-ablation")
```

## Key Features

- **Fire-and-forget**: Launch and close laptop - sweep runs in Modal cloud
- **Auto-resume**: If Modal times out (24hr max), sweep automatically respawns
- **Sequential execution**: Runs one training at a time (infra constraint)
- **Progress tracking**: State saved after each run for recovery

## Example Sweeps

See existing sweeps in `experiments/sweeps/`:
- `longer-horizon-inverted-weight-ablation/` - 2x2 ablation on horizon and scoring

## Integration

- Use `experiment-analysis` skill for post-sweep metrics analysis
- Results logged to WandB with `experiment_tag` for filtering
- Document findings in sweep directory's `results.md`
