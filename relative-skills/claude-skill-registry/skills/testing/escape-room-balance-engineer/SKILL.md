---
name: escape-room-balance-engineer
description: Balance escape room difficulty, timing, and hint systems to achieve 60-70% completion rate. Designs progressive difficulty curves, three-tier hint systems, stuck-point analysis, and playtest metrics. Use when balancing game difficulty, designing hint systems, analyzing playtest data, or optimizing escape room completion rates.
---

# Escape Room Balance Engineer

Optimize escape room difficulty to achieve the golden 60-70% completion rate through scientific balancing and playtesting.

## Purpose

This skill provides methods for:
- Difficulty curve design (progressive challenge)
- Hint system architecture (3-tier progressive hints)
- Playtest protocol and metrics analysis
- Stuck-point identification and resolution
- Completion rate optimization

## When to Use This Skill

Use this skill when:
- Balancing difficulty for new escape room games
- Designing hint systems
- Analyzing playtest feedback and metrics
- Identifying and fixing stuck points
- Optimizing for target completion rate (60-70%)

## The Golden Rule: 60-70% Completion Rate

**Why This Range**:
- <50%: Too difficult, players frustrated
- 60-70%: **Optimal** - challenging but achievable
- >80%: Too easy, no satisfaction

**Source**: Industry standard from escape room design experts

## Difficulty Curve Design

### Ideal Difficulty Progression (120-min game)

```
Difficulty
    ↑
  ████  |                      Peak (Scene 11)
  ███   |
  ██    |
  █     |
 █      |
█_______|→ Time
0   30  60  90  120 min

Key Points:
- 0-5 min: Easy victory (confidence boost)
- 5-30 min: Gradual increase
- 60-90 min: Peak difficulty (Scene 9-11)
- 90-120 min: Slight decrease (allow completion)
```

### Difficulty Assignment (15 Scenes)

| Scene | Act | Difficulty | Player Emotion | Puzzle Type |
|-------|-----|------------|----------------|-------------|
| 0 | 1 | Easy | Curiosity | Tutorial |
| 1-2 | 1 | Easy | Engagement | Pattern, Logic |
| 3-4 | 1 | Medium | Focus | Deduction |
| 5-6 | 2 | Medium | Tension | Multi-step |
| 7-8 | 2 | Hard | Challenge | Complex logic |
| 9-11 | 2 | **Very Hard** | Peak stress | Synthesis |
| 12 | 3 | Medium | Relief | Application |
| 13-14 | 3 | Easy | Completion | Narrative choice |

**Balancing Formula**:
```
Total Difficulty Points = Sum of all scene difficulties
Target: 60-70 points for 60-70% completion rate

Easy = 2 pts, Medium = 5 pts, Hard = 10 pts, Very Hard = 15 pts
Example: 3 Easy (6) + 5 Medium (25) + 3 Hard (30) + 3 Very Hard (45) = 106 pts
→ Too difficult! Reduce Very Hard to 2 scenes.
```

## Three-Tier Hint System

### Structure

**Tier 1: Direction Hint** (Vague guidance)
- Unlocks: After 3 failed attempts OR 5 minutes stuck
- Example: "Think about the books on the shelf"

**Tier 2: Specific Hint** (Clear guidance)
- Unlocks: After 5 failed attempts OR 8 minutes stuck
- Example: "Look at the first letter of each book title"

**Tier 3: Answer** (Direct solution)
- Unlocks: After 8 failed attempts OR 12 minutes stuck
- Example: "The answer is LIBRARY (L-I-B-R-A-R-Y from book titles)"

### Implementation

```typescript
interface HintSystem {
  attempts: number
  timeStuck: number // seconds
  tier1Shown: boolean
  tier2Shown: boolean
  tier3Shown: boolean
}

const getHint = (puzzle: Puzzle, hintState: HintSystem): string | null => {
  const { attempts, timeStuck, tier1Shown, tier2Shown } = hintState

  if (attempts >= 8 || timeStuck >= 720) {
    return puzzle.tier3_hint // Answer
  } else if (attempts >= 5 || timeStuck >= 480) {
    return puzzle.tier2_hint // Specific
  } else if (attempts >= 3 || timeStuck >= 300) {
    return puzzle.tier1_hint // Direction
  }

  return null // No hint yet
}
```

### Hint Impact on Endings

