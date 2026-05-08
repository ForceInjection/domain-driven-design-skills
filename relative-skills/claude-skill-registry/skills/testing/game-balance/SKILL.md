---
name: game-balance
description: Validate unit stats and combat values against GAME_REQUIREMENTS.md. Use when modifying unit properties, combat formulas, or terrain effects. Triggers on "balance", "stats", "unit values", "combat modifier".
allowed-tools: Read
---

# Game Balance Validator

## Instructions

1. Read the current GAME_REQUIREMENTS.md for authoritative values
2. Compare implementation against requirements
3. Flag any discrepancies

## Quick Reference

### Unit Stats
| Unit | Cost | Move | Attack | Defense | Range | Sight |
|------|------|------|--------|---------|-------|-------|
| Infantry | 100 | 3 | 5 | 4 | 1 | 2 |
| Tank | 300 | 5 | 8 | 6 | 1 | 2 |
| Artillery | 250 | 2 | 7 | 2 | 2-4 | 3 |
| Fighter | 350 | 8 | 6/3 | 4 | 1 | 4 |
| Bomber | 400 | 6 | 9 | 2 | 1 | 3 |

### Terrain Effects
| Terrain | Move Cost | Defense |
|---------|-----------|---------|
| Plains | 1 | +0% |
| Forest | 2 | +25% |
| Hills | 2 | +30% |
| Mountains | 3 | +40% |
| City | 1 | +35% |
| River | 2 | -10% |
| Road | 0.5 | +0% |
| Beach | 1 | -20% |

### Combat Modifiers
| Matchup | Modifier |
|---------|----------|
| Tank vs Infantry (plains) | +50% |
| Infantry vs Tank | -30% |
| Fighter vs Bomber | +75% |
| Fighter vs Ground | -40% |

### Damage Formula
```
Damage = (Attack × HP/10) × TerrainMod × Random(0.8-1.2)
```

## Validation Checklist

- [ ] Unit costs match requirements
- [ ] Movement values correct
- [ ] Attack/Defense stats accurate
- [ ] Range values (especially Artillery 2-4)
- [ ] Terrain modifiers applied correctly
- [ ] Combat modifiers implemented
- [ ] HP system uses 10 HP base
