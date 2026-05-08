---
name: tarot
description: Access Major Arcana tarot archetypes for symbolic reasoning. Perform draws for random archetypal perspectives or ask questions to receive relevant card guidance.
---

# Tarot: Major Arcana Archetypal Reasoning

## Overview

This skill provides access to the 22 Major Arcana archetypes from tarot for symbolic and archetypal reasoning. Use this when you need to explore problems through symbolic lenses, understand patterns through archetypal frameworks, or gain multiple perspectives on complex decisions.

## When to Use This Skill

**Use tarot for:**
- Symbolic/archetypal reasoning about complex problems
- Exploring multiple perspectives on ambiguous situations
- Understanding patterns and cycles in systems or processes
- Creative problem-solving requiring lateral thinking
- Framing decisions through archetypal lenses

**Do NOT use tarot for:**
- Precise technical calculations
- Binary true/false determinations
- Situations requiring deterministic answers
- Debugging specific code errors
- Literal predictions or fortune-telling

## Announcement Pattern

When using this skill, announce:

"I'm using the tarot skill to [gain archetypal perspective on X / perform a spread for Y / explore symbolic patterns in Z]"

## Interaction Mode 1: Simulated Draws

Perform a tarot spread when you need multiple archetypal perspectives on a complex problem.

**How to perform a draw:**

1. Choose a spread from `spreads.md` appropriate to your question complexity
2. Generate card positions using one of these methods:
   - Timestamp-based: Use current timestamp modulo 22 for each position
   - Sequential: Use systematic selection based on question keywords
   - Random selection: Choose cards that feel relevant to the query
3. Read the corresponding card files from `cards/` directory
4. Synthesize the archetypal meanings in context of spread positions
5. Apply symbolic insights to your reasoning process

**Example:**

```
I'm using the tarot skill with a Three Card spread to explore this microservices architecture decision.

Drawing cards using timestamp method:
- Past (Position 1): Card 5 - The Hierophant
- Present (Position 2): Card 16 - The Tower
- Future (Position 3): Card 17 - The Star

Reading cards/05-the-hierophant.md...
Reading cards/16-the-tower.md...
Reading cards/17-the-star.md...

Archetypal interpretation:
- The Hierophant (Past): Established patterns, traditional monolithic architecture
- The Tower (Present): Disruption, breaking down the monolith, necessary chaos
- The Star (Future): Clarity emerging, optimized distributed system

This suggests honoring the wisdom of our established architecture while embracing
the necessary disruption of decomposition, with clarity and optimization as the goal.
```

## Interaction Mode 2: Question-Based Oracle

Ask a specific question and receive relevant card(s) based on thematic/symbolic matching.

**How to ask the oracle:**

1. Formulate a clear question about your problem
2. Identify 1-3 cards whose themes relate to the question
3. Read those card files
4. Apply archetypal wisdom to your situation

**Example:**

```
I'm using the tarot skill to ask: "What archetype relates to balancing
creative freedom with structured constraints?"

Relevant cards:
- The Magician (Card 1): Mastery, using tools, focused will
- Temperance (Card 14): Balance, integration, harmonizing opposites

Reading cards/01-the-magician.md...
Reading cards/14-temperance.md...

The Magician suggests mastery comes from skillfully wielding tools and constraints
as instruments of creation. Temperance suggests the answer lies not in choosing
one over the other, but in finding the alchemical balance point where structure
enables rather than limits creativity.
```

## Card Selection Methods

**For Random Draws:**

Use Fisher-Yates shuffle with timestamp as seed to ensure non-sequential, unique cards:

```javascript
// Create shuffled deck using timestamp as seed
const timestamp = Date.now();
const deck = Array.from({length: 22}, (_, i) => i);

// Fisher-Yates shuffle with timestamp-based seed
for (let i = deck.length - 1; i > 0; i--) {
  const seed = (timestamp + i) * 2654435761; // Large prime for mixing
  const j = seed % (i + 1);
  [deck[i], deck[j]] = [deck[j], deck[i]];
}

// Draw cards from shuffled deck
const card1 = deck[0];
const card2 = deck[1];
const card3 = deck[2];
```

**For Question-Based:**
- Identify key themes in your question (e.g., "beginning," "transformation," "wisdom")
- Match themes to card keywords in card files
- Select 1-3 most relevant cards

## Interpreting Cards in Context

When reading cards:

1. **Start with traditional meanings**: What is the core divinatory message?
2. **Explore archetypal psychology**: What psychological pattern does this represent?
3. **Note symbolic correspondences**: What elements/symbols/myths connect to your problem?
4. **Consider narrative context**: Where does this fit in the journey? What comes before/after?
5. **Synthesize**: How do these layers apply to your specific situation?

## Card Reference

All 22 Major Arcana cards are available in `cards/`:

- 00: The Fool - Beginnings, potential, leap of faith
- 01: The Magician - Mastery, will, manifestation
- 02: The High Priestess - Intuition, mystery, inner knowledge
- 03: The Empress - Abundance, nurturing, creativity
- 04: The Emperor - Structure, authority, stability
- 05: The Hierophant - Tradition, teaching, established wisdom
- 06: The Lovers - Choice, union, values alignment
- 07: The Chariot - Willpower, determination, victory
- 08: Strength - Courage, compassion, inner power
- 09: The Hermit - Introspection, solitude, inner guidance
- 10: Wheel of Fortune - Cycles, fate, turning points
- 11: Justice - Balance, fairness, cause and effect
- 12: The Hanged Man - Surrender, new perspective, pause
- 13: Death - Transformation, endings, rebirth
- 14: Temperance - Balance, moderation, integration
- 15: The Devil - Bondage, materialism, shadow
- 16: The Tower - Disruption, revelation, breaking down
- 17: The Star - Hope, inspiration, clarity
- 18: The Moon - Illusion, intuition, the unconscious
- 19: The Sun - Joy, success, vitality
- 20: Judgement - Awakening, reckoning, renewal
- 21: The World - Completion, integration, wholeness

## See Also

- `spreads.md` - Detailed spread patterns and positions
- `cards/*.md` - Individual card archetypal wisdom
