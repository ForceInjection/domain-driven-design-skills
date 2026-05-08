---
name: workflow-pattern-analyzer-web
description: Analyzes recent conversation history using chat tools to identify recurring workflow patterns and generate Custom Skills recommendations with statistical rigor. Use when users request workflow analysis, pattern identification, skill generation suggestions, or automation opportunities based on their AI usage patterns without requiring conversation exports.
---

# Workflow Pattern Analyzer (Web Compatible)

## Instructions

This skill provides comprehensive conversation pattern analysis using Claude's native chat history tools (`recent_chats` and `conversation_search`) to identify skill-worthy automation opportunities with statistical rigor.

**Core Capabilities:**
- Web interface compatible (no exports required)
- Statistical pattern validation and scoring
- Frequency analysis and temporal tracking
- Evidence-based skill recommendations
- Complete skill package generation

**Compatible with:** Claude.ai web interface, Claude Code, API

**How Analysis Works:**
- **No scripts or Python files**: This is a pure prompt-based analysis using Claude's native capabilities
- **Full content analysis**: Examines complete conversation content, messages, and patterns (not just titles or names)
- **Thread names**: Renaming conversations has minimal impact - analysis focuses on actual message content and patterns
- **Domain discovery**: Categories emerge from your actual usage data, not forced into predefined buckets
- **Data-driven approach**: Identifies YOUR specific patterns (recipes, image prompting, game design, etc.) rather than assuming business/coding focus

## Analysis Framework

### Phase 1: Data Collection Strategy

**Determine Analysis Scope:**

Ask user: "How deep should I analyze your conversation history?"

**Options:**
- **Quick Scan** (20-30 conversations, ~2-3 min): Recent patterns and immediate opportunities
- **Standard Analysis** (50-75 conversations, ~5-7 min): Comprehensive pattern detection
- **Deep Dive** (100+ conversations, ~10-15 min): Full workflow mapping with temporal trends
- **Targeted Search** (variable): Focus on specific topics or time periods

**Data Collection Process:**

1. **Broad Sampling**: Use `recent_chats(n=30)` multiple times with varied parameters to get diverse coverage
2. **Temporal Distribution**: Sample conversations across different time periods (recent, 1 week ago, 1 month ago)
3. **Topic Exploration**: Use `conversation_search` for domains mentioned by user or detected in initial sampling
4. **Depth vs Breadth**: Balance comprehensive coverage with processing efficiency

### Phase 2: Pattern Discovery & Classification

**Extract patterns using these detection methods:**

#### A. Explicit Pattern Markers
- **Repeated phrasing**: "format this as...", "make it more...", "apply X style"
- **Consistent request structures**: "create a [X] that does [Y]"
- **Recurring formatting instructions**: tables, bullet lists, specific structures
- **Tone/voice adjustments**: "more casual", "add enthusiasm", "formal version"

#### B. Implicit Workflow Patterns
- **Multi-turn conversation structures**: Same workflow across different topics
- **Iterative refinement sequences**: Request → feedback → revision cycles
- **Context re-explanation**: Same background info provided repeatedly
- **Problem-solving approaches**: Consistent debugging/analysis methodologies

#### C. Domain Discovery (Data-Driven)
- **Let domains emerge from the data** - Do NOT pre-categorize into standard domains
- **Topic frequency analysis**: Extract actual subject matter from conversations
  - Examples of specialized domains: recipe transcription, cannabis strains, image prompting, game design, book summaries
  - Examples of traditional domains: coding, business strategy, creative writing, data analysis, technical writing
- **Task type patterns**: Identify the action types that appear (creation, transformation, analysis, troubleshooting, curation, etc.)
- **Niche specialization detection**: Look specifically for narrow, specialized topics with high engagement
- **Cross-domain workflows**: Patterns that span multiple topics
- **Domain diversity scoring**: Reward finding 8-15 distinct domains vs. forcing into 3-4 buckets

**CRITICAL**: Avoid fitting patterns into predefined categories. Each user's conversation history will have unique domains based on their actual usage.

**Terminal Output - Domain Diversity Visualization:**

After completing pattern discovery, display an ASCII chart showing domain distribution:

```
📊 Domain Distribution Analysis

Business & Strategy    ████████████░░░░░░░░ 12 patterns (32%)
Creative & Writing     ██████████░░░░░░░░░░ 10 patterns (27%)
Image Prompting        ████████░░░░░░░░░░░░  8 patterns (22%)
Learning & Education   ████░░░░░░░░░░░░░░░░  4 patterns (11%)
Recipe & Cooking       ██░░░░░░░░░░░░░░░░░░  2 patterns  (5%)
Gaming & Design        █░░░░░░░░░░░░░░░░░░░  1 pattern   (3%)

✅ Domain Diversity: 6 distinct topic areas detected
✅ No predefined categorization - domains emerged from your data
```

