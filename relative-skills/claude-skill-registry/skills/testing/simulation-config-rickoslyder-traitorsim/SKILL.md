---
name: simulation-config
description: Configure TraitorSim game parameters including regional rule variants (UK/US/Australia), recruitment mechanics, end-game modes, tie-breaking, and player counts. Use when setting up simulations, testing rule variants, comparing configurations, or when asked about game rules, regional variants, or simulation parameters.
---

# Simulation Configuration

Configure TraitorSim game parameters to test different regional rule variants, recruitment mechanics, end-game scenarios, and player counts. This skill helps set up simulations that match specific franchise rules or test custom configurations.

## Quick Start

```python
from src.traitorsim.core.config import SimulationConfig

# UK rules (standard)
uk_config = SimulationConfig(
    rule_set="UK",
    recruitment_type="standard",
    end_game_mode="vote_to_end",
    tie_break_method="revote",
    num_players=22,
    num_traitors=4,
    starting_pot=0,
    enable_dramatic_entry=True,
    shield_visibility="secret"
)

# US rules
us_config = SimulationConfig(
    rule_set="US",
    recruitment_type="standard",
    end_game_mode="vote_to_end",
    tie_break_method="random",
    num_players=20,
    num_traitors=3,
    enable_dramatic_entry=False
)

# Australia rules (Traitor's Dilemma)
aus_config = SimulationConfig(
    rule_set="Australia",
    recruitment_type="ultimatum",
    end_game_mode="traitors_dilemma",
    tie_break_method="countback",
    num_players=24,
    num_traitors=4,
    enable_dramatic_entry=True
)
```

## Regional Rule Variants

### UK Rules (Standard)

**Player Count:** 20-22 contestants
**Traitor Count:** 3-4 initial Traitors

**Recruitment:**
- Triggered when a Traitor is banished
- Faithful can decline recruitment
- If declined, game continues with fewer Traitors

**End Game:**
- **Vote to End** at Final 4 or fewer
- All players vote: Continue or End?
- Requires **unanimous consent** to end
- If vote fails, game continues (murder happens)

**Tie-Breaking (Round Table votes):**
- **Revote** with tied players immune
- If still tied after revote: No banishment

**Breakfast Order:**
- **Dramatic Entry** enabled
- Last player to enter breakfast is often suspicious
- GameMaster can manipulate entry order for drama

**Shield:**
- **Secret** - No one knows who has Shield until used

**Prize Pot:**
- Starts at £0
- Missions add £1,000-£10,000
- Final pot typically £20,000-£120,000

**Configuration:**
```python
SimulationConfig(
    rule_set="UK",
    recruitment_type="standard",
    end_game_mode="vote_to_end",
    tie_break_method="revote",
    num_players=22,
    num_traitors=4,
    starting_pot=0,
    enable_dramatic_entry=True,
    shield_visibility="secret"
)
```

### US Rules

**Player Count:** 20 contestants
**Traitor Count:** 3 initial Traitors

**Recruitment:**
- Same as UK (Faithful can decline)

**End Game:**
- **Vote to End** at Final 4
- Majority vote (not unanimous)
- If vote fails, game continues

**Tie-Breaking:**
- **Random draw** - Flip coin or draw lots
- No revote

**Breakfast Order:**
- No dramatic entry manipulation
- Players enter naturally

**Shield:**
- Sometimes **public** (announced at Round Table)

**Prize Pot:**
- Starts at $250,000
- Missions deduct from pot on failure
- Final pot typically $50,000-$200,000

**Configuration:**
```python
SimulationConfig(
    rule_set="US",
    recruitment_type="standard",
    end_game_mode="vote_to_end",
    tie_break_method="random",
    num_players=20,
    num_traitors=3,
    starting_pot=250000,
    enable_dramatic_entry=False,
    shield_visibility="public"
)
```

### Australia Rules

**Player Count:** 22-24 contestants
**Traitor Count:** 4 initial Traitors

**Recruitment:**
- **Ultimatum (Blackmail)** mode
- When last Traitor remains, can force recruitment
- "Join me or I'll reveal you as the next murder victim"
- Faithful cannot safely decline

**End Game:**
- **Traitor's Dilemma** at Final 2 (if both Traitors)
- Prisoner's Dilemma: Share or Steal?
- Both Share: Split pot 50/50
- One Steals: Stealer gets 100%, Sharer gets £0
- Both Steal: Both get £0

