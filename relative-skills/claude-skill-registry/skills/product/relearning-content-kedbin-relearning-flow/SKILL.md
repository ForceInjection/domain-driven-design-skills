---
name: relearning-content
description: Creates journal entries or project pages for a personal knowledge site. Use when the user wants to write, publish, or add content - journals, projects, or articles about cognitive engineering, productivity systems, or tool-driven growth.
license: Apache-2.0
compatibility: Requires access to your content repository. Uses create-script and voiceover skills for audio generation.
metadata:
  author: community
  version: "3.0"
---

# Relearning Content Creator

Creates structured journal entries or project pages following a cognitive engineering philosophy and Astro content schema.

## The Philosophy

**Core Mission:** Apply enterprise-grade engineering discipline to the messy reality of being human. Debug sleep, focus, and decision-making as if they were mission-critical infrastructure.

**The Lens:** Every human problem is reframed as a **systems engineering problem**. We don't moralize; we diagnose. We don't motivate; we architect.

**The Promise:** No hype. Just honest metrics. If something failed, log it. If a belief was wrong, document the update.

---

## When to use this skill

**USE THIS SKILL** when the user:
- Wants to create a new journal entry
- Wants to add a new project page
- Says "new journal", "new entry", "write about [topic]"
- Provides content/ideas and wants them formatted for the site
- Wants to document a project, tool, or system they've built

**IMPORTANT**: This skill creates content files. After content is finalized:
1. Use `create-script` skill to condense + add paralinguistic tags → saves `.txt`
2. Use `voiceover` skill on the `.txt` file → generates `.mp3` + deploys + pushes

---

## Workflow Architecture (CRITICAL)

**Your role as the main agent is REVIEWER, not drafter.**

The `google-search` subagent handles:
- Research (finding sources, opposing views)
- Drafting (writing the complete journal entry)
- Citation integration

You handle:
- Repository sync and file management
- Tone/consistency review against standards
- Iteration requests if draft doesn't match voice
- Final file creation and audio pipeline

```
User provides topic/content
        ↓
Step 0: Git pull + determine entry number
        ↓
Step 1: Spawn google-search subagent to DRAFT
        - Subagent researches topic
        - Subagent writes complete journal entry
        - Subagent returns full markdown
        ↓
Step 2: YOU review for tone/consistency
        - Does it match the voice?
        - Engineering metaphors present?
        - Fallacy → Model → Protocol structure?
        - Memorable one-liner ending?
        ↓
Step 3: If lacking, send back to subagent with feedback
        ↓
Step 4: Save final draft to entry-XXX.md
        ↓
Step 5: Present to user for approval
        ↓
Step 6: Audio pipeline (create-script → voiceover)
```

---

## How to Execute This Skill

### Step 0: Sync Repository (ALWAYS DO THIS FIRST)

```bash
cd ~/projects/your-site && git pull origin main
ls src/content/journal/
date +%Y-%m-%d  # Get today's date for the entry
```

Determine the next entry number (e.g., if entry-013.md exists, next is entry-014.md).

**CRITICAL: Use TODAY'S DATE as the publish date.** Run `date +%Y-%m-%d` to get the current date. Do NOT use the date from the user's notes - that is their draft date, not the publish date.

### Step 1: Delegate Drafting to google-search Subagent

Spawn the subagent with the user's content and request a complete draft:

```
Task(subagent_type="google-search", prompt="Draft a journal entry on the following topic:

[USER'S CONTENT/IDEAS HERE]

Requirements:
1. Research the topic thoroughly - find relevant studies, frameworks, and opposing viewpoints
2. Write a complete journal entry following the style guide (see your instructions)
3. Use the Fallacy → Model → Protocol structure
4. Include at least 3 citations with proper references
5. End with a memorable one-liner
6. Return the complete markdown file ready for publication

Entry number: entry-XXX
Date: YYYY-MM-DD")
```

### Step 2: Review the Draft for Tone/Consistency

When the subagent returns, check:

**Voice Checklist:**
- [ ] Title follows "The [Technical Noun]: [Subtitle]" pattern
- [ ] Engineering metaphors used throughout (not generic self-help language)
- [ ] Problems framed as bugs/inefficiencies, solutions as protocols/patches
- [ ] Academic rigor - citations present with author, year
- [ ] Summary is systems-framed, 1-2 sentences
- [ ] At least 3 highlights with metrics/sources
- [ ] Opening hook is personal/specific, not generic
- [ ] Fallacy section identifies legacy thinking
- [ ] Model section cites named frameworks with authors
- [ ] Protocol section has numbered phases
- [ ] Ends with memorable, quotable one-liner
- [ ] References section complete

**Red Flags (send back for revision):**
- Generic motivational language ("unlock your potential", "achieve your dreams")
- Missing citations or vague claims
- No engineering/technical metaphors
- Protocol section too abstract (needs concrete actions)
- Weak or missing one-liner ending

### Step 3: Iterate if Needed

If the draft doesn't match the voice, spawn the subagent again with specific feedback:

```
Task(subagent_type="google-search", prompt="Revise this draft:

[PASTE DRAFT HERE]

Issues to fix:
1. [Specific issue - e.g., 'Opening hook is too generic, needs a specific incident']
2. [Specific issue - e.g., 'Missing engineering metaphor for willpower concept']
3. [Specific issue - e.g., 'Protocol section needs concrete metrics']

Return the revised complete markdown.")
```

### Step 4: Save the Final Draft

Once the draft passes review, save it:

```bash
# Write to entry file
~/projects/your-site/src/content/journal/entry-XXX.md
```

### Step 5: Present to User

Show the user:
- The filename created
- A summary of the content
- The highlights/key takeaways
- Ask for any revisions

### Step 6: Audio Pipeline (After User Confirms)

Once user approves, execute the two-step audio pipeline:

#### Step 6a: Create Voiceover Script

Use the `create-script` skill to condense and add paralinguistic tags.

#### Step 6b: Generate Audio

Run the voiceover command and **only verify it started** (do not poll for progress):

```bash
cd ~/projects/chatterbox && nohup uv run python archive/voiceover_script.py \
  -i archive/entry-XXX.txt \
  -o archive/entry-XXX.mp3 \
  --entry entry-XXX \
  --push > voiceover.log 2>&1 &
```

Then verify it started:

```bash
sleep 5 && head -10 ~/projects/chatterbox/voiceover.log
```

**DO NOT poll for progress repeatedly.** Trust that the script will complete and push. The user will receive a desktop notification when done.

Tell the user:
- Voiceover generation launched in background
- They will receive a desktop notification when complete
- Can monitor with: `tail -f ~/projects/chatterbox/voiceover.log`

---

## Project Location

**Repository Path:** `~/projects/your-site` (configure to your setup)

- **Journal entries:** `src/content/journal/entry-XXX.md`
- **Project pages:** `src/content/projects/[slug].md`

---

## Content Schemas

### Journal Entry Schema

```yaml
---
title: "The [Metaphor]: [Subtitle with Engineering Framing]"
date: "YYYY-MM-DD"
summary: "[1-2 sentence hook with systems/engineering lens]"
status: "Published"
category: "Relearn [Life|Engineering|Work] / [Subcategory]"
highlights:
  - "Key Takeaway 1: [Actionable insight]"
  - "Key Takeaway 2: [Framework or model]"
  - "Key Takeaway 3: [Protocol or implementation]"
audioUrl: "/audio/entry-XXX.mp3"
---
```

### Project Page Schema

```yaml
---
title: "[Project Name]: [Subtitle]"
date: "YYYY-MM-DD"
description: "[1-2 sentence description]"
repoUrl: "https://github.com/yourusername/[repo]"
demoUrl: "[URL]"
techStack: ["Tech1", "Tech2", "Tech3"]
audioUrl: "/audio/[slug].mp3"
---
```

---

## Voice Reference (For Your Review)

### Good Examples (Match This Tone)

**Titles:**
- "The Physics of Productivity: Mastering the Input/Output Ratio"
- "The Asymptote of Effort: Overcoming the Iron Law of Diminishing Returns"
- "Memoization: The Architecture of Cognitive Caching"

**Summaries:**
- "A system running at 100% utilization with 0% throughput is not 'dedicated'—it is broken."
- "Most human exhaustion comes from re-computing solved problems."

**One-Liners:**
- "Stop watching reality. Start predicting it."
- "Stop calculating. Start retrieving."
- "Stop acquiring tools. Start becoming them."

### Bad Examples (Reject This Tone)

- "Unlock your full potential with these 5 simple steps"
- "The secret to success is believing in yourself"
- "Transform your life with the power of positive thinking"

---

## Quick Reference: Technical Metaphors

| Human Concept | Engineering Metaphor |
|---------------|---------------------|
| Decision fatigue | Memory leak, garbage collection failure |
| Willpower | Battery charge, finite resource pool |
| Habits | Compiled routines, cached functions |
| Procrastination | System deadlock, CPU thrashing |
| Attention | Single-core processor, context switching |
| Goals | Function signatures, API contracts |
| Feedback | Control loops, negative feedback systems |
| Learning | Compiling, updating dependencies |
| Forgetting | Cache invalidation, memory volatility |
| Burnout | Thermal throttling, system overload |

---

## Astro Markdown Rules

- **NO markdown tables** (use bullet lists)
- **NO code blocks with language hints**
- **ASCII-safe frontmatter** (spell out special characters)
- **NO raw HTML**
- **NO footnotes** (use [1] citation style with References section)

---

## Important Reminders

- **Delegate drafting** to google-search subagent
- **Your job is review** for tone/consistency
- **Iterate if needed** - send back with specific feedback
- **Only verify voiceover started** - don't poll for progress
- **Trust the pipeline** - script handles deploy + push + notification

**The Workflow:**

```
Git Pull → Subagent Drafts → You Review → Iterate if Needed → Save → User Confirms → create-script → voiceover (fire and forget) → Done!
```
