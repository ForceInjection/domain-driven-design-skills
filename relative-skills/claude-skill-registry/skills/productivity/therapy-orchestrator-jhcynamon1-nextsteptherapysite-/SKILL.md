---
name: therapy-orchestrator
description: "Master coordinator for NextStep Therapy's 12 skills. Diagnoses what the user needs, routes to appropriate skills, manages state across sessions, and handles context handoffs with Context Paradox awareness. Use when starting new projects, when user says 'help me with [X]' without specifics, when switching between tasks, or when determining which skill(s) to apply. Prevents context overload that degrades output quality. Includes 5 pre-built therapy workflows for common scenarios. Triggers on: help me with marketing, where do I start, what should I do first, I need to, complex multi-skill requests, ambiguous content requests."
---

# Therapy Orchestrator

The traffic controller for NextStep Therapy's 12 skills. Routes users to the right skill(s) in the right order, with the right context.

---

## The Core Job

**Diagnose** what the user actually needs, then **route** to appropriate skill(s) with proper context.

**Why this matters:**
- Wrong skill order = wasted effort
- Too much context = degraded output (Context Paradox)
- No state tracking = duplicate work
- Ambiguous routing = user confusion

---

## When to Use This Skill

**Use orchestrator when:**
- Starting any new content project
- User request is ambiguous ("help me with marketing")
- Multiple skills might apply
- Need to track state across session
- Switching between tasks mid-project

**Skip orchestrator when:**
- Request is specific and obvious
- Single skill clearly applies
- Continuing work from identified skill

---

## Diagnostic Intake Questions

### Quick Diagnosis (Ask These First)

```markdown
1. WHAT are you trying to create?
   [ ] New page (service, location, student, professional)
   [ ] Optimize existing page
   [ ] Email sequence / lead magnet
   [ ] Research / analysis only
   [ ] Something else: ________

2. WHAT do you have already?
   [ ] Keyword research / Ahrefs data
   [ ] Competitor analysis
   [ ] Existing content to improve
   [ ] Nothing yet

3. WHERE in the process are you?
   [ ] Just starting (need research first)
   [ ] Know what I want, need to execute
   [ ] Have draft, need to improve
   [ ] Have final, need to verify

4. WHAT'S the priority?
   [ ] Speed (good enough, fast)
   [ ] Quality (thorough, take time)
   [ ] Both (realistic timeline)
```

### Quick Routing Table (For Obvious Requests)

| User says... | Route to... | Notes |
|-------------|-------------|-------|
| "Optimize this meta title" | meta-title-optimizer | Direct route |
| "Create FAQ section" | faq-schema-generator | Direct route |
| "Write service page for [X]" | therapy-content-generator | May need keyword-research first |
| "Find positioning angle" | positioning-angles-therapy | Direct route |
| "Build email sequence" | email-welcome-sequence-therapy | May need lead-magnet first |
| "Research keywords for [X]" | keyword-research | Request Ahrefs/GSC data |
| "Why isn't this converting?" | conversion-optimizer | Direct route |
| "Analyze [competitor URL]" | seo-competitor-intelligence | Direct route |
| "Check this copy's voice" | brand-voice-therapy | Verify Mode |
| "This sounds like AI" | brand-voice-therapy | Then therapy-content-generator Humanize |
| "Where do I start?" | THIS SKILL | Full diagnosis needed |

---

## Complete Skill Registry (12 Skills)

### Skill Layers

```
FOUNDATION LAYER (Research & Voice)
├── keyword-research           → Validates keyword opportunity, finds quick wins
├── seo-competitor-intelligence → Analyzes competitors, finds content gaps
└── brand-voice-therapy         → Applies Jesse's Voice DNA to all content

STRATEGY LAYER (Positioning & Structure)
├── positioning-angles-therapy  → Finds CRPO-compliant positioning angles
├── therapy-content-generator   → Structures and writes page content (2000+ words)
└── faq-schema-generator        → Creates FAQ sections with JSON-LD schema

EXECUTION LAYER (Copy & Conversion)
├── direct-response-copy-therapy → Writes CRPO-compliant persuasive copy
├── conversion-optimizer         → Optimizes CTAs and hero sections
└── meta-title-optimizer         → Creates CTR-optimized title/meta tags

NURTURE LAYER (Email & Lead Gen)
├── lead-magnet-therapy          → Creates CRPO-safe lead magnets (no assessments)
└── email-welcome-sequence-therapy → Creates 5-7 email welcome sequences

COORDINATION LAYER
└── therapy-orchestrator (this skill) → Routes and coordinates all skills
```

### Skill Quick Reference

