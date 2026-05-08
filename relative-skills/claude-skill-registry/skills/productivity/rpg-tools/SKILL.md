---
name: rpg-tools
description: Solo RPG mechanical tools for dice rolling, tarot draws, oracles, name generation, character/location/memory management, and story retrieval. Use when the user asks to roll dice, draw tarot cards, consult oracles, generate names, load characters or locations, track memories, or pull from story collections during RPG sessions.
---

# RPG Tools

Mechanical tools for solo RPG sessions. Run scripts from `scripts/`.

## Tool Categories

**Instant Tools** - Work immediately, no data files needed:
- `dice.py` - Dice rolling
- `tarot.py` - Tarot draws
- `oracle.py` - Multi-system oracle

**Campaign Tools** - Require JSON data files in specific directories:
- `namegen.py` - Name generation (needs `namesets/`)
- `characters.py` - Character profiles (needs `characters/`)
- `locations.py` - Location profiles (needs `locations/`)
- `stories.py` - Story collections (needs `stories/`)
- `memories.py` - Memory tracking (needs `memories/`)
- `log.py` - Campaign event log (needs `campaign/log.json`)
- `campaign.py` - Campaign management (needs `campaign/config.json`)

---

## Instant Tools

### Dice Rolling

Roll20-compatible notation with full modifier support.

```bash
python scripts/dice.py "2d6+5"        # Basic roll with modifier
python scripts/dice.py "4d6kh3"       # Keep highest 3 (ability scores)
python scripts/dice.py "2d20kh1+5"    # Advantage
python scripts/dice.py "8d6!"         # Exploding dice
python scripts/dice.py "4dF"          # Fudge/Fate dice
python scripts/dice.py "6d10>=7"      # Count successes
```

Supports: `kh/kl` (keep), `dh/dl` (drop), `r/rr` (reroll), `!` (exploding), `!!` (compounding), `!p` (penetrating), comparison operators for success counting.

### Tarot

Draw cards for oracular guidance.

```bash
python scripts/tarot.py         # Single card
python scripts/tarot.py 3       # Three-card spread
python scripts/tarot.py 5       # Five-card spread
```

Max 10 cards per draw. Full 78-card deck (Major + Minor Arcana).

### Oracle

Multi-system oracle for injecting randomness. Provides raw symbolic material for creative interpretation.

```bash
python scripts/oracle.py axis              # Multi-axis reading (tone/direction/element/action/twist)
python scripts/oracle.py omni              # Full reading: axis + tarot + rune + I Ching + fate + prompt
python scripts/oracle.py tarot [n]         # Draw tarot card(s)
python scripts/oracle.py rune [n]          # Draw Elder Futhark rune(s)
python scripts/oracle.py iching            # Cast I Ching hexagram
python scripts/oracle.py fate [likelihood] # Yes/no oracle (impossible/unlikely/even/likely/certain)
python scripts/oracle.py prompt            # Action + Theme word pair
```

See **[Using the Oracle](references/oracle-guide.md)** for guidance on when to use each oracle type.

---

## Campaign Tools

These tools require JSON data files. See guides for schemas and examples.

### Name Generation

Requires `namesets/*.json`

```bash
python scripts/namegen.py list                              # Show available namesets
python scripts/namegen.py full --nameset ice-age-names      # Generate one name
python scripts/namegen.py full --nameset NAME --count 5     # Multiple names
```

### Characters

Requires `characters/*.json`

```bash
python scripts/characters.py list                        # List character names
python scripts/characters.py list --short                # Show minimal profiles
python scripts/characters.py get NAME                    # Get minimal profile
python scripts/characters.py get NAME --depth full       # Get full profile
python scripts/characters.py get NAME --section powers   # Get specific section
python scripts/characters.py sections NAME               # List available sections
python scripts/characters.py update NAME --field full.motivation --value "New goal" --reason "Story event"
```

Filter options: `--faction`, `--subfaction`, `--tag`, `--location`, `--branch`

### Locations

Requires `locations/*.json`

