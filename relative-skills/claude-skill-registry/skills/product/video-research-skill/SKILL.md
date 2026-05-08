---
name: video-research-skill
description: Analyze YouTube videos to generate viral video ideas and scripts. Use when given YouTube URLs to research, when asked to analyze competitors, generate video ideas from existing videos, or create a script based on what works. Accepts 1-10 YouTube video links.
---

# Video Research & Script Generator

## Overview

This skill analyzes YouTube videos, identifies what makes them successful, and generates video ideas and scripts tailored to your channel. Scripts adapt to each topic's natural structure rather than following a rigid template.

---

## FACT INTEGRITY RULES (CRITICAL)

**These rules are NON-NEGOTIABLE. Never compromise on fact integrity.**

### Never Infer - Only Extract

1. **Transcript claims:** Only quote what was EXPLICITLY said in the video. Never paraphrase into stronger claims than what was stated.
2. **Statistics:** Must have exact source + date. Never round, estimate, or "update" numbers.
3. **Quotes:** Must be verbatim from transcript. Never reconstruct from memory or paraphrase as direct quotes.
4. **Comparisons:** Only compare what was explicitly measured. Don't extrapolate.

### Source Attribution Required

Every factual claim in research output or scripts must have ONE of:
- `[TRANSCRIPT: VIDEO_TITLE, timestamp]` - Directly from video transcript
- `[USER PROVIDED]` - User stated this information
- `[OPINION]` - Clearly marked as opinion or interpretation, not fact

### Red Flags - STOP and Verify

If you find yourself writing any of these, STOP:
- "Studies show..." → Which study? From which video at what timestamp?
- "Experts say..." → Which expert? Quote from transcript required.
- "It's known that..." → Source required.
- "Approximately..." → Get exact number from transcript or mark as estimate.
- Numbers without attribution → Where did this come from?

### When Information is Unclear

- Say "The video claims [X] but does not cite a source"
- Do NOT fill gaps with plausible-sounding information
- Flag for user: "I could not verify this claim from the transcript"
- Ask user to provide source if critical to the script

### What You CAN Do

- Accurately quote and summarize what videos actually say
- Note when claims in videos lack citations
- Identify patterns across multiple videos
- Generate original opinions clearly marked as `[OPINION]`
- Suggest angles and hooks based on the content

---

## Workflow

### Step 1: Collect YouTube URLs

Extract video IDs from URLs like:
- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://youtube.com/watch?v=VIDEO_ID&...`

### Step 2: Fetch Transcripts Using Playwright MCP

For each video URL, use the Playwright MCP browser tools to extract the transcript:

#### 2a. Navigate to the video
```
mcp__plugin_playwright_playwright__browser_navigate to https://www.youtube.com/watch?v=VIDEO_ID
```

#### 2b. Take a snapshot to see the page state
```
mcp__plugin_playwright_playwright__browser_snapshot
```

#### 2c. Click "...more" to expand the description (if needed)
Look for the expand button in the description area and click it.

#### 2d. Click "Show transcript" button
Look for the transcript button (usually says "Show transcript" or has a transcript icon) and click it.

#### 2e. Wait for transcript panel to load
```
mcp__plugin_playwright_playwright__browser_wait_for with text "Transcript"
```

#### 2f. Take another snapshot to capture the transcript
The transcript panel will show timestamped text. Extract all the text content.

#### 2g. Alternative: Use browser_evaluate to extract transcript text
If the transcript is in a panel, use JavaScript to extract all text:
```javascript
() => {
  const segments = document.querySelectorAll('ytd-transcript-segment-renderer');
  return Array.from(segments).map(seg => {
    const time = seg.querySelector('.segment-timestamp')?.textContent?.trim() || '';
    const text = seg.querySelector('.segment-text')?.textContent?.trim() || '';
    return `[${time}] ${text}`;
  }).join('\n');
}
```

#### 2h. Close the browser when done with all videos
```
mcp__plugin_playwright_playwright__browser_close
```

### Step 3: Analyze Each Video

For each transcript, extract:

- **Hook Analysis:** What grabs attention in the first 30 seconds?
- **Structure:** How is the content organized? How many points? What pacing?
- **Quotable Moments:** What statements stand alone as clips?
- **Engagement Patterns:** Where do they create curiosity? How do they maintain energy?
- **Gaps:** What's missing? What questions remain unanswered?

### Step 4: Ask Clarifying Questions

Before generating ideas, understand:

