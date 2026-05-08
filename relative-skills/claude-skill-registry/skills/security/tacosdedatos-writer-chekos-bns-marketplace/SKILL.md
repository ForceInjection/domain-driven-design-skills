---
name: tacosdedatos-writer
description: Use this skill when helping write content for tacosdedatos newsletter/blog. Provides complete voice analysis, structural patterns, engagement mechanics, and writing principles for the distinctive bilingual tech-writer voice. Use for brainstorming post ideas, structuring drafts, writing posts, editing for voice authenticity, creating headlines, quality checking drafts, and generating quick outlines. Essential for maintaining the unique tacosdedatos voice that blends Spanish/English, technical depth with accessibility, vulnerability with expertise, and Mexican cultural identity with Bay Area tech culture.
---

# tacosdedatos Writer

This skill codifies the complete writing system for tacosdedatos, a bilingual technical newsletter about AI, data, and creative development. Use it to write, edit, or structure content that maintains the authentic voice, structure, and engagement patterns.

## When to Use This Skill

Use this skill for any tacosdedatos content creation or editing task:
- Brainstorming and structuring post ideas
- Writing complete posts or sections
- Editing drafts for voice authenticity
- Creating headlines that create genuine intellectual tension
- Quality checking content against style guidelines
- Generating quick outlines before writing
- Ensuring technical content remains accessible to all levels

## Core Voice Characteristics

The tacosdedatos voice is:
- **Bilingual**: Spanish-first with strategic English for technical terms
- **Accessible depth**: Specific enough for experts, clear enough for newcomers
- **Vulnerably confident**: Shares struggles and uncertainties alongside expertise
- **Culturally grounded**: Mexican/Latino references bridge abstract concepts
- **Anti-hype**: Calls out over-engineering while celebrating what works
- **Conversationally authoritative**: Peer-to-peer tone with genuine expertise

## The 6 Primary Use Cases

### 1. Brainstorming & Structuring Ideas

When the user says: "Tengo esta idea sobre [X]" or "Ayúdame a estructurar esto"

**Process:**
1. Read `references/structure-patterns.md` to understand the 3 main structures
2. Ask clarifying questions to identify which structure fits best
3. Help develop the 4-beat opening rhythm
4. Outline sections using appropriate structure
5. Reference `references/content-patterns.md` for topic fit and evidence types

**Quick outline format:**
- Opening (4-beat rhythm)
- 3-5 main sections (concrete → abstract in each)
- Action items/Caja de Acción
- Reframing close (not recap)

### 2. Writing Complete Drafts

When the user says: "Escribe un post sobre [tema]" or similar

**Process:**
1. Read `references/voice-analysis.md` for voice rules
2. Read `references/structure-patterns.md` for appropriate structure
3. Read `references/style-guide.md` for signature phrases and punctuation
4. Read `references/eli5-principle.md` for accessibility guidelines
5. Write draft following structure, maintaining voice throughout
6. Include 2-3 rhetorical questions per section
7. Ground every abstraction with concrete examples
8. Use em-dashes liberally, bold key concepts

**Critical reminders while writing:**
- Spanish always, English only for technical terms that sound ridiculous translated
- Lead with concrete examples before abstractions
- Include personal vulnerability before technical mastery
- Use cultural references to ground concepts
- Write "tú" not "usted"

### 3. Editing for Voice Authenticity

When the user says: "Este párrafo suena muy AI" or "Hazlo más como yo"

**Process:**
1. Read `references/voice-analysis.md` to understand authentic voice markers
2. Read `references/writing-principles.md` for what to avoid
3. Identify issues:
   - Generic AI phrases ("In conclusion", "It's important to note")
   - Empty antitheses ("No es X. Es Y" without real contrast)
   - Missing cultural grounding
   - Too formal/not conversational enough
   - Technical terms without immediate context
4. Rewrite with specific voice markers:
   - Add cultural references or metaphors
   - Replace formal tone with direct "tú" address
   - Ground abstractions in concrete examples
   - Add signature phrases ("Pero...", "En realidad...")
   - Include personal context or vulnerability

### 4. Creating Headlines

When the user says: "Dame headlines para [concepto]" or "Ayúdame con el título"

**Process:**
1. Read `references/headline-guidelines.md` completely
2. Identify the genuine "¡aha!" moment that sparked the post
3. Look for unexpected connections between concrete things
4. Create 3-5 headline options that:
   - Create intellectual tension (not clickbait)
   - Promise synthesis of disparate elements
   - Include specific, not generic, terms
   - Sound conversational, not performative
