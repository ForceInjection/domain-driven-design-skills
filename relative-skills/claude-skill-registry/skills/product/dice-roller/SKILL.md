---
name: dice-roller
description: This skill should be used when the GM needs to roll dice or when the user asks to "roll dice", "make a dice roll", "roll for initiative", "roll a skill check", "roll damage", or needs to resolve RPG mechanics with random dice outcomes. Provides deterministic dice rolling for tabletop RPG adventures.
---

# Dice Roller Skill

Provides a bash script for rolling dice in RPG adventures with JSON output for programmatic use.

## How to Roll Dice

Execute the dice roller script with a dice expression:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/dice-roller/scripts/roll.sh" "2d6+3"
```

The script is bundled with this skill and executes from the plugin directory.

## Supported Expressions

| Expression | Meaning |
|------------|---------|
| `1d20` | Roll one 20-sided die |
| `2d6` | Roll two 6-sided dice, sum them |
| `1d20+5` | Roll d20, add 5 |
| `3d8-2` | Roll 3d8, subtract 2 |
| `4dF` | Roll 4 Fudge dice (-1, 0, +1 each) |
| `d100` | Roll percentile (1-100) |

## Output Format

The script outputs JSON with individual rolls and computed total:

```json
{
  "expression": "2d6+3",
  "rolls": [4, 2],
  "modifier": 3,
  "total": 9
}
```

## When to Roll

For adventures with RPG rules (indicated by `System.md`), use dice rolls for:

1. **Skill Checks**: Roll per system rules, compare to difficulty threshold
2. **Attack Rolls**: Roll to hit, then roll damage if successful
3. **Saving Throws**: Roll to resist effects or avoid hazards
4. **Initiative**: Roll to determine turn order in combat

## Example Usage

**Skill Check (d20 system)**:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/dice-roller/scripts/roll.sh" "1d20+5"
# Output: {"expression": "1d20+5", "rolls": [14], "modifier": 5, "total": 19}
```
Narrate the outcome based on the result vs the difficulty class.

**Damage Roll**:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/dice-roller/scripts/roll.sh" "2d6+3"
# Output: {"expression": "2d6+3", "rolls": [5, 4], "modifier": 3, "total": 12}
```
Describe the impact narratively - "Your sword bites deep, dealing 12 damage."

## Best Practices

- Always narrate outcomes - players see the story, not raw numbers
- Parse the JSON output to extract the total for mechanical comparisons
- Include context in narration (what was rolled, why it matters)
- For hidden rolls (GM secrets), execute silently and narrate only the outcome
