---
name: new-youtube-video-skill
description: Creates a new YouTube video project with comprehensive research, competitor analysis, folder structure, and todo.md for progress tracking. Uses Playwright MCP to fetch vidIQ stats, analyze competitors, and gather research automatically. Use when starting a new YouTube video, saying "new video", "start a video project", or "I want to create a YouTube video".
---

# New YouTube Video Production Skill (Enhanced)

## Overview

This skill guides you through creating a new YouTube video from ideation to publish. It:
1. Asks comprehensive questions with options to choose from
2. Creates the project folder structure in `~/YT/Ideas/`
3. Uses Playwright MCP to fetch vidIQ keyword data and competitor analysis
4. Grabs competitor CTAs, thumbnail screenshots, and content patterns
5. Generates research artifacts (title ideas, CTA options, outlines, notes)
6. Initializes todo.md for progress tracking

---

## Step 1: Initial Questions (ALWAYS ASK FIRST)

When invoked, use AskUserQuestion to gather information through multiple choice questions:

### Question Set 1: Basic Info

```
Question 1: "What content category is this video?"
Header: "Category"
Options:
- Tech Tutorial / How-to
- AI Tools & Productivity
- Coding / Development
- Finance / Investing
- News / Reaction (Recommended for timely topics)
```

```
Question 2: "What's your video length goal?"
Header: "Length"
Options:
- Short (5-8 minutes) - Quick explainer
- Medium (10-15 minutes) - Standard tutorial (Recommended)
- Long (15-25 minutes) - Deep dive
- Very Long (25+ minutes) - Comprehensive guide
```

```
Question 3: "What's the primary format?"
Header: "Format"
Options:
- Screen recording + face cam (Recommended for tutorials)
- Mostly face cam with B-roll
- Pure screen recording
- Talking head with graphics
```

```
Question 4: "How much research help do you need?"
Header: "Research"
Options:
- Full research (fetch competitors, keywords, CTAs) (Recommended)
- Light research (just keyword validation)
- No research (I have my own data)
- I'll provide competitor URLs to analyze
```

### Question Set 2: Topic Details

After initial questions, ask:

```
Question 1: "What's the core topic?"
(Free text - user types their topic)

Question 2: "What's your unique angle or hook?"
Header: "Hook Type"
Options:
- Surprising statistic / Little-known fact
- Myth-busting / Contrarian take
- Tutorial / How-to guide
- Comparison / Showdown
- Personal experience / Case study
```

```
Question 3: "Who is the target audience?"
Header: "Audience"
Options:
- Beginners (explaining basics)
- Intermediate (practical application)
- Advanced (deep techniques)
- Mixed (layered content)
```

```
Question 4: "Do you have any competitor videos to analyze?"
Header: "Competitors"
Options:
- Yes, I'll paste URLs
- No, find top competitors for me (Recommended)
- Skip competitor research
```

---

## Step 2: Folder Creation

Create the project in `~/YT/Ideas/` (NOT root ~/YT/):

```bash
# Replace [VIDEO_TITLE] with sanitized video title (spaces to hyphens, no special chars)
mkdir -p ~/YT/Ideas/[VIDEO_TITLE]/{01_Script,02_Raw_Footage/{Screen_Recordings,Face_Cam},03_Audio/{Original,Processed},04_Assets/{B-Roll,Graphics,Music_SFX,Competitor_Thumbnails},05_Project_Files,06_Exports/{Long_Form,Shorts},07_Thumbnails}
```

Enhanced folder structure:
```
~/YT/Ideas/[Video Title]/
├── 01_Script/
│   ├── script.md              # Final script (generated later)
│   ├── outline.md             # Generated outline with structure
│   ├── research.md            # Keyword data, competitor analysis
│   ├── title-ideas.md         # 10+ title options with vidIQ scores
│   ├── cta-ideas.md           # CTA options from competitors + custom
│   └── notes.md               # Freeform notes, ideas, snippets
├── 02_Raw_Footage/
│   ├── Screen_Recordings/
│   └── Face_Cam/
├── 03_Audio/
│   ├── Original/
│   └── Processed/
├── 04_Assets/
│   ├── B-Roll/
│   ├── Graphics/
│   │   └── presentation.html  # If presentation skill is used
│   ├── Music_SFX/
│   └── Competitor_Thumbnails/ # Screenshots of competitor thumbnails
├── 05_Project_Files/
├── 06_Exports/
│   ├── Long_Form/
│   └── Shorts/
├── 07_Thumbnails/
└── todo.md                    # Progress tracker
```