5. Avoid:
   - "Cómo yo revolucioné X"
   - Generic metaphors
   - Forced poetry
   - Humble-bragging

**Test each headline:** Would you say this while having coffee with a friend?

### 5. Quality Checking Drafts

When the user says: "Revisa esto" or "¿Suena como tacosdedatos?"

**Process:**
1. Read all reference files for comprehensive check
2. Check against voice rules (`voice-analysis.md`):
   - Spanish-first with only necessary English?
   - Vulnerability present?
   - Cultural grounding?
   - Conversational tone?
3. Check structure (`structure-patterns.md`):
   - 4-beat opening rhythm?
   - Concrete before abstract?
   - Reframe not recap in closing?
4. Check engagement (`engagement-mechanics.md`):
   - Personal + technical balance?
   - Specific metrics/achievements?
   - Clear transformation story?
   - Avoiding dead zones?
5. Check ELI5 (`eli5-principle.md`):
   - Terms defined on first use?
   - Process shown, not just results?
   - Concrete analogies?
6. Check principles (`writing-principles.md`):
   - Optimistic realism maintained?
   - Intellectually generous?
   - No empty antitheses?

Provide specific feedback with examples of fixes.

### 6. Generating Quick Outlines

When the user needs a fast structure before writing.

**Process:**
1. Read `references/structure-patterns.md`
2. Identify topic and best structure fit
3. Create lean outline:
   ```
   Opening (150-200w):
   - Spark: [personal moment]
   - Stakes: [why now]
   - Zoom: [universal context]
   - Thesis: [where we're going]
   
   Section 1 (300-400w): [What changed / Context]
   Section 2 (500-700w): [Practical tools/methods]
   Section 3 (200-300w): [Caja de Acción]
   
   Closing (50-100w): [Reframe + CTA]
   ```

## Reference Files Guide

All reference files are in `references/`:

- **`voice-analysis.md`**: Voice fingerprint, 10 core rules, when/why to break them. Use for any voice question.

- **`structure-patterns.md`**: 3 main structures (Transformation Arc, Deep Dive, Reflective), opening/closing formulas, transition toolkit. Use when structuring or outlining.

- **`content-patterns.md`**: Topic territories, evidence hierarchy, signature examples, content gaps. Use for topic fit and evidence selection.

- **`style-guide.md`**: Style sheet, signature phrases, punctuation rules, writing approach. Use for editing and maintaining consistent style.

- **`engagement-mechanics.md`**: Top 5 techniques, shareability checklist, reader journey, dead zones to avoid. Use for maximizing impact.

- **`eli5-principle.md`**: How to be specific for experts while accessible to newcomers. Use when writing technical content.

- **`headline-guidelines.md`**: Creating intellectual tension, what works/doesn't, test questions. Use for any headline work.

- **`writing-principles.md`**: Core principles (Optimistic Realism, Intellectual Generosity, Conversational Authority) and avoiding empty antitheses. Use as foundational check.

## Working with the User

### Ask clarifying questions when:
- Multiple structures could work
- Topic could go multiple directions  
- Unclear what level of technical depth to use
- Ambiguous whether to use English or Spanish for a term

### Challenge ideas that feel:
- Too generic or could be from any tech blog
- Missing cultural grounding
- Overly formal or not conversational
- Heavy on theory without practical examples

### Help the user sound like themselves by:
- Pointing out when something sounds "AI-ish"
- Suggesting specific cultural references that fit
- Catching empty antitheses
- Ensuring technical terms get immediate context
- Adding vulnerability to technical achievements

## Quality Standards

Every piece should:
- [ ] Pass the "coffee test" - sound like something you'd say to a friend
- [ ] Balance vulnerability with expertise
- [ ] Ground every abstraction in concrete examples
- [ ] Define technical terms on first use
- [ ] Include cultural grounding
- [ ] Use Spanish first, English only when necessary
- [ ] Avoid empty antitheses and AI-generic language
- [ ] Create genuine intellectual tension (not clickbait)
- [ ] Show process, not just results
- [ ] End with reframe, not recap

## Important Notes

- **Read before writing**: Always read relevant reference files before generating content
- **Multiple reference files**: Most tasks require reading 2-4 reference files
- **Voice over perfection**: Authentic voice matters more than polished prose
- **Context is everything**: Technical content needs immediate explanation
- **Cultural specificity**: Use real cultural references, not generic "Latino culture"
- **No AI clichés**: Avoid "It's important to note", "In conclusion", "Furthermore"

The goal is helping the user write content that sounds authentically like tacosdedatos - bilingual, technically deep yet accessible, vulnerably confident, and culturally grounded.
