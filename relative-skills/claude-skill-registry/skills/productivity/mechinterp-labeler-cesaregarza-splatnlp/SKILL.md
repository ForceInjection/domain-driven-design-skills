---
name: mechinterp-labeler
description: Manage feature labeling workflow - queue management, label storage, similar features, progress tracking
---

# MechInterp Labeler

Manage the feature labeling workflow. This skill provides tools for:
- Priority queue management
- Setting and syncing labels
- Finding similar features
- Tracking labeling progress

## Purpose

The labeler skill enables interactive feature labeling sessions:
1. Get the next feature to label from a priority queue
2. Use overview and experiments to understand the feature
3. Save labels with categories and notes
4. Find similar features to label next
5. Track overall progress

## Commands

### Get Next Feature

```bash
cd /root/dev/SplatNLP

# Get next feature from queue
poetry run python -m splatnlp.mechinterp.cli.labeler_cli next --model ultra

# Don't auto-build queue if empty
poetry run python -m splatnlp.mechinterp.cli.labeler_cli next --model ultra --no-build
```

### Set a Label

**IMPORTANT**: Always use `--source` to track label provenance.

**Source Options:**
- `claude code` — Label created through Claude Code CLI investigation
- `codex` — Label created through Codex (OpenAI) agent
- `codex/claude` — Label created through Codex orchestrating Claude
- `manual` — Label created by human manually
- `dashboard` — Label created through dashboard UI (default)

```bash
# Label from Claude Code investigation
poetry run python -m splatnlp.mechinterp.cli.labeler_cli label \
    --feature-id 18712 \
    --name "Special Charge Stacker" \
    --model ultra \
    --source "claude code"

# With category and notes
poetry run python -m splatnlp.mechinterp.cli.labeler_cli label \
    --feature-id 18712 \
    --name "SCU Detector" \
    --category tactical \
    --notes "Responds to Special Charge Up presence, stronger at high AP" \
    --source "claude code"

# Manual labeling by human
poetry run python -m splatnlp.mechinterp.cli.labeler_cli label \
    --feature-id 18712 \
    --name "My Label" \
    --source "manual"
```

**Categories:**
- `mechanical`: Low-level patterns (token presence, combinations)
- `tactical`: Mid-level patterns (build strategies, weapon synergies)
- `strategic`: High-level patterns (playstyle, meta concepts)
- `none`: Uncategorized

## Required Label Fields

Every label in `consolidated_ultra.json` MUST include these fields:

| Field | Required | Description |
|-------|----------|-------------|
| `feature_id` | ✓ | Integer feature ID |
| `model_type` | ✓ | "ultra" or "full" |
| `dashboard_name` | ✓ | The label displayed in dashboard |
| `dashboard_category` | ✓ | mechanical, tactical, strategic, or none |
| `dashboard_notes` | ✓ | Investigation notes with evidence |
| `display_name` | ✓ | Same as dashboard_name (for compatibility) |
| `last_updated` | ✓ | ISO timestamp of last update |
| `source` | ✓ | Who created it (e.g., "claude code (full investigation)") |
| `hypothesis_confidence` | ✓ | 0.0-1.0 confidence score (DEPRECATED - use interpretability_confidence) |
| `importance_percentile` | ✓ | Decoder weight percentile (0-100, objective measure of model importance) |
| `interpretability_confidence` | ✓ | How confident we are in the interpretation (0.0-1.0, subjective) |
| `stability_score` | Optional | Split-half stability if validation was run (0.0-1.0) |
| `research_label` | Optional | Alternative label for research context |
| `research_state_path` | Optional | Path to research state JSON |

### Separating Importance from Interpretability

These three fields capture distinct dimensions:

| Field | Question Answered | Source |
|-------|-------------------|--------|
| `importance_percentile` | "Is this feature important to the model?" | Decoder weight magnitude (objective) |
| `interpretability_confidence` | "Do we understand what this feature does?" | Investigation quality (subjective) |
| `stability_score` | "Does this feature behave consistently?" | Split-half validation (objective) |

**Common combinations:**