---

## Step 3: Competitor Research via Playwright MCP

If user selected "Full research" or "Find top competitors", use Playwright MCP:

### 3a. Search YouTube for Competitors

```
1. Navigate to YouTube
2. Search for: [topic] + relevant keywords
3. Filter by: View count (high), Upload date (recent - last 6 months)
4. Extract top 5-10 videos with:
   - Title
   - View count
   - Channel name
   - Subscriber count
   - Upload date
   - Thumbnail (screenshot)
   - Video URL
```

### 3b. Fetch Competitor Details

For each top competitor video:

```
1. Navigate to video page
2. Click "Show transcript" button
3. Extract:
   - Full transcript (for CTA extraction)
   - First 60 seconds (hook analysis)
   - Last 60 seconds (outro/CTA analysis)
   - Description (for keywords, links)
4. Take thumbnail screenshot → save to Competitor_Thumbnails/
```

### 3c. Extract CTAs from Transcripts

Parse transcripts to find CTA patterns:
- Subscribe mentions ("subscribe", "hit subscribe", "join the channel")
- Like mentions ("like this video", "thumbs up", "smash that like")
- Comment prompts ("let me know in the comments", "tell me below")
- Link mentions ("link in description", "check out", "use code")
- End screen mentions ("watch this next", "check out this video")

Save examples to `cta-ideas.md`:
```markdown
# CTA Ideas for [Video Title]

## Extracted from Competitor Videos

### Subscribe CTAs
- "If you're into [topic], subscribe - I post every [frequency]" - [Channel Name] (1.2M views)
- [More examples...]

### Mid-Video CTAs
- "If this is helping you out, hit that like button" - [Channel Name]
- [More examples...]

### Outro CTAs
- "Watch this video next to learn [topic]" - [Channel Name]
- [More examples...]

## Custom CTAs for This Video
(Claude generates 3-5 custom options based on video topic)

1. Subscribe: "..."
2. Mid-video like: "..."
3. Comment prompt: "..."
4. End screen: "..."
```

### 3d. Analyze Competitor Thumbnails

Take screenshots of top performing thumbnails and note patterns:
- Face or no face
- Text overlay (how much, what style)
- Color scheme
- Emotion/expression
- Background type

Save analysis to `research.md`.

---

## Step 4: vidIQ Keyword Research via Playwright MCP

Use Playwright MCP to fetch keyword data from vidIQ:

```
1. Navigate to https://vidiq.com
2. Go to Keywords Tool (or Keyword Inspector)
3. Search for: [primary topic keyword]
4. Extract:
   - Search volume
   - Competition score
   - Overall score
   - Related keywords (top 10)
   - Trend data
5. Search 2-3 alternative keywords
6. Compare scores
```

Save to `research.md`:
```markdown
# Keyword Research for [Video Title]

## Primary Keywords

| Keyword | Volume | Competition | Score | Trend |
|---------|--------|-------------|-------|-------|
| [keyword 1] | 12K | Medium | 67 | ↑ |
| [keyword 2] | 8K | Low | 72 | → |
| [keyword 3] | 5K | High | 45 | ↓ |

## Recommended Primary Keyword
**[Best keyword]** - Score: [X], Volume: [Y]

## Related Keywords to Include
1. [related 1]
2. [related 2]
3. [related 3]
...

## SEO Recommendations
- Use "[primary keyword]" in first 60 characters of title
- Include in first sentence of description
- Add to first 3 tags
```

---

## Step 5: Generate Title Ideas

Based on keyword research and competitor analysis, generate 10+ title options:

Save to `title-ideas.md`:
```markdown
# Title Ideas for [Video Topic]

**Primary Keyword:** [keyword] (Score: X, Volume: Y)

## Curiosity Gap Titles
1. "I [Did Thing] and [Surprising Result]"
2. "Why [Experts] Do [Thing] (And You Should Too)"
3. "The [Adjective] Way to [Achieve Goal] That Nobody Talks About"

## How-To Titles
4. "How to [Achieve Goal] in [Timeframe] (Step-by-Step)"
5. "[Number] Ways to [Solve Problem] Using [Tool]"
6. "The Complete Guide to [Topic] for [Audience]"

## List/Number Titles
7. "[Number] [Topic] Mistakes That Are Costing You [Thing]"
8. "[Number] [Topic] Tips I Wish I Knew Earlier"

## Comparison Titles
9. "[Option A] vs [Option B]: Which is Better for [Use Case]?"
10. "I Tried [Thing] for [Time] - Here's What Happened"

## Contrarian Titles
11. "Stop [Common Practice] - Do This Instead"
12. "[Popular Advice] is WRONG (Here's the Truth)"

---

## Top 3 Recommended

### #1: "[Best Title]"
- Uses primary keyword: ✓
- Character count: XX/100
- Curiosity level: High
- CTR prediction: Strong

### #2: "[Second Best]"
...

### #3: "[Third Best]"
...
```

---

## Step 6: Generate Outline

Based on research, create a video outline:

Save to `outline.md`:
```markdown
# Video Outline: [Title]

**Target Length:** [X] minutes
**Format:** [Format from questions]
**Primary Keyword:** [keyword]

---

## HOOK (0:00-0:30) [FACE CAM]
**Goal:** Pattern interrupt, stop the scroll, works as standalone short

**Hook options:**
1. [Surprising stat hook]
2. [Question hook]
3. [Contrarian hook]

**Opening line:** "[Draft opening line]"

---

## INTRO (0:30-1:30) [FACE CAM]
**Goal:** Establish credibility, set expectations, first CTA

- What you'll learn
- Why it matters
- Quick roadmap
- Subscribe CTA: "[CTA from cta-ideas.md]"

---

## MAIN CONTENT

### Point 1: [Topic] (1:30-4:00) [SCREEN RECORDING]
**Short-worthy moment:** [Identify clip-worthy statement]
- Key insight
- Example/demo
- Transition to next point

### Point 2: [Topic] (4:00-7:00) [SCREEN RECORDING]
**Short-worthy moment:** [Identify clip-worthy statement]
- Key insight
- Example/demo
- Transition

### Point 3: [Topic] (7:00-10:00) [SCREEN RECORDING]
**Short-worthy moment:** [Identify clip-worthy statement]
- Key insight
- Example/demo

---

## DEMO/PRACTICAL (10:00-14:00) [SCREEN RECORDING]
- Full walkthrough
- Real-world application
- Pro tips

**Short-worthy moment:** [The reveal / result moment]

---

## CONCLUSION (14:00-15:00) [FACE CAM]
**Goal:** Summarize + provide key takeaway (short-worthy)

- Quick recap (3 bullets)
- Main insight
- Like CTA: "[CTA from cta-ideas.md]"

---

## OUTRO (15:00-15:30) [FACE CAM]
- Comment prompt: "[CTA from cta-ideas.md]"
- Next video suggestion
- End screen setup: "[CTA from cta-ideas.md]"

---

## PRODUCTION NOTES

### B-Roll Needed
- [ ] [B-roll idea 1]
- [ ] [B-roll idea 2]

### Graphics Needed
- [ ] Lower third for intro
- [ ] Stats overlay at [timestamp]
- [ ] Comparison graphic at [timestamp]

### Music/SFX
- [ ] Upbeat intro music
- [ ] Transition sounds
- [ ] Success sound for demo completion

### Presentation Slides (if applicable)
Consider using `/video-presentation` to create slides for:
- [ ] Stats reveal at [timestamp]
- [ ] Comparison at [timestamp]
- [ ] Step-by-step walkthrough
```

---

## Step 7: Create Enhanced todo.md

Create comprehensive todo.md with all research items:

```markdown
# [Video Title] - Production Progress

**Created:** [Current Date]
**Location:** ~/YT/Ideas/[Video Title]/
**Current Phase:** Pre-Production
**Last Updated:** [Current Date/Time]

---

## Research Phase
- [x] Video folder created
- [x] Competitor analysis complete ([X] videos analyzed)
- [x] Keyword research complete (Primary: "[keyword]" - Score: [X])
- [x] Title ideas generated ([X] options in title-ideas.md)
- [x] CTA options compiled (cta-ideas.md)
- [x] Outline drafted (outline.md)
- [ ] Final title selected: _______________
- [ ] vidIQ AI review requested

## Script Phase
- [ ] Script draft written (script.md)
- [ ] Hook finalized (test 3 alternatives)
- [ ] Main points complete with transitions
- [ ] CTAs placed naturally (from cta-ideas.md)
- [ ] Short-worthy moments marked (aim for 5+)
- [ ] Recording cues added ([FACE CAM], [SCREEN], [CLICK NEXT])
- [ ] vidIQ AI feedback incorporated
- [ ] Script optimized for reading aloud

## Recording Phase
- [ ] Pre-recording checklist complete
- [ ] Equipment ready (DJI Mic, iPhone, OBS)
- [ ] Screen recording complete
- [ ] Face cam recording complete
- [ ] Footage transferred to 02_Raw_Footage/

## Post-Production Phase

### Stage A: Rough Cut (Descript)
- [ ] Footage imported to Descript
- [ ] Multi-track synced (face cam + screen + audio)
- [ ] Transcript edit complete (ums, tangents removed)
- [ ] Silences shortened (0.3s max)
- [ ] Audio exported for enhancement

### Stage B: Audio Enhancement (Adobe Podcast)
- [ ] Audio uploaded to Adobe Podcast
- [ ] Enhanced audio downloaded
- [ ] Re-imported to Descript

### Stage C: Finishing (DaVinci Resolve)
- [ ] FCPXML exported from Descript
- [ ] Imported to DaVinci Resolve
- [ ] Intro/outro added
- [ ] B-roll added
- [ ] Graphics/lower thirds added
- [ ] Presentation slides integrated (if used)
- [ ] Music & SFX added
- [ ] Color graded
- [ ] Final audio mixed
- [ ] Final review done

## Export & Publish Phase
- [ ] Long-form exported to 06_Exports/Long_Form/
- [ ] Thumbnail created (reference Competitor_Thumbnails/ for inspo)
- [ ] Metadata finalized (title, description, tags)
- [ ] Uploaded to YouTube
- [ ] End screen and cards added
- [ ] Move folder from Ideas/ to In Progress/ → Uploaded/

## Shorts Phase
- [ ] Opus Clip processing complete
- [ ] 3-5 best shorts selected
- [ ] Shorts autoposted (YouTube, LinkedIn, Instagram, Facebook, TikTok, X)
- [ ] Remaining shorts scheduled

## Post-Publish (First 48 Hours)
- [ ] Respond to comments (first hour critical!)
- [ ] Pin engaging comment
- [ ] Monitor analytics at 24h
- [ ] Publish remaining shorts (space out)

## Reflection (After 1 Week)
- [ ] Analytics reviewed
- [ ] Reflection completed (see below)

---

## Quick Links

| Resource | Location |
|----------|----------|
| Outline | 01_Script/outline.md |
| Title Ideas | 01_Script/title-ideas.md |
| CTA Ideas | 01_Script/cta-ideas.md |
| Research | 01_Script/research.md |
| Competitor Thumbnails | 04_Assets/Competitor_Thumbnails/ |

---

## Analytics Snapshot (Fill after 1 week)

| Metric | Result | Target | Notes |
|--------|--------|--------|-------|
| Views (48h) | | | |
| CTR | | 4%+ | |
| Avg View Duration | | | |
| Retention | | 50%+ | |
| First 30s Retention | | 70%+ | |
| Best Short | | | |

### What Went Well
-

### What Could Improve
-

### Key Learnings
-

---

## Notes

**Topic:** [Topic from questions]
**Hook:** [Hook type selected]
**Primary Keyword:** [Keyword] (Score: [X])
**Target Length:** [Length from questions]
**Competitor Videos Analyzed:** [Count]
**Shorts Potential:** [Count of clip-worthy moments identified]
```

