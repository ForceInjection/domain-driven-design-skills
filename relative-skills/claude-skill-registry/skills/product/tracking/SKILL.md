---
name: tracking
description: Weight tracking and TDEE learning. Use when user wants to log weight, track progress, check their trend, see how their diet is working, or get adaptive calorie targets. Triggers on "log my weight", "track weight", "how am I doing", "check my progress", "TDEE", "am I losing weight", "weight trend".
---

# Weight Tracking and Adaptive TDEE Learning

This skill helps users track their weight and learn their personalized TDEE (Total Daily Energy Expenditure) using:
- **Hacker's Diet EMA**: Exponentially smoothed moving average to filter out daily noise (water, gut contents, scale error)
- **Kalman Filter**: Learns the deviation between actual TDEE and Mifflin-St Jeor estimate

## Quick Commands

```bash
# Log today's weight
uv run llmn weight add 184.2

# Log weight for a specific date
uv run llmn weight add 183.8 --date 2025-12-27

# View weight history with EMA trends
uv run llmn weight list --days 30

# Log planned calorie intake
uv run llmn calories log 1900

# Update TDEE estimate (runs Kalman filter)
uv run llmn tdee estimate

# Show comprehensive progress report
uv run llmn tdee progress

# Get adaptive calorie targets based on current progress
uv run llmn tdee targets
```

## Workflow

### Step 1: Check if User Has a Profile

```bash
uv run llmn user show
```

If no profile exists, create one:

```bash
uv run llmn user create --age 38 --sex male --height 72 --activity moderate
uv run llmn user update --weight 185 --goal "fat_loss:165"
```

**Activity levels**: `sedentary`, `lightly_active`, `moderate`, `active`, `very_active`

### Step 2: Log Weight

When the user provides a weight measurement:

```bash
uv run llmn weight add <weight_in_lbs>

# With specific date
uv run llmn weight add <weight> --date YYYY-MM-DD
```

The system automatically computes the EMA trend using the Hacker's Diet formula:
```
trend_n = trend_{n-1} + 0.1 × (weight_n - trend_{n-1})
```

This filters out daily noise with a ~10-day time constant.

### Step 3: Log Planned Calories

If the user mentions what they ate or their meal plan calories:

```bash
uv run llmn calories log <calories>

# With specific date
uv run llmn calories log <calories> --date YYYY-MM-DD
```

### Step 4: Check Progress

For progress check requests:

```bash
uv run llmn tdee progress
```

This shows:
- Current weight vs EMA trend
- Weekly rate of change (lbs/week)
- Mifflin-St Jeor baseline TDEE
- Learned TDEE adjustment (from Kalman filter)
- Your estimated TDEE with uncertainty
- Progress toward goal weight

### Step 5: Update TDEE Estimate

To update the Kalman filter with recent data:

```bash
uv run llmn tdee estimate
```

This runs the Kalman filter and shows a brief summary:
```
Updated Total Daily Energy Expenditure (TDEE) estimate (4 weeks processed)
  Mifflin-St Jeor baseline: 2528 kcal/day
  Learned bias: -150 kcal/day
  Your TDEE: 2378 ± 60 kcal/day
```

After 2-3 weeks of data, the filter converges on your personalized TDEE.

### Step 6: Get Adaptive Calorie Targets

For actionable recommendations based on current progress:

```bash
uv run llmn tdee targets
```

This compares your current rate of loss to your goal and tells you whether to adjust:
```
Adaptive Calorie Targets
  Estimated TDEE: 2378 ± 60 kcal/day
  Goal: fat loss (1 lb/week)

Current status:
  Average intake: 1900 kcal/day
  Current rate: 0.9 lbs/week (losing)

Recommendation:
  Calorie target: 1900 kcal/day
  Protein range: 148 - 185 g/day

  You're on track! Keep doing what you're doing.
```

## Example Progress Report

```
Weight Tracking Report (last 30 days)
=============================================
Current weight: 182.4 lbs
Current trend:  183.1 lbs (EMA)
Trend change:   -4.8 lbs (from 187.9)
Rate:           1.2 lbs/week (losing)

TDEE Analysis
=============================================
Mifflin-St Jeor baseline: 2150 kcal/day
Learned adjustment:       -85 kcal/day
Your estimated TDEE:      2065 ± 90 kcal/day

Average planned intake: 1900 kcal/day
  Expected deficit: 250 kcal/day
  Implied deficit:  600 kcal/day (from trend)

Progress toward goal (165 lbs)
---------------------------------------------
  Remaining: 18.1 lbs
  At current rate: ~15 weeks

Notes:
  - Losing faster than expected by ~350 kcal/day.
    Possible causes: actual intake lower than logged,
    activity higher than estimated, or metabolism
    faster than Mifflin-St Jeor predicts.
```

## Interpreting Results

### Trend vs Weight

- **Weight**: Raw daily measurement (noisy)
- **Trend (EMA)**: Filtered signal showing true direction
- Focus on trend direction, not daily fluctuations

### Implied vs Expected Deficit

| Scenario | Meaning |
|----------|---------|
| Implied > Expected | Burning more than predicted (faster loss) |
| Implied < Expected | Burning less than predicted (slower loss) |
| Implied ≈ Expected | Mifflin-St Jeor is accurate for you |

### TDEE Bias

- **Positive bias**: Your TDEE is higher than Mifflin-St Jeor predicts
- **Negative bias**: Your TDEE is lower than predicted
- **Uncertainty (±)**: Decreases as more data is collected

## Daily Workflow

Encourage users to log daily (takes 10 seconds):

```bash
# Morning: log weight
uv run llmn weight add 183.2

# After meal planning: log calories
uv run llmn calories log 1850
```

Weekly: check progress with `uv run llmn tdee progress`

## Connecting to Meal Planning

Once TDEE is learned, use it for better meal planning:

```bash
# Get your personalized targets (uses adjusted TDEE)
uv run llmn tdee estimate

# Then optimize with those targets
uv run llmn optimize --pattern pescatarian --template --goal "fat_loss:183lbs:165lbs" --json
```

The goal flag uses Mifflin-St Jeor by default, but knowing your actual TDEE helps interpret whether you need to adjust calorie targets.

## Example Session

User: "I weighed 183.2 this morning"

1. Log the weight:
   ```bash
   uv run llmn weight add 183.2
   ```

2. Show the result with trend:
   ```
   Logged: 183.2 lbs
   Trend: 183.8 lbs (EMA)
   Change from yesterday: -0.3 lbs (trend)
   ```

3. Offer to show full progress:
   ```bash
   uv run llmn tdee progress
   ```

User: "How am I doing on my diet?"

1. Run progress report:
   ```bash
   uv run llmn tdee progress
   ```

2. Summarize key metrics:
   - "You've lost 4.8 lbs (trend) over the last 30 days"
   - "That's 1.2 lbs/week - right on track for healthy weight loss"
   - "At this rate, you'll reach 165 lbs in about 15 weeks"

3. Note any discrepancies between expected and implied deficit

## Key Insights from The Hacker's Diet

1. **Trust the trend, not the scale**: Daily weight is noisy; EMA shows reality
2. **Direction matters more than magnitude**: If trend is going down, you're in deficit
3. **Patience with the filter**: EMA has ~10-day lag; don't panic at daily fluctuations
4. **Consistency beats precision**: Weighing daily matters more than weighing accurately
