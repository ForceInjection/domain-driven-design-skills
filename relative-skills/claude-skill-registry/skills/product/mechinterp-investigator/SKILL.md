---
name: mechinterp-investigator
description: Orchestrate a systematic research program to investigate and meaningfully label SAE features
---

# MechInterp Investigator

This skill guides a systematic investigation of SAE features to arrive at meaningful, non-trivial labels. It orchestrates the other mechinterp skills into a coherent research workflow.

## Phase 0: Triage (ALWAYS START HERE)

**Goal:** Quickly filter out weak/auxiliary features that don't warrant deep investigation.

**Time:** 1-2 minutes

Many SAE features have minimal influence on model outputs. Triage identifies these early so you can skip expensive analysis.

### Step 0.1: Check Decoder Weight Percentile

```python
import torch

sae_path = '/mnt/e/dev_spillover/SplatNLP/sae_runs/run_20250704_191557/sae_model_final.pth'
sae_checkpoint = torch.load(sae_path, map_location='cpu', weights_only=True)
decoder_weight = sae_checkpoint['decoder.weight']  # [512, 24576]

# Get this feature's max absolute decoder weight
feature_decoder = decoder_weight[:, FEATURE_ID]
max_abs = torch.abs(feature_decoder).max().item()

# Compare to all features
all_max_abs = torch.abs(decoder_weight).max(dim=0).values
percentile = (all_max_abs < max_abs).float().mean() * 100

print(f"Feature {FEATURE_ID} decoder weight percentile: {percentile:.1f}%")
```

| Percentile | Action |
|------------|--------|
| < 10% | **Likely weak** - check overview structure |
| 10-25% | Borderline - overview decides |
| > 25% | Proceed to Phase 1 (Overview) |

### Step 0.2: Quick Overview Check (if <10%)

If decoder percentile < 10%, run a quick overview:

```bash
poetry run python -m splatnlp.mechinterp.cli.overview_cli \
    --feature-id {FEATURE_ID} --model ultra --top-k 10
```

**Signs of clear structure (proceed to Phase 1):**
- One family dominates (>40% of breakdown)
- Strong weapon concentration (>50% one weapon)
- Clear binary ability pattern
- Top PageRank token has score > 0.20

**Signs of no structure (label as weak):**
- Family breakdown is flat (all <15%)
- Weapons are diverse
- Top PageRank score < 0.10
- High sparsity (>99%) with no clear pattern

### Triage Decision

```
Decoder percentile < 10% AND no clear structure in overview?
  │
  Yes → Label as "Weak/Aux Feature {ID}" and STOP
  │
  No → Proceed to Phase 1 (Overview)
```

### Weak Feature Label Format

```json
{
  "dashboard_name": "Weak/Aux Feature {ID}",
  "dashboard_category": "auxiliary",
  "dashboard_notes": "TRIAGE: Decoder weight {X}th percentile, no clear structure in overview. Skipped deep dive.",
  "hypothesis_confidence": 0.0,
  "source": "claude code (triage)"
}
```

### When to Override Triage

Even with low decoder weights, proceed if:
- The feature is part of a cluster you're investigating
- You have external reason to believe it's important
- You're doing exhaustive analysis of a subset

---

## ⚠️ Deep Dive Basics

A proper deep dive requires **experiments**, not just reading overview data. The overview shows correlations; experiments reveal causation.

### Minimum Requirements for a Deep Dive

| Step | What to Do | Why |
|------|------------|-----|
| 1. Overview | Run overview to see correlations | Generate hypotheses |
| 2. 1D Sweeps | Test top 3-5 families with 1D sweeps | Find causal drivers (scaling abilities) |
| 3. Binary Check | For binary abilities (Comeback, Stealth Jump, LDE, Haunt, etc.), check presence rate | Binary abilities show delta=0 in sweeps but may still be characteristic |
| 4. Bottom Tokens | Check suppressors from overview | What the feature AVOIDS is often more informative |
| 5. 2D Heatmaps | Test interactions between primary driver and correlated tokens | Verify if correlations are causal or spurious |
| 6. Kit Analysis | Check if core weapons share sub/special/class pattern | Can explain "why" behind build philosophy - determine if causal or spurious |

### Binary Abilities Need Special Handling