| Skill | Input Needed | Output | Time |
|-------|--------------|--------|------|
| keyword-research | Ahrefs/GSC data, topic | Priority keywords, opportunities | 30 min |
| seo-competitor-intelligence | Competitor URLs | Content gaps, E-E-A-T signals | 45 min |
| brand-voice-therapy | Draft content | Voice-matched content | 15-30 min |
| positioning-angles-therapy | Service, audience | 3-5 angle options | 20 min |
| therapy-content-generator | Keyword, angle, outline | 2000+ word page | 60 min |
| faq-schema-generator | Topic, existing FAQs | 10-12 FAQs + JSON-LD | 15 min |
| direct-response-copy-therapy | Angle, voice, page section | Hero, CTAs, copy | 20 min |
| conversion-optimizer | Current CTAs, page goal | Optimized CTAs, A/B options | 15 min |
| meta-title-optimizer | Keyword, differentiators | 5 title variations scored | 15 min |
| lead-magnet-therapy | Audience, pain points | Lead magnet concept | 30 min |
| email-welcome-sequence-therapy | Lead magnet, positioning | 5-7 email sequence | 45 min |

---

## Dependency Tree

### What Needs What

```
NEW SERVICE PAGE (Full Build)

keyword-research ─────────────────┐
                                  │
seo-competitor-intelligence ──────┼──→ positioning-angles-therapy
                                  │              │
brand-voice-therapy ──────────────┘              ↓
                                        therapy-content-generator
                                                 │
                              ┌──────────────────┼──────────────────┐
                              ↓                  ↓                  ↓
                    faq-schema-generator  direct-response-copy  meta-title-optimizer
                                                 │
                                                 ↓
                                        conversion-optimizer
                                                 │
                                                 ↓
                                        brand-voice-therapy (verify)
```

```
EMAIL LIST BUILDING

positioning-angles-therapy ──→ lead-magnet-therapy ──→ email-welcome-sequence-therapy
        ↓                              ↓
brand-voice-therapy            direct-response-copy-therapy
                                    (landing page)
```

```
EXISTING PAGE OPTIMIZATION

meta-title-optimizer (if CTR issue)
        ↓
conversion-optimizer (if conversion issue)
        ↓
brand-voice-therapy (if "sounds like AI")
        ↓
faq-schema-generator (if no FAQ section)
        ↓
therapy-content-generator Humanize (if AI detection)
```

---

## The Context Paradox (CRITICAL)

### Why More Context ≠ Better Output

**The problem:** Loading all previous research into every skill overwhelms the model and degrades output quality. Output becomes:
- Hedged and committee-sounding
- Overly comprehensive (loses punch)
- Trying to please all inputs (pleases none)

**The solution:** Selective context passing. Each skill gets only what it needs.

### Context Passing Rules

| To This Skill | Pass This | OMIT This |
|---------------|-----------|-----------|
| **positioning-angles-therapy** | Target audience (1 sentence), primary keyword, 3 differentiators | Full competitor analysis, all keyword variations |
| **direct-response-copy-therapy** | Selected angle (1-2 sentences), 5 voice markers max, page section to write | Full Voice DNA (545 lines), complete research |
| **therapy-content-generator** | Primary keyword + 2-3 secondaries, outline, angle summary | Competitor deep dive, full keyword spreadsheet |
| **conversion-optimizer** | Current CTA text, page goal, target audience (brief) | Content drafts, research data |
| **meta-title-optimizer** | Primary keyword, 3 differentiators, SERP competitors | Full page content, research |
| **brand-voice-therapy** (verify) | Draft content, 7-question checklist | Research data, previous drafts |
| **faq-schema-generator** | Topic, existing questions, audience | Full page content |
| **email-welcome-sequence-therapy** | Lead magnet concept (brief), positioning angle | Full lead magnet development docs |

### Context Compression Principle

| From Skill | Compress To |
|------------|-------------|
| keyword-research | Top 3 keywords + difficulty + volume (not full spreadsheet) |
| seo-competitor-intelligence | 3 content gaps in bullets (not full analysis) |
| positioning-angles-therapy | Winning angle in 1-2 sentences (not all 5 options) |
| therapy-content-generator | Key insights in 5 bullets (not full 2500-word draft) |
| brand-voice-therapy | 5 voice markers (not 545-line Voice DNA) |

### When to Run Fresh (No Context)

Run a skill with minimal context when:
- Previous skill output feels off
- You want a different angle than emerged
- Output is getting worse, not better through iterations
- You need bold, punchy copy (not hedged, comprehensive)
- Copy sounds like a committee wrote it

**Fresh start prompt pattern:**
> "Write [content type] for [topic]. Target: [1 sentence audience]. Angle: [1 sentence]. Be bold. Ignore everything else."

