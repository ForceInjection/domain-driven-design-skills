---
name: Game Sprint Planner
description: Plan development sprints for Stapledons Voyage game features. Analyzes design docs, estimates effort considering AILANG constraints, and creates realistic sprint plans. Use when user asks to "plan sprint" or estimate game feature timelines.
---

# Game Sprint Planner

Create comprehensive sprint plans for Stapledons Voyage game development.

## Quick Start

**Most common usage:**
```bash
# User says: "Plan a sprint to implement NPC movement"
# This skill will:
# 1. Check current AILANG module status
# 2. Review known limitations from CLAUDE.md
# 3. Estimate effort (AILANG code + Go engine)
# 4. Create day-by-day task breakdown
# 5. Include AILANG feedback checkpoints
```

## When to Use This Skill

Invoke this skill when:
- User says "plan sprint", "estimate feature timeline"
- User wants to prioritize game development work
- Before starting a new game feature
- Assessing scope of AILANG workarounds needed

## Project-Specific Context

### Architecture (from CLAUDE.md)
```
sim/*.ail        → AILANG game logic (manually edit)
sim_gen/*.go     → Generated Go (OK - contains game types)
game_views/*.go  → Game-specific rendering helpers (NEW)
engine/*.go      → Generic Go/Ebiten rendering (reusable)
cmd/game/main.go → Game loop
```

### ⚠️ Engine Genericization Rule

**Before planning engine work, ask:** Could a different game use this unchanged?

| If YES | If NO |
|--------|-------|
| → OK for `engine/` | → Must go in `game_views/` or AILANG |

**sim_gen/ is fine** - Generated from AILANG, game-specific types belong there.

**engine/ must be generic** - No deck names, planet names, crew roles, or game concepts.

**game_views/** - New layer for game-specific rendering (DomeRenderer, DeckStackRenderer).

### Engine Capabilities Reference

**IMPORTANT:** Before estimating effort, review what's already built:

| Reference | Contents |
|-----------|----------|
| [engine-capabilities.md](../../../design_docs/reference/engine-capabilities.md) | Complete engine reference (DrawCmd types, effects, shaders, physics) |
| [gr-effects.md](../../../design_docs/implemented/v0_1_0/gr-effects.md) | GR physics, shader uniforms, danger levels |
| [ai-handler-system.md](../../../design_docs/implemented/v0_1_0/ai-handler-system.md) | AI effect, multimodal APIs |

**Key Available Capabilities:**
- **DrawCmd**: Sprite, Rect, Text, IsoTile, IsoEntity, GalaxyBg, Star, Ui (Panel/Button/Label/Portrait/Slider/ProgressBar), Line, Circle, TextWrapped
- **Effects**: Debug, Rand, Clock, AI (Claude/Gemini/stub)
- **Assets**: Animated sprites, Audio (OGG/WAV), Fonts (TTF with scaling)
- **Shaders**: SR warp, GR warp, bloom, vignette, CRT
- **Physics**: Lorentz factor, time dilation, gravitational redshift

### Current AILANG Limitations
Before planning, check CLAUDE.md for:
- Module imports not working
- Recursion depth limits
- No RNG effect documented
- No Array type (O(1) access)
- Record update syntax issues

## Sprint Planning Workflow

### 1. Assess Current State

```bash
# Check AILANG modules compile
for f in sim/*.ail; do ailang check "$f"; done

# Check for messages from AILANG team
ailang messages list --unread
```

### 2. Identify Work Scope

For each game feature, estimate:
- **AILANG code**: Types, functions needed in `sim/*.ail`
- **game_views code**: Game-specific rendering helpers (if needed)
- **Engine code**: Generic Go/Ebiten changes (should be rare!)
- **Workarounds**: AILANG limitations to navigate
- **Testing**: How to verify it works

**Engine Genericization Check:**
Before adding to `engine/`, verify it's not game-specific:
- ❌ References decks, planets, crew roles → `game_views/`
- ❌ Hardcodes game data → AILANG
- ✅ Generic DrawCmd rendering → `engine/`
- ✅ Asset loading, camera, shaders → `engine/`

### 3. Example Sprint Plan

```markdown
# Sprint: NPC Movement (3 days)

## Goal
Implement basic NPC movement on the world grid.

## Day 1: AILANG Types & Functions
- [ ] Define Direction type in sim/world.ail
- [ ] Add moveNpc function to sim/npc_ai.ail
- [ ] Test with `ailang check`
- [ ] Report any AILANG issues encountered

## Day 2: Step Integration
- [ ] Update step function to process NPC moves
- [ ] Handle movement input from FrameInput
- [ ] Test with `ailang run --entry step`

## Day 3: Engine Rendering
- [ ] Update Go rendering to show NPCs
- [ ] Test with `make run`
- [ ] Document any performance issues

## AILANG Feedback Checkpoint
After sprint, report:
- Bugs encountered
- Features that would have helped
- Documentation gaps
```

### 4. AILANG Complexity Multipliers

When estimating effort, consider these multipliers:

| Factor | Multiplier | Example |
|--------|------------|---------|
| Module imports broken | 1.5x | Must duplicate types |
| Deep recursion needed | 2x | Grid operations |
| No RNG available | +0.5 days | Random behaviors |
| New ADT types | 1.2x | Pattern matching complexity |

### 5. Include Feedback Checkpoints

Every sprint should include:
1. **Start**: Check inbox for AILANG team responses
2. **Mid-sprint**: Report blockers immediately
3. **End**: Send summary of issues encountered

## Handoff to sprint-executor

After sprint plan is approved:

```bash
# Check and acknowledge any pending messages
ailang messages list --unread
ailang messages ack <msg-id>

# Send plan ready notification (optional)
ailang messages send sprint-executor '{
  "type": "plan_ready",
  "sprint_id": "npc-movement",
  "days": 3,
  "milestones": ["types", "step-integration", "rendering"]
}'
```

## Available Scripts

### `scripts/analyze_velocity.sh`
Analyze recent development velocity from git commits.

### `scripts/create_sprint_json.sh <sprint_id> <plan_md>`
Create JSON progress file for multi-session execution.

## Best Practices

### 1. Start Small
- First sprint should be simple (1-2 days)
- Build confidence with AILANG before complex features

### 2. Test AILANG Early
- Run `ailang check` after every file change
- Don't let compilation errors pile up

### 3. Document Workarounds
- When AILANG lacks a feature, document the workaround
- Report to AILANG team so they know the pain points

### 4. Plan for Feedback Loop
- Budget time for reporting issues
- Check inbox for responses during sprint

## Notes

- This project tests AILANG as much as it builds a game
- Sprint velocity includes AILANG issue reporting time
- Use `ailang prompt` output as reference for planning
- Check CLAUDE.md for known limitations before estimating