**Binary abilities** (you have them or you don't) show **delta=0 in 1D sweeps** because there's no scaling. This does NOT mean they're unimportant.

| Binary Abilities |
|------------------|
| Comeback, Stealth Jump, Last-Ditch Effort, Haunt, Ninja Squid, Respawn Punisher, Object Shredder, Drop Roller, Opening Gambit, Tenacity |

**To evaluate binary abilities:**
1. Check PageRank score (correlation strength)
2. Check presence rate: What % of high-activation examples contain it?
3. Compare mean activation WITH vs WITHOUT the binary token
4. Run 2D heatmap: `scaling_ability × binary_ability` to see conditional effect

### Binary Ability Analysis Protocol (CRITICAL)

Binary abilities can have **strong conditional effects** that ONLY show up in 2D analysis. Here's the exact methodology:

**Step 1: Check presence rate enrichment**
```python
from splatnlp.mechinterp.skill_helpers import load_context
import polars as pl

ctx = load_context('ultra')
df = ctx.db.get_all_feature_activations_for_pagerank(FEATURE_ID)

# Find binary token ID
binary_id = None
for tok_id, tok_name in ctx.inv_vocab.items():
    if tok_name == 'comeback':  # or stealth_jump, etc.
        binary_id = tok_id
        break

# Calculate enrichment
threshold = df['activation'].quantile(0.90)  # Top 10%
high_df = df.filter(pl.col('activation') >= threshold)

with_binary_all = df.filter(pl.col('ability_input_tokens').list.contains(binary_id))
with_binary_high = high_df.filter(pl.col('ability_input_tokens').list.contains(binary_id))

baseline_rate = len(with_binary_all) / len(df)
high_rate = len(with_binary_high) / len(high_df)
enrichment = high_rate / baseline_rate

print(f"Baseline presence: {baseline_rate:.1%}")
print(f"High-activation presence: {high_rate:.1%}")
print(f"Enrichment ratio: {enrichment:.2f}x")
# Enrichment > 1.5x suggests binary ability is characteristic
```

**Step 2: Check mean activation WITH vs WITHOUT**
```python
with_binary = df.filter(pl.col('ability_input_tokens').list.contains(binary_id))
without_binary = df.filter(~pl.col('ability_input_tokens').list.contains(binary_id))

mean_with = with_binary['activation'].mean()
mean_without = without_binary['activation'].mean()
delta = mean_with - mean_without

print(f"Mean WITH: {mean_with:.4f}")
print(f"Mean WITHOUT: {mean_without:.4f}")
print(f"Delta: {delta:+.4f}")
# Delta > 0.03 suggests meaningful effect
```

**Step 3: Run 2D heatmap (MOST IMPORTANT)**

Binary abilities can have **conditional effects** that vary by the scaling ability level:

```python
# Manual 2D analysis for binary abilities
# (The built-in 2D heatmap may not handle binary tokens correctly)

scaling_ids = {3: 48, 6: 49, 12: 50, 21: 53, 29: 80}  # ISM example
binary_id = 27  # Comeback

print("Scaling | No Binary | With Binary | Delta")
print("-" * 50)

for level, tok_id in scaling_ids.items():
    level_df = df.filter(pl.col('ability_input_tokens').list.contains(tok_id))

    with_binary = level_df.filter(pl.col('ability_input_tokens').list.contains(binary_id))
    without_binary = level_df.filter(~pl.col('ability_input_tokens').list.contains(binary_id))

    mean_with = with_binary['activation'].mean() if len(with_binary) > 0 else 0
    mean_without = without_binary['activation'].mean() if len(without_binary) > 0 else 0
    delta = mean_with - mean_without

    print(f"{level:>7} | {mean_without:>9.4f} | {mean_with:>11.4f} | {delta:>+.4f}")
```

**Example (Feature 13352):**
```
ISM × Comeback 2D Analysis:
ISM | No CB  | With CB | Delta
  0 | 0.066  | 0.117   | +0.051
  3 | 0.122  | 0.261   | +0.139
  6 | 0.147  | 0.352   | +0.205  ← PEAK INTERACTION
 12 | 0.094  | 0.163   | +0.069
 21 | 0.094  | 0.129   | +0.035

Interpretation: Comeback has STRONG conditional effect at ISM 3-6.
The +0.205 delta at ISM_6 means Comeback DOUBLES the activation!
1D sweep showed delta=0 because most examples have ISM=0 (low baseline).
```

**Step 4: Test combinations of binary abilities together**
```python
# Test multiple binary abilities together
binary_id_1 = 27  # e.g., comeback
binary_id_2 = 1   # e.g., stealth_jump

both = df.filter(
    pl.col('ability_input_tokens').list.contains(binary_id_1) &
    pl.col('ability_input_tokens').list.contains(binary_id_2)
)
neither = df.filter(
    ~pl.col('ability_input_tokens').list.contains(binary_id_1) &
    ~pl.col('ability_input_tokens').list.contains(binary_id_2)
)

# Then do 2D analysis at each scaling level
# Combinations can have stronger effects than individual abilities!
```

**Key Insight:** Binary abilities may have stronger effects when combined. Always test combinations, not just individual tokens.

### Additional Learnings

1. **Conditional effects can be much stronger than marginal effects**: A feature might show ISM with only 0.069 max_delta in 1D sweeps, but a binary ability combination at moderate ISM could produce +0.335 delta - the interaction effect can be 5x stronger than the marginal effect. 1D sweeps can dramatically underestimate a feature's true behavior.

2. **Depletion is informative**: If a binary ability shows enrichment < 1.0 (e.g., 0.72x), the feature actively *avoids* that ability. This is meaningful for interpretation - it tells you what the feature excludes, not just what it includes.

3. **Manual 2D analysis required for binary tokens**: The `Family2DHeatmapRunner` uses `parse_token()` which expects `family_name_AP` format, but binary abilities appear as just the token name (e.g., `comeback` not `comeback_10`). Use manual 2D analysis code for binary abilities (see protocol above).

4. **"Weak feature" needs decoder weight check**: A feature with weak activation effects (max_delta < 0.03) might still have high influence on outputs. Remember: **net influence = activation strength × decoder weight**. Before labeling as "weak", check the feature's decoder weights to the output tokens it contributes to. A "weak activation" feature with high decoder weights may actually be important.

5. **Watch for error-correction features**: If 1D sweeps show small deltas or effects only in unusual rung combinations, the feature may fire when prerequisites are MISSING (OOD detection). Test "explains-away" behavior by comparing activation when low-level evidence is present vs missing. Example: Does feature fire MORE when SCU_3 is absent from a high-SCU build?

6. **Beware of flanderization in top activations**: The top 100 activations over-emphasize extreme cases. The TRUE concept often lives in the **mid-activation range (25-75th percentile)**. Always compare mid vs top activation regions - if they show different weapon/ability patterns, label the mid-range concept and note the extremes as "super-stimuli".

### What Counts as Evidence

| Evidence Type | Strength | Example |
|---------------|----------|---------|
| 1D sweep max_delta > 0.05 | Strong causal | "ISM drives this feature" |
| 1D sweep max_delta 0.02-0.05 | Weak causal | "ISM has minor effect" |
| 1D sweep max_delta < 0.02 | Negligible | "ISM doesn't drive this" |
| Binary delta = 0 | Inconclusive | Need presence rate check |
| High PageRank + low delta | Spurious correlation | Token co-occurs but doesn't cause |
| 2D heatmap shows conditional effect | Interaction confirmed | "X matters only when Y is high" |
| Bottom tokens (suppressors) | Avoidance pattern | "Feature avoids death-perks" |
| Higher activation when prerequisite MISSING | Error-correction | "Fires on OOD rung combos" |
| Mid-range (25-75%) differs from top | Flanderization | "Top is super-stimuli; label mid-range" |

### Common Mistakes to Avoid

1. **Presenting overview as findings** - Overview is hypotheses, not conclusions
2. **Ignoring binary abilities** - Delta=0 doesn't mean unimportant
3. **Skipping bottom tokens** - Suppressors reveal what feature avoids
4. **Only running 1D sweeps** - 2D heatmaps needed for interaction effects
5. **Not checking weapon patterns** - Feature may be weapon-specific, not ability-specific
6. **Using only top activations** - Top activations (90%+ of max) may be "flanderized" extremes; check core region (25-75% of max)
7. **Missing error-correction features** - Small deltas in weird rung combos may indicate OOD detection
8. **Confusing data sparsity with suppression** - Zero examples at a condition ≠ "suppression to 0" (see below)
9. **Shallow validation** - Just checking if numbers "look right" without running enrichment analysis
10. **Semantic contradictions in labels** - e.g., "Zombie" (embraces death) + "high SSU" (avoids death) is contradictory
11. **Reporting weapon percentages from top-100** - Use top 20-30% instead; top-100 can be 5-10x off (e.g., 78% vs 10%)
12. **Not checking meta archetypes** - Weapons may cluster by playstyle, not kit; use splatoon3-meta skill
13. **Assuming kit-based patterns** - Check if weapons share sub/special BEFORE assuming it's kit-related
14. **Ignoring flanderization crossover** - Note where a "super-stimulus" weapon overtakes the general pattern (usually 90%+ of max activation)

### ⚠️ CRITICAL: Data Sparsity vs Suppression

**This is a common and dangerous mistake.** When you see "activation = 0" or "no effect" at some condition, ask: **Is this suppression or data sparsity?**

**Example of the mistake (Feature 1819):**
```
Original claim: "QR is HARD SUPPRESSOR - SSU_57+QR_any=0.000"
Reality: There were ZERO examples with SSU_57 + any QR in the dataset!
         The "0.000" was missing data, not suppression.
```

**How to detect data sparsity:**
```python
# ALWAYS check sample sizes when claiming suppression!
at_high_ssu = df.filter(pl.col('ability_input_tokens').list.contains(ssu_57_id))
with_qr = at_high_ssu.filter(pl.col('ability_input_tokens').list.set_intersection(qr_ids).list.len() > 0)

print(f"Examples at SSU_57 with QR: {len(with_qr)}")  # If 0, this is SPARSITY not suppression!
```

**Rule:** Never claim "suppression" unless you have ≥20 examples in the suppressed condition. Report sample sizes with all claims.

## Philosophy

A **meaningful label** should capture:
- What concept the feature encodes (not just "detects token X")
- Why the model might have learned this representation
- How it relates to strategic/tactical gameplay

**Avoid trivial labels** like:
- "SCU Detector" (just describes token presence)
- "High activation feature" (describes statistics, not meaning)

**Aim for interpretable labels** like:
- "Aggressive Slayer Build" (strategic concept)
- "Special Spam Enabler" (functional role)
- "Backline Support Kit" (playstyle archetype)

## Investigation Workflow

### Phase 0: Triage

See [Phase 0: Triage](#phase-0-triage-always-start-here) above. **Always start here.**

If feature passes triage (decoder weight ≥10% OR has clear structure), proceed to Phase 1.

### Phase 1: Initial Assessment

Run the overview and classify the feature type:

```bash
poetry run python -m splatnlp.mechinterp.cli.overview_cli \
    --feature-id {FEATURE_ID} --model {MODEL} --top-k 20
```

**Classify based on family breakdown:**

| Pattern | Type | Next Steps |
|---------|------|------------|
| One family >40% | Single-family | Check for interference, weapon specificity |
| Top 2-3 families ~20% each | Multi-family | Check synergy/redundancy, build archetype |
| Many families <15% each | Distributed | Look for meta-pattern, weapon class |
| Weapons concentrated | Weapon-specific | Weapon sweep, class analysis |

**CRITICAL**: Always check for non-monotonic effects! Higher AP doesn't always mean higher activation.

### Phase 1.5: Activation Region Analysis (CRITICAL - Anti-Flanderization)

**Don't only examine extreme activations!** High activations may be "flanderized" - exaggerated, extreme versions of the true concept that over-emphasize niche cases.

**Key insight:** The TRUE concept often lives in the **core region (25-75% of effective max)**, not the top examples. Top activations (90%+ of effective max) can mislead you into labeling a niche pattern instead of the general concept.

**Why "effective max"?** Activation distributions are heavy-tailed. Using `effective_max = 99.5th percentile of nonzero activations` prevents single outliers from making the core region nearly empty.

Run activation region analysis:

```python
from splatnlp.mechinterp.skill_helpers import load_context
import numpy as np
from collections import Counter

ctx = load_context("{MODEL}")
df = ctx.db.get_all_feature_activations_for_pagerank({FEATURE_ID})

acts = df['activation'].to_numpy()
weapons = df['weapon_id'].to_list()

# Use EFFECTIVE MAX (99.5th percentile) to handle heavy-tailed distributions
# This prevents single outliers from making the core region nearly empty
nonzero_acts = acts[acts > 0]
effective_max = np.percentile(nonzero_acts, 99.5)
true_max = acts.max()
print(f"True max: {true_max:.4f}, Effective max (99.5%ile): {effective_max:.4f}")

# Define activation regions as % of EFFECTIVE max
regions = [
    ('Floor (≤1%)', lambda a: a <= 0.01 * effective_max),
    ('Low (1-10%)', lambda a: 0.01 * effective_max < a <= 0.10 * effective_max),
    ('Below Core (10-25%)', lambda a: 0.10 * effective_max < a <= 0.25 * effective_max),
    ('Core (25-75%) - TRUE CONCEPT', lambda a: 0.25 * effective_max < a <= 0.75 * effective_max),
    ('High (75-90%)', lambda a: 0.75 * effective_max < a <= 0.90 * effective_max),
    ('Flanderization Zone (90%+)', lambda a: a > 0.90 * effective_max),
]

for region_name, filter_fn in regions:
    indices = [i for i, a in enumerate(acts) if filter_fn(a)]
    weps = [weapons[i] for i in indices]
    print(f"\n{region_name} (n={len(indices)}):")
    for wep, count in Counter(weps).most_common(5):
        name = ctx.id_to_weapon_display_name(wep)
        print(f"  {name}: {count}")
```

**Key signals to look for:**

| Pattern | Interpretation |
|---------|----------------|
| Same weapons in ALL regions | General concept (continuous feature) |
| Different weapons in core vs 90%+ | Super-stimuli detected |
| Diverse weapons in core, concentrated in 90%+ | True concept is in core region |
| Niche weapons only in 90%+ | High activations are "flanderized" extremes |

**Example (Feature 9971):**
```
Core (25-75%): Splattershot (115), Wellstring (65), Sploosh (57)...
Flanderization (90%+): Bloblobber (44), Glooga Deco (39), Range Blaster (28)

Interpretation: Core region shows GENERAL offensive investment.
Flanderization zone shows EXTREME SCU on special-dependent weapons (super-stimuli).
Label the general concept, note the super-stimuli pattern.
```

**CRITICAL**: Always check the **Bottom Tokens (Suppressors)** section! Tokens that rarely appear in high-activation examples can reveal what the feature *avoids*:

| Suppressor Pattern | Interpretation |
|-------------------|----------------|
| Death-mitigation (QR, SS, CB) suppressed | Feature avoids "death-accepting" builds |
| Defensive (IR, SR) suppressed | Feature prefers aggressive/ranged builds |
| Mobility suppressed | Feature prefers stationary/positional play |
| Special abilities suppressed | Feature encodes non-special playstyle |

**Example**: If SCU is enhanced but `quick_respawn`, `special_saver`, and `comeback` are ALL suppressed, the feature doesn't just detect "SCU" - it detects "death-averse SCU builds" (players who stack SCU but don't plan to die).

### Phase 1.6: Weapon Distribution Analysis (CRITICAL - Anti-Flanderization)

**NEVER report weapon percentages from top-100 samples.** Top-100 is severely flanderized and can give wildly misleading weapon distributions.

**Example (Feature 14096 - Real Case):**
```
Top 100:     Dark Tetra 78%, Stamper 20%  ← WRONG, flanderized
Top 10%:     Stamper 35%, Dark Tetra 21%  ← Better but still skewed
Top 30%:     Stamper 23%, Dark Tetra 10%  ← TRUE CONCEPT
Full dataset: Stamper 9%, Dark Tetra 3.5% ← Includes noise/floor
```

**Use top 20-30% for weapon characterization:**

```python
import polars as pl
import numpy as np
from collections import Counter
from splatnlp.mechinterp.skill_helpers import load_context

ctx = load_context('ultra')
df = ctx.db.get_all_feature_activations_for_pagerank(FEATURE_ID)

# Get percentile thresholds
acts = df['activation'].to_numpy()
thresholds = {p: np.percentile(acts, p) for p in [0, 50, 70, 80, 90, 95, 99]}

# Analyze by region
regions = [
    ("Bottom 50% (noise)", 0, 50),
    ("50-70% (weak)", 50, 70),
    ("Top 30% (TRUE CONCEPT)", 70, 100),
    ("Top 10%", 90, 100),
    ("Top 1% (flanderized)", 99, 100),
]

print("Region | Top Weapons")
print("-" * 60)

for name, p_low, p_high in regions:
    t_low, t_high = thresholds[p_low], thresholds.get(p_high, float('inf'))
    if p_high == 100:
        region_df = df.filter(pl.col('activation') >= t_low)
    else:
        region_df = df.filter((pl.col('activation') >= t_low) & (pl.col('activation') < t_high))

    if len(region_df) == 0:
        continue

    weapon_counts = region_df.group_by('weapon_id').agg(
        pl.col('activation').count().alias('n')
    ).sort('n', descending=True)

    top3 = []
    for row in weapon_counts.head(3).iter_rows(named=True):
        wname = ctx.id_to_weapon_display_name(row['weapon_id'])
        pct = row['n'] / len(region_df) * 100
        top3.append(f"{wname[:12]}({pct:.0f}%)")

    print(f"{name:<25} | {', '.join(top3)}")
```

**Interpretation Guide:**

| Pattern | Meaning |
|---------|---------|
| Same weapons in top-30% and top-1% | Continuous feature, no flanderization |
| Different weapons in top-30% vs top-1% | **Flanderization detected** - label top-30% concept |
| One weapon jumps from 10% to 70%+ | That weapon is "super-stimulus" for the feature |
| Weapons consistent 50%→30%→10%→1% | Stable feature, safe to use any region |

**Rule: Report weapon percentages from top 20-30%, note if top-1% differs significantly.**

### Phase 1.6.5: Ability Flanderization Check (CRITICAL)

**The same flanderization that applies to weapons applies to abilities.** A binary ability with high tail enrichment but low core coverage is a **super-stimulus**, not the core concept.

**The Rule:** If a "dominant" driver has **<30% core coverage**, it's a **tail marker**, not the headline concept.

**Use the core coverage experiment:**

```bash
cd /root/dev/SplatNLP

# Direct subcommand (recommended)
poetry run python -m splatnlp.mechinterp.cli.runner_cli coverage \
    --feature-id {FEATURE_ID} --model ultra \
    --tokens respawn_punisher,comeback,stealth_jump \
    --threshold 0.30
```

**Output tables:**
- `token_coverage`: Shows core_coverage_pct, tail_enrichment, is_tail_marker for each token
- `weapon_coverage`: Shows core vs tail weapon distributions (catches weapon flanderization)

**Coverage Interpretation:**

| Core Coverage | Interpretation | Label Implication |
|---------------|----------------|-------------------|
| >50% | **Primary driver** | Safe to headline |
| 30-50% | **Significant but not universal** | Mention in notes, not headline |
| <30% | **Tail marker / super-stimulus** | NOT the headline concept |

**Example (Feature 13934):**
```
respawn_punisher: 8.57x tail enrichment, BUT only 12% core coverage
→ RP is a super-stimulus, NOT the core concept
→ Wrong label: "RP Backline Anchor"
→ Right approach: Split core by RP presence to reveal hidden modes
```

**When you find a super-stimulus (<30% coverage):**
1. Split the core by presence/absence of the super-stimulus
2. Analyze both modes separately
3. Look for what they have in COMMON (the true concept)
4. Label the commonality, note the super-stimulus as a tail marker

### Phase 1.7: Meta-Informed Weapon Analysis (USE AFTER WEAPON SWEEP)

After identifying top weapons, **always check if they match a known meta archetype** using the `splatoon3-meta` skill.

**Step 1: Look up weapon kits**

Check `references/weapons.md` for each top weapon's sub and special:

```python
# Top weapons from Feature 14096 (top 30%):
kits = {
    "Splatana Stamper": ("Burst Bomb", "Zipcaster"),
    "Dark Tetra Dualies": ("Autobomb", "Reefslider"),
    "Glooga Dualies": ("Splash Wall", "Booyah Bomb"),
    "Dapple Dualies Nouveau": ("Torpedo", "Reefslider"),
    "Splatana Wiper": ("Torpedo", "Ultra Stamp"),
}

# Check for shared subs/specials
from collections import Counter
subs = Counter(k[0] for k in kits.values())
specials = Counter(k[1] for k in kits.values())

# If one sub/special dominates → kit-based feature
# If diverse → playstyle-based feature
```

**Step 2: Check archetype reference**

Read `references/archetypes.md` to see if weapons match a known archetype:

| Archetype | Key Weapons | Signature Abilities |
|-----------|-------------|---------------------|
| Zombie Slayer | Tetra Dualies, Splatana Wiper | QR + Comeback + Stealth Jump |
| Stealth Slayer | Carbon Roller, Inkbrush | Ninja Squid + SSU + Stealth Jump |
| Anchor/Backline | E-liter, Hydra Splatling | Respawn Punisher + Object Shredder |
| Support/Beacon | Squid Beakon weapons | Sub Power Up + ISS + Comeback |

**Step 3: Classification decision**

```
Kit Analysis Result:
├─ Shared sub weapon? → Feature may encode SUB PLAYSTYLE
├─ Shared special? → Feature may encode SPECIAL FARMING
├─ No kit pattern + archetype match? → PLAYSTYLE FEATURE (label as archetype)
└─ No kit pattern + no archetype? → WEAPON CLASS feature (check if all dualies, all shooters, etc.)
```

**Example (Feature 14096):**
```
Top 30% weapons: Stamper, Dark Tetra, Glooga, Dapple, Wiper
Kit analysis: Diverse subs (Burst, Auto, Splash Wall, Torpedo), diverse specials
Archetype check: Dark Tetra + Splatana Wiper = "Zombie Slayer" archetype!
Conclusion: PLAYSTYLE feature encoding Zombie Slayer (death-accepting aggressive)
Label: "Zombie Slayer QR (Splatana/Dualies)" - tactical category
```

**When to invoke splatoon3-meta skill:**
- After weapon_sweep shows concentrated weapon pattern
- When top weapons seem unrelated by kit but share a playstyle
- To validate that ability patterns match expected meta builds
- To identify if weapons share archetype despite different kits

### Phase 1.7.5: Kit Component Analysis (OPTIONAL but Recommended)

**When to use:** After weapon sweep, check if the core weapons share patterns in ANY kit component: **sub weapon**, **special weapon**, or **main weapon class**. This can reveal WHY certain build philosophies emerge.

**Key insight:** Weapons may cluster by:
- **Sub weapon** (Burst Bomb users, Beakon users → explains SPU/ISS builds)
- **Special weapon** (Aggressive push specials → explains survival builds)
- **Main weapon class** (All dualies, all chargers → explains mobility/positioning builds)

The feature may be driven by ONE of these - identify which, then determine if it's causal or spurious.

---

#### Component 1: Sub Weapon Pattern Analysis

**When relevant:** If kit_sweep (Phase 1.7/3d) shows sub concentration, investigate further.

```python
from collections import Counter

# Map top weapons to their subs (from weapons.md)
weapon_subs = {
    "Splattershot Jr.": "Splat Bomb",
    "Neo Splash-o-matic": "Suction Bomb",
    "Sploosh-o-matic 7": "Splat Bomb",
    # ... add more as needed
}

# Categorize subs
sub_categories = {
    # Lethal bombs
    "Splat Bomb": "lethal", "Suction Bomb": "lethal", "Burst Bomb": "lethal",
    "Curling Bomb": "lethal", "Autobomb": "lethal", "Torpedo": "lethal",
    "Fizzy Bomb": "lethal", "Ink Mine": "lethal", "Toxic Mist": "lethal",
    # Utility/Support
    "Squid Beakon": "utility", "Splash Wall": "utility", "Sprinkler": "utility",
    "Point Sensor": "utility", "Angle Shooter": "utility",
}

# Count categories
sub_counts = Counter()
for weapon in top_weapons:
    sub = weapon_subs.get(weapon)
    if sub:
        category = sub_categories.get(sub, "other")
        sub_counts[category] += 1

print("Sub Weapon Breakdown:")
for sub, count in Counter(weapon_subs.get(w) for w in top_weapons if weapon_subs.get(w)).most_common():
    print(f"  {sub}: {count}")
```

**Sub pattern implications:**

| Sub Pattern | Build Implication | Example |
|-------------|-------------------|---------|
| Shared Beakons | SPU/ISS focus for sub spam | Beacon Support builds |
| Shared Burst Bomb | Mobility + burst damage | Aggressive flanker builds |
| Shared Splash Wall | Positional/defensive play | Lane control builds |
| Diverse subs | Sub is NOT the clustering factor | Check special or main class |

---

#### Component 2: Special Weapon Pattern Analysis

**When relevant:** After weapon sweep, check if core weapons share a special weapon pattern.

```python
from collections import Counter

# Map top weapons to their specials (from weapons.md)
weapon_specials = {
    "Splatana Stamper": "Zipcaster",
    "Sloshing Machine": "Booyah Bomb",
    "Squeezer": "Trizooka",
    # ... add more as needed
}

# Categorize specials
special_categories = {
    # Zoning/Area Denial
    "Ink Storm": "zoning", "Wave Breaker": "zoning", "Tenta Missiles": "zoning",
    "Killer Wail 5.1": "zoning", "Triple Inkstrike": "zoning",
    # Team Support
    "Tacticooler": "team_support", "Big Bubbler": "team_support",
    "Splattercolor Screen": "team_support",
    # Aggression/Push
    "Trizooka": "aggression", "Crab Tank": "aggression", "Ink Jet": "aggression",
    "Ultra Stamp": "aggression", "Booyah Bomb": "aggression", "Reefslider": "aggression",
    "Kraken Royale": "aggression", "Zipcaster": "aggression",
    # Utility/Defense
    "Ink Vac": "utility", "Super Chump": "utility", "Triple Splashdown": "utility",
}

# Count categories
category_counts = Counter()
for weapon in top_weapons:
    special = weapon_specials.get(weapon)
    if special:
        category = special_categories.get(special, "other")
        category_counts[category] += 1

print("Special Category Breakdown:")
for cat, count in category_counts.most_common():
    print(f"  {cat}: {count/sum(category_counts.values())*100:.0f}%")
```

**Special pattern implications:**

| Special Pattern | Build Implication | Example |
|-----------------|-------------------|---------|
| >60% aggression | Players build for survival to deploy push specials | Feature 14964 |
| >60% zoning | Players may invest in SCU/SPU for area denial uptime | Ink Storm spam |
| >50% team_support | Team-oriented builds, may see Tenacity/CB | Support kit |
| Diverse specials | Special is NOT the clustering factor | Check sub or main class |

---

#### Component 3: Main Weapon Class Pattern Analysis

**When relevant:** If weapons seem diverse but may share a class (all shooters, all dualies, all chargers).

```python
# Weapon class mapping (from weapon-vibes.md)
weapon_classes = {
    "Splattershot": "shooter", "Splattershot Jr.": "shooter", "Splattershot Pro": "shooter",
    "Dark Tetra Dualies": "dualie", "Dapple Dualies": "dualie", "Splat Dualies": "dualie",
    "E-liter 4K": "charger", "Splat Charger": "charger", "Goo Tuber": "charger",
    "Luna Blaster": "blaster", "Range Blaster": "blaster", "Rapid Blaster": "blaster",
    "Hydra Splatling": "splatling", "Mini Splatling": "splatling",
    "Splatana Stamper": "splatana", "Splatana Wiper": "splatana",
    # ... add more as needed
}

# Count classes
class_counts = Counter(weapon_classes.get(w, "other") for w in top_weapons)

print("Weapon Class Breakdown:")
for cls, count in class_counts.most_common():
    pct = count / len(top_weapons) * 100
    print(f"  {cls}: {pct:.0f}%")
```

**Class pattern implications:**

| Class Pattern | Build Implication | Example |
|---------------|-------------------|---------|
| >60% dualies | Mobility-focused, dodge-roll builds | SSU + QSJ synergy |
| >60% chargers | Positioning, low death tolerance | Anchor builds |
| >60% blasters | Burst damage, trade-happy | QR + Comeback synergy |
| >60% splatlings | Charge management, lane holding | ISM + positioning |
| Diverse classes | Class is NOT the clustering factor | Check sub or special |

---

#### Step 4: Determine if Pattern is CAUSAL or SPURIOUS

**This is the critical step.** A strong pattern in ANY component could be causal or spurious.

| Pattern Type | Evidence | Implication |
|--------------|----------|-------------|
| **CAUSAL** | Kit component explains build philosophy | Include in label rationale |
| **SPURIOUS** | Weapons share other traits that better explain clustering | Don't emphasize that component |

**Questions to determine causality:**

1. **Does the kit component align with decoder output?**
   - Decoder promotes SCU/SS/SPU + aggressive specials → Special farming is likely causal
   - Decoder promotes ISS/SPU + shared sub weapon → Sub spam is likely causal
   - Decoder promotes SSU/QSJ + all dualies → Weapon class mobility is likely causal

2. **Do weapons share OTHER traits that better explain the clustering?**
   - All dualies with aggressive specials → Is it the CLASS or the SPECIAL?
   - Test: Do other dualies (without aggressive specials) also cluster here?

3. **Does the build philosophy make sense for this kit component?**
   - Survival builds + aggressive specials → "Stay alive to use push special" (causal)
   - Mobility builds + all dualies → "Dualies need SSU for dodge-roll play" (causal)
   - Survival builds + diverse subs/specials + all chargers → "Chargers can't trade" (class is causal)

**Example Analysis (Special-driven):**

```
Feature 14964 special breakdown: 77% aggression (Zipcaster, Booyah Bomb, Trizooka)
Build philosophy: "Balanced utility spread for survival"

Analysis:
- Decoder suppresses death-trading (Comeback, RP) ✓
- Decoder promotes survival abilities (SS, ISM) ✓
- Weapons have LOW-MED death tolerance ✓
- Weapons have aggressive push specials ✓
- Sub weapons are DIVERSE (no pattern)
- Weapon classes are DIVERSE (shooters, slosher, splatana)

Conclusion: CAUSAL - Players build for survival BECAUSE they have aggressive specials
           that require staying alive to deploy effectively.

Note: "Core weapons have aggressive push specials (77%) requiring survival to deploy"
```

**Example Analysis (Class-driven):**

```
Feature shows: 80% dualies (Dark Tetra, Dapple, Dualie Squelchers)
Decoder promotes: SSU, QSJ, RSU (mobility family)

Analysis:
- Specials are DIVERSE (not the driver)
- Subs are DIVERSE (not the driver)
- All weapons are DUALIES with dodge-roll mechanics ✓
- Dualies benefit uniquely from SSU for roll distance/recovery

Conclusion: CAUSAL - Dualies cluster because dodge-roll playstyle needs mobility
           The feature encodes "dualie mobility optimization"
```

**Counter-example (Spurious):**

```
Feature has 70% aggression specials
But: All weapons are CLOSE-range SLAYER with HIGH death tolerance
And: Decoder promotes QR, Comeback (death-trading)

Conclusion: SPURIOUS - Weapons are aggressive slayers who happen to have aggressive specials
           The special type is incidental to the slayer playstyle.
           Primary driver is ROLE (slayer), not KIT.
```

---

#### Step 5: Record findings in notes

**If pattern is CAUSAL, add to dashboard_notes:**
```
KIT PATTERN: {component} - {X}% {category/type} ({list top examples}).
INTERPRETATION: [Why this explains the build philosophy]
```

**If pattern is SPURIOUS, note briefly:**
```
KIT PATTERN: Diverse/incidental. Weapons cluster by [range/role/playstyle], not kit.
```

---

#### When to skip this phase:
- Feature is clearly mechanical (single ability stacker like "SCU_57 threshold")
- Weapons are highly diverse with no concentration in any component
- Earlier analysis already identified clear driver (e.g., single weapon dominance)

### Phase 1.8: Weapon Range/Role Classification (REQUIRED for Labels)

Before proposing any label, you MUST classify the feature's weapons by range and role. This prevents incorrect role assumptions (e.g., calling Jr./Rapid Blasters "anchors" when they're midrange).

