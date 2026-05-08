---
name: dh-players
description: This skill should be used when the GM needs to help players create Daggerheart characters, select a class/ancestry/community, define Experiences with bounded constraints, choose domain cards, or handle level advancement (1-10). Provides templates for character sheets, session state, and Experience definitions to prevent semantic drift during gameplay.
version: 1.0.0
---

# Character Creation and Advancement Skill

Guide players through creating and advancing Daggerheart characters following SRD rules.

**Authoritative Source**: For exact rule wording, use the `dh-rules` skill to reference `srd/contents/Character Creation.md`.

## File Structure

Character files follow the corvran directory structure with Daggerheart-specific content:

```
players/
  {character-slug}/
    sheet.md   # Use sheet-template.md format (traits, HP, Stress, Hope, domain cards, current status)
    story.md   # Use story-template.md format (objectives, story arcs, recent events)
```

The `sheet.md` contains character data including current game state (HP, Stress, Hope, conditions). The `story.md` tracks narrative elements like objectives and story arcs.

## Character Creation Overview

Follow these steps to create a new character:

1. **Choose a Class and Subclass** - Class determines HP, Stress, Evasion, domain access; subclass grants Foundation card
2. **Select an Ancestry** - Grants two ancestry features and narrative elements
3. **Select a Community** - Grants a community feature reflecting upbringing
4. **Assign Trait Modifiers** - Distribute +2, +1, +1, +0, +0, -1 among the six traits
5. **Record Additional Info** - Level, Evasion, HP, Stress slots, starting Hope
6. **Choose Equipment** - Weapons, armor, and starting gear
7. **Create Background** - Answer background questions from character guide
8. **Define Experiences** - Create two Experiences at +2 each with explicit scope
9. **Select Domain Cards** - Choose two cards from your class's domains
10. **Create Connections** - Establish relationships with other PCs

## The Six Traits

Daggerheart characters have six traits that measure their capabilities:

| Trait | Measures | Common Uses |
|-------|----------|-------------|
| Agility | Speed, reflexes, coordination | Dodging, acrobatics, quick reactions |
| Strength | Physical power, endurance | Lifting, breaking, melee damage |
| Finesse | Precision, dexterity, fine control | Picking locks, delicate work, ranged attacks |
| Instinct | Awareness, intuition, quick reactions | Sensing danger, reading situations |
| Presence | Charisma, willpower, force of personality | Persuasion, intimidation, spellcasting |
| Knowledge | Learning, memory, reasoning | Recalling lore, deduction, arcane magic |

### Trait Modifiers

At character creation, assign the modifiers **+2, +1, +1, +0, +0, -1** to your character's traits in any order you wish. Place higher modifiers in traits that match your class's primary abilities for optimal effectiveness.

## Classes

Daggerheart features 9 classes:

| Class | Primary Traits | Role | Domains |
|-------|----------------|------|---------|
| Bard | Presence, Knowledge | Support, inspiration | Codex, Grace |
| Druid | Instinct, Agility | Nature magic, shapeshifting | Sage, Arcana |
| Guardian | Strength, Agility | Protection, defense | Valor, Blade |
| Ranger | Instinct, Finesse | Tracking, ranged combat | Bone, Sage |
| Rogue | Finesse, Agility | Stealth, precision | Midnight, Grace |
| Seraph | Presence, Strength | Divine power, healing | Splendor, Valor |
| Sorcerer | Presence, Instinct | Innate magic, elements | Arcana, Midnight |
| Warrior | Strength, Finesse | Combat, martial prowess | Blade, Bone |
| Wizard | Knowledge, Presence | Learned magic, versatility | Codex, Splendor |

Each class provides:
- Starting trait modifier spread
- Base Evasion
- HP and Stress slots
- Class features
- Domain access (2 domains)
- Starting equipment

## Subclasses

Characters choose a subclass at character creation and take its **Foundation** card. Each class has two subclass options in the SRD. Subclasses provide:
- A Foundation card with starting subclass abilities
- Additional subclass features at levels 2, 6, and 10
- Thematic specialization within the class's role

## Ancestries

Ancestries represent your character's heritage. Each ancestry provides:
- Two ancestry features (choose from options)
- Physical characteristics guidance
- Narrative hooks

### SRD Ancestries

- Clank (Constructed beings)
- Drakona (Draconic lineage)
- Dwarf (Mountain folk)
- Elf (Fey-touched)
- Faerie (Small magical beings)
- Faun (Nature-connected)
- Firbolg (Giant-kin)
- Fungirl (Fungal beings)
- Galapa (Turtle folk)
- Giant (Towering humanoids)
- Goblin (Small and cunning)
- Halfling (Small and lucky)
- Human (Adaptable)
- Infernis (Hell-touched)
- Katari (Cat folk)
- Orc (Strong and proud)
- Ribbet (Frog folk)
- Simian (Ape folk)