| Importance | Interpretability | Meaning |
|------------|------------------|---------|
| High (>80) | High (>0.8) | Strong, well-understood feature |
| High (>80) | Low (<0.5) | Important but mysterious - needs more investigation |
| Low (<20) | High (>0.8) | Understood but weak - may be noise or redundant |
| Low (<20) | Low (<0.5) | Skip - not worth investigating |

**Rule of thumb**: Don't conflate these. A feature with 9th percentile importance but 0.85 interpretability confidence is "weak but understood" - useful for pattern recognition but not a major model component.

**Example complete label:**
```json
{
  "feature_id": 10938,
  "model_type": "ultra",
  "dashboard_name": "Positional Survival - Midrange",
  "dashboard_category": "strategic",
  "dashboard_notes": "Survival through positioning, not stealth/trading. Decoder promotes: SSU, BRU (all levels), ISS, IA, IRU. Suppresses: BPU, RSU, QR, SS. Weapons: Midrange with NO/BAD NS fit, LOW death tolerance. NS 0.84x depleted, QR 0.66x suppressed.",
  "display_name": "Positional Survival - Midrange",
  "last_updated": "2025-12-14T01:30:00.000000",
  "source": "claude code (full investigation)",
  "hypothesis_confidence": 0.85,
  "importance_percentile": 9.3,
  "interpretability_confidence": 0.85,
  "stability_score": null,
  "research_label": "Positional Survival - Midrange",
  "research_state_path": "/mnt/e/mechinterp_runs/state/feature_10938_ultra.json"
}
```

## ⚠️ Super-Stimuli Warning

**High activations may be "flanderized" versions of the true concept!**

When labeling features, don't only examine extreme activations. High activation builds can be:
- **Super-stimuli**: Extreme, exaggerated versions of the core concept
- **Weapon-gated**: Only achievable on specific niche weapons
- **Unrepresentative**: Missing the general pattern that applies across weapons

### How to Detect Super-Stimuli

1. **Examine activation regions** (as % of **effective max** = 99.5th percentile):
   - Floor (≤1%), Low (1-10%), Below Core (10-25%)
   - Core (25-75%), High (75-90%), Flanderization Zone (90%+)
   - Use effective max to prevent outliers from distorting region boundaries

2. **Look for weapons that span ALL levels continuously**:
   - If Splattershot appears in every region → feature encodes a general concept
   - If only niche weapons reach 90%+ → those are "super-stimuli"

3. **Compare core (25-75%) vs flanderization zone (90%+)**:
   - Core region: diverse weapons, general builds = TRUE CONCEPT
   - Flanderization zone: concentrated on 3-4 special-dependent weapons = SUPER-STIMULI

### Example: Feature 9971

```
Initial label (wrong): "Death-Averse SCU Stacker"
- Only looked at 90%+ activations (SCU_57 + special-dependent weapons)

Better label: "Offensive Intensity (Death-Averse)"
- Core region (25-75%) showed diverse weapons (Splattershot family, Sploosh, Hydra)
- Feature tracks general offensive investment, not specifically SCU
- Flanderization zone (90%+) with Bloblobber, Glooga are "super-stimuli" not the core concept
```

**Key insight**: The core region (25-75% of effective max) reveals the TRUE feature concept. High activations (90%+ of effective max) show what happens when that concept is pushed to flanderized extremes.

### Core Coverage Validation (BEFORE LABELING)

**Before finalizing any label, verify core coverage of the proposed signature.**

A label based on a token/ability that only appears in <30% of core examples is labeling the TAIL, not the concept.

```python
from splatnlp.mechinterp.skill_helpers import load_context
import polars as pl
import numpy as np

ctx = load_context('ultra')
df = ctx.db.get_all_feature_activations_for_pagerank(FEATURE_ID)

# Define core region
acts = df['activation'].to_numpy()
nonzero_acts = acts[acts > 0]
effective_max = np.percentile(nonzero_acts, 99.5)
core_df = df.filter(
    (pl.col('activation') > 0.25 * effective_max) &
    (pl.col('activation') <= 0.75 * effective_max)
)

# Check coverage of proposed label driver
driver_id = ctx.vocab['YOUR_TOKEN_HERE']  # e.g., 'respawn_punisher'
core_with_driver = core_df.filter(
    pl.col('ability_input_tokens').list.contains(driver_id)
)

coverage = len(core_with_driver) / len(core_df) * 100
print(f"Core coverage: {coverage:.1f}%")
```