**Step 1: Extract properties for top 5-10 core weapons from weapon-vibes.md**

| Property | Values | Label Implication |
|----------|--------|-------------------|
| RANGE | CLOSE, MID, LONG, SNIPER | Determines qualifier |
| LANE | FRONT, MID, BACK, FLEX | Confirms positioning |
| JOB | SLAYER, SUPPORT, ANCHOR, SKIRMISH, ASSASSIN | Determines role word |
| NS_FIT | CORE, GOOD, MEH, BAD, NO | Stealth vs visible |
| DEATH_TOL | HIGH, MED, LOW | Trading vs survival |

**Step 2: Find the common pattern**

If most weapons share:
- LONG/SNIPER + BACK + ANCHOR → use "Anchor" or "Backline" qualifier
- MID/LONG + MID + SKIRMISH/SUPPORT → use "Midrange" qualifier
- CLOSE/MID + FRONT + SLAYER → use "Slayer" or "Frontline" qualifier
- NO/BAD NS_FIT + LOW DEATH_TOL → "Visible" or "Positional" concept (not stealth, not trading)

**Step 3: Record in notes**

Always include weapon classification in dashboard_notes:
```
WEAPON ROLE: Midrange (MID-LONG range, SKIRMISH/SUPPORT jobs, NO/BAD NS fit, LOW death tolerance)
```

