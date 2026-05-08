---
name: playtesting-orchestrator
description: Test escape room difficulty, collect player metrics, identify stuck points, and balance gameplay for 60-70% completion rate target. Implements alpha/beta testing protocols, feedback analysis, and iterative difficulty adjustment. Use when validating game balance, analyzing player behavior, or optimizing escape room challenge levels.
---

# Playtesting Orchestrator

## Overview

Systematically test and balance escape room difficulty through structured playtesting protocols, metrics collection, and evidence-based iteration to achieve 60-70% completion rate.

## Success Metrics Target

**Gold Standard**: 60-70% completion rate
- < 50%: Too difficult (frustrating)
- 60-70%: Perfect (challenging but achievable)
- > 80%: Too easy (unfulfilling)

**Secondary Metrics**:
- Average playtime: 30-45 minutes (target range)
- Hint usage: 0.5-1.0 per puzzle
- Player rating: 4.5+ / 5.0 stars
- Replay interest: 30%+ would play next episode

## Testing Phases

### Phase 1: Alpha Testing (5 testers)

**Goal**: Find breaking bugs and major design flaws

**Tester Profile**:
- Friends/colleagues
- Mix: 2 escape room fans, 3 beginners
- Willing to give harsh feedback

**Duration**: 3-5 days

**Focus Areas**:
- ✅ Can puzzles be solved?
- ✅ Do unlocks work correctly?
- ✅ Are instructions clear?
- ✅ Any game-breaking bugs?

### Phase 2: Beta Testing (15-20 testers)

**Goal**: Balance difficulty and refine experience

**Tester Profile**:
- Target audience (20-40 year olds)
- Mix: escape room experience levels
- Ideally strangers (unbiased feedback)

**Duration**: 1-2 weeks

**Focus Areas**:
- ✅ Completion rate (aim for 60-70%)
- ✅ Stuck points (where players get blocked)
- ✅ Average time (30-45 min target)
- ✅ Hint effectiveness
- ✅ Ending distribution

### Phase 3: Open Beta (50+ testers)

**Goal**: Final validation and edge case discovery

**Tester Profile**:
- Early access buyers
- Community members
- Influencer/reviewer copies

**Duration**: 2-4 weeks

**Focus Areas**:
- ✅ Statistical validation (large sample)
- ✅ Edge cases and exploits
- ✅ Cross-device testing
- ✅ Final polish feedback

## Testing Protocol

Copy this checklist:

```
Playtest Execution:
- [ ] Step 1: Prepare test environment (15 min)
- [ ] Step 2: Brief testers (10 min)
- [ ] Step 3: Observe playthrough (45 min per tester)
- [ ] Step 4: Collect structured feedback (15 min)
- [ ] Step 5: Analyze metrics (1 hour after all tests)
- [ ] Step 6: Identify issues (30 min)
- [ ] Step 7: Implement fixes (varies)
- [ ] Step 8: Retest (repeat)
```

### Step 1: Prepare Test Environment

**Checklist**:
```
Technical:
- [ ] Fresh copy of game template
- [ ] All formulas working
- [ ] Test on target device (mobile if Notion app)
- [ ] Create test player account

Documentation:
- [ ] Feedback form ready
- [ ] Metrics tracking sheet
- [ ] Screen recording tool (if remote)
- [ ] Note-taking setup
```

### Step 2: Brief Testers

**Briefing Script**:
```
"Thanks for playtesting!

Your goal:
- Play the escape room naturally
- Think out loud as you solve
- Note anything confusing
- Be brutally honest in feedback

I'll observe without helping (unless you're completely stuck for 10+ minutes).

Expected playtime: 30-45 minutes
After: 5-10 minute feedback discussion

Ready? Here's the link..."
```

**Rules**:
- ❌ Don't give hints unless absolutely necessary
- ❌ Don't explain mechanics (test if they're intuitive)
- ✅ Note when they get confused
- ✅ Time each puzzle
- ✅ Record their comments

### Step 3: Observe Playthrough

**Observation Template**:

| Time | Puzzle/Scene | Action | Difficulty | Notes |
|------|-------------|---------|-----------|-------|
| 0:00 | Intro | Reading | - | "Confused by toggle system" |
| 2:30 | Puzzle 1 | Solving | Easy | "Got it immediately" |
| 5:15 | Puzzle 2 | Stuck | Medium | "Didn't see the hint button" |
| 10:45 | Puzzle 2 | Used Hint 1 | Medium | "Ah, now I get it" |

**Red Flags to Watch For**:
- 🚩 Stuck >5 minutes without progress
- 🚩 Frustration (sighs, complaints)
- 🚩 Confusion about what to do next
- 🚩 Skipping content/scenes
- 🚩 Guessing randomly without logic

**Green Flags**:
- ✅ "Aha!" moments (satisfying discoveries)
- ✅ Logical problem-solving
- ✅ Engaged body language
- ✅ Appropriate difficulty progression
- ✅ Excitement at story beats

### Step 4: Collect Feedback

**Structured Feedback Form**:

```
## Completion
- Did you finish? Yes / No
- If no, where did you stop?

## Difficulty (1-5 scale)
- Overall difficulty: ☐☐☐☐☐
- Puzzles: ☐☐☐☐☐ (1=too easy, 5=too hard)
- Story: ☐☐☐☐☐ (1=confusing, 5=clear)

## Time
- Start time: _____
- End time: _____
- Total duration: _____ minutes

## Stuck Points
Which puzzles were hardest? (List 1-3)
1. _____________________
2. _____________________
3. _____________________

## Hints
- Hints used: _____
- Were hints helpful? Yes / Somewhat / No
- Which hints were unclear? _____

## Enjoyment (1-5 scale)
- Story engagement: ☐☐☐☐☐
- Puzzle quality: ☐☐☐☐☐
- Overall experience: ☐☐☐☐☐

## Replay Value
Would you play another episode? Yes / Maybe / No

## Open Feedback
What did you love?
_____________________________________

What was frustrating?
_____________________________________

What would you change?
_____________________________________

## Rating
Overall rating: ⭐⭐⭐⭐⭐ (circle)
```

**Quick Interview Questions**:
1. "What was your favorite moment?"
2. "What was your least favorite moment?"
3. "Were the hints helpful?"
4. "Did the difficulty feel fair?"
5. "Would you recommend this to a friend?"

### Step 5: Analyze Metrics

**Metrics Dashboard** (Notion Database):

```
[Database: Playtest Results]

Properties:
- Tester Name (Title)
- Date (Date)
- Completed (Checkbox)
- Duration (Number, minutes)
- Stuck At (Relation → Puzzles)
- Hints Used (Number)
- Overall Rating (Select: 1-5 stars)
- Would Recommend (Checkbox)
- Feedback (Long text)

Rollups:
- Avg Completion Time: average(Duration)
- Completion Rate: count(Completed=true) / count(all) × 100
- Avg Hints: average(Hints Used)
- Avg Rating: average(Overall Rating)
```

**Statistical Analysis**:

```
Example Results (10 testers):

Completion:
✅ Completed: 6/10 (60%) → ✅ TARGET MET
❌ Quit early: 4/10 (40%)

Time:
- Fastest: 28 min
- Slowest: 62 min
- Average: 42 min → ✅ Within target (30-45)
- Median: 38 min

Hints:
- Total hints: 45
- Avg per player: 4.5
- Avg per puzzle (15 puzzles): 0.3 → ⚠️ Lower than target (0.5-1.0)

Rating:
- Average: 4.2 / 5.0 → ⚠️ Below target (4.5+)

Stuck Points (most common):
1. Puzzle 7 (6 players stuck) → 🚩 CRITICAL ISSUE
2. Puzzle 11 (4 players stuck) → ⚠️ Needs adjustment
3. Puzzle 5 (2 players stuck) → ✅ Acceptable
```

### Step 6: Identify Issues

**Issue Prioritization Matrix**:

