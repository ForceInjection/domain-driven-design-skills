---
name: workflow-schema-composer
description: |
  This skill should be used when the user wants to create a new looplia workflow, generate
  a workflow definition file, or compose workflow steps from skill recommendations. Use when
  someone says "create a looplia workflow", "generate workflow.md", "compose workflow steps",
  "build me an automation pipeline", or "/build" (final step).

  Final step in looplia workflow building: transforms skill recommendations into valid v0.6.3
  workflow YAML/Markdown files. Each step uses skill: + mission: syntax, following the one
  workflow step → one skill-executor → multiple skills architecture.

  v0.6.3: Supports input-less workflows using input-less capable skills (e.g., search).
model: claude-haiku-4-5-20251001
---

# Workflow Schema Composer

Generate complete, valid workflow definitions from skill recommendations.

## Purpose

Transform the output from skill-capability-matcher into a ready-to-use looplia workflow markdown file that follows the v0.6.2 schema.

## Process

### Step 1: Receive Inputs

From skill-capability-matcher output:
- Skill sequence with step IDs
- Mission descriptions for each step
- Data flow dependencies
- Original user requirements
- **Explicit name (if `--name` flag was provided)** - use this exact name for the workflow

### Step 1.5: Parse User Preferences from Enriched Prompt (v0.6.4)

**CRITICAL: User preferences from wizard answers MUST be incorporated into step missions.**

When the enriched prompt contains "User clarifications: Q: ... A: ..." sections, extract each preference:

**Example enriched prompt:**
```
/build search hackernews for AI news. User clarifications: Q: Which social media platforms? A: twitter, linkedin. Q: How many articles? A: top5. Q: Focus areas? A: llm, adoption. Q: Output format? A: posts
```

**Extract as structured preferences:**

| Question Pattern | Preference Key | Value | Inject Into |
|-----------------|----------------|-------|-------------|
| "platforms" / "social media" | PLATFORMS | twitter, linkedin | Output/social step mission |
| "how many" / "articles" / "count" | COUNT | 5 | Search/filter step mission |
| "focus" / "areas" / "topics" | FOCUS | llm, adoption | Search and analysis missions |
| "format" / "output" / "include" | FORMAT | posts | Final output step mission |

**Preference Injection Rules:**

1. **COUNT preferences** → Add to search/fetch step: "Find **top 5** articles..."
2. **FOCUS preferences** → Add to search and analysis: "...focusing on **LLM and adoption** trends"
3. **PLATFORM preferences** → Add to output step: "...optimized for **twitter and linkedin**"
4. **FORMAT preferences** → Add to output step: "Create **posts** (not reports)..."

### Step 2: Design Steps

For each recommended skill:

```yaml
- id: {suggestedStepId}
  skill: {skill-name}
  mission: |
    {mission description from matcher}
  needs: [{dependencies}]
  input: {input path(s)}
  output: {output path}
  model: {optional model override}
  validate:
    required_fields: [{fields}]
```

### Step 3: Resolve Dependencies

Use `dataFlow` from matcher:
- Steps with no dependencies: `needs:` is omitted
- Dependent steps: list all required step IDs in `needs:`
- Final step: add `final: true`

### Step 4: Design Input/Output Paths

Use variable substitution:
- `${{ sandbox }}/inputs/content.md` - Initial input (for workflows requiring input)
- `${{ sandbox }}/outputs/{step-id}.json` - Step outputs
- `${{ steps.{id}.output }}` - Reference previous step output

#### Input-Less Capable Skills (v0.6.3)

These skills can operate WITHOUT an input field - they fetch/generate data autonomously:

| Skill | Capability |
|-------|------------|
| `search` | Web search, API queries, autonomous data fetching |

**When a workflow's first step uses an input-less capable skill:**
1. **OMIT the `input:` field entirely** from that step
2. The mission description drives the skill's behavior
3. Subsequent steps reference the output: `${{ steps.{id}.output }}`

**Example input-less first step:**
```yaml
- id: fetch-data
  skill: search
  mission: |
    Search the web for recent technology trends.
    Extract titles, URLs, and key details.
  output: ${{ sandbox }}/outputs/data.json
  # NO input field - search operates autonomously
```

### Step 5: Suggest Validation

Based on skill output type:
- Analysis skills: `required_fields: [contentId, headline, keyThemes]`
- Idea skills: `required_fields: [contentId, hooks, angles]`
- Assembly skills: `required_fields: [contentId, suggestedOutline]`

### Step 6: Compose Frontmatter

**CRITICAL: If `--name` flag was provided, use that exact name. Do not derive or modify it.**

```yaml
---
name: {explicit-name OR derived-from-description}
version: 1.0.0
description: {user's original description, cleaned up}

steps:
  - id: ...
---
```

Naming rules:
1. If `--name article-summary` was provided → use `article-summary` exactly
2. If no `--name` → derive from description (e.g., "analyze videos" → "video-analyzer")
3. Always use kebab-case for names

### Step 7: Generate Markdown Body

Add usage documentation:

**For workflows requiring input:**
```markdown
# {Workflow Name}

{Brief description}

## Usage

```bash
looplia run {workflow-name} --file <content.md>
```
```

**For input-less workflows (v0.6.3):**
```markdown
# {Workflow Name}

{Brief description}

## Usage

```bash
looplia run {workflow-name}
```

No input required - this workflow uses autonomous skills to fetch data.
```