### Phase 2: Hypothesis Generation

Based on Phase 1, generate hypotheses about what the feature might encode:

**For single-family dominated features:**
- H1: Pure token detector (trivial - try to disprove)
- H2: Threshold detector (activates only at high AP)
- H3: Interaction detector (family + something else)
- H4: Weapon-conditional (family matters only for certain weapons)

**For multi-family features:**
- H1: Synergy detector (families work together)
- H2: Build archetype (strategic loadout pattern)
- H3: Playstyle indicator (aggressive, defensive, support)
- H4: Shared NEED (different builds solving the same tactical problem)

### Build NEED Framework (For Multi-Modal/Diffuse Features)

**When a feature activates on seemingly different build types, ask: "What NEED do these builds share?"**

Features can encode solutions to problems, not just correlations. Different builds may trigger the same feature because they're different answers to the same question.

**Step 1: Identify the tactical constraint these builds solve**

| Question | Example |
|----------|---------|
| What gameplay problem do these builds address? | "How to handle death for low-death-tolerance weapons" |
| What enemy behavior are they countering? | "Dealing with aggressive flankers" |
| What win condition are they enabling? | "Special pressure" or "Map control" |

**Step 2: Check weapon properties (use splatoon3-meta)**

Compare enriched weapons on these axes from `weapon-vibes.md`:
- **Ink feel**: STARVING / HUNGRY / AVERAGE / EFFICIENT / PAINTER
- **Range**: MELEE / CLOSE / MID / LONG / SNIPER
- **Ninja Squid affinity**: CORE / GOOD / MEH / BAD / NO
- **Death tolerance**: HIGH / MED / LOW
- **Role**: SLAYER / SUPPORT / ANCHOR / SKIRMISH / ASSASSIN