```typescript
// Hint usage affects True Ending eligibility
const canAchieveTrueEnding = () => {
  const totalHintsUsed = hintUsageLog.filter(h => h.tier === 3).length

  return totalHintsUsed <= 5 // Max 5 Tier-3 hints for True Ending
}
```

## Playtest Protocol

### Alpha Test (Internal, 5 people)

**Goal**: Find obvious bugs, impossible puzzles

**Metrics to Track**:
```
- Completion: Yes/No
- Time: Total minutes
- Stuck points: Which scenes/puzzles
- Bugs found: List
- Satisfaction: 1-5 stars
```

**Success Criteria**:
- 60%+ completion (3/5 complete)
- No critical bugs
- Average satisfaction 4+

### Beta Test (External, 20 people)

**Goal**: Validate difficulty curve, hint effectiveness

**Metrics to Track**:
```
- Completion rate: Target 60-70%
- Average time: Target 90-120 min
- Hint usage: Average 3-5 tier-3 hints
- Stuck points: >30% stuck = needs fixing
- Scene times: Identify bottlenecks
- Satisfaction: Target 4.5+
```

**Data Collection**:

```typescript
// Automatic telemetry
const trackSceneCompletion = (sceneId: string, duration: number) => {
  analytics.track('scene_completed', {
    sceneId,
    duration,
    hintsUsed: currentHints,
    attempts: currentAttempts
  })
}

// Aggregate analysis
const analyzePlaytests = () => {
  return {
    completionRate: completedPlayers / totalPlayers,
    avgTime: average(playTimes),
    stuckScenes: scenes.filter(s => avgTime(s) > 10min),
    hintsPerPuzzle: average(hintUsage)
  }
}
```

### Stuck-Point Analysis

**Identification**:
```
Stuck Point = Scene where >30% of players spend >10 minutes without progress
```

**Common Stuck Points**:
1. **Unclear objective**: Player doesn't know what to do
   - Fix: Add direction hint earlier

2. **Hidden element**: Player can't find interactive object
   - Fix: Visual cue (glow, pulse animation)

3. **Logic leap too large**: Puzzle requires insight player lacks
   - Fix: Add intermediate puzzle teaching concept