---

## Step 8: Summary & Next Steps

After creating everything, provide a summary:

```
Your video project is set up at: ~/YT/Ideas/[Video Title]/

**Research Complete:**
- Analyzed [X] competitor videos
- Primary keyword: "[keyword]" (vidIQ Score: [X])
- Generated [X] title options
- Compiled CTA examples from top performers
- Created detailed outline

**Files Created:**
- todo.md - Progress tracker
- 01_Script/outline.md - Video structure
- 01_Script/title-ideas.md - [X] title options
- 01_Script/cta-ideas.md - CTA collection
- 01_Script/research.md - Keyword data
- 04_Assets/Competitor_Thumbnails/ - [X] thumbnail screenshots

**Next Steps:**
1. Review title-ideas.md and pick your favorite
2. Review cta-ideas.md and select CTAs for each placement
3. Review outline.md and adjust structure if needed
4. When ready, say "help me write the script" and I'll create script.md

**Quick vidIQ AI Review:**
Before writing the full script, consider pasting your outline + chosen title to vidIQ AI for feedback.

Would you like me to:
1. Start writing the full script based on the outline?
2. Adjust the outline first?
3. Show you the competitor analysis details?
4. Create a presentation using /video-presentation?
```

---

## Moving Between Stages

When project progresses:

| User Says | Action |
|-----------|--------|
| "Move to In Progress" | `mv ~/YT/Ideas/[name] ~/YT/In\ Progress/[name]` + update todo.md |
| "I'm recording" | Update todo.md, show recording checklist |
| "I finished [task]" | Update todo.md, show next steps |
| "Video is published" | `mv ~/YT/In\ Progress/[name] ~/YT/Uploaded/[name]` + update todo.md |

---

## Integration with Other Skills

### After Script is Written
Suggest: "Would you like me to create a presentation using `/video-presentation`?"

### For Finance Content
If category is Finance/Investing, suggest: "For finance topics, consider using `/finance-commentary` for fact-checking against official sources."

### For Quick Shorts
Suggest: "Want to create a quick Shorts presentation on this topic? Use `/shorts-presentation`."

---

## Error Handling

### If Playwright MCP Fails
Fallback to manual workflow:
"I couldn't automatically fetch the data. Here's what to do manually:

1. Go to https://vidiq.com → Keywords Tool
2. Search for: [keywords]
3. Paste back the scores

For competitor research:
1. Search YouTube for: [topic]
2. Note the top 5 videos with high views
3. Share the URLs and I'll help analyze"

### If vidIQ Requires Login
"vidIQ requires login. Please:
1. Log in to vidIQ in your browser
2. Tell me when ready
3. I'll retry fetching the data"

---

## Example Complete Interaction

**User:** "/new-youtube-video"

**Claude:** [Uses AskUserQuestion with first question set]
"Let's create your new video project! First, a few questions..."

**User:** [Selects options through multi-choice]
- Category: Tech Tutorial
- Length: Medium (10-15 min)
- Format: Screen recording + face cam
- Research: Full research

**Claude:** [Asks for topic]
"What's the core topic for this video?"

**User:** "How to use Claude Code for automation"

**Claude:** [Uses Playwright MCP to:
1. Search YouTube for competitors
2. Fetch vidIQ keyword data
3. Take thumbnail screenshots
4. Extract CTAs from transcripts]

"I've completed the research and set up your project!

**Project:** ~/YT/Ideas/Claude-Code-Automation/

**Research Highlights:**
- Primary keyword: "Claude Code tutorial" (Score: 67, Volume: 12K)
- Analyzed 5 competitor videos (total 2.1M views)
- Best performing competitor: [Title] by [Channel] (450K views)
- Extracted 12 CTA examples from top performers

**Files Created:**
[Lists all files]

**Top 3 Recommended Titles:**
1. "Claude Code Changed How I Code - Here's Why" (curiosity)
2. "Automate ANYTHING with Claude Code (Full Tutorial)" (how-to)
3. "I Tried Claude Code for 30 Days - Honest Review" (personal)

Ready to write the script, or want to review the research first?"
