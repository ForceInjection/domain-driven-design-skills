---
name: langfuse-feedback-analyst
description: Analyzes user feedback from Langfuse annotation queues and generates surgical recommendations for template.yaml, style.yaml, and tools.yaml
allowed-tools: "*"
---

# Langfuse Feedback Analyst Skill

## Purpose

Analyzes user feedback from Langfuse annotation queues and generates surgical recommendations for `template.yaml`, `style.yaml`, and `tools.yaml` configuration files.

**Architecture Context:**
- **template.yaml**: Defines document structure requirements (sections, fields, content organization)
- **style.yaml**: 5-layer style schema (constraints, signatures, patterns, dynamics) compiled into 30+ validation checks
- **tools.yaml**: Research tool configuration (patterns, atomic tool selection, composite orchestration)

The skill maps feedback patterns to specific configuration layers, producing targeted YAML edits that address quality issues found in production traces.

**CRITICAL CONSTRAINT:** Only suggest changes to config fields that are **actually read and used** by the generation architecture. Consult `CONFIG_FIELD_USAGE_MAP.md` before making recommendations - it contains the definitive list of fields that affect generation. See `learnings/pitfalls.md` for common mistakes to avoid.

## Required Inputs

1. **Annotation Queue ID**: Langfuse queue containing feedback (scores and comments if applicable)
2. **Case Folder**: Path to case config directory or name of the case to look at (all cases are in the writing ecosystem config cases)

## Workflow

### Step 1: Retrieve Annotations
**Goal**: Your first task is to retrieve the annotation queue containing user feedback. This step fetches all completed annotations (scores and comments) from Langfuse and saves them locally for analysis.

**Tool**: `helpers/retrieve_annotations.py`

**Required Input**:
- `--queue-id`: Annotation queue ID from Langfuse (e.g., `cm42abc123xyz`)
- `--include-annotations`: Flag to fetch full trace data with scores and comments
- `--output`: Path for saving JSON output (default: `/tmp/langfuse_analysis/annotations.json`)

**Optional Filters**:
- `--status completed`: Only fetch completed annotations (recommended for analysis)
- `--limit N`: Limit to first N items (useful for testing)

**Command Structure**:
```bash
# Full annotation queue retrieval (recommended for feedback analysis)
python helpers/retrieve_annotations.py \
  --queue-id <queue_id> \
  --include-annotations \
  --status completed \
  --output /tmp/feedback_analysis/annotations.json
```

**What It Does**:
1. Fetches all items from the specified annotation queue (paginated, 50 items/page)
2. Filters by status if specified (e.g., only completed annotations)
3. For each item, retrieves the full trace data including:
   - Scores (numeric ratings)
   - Comments (text feedback)
   - Trace metadata
4. Saves structured JSON output with queue info and enriched items

**Expected Output**: `annotations.json` with structure:
```json
{
  "queue_info": {
    "name": "Case 0001 Quality Review",
    "description": "User feedback for financial newsletter case"
  },
  "total_items": 25,
  "items": [
    {
      "objectId": "trace-id-123",
      "status": "completed",
      "completedAt": "2025-01-15T10:30:00Z",
      "annotations": {
        "scores": [
          {
            "name": "quality",
            "value": 7,
            "comment": "Good content but tone is too formal"
          }
        ],
        "comments": [
          {
            "content": "Lacks personality and warmth",
            "createdAt": "2025-01-15T10:29:00Z"
          }
        ],
        "trace_metadata": {
          "case_id": "0001",
          "topic": "Market analysis"
        }
      }
    }
  ]
}
```

**Authentication**:
Requires environment variables:
```bash
LANGFUSE_PUBLIC_KEY=...
LANGFUSE_SECRET_KEY=...
LANGFUSE_HOST=...  # Optional, defaults to cloud.langfuse.com
```

### Step 2: Analyze Feedback Patterns
**Goal**: Process the raw annotations and identify distinct issues organized by config file and topic. Each issue should be clearly described with supporting quotes.

**Actions**:
- Load the `annotations.json` from Step 1
- Read through all comments and scores to understand the problems
- Group feedback by config file, then by topic/issue
- For each issue:
  - Write a clear description of the problem
  - Support with relevant user quotes
  - Note which config section it likely affects