1. **Target Outcome:** Similar video with unique angle? Response video? Deep dive on subtopic? Something entirely different?
2. **Unique Perspective:** What can you add that these videos don't have?
3. **Scope:** Ideas only, full script, or both?
4. **Keywords:** Any vidIQ validation done?

### Step 5: Generate Video Ideas

Create 3-5 ideas with:

- Multiple title options (keyword-optimized, curiosity-driven, contrarian)
- Why it will perform (search demand, differentiation, shorts potential)
- Hook concept
- Virality score (1-10) based on curiosity gap, shareability, clip potential
- Main points to cover
- Unique angle

---

## Batch Analysis Mode (10+ Videos)

When user provides 10+ URLs, offer batch mode:

```
"You've provided [X] videos. Would you like:

1. **Standard mode** - Analyze each and generate 3-5 video ideas
2. **Batch mode** - Create a landscape analysis with comparison matrix

Batch mode is great for understanding your competition comprehensively."
```

### Batch Mode Workflow

#### B1. Fetch All Transcripts
Process all videos, extracting:
- Title, channel, views, publish date, length
- Hook (first 30 seconds)
- Key claims/statistics

#### B2. Generate Comparison Matrix

```markdown
# Competitor Landscape Analysis

**Date:** [Date]
**Videos Analyzed:** [Count]

## Quick Comparison

| Video | Channel | Views | Length | Hook Style | Structure |
|-------|---------|-------|--------|------------|-----------|
| [Title] | [Channel] | [X] | [MM:SS] | [Pattern] | [Type] |
| ... | | | | | |

## Hook Patterns

| Pattern | Count | Example Video | Example Hook |
|---------|-------|---------------|--------------|
| Surprising stat | X | [Title] | "[Quote]" |
| Contrarian take | X | [Title] | "[Quote]" |
| Question | X | [Title] | "[Quote]" |
| Story | X | [Title] | "[Quote]" |

## Content Structures

| Structure | Count | Videos Using It |
|-----------|-------|-----------------|
| Problem → Solution | X | [List] |
| List/Tips | X | [List] |
| Comparison | X | [List] |
| Tutorial | X | [List] |

## Underserved Angles

Based on analysis, these angles are NOT covered:
1. [Gap 1] - Opportunity because [reason]
2. [Gap 2] - Opportunity because [reason]
3. [Gap 3] - Opportunity because [reason]

## Common Claims

| Claim | Videos Mentioning | Verified? |
|-------|-------------------|-----------|
| [Claim] | [Count] | Yes/No |

## Recommendations

### High-Priority Video Ideas
1. **[Idea]** - Fills gap in [topic], high search demand
2. **[Idea]** - Contrarian angle nobody's taking
3. **[Idea]** - Combines best hooks with underserved angle

### Content Strategy Notes
- Most successful videos use [pattern]
- Average video length: [X:XX]
- Most engaging hooks: [Type]
```

#### B3. Save Analysis

Save to: `~/YT/_Analytics/landscape-[topic]-[date].md`

#### B4. Offer Next Steps

```
"Landscape analysis complete!

**Saved to:** ~/YT/_Analytics/landscape-[topic]-[date].md

**Key findings:**
- Most common hook: [Pattern]
- Underserved angle: [Gap]
- Best opportunity: [Idea]

Would you like me to:
1. Develop one of the recommended ideas into a full script?
2. Create a new video project based on the top opportunity?
3. Just keep the analysis for reference?
```

---

### Step 6: Create Project Folder (If Proceeding)

```bash
VIDEO_TITLE="[Sanitized Video Title]"
mkdir -p ~/YT/"$VIDEO_TITLE"/{01_Script,02_Raw_Footage/{Screen_Recordings,Face_Cam},03_Audio/{Original,Processed},04_Assets/{B-Roll,Graphics,Music_SFX},05_Project_Files,06_Exports/{Long_Form,Shorts},07_Thumbnails}
```

### Step 6.5: VERIFICATION CHECKPOINT (Required Before Script)

**Before generating any script, complete this checkpoint:**

1. **List all factual claims** you extracted from transcripts
2. **Mark each claim's source:**
   | Claim | Source | Status |
   |-------|--------|--------|
   | [Claim text] | [TRANSCRIPT: Video, 2:34] | ✅ Verified |
   | [Claim text] | Video claims, no citation | ⚠️ Unverified |
   | [Claim text] | Cannot find in transcript | ❌ Do not use |