---

## Handoff Protocol Format

### Standard Handoff Block

When routing between skills, use this format:

```markdown
## HANDOFF: [From Skill] → [To Skill]

### Critical Context (ONLY what next skill needs):
- **Target keyword:** [X]
- **Selected angle:** [1-2 sentences]
- **Voice markers:** [5 items max from brand-voice-therapy]
- **CRPO constraints:** [Specific to this content]

### What NOT to pass:
- [List 2-3 things explicitly excluded]

### Explicit instructions:
[1-2 sentences telling receiving skill what to do]
```

### Example Handoff

```markdown
## HANDOFF: positioning-angles-therapy → direct-response-copy-therapy

### Critical Context:
- **Target keyword:** anxiety therapy Ontario
- **Selected angle:** "WITH you, not ahead of you - virtual therapy that meets you where you are"
- **Voice markers:**
  1. Start with disclaimer
  2. Use "right?" check-ins
  3. Process over outcome
  4. "Should vs. want" distinction
  5. Soft CTA ("no pressure")
- **CRPO constraints:** No outcome promises, no testimonials

### What NOT to pass:
- Other 4 angle options
- Full competitor analysis
- Complete Voice DNA document

### Explicit instructions:
Write hero section (3-4 sentences) and 2 CTA variations using the selected angle and voice markers. Focus on anxiety therapy service page.
```

---

## State Tracking Template

### Session State

Track progress across a session:

```markdown
## SESSION STATE

### Project: [Name]
**Started:** [Date]
**Goal:** [What we're trying to achieve]

### Completed Steps:
- [ ] Keyword research: [keyword] (KD: [X], Vol: [Y])
- [ ] Competitor analysis: [URLs analyzed]
- [ ] Positioning angle: [Selected angle]
- [ ] Content structure: [Section outline]
- [ ] Full content: [Draft complete]
- [ ] Voice check: [Pass/Fail]
- [ ] CTA optimization: [Completed]
- [ ] Meta title: [Final title]
- [ ] FAQ schema: [Added]

### Current Step:
**Skill:** [Active skill]
**Status:** [In progress / Blocked / Complete]

### Context for Next Skill:
[Relevant output from previous skill - COMPRESSED]

### Blockers:
- [ ] Need Ahrefs data
- [ ] Need GSC data
- [ ] Need competitor URLs
- [ ] Need user decision on angle
- [ ] Other: ________

### Next Steps:
1. [Action]
2. [Action]
```

---

## Pre-Built Therapy Workflows (5 Scenarios)

### Workflow 1: New Service Page (Full Build)

**When to use:** Creating a new page from scratch for a service/location/audience.

**Duration:** 2-4 hours

**Steps:**

```
1. keyword-research (30 min)
   Input: Topic, Ahrefs/GSC data if available
   Output: Primary keyword, KD, volume, secondaries
   Handoff: keyword + intent + competition level

2. seo-competitor-intelligence (45 min)
   Input: Top 5 competitor URLs
   Output: Content gaps, E-E-A-T signals needed, word count target
   Handoff: 3 key gaps + word count + schema requirements

3. positioning-angles-therapy (20 min)
   Input: Keyword, audience, gaps from step 2
   Output: 3-5 angles, recommended starter
   Handoff: Selected angle + headline direction

4. therapy-content-generator (60 min)
   Input: Keyword, angle, outline, word count target
   Output: 2000+ word content with structure
   Handoff: Full draft

5. faq-schema-generator (15 min)
   Input: Topic, draft content
   Output: 10-12 FAQs with JSON-LD schema
   Handoff: FAQs integrated

6. direct-response-copy-therapy (20 min)
   Input: Draft, angle, voice markers
   Output: Refined hero section, CTAs
   Handoff: Updated draft

7. conversion-optimizer (15 min)
   Input: Current CTAs, page goal
   Output: Optimized CTAs, friction points identified
   Handoff: Final CTA versions

8. meta-title-optimizer (15 min)
   Input: Primary keyword, differentiators
   Output: 5 title variations with scores
   Handoff: Best title selected

9. brand-voice-therapy (15 min)
   Input: Final draft
   Output: Voice verification (Pass/Fail)
   Handoff: COMPLETE (ready for publishing)
```

---

### Workflow 2: Optimize Existing Page

**When to use:** Page exists but isn't performing (low CTR, low conversions, sounds like AI).

**Duration:** 1-2 hours

**Steps:**

```
1. Diagnose the problem:
   - Low CTR? → meta-title-optimizer
   - Low conversions? → conversion-optimizer
   - Sounds like AI? → brand-voice-therapy + therapy-content-generator Humanize
   - No FAQ section? → faq-schema-generator
   - Thin content? → therapy-content-generator (expand)

2. Route based on diagnosis (may be 1-3 skills)

3. Always end with: brand-voice-therapy (verify)
```