If all enriched weapons share properties (e.g., all HUNGRY ink + NO ninja squid + LOW death tolerance), the feature may encode a need specific to that weapon class.

**Step 3: Reframe the modes as "answers to the same question"**

**Example (Feature 13934):**
```
Mode A (12%): RP anchor builds (E-liter) - "I won't die, make their deaths hurt"
Mode B (88%): Zombie utility builds (DS) - "I will die sometimes, optimize respawns"

Shared NEED: "Death management for non-stealth, low-death-tolerance, midrange+ weapons"
Both modes are VALID ANSWERS to the same tactical question.
```

**Step 4: Label the NEED, not the modes**

Instead of: "Mixed: Zombie + RP Anchor" (describes the modes)
Label as: "Balanced Utility Axis (Non-Stealth Midline+)" (describes the need)

**Key Insight:** The model learned that these seemingly different builds share a common requirement. The feature encodes that requirement, and the modes are just different implementations.

**For weapon-specific features:**
- H1: Weapon class pattern (all shooters, all chargers, etc.)
- H2: Meta build (optimal loadout for that weapon)
- H3: Weapon-ability interaction

### Phase 3: Targeted Experiments

Run experiments to test hypotheses. **Available experiment types:**

| Type | Purpose |
|------|---------|
| `family_1d_sweep` | Activation across AP rungs for one family |
| `family_2d_heatmap` | Interaction between two families |
| `within_family_interference` | Detect error correction within a family |
| `weapon_sweep` | Activation by weapon (optionally conditioned on family) |
| `weapon_group_analysis` | Compare high vs low activation by weapon |
| `pairwise_interactions` | Synergy/redundancy between tokens |
| `token_influence_sweep` | Identify enhancers and suppressors across all tokens |

## ⚠️ CRITICAL: Iterative Conditional Testing Protocol

**1D sweeps can be MISLEADING for secondary abilities.** When a feature has a strong primary driver:

### The Problem

1D sweep for secondary ability (e.g., QR) across ALL contexts might show **delta ≈ 0**

**Why this happens:**
- Most contexts have LOW primary driver (e.g., low SCU) → activation already near zero
- Secondary ability can't suppress what's already zero
- The few high-primary contexts get drowned out in the average

**Example (Feature 18712):**
```
QR 1D sweep (all contexts): mean_delta = -0.0006 → "QR has no effect" ❌ WRONG!
SCU × QR 2D heatmap:
  - At SCU_15: QR_0=0.13, QR_12=0.04 → QR suppresses 70%! ✅
  - At SCU_29: QR_0=0.15, QR_12=0.04 → QR suppresses 74%! ✅
```

### The Solution: Iterative 2D Testing

**Protocol for features with a strong primary driver:**

```
1. Confirm primary driver with 1D sweep
   └─ If monotonic response confirmed → proceed to step 2

2. For EACH correlated ability in overview (top 5-10):
   └─ Run 2D heatmap: PRIMARY × SECONDARY
   └─ Check activation at EACH primary level
   └─ Look for:
      - Suppression: secondary reduces activation at high primary
      - Synergy: secondary boosts activation at high primary
      - Spurious: no conditional effect (correlation was coincidence)

3. Group findings by semantic category:
   └─ Death-mitigation (QR, SS, CB): all suppress? → "death-averse"
   └─ Mobility (SSU, RSU): all enhance? → "mobility-synergistic"
   └─ Efficiency (ISM, ISS): mixed? → test individually
```

### 2D Heatmap Interpretation Guide

