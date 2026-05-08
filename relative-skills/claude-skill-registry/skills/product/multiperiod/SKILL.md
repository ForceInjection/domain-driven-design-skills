---
name: multiperiod
description: Per-meal optimization for balanced meals. Use when user wants to control calories per meal, avoid huge snacks, balance breakfast/lunch/dinner, or needs per-meal protein targets. Triggers on "per meal", "meal-by-meal", "balanced meals", "snack limits", "breakfast protein", "lunch calories".
---

# Multi-Period Meal Optimization

This skill creates meal plans with per-meal constraints, ensuring balanced distribution of calories and nutrients across breakfast, lunch, dinner, and snacks. This prevents issues like 995-calorie "snacks" that occur with post-hoc meal allocation.

## Template-Based vs Multi-Period

**Consider template-based first** (`--template --pattern X`):
- Produces more realistic meals (1 protein + 1 legume + vegetables per meal)
- Different foods at each meal by design
- Simpler to use: `uv run llmn optimize --pattern pescatarian --template --json`

**Use multi-period when**:
- You need exact per-meal calorie/protein control (e.g., "exactly 500-550 kcal at breakfast")
- You want to restrict specific foods to specific meals (e.g., "almonds only as snack")
- You need equi-calorie constraints (e.g., "lunch within 100 kcal of dinner")
- Template-based doesn't meet your specific nutrient requirements

## When to Use Multi-Period

Use multi-period optimization when:
- User wants **exact** calorie limits per meal (template gives approximate)
- User needs protein targets at each meal (e.g., 30g+ at breakfast)
- User wants lunch and dinner to be similar in calories (equi-calorie)
- User wants to restrict certain foods to certain meals (eggs→breakfast)

## Quick Start

For basic multi-period optimization with auto-derived meal targets:

```bash
uv run llmn optimize --multiperiod --json
```

This uses default splits: Breakfast 25%, Lunch 35%, Dinner 35%, Snack 5%.

## Workflow

### Step 1: Gather Daily Targets

First, get the user's overall daily targets:
- Total daily calories (min/max)
- Total daily protein minimum
- Any other daily nutrient constraints

### Step 2: Define Per-Meal Targets

Ask the user about meal distribution. Offer these presets:

**Balanced (default)**:
- Breakfast: 25% of calories
- Lunch: 35% of calories
- Dinner: 35% of calories
- Snack: 5% of calories (~100-150 kcal)

**Front-loaded** (big breakfast):
- Breakfast: 35% of calories
- Lunch: 30% of calories
- Dinner: 30% of calories
- Snack: 5% of calories

**Back-loaded** (big dinner):
- Breakfast: 20% of calories
- Lunch: 30% of calories
- Dinner: 45% of calories
- Snack: 5% of calories

For a 2000 kcal diet with "Balanced" split:
- Breakfast: 450-550 kcal
- Lunch: 650-750 kcal
- Dinner: 650-750 kcal
- Snack: 50-150 kcal

### Step 3: Per-Meal Protein (Optional)

Ask if user wants per-meal protein targets:
- Breakfast protein minimum (suggest 25-30g)
- Lunch protein minimum (suggest 40-50g)
- Dinner protein minimum (suggest 40-50g)
- Snack protein (usually 5-10g)

### Step 4: Create Multi-Period Profile

Create a YAML profile at `/tmp/multiperiod_profile.yaml`:

```yaml
name: multiperiod_custom
description: "Multi-period optimization with per-meal constraints"

# Daily totals (linking constraints)
calories:
  min: <daily_cal_min>
  max: <daily_cal_max>

nutrients:
  protein:
    min: <daily_protein_min>
  fiber:
    min: 30

# Per-meal structure (triggers multi-period mode)
meals:
  breakfast:
    calories:
      min: <breakfast_cal_min>
      max: <breakfast_cal_max>
    nutrients:
      protein:
        min: <breakfast_protein_min>

  lunch:
    calories:
      min: <lunch_cal_min>
      max: <lunch_cal_max>
    nutrients:
      protein:
        min: <lunch_protein_min>

  dinner:
    calories:
      min: <dinner_cal_min>
      max: <dinner_cal_max>
    nutrients:
      protein:
        min: <dinner_protein_min>

  snack:
    calories:
      min: 50
      max: 200  # Keep snacks small!

include_tags:
  - staple

options:
  max_grams_per_food: 400
```

