---
name: content
description: Generate authentic, compelling copy for portfolios. Covers tone calibration, taglines, bios, project descriptions, and avoiding assumptions.
---

# Skill: Content Writing

Generate authentic, compelling copy for portfolios.

---

## Tone Calibration

Based on `content.tone` in profile.yaml:

| Tone | Style | Example |
|------|-------|---------|
| professional | Formal, third-person | "Jacob Kieser is a software architect specializing in..." |
| conversational | Casual first-person | "I build tools that make developers' lives easier." |
| technical | Detailed, jargon-appropriate | "Implemented a distributed cache layer using Redis Cluster..." |
| creative | Storytelling, personality | "It started with a broken deploy script at 2am..." |

---

## Length Calibration

Based on `content.length`:

| Length | Approach |
|--------|----------|
| concise | Short sentences, bullet points, scannable |
| balanced | Mix of short and long, narrative + lists |
| detailed | Full paragraphs, comprehensive explanations |

---

## Focus Calibration

Based on `content.focus`:

| Focus | Emphasis |
|-------|----------|
| projects | What they've built, outcomes, tech choices |
| experience | Roles, companies, career progression |
| skills | Technical depth, certifications, expertise |
| personality | Who they are, how they think, what drives them |

---

## Writing the Tagline

### Don't Write
- "Passionate about [X]"
- "Building [vague thing] at scale"
- "Full-stack developer who loves clean code"
- "Turning coffee into code"

### Do Write
- Specific value: "Built developer tools used by 2M engineers"
- Unique angle: "Former chef who now designs food tech APIs"
- Clear outcome: "I make AI systems that don't hallucinate"
- Honest and specific: "Infrastructure engineer who deletes more code than I write"

---

## Writing the Bio

### Structure
1. **Hook** - Something specific and interesting
2. **Journey** - How they got here (briefly)
3. **Current** - What they're doing now
4. **Approach** - How they think about problems
5. **Human** - Something personal but professional

### Anti-Patterns
- "I've been passionate about technology since..."
- Lists of technologies
- "Clean code" and "best practices"
- Corporate jargon (synergize, leverage, thought leader)

### Good Examples
- "I spent five years making databases faster at Stripe. Now I help startups avoid the performance mistakes I used to fix."
- "Most of my career has been building tools that other engineers use. I'm good at finding the 80/20."

---

## Writing Project Descriptions

### Bad
"A web application built with React and Node.js that allows users to manage tasks."

### Good
"Built after realizing Asana was overkill for solo devs. 5K+ developers use it daily to track side projects without the enterprise bloat."

### Formula
1. Why it exists (the problem)
2. What it does (the solution)
3. Impact (usage, results, or what you learned)

---

## Critical: Don't Assume or Exaggerate

### Never Infer
- Scale from company name ("Engineer at Uber" ≠ "billions of rides")
- Impact without verification
- Metrics you can't confirm

### Always Ask
- User counts, revenue, scale
- Specific outcomes
- Role responsibilities
- Why they made certain choices

### What You CAN Use
- Technologies from GitHub/package.json
- Public commit history
- Documented project existence
- Dates from public sources

**If you're writing numbers without a source, STOP and ask.**

---

## Copy Creativity

Based on `ai.copy_creativity` in profile.yaml:

| Level | Approach |
|-------|----------|
| 1-3 | Safe, conventional, straightforward |
| 4-6 | Some personality, occasional metaphor |
| 7-8 | Distinctive voice, memorable phrasing |
| 9-10 | Bold, potentially polarizing, very unique |

---

## Section Headers

### Avoid Generic
- "About Me"
- "My Projects"
- "Experience"
- "Skills"

### Use Specific
- "What I Do"
- "Things I've Built"
- "Where I've Worked"
- "Background"
- Or archetype-specific: "~/about.txt", "PLAYER STATS", "Chapter One"