| Pattern | Interpretation |
|---------|----------------|
| Peak at (high_X, 0_Y) | Y is a **suppressor** |
| Peak at (high_X, high_Y) | Y is a **synergy** |
| Flat across Y at each X | Y has **no conditional effect** (spurious) |
| Non-monotonic in X at some Y | **Interference** pattern |

### Heatmap Cell Validity Check

**Before drawing conclusions from heatmap cells, check the cell metadata:**

Each cell in heatmap output includes:
- `n`: Number of valid samples in this cell
- `std`: Standard deviation of activations
- `stderr`: Standard error (std / sqrt(n)) - **new field**

| n (samples) | Interpretation |
|-------------|----------------|
| null/0 | Impossible combination (constraint violation) - **don't interpret** |
| 1-4 | Very weak evidence - note uncertainty in conclusions |
| 5-20 | Moderate evidence - interpret with caution |
| 20+ | Strong evidence - interpret confidently |

**High stderr (>0.1)** indicates high variance - the mean may not be reliable.

**Anti-patterns to avoid:**
- Drawing conclusions from cells with n < 5
- Claiming "peak at X=57, Y=29" when that cell has n=2
- Ignoring null cells (they represent impossible ability combinations)

**Example interpretation:**
```
Cell (ISM=51, IRU=29): mean=0.35, n=3, stderr=0.08
→ "ISM=51 with IRU=29 shows high activation, but n=3 means this could be noise"

Cell (ISM=51, IRU=0): mean=0.35, n=45, stderr=0.02
→ "ISM=51 without IRU shows reliable high activation (n=45)"
```

### When to Use 2D vs 1D

| Scenario | Use 1D | Use 2D |
|----------|--------|--------|
| Testing primary driver | ✅ | - |
| Testing secondary abilities | ❌ MISLEADING | ✅ REQUIRED |
| Looking for interactions | - | ✅ |
| Confirming suppressor hypothesis | - | ✅ |
| Quick initial scan | ✅ (with caution) | - |

### Template: Death-Aversion Test Battery

For single-family dominated features, always test death-mitigation:

```bash
# Test 1: Primary × Quick Respawn
poetry run python -m splatnlp.mechinterp.cli.runner_cli heatmap \
    --feature-id {ID} --family-x {PRIMARY} --family-y quick_respawn \
    --rungs-x 0,6,15,29,41,57 --rungs-y 0,6,12,21,29

# Test 2: Primary × Special Saver
poetry run python -m splatnlp.mechinterp.cli.runner_cli heatmap \
    --feature-id {ID} --family-x {PRIMARY} --family-y special_saver \
    --rungs-x 0,6,15,29,41,57 --rungs-y 0,3,6,12,21

# Test 3: Primary × Comeback (binary ability - use binary subcommand for this)
poetry run python -m splatnlp.mechinterp.cli.runner_cli binary \
    --feature-id {ID} --model ultra
```

If ALL three show suppression at Y>0, label includes "death-averse"

### Template: Error-Correction Detection

If 1D sweeps show **small deltas** or effects **only in unusual rung combinations**, test for error-correction behavior:

```python
import polars as pl
from splatnlp.mechinterp.skill_helpers import load_context

ctx = load_context('ultra')
df = ctx.db.get_all_feature_activations_for_pagerank(FEATURE_ID)

# Get token IDs for high and low rungs
# Example: SCU_57 (high) and SCU_3 (low)
high_rung_id = ctx.vocab['special_charge_up_57']
low_rung_id = ctx.vocab['special_charge_up_3']

# Compare activation when low rung is present vs missing (among high-rung builds)
high_with_low = df.filter(
    pl.col('ability_input_tokens').list.contains(high_rung_id) &
    pl.col('ability_input_tokens').list.contains(low_rung_id)
)
high_without_low = df.filter(
    pl.col('ability_input_tokens').list.contains(high_rung_id) &
    ~pl.col('ability_input_tokens').list.contains(low_rung_id)
)

mean_with = high_with_low['activation'].mean()
mean_without = high_without_low['activation'].mean()

print(f"High rung WITH low rung present: {mean_with:.4f} (n={len(high_with_low)})")
print(f"High rung WITHOUT low rung: {mean_without:.4f} (n={len(high_without_low)})")
print(f"Delta: {mean_without - mean_with:+.4f}")

# If WITHOUT > WITH, feature fires when prerequisite is MISSING = error correction!
```

**Signs of error-correction:**

| Pattern | Interpretation | Label Style |
|---------|----------------|-------------|
| Higher activation when low rung MISSING | "Explains away" missing evidence | "Error-Correction: {FAMILY}" |
| Only fires on weird rung combos | OOD detector | "OOD Detector: {PATTERN}" |
| Negative interactions in 2D heatmaps | Within-family interference | "Interference Feature: {FAMILY}" |

**Test for within-family interference (CRITICAL for single-family):**
```bash
poetry run python -m splatnlp.mechinterp.cli.runner_cli family-sweep \
    --feature-id {FEATURE_ID} --family {FAMILY} --model {MODEL}
# Check for non-monotonic response patterns in the output
```

**Test for interactions (2D heatmap):**
```bash
poetry run python -m splatnlp.mechinterp.cli.runner_cli heatmap \
    --feature-id {FEATURE_ID} --family-x {FAMILY_A} --family-y {FAMILY_B} --model {MODEL}
```

**Test for weapon specificity:**
```bash
poetry run python -m splatnlp.mechinterp.cli.runner_cli weapon-sweep \
    --feature-id {FEATURE_ID} --model {MODEL} --top-k 20 --min-examples 10
```

**CHECKPOINT: After weapon_sweep, check for dominant weapon pattern:**

If weapon_sweep diagnostics show "DOMINANT WEAPON" warning (one weapon has >2x delta of second):

1. **Run kit_sweep** to analyze by sub weapon and special weapon:
```bash
poetry run python -m splatnlp.mechinterp.cli.runner_cli kit-sweep \
    --feature-id {FEATURE_ID} --model {MODEL} --top-k 10 --analyze-combinations
```

2. **Use splatoon3-meta skill** to look up the dominant weapon's kit:
   - Read `.claude/skills/splatoon3-meta/references/weapons.md`
   - Find the weapon's sub weapon and special weapon

3. **Cross-reference** other high-activation weapons:
   - Do they share the same sub weapon?
   - Do they share the same special weapon?
   - If yes, the feature may encode **kit behavior** not weapon behavior

4. **Update hypothesis** based on findings:
   - If shared sub: Feature may encode sub weapon playstyle
   - If shared special: Feature may encode special spam/farming
   - If no kit pattern: Feature is truly weapon-specific

**Example**: Feature 18712 shows Octobrush Nouveau dominant. Kit lookup reveals Squid Beakon + Ink Storm. Other high weapons (Rapid Blaster, Range Blaster) also have "special-dependent" characteristics per meta → Feature encodes "SCU for Ink Storm spam" not just "Octobrush".

**Test for threshold effects:**
- Compare low-rung vs high-rung responses
- Look for non-linear jumps in activation
- Check if certain rungs REDUCE activation (interference)

### Phase 4: Synthesis

Combine findings into a coherent interpretation:

1. **What triggers activation?** (tokens, combinations, weapons)
2. **Is there structure beyond simple detection?** (interactions, thresholds)
3. **What gameplay concept does this represent?**
4. **Why would the model learn this?** (predictive value for recommendations)

### Phase 5: Label Proposal

Propose a label at the appropriate level:

| Complexity | Label Type | Example |
|------------|------------|---------|
| Trivial | Token detector | "SCU Presence" (avoid if possible) |
| Simple | Threshold detector | "High SCU Investment (29+ AP)" |
| Moderate | Interaction | "SCU + Mobility Combo" |
| Strategic | Build archetype | "Special Spam Slayer Kit" |
| Tactical | Playstyle | "Aggressive Frontline Build" |

### Label Specificity by Category

**The label's specificity should match its concept level:**

| Category | Specificity | Style | Examples |
|----------|-------------|-------|----------|
| **mechanical** | Terse | Token-focused, technical | "SCU Threshold 29+", "ISM Stacker" |
| **tactical** | Mid-level | Ability combos, weapon synergies | "Zombie Slayer Dualies", "Beacon Support Kit" |
| **strategic** | High-concept | Playstyle, gameplay philosophy | "Positional Survival - Midrange", "Aggressive Reentry" |

**Why this matters:**
- Mechanical features encode low-level patterns → label should be precise and technical
- Tactical features encode build strategies → label should name the strategy
- Strategic features encode gameplay philosophies → label should capture the "why"

**Examples by level:**