**Steps section:**
```markdown
## Steps

1. **{step-id}**: {brief description}
2. ...
```

## Output Format

Return a JSON object:

```json
{
  "filename": "video-to-blog.md",
  "content": "---\nname: video-to-blog\n..."
}
```

## Schema Reference

See SCHEMA.md in this skill directory for the complete v0.6.2 workflow schema.

## Validation Rules (v0.6.3)

1. **`skill:` is REQUIRED** - Every step must have a skill
2. **`mission:` is REQUIRED** - Every step must have a mission
3. **`run:` is FORBIDDEN** - Never use the old agent syntax
4. **Step IDs must be unique** - No duplicates
5. **Dependencies must exist** - All `needs:` references must be valid
6. **No circular dependencies** - Validate topological ordering
7. **Respect explicit `--name`** - If provided, use that exact name for filename and `name:` field
8. **Input-less steps (v0.6.3)** - Steps using `search` skill may OMIT `input:` field entirely

## Example Output

```yaml
---
name: video-to-blog
version: 1.0.0
description: Analyze YouTube videos and create blog outlines

steps:
  - id: analyze-content
    skill: media-reviewer
    mission: |
      Deep analysis of video transcript. Extract key themes,
      important quotes with timestamps, and narrative structure.
    input: ${{ sandbox }}/inputs/content.md
    output: ${{ sandbox }}/outputs/analysis.json
    model: haiku
    validate:
      required_fields: [contentId, headline, keyThemes, importantQuotes]

  - id: generate-ideas
    skill: idea-synthesis
    mission: |
      Generate hooks, angles, and questions from the analysis.
      Read user profile for personalization context.
    needs: [analyze-content]
    input: ${{ steps.analyze-content.output }}
    output: ${{ sandbox }}/outputs/ideas.json
    validate:
      required_fields: [contentId, hooks, angles, questions]

  - id: build-outline
    skill: writing-kit-assembler
    mission: |
      Create structured blog outline with sections, key points,
      and supporting quotes from analysis and ideas.
    needs: [analyze-content, generate-ideas]
    input:
      - ${{ steps.analyze-content.output }}
      - ${{ steps.generate-ideas.output }}
    output: ${{ sandbox }}/outputs/outline.json
    final: true
    validate:
      required_fields: [contentId, suggestedOutline]
---

# Video to Blog Workflow

Transform video content into structured blog outlines.

## Usage

```bash
looplia run video-to-blog --file <transcript.md>
```

## Steps

1. **analyze-content**: Deep analysis using media-reviewer skill
2. **generate-ideas**: Idea synthesis with user personalization
3. **build-outline**: Assemble outline using writing-kit-assembler skill
```

## Important Rules

1. **Always use skill: syntax** - Never use `run: agents/X`
2. **Always include mission** - Detailed task description
3. **Use valid YAML** - Proper indentation and quoting
4. **Include validation** - Add `validate:` with appropriate fields
5. **Mark final step** - Last step gets `final: true`
6. **Respect --name flag** - If `--name X` is provided, the workflow MUST be named `X` and saved as `X.md`
7. **Detect input-less workflows** - If first step uses `search` skill, OMIT input field
8. **Incorporate user preferences (v0.6.4)** - Extract preferences from "User clarifications" and inject into step missions. Each preference MUST appear in at least one mission.

## Example: Input-Less Workflow (v0.6.3)

When the workflow fetches data autonomously (no user input needed):

```yaml
---
name: daily-news-digest
version: 1.0.0
description: Fetch trending news and compile a digest report

steps:
  - id: fetch-news
    skill: search
    mission: |
      Search the web for today's trending technology news.
      Extract title, URL, source, and brief summary for each story.
    output: ${{ sandbox }}/outputs/news.json
    # NO input field - search operates autonomously
    validate:
      required_fields: [query, mode, results]

  - id: compile-digest
    skill: content-documenter
    mission: |
      Compile the news into a formatted digest with categories and insights.
    needs: [fetch-news]
    input: ${{ steps.fetch-news.output }}
    output: ${{ sandbox }}/outputs/digest.json
    final: true
    validate:
      required_fields: [reportTitle, sections, summary]
---

# Daily News Digest

Fetches and compiles trending news into a digest.

## Usage

```bash
looplia run daily-news-digest
```

No input required - this workflow fetches data autonomously.
```

## Example: User Preference Injection (v0.6.4)

Given enriched prompt:
```
/build search hackernews for AI news. User clarifications: Q: Which platforms? A: twitter, linkedin. Q: How many? A: top5. Q: Focus areas? A: llm, adoption. Q: Output format? A: posts
```

**Extracted preferences:**
- PLATFORMS: twitter, linkedin
- COUNT: 5
- FOCUS: llm, adoption
- FORMAT: posts

**BAD workflow (ignores preferences):**
```yaml
- id: fetch-news
  skill: search
  mission: |
    Search HackerNews for AI news articles.
    Extract titles and summaries.

- id: compile-output
  skill: content-documenter
  mission: |
    Compile the news into a report.
```

**GOOD workflow (incorporates preferences):**
```yaml
- id: fetch-news
  skill: search
  mission: |
    Search HackerNews for the top 5 AI news articles
    focusing on LLM developments and adoption trends.
    Extract titles, URLs, and key summaries.

- id: compile-output
  skill: content-documenter
  mission: |
    Create engaging social media posts optimized for
    twitter and linkedin. Focus on LLM and adoption angles.
    Output as posts, not a formal report.
```