### Step 5: Add Optional Constraints

**Equi-calorie constraint** (lunch ≈ dinner):
```yaml
equicalorie:
  - meals: [lunch, dinner]
    tolerance: 100  # Within 100 kcal of each other
```

**Food-meal affinity** (restrict foods to specific meals):
```yaml
food_meal_rules:
  171287: [breakfast]     # Eggs only at breakfast
  170567: [snack]         # Almonds only as snack
  175167: [lunch, dinner] # Salmon for lunch/dinner only
```

### Step 6: Run Optimization

```bash
uv run llmn optimize --file /tmp/multiperiod_profile.yaml --json
```

### Step 7: Present Results

The JSON output has a `meals` structure:

```json
{
  "data": {
    "meals": [
      {
        "meal_type": "breakfast",
        "foods": [...],
        "total_calories": 480,
        "total_protein": 32
      },
      {
        "meal_type": "snack",
        "foods": [...],
        "total_calories": 145,  // Now properly constrained!
        "total_protein": 5
      }
    ],
    "daily_totals": {...}
  }
}
```

Present each meal separately with its foods and totals.

### Step 8: Handle Infeasibility

Multi-period has more constraints, so infeasibility is more common. Check for:

1. **Per-meal minimums exceed daily maximum**:
   "Your per-meal calorie minimums sum to 2500 kcal but daily max is 2000 kcal"
   → Reduce per-meal minimums

2. **Per-meal maximums below daily minimum**:
   "Your per-meal calorie maximums sum to 1500 kcal but daily min is 1800 kcal"
   → Increase per-meal maximums

3. **Protein constraints too tight**:
   "Can't get 50g protein at breakfast with available foods"
   → Reduce breakfast protein or add high-protein breakfast foods

The optimizer's `infeasibility_diagnosis` field explains the conflict.

## Example Profiles

### Weight Loss with Balanced Meals (1800 kcal)

```yaml
calories:
  min: 1700
  max: 1900

nutrients:
  protein:
    min: 150

meals:
  breakfast:
    calories: {min: 400, max: 500}
    nutrients: {protein: {min: 30}}
  lunch:
    calories: {min: 550, max: 650}
    nutrients: {protein: {min: 45}}
  dinner:
    calories: {min: 550, max: 650}
    nutrients: {protein: {min: 45}}
  snack:
    calories: {min: 50, max: 150}

equicalorie:
  - meals: [lunch, dinner]
    tolerance: 75
```

### High-Protein Muscle Building (2800 kcal)

```yaml
calories:
  min: 2700
  max: 2900

nutrients:
  protein:
    min: 200

meals:
  breakfast:
    calories: {min: 600, max: 750}
    nutrients: {protein: {min: 50}}
  lunch:
    calories: {min: 800, max: 950}
    nutrients: {protein: {min: 60}}
  dinner:
    calories: {min: 800, max: 950}
    nutrients: {protein: {min: 60}}
  snack:
    calories: {min: 200, max: 350}
    nutrients: {protein: {min: 20}}
```

## Commands Reference

```bash
# Quick multi-period with auto-derived targets
uv run llmn optimize --multiperiod --json

# Multi-period with custom profile
uv run llmn optimize --file /tmp/multiperiod_profile.yaml --json

# With verbose output (shows constraint matrices)
uv run llmn optimize --file /tmp/multiperiod_profile.yaml --verbose

# With explicit food IDs (bypass tag filtering)
uv run llmn optimize --multiperiod --foods 175167,171287,172421 --json
```

## Tips

1. **Start simple**: Use `--multiperiod` flag first, then customize with a profile
2. **Check the math**: Per-meal calorie ranges must sum to cover daily range
3. **Read the diagnosis**: Infeasibility messages are specific and actionable
4. **Snacks are small**: Keep snack max at 150-200 kcal to avoid the "995 cal snack" problem
5. **Equi-calorie helps**: Requiring lunch ≈ dinner creates more balanced days