**Tie-Breaking:**
- **Countback** - Cumulative votes across all previous Round Tables
- Player with most total votes is banished
- If still tied: Random

**Breakfast Order:**
- Dramatic entry enabled

**Shield:**
- Secret

**Prize Pot:**
- Starts at AU$250,000
- Missions add to pot
- Final pot typically AU$100,000-AU$250,000

**Configuration:**
```python
SimulationConfig(
    rule_set="Australia",
    recruitment_type="ultimatum",
    end_game_mode="traitors_dilemma",
    tie_break_method="countback",
    num_players=24,
    num_traitors=4,
    starting_pot=250000,
    enable_dramatic_entry=True,
    shield_visibility="secret"
)
```

## Configuration Parameters

### rule_set: str
**Options:** `"UK"`, `"US"`, `"Australia"`, `"custom"`

**Default:** `"UK"`

**Impact:**
- Sets default values for other parameters
- Affects GameMaster narration style
- Influences cultural references

**Custom:** Allows mixing rules from different variants

### num_players: int
**Range:** 10-30

**Typical values:**
- Small game: 10-12
- Standard: 20-24
- Large game: 25-30

**Impact on gameplay:**
- **Smaller games** (10-15): Faster pace, fewer days, easier to track alliances
- **Larger games** (20+): Longer seasons, more complex social dynamics, harder to form unanimous votes

### num_traitors: int
**Range:** 2-6

**Typical ratios:**
- **15% Traitors**: 3 Traitors / 20 players
- **18% Traitors**: 4 Traitors / 22 players
- **20% Traitors**: 6 Traitors / 30 players

**Impact on gameplay:**
- **Fewer Traitors**: Harder for Traitors to win, more paranoia
- **More Traitors**: Voting bloc advantage, easier to recruit

**Critical:** If Traitors ever outnumber Faithfuls at Vote to End, Traitors auto-win

### recruitment_type: str
**Options:** `"standard"`, `"ultimatum"`, `"none"`

**Standard:**
- Triggered when Traitor banished
- Faithful can decline
- If declined, game continues with reduced Traitors

**Ultimatum (Blackmail):**
- Last remaining Traitor forces "Join or Die"
- Faithful can technically decline, but will be murdered
- Adds tension to end game

**None:**
- No recruitment ever
- If Traitors eliminated, Faithfuls auto-win

**Impact:**
- `standard`: Balanced, allows Faithful heroes
- `ultimatum`: Favors Traitors in end game
- `none`: Favors Faithfuls

### end_game_mode: str
**Options:** `"vote_to_end"`, `"traitors_dilemma"`, `"elimination"`

**Vote to End:**
- At Final 4 (or fewer), players vote to continue or end
- If unanimous to end: Remaining Faithfuls split pot
- If vote fails: Game continues (Traitors murder)

**Traitor's Dilemma:**
- At Final 2 with 2 Traitors: Share or Steal decision
- See Australia rules above

**Elimination:**
- Game continues until only Traitors OR only Faithfuls remain
- No vote to end

**Impact:**
- `vote_to_end`: Requires unanimous trust (hard to achieve)
- `traitors_dilemma`: Adds drama to Traitor vs Traitor end
- `elimination`: Longest games, highest body count

### tie_break_method: str
**Options:** `"revote"`, `"countback"`, `"random"`, `"no_banishment"`

**Revote:**
- Tied players are immune
- Re-vote on remaining nominees
- If still tied: No banishment

**Countback:**
- Sum all votes each tied player received across entire season
- Player with most cumulative votes is banished
- If still tied: Random

**Random:**
- Flip coin / draw lots
- Immediate resolution

**No Banishment:**
- Ties always result in no banishment
- Simpler, favors Traitors (no Traitor eliminated)

**Impact:**
- `revote`: Dramatic, requires social maneuvering
- `countback`: Rewards consistent voting, punishes polarizing players
- `random`: Fastest, but feels unfair
- `no_banishment`: Simplest, least drama

### starting_pot: int
**Range:** 0 to 500,000

**Typical values:**
- UK: £0 (missions add to pot)
- US: $250,000 (missions deduct on failure)
- Australia: AU$250,000 (missions add)

**Impact:**
- Starting high + deductions: Missions feel high-stakes
- Starting zero + additions: More forgiving, cooperative vibe