**Mixed Ancestry**: Take the top (first-listed) ancestry feature from one ancestry and the bottom (second-listed) ancestry feature from another.

## Communities

Communities represent where your character was raised. Each community provides:
- One community feature
- Social connections
- Cultural background

### SRD Communities

- Highborne (Nobility)
- Loreborne (Scholars)
- Orderborne (Military/Law)
- Ridgeborne (Mountain dwellers)
- Seaborne (Coastal/Sailors)
- Skyborne (Aerial/High places)
- Underborne (Underground)
- Wanderborne (Travelers/Nomads)
- Wildborne (Wilderness)

## Experiences

Experiences represent your character's background and training. At character creation, your PC gets **two Experiences, each with a +2 modifier**. When making a move, you can spend a Hope to add a relevant Experience's modifier to an action or reaction roll.

### Experience Structure

Use the bounded constraint format to prevent semantic drift:

```
references/experience-template.md
```

Each Experience defines:
- **Modifier**: The bonus applied (starts at +2 at character creation)
- **Narrative Origin**: How the character acquired this experience
- **Applies When**: Specific situations where it applies (positive scope)
- **Does NOT Apply**: Explicit exclusions

**Important constraints**: An Experience can't be too broadly applicable (e.g., "Lucky" or "Highly Skilled" could apply to any roll). It also can't grant specific mechanical benefits like magic spells or special abilities.

### Critical Guidance for Experiences

**Treat Experiences as bounded permissions, not general traits.**

- Only apply an Experience when the action clearly falls within its positive scope
- When scope is unclear, default to NOT applying the bonus
- Experiences do not grant abilities; they modify action rolls within their scope

## Combat Stats

### Evasion

Your character's starting **Evasion is determined by their class**. Copy this number into the Evasion field.

Evasion can be modified by ancestry features, subclass features, armor, weapons, and magic items. **Evasion is NOT modified by traits** (unlike D&D AC).

Attackers must meet or exceed your Evasion with their attack roll to hit you.

### Hit Points (HP)

Characters have HP slots (typically 6). Damage is applied based on thresholds:
- Below Major threshold: Mark 1 HP
- Meets/exceeds Major: Mark 2 HP
- Meets/exceeds Severe: Mark 3 HP

**Damage Thresholds**:
- Major = Level + Armor Major Base
- Severe = Level + Armor Severe Base

When all HP slots are marked, the character is dying.

### Stress

Characters have Stress slots (typically 6). Stress accumulates from:
- Narrative consequences
- Failed Fear rolls
- Certain ability effects

**At Maximum Stress**: Gain the Vulnerable condition.

### Armor

Armor provides:
- **Armor Score**: Reduces incoming damage
- **Armor Slots**: Can mark slots instead of HP (1 slot = 1 HP regardless of threshold)
- **Threshold Bonuses**: Adds to Major/Severe thresholds

## Hope

Characters can hold up to 6 Hope tokens. **At character creation, start with 2 Hope.**

**Gaining Hope**: When your hope die is higher on an action roll

**Spending Hope**: Reroll a die, boost damage, activate certain class features

Hope tokens persist between sessions until spent.

## Domain Cards

Characters choose domain cards from their class's accessible domains.

### Domain Card Selection

At character creation:
1. Identify your class's two domains
2. Select starting domain cards (number per class)
3. Record each card's name, domain, level, and recall cost

Domain cards include:
- **Name**: The card's name
- **Domain**: Which domain it belongs to
- **Level**: Card's power level (1-5)
- **Recall Cost**: Resources needed to recall after use

## Recording the Character

Write character data to `players/{character-slug}/sheet.md` using the Daggerheart template:

```
references/sheet-template.md
```

For a completed example, see:
```
references/sheet-example.md
```

### Daggerheart Sheet Sections

The sheet.md file must include:

1. **Character Identity** - Name, class, subclass, level, ancestry, community
2. **Traits** - All six traits with modifiers
3. **Combat Stats** - Evasion, HP slots, Stress slots, Armor Score, Damage Thresholds
4. **Hope** - Current Hope tokens (max 6)
5. **Experiences** - Using bounded constraint format
6. **Domain Cards** - Cards from accessible domains
7. **Equipment** - Active weapon and armor
8. **Features** - Class, subclass, ancestry, and community features

## Level Advancement