---

### Workflow 3: Build Email List

**When to use:** Want to capture leads via lead magnet and nurture sequence.

**Duration:** 2-3 hours

**Steps:**

```
1. positioning-angles-therapy (20 min)
   Find angle for lead magnet
   Handoff: Angle + target audience pain points

2. lead-magnet-therapy (30 min)
   Create concept (NO diagnostic assessments)
   Handoff: Lead magnet concept + hook

3. direct-response-copy-therapy (30 min)
   Write landing page copy
   Handoff: Landing page draft

4. email-welcome-sequence-therapy (45 min)
   Create 5-7 email nurture sequence
   Handoff: Email sequence draft

5. brand-voice-therapy (30 min)
   Verify all copy matches Jesse's voice
   Handoff: COMPLETE
```

---

### Workflow 4: Competitive Research Sprint

**When to use:** Need to understand competitive landscape before creating content.

**Duration:** 1 hour

**Steps:**

```
1. keyword-research (20 min)
   Validate keyword opportunity
   Handoff: Keyword data + opportunity assessment

2. seo-competitor-intelligence (30 min)
   Deep analysis of top 5 competitors
   Handoff: Content gaps, differentiators, E-E-A-T signals

3. positioning-angles-therapy (15 min)
   Find differentiation angles
   Handoff: 3-5 angles for content creation

Output: Strategic brief ready for content creation
```

---

### Workflow 5: Quick Content Refresh

**When to use:** Existing content needs freshening (AI detection, outdated, voice drift).

**Duration:** 30-45 minutes

**Steps:**

```
1. therapy-content-generator Humanize section (20 min)
   Focus on AI phrase elimination
   Handoff: Humanized content

2. brand-voice-therapy Verify (10 min)
   Run 7-question test
   Handoff: Pass/Fail + fixes if needed

3. Update "Last Updated" date (2 min)

4. If meta title old: meta-title-optimizer (15 min)
```

---

## Quick Routing Reference

### By User Goal

| Goal | Primary Skill | Secondary Skills | Workflow |
|------|---------------|------------------|----------|
| Create new page | therapy-content-generator | keyword-research, positioning-angles-therapy, faq-schema-generator | Workflow 1 |
| Improve existing page | (varies by diagnosis) | brand-voice-therapy (verify) | Workflow 2 |
| Build email list | lead-magnet-therapy | email-welcome-sequence-therapy, direct-response-copy-therapy | Workflow 3 |
| Research competition | seo-competitor-intelligence | keyword-research | Workflow 4 |
| Fix AI-sounding content | brand-voice-therapy | therapy-content-generator Humanize | Workflow 5 |
| Improve CTR | meta-title-optimizer | - | Direct |
| Improve conversions | conversion-optimizer | direct-response-copy-therapy | Direct |
| Find positioning | positioning-angles-therapy | - | Direct |

### By What's Missing

| Missing | Run This First |
|---------|----------------|
| Don't know what keyword to target | keyword-research |
| Don't know what makes me different | positioning-angles-therapy |
| Don't have content | therapy-content-generator |
| Don't have FAQ section | faq-schema-generator |
| Don't have lead magnet | lead-magnet-therapy |
| Don't have email sequence | email-welcome-sequence-therapy |
| Copy doesn't sound like me | brand-voice-therapy |
| Page isn't converting | conversion-optimizer |
| Title isn't getting clicks | meta-title-optimizer |

---

## The Test

Before routing to any skill, verify:

1. **Did you ask diagnostic questions?** Or is the request obviously specific?
2. **Did you check what already exists?** Prevent duplicate work.
3. **Did you identify dependencies?** What needs to happen first?
4. **Did you prepare minimal context handoff?** Not everything, just essentials.
5. **Did you set expectations for next steps?** User knows what's coming.

---

## Anti-Patterns to Avoid

**DON'T:**
- Jump to execution without diagnosis
- Run execution skills without foundation (positioning, voice)
- Try to do everything at once
- Feed everything from every skill into the next (Context Paradox)
- Chain skills when output is getting worse
- Skip the "boring" strategy work

**DO:**
- Start with qualifying questions
- Build foundation before execution
- Sequence skills logically
- Compress context between skills
- Track what's been created
- Run fresh when output feels off

---

## Sources

- Skill inventory: `.claude/skills/README.md`
- CLAUDE.md workflows: `CLAUDE.md` (Skills section)
- Context Paradox: Adapted from Vibe Marketer orchestrator principles
- Workflow patterns: AAA Framework content system