```
Feature encodes "SCU above 29 AP threshold"
→ Category: mechanical
→ Label: "SCU Threshold 29+" (terse, specific)

Feature encodes "QR + Comeback + Stealth Jump on dualies"
→ Category: tactical
→ Label: "Zombie Slayer Dualies" (names the combo + weapon)

Feature encodes "survive through positioning, not stealth or trading"
→ Category: strategic
→ Label: "Positional Survival - Midrange" (high-concept + role)
```

### Strategic Label Quality Checklist

Before finalizing a label, verify:

1. **Concept over tokens**: Does the label describe a GAMEPLAY CONCEPT, not just list abilities?
   - BAD: "SSU + ISM + SRU Kit", "Swim Efficiency Kit"
   - GOOD: "Positional Survival", "Aggressive Reentry"

2. **Positive framing**: Does the label describe what the feature IS, not just what it avoids?
   - BAD: "Death-Averse Efficiency", "Anti-Stealth Build"
   - GOOD: "Positional Survival", "Visible Zone Control"

3. **The "why" test**: Can you answer "why would a player build this?"
   - If answer is "to have SSU and ISM" → label is too mechanical
   - If answer is "to survive through positioning at midrange" → label captures concept

4. **Range/role qualifier**: Have you verified weapon range (Phase 1.8) and added appropriate qualifier?
   - Backline (SNIPER/LONG + ANCHOR) → "- Anchor" or "- Backline"
   - Midrange (MID/LONG + SUPPORT/SKIRMISH) → "- Midrange"
   - Frontline (CLOSE/MID + SLAYER) → "- Slayer" or "- Frontline"

### Strategic Label Format

**Prefer: "[Concept] - [Qualifier]"**

| Concept Examples | What it captures |
|------------------|------------------|
| Positional Survival | Stay alive through positioning, not stealth/trading |
| Aggressive Reentry | Pressure through fast respawn (zombie) |
| Stealth Approach | Win through concealment (NS builds) |
| Special Pressure | Win through special uptime |
| Lane Persistence | Hold lanes through sustain |

| Qualifier Examples | When to use |
|--------------------|-------------|
| Midrange | MID-range weapons, SKIRMISH/SUPPORT jobs |
| Anchor | LONG/SNIPER range, ANCHOR job, chargers/splatlings |
| Slayer | CLOSE/MID range, SLAYER job, aggressive weapons |
| Support | SUPPORT job, team utility focus |
| (Weapon Class) | When specific to dualies, blasters, etc. |

### Label Anti-Patterns to Avoid

| Anti-Pattern | Example | Why It's Bad | Better Label |
|--------------|---------|--------------|--------------|
| Token listing | "SSU + ISM Kit" | Describes tokens, not purpose | "Positional Survival" |
| Negation-only | "Death-Averse" | Describes avoidance, not identity | "Positional Survival" |
| Wrong role | "Anchor" for Jr./Rapid | Anchor implies backline chargers | "- Midrange" |
| Too generic | "Utility Build" | Could mean anything | "Positional Survival - Midrange" |
| Flanderized | Based on top 100 only | Captures tail, not core concept | Check core region first |

### Phase 6: Deeper Dive (For Thorny Features)

**When to use:** If the standard deep dive (Phases 1-5) didn't produce a clear interpretation:
- All scaling effects weak (max_delta < 0.03)
- No clear primary driver
- Conflicting signals from different experiments
- Feature seems important (high contribution to outputs) but unclear why

**The Deeper Dive uses the hypothesis/state management system** for systematic exploration:

#### Step 1: Initialize Research State

```python
from splatnlp.mechinterp.state import ResearchState, Hypothesis

state = ResearchState(feature_id=FEATURE_ID, model_type="ultra")

# Add competing hypotheses based on what you've observed
state.add_hypothesis(Hypothesis(
    id="h1",
    description="Feature encodes weapon-specific pattern for Dapple Nouveau",
    status="pending"
))
state.add_hypothesis(Hypothesis(
    id="h2",
    description="Feature encodes binary ability package (Stealth + Comeback)",
    status="pending"
))
state.add_hypothesis(Hypothesis(
    id="h3",
    description="Feature has high decoder weights despite weak activation effects",
    status="pending"
))
```

#### Step 2: Check Decoder Weights

For "weak activation" features, check if they have high influence via decoder weights:

```python
# Load SAE decoder weights
import torch
sae_path = '/mnt/e/dev_spillover/SplatNLP/sae_runs/run_20250704_191557/sae_model_final.pth'
sae_checkpoint = torch.load(sae_path, map_location='cpu', weights_only=True)
decoder_weight = sae_checkpoint['decoder.weight']  # [512, 24576]

# Get this feature's decoder weights to output space
feature_decoder = decoder_weight[:, FEATURE_ID]  # [512]

# Check magnitude
print(f"Decoder weight L2 norm: {torch.norm(feature_decoder):.4f}")
print(f"Max absolute weight: {torch.abs(feature_decoder).max():.4f}")

# Compare to other features
all_norms = torch.norm(decoder_weight, dim=0)
percentile = (all_norms < torch.norm(feature_decoder)).float().mean() * 100
print(f"Percentile among all features: {percentile:.1f}%")
```

If decoder weights are high (>75th percentile), the feature may be important despite weak activation effects.

#### Step 3: Decoder Output Analysis (CRITICAL for Diffuse Features)

**When activation analysis doesn't yield a clean interpretation, analyze what the feature RECOMMENDS.**

This technique asks: "What does this feature push the model to predict?" rather than "What activates this feature?"

**Use the decoder CLI:**

```bash
cd /root/dev/SplatNLP

# Quick output influence check
poetry run python -m splatnlp.mechinterp.cli.decoder_cli output-influence \
    --feature-id {FEATURE_ID} \
    --model ultra \
    --top-k 15

# Check decoder weight importance
poetry run python -m splatnlp.mechinterp.cli.decoder_cli weight-percentile \
    --feature-id {FEATURE_ID} \
    --model ultra
```

See **mechinterp-decoder** skill for full documentation.

**Interpretation Guide:**

| Output Pattern | Interpretation |
|----------------|----------------|
| Promotes low-AP tokens (_3, _6) | "Recommend light investment" |
| Promotes high-AP tokens (_51, _57) | "Recommend heavy stacking" |
| Suppresses high-AP tokens | "Anti-stacking / balanced build" |
| Promotes death-mitigation (QR, CB, SS) | "Recommend zombie/respawn optimization" |
| Suppresses death-mitigation | "Death-averse / stay alive" |

**Example (Feature 13934):**
```
PROMOTES: respawn_punisher (+0.23), comeback (+0.16), QSJ_6 (+0.15), IA_3 (+0.14), ISM_6 (+0.13)
SUPPRESSES: RSU_57 (-0.30), QR_57 (-0.25), RSU_51 (-0.24)

Interpretation: Feature recommends "balanced utility spread with low-AP investments"
               and DISCOURAGES heavy stacking of any single ability.
```

**When to use decoder output analysis:**
- Activation analysis shows multi-modal or diffuse patterns
- No single signature covers >50% of core
- Feature seems "confused" between different build types
- You want to understand the feature's PURPOSE, not just what triggers it

**Key Insight:** A feature can activate on seemingly different builds because they share the same NEED. The output analysis reveals what the feature is recommending, which may unify apparently contradictory activation patterns.

### Decoder Output Semantic Grouping (CRITICAL for Labels)

After running decoder output analysis, group promoted/suppressed tokens by MEANING, not just family:

| Semantic Group | Token Families | Gameplay Meaning |
|----------------|----------------|------------------|
| **Mobility** | SSU, RSU | How you reposition |
| **Survival** | BRU, IRU, RES, QR, SS, RP | How you stay alive |
| **Efficiency** | ISM, ISS, IRU | How you sustain pressure |
| **Lethality** | IA, MPU, BPU (bomb damage) | How you get kills |
| **Special-Focus** | SCU, SS, SPU, Tenacity | How you use specials |
| **Stealth** | NS, (high SSU) | How you approach unseen |
| **Death-Trading** | QR, CB, SJ, SS | How you weaponize respawn |

**Abbreviation Key:**
- SSU = Swim Speed Up, RSU = Run Speed Up
- BRU = Bomb (Sub) Resistance Up, RES = Ink Resistance Up
- IRU = Ink Recovery Up, ISM = Ink Saver Main, ISS = Ink Saver Sub
- BPU = Bomb (Sub) Power Up, SPU = Special Power Up
- SCU = Special Charge Up, SS = Special Saver
- QR = Quick Respawn, CB = Comeback, SJ = Stealth Jump
- IA = Intensify Action, MPU = Main Power Up, NS = Ninja Squid, RP = Respawn Punisher

**Then ask:** "What COMBINATION of groups defines this feature?"