### enable_dramatic_entry: bool
**Default:** `True`

**Effect:**
- GameMaster can manipulate breakfast entry order
- Last player to enter is often suspicious ("Why were they late?")
- Creates "breakfast order tell" - Traitors may consistently enter last

**Impact:**
- Adds observable clues for Faithfuls
- Creates extra paranoia

### shield_visibility: str
**Options:** `"secret"`, `"public"`

**Secret:**
- No one knows who has Shield
- Shield holder can bluff ("I have Shield, so don't waste murder on me")
- Creates information asymmetry

**Public:**
- Announced at Round Table who has Shield
- No bluffing possible
- Shield holder is obvious target AFTER shield used

**Impact:**
- `secret`: More strategic, allows Shield bluffing
- `public`: Simpler, less deception

### personality_generation: str
**Options:** `"archetype"`, `"random"` (deprecated)

**Archetype:**
- Uses persona library with backstories
- Grounded in demographics and psychology
- Preferred for realistic gameplay

**Random (deprecated):**
- Random OCEAN trait assignment
- No backstory or demographic grounding
- **Not recommended**

**Impact:**
- `archetype`: Rich, emergent social dynamics
- `random`: Shallow, unpredictable agents

## Instructions

### When Setting Up a Simulation

1. **Choose rule set**:
   ```python
   # Standard UK rules
   config = SimulationConfig(rule_set="UK")

   # Or custom mix
   config = SimulationConfig(
       rule_set="custom",
       recruitment_type="ultimatum",  # From Australia
       end_game_mode="vote_to_end",   # From UK
       tie_break_method="random"      # From US
   )
   ```

2. **Adjust player counts**:
   ```python
   config.num_players = 15  # Smaller game for testing
   config.num_traitors = 3  # 20% ratio
   ```

3. **Set persona library**:
   ```python
   config.persona_library_path = "data/personas/library/test_batch_001_personas.json"
   ```

4. **Validate configuration**:
   ```python
   config.validate()
   # Raises error if invalid (e.g., more Traitors than players)
   ```

5. **Run simulation**:
   ```python
   from src.traitorsim.core.game_engine import GameEngine

   engine = GameEngine(config=config)
   results = engine.run()
   ```

### When Testing Rule Variants

**Compare UK vs US end game:**
```python
configs = [
    SimulationConfig(rule_set="UK", end_game_mode="vote_to_end"),
    SimulationConfig(rule_set="US", end_game_mode="vote_to_end", tie_break_method="random")
]

results = []
for config in configs:
    engine = GameEngine(config=config)
    result = engine.run()
    results.append(result)

# Compare outcomes
for i, result in enumerate(results):
    print(f"Config {i+1}: Winner: {result['winner']}, Days: {result['days']}")
```

**Test recruitment mechanics:**
```python
# Standard recruitment
config_standard = SimulationConfig(recruitment_type="standard")

# Ultimatum recruitment
config_ultimatum = SimulationConfig(recruitment_type="ultimatum")

# No recruitment
config_none = SimulationConfig(recruitment_type="none")

# Run multiple games with each config
for config in [config_standard, config_ultimatum, config_none]:
    for trial in range(10):
        engine = GameEngine(config=config)
        result = engine.run()
        # Analyze Traitor win rate
```

### When Debugging Game Rules

**Test edge cases:**

1. **All Traitors banished early**:
   ```python
   # Run game, manually banish all Traitors
   # Expected: Faithfuls auto-win
   ```

2. **Final 2 with 2 Traitors**:
   ```python
   config = SimulationConfig(end_game_mode="traitors_dilemma")
   # Manually set state to Final 2 Traitors
   # Expected: Share/Steal decision triggers
   ```

3. **Traitor majority at Vote to End**:
   ```python
   # Set state to Final 4: 3 Traitors, 1 Faithful
   # Expected: Traitors vote to end, auto-win
   ```

4. **Countback tie-break with equal votes**:
   ```python
   config = SimulationConfig(tie_break_method="countback")
   # Create scenario where 2 players have identical cumulative votes
   # Expected: Falls back to random
   ```

## Configuration Best Practices

### For Testing/Development

**Use small games:**
```python
config = SimulationConfig(
    num_players=10,
    num_traitors=2,
    enable_dramatic_entry=False,  # Simpler
    tie_break_method="random"     # Faster
)
```