This validates data-driven discovery of diverse patterns.

#### D. Niche & Specialized Pattern Detection

**Explicitly search for underrepresented domains:**
- **Hobbyist domains**: Recipes, cocktails, cannabis, gardening, gaming, fitness, travel planning
- **Creative domains**: Story writing, worldbuilding, character development, art direction, music composition
- **Prompt engineering**: Image generation (Midjourney, Stable Diffusion, DALL-E), video generation, AI art workflows
- **Learning & education**: Book summaries, concept explanations, study guides, teaching materials
- **Personal organization**: Resume writing, cover letters, personal branding, goal setting
- **Entertainment & media**: Game design, narrative design, content creation, video scripts
- **Wellness & lifestyle**: Meal planning, workout routines, meditation guides, habit tracking

**Detection strategy:**
- Look for concentrated clusters of 5+ conversations on the same narrow topic
- Identify specialized vocabulary/jargon (strain names, recipe terms, art styles, game mechanics)
- Find recurring templates/formats specific to that domain
- Don't dismiss low-frequency patterns if they show high consistency and complexity
- Pay special attention to patterns that appear in conversation titles or search results
- Consider that niche patterns may have lower frequency but higher value due to specialization

**Quality indicators for niche patterns:**
- Consistent terminology and domain-specific language
- Recurring output formats or structures
- User demonstrates growing expertise over time
- High engagement (longer conversations, multiple refinements)
- Clear workflow or methodology emerging

#### E. Temporal Patterns
- **Weekly/monthly recurring tasks**: Reports, summaries, check-ins
- **Event-driven patterns**: Meeting prep, post-mortems, launches
- **Seasonal trends**: Quarterly reviews, annual planning
- **Frequency trends**: Increasing/stable/decreasing over time

### Phase 3: Frequency Analysis & Validation

For each identified pattern, calculate:

#### Occurrence Metrics
- **Absolute frequency**: Total instances found in analyzed conversations
- **Relative frequency**: Percentage of conversations containing pattern
- **Temporal distribution**: First occurrence, most recent, clustering
- **Consistency score**: Similarity across pattern instances (0-100%)

#### Statistical Validation
- **Significance threshold**: Pattern must appear in >5% of conversations OR >3 absolute instances
- **Consistency requirement**: 70%+ similarity in requirements/structure across instances
- **Sample size consideration**: Adjust thresholds based on total conversations analyzed

#### Evidence Collection
- Extract 2-4 representative conversation excerpts per pattern
- Note variation types (what changes vs what stays constant)
- Document user refinement patterns (common adjustments made)

### Phase 4: Skill-Worthiness Scoring (0-10 Scale)

**Use extended reasoning to evaluate each pattern across 5 dimensions:**

#### 1. Frequency Score (0-10)
- **10**: Daily usage (20+ instances or >25% of conversations)
- **8-9**: Multiple times per week (10-20 instances or 15-25%)
- **6-7**: Weekly usage (5-9 instances or 8-15%)
- **4-5**: Bi-weekly to monthly (3-4 instances or 5-8%)
- **2-3**: Monthly or less (2 instances or 3-5%)
- **0-1**: One-off or <3% of conversations

#### 2. Consistency Score (0-10)
- **10**: Identical requirements every time (90-100% similarity)
- **8-9**: Highly consistent with minor variations (75-90%)
- **6-7**: Core structure consistent, details vary (60-75%)
- **4-5**: Recognizable pattern, significant variation (45-60%)
- **2-3**: Loosely related, different each time (30-45%)
- **0-1**: No discernible consistency (<30%)

#### 3. Complexity Score (0-10)
- **10**: Multi-step workflow with decision points, high cognitive load
- **8-9**: Complex methodology requiring expertise/frameworks
- **6-7**: Moderate complexity with structured approach
- **4-5**: Straightforward process with some nuance
- **2-3**: Simple task with minimal steps
- **0-1**: Trivial one-step operation

#### 4. Time Savings Score (0-10)
- **10**: >60 min saved per use (or >10 hours/month total)
- **8-9**: 30-60 min per use (or 5-10 hours/month)
- **6-7**: 15-30 min per use (or 2-5 hours/month)
- **4-5**: 5-15 min per use (or 1-2 hours/month)
- **2-3**: 2-5 min per use (or 30-60 min/month)
- **0-1**: <2 min per use (<30 min/month)