```bash
python scripts/locations.py list                         # List all locations
python scripts/locations.py list --tag settlement        # Filter by tag
python scripts/locations.py tree                         # Show full hierarchy
python scripts/locations.py get NAME --depth full        # Get full profile
python scripts/locations.py connections NAME             # Show all connections
```

Filter options: `--tag`, `--parent`, `--type`

### Stories

Requires `stories/*.json`

```bash
python scripts/stories.py meta --campaign NAME           # Show available tags/counts
python scripts/stories.py random --campaign NAME         # Random story
python scripts/stories.py random --campaign NAME --theme loss --mood melancholic
python scripts/stories.py show --campaign NAME --story STORY_ID
```

Filter options: `--collection`, `--theme`, `--mood`, `--era`

### Memories

Requires `memories/*.json`

```bash
python scripts/memories.py list --campaign NAME          # List all memories
python scripts/memories.py random --campaign NAME        # Random memory
python scripts/memories.py search "query" --campaign NAME
python scripts/memories.py character NAME                # Memories involving character
python scripts/memories.py location NAME                 # Memories at location
```

Filter options: `--character`, `--location`, `--type`, `--tag`, `--era`, `--session`, `--intensity`, `--perspective`

### Campaign Log

Requires `campaign/log.json`

```bash
python scripts/log.py add "Event summary" --date Y3.D45  # Add log entry
python scripts/log.py add "Event" --date-loose "after the festival"
python scripts/log.py add "Major event" --importance critical --branch main
python scripts/log.py add "Event" --characters "juno:defining,tam:present"
python scripts/log.py list                               # List all entries
python scripts/log.py list --branch main                 # Filter by branch
python scripts/log.py list --character juno              # Filter by character
python scripts/log.py list --from Y3.D1 --to Y3.D100     # Date range
python scripts/log.py show log-00001                     # Show specific entry
python scripts/log.py delete log-00001                   # Delete entry
```

Key options: `--date`, `--date-loose`, `--branch`, `--characters`, `--locations`, `--importance`, `--tags`, `--session`, `--json`

Filter options: `--branch`, `--character`, `--location`, `--importance`, `--tag`, `--from`, `--to`, `--limit`, `--verbose`

### Campaign Management

Requires `campaign/config.json`

```bash
python scripts/campaign.py init "Campaign Name"          # Initialize new campaign
python scripts/campaign.py show                          # Show config
python scripts/campaign.py branch list                   # List all branches
python scripts/campaign.py branch switch main            # Switch active branch
python scripts/campaign.py branch create arc-two "The Second Arc" --from main
python scripts/campaign.py state show                    # Show campaign state
python scripts/campaign.py state show --character juno   # Show character state
python scripts/campaign.py state set juno location "The Spire" --reason "Traveled north"
python scripts/campaign.py changelog show                # Show all changes
python scripts/campaign.py changelog show --character juno --limit 5
```

Key options: `--json`, `--reason` (required for state changes)

---

## Session Workflow

Guides for before and after play:

- **[Session Setup](references/session-setup-guide.md)** - Calibrate tone, direction, and pacing
- **[Session Debrief](references/session-debrief-guide.md)** - Post-session reflection and character growth

**Optional modifiers:**
- [Mature Content](modifiers/mature-content.md) - For authentic dark themes
- [Combat Realism](modifiers/combat-realism.md) - For grounded, consequential violence

---

## Creating Campaign Data

Guides for creating your own JSON data files:

- **[Creating Characters](references/character-guide.md)** - Character JSON schema and workflow
- **[Creating Locations](references/location-guide.md)** - Location hierarchy and connections
- **[Creating Memories](references/memories-guide.md)** - Memory tracking with cross-references
- **[Creating Namesets](references/nameset-guide.md)** - Name generation collections
- **[Capturing Stories](references/story-capture-guide.md)** - Story extraction workflow
- **[Using the Oracle](references/oracle-guide.md)** - Oracle types and when to use them
- **[Managing Campaign State](references/campaign-state-guide.md)** - Branches, log, state, and changelog