Characters advance from level 1 to level 10. The party levels up together whenever the GM decides a narrative milestone has been reached (typically every 3 sessions).

### Tiers

Daggerheart's 10 levels are divided into 4 tiers that affect damage thresholds, tier achievements, and advancement access:

| Tier | Levels | Significance |
|------|--------|--------------|
| Tier 1 | 1 | Starting tier |
| Tier 2 | 2-4 | First tier achievements unlock |
| Tier 3 | 5-7 | Mid-level power increase |
| Tier 4 | 8-10 | High-level mastery |

### Level Up Steps

Follow these four steps each time the party levels up:

#### Step 1: Tier Achievements

When entering a new tier (levels 2, 5, 8), gain these benefits:

| Level | Tier Achievement |
|-------|------------------|
| 2 | Gain a new Experience at +2, permanently increase Proficiency by 1 |
| 5 | Gain a new Experience at +2, permanently increase Proficiency by 1, clear any marked traits |
| 8 | Gain a new Experience at +2, permanently increase Proficiency by 1, clear any marked traits |

#### Step 2: Choose Advancements

Choose **two advancements** from your current tier or below. Each advancement has slots; mark one slot when chosen. Options with multiple slots can be taken multiple times.

| Advancement | Effect | Slots |
|-------------|--------|-------|
| Increase Traits | Choose 2 unmarked traits, gain +1 to each, mark them (can't increase again until next tier clears marks) | Per tier |
| Add HP Slot | Permanently add 1 HP slot | Multiple |
| Add Stress Slot | Permanently add 1 Stress slot | Multiple |
| Increase Experience | Choose 2 Experiences, gain +1 to each | Multiple |
| Additional Domain Card | Take a domain card at or below your level from your class's domains | Multiple |
| Increase Evasion | Gain permanent +1 to Evasion | Multiple |
| Upgrade Subclass Card | Take the next subclass card (Foundation → Specialization → Mastery). Locks out multiclass option for this tier. | Per tier |
| Increase Proficiency | Increase Proficiency by 1, add 1 damage die to weapon. **Costs 2 advancement slots.** | Per tier |
| Multiclass | Choose additional class, gain its class feature and one domain. Take foundation card from one of its subclasses. Locks out upgraded subclass and future multiclass. **Costs 2 advancement slots.** | Once ever |

#### Step 3: Increase Damage Thresholds

All damage thresholds increase by 1:
- Major = Level + Armor Major Base
- Severe = Level + Armor Severe Base

#### Step 4: Gain Domain Card

Acquire a new domain card at your level or lower from one of your class's domains. Add it to your loadout or vault. You may also exchange one previously acquired card for a different card of the same level or lower.

### Proficiency

Proficiency determines the number of damage dice rolled with weapons. It increases:
- At character creation (class-based starting value)
- At tier achievements (levels 2, 5, 8)
- Via the "Increase Proficiency" advancement (costs 2 slots)

### Recording Level Up Changes

Update the character sheet (`players/{slug}/sheet.md`) with:
1. New level number
2. Updated damage thresholds
3. New Experiences (if tier achievement)
4. Updated Proficiency (if tier achievement or advancement)
5. Marked advancement slots
6. Marked traits (if "Increase Traits" was chosen)
7. New domain cards
8. Any new HP/Stress/Evasion values

## Multiclassing

Daggerheart supports multiclassing, allowing characters to gain features from a second class.

### Multiclassing Requirements

- Character must be at least level 2
- Must meet the new class's trait prerequisites
- Gain limited features from the new class

### What Multiclassing Provides

- Access to the new class's starting features
- Access to the new class's domains for domain cards
- Subclass access at appropriate multiclass levels

### What Multiclassing Does NOT Provide

- Full HP/Stress slot progression
- All starting equipment
- Duplicate features

## Rolling During Character Creation

Use the dice-roller skill for any randomization:

**Duality Dice for trait-related rolls**:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/../corvran/skills/dice-roller/scripts/roll.sh" "DdD+2"
```

**Standard dice for other purposes**:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/../corvran/skills/dice-roller/scripts/roll.sh" "1d6"
```

## Fallback Without Dice Roller

If the corvran dice-roller is unavailable, describe the required roll and ask the player for the result:

> "Roll 2d12 for your Duality Dice and add your Agility modifier (+2). Tell me both die values and the total."

## References

Detailed templates in this skill's `references/` directory:

- `sheet-template.md` - Blank character sheet template
- `sheet-example.md` - Completed Level 1 Guardian example
- `story-template.md` - Character story template (objectives, arcs, events)
- `experience-template.md` - Bounded Experience constraint template