**Benefits:**
- Faster execution (fewer agents)
- Easier to debug (fewer interactions)
- Quicker iteration

### For Realistic Simulation

**Use standard UK rules with full persona library:**
```python
config = SimulationConfig(
    rule_set="UK",
    num_players=22,
    num_traitors=4,
    personality_generation="archetype",
    persona_library_path="data/personas/library/production_100_personas.json",
    enable_dramatic_entry=True,
    shield_visibility="secret"
)
```

**Benefits:**
- Matches actual show rules
- Rich social dynamics
- Emergent behaviors

### For Research/Analysis

**Vary one parameter at a time:**
```python
baseline = SimulationConfig(rule_set="UK")

# Test impact of recruitment type
configs = [
    baseline,
    SimulationConfig(rule_set="UK", recruitment_type="ultimatum"),
    SimulationConfig(rule_set="UK", recruitment_type="none")
]

# Run 50 trials per config
for config in configs:
    for trial in range(50):
        result = run_simulation(config)
        save_result(result, config_name=config.recruitment_type)

# Analyze Traitor win rates
```

## Common Configuration Errors

### Error 1: More Traitors Than Players

```python
config = SimulationConfig(num_players=10, num_traitors=15)
# ❌ ValueError: num_traitors (15) exceeds num_players (10)
```

**Fix:** Ensure `num_traitors < num_players`

### Error 2: Invalid Rule Set

```python
config = SimulationConfig(rule_set="Canada")
# ❌ ValueError: Invalid rule_set. Must be: UK, US, Australia, custom
```

**Fix:** Use valid rule set name

### Error 3: Traitor Majority at Start

```python
config = SimulationConfig(num_players=10, num_traitors=6)
# ⚠️  Warning: Traitors start with majority (6/10). Game balance broken.
```

**Fix:** Keep Traitors to 15-20% of total:
```python
config = SimulationConfig(num_players=10, num_traitors=2)  # 20%
```

### Error 4: Missing Persona Library

```python
config = SimulationConfig(
    personality_generation="archetype",
    persona_library_path="data/personas/library/nonexistent.json"
)

engine = GameEngine(config=config)
# ❌ FileNotFoundError: Persona library not found
```

**Fix:** Generate library first or use correct path

### Error 5: Invalid Tie-Break Method

```python
config = SimulationConfig(tie_break_method="majority_vote")
# ❌ ValueError: Invalid tie_break_method
```

**Fix:** Use valid method: `revote`, `countback`, `random`, or `no_banishment`

## Advanced Configuration

### Custom Mission Sets

```python
from src.traitorsim.missions.mission_registry import MissionRegistry

config = SimulationConfig(rule_set="UK")

# Override default missions
custom_missions = MissionRegistry()
custom_missions.register("Laser Heist", primary_stat="dexterity", difficulty=0.7)
custom_missions.register("Quiz Challenge", primary_stat="intellect", difficulty=0.6)
custom_missions.register("Trust Fall", primary_stat="social_influence", difficulty=0.5)

config.mission_registry = custom_missions
```

### Seeded Randomness (Reproducible Games)

```python
config = SimulationConfig(
    rule_set="UK",
    random_seed=42  # Same seed = same game every time
)

# Run game twice with same seed
result1 = GameEngine(config=config).run()
result2 = GameEngine(config=config).run()

assert result1 == result2  # Identical outcomes
```

### Hybrid Rule Sets

**Example: UK rules + US tie-breaking**
```python
config = SimulationConfig(
    rule_set="custom",
    recruitment_type="standard",      # UK
    end_game_mode="vote_to_end",      # UK
    tie_break_method="random",        # US
    enable_dramatic_entry=True,       # UK
    num_players=20,                   # US
    num_traitors=3,                   # US
    starting_pot=100000               # Hybrid
)
```

## When to Use This Skill

Use this skill when:
- Setting up a new simulation
- Testing different regional rule variants
- Comparing recruitment mechanics
- Debugging game rule logic
- Creating custom configurations
- Running research experiments with varying parameters

## When NOT to Use This Skill

Don't use this skill for:
- Analyzing game outcomes (use game-analyzer skill)
- Debugging agent memory (use memory-debugger skill)
- Generating personas (use persona-pipeline skill)
- Validating content (use world-bible-validator skill)
