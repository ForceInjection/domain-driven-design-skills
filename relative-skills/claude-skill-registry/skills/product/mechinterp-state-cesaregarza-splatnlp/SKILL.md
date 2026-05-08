---
name: mechinterp-state
description: Manage research state for SAE feature analysis including hypotheses, evidence tracking, and research history
---

# MechInterp State Management

Manage the research state for mechanistic interpretability analysis of SAE features. Track hypotheses, link evidence, maintain history, and generate summaries.

## Purpose

This skill provides persistent research state management:
- Create and track hypotheses about feature behavior
- Link experimental evidence to hypotheses
- Maintain a chronological history of research actions
- Generate summaries and export notes

## When to Use

Use this skill to:
- Start a new research investigation on a feature
- Add or update hypotheses based on observations
- Record evidence from experiments
- Get a summary of current research progress
- Export notes for documentation

## State Location

Research state is stored at:
```
/mnt/e/mechinterp_runs/state/feature_{id}_{model}.json
```

Notes are exported to:
```
/mnt/e/mechinterp_runs/notes/feature_{id}_{model}.md
```

## Operations

### Initialize or Load State

```python
from splatnlp.mechinterp.state import ResearchStateManager

# Load existing state or create new
manager = ResearchStateManager(feature_id=18712, model_type="ultra")

# Check current state
print(manager.get_summary())
```

### Add Hypothesis

```python
# Add a new hypothesis
h = manager.add_hypothesis(
    statement="Feature 18712 detects high SCU investment (>= 41 AP)",
    confidence=0.6,
    tags=["family-specific", "threshold-based"]
)
print(f"Created hypothesis {h.id}")
```

### Update Hypothesis

```python
# Update confidence based on evidence
manager.update_hypothesis(
    h_id="h001",
    confidence_delta=+0.1,  # Increase by 10%
    status=HypothesisStatus.TESTING
)

# Or set absolute confidence
manager.update_hypothesis(
    h_id="h001",
    confidence_absolute=0.8,
    status=HypothesisStatus.SUPPORTED
)
```

### Add Evidence

```python
# Link evidence from an experiment
from splatnlp.mechinterp.schemas.research_state import EvidenceStrength

evidence = manager.add_evidence(
    experiment_id="20250607_142531",
    result_path="/mnt/e/mechinterp_runs/results/20250607_142531__result.json",
    summary="SCU family sweep shows +0.35 mean delta at rungs >= 41",
    strength=EvidenceStrength.STRONG,
    supports=["h001"],  # Hypothesis IDs this supports
    key_metrics={"mean_delta": 0.35, "effect_size": 1.2}
)
```

### Add from Experiment Result

```python
# Directly from ExperimentResult object
from splatnlp.mechinterp.schemas import ExperimentResult

result = ExperimentResult.model_validate_json(result_path.read_text())
evidence = manager.add_evidence_from_result(
    result=result,
    supports=["h001"],
    strength=EvidenceStrength.MODERATE
)
```

### Record Pitfalls

```python
# Note things to avoid in future experiments
manager.add_pitfall("ReLU floor detected at low activation - avoid weapon gating")
manager.add_pitfall("Multi-rung SCU already present in 30% of base contexts")
```

### Get Summary

```python
# Get current research summary
summary = manager.get_summary()
print(summary)

# Example output:
# # Research State: Feature 18712
# Model: ultra
# Label: unlabeled
#
# ## Hypotheses (2 active)
# - [h001] (testing, 70%) Feature 18712 detects high SCU investment
# - [h002] (proposed, 50%) Secondary response to ISS at high SCU
#
# ## Evidence (3 items)
# - [e001] SCU family sweep shows +0.35 mean delta...
# ...
```

### Export Notes

```python
# Export to Markdown file
notes_path = manager.export_notes()
print(f"Notes exported to {notes_path}")
```

### Get Next Experiment Suggestions

```python
# Get suggestions based on current state
suggestions = manager.get_next_experiment_suggestions()
for s in suggestions:
    print(f"- {s}")
```

## CLI Usage

```bash
# View state summary
cd /root/dev/SplatNLP
poetry run python -c "
from splatnlp.mechinterp.state import ResearchStateManager
m = ResearchStateManager(18712, 'ultra')
print(m.get_summary())
"

# List all states
poetry run python -c "
from splatnlp.mechinterp.state.io import list_states
for fid, model, path in list_states():
    print(f'{model}/{fid}: {path}')
"
```

## State Schema

```json
{
  "feature_id": 18712,
  "model_type": "ultra",
  "feature_label": "SCU threshold detector",
  "hypotheses": [
    {
      "id": "h001",
      "statement": "Feature detects SCU >= 41 AP",
      "status": "testing",
      "confidence": 0.7,
      "supporting_evidence": ["e001", "e002"],
      "refuting_evidence": [],
      "tags": ["family-specific"]
    }
  ],
  "evidence_index": [
    {
      "id": "e001",
      "experiment_id": "20250607_142531",
      "result_path": "/mnt/e/...",
      "summary": "SCU sweep shows threshold at 41 AP",
      "strength": "strong",
      "key_metrics": {"mean_delta": 0.35}
    }
  ],
  "active_constraints": ["one_rung_per_family"],
  "known_pitfalls": ["relu_floor_at_low_activation"],
  "history": [...],
  "notes": "Free-form research notes..."
}
```

## Hypothesis Status Flow

```
proposed -> testing -> supported
                   \-> refuted
                   \-> superseded (by new hypothesis)
```

## See Also

- **mechinterp-glossary-and-constraints**: Domain knowledge reference
- **mechinterp-next-step-planner**: Propose experiments
- **mechinterp-runner**: Execute experiments
- **mechinterp-summarizer**: Generate research notes from results