3. **Present to user:**
   ```
   ## Verification Checkpoint

   I extracted these factual claims from the videos:

   ✅ VERIFIED (from transcript):
   - [list claims with timestamps]

   ⚠️ UNVERIFIED (video claims without citation):
   - [list claims - will attribute to "Source video claims..."]

   ❌ CANNOT USE (not found in transcripts):
   - [list any claims I'm uncertain about]

   Should I proceed with the script using only verified claims?
   Or would you like to provide sources for any unverified claims?
   ```

4. **Only proceed** after user confirms

### Step 7: Generate Script

Create a script that fits the content, not a rigid template.

---

## Script Writing Principles

### Adapt Structure to Content

Different topics need different structures:

| Content Type | Natural Structure |
|--------------|-------------------|
| Tutorial | Problem → Solution → Step-by-step demo → Variations |
| Comparison | Context → Option A → Option B → Verdict |
| Explainer | Hook → Core concept → Examples → Implications |
| News/Reaction | The news → Why it matters → Hot take → What's next |
| List/Tips | Hook → Items (varying depth based on importance) → Wrap-up |

Don't force every video into the same mold. Let the content dictate the flow.

### Format for Production

Mark sections with their recording type:
- `[FACE CAM]` - Intro, outro, transitions, personal takes
- `[SCREEN RECORDING]` - Demos, walkthroughs, code, UI
- `[SCREEN RECORDING] 🖱️` - Interactive demos needing cursor highlight

Target 10-20 minutes, but let content dictate length.

### Write for Speaking, Not Reading

- Short sentences (8-12 words)
- Natural speech patterns
- `[PAUSE]` for breath points
- `[EMPHASIS]` for energy shifts
- No tongue-twisters
- Conversational, not robotic

### Create Clip-Worthy Moments Organically

Instead of forcing "KEY TAKEAWAY" markers everywhere:

- Write bold, quotable statements that naturally summarize insights
- Make statements complete and self-contained (no "as I mentioned")
- Vary where these moments appear based on content flow
- Not every section needs a clip moment—quality over quantity
- Aim for 3-5 genuinely strong moments per video, not forced markers

### Hook Principles (First 30 Seconds)

The hook must:
- Stop the scroll immediately
- Create a curiosity gap
- Promise specific value
- Work as a standalone short

Use patterns that fit the content:
- **Surprising stat:** "[X]% of people get this wrong..."
- **Contrarian take:** "Everyone says [X]. That's wrong..."
- **Future pacing:** "By the end, you'll be able to..."
- **Problem agitation:** "If you're struggling with [X]..."
- **Curiosity gap:** "There's a reason [experts] do this..."
- **Story:** "Last week I [did something] and it changed everything..."
- **Challenge:** "I bet you've never tried [technique]..."
- **Direct promise:** "This is the fastest way to [result]..."

Pick what fits. Don't rotate mechanically.

### CTAs That Don't Feel Forced

Integrate naturally based on context:
- Subscribe mentions should feel conversational, not scripted
- Place engagement asks where they make sense, not at fixed timestamps
- One or two CTAs per video is enough—don't interrupt flow

---

## What to Include in script.md

```markdown
# [Video Title]

**Target Length:** [X] minutes (flexible based on content)
**Keywords:** [from vidIQ or analysis]
**Recording Notes:** [any special setup needed]

---

[Script content organized by natural sections]
[Mark recording types: [FACE CAM], [SCREEN RECORDING], etc.]
[Include [PAUSE] and [EMPHASIS] markers for delivery]
[Note any B-roll, graphics, or visual elements needed]

---

## Production Notes
- [Any specific visual/editing notes]
- [B-roll suggestions]
- [Graphics needed]

## Shorts Potential
- [List genuinely clip-worthy moments with timestamps]
- [Only include strong standalone moments]
```

---

## After Script: vidIQ Validation

Prompt for keyword check:

```
Quick vidIQ check before recording:

1. vidIQ → Keywords Tool
2. Search: "[primary keyword]" and alternatives
3. Paste back: KEYWORD, SCORE, VOLUME, COMPETITION, RELATED

(Or "skip vidiq" to proceed)
```

Incorporate results into title and script naturally.

---

## After Script: vidIQ AI Review

Always prompt for AI review:

```
Script ready for vidIQ AI review:

1. vidIQ → AI Coach
2. Share title + script
3. Ask for retention, SEO, virality feedback
4. Paste full feedback here
```

Incorporate feedback by updating the script directly—don't just append notes.

---

## Create todo.md