| Issue | Frequency | Impact | Priority |
|-------|-----------|--------|----------|
| Puzzle 7 unclear | 60% | High (blocker) | 🔴 Critical |
| Hint 3 not helpful | 40% | Medium | 🟡 High |
| Story confusing | 20% | Low | 🟢 Medium |
| Typo in Scene 5 | 10% | None | ⚪ Low |

**Fix Categories**:

**Critical (Fix before any release)**:
- Puzzles >30% stuck rate
- Game-breaking bugs
- Major confusion points

**High (Fix before beta end)**:
- Puzzles 20-30% stuck rate
- Ineffective hints
- Pacing issues

**Medium (Fix if time allows)**:
- Polish improvements
- Minor confusion
- Optional content

**Low (Nice to have)**:
- Typos
- Cosmetic issues
- Edge cases

### Step 7: Implement Fixes

**Common Issues & Solutions**:

**Issue 1: Puzzle Too Hard (>30% stuck)**

Solutions:
```
A. Add clearer instructions
Before: "Solve the code"
After: "Solve the 4-digit code using the calendar"

B. Add progressive hints
Hint 1: "Look at the calendar on the wall"
Hint 2: "Red-circled dates are important"
Hint 3: "The code is: Month+Day of first red date"

C. Simplify puzzle
Remove: 2 red herring dates
Result: Clearer pattern

D. Add visual cues
Add: Arrow pointing to calendar in scene image
```

**Issue 2: Puzzle Too Easy (<5% stuck)**

Solutions:
```
A. Remove obvious hints
Before: "The password is hidden in the photo *on the desk*"
After: "The password is hidden in the photo"

B. Add complexity
Before: 3-digit code
After: 4-digit code with letter-number substitution

C. Add noise
Before: Clean calendar with 1 date circled
After: Multiple dates, only holidays matter
```

**Issue 3: Ineffective Hints**

Solutions:
```
Bad Hint: "Think about it"
Better: "The answer is related to the calendar"
Best: "Count the number of red dates on the calendar"

Progression:
Hint 1: Direction (what to look at)
Hint 2: Method (how to solve)
Hint 3: Near-answer (almost gives solution)
```

**Issue 4: Pacing Problems**

Solutions:
```
Too slow start:
- Make Puzzle 1-2 easier
- Add immediate action/intrigue
- Shorter intro text

Too fast middle:
- Add optional exploration
- Insert character moment
- Include "breathing room" puzzle

Rushed ending:
- Extend final act by 5 minutes
- Add emotional payoff scene
- Don't end immediately after final puzzle
```

### Step 8: Retest

**Iteration Cycle**:
```
Test 1 → Identify 5 critical issues → Fix
↓
Test 2 → Validate fixes, find 3 new issues → Fix
↓
Test 3 → Final polish, 1-2 minor issues → Fix
↓
Release
```

**Regression Testing**:
After each fix, test:
- ✅ Issue is resolved
- ✅ Fix didn't break anything else
- ✅ Overall metrics improved

## Difficulty Balancing Guidelines

### Easy Puzzles (20%, Start of Game)

**Characteristics**:
- Single-step logic
- Clear visual cues
- Immediate feedback
- < 2 minutes to solve

**Example**: "Enter the password from the sticky note"

### Medium Puzzles (60%, Core Game)

**Characteristics**:
- 2-3 step logic
- Some inference required
- Hints available after 2-3 attempts
- 3-5 minutes to solve

**Example**: "Decode the safe combination from the calendar (requires counting + pattern recognition)"

### Hard Puzzles (20%, Challenge)

**Characteristics**:
- Multi-step reasoning
- Combines multiple clues
- Requires backtracking
- 5-10 minutes to solve

**Example**: "Use 3 separate clues to determine the final escape code (requires synthesis)"

**Placement**: Hard puzzles at 60-75% mark, NOT at end (allow breathing room)

## Metrics-Driven Optimization

### If Completion Rate < 60% (Too Hard)

**Actions**:
```
1. Identify top 3 stuck points
2. For each stuck point:
   - Add Hint 0 (earlier hint)
   - Improve Hint 1-3 clarity
   - Simplify puzzle mechanics
   - Add visual cues
3. Reduce number of steps required
4. Test again
```