| Promoted Groups | Suppressed Groups | Strategic Concept |
|-----------------|-------------------|-------------------|
| Mobility + Survival + Efficiency | Death-Trading, Stealth | **Positional Survival** |
| Death-Trading + Mobility | Survival | **Zombie/Aggressive Reentry** |
| Stealth + Mobility | - | **Stealth Approach** |
| Special-Focus + Efficiency | Mobility | **Special Farming** |
| Lethality + Mobility | Efficiency | **Aggressive Slayer** |

**This semantic grouping directly informs the strategic label.**

### Post-Decoder Sweep Rule

**After decoder output analysis, verify the top promoted/suppressed families with causal 1D sweeps.**

The decoder tells you what the feature RECOMMENDS, but not whether it's causally driven by those tokens. To validate:

1. **Identify top 2 promoted families** from decoder output (highest positive contributions)
2. **Identify top 2 suppressed families** from decoder output (most negative contributions)
3. **Run 1D sweeps** for any not yet tested in Phase 2

| Decoder Shows | Test With | Expected If Valid |
|---------------|-----------|-------------------|
| BRU highly promoted | `family_1d_sweep` BRU | Positive delta with BRU levels |
| RSU suppressed | `family_1d_sweep` RSU | Negative delta or flat |

**Example:** Feature 10938 decoder showed BRU heavily promoted (+0.126, +0.120, +0.108 for different rungs), but initial sweeps only tested SSU/ISM. Should have run:
```bash
# Missing sweep that would validate decoder findings
poetry run python -m splatnlp.mechinterp.cli.runner_cli run-spec \
    --spec '{"type": "family_1d_sweep", "variables": {"family": "bomb_resistance_up"}}' \
    --feature-id 10938 --model ultra
```

**Anti-pattern:** Trusting decoder output without causal validation. Decoder weights show correlation to output tokens, not causal effect of input tokens.

#### Step 4: Run Targeted Experiments

Based on hypotheses, run specific tests:

```python
# Log experiments and findings to state
state.add_evidence(
    hypothesis_id="h1",
    experiment_type="weapon_sweep",
    finding="37% Dapple Nouveau, but also 10% .96 Gal Deco - not single-weapon",
    supports=False
)

state.add_evidence(
    hypothesis_id="h3",
    experiment_type="decoder_weight_check",
    finding="Decoder L2 norm: 0.89 (92nd percentile) - HIGH despite weak activation",
    supports=True
)
```

#### Step 5: Synthesize

```python
# Review all evidence
state.summarize()

# Update hypothesis statuses
state.update_hypothesis("h1", status="rejected")
state.update_hypothesis("h3", status="supported")

# Propose final interpretation
state.set_conclusion(
    "Feature has weak activation effects but high decoder weights. "
    "It acts as a 'fine-tuning' feature that makes small but important "
    "adjustments to output probabilities."
)
```

#### When Deeper Dive is Complete

The state object provides an audit trail of:
- What hypotheses were considered
- What experiments were run
- What evidence was found
- Why the final interpretation was chosen

This is useful for:
- Revisiting the feature later
- Explaining the interpretation to others
- Identifying if new evidence should change the interpretation

## Decision Trees

### Single-Family Dominated Feature

```
1. Run within_family_interference to check for error correction
   └─ If interference found → "Error-Correcting {FAMILY} Detector"
   └─ If enhancement patterns → "{FAMILY} Stacker (synergistic)"
   └─ If neutral → continue

2. Check for non-monotonic 1D response
   └─ If drops at certain rungs → investigate interference
   └─ If monotonic with threshold → "High {FAMILY} Investment"
   └─ If monotonic with no threshold → probably trivial

3. Run weapon_sweep to check weapon specificity
   └─ If weapon-concentrated → run weapon_group_analysis
   └─ If weapon-specific patterns → "{WEAPON_CLASS} + {FAMILY}"

4. Run 2D sweep with second-ranked family
   └─ If interaction effect → "{FAMILY_A} + {FAMILY_B} Combo"
   └─ If no interaction → try third family

5. If all trivial → label as "{FAMILY} Stacker" with note "simple detector"
```

### Multi-Family Feature

```
1. Check if families are related
   └─ All mobility (SSU, RSU, QSJ) → "Mobility Kit"
   └─ All ink efficiency (ISM, ISS, IRU) → "Efficiency Kit"
   └─ Mixed → continue

2. Run pairwise interaction analysis
   └─ Positive synergy → "Synergistic Build"
   └─ Redundancy → "Alternative Paths"

3. Check weapon breakdown
   └─ Weapon class pattern → "{CLASS} Optimal Build"

4. Consider strategic meaning
   └─ What playstyle does this combination enable?
```

## Example Investigation

**Feature 18712 (Deep Analysis):**

1. **Overview**: SCU 31%, SSU 11%, ISS 10% → Single-family dominated
2. **Hypothesis**: Could be SCU + something, or just trivial SCU detector
3. **2D Heatmap (SCU × SSU)**: Peak at SCU=57, SSU=0. Non-monotonic drops visible!
   - SCU 6→12: DROP of 0.02 (unexpected)
   - SCU 15→21: DROP of 0.01
4. **Interference Analysis**:
   - SCU_12 REDUCES SCU_51 signal by 0.10 (interference!)
   - SCU_15 ENHANCES SCU_51 signal by 0.12 (synergy!)
5. **Weapon Analysis**: Effect varies by weapon
   - weapon_id_50: SCU_3 reduces SCU_15 (-0.08)
   - weapon_id_7020: SCU_3 enhances SCU_15 (+0.03)
6. **Interpretation**: Feature detects "clean" high-SCU builds.
   - Low rungs (SCU_3, SCU_12) can contaminate the signal
   - Effect is weapon-dependent
7. **Label**: "SCU Purity Detector (weapon-conditional)" - NOT trivial!

**Key Insight**: What looked like a simple "SCU detector" actually encodes
complex error-correction behavior. Always check for interference!

## Commands Summary

```bash
# Phase 1: Overview (with extended analyses)
poetry run python -m splatnlp.mechinterp.cli.overview_cli \
    --feature-id {ID} --model ultra --top-k 20

# Phase 1 with extended analyses (enrichment, regions, binary, kit)
poetry run python -m splatnlp.mechinterp.cli.overview_cli \
    --feature-id {ID} --model ultra --all

# Phase 3a: 1D sweep for dominant family (direct subcommand)
poetry run python -m splatnlp.mechinterp.cli.runner_cli family-sweep \
    --feature-id {ID} --family {FAMILY} --model ultra

# Phase 3b: 2D heatmap for interactions (direct subcommand)
poetry run python -m splatnlp.mechinterp.cli.runner_cli heatmap \
    --feature-id {ID} --family-x {FAMILY_A} --family-y {FAMILY_B} --model ultra

# Phase 3c: Weapon sweep (direct subcommand)
poetry run python -m splatnlp.mechinterp.cli.runner_cli weapon-sweep \
    --feature-id {ID} --model ultra --top-k 20

# Phase 3d: Kit sweep (if dominant weapon detected)
poetry run python -m splatnlp.mechinterp.cli.runner_cli kit-sweep \
    --feature-id {ID} --model ultra --analyze-combinations

# Phase 3e: Binary ability analysis
poetry run python -m splatnlp.mechinterp.cli.runner_cli binary \
    --feature-id {ID} --model ultra

# Phase 3f: Core coverage analysis
poetry run python -m splatnlp.mechinterp.cli.runner_cli coverage \
    --feature-id {ID} --tokens {TOKEN1},{TOKEN2}

# Phase 1.7.5: Kit Component Analysis (see skill for full code)
# After weapon sweep, check for patterns in: sub weapons, specials, or weapon class
# For any concentrated pattern, determine if CAUSAL (explains build) or SPURIOUS (incidental)

# Phase 5: Set label
poetry run python -m splatnlp.mechinterp.cli.labeler_cli label \
    --feature-id {ID} --name "{LABEL}" --category {tactical|strategic|mechanical}
```

## Labeling Categories

- **mechanical**: Low-level patterns (token presence, simple combinations)
- **tactical**: Mid-level patterns (build synergies, weapon kits)
- **strategic**: High-level patterns (playstyles, meta concepts)

## See Also

- **mechinterp-overview**: Initial feature assessment (now includes bottom tokens)
- **mechinterp-runner**: Execute experiments (includes `core_coverage_analysis` and `decoder_output_analysis`)
- **mechinterp-decoder**: Decoder weight analysis - what features recommend (USE for diffuse/heterogeneous features)
- **mechinterp-next-step-planner**: Generate experiment specs
- **mechinterp-labeler**: Save labels
- **mechinterp-glossary-and-constraints**: Domain reference
- **mechinterp-ability-semantics**: Ability semantic groupings (check AFTER hypotheses)
- **splatoon3-meta**: Weapon archetypes, kit lookups, meta knowledge (USE for weapon pattern interpretation)
