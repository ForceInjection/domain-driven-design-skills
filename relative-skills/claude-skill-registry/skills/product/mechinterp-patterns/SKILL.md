---
name: mechinterp-patterns
description: Reference catalog of recurring SAE feature patterns - check when labeling new features, add new patterns as discovered
---

# MechInterp Patterns

A growing catalog of recurring patterns observed during SAE feature investigation. Use this to quickly recognize common archetypes and maintain consistency in labeling.

## Pattern Catalog Location

The main patterns document is at:
```
/mnt/e/mechinterp_runs/potential_patterns.md
```

**Always read this file** when:
1. Starting to label a new feature - check if it matches a known pattern
2. You've identified what seems like a recurring theme
3. You want consistent labeling terminology

## Quick Pattern Reference

| Pattern | Key Signature | Example Label |
|---------|---------------|---------------|
| Death-Averse | SCU/SPU driver + QR/SS/CB suppressed | "Offensive Intensity (Death-Averse)" |
| Zombie/Respawn | QR driver + Comeback/SJ enriched | "QR Stacker (Slayer)" |
| Ink Efficiency | ISM/ISS/IRU driver + mobility suppressed | "Ink Economy (Anti-Mobility)" |
| Mobility | SSU/RSU driver + ink suppressed | "Stealth Mobility Build" |
| Weapon-Gated | >50% single weapon | "{Weapon} {Ability} Build" |
| Special Power | SPU/SCU driver + threshold effects | "Special Power Stacker" |
| Weak/Auxiliary | <10% decoder percentile + no structure | "Weak/Aux Feature {ID}" |

## When to Update the Patterns Document

### Add a New Pattern When:
- You see a signature that doesn't match existing patterns
- The pattern has a clear "why would the model learn this?" explanation

### Add a Feature to Existing Pattern When:
- The feature clearly matches the signature
- It reinforces the pattern interpretation

### Promote to Confirmed When:
- 3+ features show the same pattern
- Signature is consistent across features

## Usage in Investigation Workflow

**Phase 1 (Overview)**: After running overview, check patterns document:
```
Does the family breakdown + weapon distribution match a known pattern?
If yes → Use pattern's label style and run confirmatory experiments
If no → Standard deep dive, potentially discover new pattern
```

**Phase 5 (Label Proposal)**: Before finalizing label:
```
Is this a known pattern? → Use consistent terminology
Is this a new pattern? → Add to "Suspected Patterns" in the document
```

## Maintaining Consistency

When labeling features that match known patterns, use consistent terminology:

| Pattern | Preferred Terms |
|---------|-----------------|
| Death-Averse | "Death-Averse", "Anti-Zombie" |
| Zombie | "Zombie", "Respawn-Focused" |
| Mobility | "Mobility", "Movement" |
| Ink Efficiency | "Ink Economy", "Ink Efficiency" |
| Weapon-Gated | "{Weapon} Build", "{Weapon}-Specific" |

## See Also

- **mechinterp-investigator**: Main investigation workflow
- **mechinterp-glossary-and-constraints**: Ability families and terminology
- **splatoon3-meta**: Game meta knowledge for pattern interpretation