**Output**: `feedback_analysis.md` - Structured analysis organizing issues by config file and topic:
```markdown
# Feedback Analysis

## style.yaml Issues

### Issue: Tone is too formal and impersonal
**Description**: Users consistently report that the writing style feels stiff, corporate, and lacks warmth. The content reads like formal business communication rather than engaging reader-focused content.

**Supporting Quotes**:
- "Too stiff and corporate"
- "Lacks personality and warmth"
- "Reads like a press release, not a newsletter"
- "Would prefer more conversational tone"

**Likely Config Section**: `signatures.tone`

### Issue: Inconsistent voice throughout content
**Description**: The writing voice shifts between formal and casual, making it unclear who the target audience is.

**Supporting Quotes**:
- "Switches between formal and casual unexpectedly"
- "First half is professional, second half too chatty"
- "Unclear who this is written for"

**Likely Config Section**: `signatures.voice` or `dynamics.audience_adaptation`

---

## template.yaml Issues

### Issue: Missing context/background section
**Description**: Content jumps directly into analysis without providing necessary background or market context. Users expect a setup section before diving into details.

**Supporting Quotes**:
- "Need more background information upfront"
- "Jumps into analysis without context"
- "Where's the market overview? I'm lost"
- "Assumes I know what happened yesterday"

**Likely Config Section**: `sections` (needs new section added)

### Issue: Summary section contains too much detail
**Description**: The summary section is too dense and detailed, defeating its purpose as a quick overview.

**Supporting Quotes**:
- "Summary is almost as long as the full analysis"
- "Too much detail in what should be a quick overview"

**Likely Config Section**: `requirements.summary.word_count` or similar

---

## tools.yaml Issues

### Issue: Data appears outdated
**Description**: The information presented doesn't reflect recent developments, suggesting research tools aren't pulling current enough data.

**Supporting Quotes**:
- "Information seems outdated"
- "Missing the news from this morning"
- "Need more current sources"

**Likely Config Section**: `research_patterns` (date ranges or tool selection)

### Issue: Insufficient depth on key topics
**Description**: Important topics are covered too superficially, lacking the depth users expect.

**Supporting Quotes**:
- "Glosses over the most important part"
- "Need more detail on earnings impact"
- "Too surface level"

**Likely Config Section**: `research_patterns` (tool orchestration or additional steps)
```

**Save Location**: `/tmp/feedback_analysis/feedback_analysis.md`

### Step 3: Load Relevant Configuration Files
**Goal**: Load the config files that need changes based on the feedback analysis.

**Actions**:
- Review `feedback_analysis.md` to see which files have issues
- Load the relevant YAML files from the case folder
- Parse and read the current configuration

**Output**: Config files loaded in memory

### Step 4: Map Issues to Config Sections
**Goal**: For each issue in the feedback, identify exactly where in the config file it needs to be addressed.

**CRITICAL:** Before mapping, consult `CONFIG_FIELD_USAGE_MAP.md` to verify the target field is actually used by the generation system. Only map issues to fields listed in the "Actually Used" sections.

**Actions**:
- For each issue in `feedback_analysis.md`:
  - Verify the target config field is in CONFIG_FIELD_USAGE_MAP.md
  - Locate the exact section in the loaded config file
  - Extract the current value/configuration
  - Document what needs to change based on the issue description
  - **Skip** if the logical target field is not used by the architecture (document as "No actionable field available")

**Output**: Issue-to-config mapping:
```json
{
  "tone_too_formal": {
    "file": "style.yaml",
    "section": "signatures.tone",
    "current_value": "professional, authoritative",
    "problem": "Users report tone is too stiff and impersonal; needs more warmth and conversational elements"
  },
  "inconsistent_voice": {
    "file": "style.yaml",
    "section": "signatures.voice",
    "current_value": "analytical, data-driven",
    "problem": "Voice shifts between formal and casual; needs consistent target audience definition"
  },
  "missing_context_section": {
    "file": "template.yaml",
    "section": "sections",
    "current_value": ["summary", "analysis", "outlook"],
    "problem": "Template missing background/context section; users need setup before analysis"
  },
  "outdated_data": {
    "file": "tools.yaml",
    "section": "research_patterns.default.steps",
    "problem": "Date ranges or tool selection not pulling recent enough information"
  }
}
```

### Step 5: Generate Recommendations
**Actions**:
- For each mapped issue, generate specific YAML changes:
  - **template.yaml**: Structural modifications (sections, word counts, etc.)
  - **style.yaml**: Rule adjustments (tone, formality, constraints, patterns)
  - **tools.yaml**: Research pattern refinements (tool selection, parameters)
- Ensure changes are surgical (minimal diff, maximal impact)
- Provide before/after examples for each recommendation
- Include rationale linking feedback to change

**Field Selection:** Consult `CONFIG_FIELD_USAGE_MAP.md` for:
- Which fields are actually read by the generation system
- Priority hierarchy (HIGH/MEDIUM/LOW impact changes)
- Fields to avoid (metadata, documentation-only, unimplemented features)

**Output**: Structured recommendations with diffs
```yaml
# Recommendation for style.yaml
file: style.yaml
section: signatures.tone
issue: "Tone too formal (15/25 feedback items, avg score 3.2)"

current:
  tone:
    value: "professional, authoritative"
    rubric: "Maintain formal business tone"

recommended:
  tone:
    value: "professional yet approachable, conversational"
    rubric: "Balance expertise with warmth; use 2nd person occasionally"

rationale: |
  60% of low-score feedback cited "too stiff" or "lacks personality".
  Adjusting tone signature to allow conversational elements while
  maintaining professionalism should address this pattern.
```

### Step 6: Generate Executive Summary
**Goal**: Create a concise executive summary of the analysis for quick review.

**Actions**:
- Compile top issues identified in Step 2
- List recommended config file adjustments from Step 5
- Keep it brief and actionable

**Output**: `executive_summary.md` with:
```markdown
# Executive Summary

## Top Issues Identified
1. **Tone too formal** (style.yaml) - Users find content stiff and impersonal
2. **Missing context section** (template.yaml) - Content lacks background setup
3. **Outdated data** (tools.yaml) - Research not pulling recent information

## Recommended Adjustments
- **style.yaml**: Adjust `signatures.tone` to allow conversational elements
- **template.yaml**: Add context/background section to document structure
- **tools.yaml**: Update date ranges in research patterns for current data

See `analysis_report.md` for detailed recommendations with before/after YAML changes.
```