4. **Technical confusion**: UI unclear (what's clickable?)
   - Fix: Better affordances (hover states, labels)

**Resolution Priority**:
```
Priority = (% Players Stuck) × (Average Time Stuck)

Example:
Scene 7: 40% stuck × 15 min = 600 points → HIGH PRIORITY
Scene 3: 20% stuck × 5 min = 100 points → Low priority
```

## Difficulty Calibration

### Puzzle Difficulty Factors

**Complexity Dimensions**:
1. **Steps**: How many actions to solve?
   - 1-2 steps: Easy
   - 3-4 steps: Medium
   - 5-7 steps: Hard
   - 8+ steps: Very Hard

2. **Knowledge**: What must player know?
   - Common knowledge: Easy
   - Domain knowledge: Medium
   - Specialized knowledge: Hard
   - Creative insight: Very Hard

3. **Clues**: How obvious are hints?
   - Direct: Easy
   - Indirect: Medium
   - Subtle: Hard
   - Hidden: Very Hard

**Scoring**:
```
Puzzle Difficulty Score = Steps × Knowledge × Clues

Example:
Puzzle A: 3 steps × Common × Direct = 3 × 1 × 1 = 3 (Easy)
Puzzle B: 5 steps × Domain × Indirect = 5 × 2 × 2 = 20 (Hard)
Puzzle C: 8 steps × Creative × Hidden = 8 × 4 × 3 = 96 (Very Hard)
```

### Adjusting Difficulty Post-Launch

**If Completion Rate Too Low** (<50%):
1. Add Tier-0 hints (auto-show after 2 min)
2. Simplify hardest puzzle (reduce steps)
3. Make clues more obvious (highlight, animate)

**If Completion Rate Too High** (>80%):
1. Remove some Tier-1 hints
2. Add red herrings (misleading clues)
3. Increase puzzle step count

## Timing Targets

**Scene Time Budgets** (120-min game, 15 scenes):

```
Scene 0-2 (Act 1 intro): 5 min each = 15 min total
Scene 3-4 (Act 1 exploration): 7 min each = 14 min total
Scene 5-8 (Act 2 investigation): 10 min each = 40 min total
Scene 9-11 (Act 2 climax): 15 min each = 45 min total
Scene 12-14 (Act 3 resolution): 5 min each = 15 min total

Total: 129 min (slightly over to allow 10% slack)
```

**Buffer Strategy**: Design for 130 min, target 120 min (allows 8% player variation)

## Playtest Metrics Dashboard

```typescript
interface PlaytestMetrics {
  // Completion
  totalPlayers: number
  completedPlayers: number
  completionRate: number  // Target: 0.6-0.7

  // Timing
  avgPlayTime: number  // Target: 120 min
  medianPlayTime: number
  sceneAvgTimes: Record<string, number>

  // Difficulty
  avgHintsUsed: number  // Target: 3-5 tier-3 hints
  stuckScenes: string[]  // Scenes with >30% stuck
  failedPuzzles: Record<string, number>  // Puzzle ID → fail count

  // Satisfaction
  avgRating: number  // Target: 4.5+
  wouldReplay: number  // Target: 40%+
  wouldRecommend: number  // Target: 80%+
}
```

**Automated Analysis**:

```typescript
const analyzePlaytests = (data: PlaytestData[]): BalanceReport => {
  const metrics = calculateMetrics(data)

  const issues: Issue[] = []

  if (metrics.completionRate < 0.5) {
    issues.push({
      type: 'difficulty_too_high',
      severity: 'critical',
      recommendation: 'Add tier-0 hints, simplify hardest puzzles'
    })
  }

  if (metrics.stuckScenes.length > 3) {
    issues.push({
      type: 'multiple_stuck_points',
      severity: 'high',
      scenes: metrics.stuckScenes,
      recommendation: 'Review each stuck scene, add visual cues'
    })
  }

  return { metrics, issues, recommendations: generateRecommendations(issues) }
}
```

See `scripts/analyze_playtests.py` for automated analysis.

## Balancing Workflow

```
Difficulty Balancing Process:
- [ ] Step 1: Design initial difficulty curve (target distribution)
- [ ] Step 2: Assign difficulty to each scene/puzzle
- [ ] Step 3: Alpha test (5 people, internal)
- [ ] Step 4: Analyze alpha metrics (completion, stuck points)
- [ ] Step 5: Adjust difficulty (simplify stuck scenes)
- [ ] Step 6: Beta test (20 people, external)
- [ ] Step 7: Analyze beta metrics (detailed telemetry)
- [ ] Step 8: Fine-tune (hints, timing, clues)
- [ ] Step 9: Validate final metrics (60-70% target)
- [ ] Step 10: Launch with telemetry enabled
```

## Anti-Patterns

❌ **Difficulty Spike**: Easy → Easy → **Impossible** → Easy
✅ **Smooth Curve**: Gradual increase with peak at 70% through game

❌ **One-Size-Fits-All**: Same difficulty for all players
✅ **Adaptive Hints**: Dynamic hint timing based on player performance

❌ **No Feedback**: Player doesn't know if making progress
✅ **Progress Indicators**: "2/5 clues found", "You're close..."

❌ **Guess-and-Check**: Trial and error required
✅ **Logical Deduction**: Solvable with available information

## Resources

**Difficulty Design**: `references/difficulty-curve-templates.md` - Proven curve shapes
**Hint System**: `references/three-tier-hint-guide.md` - Implementation patterns
**Playtest Protocol**: `references/playtest-procedure.md` - Step-by-step guide
**Metrics Analysis**: `references/metrics-interpretation-guide.md` - What numbers mean
**Stuck-Point Fixes**: `references/common-fixes-library.md` - 50+ solutions

**Scripts**:
- `scripts/analyze_playtests.py` - Generate balance report from telemetry
- `scripts/difficulty_calculator.py` - Score puzzle difficulty
- `scripts/hint_optimizer.py` - Recommend hint unlock timing

## Success Criteria

Well-balanced escape room should:
- ✅ Completion rate 60-70%
- ✅ Average time within 10% of target (108-132 min for 120-min game)
- ✅ No scene >30% stuck rate
- ✅ Hint usage 3-5 tier-3 hints average
- ✅ Smooth difficulty curve (no spikes)
- ✅ Player satisfaction 4.5+/5
- ✅ Replay intent 40%+
- ✅ No critical bugs in playtest

---

**Version**: 1.0
**Last Updated**: 2025-01-04
**Author**: Escape Room Balance Specialist