### If Completion Rate > 80% (Too Easy)

**Actions**:
```
1. Remove most obvious hints
2. Increase puzzle complexity:
   - More steps
   - Additional red herrings
   - Less obvious connections
3. Reduce visual cues
4. Test again
```

### If Average Time > 50 min (Too Long)

**Actions**:
```
1. Remove 2-3 puzzles
2. Shorten intro/outro text
3. Make early puzzles easier (faster start)
4. Consider splitting into 2 episodes
```

### If Average Time < 25 min (Too Short)

**Actions**:
```
1. Add 3-5 puzzles
2. Expand story content
3. Add optional exploration
4. Increase puzzle complexity
```

## Remote Testing

**Tools**:
```
Video call: Zoom, Google Meet
Screen share: Tester shares Notion screen
Recording: Loom, OBS (with permission)
Feedback: Google Forms, Notion database
```

**Protocol Adjustments**:
```
- Send template link 5 min before call
- Brief over video call
- Watch via screen share
- Take notes in real-time
- Post-test interview via call
- Send feedback form after
```

**Benefits**:
- ✅ Test remote/international users
- ✅ Larger tester pool
- ✅ Async testing possible

**Challenges**:
- ❌ Less body language observation
- ❌ Technical issues
- ❌ Time zone coordination

## A/B Testing

**Use Case**: Compare two design approaches

**Example**:
```
Version A: Toggle-based hint system
Version B: Automatic hint after X attempts

Test:
- 10 testers each version
- Compare:
  - Hint usage rate
  - Player satisfaction
  - Completion time
- Choose winner

Result:
Version B: 4.6 rating, 68% completion
Version A: 4.2 rating, 62% completion
→ Implement Version B
```

## Resources

### references/
- `metrics-dashboard.md` - Statistical analysis templates
- `feedback-templates.md` - Survey forms and interview scripts
- `balancing-guide.md` - Difficulty calibration formulas

### assets/
- `playtest-tracker.notion` - Pre-built testing database
- `feedback-form.pdf` - Printable tester handout

## Example Application

**User**: "My escape room only has 35% completion rate, fix it"

**Analysis**:
```
Current Metrics:
- Completion: 35% (target: 60-70%) → 🔴 CRITICAL
- Avg time: 38 min (target: 30-45) → ✅ OK
- Avg rating: 3.8 / 5.0 (target: 4.5+) → 🟡 Low

Stuck Point Analysis:
- Puzzle 7: 8/10 testers stuck (80%) → 🔴 BLOCKER
- Puzzle 11: 6/10 testers stuck (60%) → 🔴 BLOCKER
- Puzzle 14: 4/10 testers stuck (40%) → 🟡 Hard

Root Cause (Puzzle 7):
- Tester feedback: "Didn't know what to do"
- Observation: No clear instruction
- Hint 1: "Think about the clues" (too vague)

Fixes:
1. Puzzle 7:
   - Add explicit instruction: "Enter the 4-digit code"
   - Improve Hint 1: "Look at the calendar dates"
   - Add Hint 0 (appears immediately): "This puzzle uses the calendar"
   - Add visual: Arrow pointing to calendar

2. Puzzle 11:
   - Simplify from 5-step to 3-step
   - Remove 2 red herring clues
   - Better Hint 2: "Combine the symbols from Scene 8 and Scene 10"

3. Puzzle 14:
   - Move Hint 1 trigger from 5 attempts to 3 attempts
   - Add intermediate hint between Hint 1 and 2

Predicted Impact:
- Puzzle 7 stuck rate: 80% → 20%
- Puzzle 11 stuck rate: 60% → 30%
- Puzzle 14 stuck rate: 40% → 25%
- Overall completion: 35% → 65% ✅ TARGET RANGE

Next Steps:
1. Implement fixes (2 hours)
2. Retest with 5 new testers (1 week)
3. Validate metrics improved
4. Final polish and release
```

Systematic playtesting transforms frustrating experiences into engaging challenges that 60-70% of players can conquer—the sweet spot for satisfaction and replay value.