#### 5. Error Reduction Score (0-10)
- **10**: Critical tasks with major error consequences
- **8-9**: Common mistakes significantly impact quality
- **6-7**: Regular pitfalls that skill could prevent
- **4-5**: Occasional errors, modest quality improvement
- **2-3**: Minor inconsistencies, small quality gains
- **0-1**: No error patterns, quality already consistent

#### Composite Scoring
- **Total Score**: Sum of 5 dimensions (0-50 scale)
- **Priority Classification**:
  - **Critical** (40-50): Implement immediately
  - **High** (30-39): Strong candidates for skill creation
  - **Medium** (20-29): Consider for skill creation
  - **Low** (10-19): Defer or handle with simple prompts
  - **Not Viable** (0-9): Not worth skill automation

### Phase 5: Relationship Mapping & Consolidation

#### A. Overlap Detection
- Identify shared components across patterns
- Map overlapping functionality (>40% shared steps)
- Find hierarchical relationships (high-level task composed of sub-tasks)
- Detect sequential workflows (tasks that occur in sequence)

#### B. Consolidation Strategies

**Use extended reasoning to determine:**

- **Merge** (>60% overlap): Combine into single comprehensive skill
- **Separate with cross-reference** (30-60% overlap): Distinct skills with links
- **Hierarchical**: Main skill + specialized variants → parent/child structure
- **Modular**: Extract common elements → shared templates/references

#### C. Boundary Optimization

Each skill should have:
- **Clear purpose**: Single, well-defined use case
- **Distinct triggers**: Easy to know when to use vs other skills
- **Minimal overlap**: <30% shared functionality with other skills
- **Appropriate scope**: Not too broad (generic) or narrow (over-specialized)

### Phase 6: Prioritization Matrix

Generate 2D matrix visualization:

```
VALUE/IMPACT (High to Low)
     │
HIGH │  🔥 Quick Wins        ⭐ Strategic
     │  [High-priority         [Complex but
     │   automation]           critical]
     │
     │  ──────────────────────────────
     │
LOW  │  🔧 Automate          ⏸️  Defer
     │  [Nice-to-have         [Not worth
     │   efficiency]           automating]
     │
     └────────────────────────────────
          LOW    FREQUENCY    HIGH
```

**Classify each pattern:**
- **X-axis**: Frequency score (0-10)
- **Y-axis**: Average of Complexity, Time Savings, Error Reduction (0-10)
- **Size indicator**: Total composite score
- **Color coding**: Implementation difficulty

**Strategic Recommendations:**
1. **Top 3-5 Quick Wins**: Highest ROI (frequency × impact)
2. **Strategic Skills**: High impact even if lower frequency
3. **Quick Automations**: High frequency, simpler to implement
4. **Defer List**: Patterns not meeting skill-worthiness thresholds

### Phase 7: Skill Package Generation

For each approved skill, create:

#### A. Skill Specification Document

```markdown
## [Skill Name]

**Pattern Evidence:**
- Frequency: [X instances in Y conversations (Z%)]
- Consistency: [X/10 score]
- Time savings: [X hours/month]

**Composite Score: [X/50]**
- Frequency: [X/10]
- Consistency: [X/10]
- Complexity: [X/10]
- Time Savings: [X/10]
- Error Reduction: [X/10]

**Example Conversations:**
1. [Date]: [Brief excerpt showing pattern]
2. [Date]: [Brief excerpt showing pattern]
3. [Date]: [Brief excerpt showing pattern]

**Pattern Components:**
- **Consistent elements**: [What stays the same]
- **Variable elements**: [What changes per instance]
- **Common refinements**: [Typical adjustments user makes]

**Proposed Skill Structure:**

SKILL.md sections:
1. Overview & trigger conditions
2. [Main workflow methodology]
3. Quality standards
4. Examples

Supporting files needed:
- reference.md: [Detailed framework/methodology]
- templates/: [Reusable output templates]
- examples.md: [Additional use cases]
```

#### B. Complete SKILL.md File

Generate production-ready skill with:
- Proper YAML frontmatter (name, description with triggers)
- Clear instructions based on pattern analysis
- Evidence-based examples from actual conversations
- Quality standards derived from user refinement patterns
- Progressive disclosure (link to references for detail)

## Output Formats

After analysis completion, present:

### Summary Report