| Core Coverage | Label Guidance |
|---------------|----------------|
| >50% | Safe to headline this token/ability |
| 30-50% | Mention in notes, but not as headline |
| <30% | **WRONG LABEL** - this is a tail marker, not the concept |

**Red flags that indicate wrong labeling:**
- Binary ability with >5x tail enrichment but <20% core presence → tail marker
- Weapon with >40% in top-100 but <15% in core → flanderized
- Proposed signature covers <30% of core examples → incomplete interpretation

**Example (Feature 13934):**
```
Wrong approach: See RP with 8.57x enrichment → label as "RP Backline Anchor"
Reality: RP only in 12% of core → RP is super-stimulus, not concept

Right approach: Check core coverage FIRST
→ RP at 12% means it's a tail marker
→ Split by RP presence to find true concept
→ Label the commonality across modes
```

## Label Quality Examples

### Evolution from Mechanical to Strategic

| Investigation Stage | Label | Problem |
|--------------------|-------|---------|
| After 1D sweeps | "SSU + ISM + IRU Kit" | Just lists tokens |
| After binary analysis | "Swim Efficiency Kit (Death-Averse)" | Mechanical + negation |
| After decoder grouping | "Swim Utility Sustain" | Better but still mechanical |
| After weapon role check | "Positional Survival - Midrange" | Strategic concept + role |

### Good vs Bad Labels

