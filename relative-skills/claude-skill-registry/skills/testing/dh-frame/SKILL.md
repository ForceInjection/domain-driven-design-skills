---
name: dh-frame
description: This skill should be used when creating a new Daggerheart campaign, establishing world tone and themes, selecting or building a campaign frame, or reframing an existing adventure. Campaign frames provide pitch, tone, themes, community/ancestry/class guidance, principles, distinctions, inciting incidents, and special mechanics for a particular type of story.
version: 1.0.0
---

# Campaign Frame Skill

Guide GMs through selecting, customizing, or creating campaign frames that shape the tone, themes, and mechanics of a Daggerheart adventure.

**Authoritative Source**: For official frame content, reference the SRD frames in `references/srd/`.

## What is a Campaign Frame?

A campaign frame is a template that provides inspiration, tools, and mechanics to support a particular type of story. Frames establish the narrative foundation before character creation begins, ensuring all players share expectations about tone, themes, and the world they'll inhabit.

Every campaign frame has a **complexity rating** (● to ●●●) indicating how much its mechanics deviate from core Daggerheart rules.

## When to Use This Skill

### Initial World Creation (Primary Use)

Invoke this skill when starting a new Daggerheart campaign to:
- Select an existing SRD frame or create a custom one
- Establish tone, themes, and touchstones
- Prepare session zero questions
- Identify special mechanics that will apply

### Player-Initiated Reframing

Players may request reframing when:
- The campaign's direction has shifted significantly
- The group wants to explore different themes
- A major narrative turning point demands new framing

When reframing, preserve continuity while adjusting:
- Tone and feel (can shift based on story events)
- Active principles (which ones are most relevant now)
- Distinctions (new world elements revealed)

### GM-Initiated Mid-Adventure Reframing (Rare)

GMs might reframe when:
- A major world-changing event occurs
- The campaign pivots to a new arc with different themes
- Players have outgrown the original frame's scope

**Caution**: Mid-adventure reframing should be discussed with players. Sudden tonal shifts without buy-in can feel jarring.

## Frame Structure

Each campaign frame includes these sections:

| Section | Purpose |
|---------|---------|
| **Pitch** | 2-3 sentence hook to present to players |
| **Tone & Feel** | Adjectives describing the emotional atmosphere |
| **Themes** | Core narrative tensions and questions explored |
| **Touchstones** | Media references that capture the vibe |
| **Overview** | Background lore and setting context |
| **Communities** | How SRD communities fit this setting |
| **Ancestries** | Ancestry-specific adaptations |
| **Classes** | Class-specific setting connections |
| **Player Principles** | Guidelines for player roleplay |
| **GM Principles** | Guidelines for GM narration |
| **Distinctions** | Unique setting elements and rules |
| **Inciting Incident** | Campaign-starting scenario |
| **Campaign Mechanics** | Special rules unique to this frame |
| **Session Zero Questions** | Discussion prompts for character creation |

For detailed explanations, see `references/frame-structure.md`.

## Using an SRD Frame

The Daggerheart SRD includes official campaign frames. To use one:

1. **Read the frame** from `references/srd/`
2. **Present the pitch** to players before session zero
3. **Share tone, themes, and touchstones** so players understand expectations
4. **During session zero**, use the community/ancestry/class guidance and questions
5. **Record frame elements** in your world's documentation
6. **Apply campaign mechanics** as specified in the frame
7. **Initialize resources** - GM starts with 5 Fear tokens

### Campaign Resource Initialization

When a new campaign begins:

| Resource | Starting Value |
|----------|---------------|
| GM Fear tokens | 5 |
| Player Hope tokens | 2 each (per character creation) |

The GM's starting Fear provides immediate narrative options for the opening session without requiring player failures first.

### Recording Frame Selection

When using a frame, document it in `worlds/{slug}/world_state.md`:

```markdown
## Campaign Frame

**Frame**: [Frame Name]
**Complexity**: [● to ●●●]

### Active Themes
- [Theme 1]
- [Theme 2]

### Session Zero Answers
> [Question from frame]
[Player/group answer]

### Special Mechanics
[Any frame-specific rules in effect]
```

## Creating a Custom Frame

Use `references/frame-template.md` as a starting point. Fill in each section thoughtfully:

### Step 1: Define the Core Concept

Start with:
- **Pitch**: What's the elevator pitch? (2-3 sentences max)
- **Tone & Feel**: List 5-7 adjectives
- **Themes**: What tensions will the campaign explore?
- **Touchstones**: What media captures the vibe?

### Step 2: Establish the World

Write the **Overview** section covering:
- Recent history leading to current tensions
- Major factions or forces in conflict
- What the world was like before and what changed
- Stakes for the characters

### Step 3: Adapt Character Options

For each community, ancestry, and class:
- How does it fit this setting?
- What unique aspects exist here?
- What session zero questions connect characters to the frame?

### Step 4: Define Principles

**Player Principles** should encourage:
- Engagement with frame themes
- Character vulnerability appropriate to tone
- Roleplay that reinforces the setting

**GM Principles** should guide:
- How to portray NPCs and factions
- What kinds of challenges to present
- How to maintain tonal consistency

### Step 5: Create Distinctions

Distinctions are unique setting elements:
- Geography, time, or cosmological differences
- Social structures or customs
- Supernatural elements or unique dangers

Each distinction should have narrative and potentially mechanical implications.

### Step 6: Design the Inciting Incident

The inciting incident should:
- Thrust characters into the central conflict
- Connect to frame themes
- Provide clear initial direction
- Leave room for player agency

### Step 7: Add Campaign Mechanics (Optional)

If your frame requires special rules:
- Keep complexity appropriate to the rating
- Clearly explain triggers and effects
- Consider how mechanics reinforce themes

### Step 8: Prepare Session Zero Questions

Questions should:
- Connect characters to the world
- Establish relationships and stakes
- Reveal backstory relevant to themes
- Vary by community/ancestry/class where appropriate

## Complexity Ratings

| Rating | Meaning |
|--------|---------|
| ● | Minimal mechanical changes; mostly narrative framing |
| ●● | Some new mechanics or modified rules |
| ●●● | Significant mechanical additions; requires familiarity with core rules |

## Integration with World Building

Frame elements should flow into your world documentation:

| Frame Section | Maps To |
|---------------|---------|
| Overview | `worlds/{slug}/world_state.md` |
| Communities/Ancestries/Classes | Character creation guidance |
| Distinctions | `worlds/{slug}/locations.md`, custom rules |
| Inciting Incident | Opening session prep |
| NPCs from frame | `worlds/{slug}/characters.md` |
| Session Zero Answers | Player backstory integration |

## Reframing an Existing Campaign

When reframing mid-campaign:

1. **Discuss with players** - Get buy-in for the tonal/thematic shift
2. **Identify what persists** - Core relationships, ongoing plots, character arcs
3. **Define what changes** - New themes, adjusted tone, revealed distinctions
4. **Update documentation** - Revise world_state.md to reflect new frame
5. **Introduce narratively** - The reframe should feel earned, not arbitrary

### Partial Reframing

Sometimes only parts of the frame need adjustment:
- **Tone shift**: The story grows darker or lighter
- **New themes emerge**: Original themes resolve, new ones arise
- **Distinctions revealed**: Hidden world elements come to light

Document changes as "Frame Evolution" in world_state.md.

## References

- `references/frame-template.md` - Blank template for custom frames
- `references/frame-structure.md` - Detailed explanation of each section
- `references/srd/` - Official Daggerheart SRD frames