```markdown
# Workflow Pattern Analysis Report
**Analysis Date**: [Timestamp]
**Conversations Analyzed**: [X conversations across Y time period]
**Patterns Identified**: [X patterns]
**Skills Recommended**: [Y skills]

## 📊 Skill Prioritization Matrix

```mermaid
%%{init: {'theme':'base'}}%%
quadrantChart
    title Skill Prioritization: Frequency vs Impact
    x-axis Low Frequency --> High Frequency
    y-axis Low Impact --> High Impact
    quadrant-1 Strategic
    quadrant-2 Quick Wins
    quadrant-3 Defer
    quadrant-4 Automate
    [Skill Name 1]: [freq_score/10, impact_score/10]
    [Skill Name 2]: [freq_score/10, impact_score/10]
    [Skill Name 3]: [freq_score/10, impact_score/10]
```
\```

**Legend:**
- **Quick Wins** (top-right): High frequency, high impact - implement first
- **Strategic** (top-left): Lower frequency but high value - critical capabilities
- **Automate** (bottom-right): High frequency, simpler - nice efficiency gains
- **Defer** (bottom-left): Low priority - consider simple prompts instead

## 🔥 HIGH-PRIORITY OPPORTUNITIES

### 1. [Skill Name]
**Score: [X/50]** (Frequency: X/10, Consistency: X/10, Complexity: X/10, Time: X/10, Error: X/10)

**Pattern Description**: [What you do repeatedly]

**Evidence**:
- Found in [X] conversations ([Y%] of analyzed sample)
- First seen: [Date], Most recent: [Date]
- Average time per instance: [X minutes]

**Example Occurrences**:
1. [Date]: "[Brief excerpt]"
2. [Date]: "[Brief excerpt]"

**Proposed Skill**: "[One-line skill description]"

**Time Savings**: [X hours/month]

---

[Repeat for top 5-8 patterns]

## 💡 MODERATE OPPORTUNITIES
[Briefer summaries of medium-priority patterns]

## 🎯 QUICK AUTOMATION CANDIDATES
[Simple, high-frequency patterns]

## ⏸️  DEFERRED PATTERNS
[Patterns that didn't meet skill-worthiness thresholds]

## 📊 ANALYSIS METADATA
- Total conversations: [X]
- Date range: [earliest] to [latest]
- Unique patterns identified: [X]
- Patterns validated: [Y]
- Cross-pattern overlaps: [Z]
- Recommended consolidations: [N]
```

### Interactive Follow-Up Options

```
What would you like to do next?

A. Generate complete SKILL.md files for [top 3-5 skills]
B. Deep dive into specific pattern: [skill name]
C. Expand analysis with more conversations
D. Focus on specific domain/topic area
E. Adjust scoring weights and recalculate priorities
```

## Quality Standards

### Pattern Validation Requirements
- **Minimum frequency**: 3 instances OR >5% of conversations
- **Consistency threshold**: 70% similarity across instances
- **Evidence requirement**: 2-3 conversation excerpts minimum
- **Time savings minimum**: >30 min/month cumulative
- **Statistical significance**: Validated against sample size

### Skill Recommendations
- **Maximum 8-10 skills**: Focus on highest ROI patterns
- **Clear differentiation**: Each skill has distinct purpose
- **Evidence-based design**: Skill structure reflects actual usage patterns
- **Practical focus**: Prioritize patterns with real time/quality impact

### Analysis Rigor
- **No generic patterns**: Avoid broad categories like "writing" or "analysis"
- **Domain diversity validated**: Patterns should span 6+ distinct topic areas (not just business/coding)
- **Niche specializations identified**: Don't dismiss specialized patterns as outliers
- **No artificial categorization**: Avoid forcing patterns into predefined domains (coding, writing, business, analysis)
- **Validated frequencies**: Ensure counts are accurate within sample
- **Temporal awareness**: Note if pattern is emerging, stable, or declining
- **User context**: Consider user's domain expertise and role

## Examples

### Example 1: Quick Scan Request

**User**: "Analyze my recent chats for automation opportunities"

**Claude**:
I'll perform a quick scan of your recent conversation history to identify skill opportunities.

[Uses recent_chats(n=30) multiple times]

📊 **Quick Scan Results** (30 conversations analyzed)

🔥 **TOP OPPORTUNITY**:

**"Email Response Composer"** - Score: 42/50
- Found in 9 conversations (30%)
- Pattern: You regularly ask me to draft professional emails with specific tone and structure requirements
- Time savings: ~90 min/month (10 min per email × 9 emails)
- Evidence: Consistent 3-paragraph structure with greeting, main content, action items

Want me to:
A. Generate complete skill package for this
B. Continue analysis for more patterns (expand to 50-75 conversations)
C. Focus on other domains

### Example 2: Targeted Domain Analysis