| Bad Label | Why | Good Label | Why |
|-----------|-----|------------|-----|
| "SCU Detector" | Token presence only | "Special Pressure Build" | Gameplay purpose |
| "Death-Averse Efficiency" | Negation + mechanical | "Positional Survival" | Positive concept |
| "High SSU Anchor" | Wrong role (Jr. isn't anchor) | "- Midrange" | Correct role |
| "Zombie + RP Mixed" | Describes modes, not concept | "Utility Axis (Multi-Modal)" | Names the pattern |
| "ISM Build" | Single token | "Ink Sustain - Backline" | Concept + role |

### The Strategic Label Test

Before saving a label, ask:

1. "Would a competitive Splatoon player recognize this playstyle?"
   - If no → too mechanical or wrong terminology

2. "Does this explain WHY the model learned this pattern?"
   - If no → you're describing correlation, not causation

3. "Could I explain this to someone who doesn't know the tokens?"
   - If no → label is too technical

### Mandatory Label Components

Every strategic/tactical label should have:

1. **Core concept** - The gameplay behavior (e.g., "Positional Survival")
2. **Role qualifier** - Where/how it's played (e.g., "- Midrange")
3. **Notes with evidence** - Decoder groups, weapon classification, key enrichments

### Label Specificity by Category

**Match label specificity to concept level:**

| Category | Specificity | Example |
|----------|-------------|---------|
| **mechanical** | Terse, technical | "SCU Threshold 29+", "ISM Stacker" |
| **tactical** | Mid-level, names the combo | "Zombie Slayer Dualies", "Beacon Support Kit" |
| **strategic** | High-concept, captures the "why" | "Positional Survival - Midrange" |

- Mechanical = low-level pattern → precise, token-focused
- Tactical = build strategy → names the combo + weapon/class
- Strategic = gameplay philosophy → high-concept + role qualifier

### Skip a Feature

```bash
# Skip the next feature
poetry run python -m splatnlp.mechinterp.cli.labeler_cli skip --model ultra

# Skip specific feature with reason
poetry run python -m splatnlp.mechinterp.cli.labeler_cli skip \
    --feature-id 18712 \
    --reason "ReLU floor too high, hard to interpret"
```

### Add Features to Queue

```bash
# Add single feature
poetry run python -m splatnlp.mechinterp.cli.labeler_cli add 18712 --model ultra

# Add multiple with priority
poetry run python -m splatnlp.mechinterp.cli.labeler_cli add 18712,18890,19042 \
    --priority 0.8 \
    --reason "SCU-related cluster"
```

### Find Similar Features

```bash
poetry run python -m splatnlp.mechinterp.cli.labeler_cli similar \
    --feature-id 18712 \
    --top-k 5 \
    --model ultra
```

### Check Status

```bash
poetry run python -m splatnlp.mechinterp.cli.labeler_cli status --model ultra
```

Output example:
```
## Labeling Status (ultra)

### Labels
- Total labeled: 45
- From dashboard: 30
- From research: 10
- Merged: 5

### Categories
- tactical: 20
- mechanical: 15
- strategic: 5
- uncategorized: 5

### Queue
- Pending: 25
- Completed: 40
- Skipped: 5
```

### Sync Labels

Pull labels from all sources (dashboard, research states):

```bash
poetry run python -m splatnlp.mechinterp.cli.labeler_cli sync --model ultra
```

### Export Labels

```bash
poetry run python -m splatnlp.mechinterp.cli.labeler_cli export \
    --model ultra \
    --output /mnt/e/mechinterp_runs/labels/export.csv
```

### Build Priority Queue

```bash
# By activation count (features with most data)
poetry run python -m splatnlp.mechinterp.cli.labeler_cli build-queue \
    --model ultra \
    --method activation_count \
    --top-k 50

# From cluster (similar to a seed feature)
poetry run python -m splatnlp.mechinterp.cli.labeler_cli build-queue \
    --model ultra \
    --method cluster \
    --seed 18712 \
    --top-k 10
```

## Typical Labeling Session

```
User: Let's label some features

Claude: [runs: labeler_cli next --model ultra]
        Next feature: 18712 (priority: 0.85)

        [runs: overview_cli --feature-id 18712]
        ## Feature 18712 Overview
        - Top token: special_charge_up (27%)
        - Family: SCU 31%
        ...

        Based on the overview, this feature appears to detect
        Special Charge Up stacking. Want me to run a sweep?

User: Yes, confirm with an SCU sweep

Claude: [runs: runner_cli with family_1d_sweep]
        Results confirm monotonic increase with SCU.

        Proposed label: "SCU Detector - High AP"

User: Call it "Special Charge Stacker"

Claude: [runs: labeler_cli label --feature-id 18712
               --name "Special Charge Stacker" --category tactical
               --source "claude code"]
        Label saved (source: claude code). Finding similar features...

        [runs: labeler_cli similar --feature-id 18712]
        Similar features:
        - 19042 (sim=0.82)
        - 18890 (sim=0.75)

        Want to add these to the queue?
```

## Label Storage

Labels are stored in three places (kept in sync):

1. **Dashboard**: `src/splatnlp/dashboard/feature_labels_{model}.json`
2. **Research State**: `/mnt/e/mechinterp_runs/state/{model}/f{id}.json`
3. **Consolidated**: `/mnt/e/mechinterp_runs/labels/consolidated_{model}.json`

The consolidator merges all sources and resolves conflicts.

## Queue Storage

Queue state is persisted at:
- `/mnt/e/mechinterp_runs/labels/queue_{model}.json`

Contains:
- Pending entries with priorities
- Completed feature IDs
- Skipped feature IDs

## Programmatic Usage

```python
from splatnlp.mechinterp.labeling import (
    LabelConsolidator,
    LabelingQueue,
    QueueBuilder,
    SimilarFinder,
)

# Queue management
queue = LabelingQueue.load("ultra")
entry = queue.get_next()
queue.mark_complete(entry.feature_id, "My Label")

# Set labels
consolidator = LabelConsolidator("ultra")
consolidator.set_label(
    feature_id=18712,
    name="SCU Detector",
    category="tactical",
    notes="Responds to SCU presence",
)

# Find similar
finder = SimilarFinder("ultra")
similar = finder.find_by_top_tokens(18712, top_k=5)

# Build queue
builder = QueueBuilder("ultra")
queue = builder.build_by_activation_count(top_k=50)
```

## See Also

- **mechinterp-overview**: Quick feature overview before labeling
- **mechinterp-runner**: Run experiments to validate hypotheses
- **mechinterp-state**: Track detailed research progress
- **mechinterp-summarizer**: Generate notes from experiments