```markdown
# [Video Title] - Production Progress

**Created:** [Date]
**Current Phase:** Pre-Production
**Last Updated:** [Date/Time]

## Research & Planning
- [x] Competitor videos analyzed
- [x] Video idea selected
- [x] Folder structure created
- [ ] Topic validated in vidIQ
- [ ] Keywords incorporated

## Script
- [x] Script draft generated
- [ ] Hook alternatives tested
- [ ] Reviewed for natural flow
- [ ] Optimized for speaking
- [ ] Strong clip moments identified

## Recording
- [ ] Pre-recording checklist complete
- [ ] Screen recording complete
- [ ] Face cam recording complete
- [ ] Footage transferred

## Post-Production
- [ ] Audio processed
- [ ] Rough cut complete
- [ ] B-roll added
- [ ] Graphics added
- [ ] Color graded
- [ ] Audio mixed
- [ ] Final review

## Export & Publish
- [ ] Long-form exported
- [ ] Thumbnail created
- [ ] Metadata written
- [ ] Uploaded to YouTube
- [ ] Shorts generated (Opus Clip)
- [ ] Shorts autoposted (YouTube, LinkedIn, Instagram, Facebook, TikTok, X)

## Notes
- Research videos: [URLs]
- Unique angle: [what makes this different]
- vidIQ keywords: [add when validated]
```

---

## Save Files to Project Folder

All output goes to the VIDEO PROJECT folder:
- `~/YT/[Video Title]/01_Script/script.md`
- `~/YT/[Video Title]/01_Script/research.md`
- `~/YT/[Video Title]/todo.md`

---

## Example Interaction Flow

1. User provides YouTube URLs
2. Use Playwright MCP to navigate to each video and extract transcript
3. Identify patterns, hooks, gaps from the transcripts
4. Ask clarifying questions about intent and angle
5. Generate 3-5 tailored video ideas
6. User selects an idea
7. Create folder structure
8. **Run Verification Checkpoint** - list all claims with sources
9. Generate script adapted to topic's natural structure (after user confirms)
10. Create research.md and todo.md
11. Prompt for vidIQ validation
12. Prompt for vidIQ AI review
13. Incorporate feedback and finalize
14. **Offer metadata generation** (see Step 8: Metadata Generation below)

---

## Step 8: Metadata Generation (After Script)

After script is finalized, offer to generate YouTube metadata:

```
Script complete! Would you like me to generate YouTube metadata?

This includes:
- Optimized title (with vidIQ validation)
- Full description with timestamps
- Tags (up to 500 characters)
- Hashtags

Options:
1. Yes - Full metadata with vidIQ validation (~5 min)
2. Quick - Generate metadata without vidIQ (I'll validate later)
3. Skip - I'll do metadata manually
```

### If User Selects Full Metadata with vidIQ

Follow the structured copy-paste workflow:

#### 8a. Keyword Validation

```
## vidIQ Keyword Check

Please validate your keywords:

1. Go to: https://app.vidiq.com → Keywords Tool
2. Search these terms one at a time:

   PRIMARY: "[primary keyword from script]"
   ALT 1: "[alternative 1]"
   ALT 2: "[alternative 2]"

3. For EACH keyword, paste back:

---
KEYWORD: [keyword]
SCORE: [0-100]
VOLUME: [e.g., 12K]
COMPETITION: [Low/Medium/High]
TREND: [Rising/Stable/Declining]
RELATED: [top 5 related, comma-separated]
---

(Type "skip" to proceed without keyword data)
```

#### 8b. Title Optimization

```
## Title Check

Test your title in vidIQ:

1. Go to vidIQ → AI Title Generator (or use extension)
2. Enter: "[current title from script]"
3. Paste back:

---
TITLE: [your title]
SCORE: [0-100]
SUGGESTIONS:
1. [alt 1]
2. [alt 2]
3. [alt 3]
---

(Type "skip" to keep current title)
```

#### 8c. Tag Collection

```
## Tag Suggestions

For best tags:

1. Use vidIQ extension on a top competitor video
2. Check their tags section
3. Paste the most relevant ones:

---
COMPETITOR TAGS: [comma-separated list]
---

Or type "generate" and I'll create tags from keywords.
```

#### 8d. Generate metadata.md

Create `~/YT/[Project]/01_Script/metadata.md` with:

```markdown
# [Video Title] - YouTube Metadata

**Generated:** [Date]
**vidIQ Data:** [Complete/Partial/Skipped]

---

## TITLE

**Final Title:** "[Title]"
- Characters: XX/100
- vidIQ Score: [XX or "Not checked"]
- Primary keyword position: [X]

**Alternatives:**
1. "[Alt 1]"
2. "[Alt 2]"
3. "[Alt 3]"

---

## DESCRIPTION (Copy-Paste Ready)

```
[SEO-optimized first line with primary keyword]