**User**: "Find patterns in how I use you for coding tasks"

**Claude**:
I'll analyze your coding-related conversations to identify workflow patterns.

[Uses conversation_search for coding terms + recent_chats filtering]

📊 **Coding Workflow Analysis** (18 relevant conversations)

🔥 **TOP PATTERNS**:

1. **"Code Review Checklist Generator"** - Score: 38/50
   - Found in 7 code review discussions
   - Pattern: You ask for language-specific review checklists before reviewing PRs
   - Consistency: 85% (always includes security, performance, style sections)

2. **"API Documentation Humanizer"** - Score: 35/50
   - Found in 5 documentation tasks
   - Pattern: Converting technical API specs into developer-friendly guides
   - Structure: Always includes quick start, common use cases, troubleshooting

Want me to build skills for these patterns?

### Example 3: Deep Dive Analysis

**User**: "Do a comprehensive analysis of my workflow over the last few months"

**Claude**:
I'll perform a deep analysis of your conversation history. This will take 10-15 minutes to ensure comprehensive coverage.

[Uses recent_chats extensively, conversation_search for discovered topics, temporal sampling]

📊 **Comprehensive Workflow Analysis**
- **Conversations analyzed**: 120
- **Date range**: [3 months]
- **Patterns identified**: 15
- **Skills recommended**: 6

🔥 **CRITICAL PRIORITY** (Score 40-50):

1. **"Weekly Status Report Generator"** - Score: 47/50
   - Frequency: 12 instances (10% of conversations)
   - Consistency: 95% - always same structure
   - Evidence: Every Monday, you format updates in identical 5-section template
   - Time savings: 240 min/month (20 min/week × 4 weeks × 3 months avg)

⭐ **HIGH PRIORITY** (Score 30-39):

2. **"Client Proposal Framework"** - Score: 36/50
3. **"Meeting Notes Structurer"** - Score: 34/50
4. **"Technical Concept Explainer"** - Score: 31/50

[Full analysis report with evidence, prioritization matrix, skill specifications]

**Recommended Implementation Path**:
1. Start with "Weekly Status Report Generator" (highest ROI)
2. Build "Client Proposal Framework" and "Meeting Notes Structurer" next (complementary workflows)
3. Evaluate remaining patterns after 2-4 weeks of usage

Generate complete skill packages now? [Y/N]

## Anti-Patterns to Avoid

**Don't recommend skills for:**
- **One-off variations**: Tasks that seem similar but are fundamentally different each time
- **Over-simplified tasks**: Things easier to just ask directly than invoke a skill
- **Better solved by tools**: When external apps/services do it better
- **Insufficient data**: Patterns with <3 instances or <5% frequency (unless strategic)
- **Generic categories**: Broad skills like "help with writing" or "analyze data"

**Red flags in patterns:**
- High frequency but no consistency (chaotic variation)
- High consistency but very low frequency (use a prompt template instead)
- Pattern is declining over time (user may have found better solution)
- Task requires real-time data or external authentication (needs MCP, not skill)

## When to Use This Skill

**✅ Use this skill when:**
- User requests analysis of their conversation patterns
- User wants to identify automation opportunities
- User asks what skills they should create
- User mentions repetitive tasks or workflows
- User wants evidence-based skill recommendations
- User is in web interface (can't use export-based analysis)

**❌ Don't use this skill when:**
- User has conversation export files available (use export-based plugin instead for more comprehensive analysis)
- User wants cross-platform ChatGPT + Claude analysis (requires exports)
- User has very few conversations (<10) making pattern detection unreliable
- User wants to build specific skill they already have in mind
- User is asking about existing skills or community skills

**⚡ Proactive Use:**
When you detect potential patterns during normal conversation, offer:
```
💭 Pattern detected: This is the [Xth] time you've asked me to [action].

Would you like me to analyze your conversation history for similar 
patterns and recommend a Custom Skill? I can identify other automation 
opportunities you might not have noticed.

[Yes, analyze] [Not now]
```

## Progressive Disclosure Strategy

**Keep main analysis concise by organizing information hierarchically:**

1. **Quick overview first**: Summary report with top 3-5 opportunities
2. **Details on demand**: Expand specific patterns when user shows interest
3. **Implementation when ready**: Generate complete skill packages only after user approval
4. **Iterative refinement**: Allow user to adjust scoring weights, focus areas, or analysis depth

**Load additional detail only when:**
- User requests deep dive on specific pattern
- Generating complete skill packages (not just analysis)
- User wants to understand scoring methodology in detail
- Building skills for complex domains requiring extensive examples