[Main body - 2-3 paragraphs about the video]

⏱️ TIMESTAMPS
0:00 - Hook
[XX:XX] - [Section from script]
[XX:XX] - [Section from script]
[XX:XX] - Conclusion

🔗 RESOURCES
[Any links mentioned in video]

📱 CONNECT
[Social links]

#[hashtag1] #[hashtag2] #[hashtag3]
```

**Stats:** XXX/5000 characters

---

## TAGS (Copy-Paste Ready)

```
[primary keyword], [variation], [related], [topic], [tool name], [audience term], [question format], [long-tail phrase]
```

**Stats:** XX tags, XXX/500 characters

---

## HASHTAGS

**Description (max 3):** #[main] #[secondary] #[tertiary]
**Shorts:** #Shorts #[topic] #[tool]

---

## THUMBNAIL BRIEF

Based on your niche and competitors:
- Face: [Yes/No] with [emotion]
- Text: "[suggested overlay]"
- Colors: [scheme]
- Style: [description]

---

## PRE-UPLOAD CHECKLIST

- [ ] Title copied
- [ ] Description copied
- [ ] Tags copied
- [ ] Thumbnail ready
- [ ] End screen configured
- [ ] Cards added
- [ ] Playlist assigned

---

## VIDIQ LOG

| Keyword | Score | Volume | Competition |
|---------|-------|--------|-------------|
| [kw1] | [X] | [X] | [X] |
| [kw2] | [X] | [X] | [X] |

**Title Score:** [X] (Original) → [X] (Final)
**Data Status:** [Complete/Partial/Skipped]
```

### If User Selects Quick Metadata (No vidIQ)

Generate metadata based on:
- Keywords from script SEO section
- Best practices for the niche
- Standard YouTube patterns

Add note to metadata.md:
```
**vidIQ Data:** Skipped
**Recommendation:** Validate keywords and title in vidIQ before upload
```

### Graceful Fallback Handling

If at any point the user:
- Provides incomplete data → Use what's available, fill gaps with best practices
- Gets frustrated → Offer to skip remaining steps
- Can't access vidIQ → Generate metadata without it, add validation reminder

```
No worries! I'll generate metadata with what we have.

You can always:
1. Validate keywords in vidIQ before upload
2. Use YouTube Studio's tag suggestions
3. Check competitor descriptions for ideas

Proceeding with best-effort metadata...
```

### Update todo.md

After metadata generation, update the project's todo.md:

```markdown
## Export & Publish
- [ ] Long-form exported
- [ ] Thumbnail created
- [x] Metadata generated (01_Script/metadata.md)
- [ ] Uploaded to YouTube
```

---

## Troubleshooting

### Transcript Extraction Fails

**Symptom:** Playwright can't find transcript button or panel

**Solutions (try in order):**
1. **Check video has captions:** Some videos have no CC/transcript
2. **Try different selectors:** YouTube UI changes periodically
   - Look for "Show transcript" text button
   - Look for transcript icon (three lines)
   - Try expanding description first ("...more" button)
3. **Fallback to Python script:**
   ```bash
   cd ~/YT/_Config/scripts
   source .venv/bin/activate
   python fetch_youtube.py "VIDEO_URL" --format markdown
   ```
4. **Manual fallback:** Ask user to copy-paste transcript from YouTube

### Common Playwright Selector Issues

If YouTube updates their UI, these selectors may need updating:

| Element | Current Selector | Alternative |
|---------|-----------------|-------------|
| Transcript button | `ytd-video-description-transcript-section-renderer` | Look for "Show transcript" text |
| Transcript segments | `ytd-transcript-segment-renderer` | Check for `ytd-transcript-*` elements |
| Timestamp | `.segment-timestamp` | May change to different class |
| Text | `.segment-text` | May change to different class |

**To debug:** Take a `browser_snapshot` and look for transcript-related elements in the output.

### Playwright Hangs or Times Out

1. **Browser install:** Run `mcp__plugin_playwright_playwright__browser_install` if browser not found
2. **Close stale sessions:** Use `browser_close` before starting new extraction
3. **Check YouTube login:** Some videos require login - ask user to log in via browser first

### Video Has No Usable Transcript

Some videos won't have transcripts:
- Private videos
- Videos with disabled captions
- Very new videos (captions still processing)
- Music videos / non-speech content

**Response:** Tell user: "This video has no available transcript. Would you like to: (a) provide a manual transcript, (b) skip this video, or (c) try again later?"
